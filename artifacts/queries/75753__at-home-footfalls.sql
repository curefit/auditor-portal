-- Purpose: Count at-home live session footfalls by grain and city.
-- Output: Grain, city_name, service_type, sub_service_type, footfalls.
-- Membership-date fix: transferred/upgraded packs use membership-service created/start/end dates for live-session eligibility.
SELECT
  Date_Trunc ({{grain}}, createddate_date) AS "Grain",
  CASE
    WHEN selectedcityid = 'Bangalore' THEN 'Bangalore'
    WHEN selectedcityid = 'Gurgaon' THEN 'Gurgaon'
    WHEN selectedcityid = 'Hyderabad' THEN 'Hyderabad'
    WHEN selectedcityid IN ('Mumbai', 'Navi_Mum_And_Thane') THEN 'Mumbai'
    ELSE 'Others'
  END city_name,
  -- dwh_fitness_mart.booking_fact.service_type,
  'At Home' AS service_type,
  'At Home' AS sub_service_type,
  COUNT(DISTINCT usersessionid) AS footfalls
FROM
  (
    SELECT
      md.user_id,
      md.business_line,
      -- Transfers/upgrades should use membership-service dates for at-home session eligibility windows.
      CASE
        WHEN lower(cast(md.is_transferred_pack AS varchar)) = 'true'
        OR lower(cast(md.is_upgrade_pack AS varchar)) = 'true' THEN mdb."start"
        ELSE md.pack_start_date
      END AS pack_start_date,
      CASE
        WHEN lower(cast(md.is_transferred_pack AS varchar)) = 'true'
        OR lower(cast(md.is_upgrade_pack AS varchar)) = 'true' THEN mdb."end"
        ELSE md.pack_end_date
      END AS pack_end_date,
      CASE
        WHEN lower(cast(md.is_transferred_pack AS varchar)) = 'true'
        OR lower(cast(md.is_upgrade_pack AS varchar)) = 'true' THEN mdb.created_date
        ELSE md.membership_created_date
      END AS membership_created_date
    FROM
      dwh_fitness_mart.membership_dim md
      LEFT JOIN pk_curefitplatforms_membershipdb.memberships mdb ON mdb.id = md.membership_service_id
	WHERE
	  1 = 1
	  AND md.membership_created_date BETWEEN {{Start_Date}} AND {{End_Date}}
	  AND md.business_line IN ('LIVE', 'TRANSFORM') -- At-home footfalls are tied to LIVE and TRANSFORM memberships.
  ) base
  LEFT JOIN dwh_live.live_bookings
  ON live_bookings.userid = base.user_id
  AND date(createddate_date) BETWEEN pack_start_date AND pack_end_date -- Mapping sessions during the pack duration
  AND date(createddate_date) BETWEEN {{Start_Date}} AND {{End_Date}} -- Report window bounds at-home sessions, not just membership eligibility.
  AND coalesce(usersessionid, 'xx') NOT LIKE '%FIT%FIVE%'
  AND live_bookings.userid_50_percent_completed IS NOT NULL -- Count only sessions where the user completed enough of the live workout.

GROUP BY
  1,
  2,
  3,
  4
ORDER BY
  1,
  2