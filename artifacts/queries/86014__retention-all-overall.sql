-- Purpose:
-- Combined D365 retention query 


WITH membership_fact_snapshot AS (

  SELECT *
  FROM (
    SELECT
      mf.*,
      row_number() OVER (
        PARTITION BY mf.membership_key
        ORDER BY mf.transaction_date DESC, mf.membership_fact_ts_ms DESC
      ) AS rn
    FROM dwh_fitness_mart.membership_fact mf
    WHERE mf.transaction_date = DATE('2026-06-16')
      AND mf.business_line IN ('ELITE', 'PRO', 'LUX', 'PLAY', 'LIVE', 'TRANSFORM', 'PLAY_ACADEMY', 'GOLDs', 'SGT')
  )
  WHERE rn = 1
),

membership_fact_enriched AS (
  SELECT
    mf.*,
    date(coalesce(mf.membership_created_time, CAST(mf.membership_created_date AS timestamp))) AS membership_purchase_date,
    CASE
      WHEN mf.cancellation_date IS NOT NULL
      THEN least(date(mf.pack_end_date), date(mf.cancellation_date))
      ELSE date(mf.pack_end_date)
    END AS effective_pack_end_date
  FROM membership_fact_snapshot mf
),

same_device_flag_core AS (
  SELECT
    date_trunc('month', last_data.effective_pack_end_date) AS date_month,
    last_data.business_line,
    last_data.userid AS user_id,
    max(
      CASE
        WHEN last_data.userid <> first_data.userid
         AND date_diff(
               'day',
               date(last_data.effective_pack_end_date),
               date(first_data.membership_created_time)
             ) <= 365
        THEN 1 ELSE 0
      END
    ) AS same_device_d365_flag
  FROM (
    SELECT
      mf.user_id AS userid,
      mf.business_line,
      bf.device_id,
      mf.effective_pack_end_date,
      mf.membership_created_time
    FROM dwh_fitness_mart.booking_fact bf
    JOIN membership_fact_enriched mf
      ON bf.membership_key = mf.membership_key
     AND date(bf.class_date)
            BETWEEN mf.effective_pack_end_date - interval '365' day
                AND mf.effective_pack_end_date
    WHERE mf.business_line IN ('ELITE', 'PRO', 'LUX')
      AND bf.class_date > date('2017-01-01')
      AND bf.device_id IS NOT NULL
      AND mf.effective_pack_end_date BETWEEN DATE('2022-04-01') AND DATE('2026-03-31')
      AND (
        mf.cancellation_date IS NULL
        OR mf.membership_purchase_date <> date(mf.cancellation_date)
      )
	
  ) last_data
  JOIN (
    SELECT
      mf.user_id AS userid,
      mf.business_line,
      bf.device_id,
      mf.membership_created_time
    FROM dwh_fitness_mart.booking_fact bf
    JOIN membership_fact_enriched mf
      ON bf.membership_key = mf.membership_key
     AND date(bf.class_date)
            BETWEEN date(mf.pack_start_date)
                AND date(mf.pack_start_date) + interval '365' day
    WHERE mf.business_line IN ('ELITE', 'PRO', 'LUX')
      AND bf.class_date > date('2017-01-01')
      AND bf.device_id IS NOT NULL
      AND (
        mf.cancellation_date IS NULL
        OR mf.membership_purchase_date <> date(mf.cancellation_date)
      )
	
  ) first_data
    ON last_data.device_id = first_data.device_id
   AND last_data.membership_created_time < first_data.membership_created_time
   AND last_data.business_line = first_data.business_line
  GROUP BY 1,2,3
),

renewal_history_core AS (
  SELECT
    mf.membership_key,
    lead(mf.membership_created_time) OVER (
      PARTITION BY mf.user_id
      ORDER BY mf.membership_created_time, membership_key
    ) AS next_pack_purchased_time
  FROM membership_fact_enriched mf
  WHERE mf.business_line IN ('ELITE', 'PRO', 'LUX')
    -- AND coalesce(mf.attribution_reason, 'xx') NOT IN ('MANUAL_OVERRIDE_CENTER_SHUTDOWN')
    AND (
      mf.cancellation_date IS NULL
      OR mf.membership_purchase_date <> date(mf.cancellation_date)
    )
),

membership_history_core AS (
  SELECT
    date_trunc('month', mf.effective_pack_end_date) AS date_month,
    mf.membership_key,
    CAST(mf.user_id AS varchar) AS user_id,
    mf.business_line,
    mf.effective_pack_end_date AS pack_end_date,
    date_add('day', 365, mf.effective_pack_end_date) AS d365_date,
    mf.is_enterprise,cancellation_date
  FROM membership_fact_enriched mf
  LEFT JOIN dwh_fitness_mart.center_dim cd
    ON mf.attributed_center_key = cd.center_key
  WHERE mf.business_line IN ('ELITE', 'PRO', 'LUX')
    -- AND coalesce(mf.attribution_reason, 'xx') NOT IN ('MANUAL_OVERRIDE_CENTER_SHUTDOWN')
    AND (
      mf.cancellation_date IS NULL
      OR mf.membership_purchase_date <> date(mf.cancellation_date)
    )
),

