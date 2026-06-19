-- Purpose:
--   Count paid ELITE / PRO / PLAY / LUX members by gender as of the selected end date.
--
-- Auditor note:
--   This query intentionally keeps the same gender source order as the older
--   Metabase card, so the output remains comparable to prior reporting.
--
-- Output:
--   Gender  - "m", "f", or "NA"
--   MEMBERS - distinct paid member users in the eligible member base
--
-- Important validation note:
--   The earlier aggressive simplification changed results because it allowed
--   "predictedgender" rows from Rashi attributes to contribute. The original
--   query text only scans Attribute IN ('Gender', 'gender', 'birthday'), so
--   predictedgender is kept inside the CASE for compatibility but is not
--   actually included by the WHERE filter.
WITH

-- 1. Build the eligible member base.
--
-- Business rule:
--   Include users who had a paid ELITE / PRO / PLAY membership created between
--   2017-10-01 and the selected Metabase end date {{ed}}.
--
-- Date rule:
--   For transferred or upgraded packs, use the membership-service created_date.
--   For all other packs, use membership_created_date from membership_dim.
--
-- Why GROUP BY 1:
--   A user may have multiple qualifying memberships. The final count is member
--   users, so each user should appear once in the base.
base AS (
  SELECT
    m.user_id
  FROM dwh_fitness_mart.membership_fact m
  LEFT JOIN pk_curefitplatforms_membershipdb.memberships mdb
    ON mdb.id = m.membership_service_id
  WHERE DATE(
      CASE
        WHEN LOWER(CAST(m.is_transferred_pack AS VARCHAR)) = 'true'
          OR LOWER(CAST(m.is_upgrade_pack AS VARCHAR)) = 'true'
          THEN mdb.created_date
        ELSE m.membership_created_date
      END
    ) BETWEEN DATE('2017-10-01') AND {{ed}}
    AND m.business_line IN ('ELITE', 'PRO', 'PLAY', 'LUX')
    AND m.amount_paid > 0
	-- Freeze to a single fact-table snapshot so results do not move because of
    -- late-arriving tech changes or partition refreshes.
	AND m.transaction_date = date '2026-06-16'
  GROUP BY 1
),

-- 2. Read gender captured during post-pack-purchase onboarding.
--
-- Business meaning:
--   This is self-declared information from the onboarding form. It is used only
--   when the user profile and Rashi attribute sources do not provide gender.
--
-- Why DOB fields remain here:
--   The old card calculated age in this CTE even though the final report only
--   shows gender. We keep the same calculation shape to avoid changing edge
--   behavior in the source aggregation.
age_onboarding AS (
  SELECT
    nrs.userid,
    DATE_DIFF(
      'year',
      DATE(SUBSTR(MAX(CASE WHEN nrs.questionid = 'onboarding_user_dob_v1' THEN nrs.answer END), 1, 10)),
      CURRENT_DATE
    ) AS age,
    DATE(SUBSTR(MAX(CASE WHEN nrs.questionid = 'onboarding_user_dob_v1' THEN nrs.answer END), 1, 10)) AS birthday,
    SUBSTR(
      MAX(
        CASE
          WHEN nrs.questionid = '@Home Guidance_Gender_v1'
            AND LOWER(TRIM(nrs.answer)) IN ('m', 'f')
            THEN LOWER(TRIM(nrs.answer))
        END
      ),
      1,
      1
    ) AS gender
  FROM pk_curefitprod_cfdb.npsresponses nrs
  WHERE nrs.answer IS NOT NULL
    AND nrs.answer != ''
    AND nrs.formid = 'post_pack_purchase_onboarding'
    AND nrs.questionid IN ('onboarding_user_dob_v1', '@Home Guidance_Gender_v1')
	AND coalesce(date(created_at), date('1900-01-01')) <= {{ed}} -- ensure no backfill
  GROUP BY 1
),

