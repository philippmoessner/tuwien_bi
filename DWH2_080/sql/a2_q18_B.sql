-- 18: For 2023, show Reading Events by Quarter for Vienna, Berlin, Moscow, and London (all
-- parameters). Return the four cities on rows and the four quarters of 2023 (Q1–Q4) on columns.

SELECT
    dc.city_name,
    SUM(f.reading_events_count) FILTER (WHERE dt.quarter_num = 1) AS q1_reading_events,
    SUM(f.reading_events_count) FILTER (WHERE dt.quarter_num = 2) AS q2_reading_events,
    SUM(f.reading_events_count) FILTER (WHERE dt.quarter_num = 3) AS q3_reading_events,
    SUM(f.reading_events_count) FILTER (WHERE dt.quarter_num = 4) AS q4_reading_events
FROM dwh2_080.ft_param_city_month AS f
JOIN dwh2_080.dim_city      AS dc ON f.city_key  = dc.city_key
JOIN dwh2_080.dim_timemonth AS dt ON f.month_key = dt.month_key
WHERE
    dt.year_num = 2023
    AND dc.city_name IN ('Vienna', 'Berlin', 'Moscow', 'London')
GROUP BY
    dc.city_name
ORDER BY
    CASE dc.city_name
        WHEN 'Vienna' THEN 1
        WHEN 'Berlin' THEN 2
        WHEN 'Moscow' THEN 3
        WHEN 'London' THEN 4
        ELSE 5
    END;