SET search_path TO dwh_080, stg_080;

TRUNCATE TABLE dim_reading_mode RESTART IDENTITY CASCADE;

INSERT INTO dwh_080.dim_reading_mode (
    modename,
    latency,
    validfrom,
    validto,
    details
)
SELECT 
    modename,
    latency,
    validfrom,
    validto,
    details
FROM stg_080.tb_readingmode;

ANALYZE dim_reading_mode;