WITH revenue_summary AS (
    SELECT year, base_amount, sort_key
    FROM (
        SELECT
            1 AS sort_key,
            'FY23' AS year,
            ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount
        FROM dwh_d2c_metrics.bizfin_sales_data
        WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2022-04-01' AND DATE '2023-03-31'
		AND manual_channel_type IN ('1P','3P','EBO','B2B MP')

        UNION ALL

        SELECT
            2 AS sort_key,
            'FY24' AS year,
            ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount
        FROM dwh_d2c_metrics.bizfin_sales_data
        WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'
		AND manual_channel_type IN ('1P','3P','EBO','B2B MP')

        UNION ALL

        SELECT
            3 AS sort_key,
            'FY25' AS year,
            ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount
        FROM dwh_d2c_metrics.bizfin_sales_data
        WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'
		AND manual_channel_type IN ('1P','3P','EBO','B2B MP')

        UNION ALL

        SELECT
            4 AS sort_key,
            'FY26' AS year,
            ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount
        FROM dwh_d2c_metrics.bizfin_sales_data
        WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'
		AND manual_channel_type IN ('1P','3P','EBO','B2B MP')
    ) t
),
fy_year_1p_metrics AS (
    SELECT
        fy_year,
        ROUND(SUM(total_price) / NULLIF(COUNT(DISTINCT order_id), 0)) AS aov,
        ROUND(COUNT(DISTINCT billing_address_phone) * 1.0 / NULLIF(COUNT(DISTINCT order_id), 0),4) AS customer_to_order_ratio
    FROM (
        SELECT
            CASE
                WHEN DATE(filter_date) BETWEEN DATE('2024-04-01') AND DATE('2025-03-31') THEN 'FY25'
                WHEN DATE(filter_date) BETWEEN DATE('2025-04-01') AND DATE('2026-03-31') THEN 'FY26'
            END AS fy_year,
            total_price,
            order_id,
            billing_address_phone
        FROM dwh_d2c_metrics.d2c_bizfin_revenue
        WHERE filter_date IS NOT NULL
          AND DATE(filter_date) BETWEEN DATE('2024-04-01') AND DATE('2026-03-31')
          AND LOWER(shipment_type) NOT IN ('exchange', 'amazon_exchange')
          AND LOWER(channel_to_be_considered_for_bizfin) = 'yes'
          AND (coupon_detail IS NULL OR LOWER(coupon_detail) NOT IN ('freebie', 'influencer', 'b2b'))
          AND channel_type = '1P'
    ) source
    WHERE fy_year IS NOT NULL
    GROUP BY 1
),
revenue_metric_year_mapping AS (
    SELECT
        r.year,
        r.base_amount,
        r.sort_key,
        CASE
            WHEN r.year IN ('FY23', 'FY24', 'FY25') THEN 'FY25'
            WHEN r.year = 'FY26' THEN 'FY26'
        END AS metric_year
    FROM revenue_summary r
)
SELECT
    r.year,
    r.base_amount,
    m.aov,
	m.customer_to_order_ratio,
    ROUND((r.base_amount / NULLIF(m.aov, 0)) * m.customer_to_order_ratio) AS customers
FROM revenue_metric_year_mapping r
JOIN fy_year_1p_metrics m
  ON r.metric_year = m.fy_year
ORDER BY r.sort_key
