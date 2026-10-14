WITH base_data AS (
    SELECT
        DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) AS invoice_dt,
        TRIM(manual_channel_type) AS manual_channel_type,
        CAST(REPLACE(base_amount, ',', '') AS DOUBLE) AS base_amount
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2022-04-01' AND DATE '2026-03-31'
),

yearly_summary AS (
    SELECT
        CASE
            WHEN invoice_dt BETWEEN DATE '2022-04-01' AND DATE '2023-03-31' THEN 'FY23'
            WHEN invoice_dt BETWEEN DATE '2023-04-01' AND DATE '2024-03-31' THEN 'FY24'
            WHEN invoice_dt BETWEEN DATE '2024-04-01' AND DATE '2025-03-31' THEN 'FY25'
            WHEN invoice_dt BETWEEN DATE '2025-04-01' AND DATE '2026-03-31' THEN 'FY26'
        END AS year,
        ROUND(SUM(base_amount)) AS total_base_amount,
        ROUND(SUM(CASE
            WHEN manual_channel_type IN ('1P', '3P', 'B2B MP', 'Online', 'Others', 'To Check') THEN base_amount
            ELSE 0
        END)) AS online_base_amount,
        ROUND(SUM(CASE
            WHEN manual_channel_type IN ('B2B', 'Commerical', 'EBO', 'Liquidation', 'Offline')
                OR manual_channel_type IS NULL THEN base_amount
            ELSE 0
        END)) AS offline_base_amount,
        ROUND(SUM(CASE
            WHEN invoice_dt BETWEEN DATE '2024-04-01' AND DATE '2026-03-31'
                AND manual_channel_type IN ('1P', 'EBO') THEN base_amount
        END)) AS ownchannel_base_amount
    FROM base_data
    GROUP BY 1
),

metric_rows AS (
    SELECT
        1 AS sort_order,
        'Online Percentage' AS metric,
        year,
        ROUND(online_base_amount / NULLIF(total_base_amount, 0), 4) AS metric_value
    FROM yearly_summary

    UNION ALL

    SELECT
        2 AS sort_order,
        'Offline Percentage' AS metric,
        year,
        ROUND(offline_base_amount / NULLIF(total_base_amount, 0), 4) AS metric_value
    FROM yearly_summary

    UNION ALL

    SELECT
        3 AS sort_order,
        'Own Channel Percentage' AS metric,
        year,
        ROUND(ownchannel_base_amount / NULLIF(total_base_amount, 0), 4) AS metric_value
    FROM yearly_summary
)

SELECT
    metric,
    MAX(CASE WHEN year = 'FY23' THEN metric_value END) AS FY23,
    MAX(CASE WHEN year = 'FY24' THEN metric_value END) AS FY24,
    MAX(CASE WHEN year = 'FY25' THEN metric_value END) AS FY25,
    MAX(CASE WHEN year = 'FY26' THEN metric_value END) AS FY26
FROM metric_rows
GROUP BY
    sort_order,
    metric
ORDER BY sort_order
