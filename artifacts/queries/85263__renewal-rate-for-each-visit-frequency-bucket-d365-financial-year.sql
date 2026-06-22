-- Purpose:
-- This query measures D365 renewal performance by financial year for ELITE and PRO.
-- "D365" means the user renewed within 365 days after their pack end date.
--
-- Important interpretation notes for auditors:
-- 1. We are not using the live current state of memberships. We are using a fixed
--    membership_fact snapshot dated 2026-06-16 so the same source cut is applied
--    consistently every time the query runs.
-- 2. The reporting period is hardcoded from 2022-04-01 to 2026-03-31, and
--    it is applied on pack_end_date itself.
--    In simple terms: FY24 means pack_end_date between 2022-04-01 and 2023-03-31,
--    FY25 means pack_end_date between 2023-04-01 and 2024-03-31, and so on.
-- 3. Enterprise/B2B memberships are excluded because this cut is intended to
--    reflect consumer renewal behavior.

WITH membership_fact_snapshot AS (
  -- Step 1: Start from a fixed membership_fact snapshot.
  -- Reason:
  -- membership_fact is partitioned by transaction_date, so this fixed date keeps
  -- the query stable and audit-friendly. We then keep only the latest record per
  -- membership_key inside that fixed snapshot cut.
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
      AND mf.business_line IN ('ELITE', 'PRO')
  )
  WHERE rn = 1
),

active_center AS (
  -- Step 2: Identify "active" centers.
  -- Reason:
  -- Some membership attribution logic depends on whether a center was genuinely
  -- operational in that month. A center is treated as active if its attended
  -- booking volume is sufficiently large (>1000), with a fallback to the prior
  -- month when the current month looks artificially low.
  SELECT class_month, center_service_id
  FROM (
    SELECT
      class_month,
      center_service_id,
      CASE
        WHEN classes < 1000 THEN lag(classes) OVER (
          PARTITION BY center_service_id
          ORDER BY class_month
        )
        ELSE classes
      END AS actual_classes
    FROM (
      SELECT
        date_trunc('month', date(bf.class_date)) AS class_month,
        cd.center_service_id,
        count(DISTINCT bf.booking_key) AS classes
      FROM dwh_fitness_mart.booking_fact bf
      JOIN dwh_fitness_mart.center_dim cd
        ON cd.center_key = bf.center_key
      WHERE bf.attendance_time IS NOT NULL
        AND date(bf.class_date) BETWEEN DATE('2022-04-01') AND DATE('2026-03-31')
        AND date(bf.class_date) >= date('2016-01-01')
      GROUP BY 1,2
    )
  )
  WHERE actual_classes > 1000
),

same_device_flag AS (
  -- Step 3: Detect likely renewals on the same device but under a different user id.
  -- Reason:
  -- This follows the renewal-side logic from card 85336. It is broader than the
  -- base cohort and is used only to recover likely renewals that would be missed
  -- by a direct user_id-only check.
  SELECT
    date_trunc('month', last_data.pack_end_date) AS date_month,
    last_data.business_line,
    last_data.userid AS user_id,
    max(
      CASE
        WHEN last_data.userid <> first_data.userid
         AND date_diff(
               'day',
               date(last_data.pack_end_date),
               date(first_data.membership_created_time)
             ) <= 60
        THEN 1 ELSE 0
      END
    ) AS same_device_d60_flag
  FROM (
    SELECT
      mf.user_id AS userid,
      mf.business_line,
      bf.device_id,
      date(mf.pack_end_date) AS pack_end_date,
      mf.membership_created_time
    FROM dwh_fitness_mart.booking_fact bf
    JOIN membership_fact_snapshot mf
      ON bf.membership_key = mf.membership_key
     AND date(bf.class_date)
            BETWEEN date(mf.pack_end_date) - interval '30' day
                AND date(mf.pack_end_date)
    WHERE lower(coalesce(mf.status, 'xx')) NOT LIKE '%canc%'
      AND mf.business_line IN ('ELITE', 'PRO')
      AND bf.class_date > date('2017-01-01')
      AND bf.device_id IS NOT NULL
      AND date(mf.pack_end_date) BETWEEN DATE('2022-04-01') AND DATE('2026-03-31')
  ) last_data
  JOIN (
    SELECT
      mf.user_id AS userid,
      mf.business_line,
      bf.device_id,
      mf.membership_created_time
    FROM dwh_fitness_mart.booking_fact bf
    JOIN membership_fact_snapshot mf
      ON bf.membership_key = mf.membership_key
     AND date(bf.class_date)
            BETWEEN date(mf.pack_start_date)
                AND date(mf.pack_start_date) + interval '30' day
    WHERE lower(coalesce(mf.status, 'xx')) NOT LIKE '%canc%'
      AND mf.business_line IN ('ELITE', 'PRO')
      AND bf.class_date > date('2017-01-01')
      AND bf.device_id IS NOT NULL
  ) first_data
    ON last_data.device_id = first_data.device_id
   AND last_data.membership_created_time < first_data.membership_created_time
   AND last_data.business_line = first_data.business_line
  GROUP BY 1,2,3
),

