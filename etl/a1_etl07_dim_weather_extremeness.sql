-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_080, stg_080;

-- =======================================
-- Load dim_weather_extremeness
-- =======================================

-- Step 1: Truncate target table
TRUNCATE TABLE dim_weather_extremeness RESTART IDENTITY CASCADE;

