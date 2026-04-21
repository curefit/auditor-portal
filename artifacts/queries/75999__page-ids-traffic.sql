with base as (
    select 
    user_userid ,-- event_eventparams_pageid as page_ids, 
    ts_date
    from pk_curefit_app_events.page_view 
    where ts_date between {{Start}} and {{End}}
    group by 1,2 
)

select 
date_trunc({{Time_Granularity}},ts_date) as Time_Granularity, 
--page_ids , 
count(distinct user_userid) as Traffic 
from base 
group by 1
order by 2 desc