membership_base_core AS (
  SELECT *
  FROM membership_history_core
  WHERE  LEAST(COALESCE(cancellation_date, pack_end_date), pack_end_date) BETWEEN DATE('2022-04-01') AND DATE('2025-03-31')
    -- AND is_enterprise = 0
),

base_membership_core AS (
  SELECT
    mb.date_month,
    mb.membership_key,
    mb.user_id,
    mb.business_line,
    CASE
      WHEN rh.next_pack_purchased_time IS NOT NULL
       AND date(rh.next_pack_purchased_time) <= mb.d365_date
      THEN 1 ELSE 0
    END AS direct_d365_flag
  FROM membership_base_core mb
  LEFT JOIN renewal_history_core rh
    ON mb.membership_key = rh.membership_key
),

user_month_base_core AS (
  SELECT
    date_month,
    membership_key,
    user_id,
    business_line,
    max(direct_d365_flag) AS direct_d365_flag
  FROM base_membership_core
  GROUP BY 1,2,3,4
),

flagged_core AS (
  SELECT
    umb.date_month,
    umb.membership_key,
    umb.user_id,
    umb.business_line,
    CASE
      WHEN greatest(
             coalesce(umb.direct_d365_flag, 0),
             coalesce(sdf.same_device_d365_flag, 0)
           ) = 1
      THEN 1 ELSE 0
    END AS renewed_flag
  FROM user_month_base_core umb
  LEFT JOIN same_device_flag_core sdf
    ON sdf.user_id = umb.user_id
   AND sdf.date_month = umb.date_month
   AND sdf.business_line = umb.business_line
),

play_live_history AS (
  SELECT
    date_trunc('month', mf.effective_pack_end_date) AS date_month,
    mf.membership_key,
    CAST(mf.user_id AS varchar) AS user_id,
    mf.business_line,
    mf.effective_pack_end_date AS pack_end_date,
    date_add('day', 365, mf.effective_pack_end_date) AS d365_date,
    mf.membership_created_time,
    lead(mf.membership_created_time) OVER (
      PARTITION BY mf.user_id, mf.business_line
      ORDER BY mf.membership_created_time, mf.effective_pack_end_date, mf.membership_key
    ) AS next_same_line_purchase_time,effective_pack_end_date,is_enterprise
  FROM membership_fact_enriched mf
  WHERE mf.business_line IN ('PLAY', 'LIVE', 'TRANSFORM', 'PLAY_ACADEMY', 'GOLDs', 'SGT')
    AND (
      mf.cancellation_date IS NULL
      OR mf.membership_purchase_date <> date(mf.cancellation_date)
    )
	
	AND (
      mf.cancellation_date IS NULL
      OR mf.pack_start_date <> date(mf.cancellation_date)
    )
	
),

flagged_play_live AS (
  SELECT
    date_month,
    membership_key,
    user_id,
    business_line,
    CASE
      WHEN next_same_line_purchase_time IS NOT NULL
       AND date(next_same_line_purchase_time) <= d365_date
      THEN 1 ELSE 0
    END AS renewed_flag
  FROM play_live_history
  WHERE effective_pack_end_date BETWEEN DATE('2022-04-01') AND DATE('2025-03-31')
    -- AND coalesce(is_enterprise,0) = 0
),

combined_flagged AS (
  SELECT * FROM flagged_core
  UNION ALL
  SELECT * FROM flagged_play_live
),

user_overall AS (
  SELECT
    CASE
      WHEN month(date_month) >= 4
      THEN concat('FY', cast(year(date_month) + 1 AS varchar), '-', substr(cast(year(date_month) + 2 AS varchar), 3, 2))
      ELSE concat('FY', cast(year(date_month) AS varchar), '-', substr(cast(year(date_month) + 1 AS varchar), 3, 2))
    END AS financial_year,
    CASE
      WHEN month(date_month) >= 4 THEN year(date_month)
      ELSE year(date_month) - 1
    END AS fy_start_year,
    count(DISTINCT membership_key) AS base,
    count(DISTINCT CASE WHEN renewed_flag = 1 THEN membership_key END) AS renewed_users
  FROM combined_flagged
  GROUP BY 1,2
),

final_users AS (
  SELECT * FROM user_overall
)

SELECT
  financial_year,
  round(100.0 * renewed_users / nullif(base, 0), 2) AS d365_pct
FROM final_users
ORDER BY fy_start_year DESC