renewal_history AS (
  -- Step 4: Build the broad renewal universe.
  -- Reason:
  -- This follows card 85336. It determines the "next pack purchased time" from
  -- the broader membership universe so renewal identification is consistent with
  -- the approved renewal logic.
  SELECT
    mf.membership_key,
    lead(mf.membership_created_time) OVER (
      PARTITION BY mf.user_id
      ORDER BY mf.membership_created_time
    ) AS next_pack_purchased_time
  FROM membership_fact_snapshot mf
  WHERE lower(coalesce(mf.status, 'xx')) NOT LIKE '%canc%'
    AND mf.business_line IN ('ELITE', 'PRO')
    AND coalesce(mf.attribution_reason, 'xx') NOT IN ('MANUAL_OVERRIDE_CENTER_SHUTDOWN')
),

membership_history AS (
  -- Step 5: Build the expiry cohort base exactly as in the existing 85263 logic.
  -- Reason:
  -- The user asked that the base should not change. So pack types included in
  -- the cohort remain the same as before, while renewals are evaluated using the
  -- broader renewal logic above.
  SELECT
    date_trunc('month', date(mf.pack_end_date)) AS date_month,
    date_trunc('month', date(mf.pack_end_date)) AS retention_date_month,
    mf.membership_key,
    mf.user_id,
    mf.business_line,
    date(mf.pack_start_date) AS pack_start_date,
    date(mf.pack_end_date) AS pack_end_date,
    date_add('day', 365, date(mf.pack_end_date)) AS d365_date,
    CASE
      WHEN lower(cd.center_name) LIKE 'cure.fit%' THEN 'Curefit_Attributed'
      ELSE cd.center_type
    END AS derived_center_type,
    cd.center_service_id AS attributed_centerservice_id,
    cd.center_name AS attributed_centername,
    mf.is_enterprise
  FROM membership_fact_snapshot mf
  LEFT JOIN dwh_fitness_mart.center_dim cd
    ON mf.attributed_center_key = cd.center_key
  WHERE lower(coalesce(mf.status, 'xx')) NOT LIKE '%canc%'
    AND mf.business_line IN ('ELITE', 'PRO')
    AND coalesce(mf.attribution_reason, 'xx') NOT IN ('MANUAL_OVERRIDE_CENTER_SHUTDOWN')
    AND (
      mf.amount_paid > 0
      OR coalesce(mf.membership_type, 'xx') IN ('MEMBER_MIGRATION', 'ENTERPRISE', 'MIGRATION')
      OR coalesce(mf.pack_name, 'xx') IN ('Transferred Pack')
      OR coalesce(mf.status, 'xx') IN ('MEMBERSHIP_TRANSFERRED')
      OR coalesce(mf.source, 'xx') IN ('MIGRATION')
    )
),

membership_base AS (
  -- Step 6: Restrict the cohort to the hardcoded pack-end reporting window and B2C only.
  SELECT *
  FROM membership_history
  WHERE pack_end_date BETWEEN DATE('2022-04-01') AND DATE('2025-03-31')
    AND is_enterprise = 0
),

