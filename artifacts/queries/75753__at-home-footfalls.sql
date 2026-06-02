-- Purpose: Count at-home live session footfalls by grain and city.
-- Output: Grain, city_name, service_type, sub_service_type, footfalls.
-- Membership-date fix: transferred/upgraded packs use membership-service created/start/end dates for live-session eligibility.
Select
  Date_Trunc({{grain}}, createddate_date) as "Grain",
        CASE WHEN selectedcityid = 'Bangalore' THEN 'Bangalore'
                 WHEN selectedcityid = 'Gurgaon' THEN 'Gurgaon'
                 WHEN selectedcityid = 'Hyderabad' THEN 'Hyderabad'
                 WHEN selectedcityid IN ('Mumbai','Navi_Mum_And_Thane') THEN 'Mumbai' ELSE 'Others' END city_name, 
        -- dwh_fitness_mart.booking_fact.service_type,
        'At Home' as service_type,
        'At Home'  as sub_service_type,
                 
        COUNT(DISTINCT usersessionid) as footfalls
        

      from (
        select
          md.user_id,
          md.business_line,
          -- Transfers/upgrades should use membership-service dates for at-home session eligibility windows.
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
      ) base
      
        left join dwh_live.live_bookings
        -- add membership_dim here
      on live_bookings.userid=base.user_id and date(createddate_date) between pack_start_date and pack_end_date
      and
        year(createddate_date) >= year(Date('2017-01-01'))
        and coalesce(usersessionid, 'xx') NOT LIKE '%FIT%FIVE%'
        -- Count only sessions where the user completed enough of the live workout.
        and live_bookings.userid_50_percent_completed is not Null
        
        where 1=1
      AND base.membership_created_date >= date('2017-01-01')
      -- At-home footfalls are tied to LIVE and TRANSFORM memberships.
      and base.business_line in ('LIVE','TRANSFORM')
    GROUP BY
      1,
      2,
      3,
      4
