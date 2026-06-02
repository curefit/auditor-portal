-- Purpose: Count month-end membership base by business line and city, including all packs.
-- Output: month, business_line, city_name, user_base.
-- Membership-date fix: transferred/upgraded packs use membership-service created/start/end dates for city-level active windows.
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
select
membership_key,
md.business_line,
-- Transfers/upgrades should use membership-service dates so city-level month-end counts follow the corrected pack window.
case
    when lower(cast(md.is_transferred_pack as varchar)) = 'true' or lower(cast(md.is_upgrade_pack as varchar)) = 'true' then mdb.created_date
    else md.membership_created_date
end as membership_created_date,
case
    when lower(cast(md.is_transferred_pack as varchar)) = 'true' or lower(cast(md.is_upgrade_pack as varchar)) = 'true' then mdb."start"
    else md.pack_start_date
end as pack_start_date,
case
    when lower(cast(md.is_transferred_pack as varchar)) = 'true' or lower(cast(md.is_upgrade_pack as varchar)) = 'true' then mdb."end"
    else md.pack_end_date
end as pack_end_date,
md.is_enterprise, md.amount_paid, md.pack_name, md.user_id, cd.city_name, md.cancellation_date
from dwh_fitness_mart.membership_dim md 
left join pk_curefitplatforms_membershipdb.memberships mdb on mdb.id = md.membership_service_id
left join dwh_fitness_mart.center_dim cd on cd.center_key=coalesce(md.attributed_center_key,md.final_center_key,md.purchase_center_key,md.last_30_days_preferred_center_key)

where 1=1
and UPPER(md.business_line) not like '%PT%' -- users of PT are counted in ELITE/PRO memberships

and md.business_line is not null
) md
-- Count users whose pack is active on the month-end date.
on d.month_end_date between md.pack_start_date and least(coalesce(md.cancellation_date,pack_end_date),md.pack_end_date)
group by 1,2,3
order by 1 desc, 3 desc
