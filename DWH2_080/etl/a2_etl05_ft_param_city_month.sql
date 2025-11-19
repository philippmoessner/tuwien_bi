-- Assignment 2 ETL: ft_param_city_month
-- GRAIN: month_key × city_key × param_key

-- EXAMPLE SHAPE (sketch only):
-- TRUNCATE TABLE ft_param_city_month;
-- WITH cte1 AS (...),
--      cte2 AS (...),
--      cte3 AS (...),
--      ... AS (...),
--      final_cte AS (...)
-- INSERT INTO ft_param_city_month (...columns...)
-- SELECT ... FROM final_cte;

-- Make A2 dwh2_xxx, stg2_xxx schemas the default for this session
SET search_path TO dwh2_080, stg2_080;

-- =======================================
-- Load ft_param_city_month
-- =======================================

TRUNCATE TABLE ft_param_city_month RESTART IDENTITY CASCADE;

WITH readings_enriched AS (
    SELECT
        tm.month_key,
        dc.city_key,
        dp.param_key,
        re.paramid,
        re.sensordevid,
        re.readat::date AS day_date,
        re.recordedvalue,
        re.datavolumekb,
        re.dataquality
    FROM tb_readingevent AS re
    JOIN tb_sensordevice AS sd
      ON sd.id = re.sensordevid
    JOIN tb_city AS ci
      ON ci.id = sd.cityid
    JOIN tb_country AS co
      ON co.id = ci.countryid
    JOIN dim_city AS dc
      ON dc.city_name = ci.cityname
     AND dc.country_name = co.countryname
    JOIN tb_param AS p
      ON p.id = re.paramid
    JOIN dim_param AS dp
      ON dp.param_name = p.paramname
    JOIN dim_timemonth AS tm
      ON re.readat::date BETWEEN tm.mfirst_day AND tm.mlast_day
),

daily_values AS (
    SELECT
        month_key,
        city_key,
        param_key,
        paramid,
        day_date,
        MAX(recordedvalue) AS daily_max_value
    FROM readings_enriched
    GROUP BY
        month_key,
        city_key,
        param_key,
        paramid,
        day_date
),

daily_ranks AS (
    SELECT
        dv.month_key,
        dv.city_key,
        dv.param_key,
        dv.day_date,
        COALESCE(
            MAX(
                CASE
                    WHEN pa.threshold <= dv.daily_max_value
                    THEN dap.alert_rank
                    ELSE 0
                END
            ),
            0
        ) AS daily_rank
    FROM daily_values AS dv
    LEFT JOIN tb_paramalert AS pa
      ON pa.paramid = dv.paramid
    LEFT JOIN tb_alert AS a
      ON a.id = pa.alertid
    LEFT JOIN dim_alertpeak AS dap
      ON dap.alert_level_name = a.alertname
    GROUP BY
        dv.month_key,
        dv.city_key,
        dv.param_key,
        dv.day_date
),

monthly_alerts AS (
    SELECT
        month_key,
        city_key,
        param_key,
        MAX(daily_rank) AS monthly_peak_rank,
        COUNT(*) FILTER (WHERE daily_rank >= 1) AS exceed_days_any
    FROM daily_ranks
    GROUP BY
        month_key,
        city_key,
        param_key
),

monthly_measures AS (
    SELECT
        r.month_key,
        r.city_key,
        r.param_key,
        COUNT(DISTINCT (r.sensordevid, r.day_date)) AS reading_events_count,
        COUNT(DISTINCT r.sensordevid) AS devices_reporting_count,
        AVG(r.recordedvalue) AS recordedvalue_avg,
        percentile_cont(0.95) WITHIN GROUP (ORDER BY r.recordedvalue)
            AS recordedvalue_p95,
        SUM(r.datavolumekb) AS data_volume_kb_sum,
        AVG(r.dataquality) AS data_quality_avg,
        COUNT(DISTINCT r.day_date) AS days_with_readings
    FROM readings_enriched AS r
    GROUP BY
        r.month_key,
        r.city_key,
        r.param_key
),

final_measures AS (
    SELECT
        m.month_key,
        m.city_key,
        m.param_key,
        m.reading_events_count,
        m.devices_reporting_count,
        m.recordedvalue_avg,
        m.recordedvalue_p95,
        m.data_volume_kb_sum,
        m.data_quality_avg,
        (t.days_in_month - m.days_with_readings) AS missing_days
    FROM monthly_measures AS m
    JOIN dim_timemonth AS t
      ON t.month_key = m.month_key
)

INSERT INTO ft_param_city_month (
    ft_pcm_key,
    month_key,
    city_key,
    param_key,
    alertpeak_key,
    reading_events_count,
    devices_reporting_count,
    recordedvalue_avg,
    recordedvalue_p95,
    exceed_days_any,
    data_volume_kb_sum,
    data_quality_avg,
    missing_days
)
SELECT
    ROW_NUMBER() OVER (ORDER BY fm.month_key, fm.city_key, fm.param_key) AS ft_pcm_key,
    fm.month_key,
    fm.city_key,
    fm.param_key,
    dap.alertpeak_key,
    fm.reading_events_count,
    fm.devices_reporting_count,
    fm.recordedvalue_avg,
    fm.recordedvalue_p95,
    ma.exceed_days_any,
    fm.data_volume_kb_sum,
    fm.data_quality_avg,
    fm.missing_days
FROM final_measures AS fm
JOIN monthly_alerts AS ma
  ON ma.month_key = fm.month_key
 AND ma.city_key  = fm.city_key
 AND ma.param_key = fm.param_key
JOIN dim_alertpeak AS dap
  ON dap.alert_rank = ma.monthly_peak_rank;



