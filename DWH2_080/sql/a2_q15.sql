select 
	c.country_name,
	sum(case when t.year_num = 2023 then ft.exceed_days_any else 0 end) as exceed_days_23,
	sum(case when t.year_num = 2024 then ft.exceed_days_any else 0 end) as exceed_days_24
from dwh2_080.ft_param_city_month ft
full join dwh2_080.dim_param as p on ft.param_key = p.param_key 
full join dwh2_080.dim_city as c on ft.city_key = c.city_key 
full join dwh2_080.dim_timemonth as t on ft.month_key = t.month_key
where c.region_name = 'Eastern Europe'
group by c.country_name
