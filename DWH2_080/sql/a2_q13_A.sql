select 
	c.city_name,
	sum(case when t.month_name  = 'Jan' then ft.exceed_days_any else 0 end) as exceed_days_jan,
	sum(case when t.month_name  = 'Feb' then ft.exceed_days_any else 0 end) as exceed_days_feb,
	sum(case when t.month_name  = 'Mar' then ft.exceed_days_any else 0 end) as exceed_days_mar
from dwh2_080.ft_param_city_month ft
full join dwh2_080.dim_param as p on ft.param_key = p.param_key 
full join dwh2_080.dim_city as c on ft.city_key = c.city_key 
full join dwh2_080.dim_timemonth as t on ft.month_key = t.month_key
where t.quarter_num = 1 and t.year_num = 2023 and (ft.alertpeak_key = 1000 or ft.alertpeak_key = 1001)
group by c.city_name
