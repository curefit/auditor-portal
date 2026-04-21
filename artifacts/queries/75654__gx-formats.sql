with   base as  (
SELECT
      date_trunc('quarter', membership_created_date) AS "quarter",
      m.membership_key,
      final_center_key,
      c.city_name attributed_city,
      m.user_id,
      m.pack_start_date,
            m.pack_end_date
    FROM
      dwh_fitness_mart.membership_dim m
    JOIN dwh_fitness_mart.center_dim c on c.center_key = final_center_key
    --  JOIN dwh_curefit.dim_date dd ON dd.full_date BETWEEN m.pack_start_date AND m.pack_end_date
    WHERE
     1=1
      AND m.membership_created_date >= date('2017-01-01')
      and m.business_line in ('ELITE','PRO','PLAY')
      and amount_paid>2000
    GROUP BY
      1,
      2,
      3,
      4,5,6,7
)
-- select count(distinct base.user_id) from base
,

all_sessions_df as (
      Select
      distinct
        bf.membership_key,
        booking_key as classes,
        -- Case
        --   When UPPER(workout_name) like '%DANCE%' Then 400
        --   When UPPER(workout_name) like '%BURN%' Then 400
        --   When UPPER(workout_name) like '%BOXING%' Then 350
        --   When (
        --     UPPER(workout_name) like '%S&C%'
        --     or UPPER(workout_name) like '%STRENGTH AND CONDITIONING%'
        --     or UPPER(workout_name) like '%STRENGTH%'
        --   ) Then 350
        --   When UPPER(workout_name) like '%HRX%' Then 300
        --   Else 250
        -- End as calorie,
        class_date,
        attendance_time,
        -- Date_Trunc('Week', class_date) Weeks_Active,
        -- Case
        --   When extract(
        --     hour
        --     From
        --       attendance_time
        --   ) <= 12 Then 'Morning'
        --   Else 'Evening'
        -- End as slot,
        -- Case
        --   When service_type = 'GX' Then 50
        --   When service_type = 'PLAY' Then 50
        --   When service_type = 'GYM' Then 90
        --   Else 70
        -- End as minutes,
        -- Extract(
        --   DOW
        --   FROM
        --     class_date
        -- ) as day_week,
        Case
          When UPPER(workout_name) like '%YOGA%' Then 'YOGA'
          When UPPER(workout_name) like '%BARRE%' Then 'BARRE'
          When UPPER(workout_name) like '%BOXING%' Then 'BOXING'
          When UPPER(workout_name) like '%CARDIO%' Then 'CARDIO'
          When UPPER(workout_name) like '%DANCE%' Then 'DANCE'
          When UPPER(workout_name) like '%HIIT%' Then 'HIIT'
          When UPPER(workout_name) like '%BURN%' Then 'BURN'
          When UPPER(workout_name) like '%HRX%' Then 'HRX'
          When UPPER(workout_name) like '%GYM%' Then 'GYM'
          When (
            UPPER(workout_name) like '%S&C%'
            or UPPER(workout_name) like '%STRENGTH AND CONDITIONING%'
            or UPPER(workout_name) like '%STRENGTH%'
          ) Then 'STRENGTH'
          When service_type like '%GYM%' Then 'GYM'
          Else workout_name
        End as workoutname,
        service_type,
        -- e.employee_name as trainername, 
        -- c.center_name, 
        -- c.city_name,
        class_id
      from base class_base  join 
        dwh_fitness_mart.booking_fact bf on bf.membership_key=class_base.membership_key 
        --and date(class_date) between pack_start_date and pack_end_date
        Left join dwh_fitness_mart.workout_dim wd ON bf.workout_key = wd.workout_key
        Left join dwh_fitness_mart.employee_dim e ON bf.trainer_key = e.employee_key
        and service_type = ('GX')
        Left join dwh_fitness_mart.center_dim c on bf.center_key = c.center_key
      Where
        class_date between  Date('2017-01-01') 
        and {{Last_date}}
        and attendance_time is not null
        and service_type IN ('GX', 'GYM', 'PLAY')
        -- and Exists (select 1 from (select  user_id from base Union  select  user2 as user_id from usersinSquads) b1 where b1.user_id=bf.user_id
        
        
--         and (EXISTS (SELECT 1 FROM base WHERE base.user_id = bf.user_id)
--   OR EXISTS (SELECT 1 FROM usersinSquads WHERE usersinSquads.user2 = bf.user_id)
        -- or user_id in (select distinct user_id from Squads)
        -- )
    --   Union All
    
    --   Select
    --     distinct
    --     userid,
    --     usersessionid,
    --     -- Case
    --     --   When UPPER(packid) like '%DIYLIV01%' Then 400
    --     --   When UPPER(packid) in ('DIYLIV06', 'DIYLIV04')
    --     --   or UPPER(packid) in ('DIYPACK018', 'DIYPACK009') Then 350
    --     --   Else 250
    --     -- End,
    --     createddate_date,
    --     createddate,
    --     -- Date_Trunc('Week', createddate_date) Weeks_Active,
    --     -- Case
    --     --   When extract(
    --     --     Hour
    --     --     From
    --     --       createddate
    --     --   ) <= 12 Then 'Morning'
    --     --   Else 'Evening'
    --     -- End as slot,
    --     -- Round(((1.0 * user_duration) / 60000), 0) as minutes,
    --     -- Extract(
    --     --   DOW
    --     --   FROM
    --     --     createddate_date
    --     -- ) as day_week,
    --     Case
    --       When UPPER(packid) LIKE '%DIY%' Then 'DIY'
    --       When UPPER(packid) LIKE '%LIVE%' Then Split(UPPER(packid), '_') [ 1 ]
    --       When UPPER(packid) LIKE '%MEDPACK%' Then 'MEDITATION'
    --       When UPPER(packid) LIKE '%MMPACK%' Then 'MEDITATION'
    --       When UPPER(packid) LIKE '%SNC%' Then 'STRENGTH'
    --       Else UPPER(packid)
    --     End as packid,
    --     'Live',
    --     -- trainername, 
    --     -- null as center_name,
    --     -- selectedcityid as city_name,
    --     null as classid

    --   from base class_base  join dwh_live.live_bookings
    --     -- add membership_dim here
    --   on live_bookings.membership_key=class_base.membership_key and date(createddate_date) between pack_start_date and pack_end_date
    --   Where
    --     year(createddate_date) >= year(Date('2017-01-01'))
    --     and coalesce(usersessionid, 'xx') NOT LIKE '%FIT%FIVE%'
    --     and live_bookings.userid_50_percent_completed is not Null
    --     and UPPER(packid) in (
    --       'YOGA',
    --       'STRENGTH',
    --       'SNC',
    --       'LIVE_YOGA',
    --       'LIVE_SNC',
    --       'LIVE_DANCE',
    --       'HRX',
    --       'DANCE',
    --       'BOXING',
    --       'CARDIO'
    --     )

    ),
User_classes as(
  
          select
            bs.membership_key,
            -- Count(Distinct cl.classes) as classes,
            -- case
            --   when count(
            --     case
            --       when class_date between date_add('day', -30, pack_end_date)
            --       and pack_end_date then cl.classes
            --     end
            --   ) > 0 then True
            --   else False
            -- end as last_month_active,
            -- Sum(calorie) calorie_burnt,
            -- Count(Distinct class_date) total_woorkout_days,
            -- Min(class_date) as first_class,
            -- Max(class_date) as latest_class,
            -- Sum(minutes) total_minutes_worked,
            -- nullif(Count(
            --   Distinct center_name
            -- ) ,0) as Centers,
            -- -- nullif(Count(
            -- --   Distinct cl.city_name
            -- -- ) ,0) as Cities,
            -- nullif(Count(
            --   Distinct Case
            --     When day_week in (6, 7) Then class_date
            --   End
            -- ) ,0) as Weekend_at_cult,
            -- nullif ( Count(
            --   Distinct Case
            --     When day_week in (6, 7) Then DATE_TRUNC('week', class_date)
            --   End
            -- ),0) as DISTINCT_Weekend_at_cult,
            nullif(Count(Distinct workoutname),0) as formats,
            case
              when Count(Distinct workoutname) > 1 then Array_distinct(Array_agg(workoutname))
            end as formats_concat,
            nullif(Count(
              Distinct Case
                When service_type in ('GX') Then cl.classes
              End
            ),0) as GX_Classes,
            nullif(Count(
              Distinct Case
                When service_type in ('GYM') Then cl.classes
              End
            ),0) as GYM_Classes,
            nullif(Count(
              Distinct Case
                When service_type in ('Live') Then cl.classes
              End
            ),0) as Live_Classes,
            nullif(Count(
              Distinct Case
                When service_type in ('PLAY') Then cl.classes
              End
            ),0) as PLAY_Classes
            -- nullif(Count(
            --   Distinct Case
            --     When slot = 'Morning' Then cl.classes
            --   End
            -- ),0) as Morning_Classes,
            -- nullif(Count(
            --   Distinct Case
            --     When slot = 'Evening' Then cl.classes
            --   End
            -- ),0) as Evening_Classes,
            -- nullif(Count(Distinct Weeks_Active),0) Weeks_Active
          from
            base bs
             join all_sessions_df cl on bs.membership_key = cl.membership_key
            -- and class_date between pack_start_date and pack_end_date
            
          group by
            1
        
    )
select 
count(distinct case when formats=1  then membership_key end ) as Single_format,
count(distinct case when formats>1  then membership_key end ) as Multi_format
from User_classes 
-- and
