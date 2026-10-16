SELECT
    year,
    CASE 
		WHEN business_category = 'Avant Footwear' THEN business_category
		ELSE  'CS Footwear'
	END AS business_category,
    ROUND(base_amount * 1.000 / total_units) AS asp
FROM (
    SELECT
        1 AS sort_key,
        'FY23' AS year,
        business_category,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2022-04-01' AND DATE '2023-03-31'
        AND business_category IN ('Avant Footwear', 'CS Footwear', 'CultSport Footwear')
        AND manual_channel_type IN ('1P','3P','EBO')
    GROUP BY 3

    UNION ALL

    SELECT
        2 AS sort_key,
        'FY24' AS year,
        business_category,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'
        AND business_category IN ('Avant Footwear', 'CS Footwear', 'CultSport Footwear')
        AND manual_channel_type IN ('1P','3P','EBO')
    GROUP BY 3

    UNION ALL

    SELECT
        3 AS sort_key,
        'FY25' AS year,
        business_category,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'
        AND business_category IN ('Avant Footwear', 'CS Footwear', 'CultSport Footwear')
        AND manual_channel_type IN ('1P','3P','EBO')
    GROUP BY 3

    UNION ALL

    SELECT
        4 AS sort_key,
        'FY26' AS year,
        business_category,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'
        AND business_category IN ('Avant Footwear', 'CS Footwear', 'CultSport Footwear')
        AND manual_channel_type IN ('1P','3P','EBO')
    GROUP BY 3

    UNION ALL

    SELECT
        5 AS sort_key,
        'H1-FY26' AS year,
        business_category,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2025-04-01' AND DATE '2025-09-30'
        AND business_category IN ('Avant Footwear', 'CS Footwear', 'CultSport Footwear')
        AND manual_channel_type IN ('1P','3P','EBO')
    GROUP BY 3

    UNION ALL

    SELECT
        6 AS sort_key,
        'H1-FY27' AS year,
        business_category,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2026-04-01' AND DATE '2026-09-30'
        AND business_category IN ('Avant Footwear', 'CS Footwear', 'CultSport Footwear')
        AND manual_channel_type IN ('1P','3P','EBO')
    GROUP BY 3
) t
ORDER BY sort_key, business_category
