SET search_path TO dwh_080, stg_080;

WITH reading_value_anomalies AS 
(
  SELECT
    SUM(CASE WHEN recordedvalue < 0 THEN 1 ELSE 0 END) AS negative_readings,
    SUM(CASE WHEN recordedvalue > 1000000 THEN 1 ELSE 0 END) AS implausibly_large
  FROM ft_readingevent
)
SELECT
  negative_readings,
  implausibly_large,
  CASE WHEN COALESCE(negative_readings,0)=0 AND COALESCE(implausibly_large,0)=0 THEN 'OK' ELSE 'fail' END AS status_check,
  CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM reading_value_anomalies;


