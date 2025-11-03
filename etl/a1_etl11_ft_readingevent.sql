SET search_path TO dwh_080, stg_080;

TRUNCATE TABLE ft_readingevent RESTART IDENTITY CASCADE;

INSERT INTO dwh_080.ft_readingevent (
    timeday_key,
    city_key,
    device_key,
    param_key,
    reading_mode_id,       
    weather_extremeness_id,
    power_plan_id,  
    recordedvalue,
    datavolumekb,
    dataquality,
    alertlevel
)
SELECT
    td.id AS timeday_key,
    dc.city_key AS city_key,
    dd.device_key AS device_key,
    dp.param_key AS param_key,
    drm.reading_mode_id,  
    COALESCE(dwe_rule.id, dwe_normal.id) AS weather_extremeness_id,  
    COALESCE(dpp.power_plan_id, dpp_any.power_plan_id) AS power_plan_id,
    r.recordedvalue AS recordedvalue,
    r.datavolumekb AS datavolumekb,
    r.dataquality AS dataquality,
    ac.alertlevel AS alertlevel

FROM stg_080.tb_readingevent r

JOIN stg_080.tb_sensordevice sd ON sd.id = r.sensordevid
JOIN stg_080.tb_city c ON c.id = sd.cityid
JOIN dwh_080.dim_timeday td ON td.full_date = r.readat
JOIN dwh_080.dim_device dd ON dd.device_id = r.sensordevid
JOIN dwh_080.dim_city dc ON dc.city_id = c.id
JOIN dwh_080.dim_param dp ON dp.param_id = r.paramid

LEFT JOIN stg_080.tb_readingmode rm
       ON rm.id = r.readingmodeid
LEFT JOIN dwh_080.dim_reading_mode drm
       ON drm.modename = rm.modename
      AND rm.validfrom = drm.validfrom
      AND COALESCE(rm.validto, DATE '2999-12-31') = COALESCE(drm.validto, DATE '2999-12-31')

LEFT JOIN LATERAL (
  SELECT dwe_rule.id
  FROM stg_080.tb_weather w
  JOIN dwh_080.dim_weather_extremeness dwe_rule
    ON dwe_rule.extremeness_flag = CASE
      WHEN (w.tempdaymax <= 0 OR w.tempdaymin <= -5 OR w.tempdayavg <= 0) THEN 'ColdSnap'
      WHEN w.tempdaymax >= 35 THEN 'Heatwave'
      WHEN w.precipmm   >= 30 THEN 'HeavyRain'
      WHEN w.windspeed  >= 15 OR w.windgusts >= 30 THEN 'HighWind'
      ELSE 'Normal'
    END
  WHERE w.cityid = c.id
    AND w.observedat <= r.readat
  ORDER BY w.observedat DESC
  LIMIT 1
) dwe_rule ON TRUE

LEFT JOIN LATERAL (
  SELECT dwe_normal.id
  FROM dwh_080.dim_weather_extremeness dwe_normal
  WHERE dwe_normal.extremeness_flag = 'Normal'
  LIMIT 1
) dwe_normal ON TRUE

LEFT JOIN LATERAL (
    SELECT dpwr.power_plan_id
    FROM stg_080.tb_device_power_plan dmap
    JOIN dwh_080.dim_power_plan dpwr
      ON dpwr.power_plan_nk = dmap.power_planid
    WHERE dmap.sensordevid = sd.id
      AND r.readat BETWEEN dmap.validfrom AND COALESCE(dmap.validto, DATE '2999-12-31')
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
) dpp_any ON TRUE

LEFT JOIN (
    SELECT
        r2.id AS reading_id,
        COALESCE(MAX(MOD(pa.alertid, 100)), 0) AS alertlevel
    FROM stg_080.tb_readingevent r2
    LEFT JOIN stg_080.tb_paramalert pa
           ON pa.paramid = r2.paramid
          AND r2.recordedvalue >= pa.threshold
    GROUP BY r2.id
) ac ON ac.reading_id = r.id;

ANALYZE ft_readingevent;



