-- 16: For 2024, show Data Volume (KB) by Param Category × Quarter. Return Param Categories on
-- rows and the four quarters of 2024 (Q1–Q4) on columns.

SELECT
    dp.category,
    SUM(f.data_volume_kb_sum) FILTER (WHERE dt.quarter_num = 1) AS q1_data_volume_kb,
    SUM(f.data_volume_kb_sum) FILTER (WHERE dt.quarter_num = 2) AS q2_data_volume_kb,
    SUM(f.data_volume_kb_sum) FILTER (WHERE dt.quarter_num = 3) AS q3_data_volume_kb,
    SUM(f.data_volume_kb_sum) FILTER (WHERE dt.quarter_num = 4) AS q4_data_volume_kb
FROM dwh2_080.ft_param_city_month AS f
JOIN dwh2_080.dim_param      AS dp ON f.param_key  = dp.param_key
JOIN dwh2_080.dim_timemonth  AS dt ON f.month_key  = dt.month_key
WHERE dt.year_num = 2024
GROUP BY
    dp.category
ORDER BY
    dp.category;