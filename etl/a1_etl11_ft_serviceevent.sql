-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_080, stg_080;

-- =======================================
-- Load ft_serviceevent (seed, FK-safe)
-- =======================================

-- 1) Truncate target
TRUNCATE TABLE ft_serviceevent RESTART IDENTITY CASCADE;

-- 2) Insert a small, valid seed set
INSERT INTO dwh_080.ft_serviceevent (
  timeday_key, servicetype_key, employee_key, city_key, device_key,
  service_cost, service_duration_minutes, service_quality,
  qualified_work, overqualified_work
)
SELECT
    td.id AS timeday_key,
    dst.servicetype_key AS servicetype_key,
    de.employee_key AS employee_key,
    dc.city_key AS city_key,
    dd.device_key AS device_key,
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
JOIN dwh_080.dim_employee de ON de.badgenumber = e.badgenumber;

-- 3) Refresh stats (optional but recommended)
ANALYZE ft_serviceevent;

