SELECT
  year,
  channel_type,
  base_amount * 1.000/ SUM(base_amount) OVER(PARTITION BY year) AS percentage
FROM (
  SELECT
    1 AS sort_key,
    'FY23' AS year,
    CASE 
      WHEN manual_channel_type = '1P' THEN '1P'
      WHEN manual_channel_type = 'EBO' THEN 'EBO'
	  WHEN manual_channel_type = '3P' THEN 'Ecommerce'
      ELSE 'Other Offline/Online Channel'
    END AS channel_type,
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
      WHEN manual_channel_type = '1P' THEN '1P'
      WHEN manual_channel_type = 'EBO' THEN 'EBO'
	  WHEN manual_channel_type = '3P' THEN 'Ecommerce'
      ELSE 'Other Offline/Online Channel'
    END AS channel_type,
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
      WHEN manual_channel_type = '1P' THEN '1P'
      WHEN manual_channel_type = 'EBO' THEN 'EBO'
	  WHEN manual_channel_type = '3P' THEN 'Ecommerce'
      ELSE 'Other Offline/Online Channel'
    END AS channel_type,
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
      WHEN manual_channel_type = '1P' THEN '1P'
      WHEN manual_channel_type = 'EBO' THEN 'EBO'
	  WHEN manual_channel_type = '3P' THEN 'Ecommerce'
      ELSE 'Other Offline/Online Channel'
    END AS channel_type,
    ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
    SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units
  FROM dwh_d2c_metrics.bizfin_sales_data
  WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'
  GROUP BY 3
) t
ORDER BY sort_key, channel_type
