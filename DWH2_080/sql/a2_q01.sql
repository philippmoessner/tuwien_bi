SELECT 
	c.country_name,
	SUM(CASE WHEN t.month_num = 1 THEN ft.exceed_days_any ELSE 0 END) AS january,
	SUM(CASE WHEN t.month_num = 2 THEN ft.exceed_days_any ELSE 0 END) AS february,
	SUM(CASE WHEN t.month_num = 3 THEN ft.exceed_days_any ELSE 0 END) AS march
FROM dwh2_080.ft_param_city_month ft
FULL JOIN dwh2_080.dim_param AS p ON ft.param_key = p.param_key 
FULL JOIN dwh2_080.dim_city AS c ON ft.city_key = c.city_key 
FULL JOIN dwh2_080.dim_timemonth AS t ON ft.month_key = t.month_key
WHERE p.param_name = 'PM2' AND t.year_num = 2024 AND t.month_num  <= 3
GROUP BY c.country_name