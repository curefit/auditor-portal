-- Purpose: Count live and monthly active memberships for ELITE, PRO, PLAY, and LUX.
-- Output: Year, Month, month, liveMemberships, activeMemberships, monthlyActiveMemberships, avg_sessions.
-- Membership-date fix: transferred/upgraded packs use membership-service created/start/end dates for live and active windows.
with liveMemberships as(
select Weekstart.weekstart as weekstart,
m.membership_key as membershipdb_id, -- Cult membership id
m.user_id,
date(m.pack_start_date) as Startdate,
date(m.pack_end_date) as enddate,
date(m.membership_created_date) as membership_created_date

from
(
SELECT distinct date_trunc('month',full_date) as Weekstart
FROM "dwh_curefit"."dim_date" 
where full_date between {{Start_Date}} and {{end_date}}
) weekstart
left join (
    select
        md.membership_key,
        md.user_id,
        md.business_line,
        md.amount_paid,
        md.status,
        -- Transfers/upgrades should use membership-service dates so live and active windows use the corrected pack lifecycle.
        case
            when lower(cast(md.is_transferred_pack as varchar)) = 'true' or lower(cast(md.is_upgrade_pack as varchar)) = 'true' then mdb."start"
            else md.pack_start_date
        end as pack_start_date,
        case
            when lower(cast(md.is_transferred_pack as varchar)) = 'true' or lower(cast(md.is_upgrade_pack as varchar)) = 'true' then mdb."end"
            else md.pack_end_date
        end as pack_end_date,
        case
            when lower(cast(md.is_transferred_pack as varchar)) = 'true' or lower(cast(md.is_upgrade_pack as varchar)) = 'true' then mdb.created_date
            else md.membership_created_date
        end as membership_created_date
    from dwh_fitness_mart.membership_dim md
    left join pk_curefitplatforms_membershipdb.memberships mdb
        on mdb.id = md.membership_service_id
-- Live membership must cover the complete month.
) m on date(m.pack_start_date)<=weekstart.Weekstart and date(m.pack_end_date)>=date_add('month',1,weekstart.Weekstart)

where  m.business_line  is not null
-- Fitness membership lines included in the active-membership report.
and m.business_line in ('ELITE','PRO','PLAY','LUX')
-- Keep customer-paid packs; enterprise packs are intentionally not included here.
and (m.amount_paid>2000 
-- or is_enterprise = 1
)
-- Cancelled memberships are not counted as live.
and m.status not like ('%CANC%')

)
-- select * from liveMemberships
,

activeMemberships as(

select weekstart.weekstart as weekstart,
b.membership_key as membershipserviceid, --cult membershipid
b.user_id,
b.class_date,
b.booking_key

from

(
SELECT distinct date_trunc('month',full_date) as Weekstart
FROM "dwh_curefit"."dim_date" 
where full_date between {{Start_Date}} and {{end_date}}
) weekstart

left join"dwh_fitness_mart"."booking_fact" b on date(b.class_date)>= weekstart.Weekstart and date(b.class_date)< date_Add('month',1,weekstart.weekstart) and b.attendance_Time is not null -- Active users are counted only when they attended a class in the month.
and date(b.class_date)>=date('2022-01-01') -- Partition 
)
-- select * from activeMemberships
select year(l1.Weekstart) as Year,
month(l1.weekstart) as Month,
date_trunc('month',l1.weekstart) month,
count(distinct l1.membershipdb_id) as liveMemberships,
count(distinct am.user_id) as activeMemberships,
round(count(distinct am.user_id)*100.00/count(distinct l1.membershipdb_id),2) as monthlyActiveMemberships,
1.00*count(distinct booking_key)/nullif(count(distinct am.user_id),0) as avg_sessions
from liveMemberships l1
left join activeMemberships am on l1.user_id=am.user_id and l1.weekstart=am.weekstart and am.class_date between l1.Startdate and l1.enddate

group by 1,2,3
order by 1,2,3
