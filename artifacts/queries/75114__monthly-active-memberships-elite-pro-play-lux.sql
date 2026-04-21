--------------- OLD QUERY--------------
with liveMemberships as(
select Weekstart.weekstart as weekstart,
m.membership_key as membershipdb_id, -- Cult membership id
m.user_id,
date(m.pack_start_date) as Startdate,
date(m.pack_end_date) as enddate

from
(
SELECT distinct date_trunc('month',full_date) as Weekstart
FROM "dwh_curefit"."dim_date" 
where full_date between {{Start_Date}} and {{end_date}}
) weekstart
left join "dwh_fitness_mart"."membership_dim" m on date(m.pack_start_date)<=weekstart.Weekstart and date(m.pack_end_date)>=date_add('month',1,weekstart.Weekstart)

where  m.business_line  is not null
and m.business_line in ('ELITE','PRO','PLAY','LUX')
and (m.amount_paid>2000 
-- or is_enterprise = 1
)
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

left join"dwh_fitness_mart"."booking_fact" b on date(b.class_date)>= weekstart.Weekstart and date(b.class_date)< date_Add('month',1,weekstart.weekstart) and b.attendance_Time is not null

and date(b.class_date)>=date('2022-01-01')
)
-- select * from activeMemberships
select year(l1.Weekstart) as Year,
month(l1.weekstart) as Month,
date_trunc('month',l1.weekstart) month,
-- CASE WHEN coalesce(city_name,city_name) in ('Bangalore') THEN 'Bangalore'
--             WHEN coalesce(city_name,city_name) in ('Gurgaon') THEN 'Gurgaon'
--             WHEN coalesce(city_name,city_name) in ('Hyderabad') THEN 'Hyderabad'
--             WHEN coalesce(city_name,city_name) in ('Mumbai','Navi_Mum_And_Thane') THEN 'Mumbai_Navi_Mum_And_Thane'
--             WHEN coalesce(city_name,city_name) in ('Pune') THEN 'Pune'
--             WHEN coalesce(city_name,city_name) in ('Chennai') THEN 'Chennai'
--             ELSE 'Others' END as city_name,
count(distinct l1.membershipdb_id) as liveMemberships,
count(distinct am.user_id) as activeMemberships,
round(count(distinct am.user_id)*100.00/count(distinct l1.membershipdb_id),2) as monthlyActiveMemberships,
1.00*count(distinct booking_key)/nullif(count(distinct am.user_id),0) as avg_sessions
from liveMemberships l1
left join activeMemberships am on l1.user_id=am.user_id and l1.weekstart=am.weekstart and am.class_date between l1.Startdate and l1.enddate


group by 1,2,3
order by 1,2,3
--------------- NEW QUERY CHANGED ON 25 MARCH 2025 USING NEW database--------
-- WITH
--   MTD_dates AS (
--     SELECT DISTINCT
--       date_trunc ('month', full_date) AS monthstart,
--       date_add('day',-1,date_add('month',1,date_trunc ('month', full_date))) as monthend
--     --   ,
--     --   date_add ('day',DAY ({{end_date}}) -1,date_trunc ('month', full_date)) AS monthend1
--     FROM
--       "dwh_curefit"."dim_date"
--     WHERE
--       full_date BETWEEN {{Start_Date}} AND {{end_date}}
--   )
  
  
-- --   select max(monthend), max(monthend1) from MTD_dates
-- SELECT
--   YEAR (monthstart) AS YEAR,
--   MONTH (monthstart) AS MONTH,
--   count(DISTINCT m.membership_id) AS liveMemberships,
--   count(DISTINCT case when b.user_id is not null then  m.membership_id end) AS activeMemberships,
--   round(  count(DISTINCT case when b.user_id is not null then  m.membership_id end)* 100.00 / count(DISTINCT m.membership_id),2) AS monthlyActiveMemberships
-- FROM
--   MTD_dates
--   LEFT JOIN dwh_fitness.fitness_memberships m ON date(m.pack_start_date) <= MTD_dates.monthstart
--   AND date(m.pack_end_date) > MTD_dates.monthend 
--   and m.category = 'ELITE'
--     AND m.amount_paid > 2000
--   AND m.status NOT LIKE ('%CANC%')
  
--  LEFT JOIN dwh_fitness.fitness_bookings b ON date(b.class_date) >= MTD_dates.monthstart
--       AND date(b.class_date) <= MTD_dates.monthend
--       AND b.attendance_Time IS NOT NULL
--       and m.user_id=b.user_id

--   group by 1,2
--   order by 1 desc, 2 desc
  
-- SELECT
--   YEAR (monthstart) AS YEAR,
--   MONTH (monthstart) AS MONTH,
-- --   count(DISTINCT m.membership_key) AS liveMemberships,
-- --   count(DISTINCT case when b.user_id is not null then  m.membership_key end) AS activeMemberships,
--   round(  count(DISTINCT case when b.user_id is not null then  m.membership_key end)* 100.00 / count(DISTINCT m.membership_key),2) AS monthlyActiveMemberships
-- FROM
--   MTD_dates
--   LEFT JOIN dwh_fitness_mart.membership_dim m ON date(m.pack_start_date) <= MTD_dates.monthstart
--   AND date(m.pack_end_date) > MTD_dates.monthend 
--   and m.business_line = 'ELITE'
--     AND m.amount_paid > 2000
--   AND m.status NOT LIKE ('%CANC%')
  
--  LEFT JOIN dwh_fitness_mart.booking_fact b ON date(b.class_date) >= MTD_dates.monthstart
--       AND date(b.class_date) <= MTD_dates.monthend
--       AND b.attendance_Time IS NOT NULL
--       and m.user_id=b.user_id

--   group by 1,2
--   order by 1 desc, 2 desc
