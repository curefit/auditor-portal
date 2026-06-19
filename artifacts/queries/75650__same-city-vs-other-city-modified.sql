-- Purpose: Classify memberships as same-city or multi-city based on attended booking cities.
-- Output: type, memberships.
-- Membership-date fix: transferred/upgraded packs use membership-service created_date for the membership cohort filter.
WITH
  base AS (
    SELECT
      date_trunc('quarter', CASE
        WHEN LOWER(CAST(m.is_transferred_pack AS VARCHAR)) = 'true'
          OR LOWER(CAST(m.is_upgrade_pack AS VARCHAR)) = 'true'
          THEN mdb.created_date
        ELSE m.membership_created_date
      END) AS "quarter",
      m.membership_key,
      final_center_key,
      c.city_name attributed_city
    FROM
      dwh_fitness_mart.membership_fact m
    LEFT JOIN pk_curefitplatforms_membershipdb.memberships mdb
      ON mdb.id = m.membership_service_id
    JOIN dwh_fitness_mart.center_dim c
      ON c.center_key = final_center_key
    WHERE
      1 = 1
	  -- Use membership-service created_date for transferred/upgraded packs before bucketing memberships by quarter.
      AND DATE(CASE
        WHEN LOWER(CAST(m.is_transferred_pack AS VARCHAR)) = 'true'
          OR LOWER(CAST(m.is_upgrade_pack AS VARCHAR)) = 'true'
          THEN mdb.created_date
        ELSE m.membership_created_date
      END) BETWEEN DATE('2017-01-01') AND {{Last_date}}
	  -- Same-city behavior is reviewed for the main fitness membership lines.
      AND m.business_line IN ('ELITE', 'PRO', 'PLAY')
	  -- Keep customer-paid memberships excluding the complimentary packs etc.
      AND amount_paid > 2000
	  -- Freeze to a single fact-table snapshot so results do not move because of
	  -- late-arriving tech changes or partition refreshes.
	  AND m.transaction_date = date '2026-06-16'
    GROUP BY
      1, 2, 3, 4
  )

SELECT
  IF(other_city_checkins > 0, 'Multi', 'Same') type,
  COUNT(membership_key) memberships
FROM (
  SELECT
    b.membership_key,
    COUNT_IF(c.city_name = attributed_city) attributed_city_checkins,
    COUNT_IF(c.city_name <> attributed_city) other_city_checkins
  FROM base b
  JOIN dwh_fitness_mart.booking_fact bf
    ON b.membership_key = bf.membership_key
    AND bf.class_date BETWEEN DATE('2017-01-01') AND {{Last_date}}
	-- Only attended classes are used to decide same vs multi-city.
    AND attendance_time IS NOT NULL
  LEFT JOIN dwh_fitness_mart.center_dim c
    ON c.center_key = bf.center_key
  GROUP BY 1
)
GROUP BY 1
ORDER BY 1, 2
