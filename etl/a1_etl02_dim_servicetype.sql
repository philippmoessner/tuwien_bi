-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_080, stg_080;

-- =======================================
-- Load dim_servicetype
-- =======================================

-- Step 1: Truncate target table
TRUNCATE TABLE dim_servicetype RESTART IDENTITY CASCADE;

INSERT INTO dwh_080.dim_servicetype (
  servicetype_id, typename, servicegroup, category, minlevel, details
)
SELECT
  st.id,
  st.typename,
  st.servicegroup,
  st.category,
  st.minlevel,
  st.details
FROM stg_080.tb_servicetype st;