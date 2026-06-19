-- Purpose: Classify memberships as same-center or multi-center based on attended booking centers.
-- Output: type, memberships.
-- Membership-date fix: transferred/upgraded packs use membership-service created_date for the membership cohort filter.
WITH
  base AS (
    SELECT
      date_trunc('quarter', CASE
        WHEN LOWER(CAST(m.is_transferred_pack AS VARCHAR)) = 'true' OR LOWER(CAST(m.is_upgrade_pack AS VARCHAR)) = 'true' THEN mdb.created_date
        ELSE m.membership_created_date
      END) AS "quarter",
      m.membership_key,
      final_center_key,
      c.city_name attributed_city
    FROM
      dwh_fitness_mart.membership_fact m
    LEFT JOIN pk_curefitplatforms_membershipdb.memberships mdb
      ON mdb.id = m.membership_service_id
    JOIN dwh_fitness_mart.center_dim c on c.center_key = final_center_key
    --  JOIN dwh_curefit.dim_date dd ON dd.full_date BETWEEN m.pack_start_date AND m.pack_end_date
    WHERE
     1=1
      -- Use membership-service created_date for transferred/upgraded packs before bucketing memberships by quarter.
      AND DATE(CASE
        WHEN LOWER(CAST(m.is_transferred_pack AS VARCHAR)) = 'true' OR LOWER(CAST(m.is_upgrade_pack AS VARCHAR)) = 'true' THEN mdb.created_date
        ELSE m.membership_created_date
      END) between date('2017-01-01') and {{Last_date}}
      -- Same-center behavior is reviewed for the main fitness membership lines.
      and m.business_line in ('ELITE','PRO','PLAY')
      -- Keep customer-paid memberships excluding the complimentary packs etc.
      and amount_paid>2000
	  -- Freeze to a single fact-table snapshot so results do not move because of
	  -- late-arriving tech changes or partition refreshes.
	  AND m.transaction_date = date '2026-06-16'
    GROUP BY
      1,
      2,
      3,
      4
  )
  
  SELECT  IF(other_center_checkins>0,'Multi','Same') type,count(membership_key) memberships
  FROM (
  select 
    b.membership_key,
    COUNT_IF(bf.center_key = final_center_key) attributed_center_checkins,
    COUNT_IF(bf.center_key <> final_center_key) other_center_checkins
  from base b 
  JOIN dwh_fitness_mart.booking_fact bf 
  on b.membership_key=bf.membership_key
  and bf.class_date between Date('2017-01-01') 
        and {{Last_date}}
  -- Only attended classes are used to decide same vs multi-center.
  and attendance_time is not null

  group by 1)
  group by 1 
  order by 1,2
