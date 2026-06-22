WITH dates AS (
  -- Build one row per reporting month.
  -- In the output, `month` is the first day of the month,
  -- but the membership check is done on that month's last day.
  SELECT
    date_trunc('month', full_date) AS month,
    min(full_date) AS month_start_date,
    max(full_date) AS month_end_date,
    date_add('day', -1, min(full_date)) AS prev_month_end_date
  FROM dwh_curefit.dim_date
  WHERE full_date BETWEEN {{start_date}} AND {{end_date}}
  GROUP BY 1
),

base_memberships AS (
  -- Prepare the membership base used for the month-end snapshot.
  --
  -- Important audit rule:
  -- For transferred / upgraded packs, the dates from the membership-service table
  -- are treated as the source of truth. This avoids counting the user on the wrong
  -- active window when pack dates changed because of a transfer or upgrade.
  SELECT
    membership_key,
    md.business_line,
    CASE
      WHEN lower(cast(md.is_transferred_pack AS varchar)) = 'true'
        OR lower(cast(md.is_upgrade_pack AS varchar)) = 'true' THEN mdb.created_date
      ELSE md.membership_created_date
    END AS membership_created_date,
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
    md.is_enterprise,
    md.user_id,
    cd.city_name,
    md.cancellation_date
  FROM dwh_fitness_mart.membership_fact md
  LEFT JOIN pk_curefitplatforms_membershipdb.memberships mdb
    ON mdb.id = md.membership_service_id
  LEFT JOIN dwh_fitness_mart.center_dim cd
    ON cd.center_key = coalesce(
      md.attributed_center_key,
      md.final_center_key,
      md.purchase_center_key,
      md.last_30_days_preferred_center_key
    )
  WHERE 1 = 1
    -- Freeze to a single fact-table snapshot so results do not move because of
    -- late-arriving tech changes or partition refreshes.
    AND md.transaction_date = date '2026-06-16'

    -- PT users are excluded because they are already counted inside ELITE / PRO.
    -- Keeping PT here would double count the membership base.
    AND upper(md.business_line) NOT LIKE '%PT%'

    -- Only keep memberships that have a mapped business line.
    AND md.business_line IS NOT NULL
),

active_memberships AS (
  -- Keep only memberships that are active on the month-end date.
  --
  -- A pack is considered active if month_end_date falls between:
  -- 1. the effective pack start date, and
  -- 2. the earlier of cancellation_date and pack_end_date.
  --
  -- This means a cancelled pack stops contributing after cancellation,
  -- even if the original pack_end_date is later.
  SELECT
    d.month,
    CASE
      WHEN md.is_enterprise = 1 THEN md.business_line || ' (B2B)'
      ELSE md.business_line
    END AS business_line,
    md.user_id,
    md.city_name,
    md.membership_key,
    md.membership_created_date,
    md.pack_start_date,
    md.pack_end_date
  FROM dates d
  JOIN base_memberships md
    ON d.month_end_date BETWEEN md.pack_start_date AND least(
      coalesce(md.cancellation_date, md.pack_end_date),
      md.pack_end_date
    )
),

deduped_user_city AS (
  -- Audit fix for city-level reporting:
  -- The same user can appear in more than one city within the same month and business line
  -- because different active membership rows can resolve to different centers / cities.
  --
  -- If we count distinct users separately inside each city bucket and later sum cities,
  -- the same user gets counted multiple times.
  --
  -- To make city totals roll back exactly to the non-city monthly total,
  -- assign each (month, business_line, user_id) to exactly one city.
  --
  -- Rule used:
  -- pick the most recent active membership row for that user within the month/business line.
  -- Ties are broken deterministically so the output is stable.
  SELECT
    month,
    business_line,
    city_name,
    user_id,
    row_number() OVER (
      PARTITION BY month, business_line, user_id
      ORDER BY
        coalesce(membership_created_date, date '1900-01-01') DESC,
        coalesce(pack_start_date, date '1900-01-01') DESC,
        coalesce(pack_end_date, date '1900-01-01') DESC,
        CASE WHEN city_name IS NULL THEN 1 ELSE 0 END,
        membership_key DESC
    ) AS city_rank
  FROM active_memberships
)

-- Final city-level month-end base.
-- Because each user is forced into one city only, summing city rows back to month
-- will match the non-city query.
SELECT
  month,
  city_name,
  count(*) AS user_base
FROM deduped_user_city
WHERE city_rank = 1
GROUP BY
  month,
  city_name
ORDER BY 1 DESC, 3 DESC