base_membership AS (
  -- Step 7: Classify whether each base membership renewed within 365 days.
  -- Reason:
  -- The base membership cohort stays unchanged, but the actual renewal signal
  -- now uses the broader renewal universe from card 85336.
  SELECT
    mb.date_month,
    mb.retention_date_month,
    mb.membership_key,
    mb.user_id,
    mb.business_line,
    CASE
      WHEN rh.next_pack_purchased_time IS NOT NULL
       AND date(rh.next_pack_purchased_time) <= mb.d365_date
      THEN 1 ELSE 0
    END AS direct_d365_flag,
    CASE
      WHEN mb.derived_center_type = 'Curefit_Attributed'
      THEN mb.business_line || '_Curefit_Attributed'
      ELSE mb.business_line || '_' || mb.derived_center_type
    END AS category
  FROM membership_base mb
  LEFT JOIN renewal_history rh
    ON mb.membership_key = rh.membership_key
  LEFT JOIN active_center ac
    ON ac.center_service_id = mb.attributed_centerservice_id
   AND ac.class_month = mb.date_month
  WHERE lower(mb.attributed_centername) LIKE 'cure.fit%'
     OR ac.center_service_id IS NOT NULL
),

filtered_membership AS (
  -- Step 8: Keep only the allowed business-line x center-type combinations.
  SELECT *
  FROM base_membership
  WHERE category IN (
    'ELITE_GX',
    'ELITE_GYM',
    'ELITE_Curefit_Attributed',
    'PRO_GX',
    'PRO_GYM',
    'PRO_Curefit_Attributed'
  )
),

user_month_base AS (
  -- Step 9: Collapse to one record per user per month per business line.
  SELECT
    date_month,
    retention_date_month,
    user_id,
    business_line,
    max(direct_d365_flag) AS direct_d365_flag
  FROM filtered_membership
  GROUP BY 1,2,3,4
),

flagged AS (
  -- Step 10: Final renewal flag at user level.
  SELECT
    umb.date_month,
    umb.retention_date_month,
    umb.user_id,
    umb.business_line,
    CASE
      WHEN greatest(
             coalesce(umb.direct_d365_flag, 0),
             coalesce(sdf.same_device_d60_flag, 0)
           ) = 1
      THEN 1 ELSE 0
    END AS renewed_flag
  FROM user_month_base umb
  LEFT JOIN same_device_flag sdf
    ON sdf.user_id = umb.user_id
   AND sdf.date_month = umb.date_month
   AND sdf.business_line = umb.business_line
),

user_detail AS (
  -- Step 11: Convert cohort months into financial years and aggregate by business line.
  SELECT
   CASE
      WHEN month(retention_date_month) >= 4
      THEN concat('FY', cast(year(retention_date_month) +1 AS varchar), '-', substr(cast(year(retention_date_month) + 2 AS varchar), 3, 2))
      ELSE concat('FY', cast(year(retention_date_month)  AS varchar), '-', substr(cast(year(retention_date_month) +1 AS varchar), 3, 2))
    END AS financial_year,
    CASE
      WHEN month(retention_date_month) >= 4 THEN year(retention_date_month)
      ELSE year(retention_date_month) - 1
    END AS fy_start_year,
    business_line,
    count(DISTINCT user_id) AS base,
    count(DISTINCT CASE WHEN renewed_flag = 1 THEN user_id END) AS renewed_users
  FROM flagged
  GROUP BY 1,2,3
),

user_overall AS (
  -- Step 12: Build the overall ELITE+PRO line.
  SELECT
     CASE
      WHEN month(retention_date_month) >= 4
      THEN concat('FY', cast(year(retention_date_month) +1 AS varchar), '-', substr(cast(year(retention_date_month) + 2 AS varchar), 3, 2))
      ELSE concat('FY', cast(year(retention_date_month)  AS varchar), '-', substr(cast(year(retention_date_month) +1 AS varchar), 3, 2))
    END AS financial_year,
    CASE
      WHEN month(retention_date_month) >= 4 THEN year(retention_date_month)
      ELSE year(retention_date_month) - 1
    END AS fy_start_year,
    'OVERALL' AS business_line,
    count(DISTINCT user_id) AS base,
    count(DISTINCT CASE WHEN renewed_flag = 1 THEN user_id END) AS renewed_users
  FROM flagged
  GROUP BY 1,2,3
),

final_users AS (
  SELECT * FROM user_detail
  UNION ALL
  SELECT * FROM user_overall
)

SELECT
  financial_year,
  business_line,
  base,
  renewed_users,
  round(
    100.0 * renewed_users / nullif(base, 0),
    2
  ) AS d365_pct
FROM final_users
ORDER BY
  fy_start_year DESC,
  business_line
