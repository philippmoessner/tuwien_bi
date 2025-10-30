-- Make A1 dwh_xxx schema the default for this session
SET search_path TO dwh_080, stg_080;

-- =============================================
-- Check correct range of extracted alert levels
-- =============================================

WITH levels AS ( 
    SELECT MIN(alertlevel) AS alert_min, MAX(alertlevel) AS alert_max
    FROM ft_readingevent
)
SELECT lv.alert_min, lv.alert_max, CASE WHEN lv.alert_min = 0 AND lv.alert_max = 4 THEN 'OK' ELSE 'fail' END AS status_check
FROM levels as lv