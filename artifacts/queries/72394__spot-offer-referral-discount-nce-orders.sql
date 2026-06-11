/*
    CISA Auditing

    Purpose:
      Measure how many new paid membership orders came through referral-related
      offers, grouped by financial year.

    Output:
      1. FY
      2. New Orders
      3. Referral Orders
      4. % Referral Orders

    Important scope note:
      Revenue-side analysis is intentionally excluded from the final output.
      The revenue fields are still present/commented in the query only for
      traceability and future reference.

    Financial years covered:
      FY23-24 = 2023-04-01 to 2024-03-31
      FY24-25 = 2024-04-01 to 2025-03-31
      FY25-26 = 2025-04-01 to 2026-03-31
*/

WITH non_complimentary_memberships AS (
    /*
        This CTE creates each user's valid paid-membership sequence.

        Why this is needed:
          For PLAY / LIVE / LUX, the query derives whether an order is "New"
          or "Repeat" by checking whether it is the user's first valid paid
          membership.

        Why complimentary memberships are excluded:
          Free memberships should not make a later paid membership look like
          a repeat paid purchase.

        Why cancelled / transferred / upgraded memberships are excluded:
          These statuses may not represent a clean new paid acquisition order.
          Excluding them helps ensure the first-membership rank is based on
          genuine paid memberships only.

        Why enterprise memberships are excluded:
          Enterprise memberships follow a different business/payment flow and
          should not affect consumer new-vs-repeat classification here.

        Auditor note:
          This CTE is not date-bounded. That means it uses the full available
          membership history to classify whether a user's membership is first
          or repeat. This is useful for lifetime New/Repeat accuracy.
		  Actual date-bounding is carried out in base CTE by defining Main reporting window for membership orders.
    */
    SELECT
        membership_dim.membership_key,
        membership_dim.user_id,

        /*
            Rank each user's valid paid memberships in chronological order.

            rank = 1 means this is the user's first valid paid membership.
            rank > 1 means the user had a prior valid paid membership.
        */
        row_number() OVER (
            PARTITION BY membership_dim.user_id
            ORDER BY
                membership_dim.membership_created_date ASC,
                membership_dim.membership_created_time ASC,
                membership_dim.order_id ASC
        ) AS non_complimentary_membership_rank

    FROM dwh_fitness_mart.membership_dim

    WHERE upper(COALESCE(membership_dim.membership_type, '')) NOT IN ('COMPLIMENTARY', 'COMPLIMENTORY')
        AND status NOT LIKE '%CANCEL%'
        AND status NOT LIKE 'TRANSFER%'
        AND status NOT LIKE 'UPGRADE%'
        AND is_enterprise = 0
),

membership_classified AS (
    /*
        This CTE assigns each membership a New / Repeat classification.

        ELITE / PRO:
          Uses membership_dim.fitness_membership_type because that field is
          already maintained for these business lines.

        Complimentary memberships:
          Set to NULL because free memberships are not counted as paid new
          acquisition orders.

        PLAY / LIVE / LUX:
          Uses the first valid paid-membership rank from the previous CTE:
            rank = 1 => New
            rank > 1 => Repeat
    */
    SELECT
        membership_dim.membership_key,
        membership_dim.order_id,
        membership_dim.user_id,
        membership_dim.membership_created_date,
        membership_dim.amount_paid,
        membership_dim.business_line,

        CASE
            WHEN membership_dim.business_line IN ('ELITE', 'PRO')
                THEN COALESCE(membership_dim.fitness_membership_type, 'Repeat')

            WHEN upper(COALESCE(membership_dim.membership_type, '')) IN ('COMPLIMENTARY', 'COMPLIMENTORY')
                THEN NULL

            WHEN ncm.non_complimentary_membership_rank = 1
                THEN 'New'

            WHEN ncm.non_complimentary_membership_rank > 1
                THEN 'Repeat'

            ELSE NULL
        END AS derived_membership_type

    FROM dwh_fitness_mart.membership_dim

    LEFT JOIN non_complimentary_memberships ncm
        ON membership_dim.membership_key = ncm.membership_key

    WHERE 1 = 1
),

