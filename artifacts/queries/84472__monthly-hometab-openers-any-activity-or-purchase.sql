/*
    CISA Audit Note:

    Primary audited output:
        users_any_activity_or_purchase
        or pct_users_any_activity_or_purchase

    Supporting columns used for validation / traceability:
        monthly_hometab_openers
        users_booked_class
        users_purchased_pack
        users_purchased_cultstore_via_app

    These supporting columns can be ignored for final auditing. 
	Corresponding intermediate CTEs are required because the final metric is built from multiple activity sources. 

    Business logic:
    A user is counted in users_any_activity_or_purchase for a month if they:
        1. opened the home tab in that month, and
        2. completed at least one of the following activities in the same month:
            - booked a class
            - purchased a paid pack
            - purchased from Cultstore via the app
    
*/

WITH monthly_hometab_openers AS (
    SELECT DISTINCT
        CAST(user_userid AS varchar) AS user_id,
        DATE_TRUNC('month', ts_date) AS month
    FROM pk_curefit_app_events.page_view
    WHERE ts_date BETWEEN date('2023-04-01') AND date('2026-03-31') -- -- Restrict to the reporting window.
      AND ts_date >= DATE('2023-01-01') -- Partition guard to avoid scanning very old app-event data.
      AND LOWER(COALESCE(event_eventparams_pageid, '')) = 'hometab' -- Keep only app opens on the home tab; this is the base cohort.
      AND user_userid IS NOT NULL -- User-level funnel needs a valid user id for downstream joins.
),

monthly_class_bookers AS (
    SELECT DISTINCT
        o.user_id,
        o.month
    FROM dwh_fitness_mart.booking_fact bf
    JOIN monthly_hometab_openers o
        ON CAST(bf.user_id AS varchar) = o.user_id -- Same user as the hometab opener cohort.
       AND DATE_TRUNC('month', bf.booking_date) = o.month -- Same-month attribution: only count bookings in the opener's month.
    WHERE booking_date BETWEEN date('2023-04-01') AND date('2026-03-31') -- Use booking_date as the activity date requested by the business logic.
      AND class_date >= DATE('2023-01-01') -- Partition guard: booking_fact is partitioned by class_date.
      AND bf.user_id IS NOT NULL -- Prevent null-user bookings from inflating user counts.
),

monthly_pack_purchasers AS (
    SELECT DISTINCT
        o.user_id,
        o.month
    FROM dwh_fitness_mart.membership_dim m
    LEFT JOIN pk_curefitplatforms_membershipdb.memberships mdb
        ON mdb.id = m.membership_service_id -- Required only for transferred/upgraded packs, where created_date from the membership service table is the true purchase date.
    JOIN monthly_hometab_openers o
        ON CAST(m.user_id AS varchar) = o.user_id -- Same user as the hometab opener cohort.
       AND DATE_TRUNC(
            'month',
            CASE
                WHEN LOWER(CAST(m.is_transferred_pack AS varchar)) = 'true'
                  OR LOWER(CAST(m.is_upgrade_pack AS varchar)) = 'true'
                THEN DATE(mdb.created_date)
                ELSE m.membership_created_date
            END
        ) = o.month -- Same-month attribution based on the agreed pack-purchase date logic.
    WHERE m.amount_paid > 0 -- Paid members only; excludes complimentary / zero-value packs.
      AND m.user_id IS NOT NULL -- User-level aggregation requires a valid user id.
      AND CASE
              WHEN LOWER(CAST(m.is_transferred_pack AS varchar)) = 'true'
                OR LOWER(CAST(m.is_upgrade_pack AS varchar)) = 'true'
              THEN DATE(mdb.created_date)
              ELSE m.membership_created_date
          END BETWEEN date('2023-04-01') AND date('2026-03-31') -- Apply the reporting window..
),