-- 3. Read gender from the latest user profile row.
--
-- Business meaning:
--   This is the preferred source because it comes from the primary user profile.
--
-- Why ROW_NUMBER:
--   The user table can contain multiple versions of a profile. The latest
--   updated row is used, matching the older card behavior.
user_age AS (
  SELECT
    CAST(id AS VARCHAR) AS userid,
    CASE
      WHEN SUBSTR(LOWER(TRIM(gender)), 1, 1) IN ('m', 'f')
        THEN SUBSTR(LOWER(TRIM(gender)), 1, 1)
    END AS gender,
    DATE_DIFF('year', CAST(SUBSTR(birthday, 1, 10) AS DATE), CURRENT_DATE) AS age,
    CAST(SUBSTR(birthday, 1, 10) AS DATE) AS birthday
  FROM (
    SELECT
      id,
      gender,
      birthday,
      ROW_NUMBER() OVER (PARTITION BY id ORDER BY updatedat DESC) AS rf
    FROM pk_cfuserservice_cultapp.User
	WHERE coalesce(date(createdat), date('1900-01-01'))<= {{ed}} -- ensure no backfil 
  ) user
  WHERE rf = 1
),

-- 4. Read gender from Rashi user attributes.
--
-- Business meaning:
--   This is the fallback source after the user profile. It captures gender-like
--   attributes stored in the Rashi platform.
--
-- Important:
--   The WHERE clause intentionally includes only 'Gender', 'gender', and
--   'birthday'. Although the CASE also mentions 'predictedgender', the original
--   query never scanned predictedgender rows because of this WHERE filter.
--   Keeping that behavior avoids changing reported numbers.
rashi_age AS (
  SELECT
    CAST(Userid AS VARCHAR) AS userid,
    DATE_DIFF(
      'year',
      MIN(DATE(FROM_UNIXTIME(CAST(CASE WHEN Attribute IN ('birthday') THEN value END AS DOUBLE) / 1000) + INTERVAL '330' MINUTE)),
      CURRENT_DATE
    ) AS age,
    MIN(DATE(FROM_UNIXTIME(CAST(CASE WHEN Attribute IN ('birthday') THEN value END AS DOUBLE) / 1000) + INTERVAL '330' MINUTE)) AS birthday,
    MAX(
      CASE
        WHEN Attribute IN ('Gender', 'gender', 'predictedgender')
          AND COALESCE(
            SUBSTR(LOWER(CAST(JSON_EXTRACT(value, '$.gender') AS VARCHAR)), 1, 1),
            SUBSTR(TRIM(LOWER(value)), 1, 1)
          ) IN ('m', 'f')
          THEN COALESCE(
            SUBSTR(LOWER(CAST(JSON_EXTRACT(value, '$.gender') AS VARCHAR)), 1, 1),
            SUBSTR(TRIM(LOWER(value)), 1, 1)
          )
      END
    ) AS gender
  FROM pk_cfprodplatforms_rashi.User_Attribute
  WHERE Attribute IN ('Gender', 'gender', 'birthday') -- Attribute itself is partition | so avoiding date filter
    AND value != ''
  GROUP BY 1
),

-- 5. Pick one gender per user.
--
-- Source priority:
--   1. Latest user profile gender
--   2. Rashi attribute gender
--   3. Onboarding form gender
--   4. NA when no valid gender is available
--
-- Why we still start from the full User table:
--   This mirrors the old card. Restricting this step to only users in base is
--   tempting for performance, but it caused a small result difference in
--   validation. For audit reporting, we keep the exact source behavior.
gender_base AS (
  SELECT
    CAST(u.id AS VARCHAR) AS user_id,
    COALESCE(ua.gender, ra.gender, ab.gender, 'NA') AS gender
  FROM pk_cfuserservice_cultapp.User u
  LEFT JOIN user_age ua
    ON ua.userid = CAST(u.id AS VARCHAR)
  LEFT JOIN rashi_age ra
    ON CAST(ra.userid AS VARCHAR) = CAST(u.id AS VARCHAR)
  LEFT JOIN age_onboarding ab
    ON CAST(ab.userid AS VARCHAR) = CAST(u.id AS VARCHAR)
)

-- 6. Join the eligible member base to the selected gender and count members.
--
-- Final cleanup:
--   Blank gender values are reported as NA. This keeps the output simple and
--   avoids a separate empty-string bucket in the table.
SELECT
  COALESCE(NULLIF(TRIM(gender_base.gender), ''), 'NA') AS Gender,
  COUNT(base.user_id) AS MEMBERS
FROM base
LEFT JOIN gender_base
  ON gender_base.user_id = base.user_id
GROUP BY 1
ORDER BY 1
