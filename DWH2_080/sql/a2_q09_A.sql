select 
	c.country_name,
	sum(case when t.quarter_num = 1 then ft.reading_events_count else 0 end) as events_q1,
	sum(case when t.quarter_num = 2 then ft.reading_events_count else 0 end) as events_q2,
	sum(case when t.quarter_num = 3 then ft.reading_events_count else 0 end) as events_q3,
	sum(case when t.quarter_num = 4 then ft.reading_events_count else 0 end) as events_q4
from dwh2_080.ft_param_city_month ft
full join dwh2_080.dim_param as p on ft.param_key = p.param_key 
full join dwh2_080.dim_city as c on ft.city_key = c.city_key 
full join dwh2_080.dim_timemonth as t on ft.month_key = t.month_key
where t.year_num = 2024
group by c.country_name
order by sum(ft.reading_events_count) desc
limit 10