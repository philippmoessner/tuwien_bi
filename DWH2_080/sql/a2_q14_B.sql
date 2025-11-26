-- 14: For 2024, list the Top 10 City × Param pairs by Avg Data Quality. Return the 10 City–Param
-- pairs with the highest values on rows (highest -> lowest) and one column with Avg Data Quality
-- for 2024.

SELECT
    dc.city_name,
    dp.param_name,
    AVG(f.data_quality_avg) AS avg_data_quality_2024
FROM dwh2_080.ft_param_city_month AS f
JOIN dwh2_080.dim_city AS dc 
    ON f.city_key = dc.city_key
JOIN dwh2_080.dim_param AS dp
    ON f.param_key = dp.param_key
JOIN dwh2_080.dim_timemonth AS dt
    ON f.month_key = dt.month_key
WHERE dt.year_num = 2024
GROUP BY
    dc.city_name,
    dp.param_name
ORDER BY
    avg_data_quality_2024 DESC
LIMIT 10;