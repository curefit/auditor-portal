with nps_base as (
select response_date, service_type, sum(promoters) as promoters, sum(detractors) as detractors, sum(passives) as passives, sum(total_responses) as total_responses
from dwh_fitness_metrics.nps_responses_base
where response_date between {{start_date}} and date_add('day',6,date_trunc('week',{{end_date}}))
[[and center_business_line in (select distinct business_line from dwh_fitness_mart.center_dim where {{business_line}})]] [[and {{activity_status}}]] [[and {{service_type}}]] [[and {{sub_service_type}}]]
[[and {{ownership_type}}]] [[and {{city_name}}]] [[and {{center_name}}]] [[and {{center_service_id}}]]
group by 1,2
)

, combinations_base as (
select a.day as "period", a.service_type
, coalesce((promoters),0) as promoters, coalesce((detractors),0) as detractors, coalesce((passives),0) as passives, coalesce((total_responses),0) as total_responses,
coalesce(100.00*((b.promoters) - (b.detractors))/(b.total_responses),0) as nps, sum(a.footfall) as footfall
from dwh_fitness_metrics.footfall_by_service_type a
left join nps_base b
on b.response_date = a.day
and a.service_type = b.service_type
where a.day between {{start_date}} and date_add('day',6,date_trunc('week',{{end_date}}))
group by 1,2,3,4,5,6,7)

, individual_nps as (
(select '1. Q - '||cast(date_trunc('quarter',response_date) as varchar) as period, service_type, 100.00*(sum(promoters)-sum(detractors))/sum(total_responses) as nps
from nps_base
where service_type is not null and response_date between {{start_date}} and {{end_date}}
group by 1,2)
union all
(select '2. M - '||cast(date_trunc('month',response_date) as varchar) as period, service_type, 100.00*(sum(promoters)-sum(detractors))/sum(total_responses) as nps
from nps_base
where response_date between date_trunc('month',{{end_date}} - interval '2' MONTH) and {{end_date}}
and service_type is not null
group by 1,2)
union all
(select '3. W - '||cast(date_trunc('week',response_date) as varchar) as period, service_type, 100.00*(sum(promoters)-sum(detractors))/sum(total_responses) as nps
from nps_base
where response_date between date_trunc('week',date_add('week',-3,{{end_date}})) and date_add('day',6,date_trunc('week',{{end_date}}))
and service_type is not null
group by 1,2)
union all
(select '4. D - '||cast(response_date as varchar) as period, service_type, 100.00*(sum(promoters)-sum(detractors))/sum(total_responses) as nps
from nps_base
where response_date between date_add('day',-6,{{end_date}}) and {{end_date}}
and service_type is not null
group by 1,2)
)

