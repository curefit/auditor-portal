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
        
        
        
        -- distinct
        -- user_id,
        -- usersessionid,
        -- -- Case
        -- --   When UPPER(packid) like '%DIYLIV01%' Then 400
        -- --   When UPPER(packid) in ('DIYLIV06', 'DIYLIV04')
        -- --   or UPPER(packid) in ('DIYPACK018', 'DIYPACK009') Then 350
        -- --   Else 250
        -- -- End,
        -- createddate_date,
        -- createddate,
        -- -- Date_Trunc('Week', createddate_date) Weeks_Active,
        -- -- Case
        -- --   When extract(
        -- --     Hour
        -- --     From
        -- --       createddate
        -- --   ) <= 12 Then 'Morning'
        -- --   Else 'Evening'
        -- -- End as slot,
        -- -- Round(((1.0 * user_duration) / 60000), 0) as minutes,
        -- -- Extract(
        -- --   DOW
        -- --   FROM
        -- --     createddate_date
        -- -- ) as day_week,
        -- Case
        --   When UPPER(packid) LIKE '%DIY%' Then 'DIY'
        --   When UPPER(packid) LIKE '%LIVE%' Then Split(UPPER(packid), '_') [ 1 ]
        --   When UPPER(packid) LIKE '%MEDPACK%' Then 'MEDITATION'
        --   When UPPER(packid) LIKE '%MMPACK%' Then 'MEDITATION'
        --   When UPPER(packid) LIKE '%SNC%' Then 'STRENGTH'
        --   Else UPPER(packid)
        -- End as packid,
        -- 'Live',
        -- -- trainername, 
        -- -- null as center_name,
        -- -- selectedcityid as city_name,
        -- null as classid

      from    dwh_fitness_mart.membership_dim base
      
        left join dwh_live.live_bookings
        -- add membership_dim here
      on live_bookings.userid=base.user_id and date(createddate_date) between pack_start_date and pack_end_date
      and
        year(createddate_date) >= year(Date('2017-01-01'))
        and coalesce(usersessionid, 'xx') NOT LIKE '%FIT%FIVE%'
        and live_bookings.userid_50_percent_completed is not Null
        -- and UPPER(packid) in (
        --   'YOGA',
        --   'STRENGTH',
        --   'SNC',
        --   'LIVE_YOGA',
        --   'LIVE_SNC',
        --   'LIVE_DANCE',
        --   'HRX',
        --   'DANCE',
        --   'BOXING',
        --   'CARDIO'
        -- )
        where 1=1
      AND base.membership_created_date >= date('2017-01-01')
      and base.business_line in ('LIVE','TRANSFORM')
    --   and amount_paid>2000
    GROUP BY
      1,
      2,
      3,
      4
