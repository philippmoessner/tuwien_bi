-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_080, stg_080;

-- =======================================
-- Load ft_readingevent (seed, FK-safe)
-- =======================================

-- 1) Truncate target
TRUNCATE TABLE ft_readingevent RESTART IDENTITY CASCADE;

-- 2) Insert a small, valid seed set
INSERT INTO dwh_080.ft_readingevent (
    timeday_key,
    city_key,
    device_key,
    param_key,
    weather_extremeness_key,
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
    NULL AS weather_extremeness_key,
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


-- 3) Refresh stats (optional but recommended)
ANALYZE ft_readingevent;



