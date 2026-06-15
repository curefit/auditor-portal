WITH revenue_summary AS (
    SELECT year, base_amount, sort_key
    FROM (
        SELECT
            1 AS sort_key,
            'FY23' AS year,
            ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount
        FROM dwh_d2c_metrics.bizfin_sales_data
        WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2022-04-01' AND DATE '2023-03-31'

        UNION ALL

        SELECT
            2 AS sort_key,
            'FY24' AS year,
            ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount
        FROM dwh_d2c_metrics.bizfin_sales_data
        WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'

        UNION ALL

        SELECT
            3 AS sort_key,
            'FY25' AS year,
            ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount
        FROM dwh_d2c_metrics.bizfin_sales_data
        WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'

        UNION ALL

        SELECT
            4 AS sort_key,
            'FY26' AS year,
            ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount
        FROM dwh_d2c_metrics.bizfin_sales_data
        WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'
    ) t
),
fy26_aov AS (
    SELECT
        ROUND(SUM(total_price) / NULLIF(COUNT(DISTINCT order_id), 0)) AS aov
    FROM dwh_d2c_metrics.d2c_bizfin_revenue
    WHERE filter_date IS NOT NULL
      AND DATE(filter_date) BETWEEN DATE('2025-04-01') AND DATE('2026-03-31')
      AND LOWER(shipment_type) NOT IN ('exchange', 'amazon_exchange')
      AND LOWER(channel_to_be_considered_for_bizfin) = 'yes'
      AND (coupon_detail IS NULL OR LOWER(coupon_detail) NOT IN ('freebie', 'influencer', 'b2b'))
      AND channel_type IN ('3P', '1P', 'FBA', 'FBF')
)
SELECT
    r.year,
    r.base_amount,
    a.aov,
    ROUND(r.base_amount / NULLIF(a.aov, 0)) AS customers
FROM revenue_summary r
CROSS JOIN fy26_aov a
ORDER BY r.sort_key
