-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_080, stg_080;

-- =======================================
-- Load dim_city
-- =======================================

-- Step 1: Truncate target table
TRUNCATE TABLE dim_city RESTART IDENTITY CASCADE;

INSERT INTO dwh_080.dim_city (
  city_id, name, country, population, latitude, longitude
)
SELECT
    c.id AS city_id,
    c.cityname AS name,
    co.countryname AS country,
    c.population,
    c.latitude,
    c.longitude
FROM stg_080.tb_city c
JOIN stg_080.tb_country co ON co.id = c.countryid;