, platform_nps as (
select '1. Q - '||cast(a.period as varchar) as period, 
sum(case when a.service_type in ('GX','GYM') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM') then b.footfall end),0) as gx_gym_nps,
sum(case when a.service_type in ('GX','GYM','PLAY') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM','PLAY') then b.footfall end),0) as gx_gym_play_nps,
sum(case when a.service_type in ('GX','GYM','PLAY','LIVE') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM','PLAY','LIVE') then b.footfall end),0) as gx_gym_play_live_nps,
sum(case when a.service_type in ('GX','GYM','PLAY','LIVE','PT') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM','PLAY','LIVE','PT') then b.footfall end),0) as platform_nps
from
(select date_trunc('quarter',period) as period, service_type, 100.00*(sum(promoters) - sum(detractors))/nullif(sum(total_responses),0) * sum(footfall) as numerator
from combinations_base
where period between {{start_date}} and {{end_date}}
and total_responses > 0
group by 1,2) a
join (select Date_Trunc('quarter',period) as period, service_type, sum(footfall) as footfall from combinations_base where total_responses > 0 and period <= {{end_date}} group by 1,2) b on a.period = b.period and a.service_type = b.service_type
group by 1
union all
select '2. M - '||cast(a.period as varchar) as period, 
sum(case when a.service_type in ('GX','GYM') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM') then b.footfall end),0) as gx_gym_nps,
sum(case when a.service_type in ('GX','GYM','PLAY') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM','PLAY') then b.footfall end),0) as gx_gym_play_nps,
sum(case when a.service_type in ('GX','GYM','PLAY','LIVE') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM','PLAY','LIVE') then b.footfall end),0) as gx_gym_play_live_nps,
sum(case when a.service_type in ('GX','GYM','PLAY','LIVE','PT') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM','PLAY','LIVE','PT') then b.footfall end),0) as platform_nps
from
(select date_trunc('month',period) as period, service_type, 100.00*(sum(promoters) - sum(detractors))/nullif(sum(total_responses),0) * sum(footfall) as numerator
from combinations_base
where period between date_trunc('month',{{end_date}} - interval '2' MONTH) and {{end_date}}
and total_responses > 0
group by 1,2) a
join (select Date_Trunc('month',period) as period, service_type, sum(footfall) as footfall from combinations_base where total_responses > 0 group by 1,2) b on a.period = b.period and a.service_type = b.service_type
group by 1
union all
select '3. W - '||cast(a.period as varchar) as period, 
sum(case when a.service_type in ('GX','GYM') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM') then b.footfall end),0) as gx_gym_nps,
sum(case when a.service_type in ('GX','GYM','PLAY') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM','PLAY') then b.footfall end),0) as gx_gym_play_nps,
sum(case when a.service_type in ('GX','GYM','PLAY','LIVE') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM','PLAY','LIVE') then b.footfall end),0) as gx_gym_play_live_nps,
sum(case when a.service_type in ('GX','GYM','PLAY','LIVE','PT') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM','PLAY','LIVE','PT') then b.footfall end),0) as platform_nps
from
(select date_trunc('week',period) as period, service_type, 100.00*(sum(promoters) - sum(detractors))/nullif(sum(total_responses),0) * sum(footfall) as numerator
from combinations_base
where period between date_trunc('week',date_add('week',-3,{{end_date}})) and date_add('day',6,date_trunc('week',{{end_date}}))
and total_responses > 0
group by 1,2) a
join (select Date_Trunc('week',period) as period, service_type, sum(footfall) as footfall from combinations_base where total_responses > 0 group by 1,2) b on a.period = b.period and a.service_type = b.service_type
group by 1
union all
select '4. D - '||cast(a.period as varchar) as period, 
sum(case when a.service_type in ('GX','GYM') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM') then b.footfall end),0) as gx_gym_nps,
sum(case when a.service_type in ('GX','GYM','PLAY') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM','PLAY') then b.footfall end),0) as gx_gym_play_nps,
sum(case when a.service_type in ('GX','GYM','PLAY','LIVE') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM','PLAY','LIVE') then b.footfall end),0) as gx_gym_play_live_nps,
sum(case when a.service_type in ('GX','GYM','PLAY','LIVE','PT') then a.numerator end)/nullif(sum(case when a.service_type in ('GX','GYM','PLAY','LIVE','PT') then b.footfall end),0) as platform_nps
from
(select period as period, service_type, 100.00*(sum(promoters) - sum(detractors))/nullif(sum(total_responses),0) * sum(footfall) as numerator
from combinations_base
where period between date_add('day',-6,{{end_date}}) and {{end_date}}
and total_responses > 0
group by 1,2) a
join (select period as period, service_type, sum(footfall) as footfall from combinations_base where total_responses > 0 group by 1,2) b on a.period = b.period and a.service_type = b.service_type
group by 1
)

-- select * from platform_nps
select period, 'PLATFORM' as service_type, platform_nps as nps from platform_nps
union all
select * from individual_nps
union all
select period, 'GX + GYM' as service_type, gx_gym_nps as nps from platform_nps
union all
select period, 'GX + GYM + PLAY' as service_type, gx_gym_play_nps as nps from platform_nps
union all
select period, 'GX + GYM + PLAY + LIVE' as service_type, gx_gym_play_live_nps as nps from platform_nps
order by 1, 
    case
        when service_type = 'PLATFORM' then 1
        when service_type = 'GX' then 2
        when service_type = 'GYM' then 3
        when service_type = 'PLAY' then 4
        when service_type = 'LIVE' then 5
        when service_type = 'BOOTCAMP' then 6
        when service_type = 'TRANSFORM' then 7
        when service_type = 'TRANSFORM_PLUS' then 8
        when service_type = 'PT' then 9
        when service_type = 'GX + GYM' then 10
        when service_type = 'GX + GYM + PLAY' then 11
        when service_type = 'GX + GYM + PLAY + LIVE' then 12 end