monthly_cultstore_shopify AS (
    SELECT DISTINCT
        o.user_id,
        o.month
    FROM pk_d2c_cultstore.order_placed shop
    JOIN monthly_hometab_openers o
        ON CAST(COALESCE(shop.user_userid, shop.event_eventparams_userid) AS varchar) = o.user_id -- Use whichever user id is populated in the Shopify app-origin event.
       AND DATE_TRUNC('month', shop.ts_date) = o.month -- Same-month attribution using ts_date as the order event date.
    WHERE event_eventparams_weborigin = 'CUREFIT_APP' -- Keep only Cultstore orders originating from the app.
      AND ts_date BETWEEN date('2023-04-01') AND date('2026-03-31') -- User-selected reporting window.
      AND ts_date >= DATE('2023-01-01') -- Partition guard on the Shopify event table.
      AND COALESCE(user_userid, event_eventparams_userid) IS NOT NULL -- Drop events that cannot be mapped back to a user.
),

monthly_cultstore_custom AS (
    SELECT DISTINCT
        o.user_id,
        o.month
    FROM dwh_cultsports.item_view iv
    JOIN monthly_hometab_openers o
        ON CAST(iv.userid AS varchar) = o.user_id -- Match the custom Cultstore user id to the opener cohort.
       AND DATE_TRUNC('month', iv.order_created_at_date) = o.month -- Same-month attribution using order_created_at_date.
    WHERE source = 'CUREFIT_APP' -- Keep only orders attributed to the app source.
      AND order_created_at_date BETWEEN date('2023-04-01') AND date('2026-03-31') -- User-selected reporting window.
      AND order_created_at_date >= DATE('2023-01-01') -- Partition guard on the custom order table.
      AND userid IS NOT NULL -- Drop rows with no usable user id.
),

monthly_cultstore_purchasers AS (
    SELECT user_id, month
    FROM monthly_cultstore_shopify
    UNION
    SELECT user_id, month
    FROM monthly_cultstore_custom
),

monthly_any_activity AS (
    SELECT user_id, month
    FROM monthly_class_bookers
    UNION
    SELECT user_id, month
    FROM monthly_pack_purchasers
    UNION
    SELECT user_id, month
    FROM monthly_cultstore_purchasers
)

SELECT
    o.month,
    COUNT(DISTINCT o.user_id) AS monthly_hometab_openers,
    COUNT(DISTINCT cb.user_id) AS users_booked_class,
    COUNT(DISTINCT pp.user_id) AS users_purchased_pack,
    COUNT(DISTINCT cp.user_id) AS users_purchased_cultstore_via_app,
    COUNT(DISTINCT aa.user_id) AS users_any_activity_or_purchase,
    ROUND(100.0 * COUNT(DISTINCT cb.user_id) / NULLIF(COUNT(DISTINCT o.user_id), 0), 2) AS pct_users_booked_class,
    ROUND(100.0 * COUNT(DISTINCT pp.user_id) / NULLIF(COUNT(DISTINCT o.user_id), 0), 2) AS pct_users_purchased_pack,
    ROUND(100.0 * COUNT(DISTINCT cp.user_id) / NULLIF(COUNT(DISTINCT o.user_id), 0), 2) AS pct_users_purchased_cultstore_via_app,
    ROUND(100.0 * COUNT(DISTINCT aa.user_id) / NULLIF(COUNT(DISTINCT o.user_id), 0), 2) AS pct_users_any_activity_or_purchase
FROM monthly_hometab_openers o
LEFT JOIN monthly_class_bookers cb
    ON o.user_id = cb.user_id
   AND o.month = cb.month 		-- Check whether the opener also booked a class in that same month.
LEFT JOIN monthly_pack_purchasers pp
    ON o.user_id = pp.user_id
   AND o.month = pp.month 		-- Check whether the opener also purchased a paid pack in that same month.
LEFT JOIN monthly_cultstore_purchasers cp
    ON o.user_id = cp.user_id
   AND o.month = cp.month 		-- Check whether the opener also purchased from Cultstore via app in that same month.
LEFT JOIN monthly_any_activity aa
    ON o.user_id = aa.user_id
   AND o.month = aa.month 		-- Combined same-month flag for any of the three activities.
GROUP BY 1
ORDER BY 1
