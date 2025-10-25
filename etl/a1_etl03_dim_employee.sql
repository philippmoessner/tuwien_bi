-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_080, stg_080;

-- =======================================
-- Load dim_employee
-- =======================================

-- Step 1: Truncate target table
TRUNCATE TABLE dim_employee RESTART IDENTITY CASCADE;

INSERT INTO dwh_080.dim_employee (
  badgenumber, rolename, rolelevel, category, valid_from, valid_to, is_active, months_of_education
)
SELECT
    e.badgenumber,
    r.rolename,
    r.rolelevel,
    r.category,
    e.validfrom,
    e.validto,
    (e.validto IS NULL) AS is_active,
    NULL::INT AS months_of_education
FROM stg_080.tb_employee e
JOIN stg_080.tb_role r ON r.id = e.roleid;
