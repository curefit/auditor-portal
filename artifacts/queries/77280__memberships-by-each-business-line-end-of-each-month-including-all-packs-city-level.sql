with dates as (
select date_trunc('month',full_date) as "month", min(full_date) as month_start_date, max(full_date) month_end_date, date_add('day',-1,min(full_date)) as prev_month_end_date
from dwh_curefit.dim_date
where full_date between {{start_date}} and {{end_date}}
group by 1
)

-- select * from dates

select 
d."month"
, case when is_enterprise = 1 then md.business_line||' (B2B)' else md.business_line end as business_line
,city_name
,count(distinct user_id) as user_base
from dates d
left join (
select membership_key, md.business_line, membership_created_date, pack_start_date, pack_end_date, is_enterprise, amount_paid, pack_name, user_id, cd.city_name, cancellation_date
from dwh_fitness_mart.membership_dim md 
left join dwh_fitness_mart.center_dim cd on cd.center_key=coalesce(attributed_center_key,final_center_key,purchase_center_key,last_30_days_preferred_center_key)

where 1=1
and UPPER(md.business_line) not like '%PT%' -- users of PT are counted in ELITE/PRO memberships

and md.business_line is not null
) md
on d.month_end_date between md.pack_start_date and least(coalesce(md.cancellation_date,pack_end_date),md.pack_end_date)
group by 1,2,3
order by 1 desc, 3 desc
