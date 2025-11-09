-- Make A1 dwh_xxx schema the default for this session
SET search_path TO dwh_080, stg_080;

-- ===============================================
-- Check equal number of entries for serviceevents
-- ===============================================
WITH dwh_re AS 
(
  SELECT '080' as group_num
  	, COUNT(id) as dwh_count
  FROM ft_serviceevent
),
stg_re AS 
(
  SELECT '080' as group_num
  	, COUNT(id) as stg_count
  FROM tb_serviceevent
)
SELECT
  d.dwh_count
  , s.stg_count
  , CASE WHEN d.dwh_count = s.stg_count THEN 'OK' ELSE 'fail' END AS status_check
  , CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM dwh_re d
INNER JOIN stg_re s on d.group_num = s.group_num


