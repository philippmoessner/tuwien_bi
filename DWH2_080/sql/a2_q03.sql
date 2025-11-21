select 
	c.city_name,
	sum(ft.exceed_days_any )
from dwh2_080.ft_param_city_month ft
full join dwh2_080.dim_param as p on ft.param_key = p.param_key 
full join dwh2_080.dim_city as c on ft.city_key = c.city_key 
full join dwh2_080.dim_timemonth as t on ft.month_key = t.month_key
where p.param_name = 'PM10' and t.year_num = 2024
group by c.city_name