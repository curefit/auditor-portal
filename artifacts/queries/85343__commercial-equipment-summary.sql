WITH base AS (
  SELECT
    CASE
      WHEN DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2022-04-01' AND DATE '2023-03-31' THEN 'FY23'
      WHEN DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2023-04-01' AND DATE '2024-03-31' THEN 'FY24'
      WHEN DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2024-04-01' AND DATE '2025-03-31' THEN 'FY25'
      WHEN DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2025-04-01' AND DATE '2026-03-31' THEN 'FY26'
    END AS year,
    CAST(REPLACE(base_amount, ',', '') AS DOUBLE) AS base_amount_value,
    business_category
  FROM dwh_d2c_metrics.bizfin_sales_data
  WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2022-04-01' AND DATE '2026-03-31'
)

SELECT
  year,
  ROUND(SUM(CASE WHEN business_category = 'Commercial Equipment' THEN base_amount_value ELSE 0 END)) AS base_amount,
  ROUND(
    100 * SUM(CASE WHEN business_category = 'Commercial Equipment' THEN base_amount_value ELSE 0 END)
    / NULLIF(SUM(base_amount_value), 0),
    2
  ) AS percentage
FROM base
GROUP BY year
ORDER BY year
