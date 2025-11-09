-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_080, stg_080;

-- =======================================
-- Load dim_timeday
-- =======================================

-- Step 1: Truncate target table, the dim_timeday in this case
TRUNCATE TABLE dim_timeday RESTART IDENTITY CASCADE;

-- Step 2: Insert data into the dim_timeday
INSERT INTO dwh_080.dim_timeday (
    id,
    full_date,
    day_num,
    month_num,
    year_num
)
SELECT
    TO_CHAR(d::date, 'YYYYMMDD')::INT AS id,
    d::date AS full_date,
    EXTRACT(DAY   FROM d)::INT AS day_num,
    EXTRACT(MONTH FROM d)::INT AS month_num,
    EXTRACT(YEAR  FROM d)::INT AS year_num
FROM generate_series('2023-01-01'::date, '2024-12-31'::date, interval '1 day') AS g(d);