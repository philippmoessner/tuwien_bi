select 
	c.country_name,
	avg(ft.recordedvalue_avg) as "PM10 recordedvalue_avg",
	avg(ft.recordedvalue_p95) as "PM10 recordedvalue_p95" 
from dwh2_080.ft_param_city_month ft
full join dwh2_080.dim_param as p on ft.param_key = p.param_key 
full join dwh2_080.dim_city as c on ft.city_key = c.city_key 
full join dwh2_080.dim_timemonth as t on ft.month_key = t.month_key
where t.year_num = 2023 and p.param_name = 'PM10'
group by c.country_name