base AS (
    /*
        This CTE creates the final order-level base.

        One row represents one qualifying membership order, with:
          is_new_order      = whether the order is classified as New
          is_referral_order = whether the order used a referral-related offer
    */
    SELECT
        /*
            Map each membership order into the required financial year.
        */
        CASE
            WHEN membership_classified.membership_created_date BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'
                THEN 'FY23-24'

            WHEN membership_classified.membership_created_date BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'
                THEN 'FY24-25'

            WHEN membership_classified.membership_created_date BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'
                THEN 'FY25-26'
        END AS FY,

        membership_classified.order_id,

        /*
            Revenue is retained in the base for traceability, but revenue
            metrics are intentionally commented out in the final SELECT.
        */
        COALESCE(membership_classified.amount_paid, 0) AS revenue,

        membership_classified.business_line,

        CASE
            WHEN membership_classified.derived_membership_type = 'New' THEN 1
            ELSE 0
        END AS is_new_order,

        CASE
            WHEN orders_offer_fact.order_id IS NOT NULL THEN 1
            ELSE 0
        END AS is_referral_order

    FROM membership_classified

    LEFT JOIN (
        /*
            Referral-offer lookup.

            Why DISTINCT order_id:
              An order may have multiple offer rows. The metric only needs to
              know whether the order had at least one referral offer. DISTINCT
              prevents duplicate offer rows from inflating order counts.

            Why offer_dim is used:
              Referral offers are identified using offer titles containing
              "refer", rather than maintaining a fixed list of offer IDs.

            Date filter:
              Only offer usage between 2023-04-01 and 2026-03-31 is considered.
        */
        SELECT DISTINCT
            order_id
        FROM dwh_fitness_mart.orders_offer_fact
        WHERE offer_id IN (
            SELECT
                offer_id
            FROM dwh_fitness_mart.offer_dim
            WHERE lower(title) LIKE '%refer%'
        )
            AND purchase_date BETWEEN DATE('2023-04-01') AND DATE('2026-03-31')
    ) AS orders_offer_fact
        ON orders_offer_fact.order_id = membership_classified.order_id

    WHERE membership_classified.amount_paid > 2000

        /*
            Main reporting window for membership orders.
        */
        AND membership_classified.membership_created_date BETWEEN DATE('2023-04-01') AND DATE('2026-03-31')
        AND membership_classified.business_line IN ('ELITE', 'PRO', 'PLAY', 'LIVE', 'LUX')

        /*
            Final metric is only for new paid membership orders.
        */
        AND membership_classified.derived_membership_type IN ('New')
)

SELECT
    FY,

    /*
        Total number of distinct new paid membership orders.
    */
    COUNT(DISTINCT CASE
        WHEN is_new_order = 1 THEN order_id
    END) AS "New Orders",

    /*
        Number of distinct new paid membership orders that used a
        referral-related offer.
    */
    COUNT(DISTINCT CASE
        WHEN is_new_order = 1
            AND is_referral_order = 1
            THEN order_id
    END) AS "Referral Orders",

    /*
        Share of new orders that used referral.

        NULLIF prevents divide-by-zero if any FY has zero new orders.
    */
    ROUND(
        1.0 * COUNT(DISTINCT CASE
            WHEN is_new_order = 1
                AND is_referral_order = 1
                THEN order_id
        END)
        / NULLIF(COUNT(DISTINCT CASE
            WHEN is_new_order = 1 THEN order_id
        END), 0),
        2
    ) AS "% Referral Orders"

FROM base

/*
    Keep only rows mapped to the three required financial years.
*/
WHERE FY IS NOT NULL

GROUP BY 1

/*
    Orders FY labels chronologically because the labels sort correctly here.
*/
ORDER BY 1
