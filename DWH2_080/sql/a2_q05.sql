select 
	p.category ,
	sum(case when t.year_num = 2023 then ft.data_volume_kb_sum else 0 end) as "data volume (kb) 2023",
	sum(case when t.year_num = 2024 then ft.data_volume_kb_sum else 0 end) as "data volume (kb) 2024"
from dwh2_080.ft_param_city_month ft
full join dwh2_080.dim_param as p on ft.param_key = p.param_key 
full join dwh2_080.dim_city as c on ft.city_key = c.city_key 
full join dwh2_080.dim_timemonth as t on ft.month_key = t.month_key
where t.year_num = 2023 or t.year_num = 2024
group by p.category