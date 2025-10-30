-- Make A1 dwh_xxx schema the default for this session
SET search_path TO dwh_080, stg_080;

-- ==================================================
-- Check correct education duration for all employees
-- ==================================================

WITH role_edu AS (
    SELECT b.role_id, SUM(c.months_of_education) AS ed_dur
    FROM stg_080.tb_roletocertificate AS b
    JOIN stg_080.tb_certificates AS c
        ON b.certificate_id = c.id
    GROUP BY b.role_id
),
employees AS (
    SELECT COUNT(de.employee_key) AS total_employees
    FROM dwh_080.dim_employee AS de
),
sub_result AS (
SELECT
  (SELECT COUNT(*)
   FROM dwh_080.dim_employee de
   JOIN role_edu re ON de.role_id = re.role_id
   WHERE re.ed_dur = de.months_of_education) AS correct_edu_durations,
  (SELECT COUNT(*) FROM dwh_080.dim_employee) AS total_employees
)
SELECT correct_edu_durations, 
        total_employees, 
        CASE WHEN s.correct_edu_durations = s.total_employees THEN 'OK' ELSE 'fail' END AS status_check,
        CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM sub_result s;