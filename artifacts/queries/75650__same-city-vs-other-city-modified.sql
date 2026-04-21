WITH
  base AS (
    SELECT
      date_trunc('quarter', membership_created_date) AS "quarter",
      m.membership_key,
      final_center_key,
      c.city_name attributed_city
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
      4
  )
  
  SELECT  IF(other_city_checkins>0,'Multi','Same') type,count(membership_key) memberships
  FROM (
  select 
    b.membership_key,
    COUNT_IF(c.city_name = attributed_city) attributed_city_checkins,
    COUNT_IF(c.city_name <> attributed_city) other_city_checkins
  from base b 
  JOIN dwh_fitness_mart.booking_fact bf 
  on b.membership_key=bf.membership_key
  and bf.class_date between  Date('2017-01-01') 
        and {{Last_date}}
  and attendance_time is not null
    join dwh_fitness_mart.center_dim c 
  on c.center_key = bf.center_key
  group by 1)
  group by 1 
  order by 1,2
