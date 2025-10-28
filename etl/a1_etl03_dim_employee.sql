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
WITH role_edu AS (
  SELECT
    rc.role_id,
    COALESCE(SUM(c.months_of_education), 0) AS months_of_education
  FROM stg_080.tb_roletocertificate rc
  JOIN stg_080.tb_certificates c ON c.id = rc.certificate_id
  GROUP BY rc.role_id
)
SELECT
  e.badgenumber,
  r.rolename,
  r.rolelevel,
  r.category,
  e.validfrom,
  e.validto,
  (e.validto IS NULL) AS is_active,
  COALESCE(re.months_of_education, 0) AS months_of_education
FROM stg_080.tb_employee e
JOIN stg_080.tb_role r ON r.id = e.roleid
LEFT JOIN role_edu re ON re.role_id = r.id;

