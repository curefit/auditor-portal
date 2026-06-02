-- Purpose: Split memberships by single-format versus multi-format workout behavior.
-- Output: Single_format, Multi_format.
-- Membership-date fix: transferred/upgraded packs use membership-service created/start/end dates for cohort and pack-window logic.
with   base as  (
SELECT
      date_trunc('quarter', CASE
        WHEN LOWER(CAST(m.is_transferred_pack AS VARCHAR)) = 'true' OR LOWER(CAST(m.is_upgrade_pack AS VARCHAR)) = 'true' THEN mdb.created_date
        ELSE m.membership_created_date
      END) AS "quarter",
      m.membership_key,
      final_center_key,
      c.city_name attributed_city,
      m.user_id,
      -- Transfers/upgrades should use membership-service dates when downstream logic needs the pack active window.
      CASE
        WHEN LOWER(CAST(m.is_transferred_pack AS VARCHAR)) = 'true' OR LOWER(CAST(m.is_upgrade_pack AS VARCHAR)) = 'true' THEN mdb."start"
        ELSE m.pack_start_date
      END AS pack_start_date,
      CASE
        WHEN LOWER(CAST(m.is_transferred_pack AS VARCHAR)) = 'true' OR LOWER(CAST(m.is_upgrade_pack AS VARCHAR)) = 'true' THEN mdb."end"
        ELSE m.pack_end_date
      END AS pack_end_date
    FROM
      dwh_fitness_mart.membership_dim m
    LEFT JOIN pk_curefitplatforms_membershipdb.memberships mdb
      ON mdb.id = m.membership_service_id
    JOIN dwh_fitness_mart.center_dim c on c.center_key = final_center_key
    --  JOIN dwh_curefit.dim_date dd ON dd.full_date BETWEEN m.pack_start_date AND m.pack_end_date
    WHERE
     1=1
      -- Use membership-service created_date for transferred/upgraded packs before building the format-analysis base.
      AND DATE(CASE
        WHEN LOWER(CAST(m.is_transferred_pack AS VARCHAR)) = 'true' OR LOWER(CAST(m.is_upgrade_pack AS VARCHAR)) = 'true' THEN mdb.created_date
        ELSE m.membership_created_date
      END) between date('2017-01-01') and {{Last_date}}
      -- Workout-format behavior is reviewed for the main fitness membership lines.
      and m.business_line in ('ELITE','PRO','PLAY')
      -- Keep customer-paid memberships.
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

        class_date,
        attendance_time,

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

    ),
User_classes as(
  
          select
            bs.membership_key,
            
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
