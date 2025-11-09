-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_080, stg_080;

-- =======================================
-- Load dim_param
-- =======================================

-- Step 1: Truncate target table
TRUNCATE TABLE dim_param RESTART IDENTITY CASCADE;

INSERT INTO dwh_080.dim_param (
  param_id, paramname, category, purpose, unit
)
SELECT
    p.id,
    p.paramname,
    p.category,
    p.purpose,
    p.unit
FROM stg_080.tb_param p;
