-- 20: For 2024, show Avg Recorded Value by Country for all parameters with Purpose = Scientific
-- Study, limited to Western Europe. Return Countries in Western Europe on rows and each
-- Scientific Study parameter on columns (values = Avg Recorded Value).

SELECT
    dc.country_name,
    dp.param_name,
    AVG(f.recordedvalue_avg) AS avg_recorded_value_2024
FROM dwh2_080.ft_param_city_month AS f
JOIN dwh2_080.dim_city       AS dc ON f.city_key  = dc.city_key
JOIN dwh2_080.dim_param      AS dp ON f.param_key = dp.param_key
JOIN dwh2_080.dim_timemonth  AS dt ON f.month_key = dt.month_key
WHERE
    dt.year_num = 2024
    AND dp.purpose = 'Scientific Study'
    AND dc.region_name = 'Western Europe'
GROUP BY
    dc.country_name,
    dp.param_name
ORDER BY
    dc.country_name,
    dp.param_name;