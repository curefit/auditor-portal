WITH base AS (
    SELECT
        1 AS sort_key,
        'FY23' AS year,
        CAST(REPLACE(base_amount, ',', '') AS DOUBLE) AS base_amount_value,
        business_category
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2022-04-01' AND DATE '2023-03-31'

    UNION ALL

    SELECT
        2 AS sort_key,
        'FY24' AS year,
        CAST(REPLACE(base_amount, ',', '') AS DOUBLE) AS base_amount_value,
        business_category
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'

    UNION ALL

    SELECT
        3 AS sort_key,
        'FY25' AS year,
        CAST(REPLACE(base_amount, ',', '') AS DOUBLE) AS base_amount_value,
        business_category
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'

    UNION ALL

    SELECT
        4 AS sort_key,
        'FY26' AS year,
        CAST(REPLACE(base_amount, ',', '') AS DOUBLE) AS base_amount_value,
        business_category
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'

    UNION ALL

    SELECT
        5 AS sort_key,
        'H1-FY26' AS year,
        CAST(REPLACE(base_amount, ',', '') AS DOUBLE) AS base_amount_value,
        business_category
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2025-04-01' AND DATE '2025-09-30'

    UNION ALL

    SELECT
        6 AS sort_key,
        'H1-FY27' AS year,
        CAST(REPLACE(base_amount, ',', '') AS DOUBLE) AS base_amount_value,
        business_category
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2026-04-01' AND DATE '2026-09-30'
)
SELECT
  year,
  ROUND(
    100 * SUM(CASE WHEN business_category = 'Commercial Equipment' THEN base_amount_value ELSE 0 END)
    / NULLIF(SUM(base_amount_value), 0),
    2
  ) AS percentage
FROM base
GROUP BY sort_key, year
ORDER BY sort_key
