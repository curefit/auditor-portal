-- Purpose: Compact monthly output for the % 12M/12M+ packs sold metric.
-- Source: Optimized from Metabase card 76611 while preserving the original pack-count grain.
-- Output: month_start, fiscal_year, total_packs_sold, packs_12m_plus, pct_12m_plus.
WITH original_pack_grain AS (
    SELECT
        purchase_date,
        CASE
            WHEN LOWER(pack_name) LIKE '%12m%'
              OR LOWER(pack_name) LIKE '%12%m%' THEN '2. 12 Months'
            WHEN LOWER(pack_name) LIKE '%1m%'
              OR LOWER(pack_name) LIKE '%1%m%'
              OR LOWER(pack_name) LIKE '%monthly%' THEN '5. 1 Month'
            WHEN LOWER(pack_name) LIKE '%3m%'
              OR LOWER(pack_name) LIKE '%3%m%' THEN '4. 3 Months'
            WHEN LOWER(pack_name) LIKE '%6m%'
              OR LOWER(pack_name) LIKE '%6%m%'
              OR LOWER(pack_name) = '4. 3 Months' THEN '3. 6 Months'
            ELSE '6. >12 Months'
        END AS pack_duration,
        COUNT(DISTINCT CASE WHEN amount_paid > 0 THEN order_id END) AS packs
    FROM (
        SELECT
            DATE_DIFF(
                'day',
                CASE
                    WHEN LOWER(CAST(membership_dim.is_transferred_pack AS VARCHAR)) = 'true'
                      OR LOWER(CAST(membership_dim.is_upgrade_pack AS VARCHAR)) = 'true'
                        THEN membership_mdb."start"
                    ELSE membership_dim.pack_start_date
                END,
                COALESCE(
                    original_pack_end_date,
                    CASE
                        WHEN LOWER(CAST(membership_dim.is_transferred_pack AS VARCHAR)) = 'true'
                          OR LOWER(CAST(membership_dim.is_upgrade_pack AS VARCHAR)) = 'true'
                            THEN membership_mdb."end"
                        ELSE membership_dim.pack_end_date
                    END
                )
            ) AS day_difference,
            DATE(
                CASE
                    WHEN LOWER(CAST(membership_dim.is_transferred_pack AS VARCHAR)) = 'true'
                      OR LOWER(CAST(membership_dim.is_upgrade_pack AS VARCHAR)) = 'true'
                        THEN membership_mdb.created_date
                    ELSE membership_dim.membership_created_date
                END
            ) AS purchase_date,
            membership_dim.business_line,
            membership_dim.amount_paid,
            membership_dim.order_key AS order_id,
            membership_dim.pack_name,
            CASE
                WHEN membership.previous_sku IS NULL
                 AND (membership.membership_rank = 1 OR membership.membership_rank IS NULL) THEN 'New'
                WHEN membership.membership_key IS NOT NULL
                 AND membership.membership_rank > 1 THEN 'Repeat'
                WHEN membership.previous_sku IS NOT NULL THEN 'Repeat'
                ELSE 'Check'
            END AS membership_type,
            COALESCE(orders_fact.city_name, attributed_center.city_name, purchase_center.city_name) AS order_cityname,
            membership_dim.is_select,
            CASE
                WHEN DATE(
                    CASE
                        WHEN LOWER(CAST(membership_dim.is_transferred_pack AS VARCHAR)) = 'true'
                          OR LOWER(CAST(membership_dim.is_upgrade_pack AS VARCHAR)) = 'true'
                            THEN membership_mdb.created_date
                        ELSE membership_dim.membership_created_date
                    END
                ) < DATE(purchase_center.center_launch_date) THEN 1
                ELSE 0
            END AS pre_sales_flag
        FROM dwh_fitness_mart.membership_dim
        LEFT JOIN pk_curefitplatforms_membershipdb.memberships membership_mdb
            ON membership_mdb.id = membership_dim.membership_service_id
        LEFT JOIN dwh_fitness_mart.orders_fact
            ON dwh_fitness_mart.orders_fact.order_key = dwh_fitness_mart.membership_dim.order_key
           AND DATE(orders_fact.purchase_date) >= DATE(current_date) - INTERVAL '3' YEAR
        LEFT JOIN dwh_fitness_mart.center_dim purchase_center
            ON purchase_center.center_key = membership_dim.purchase_center_key
        LEFT JOIN (
            SELECT
                membership_key,
                ROW_NUMBER() OVER (
                    PARTITION BY membership_dim.user_id
                    ORDER BY CASE
                        WHEN LOWER(CAST(membership_dim.is_transferred_pack AS VARCHAR)) = 'true'
                          OR LOWER(CAST(membership_dim.is_upgrade_pack AS VARCHAR)) = 'true'
                            THEN repeat_mdb.created_date
                        ELSE membership_dim.membership_created_date
                    END
                ) AS membership_rank,
                LAG(membership_dim.business_line) OVER (
                    PARTITION BY membership_dim.user_id
                    ORDER BY CASE
                        WHEN LOWER(CAST(membership_dim.is_transferred_pack AS VARCHAR)) = 'true'
                          OR LOWER(CAST(membership_dim.is_upgrade_pack AS VARCHAR)) = 'true'
                            THEN repeat_mdb.created_date
                        ELSE membership_dim.membership_created_date
                    END
                ) AS previous_sku
            FROM dwh_fitness_mart.membership_dim
            LEFT JOIN pk_curefitplatforms_membershipdb.memberships repeat_mdb
                ON repeat_mdb.id = membership_dim.membership_service_id
            WHERE LOWER(COALESCE(membership_dim.status, 'xx')) NOT LIKE '%canc%'
              AND (
                    membership_dim.amount_paid > 0
                 OR COALESCE(membership_dim.membership_type, 'xx') IN ('MEMBER_MIGRATION', 'ENTERPRISE', 'MIGRATION')
                 OR COALESCE(membership_dim.pack_name, 'xx') IN ('Transferred Pack')
                 OR COALESCE(membership_dim.status, 'xx') IN ('MEMBERSHIP_TRANSFERRED')
                 OR COALESCE(membership_dim.source, 'xx') IN ('MIGRATION')
              )
        ) membership
            ON membership.membership_key = membership_dim.membership_key
        LEFT JOIN dwh_fitness_mart.center_dim attributed_center
            ON membership_dim.final_center_key = attributed_center.center_key
        WHERE membership_dim.business_line IN ('ELITE', 'PRO')
          AND DATE(
                CASE
                    WHEN LOWER(CAST(membership_dim.is_transferred_pack AS VARCHAR)) = 'true'
                      OR LOWER(CAST(membership_dim.is_upgrade_pack AS VARCHAR)) = 'true'
                        THEN membership_mdb.created_date
                    ELSE membership_dim.membership_created_date
                END
            ) BETWEEN {{Start_Date}} AND {{End_Date}}
          AND membership_dim.amount_paid IS NOT NULL
          AND membership_dim.amount_paid > 0
    )
    WHERE day_difference > 0
      AND LOWER(pack_name) NOT LIKE '%upgraded%'
      AND LOWER(pack_name) NOT LIKE '%transfer%'
    GROUP BY
        purchase_date,
        business_line,
        CASE
            WHEN is_select = 0 THEN 'Pass'
            WHEN is_select = 1 THEN 'Select'
        END,
        CASE
            WHEN membership_type = 'Repeat' THEN 'Repeat'
            WHEN membership_type = 'New' THEN 'New'
            ELSE 'Error'
        END,
        CASE
            WHEN order_cityname IN ('Bangalore', 'Hyderabad', 'Gurgaon', 'Pune') THEN order_cityname
            WHEN order_cityname IN ('Navi_Mum_And_Thane', 'Mumbai') THEN 'Mumbai'
            WHEN order_cityname IS NULL THEN 'Empty City'
            ELSE 'Others'
        END,
        CASE
            WHEN LOWER(pack_name) LIKE '%12m%'
              OR LOWER(pack_name) LIKE '%12%m%' THEN '2. 12 Months'
            WHEN LOWER(pack_name) LIKE '%1m%'
              OR LOWER(pack_name) LIKE '%1%m%'
              OR LOWER(pack_name) LIKE '%monthly%' THEN '5. 1 Month'
            WHEN LOWER(pack_name) LIKE '%3m%'
              OR LOWER(pack_name) LIKE '%3%m%' THEN '4. 3 Months'
            WHEN LOWER(pack_name) LIKE '%6m%'
              OR LOWER(pack_name) LIKE '%6%m%'
              OR LOWER(pack_name) = '4. 3 Months' THEN '3. 6 Months'
            ELSE '6. >12 Months'
        END,
        pre_sales_flag
),
period_rollup AS (
    SELECT
        DATE_TRUNC('month', purchase_date) AS month_start,
        CASE
            WHEN MONTH(purchase_date) >= 4
                THEN CONCAT('FY', SUBSTR(CAST(YEAR(purchase_date) + 1 AS VARCHAR), 3, 2))
            ELSE CONCAT('FY', SUBSTR(CAST(YEAR(purchase_date) AS VARCHAR), 3, 2))
        END AS fiscal_year,
        SUM(packs) AS total_packs_sold,
        SUM(CASE WHEN pack_duration IN ('2. 12 Months', '6. >12 Months') THEN packs ELSE 0 END) AS packs_12m_plus
    FROM original_pack_grain
    GROUP BY 1, 2
)
SELECT
    month_start,
    fiscal_year,
    total_packs_sold,
    packs_12m_plus,
    ROUND(100.0 * packs_12m_plus / NULLIF(total_packs_sold, 0), 2) AS pct_12m_plus
FROM period_rollup
ORDER BY month_start
