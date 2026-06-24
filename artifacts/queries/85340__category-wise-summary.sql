SELECT
  year,
  business_category,
  base_amount,
  (base_amount * 100)/SUM(base_amount) OVER(PARTITION BY YEAR) AS percentage
FROM (
  SELECT
    1 AS sort_key,
    'FY23' AS year,
    CASE 
      WHEN business_category = 'Apparel' THEN 'Apparel'
      WHEN business_category IN ('CS Footwear', 'Avant Footwear') THEN 'Footwear'
      ELSE 'Equipment and Accessories'
    END AS business_category,
    ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
    SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units
  FROM dwh_d2c_metrics.bizfin_sales_data
  WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2022-04-01' AND DATE '2023-03-31'
  GROUP BY 3

  UNION ALL

  SELECT
    2 AS sort_key,
    'FY24' AS year,
    CASE 
      WHEN business_category = 'Apparel' THEN 'Apparel'
      WHEN business_category IN ('CS Footwear', 'Avant Footwear') THEN 'Footwear'
      ELSE 'Equipment and Accessories'
    END AS business_category,
    ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
    SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units
  FROM dwh_d2c_metrics.bizfin_sales_data
  WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'
  GROUP BY 3

  UNION ALL

  SELECT
    3 AS sort_key,
    'FY25' AS year,
    CASE 
      WHEN business_category = 'Apparel' THEN 'Apparel'
      WHEN business_category IN ('CS Footwear', 'Avant Footwear') THEN 'Footwear'
      ELSE 'Equipment and Accessories'
    END AS business_category,
    ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
    SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units
  FROM dwh_d2c_metrics.bizfin_sales_data
  WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'
  GROUP BY 3

  UNION ALL

  SELECT
    4 AS sort_key,
    'FY26' AS year,
    CASE 
      WHEN business_category = 'Apparel' THEN 'Apparel'
      WHEN business_category IN ('CS Footwear', 'Avant Footwear') THEN 'Footwear'
      ELSE 'Equipment and Accessories'
    END AS business_category,
    ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
    SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units
  FROM dwh_d2c_metrics.bizfin_sales_data
  WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'
  GROUP BY 3
) t
ORDER BY sort_key, business_category
