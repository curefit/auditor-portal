SELECT year,
       -- total_amount,
       base_amount,
       -- total_nlc,
       ROUND(total_units) AS total_units,
       -- gm,
       -- gm_percent,
       -- total_unique_sku_code,
       total_unique_styleid
       -- total_unique_pincode
FROM (
    SELECT
        1 AS sort_key,
        'FY23' AS year,
        ROUND(SUM(CAST(REPLACE(total_amount, ',', '') AS DOUBLE))) AS total_amount,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        ROUND(SUM(nlc)) AS total_nlc,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc)) AS gm,
        (ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc))) * 1.000/ ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS gm_percent,
        COUNT(DISTINCT item_code) AS total_unique_sku_code,
        COUNT(DISTINCT style_id) AS total_unique_styleid,
        COUNT(DISTINCT bill_to_pincode) AS total_unique_pincode
    FROM  dwh_d2c_metrics.bizfin_sales_data
    WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2022-04-01' AND DATE '2023-03-31'

    UNION ALL

    SELECT
        2 AS sort_key,
        'FY24' AS year,
        ROUND(SUM(CAST(REPLACE(total_amount, ',', '') AS DOUBLE))) AS total_amount,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        ROUND(SUM(nlc)) AS total_nlc,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc)) AS gm,
        (ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc))) * 1.000/ ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS gm_percent,
        COUNT(DISTINCT item_code) AS total_unique_sku_code,
        COUNT(DISTINCT style_id) AS total_unique_styleid,
        COUNT(DISTINCT bill_to_pincode) AS total_unique_pincode
    FROM  dwh_d2c_metrics.bizfin_sales_data
    WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'

    UNION ALL

    SELECT
        3 AS sort_key,
        'FY25' AS year,
        ROUND(SUM(CAST(REPLACE(total_amount, ',', '') AS DOUBLE))) AS total_amount,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        ROUND(SUM(nlc)) AS total_nlc,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc)) AS gm,
        (ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc))) * 1.000/ ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS gm_percent,
        COUNT(DISTINCT item_code) AS total_unique_sku_code,
        COUNT(DISTINCT style_id) AS total_unique_styleid,
        COUNT(DISTINCT bill_to_pincode) AS total_unique_pincode
    FROM  dwh_d2c_metrics.bizfin_sales_data
    WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'

    UNION ALL

    SELECT
        5 AS sort_key,
        'FY26' AS year,
        ROUND(SUM(CAST(REPLACE(total_amount, ',', '') AS DOUBLE))) AS total_amount,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        ROUND(SUM(nlc)) AS total_nlc,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc)) AS gm,
        (ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc))) * 1.000/ ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS gm_percent,
        COUNT(DISTINCT item_code) AS total_unique_sku_code,
        COUNT(DISTINCT style_id) AS total_unique_styleid,
        COUNT(DISTINCT bill_to_pincode) AS total_unique_pincode
    FROM  dwh_d2c_metrics.bizfin_sales_data
    WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'
) t
ORDER BY sort_key
