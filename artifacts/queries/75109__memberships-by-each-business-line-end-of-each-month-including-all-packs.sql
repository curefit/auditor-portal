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
,
count(distinct user_id) as user_base
from dates d
left join (
select membership_key, business_line, membership_created_date, pack_start_date, pack_end_date, is_enterprise, amount_paid, pack_name, user_id
from dwh_fitness_mart.membership_dim 
where lower(status) not like '%canc%'
-- and ((amount_paid > 0) --or (lower(source) <> 'enterprise_split' and is_enterprise = 1)
-- )
and business_line is not null
) md
on d.month_end_date between md.pack_start_date and md.pack_end_date
group by 1,2
order by 1 desc, 3 desc
