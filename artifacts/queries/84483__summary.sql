SELECT year,
       base_amount,
       ROUND(total_units) AS total_units,
       total_unique_styleid
FROM (
    SELECT
        1 AS sort_key,
        'FY23' AS year,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units,
        COUNT(DISTINCT style_id) AS total_unique_styleid
    FROM  dwh_d2c_metrics.bizfin_sales_data
    WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2022-04-01' AND DATE '2023-03-31'

    UNION ALL

    SELECT
        2 AS sort_key,
        'FY24' AS year,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units,
        COUNT(DISTINCT style_id) AS total_unique_styleid
    FROM  dwh_d2c_metrics.bizfin_sales_data
    WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'

    UNION ALL

    SELECT
        3 AS sort_key,
        'FY25' AS year,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units,
        COUNT(DISTINCT style_id) AS total_unique_styleid
    FROM  dwh_d2c_metrics.bizfin_sales_data
    WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'

    UNION ALL

    SELECT
        4 AS sort_key,
        'FY26' AS year,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units,
        COUNT(DISTINCT style_id) AS total_unique_styleid
    FROM  dwh_d2c_metrics.bizfin_sales_data
    WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'
) t
ORDER BY sort_key
