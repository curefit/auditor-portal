WITH yearly_summary AS (
    SELECT
        1 AS sort_key,
        'FY23' AS year,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS total_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('1P', '3P', 'B2B MP', 'Online', 'Others', 'To Check') THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS online_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('B2B', 'Commerical', 'EBO', 'Liquidation', 'Offline')
                OR manual_channel_type IS NULL THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS offline_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('1P', 'EBO') THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS ownchannel_base_amount
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2022-04-01' AND DATE '2023-03-31'

    UNION ALL

    SELECT
        2 AS sort_key,
        'FY24' AS year,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS total_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('1P', '3P', 'B2B MP', 'Online', 'Others', 'To Check') THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS online_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('B2B', 'Commerical', 'EBO', 'Liquidation', 'Offline')
                OR manual_channel_type IS NULL THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS offline_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('1P', 'EBO') THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS ownchannel_base_amount
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'

    UNION ALL

    SELECT
        3 AS sort_key,
        'FY25' AS year,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS total_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('1P', '3P', 'B2B MP', 'Online', 'Others', 'To Check') THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS online_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('B2B', 'Commerical', 'EBO', 'Liquidation', 'Offline')
                OR manual_channel_type IS NULL THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS offline_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('1P', 'EBO') THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS ownchannel_base_amount
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'

    UNION ALL

    SELECT
        4 AS sort_key,
        'FY26' AS year,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS total_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('1P', '3P', 'B2B MP', 'Online', 'Others', 'To Check') THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS online_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('B2B', 'Commerical', 'EBO', 'Liquidation', 'Offline')
                OR manual_channel_type IS NULL THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS offline_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('1P', 'EBO') THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS ownchannel_base_amount
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'

    UNION ALL

    SELECT
        5 AS sort_key,
        'H1-FY26' AS year,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS total_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('1P', '3P', 'B2B MP', 'Online', 'Others', 'To Check') THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS online_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('B2B', 'Commerical', 'EBO', 'Liquidation', 'Offline')
                OR manual_channel_type IS NULL THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS offline_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('1P', 'EBO') THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS ownchannel_base_amount
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2025-04-01' AND DATE '2025-09-30'

    UNION ALL

    SELECT
        6 AS sort_key,
        'H1-FY27' AS year,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS total_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('1P', '3P', 'B2B MP', 'Online', 'Others', 'To Check') THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS online_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('B2B', 'Commerical', 'EBO', 'Liquidation', 'Offline')
                OR manual_channel_type IS NULL THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS offline_base_amount,
        ROUND(SUM(CASE
            WHEN TRIM(manual_channel_type) IN ('1P', 'EBO') THEN CAST(REPLACE(base_amount, ',', '') AS DOUBLE)
            ELSE 0
        END)) AS ownchannel_base_amount
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2026-04-01' AND DATE '2026-09-30'
),
metric_rows AS (
    SELECT 1 AS sort_order, 'Online Percentage' AS metric, year,
           ROUND(online_base_amount / NULLIF(total_base_amount, 0), 4) AS metric_value
    FROM yearly_summary
    UNION ALL
    SELECT 2 AS sort_order, 'Offline Percentage' AS metric, year,
           ROUND(offline_base_amount / NULLIF(total_base_amount, 0), 4) AS metric_value
    FROM yearly_summary
    UNION ALL
    SELECT 3 AS sort_order, 'Own Channel Percentage' AS metric, year,
           ROUND(ownchannel_base_amount / NULLIF(total_base_amount, 0), 4) AS metric_value
    FROM yearly_summary
)
SELECT
    metric,
    MAX(CASE WHEN year = 'FY23' THEN metric_value END) AS FY23,
    MAX(CASE WHEN year = 'FY24' THEN metric_value END) AS FY24,
    MAX(CASE WHEN year = 'FY25' THEN metric_value END) AS FY25,
    MAX(CASE WHEN year = 'FY26' THEN metric_value END) AS FY26,
    MAX(CASE WHEN year = 'H1-FY26' THEN metric_value END) AS `H1-FY26`,
    MAX(CASE WHEN year = 'H1-FY27' THEN metric_value END) AS `H1-FY27`
FROM metric_rows
GROUP BY sort_order, metric
ORDER BY sort_order
