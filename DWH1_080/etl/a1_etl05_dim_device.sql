-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_080, stg_080;

-- =======================================
-- Load dim_device
-- =======================================

-- Step 1: Truncate target table
TRUNCATE TABLE dim_device RESTART IDENTITY CASCADE;

INSERT INTO dwh_080.dim_device (
  device_id, sensortype, manufacturer, technology, locationname, locationtype, altitude, installdate, city, country
)
SELECT
    d.id AS device_id,
    st.typename AS sensortype,
    st.manufacturer,
    st.technology,
    d.locationname,
    d.locationtype,
    d.altitude,
    d.installedat AS installdate,
    c.cityname AS city,
    co.countryname AS country
FROM stg_080.tb_sensordevice d
JOIN stg_080.tb_sensortype  st ON st.id = d.sensortypeid
JOIN stg_080.tb_city c ON c.id  = d.cityid
JOIN stg_080.tb_country co ON co.id = c.countryid;
