SET search_path TO dwh_080, stg_080;

TRUNCATE TABLE ft_serviceevent RESTART IDENTITY CASCADE;

INSERT INTO dwh_080.ft_serviceevent (
    timeday_key,
    servicetype_key,
    employee_key,
    city_key,
    device_key,
    power_plan_id,        
    service_cost,
    service_duration_minutes,
    service_quality,
    qualified_work,
    overqualified_work
)
SELECT
    td.id AS timeday_key,
    dst.servicetype_key AS servicetype_key,
    de.employee_key AS employee_key,
    dc.city_key AS city_key,
    dd.device_key AS device_key,

    COALESCE(dpp.power_plan_id, dpp_any.power_plan_id) AS power_plan_id,

    se.servicecost AS service_cost,
    se.durationminutes AS service_duration_minutes,
    se.servicequality AS service_quality,

    CASE WHEN de.rolelevel = dst.minlevel THEN 1 ELSE 0 END AS qualified_work,
    CASE WHEN de.rolelevel > dst.minlevel THEN 1 ELSE 0 END AS overqualified_work

FROM stg_080.tb_serviceevent se
JOIN stg_080.tb_sensordevice sd ON sd.id = se.sensordevid
JOIN stg_080.tb_city c ON c.id  = sd.cityid
JOIN dwh_080.dim_timeday td ON td.full_date = se.servicedat
JOIN dwh_080.dim_servicetype dst ON dst.servicetype_id = se.servicetypeid
JOIN dwh_080.dim_device dd ON dd.device_id = se.sensordevid
JOIN dwh_080.dim_city dc ON dc.city_id = c.id
JOIN stg_080.tb_employee e ON e.id = se.employeeid
JOIN dwh_080.dim_employee de ON de.badgenumber = e.badgenumber AND se.servicedat BETWEEN de.valid_from AND COALESCE(de.valid_to, DATE '2999-12-31')

LEFT JOIN LATERAL (
    SELECT dpwr.power_plan_id
    FROM stg_080.tb_device_power_plan dmap
    JOIN dwh_080.dim_power_plan dpwr
        ON dpwr.power_plan_nk = dmap.power_planid
    WHERE dmap.sensordevid = sd.id
      AND se.servicedat BETWEEN dmap.validfrom AND COALESCE(dmap.validto, DATE '2999-12-31')
    ORDER BY dmap.validfrom DESC
    LIMIT 1
) dpp ON TRUE

LEFT JOIN LATERAL (
    SELECT dpwr2.power_plan_id
    FROM stg_080.tb_device_power_plan dmap2
    JOIN dwh_080.dim_power_plan dpwr2
      ON dpwr2.power_plan_nk = dmap2.power_planid
    WHERE dmap2.sensordevid = sd.id
    ORDER BY dmap2.validfrom DESC
    LIMIT 1
) dpp_any ON TRUE;

ANALYZE ft_serviceevent;
