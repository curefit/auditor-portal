WITH source_by_state AS (
  SELECT
    1 AS sort_key,
    'FY23' AS year,
    bill_from_state,
    ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount
  FROM dwh_d2c_metrics.bizfin_sales_data
  WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2022-04-01' AND DATE '2023-03-31'
  GROUP BY 3

  UNION ALL

  SELECT
    2 AS sort_key,
    'FY24' AS year,
    bill_from_state,
    ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount
  FROM dwh_d2c_metrics.bizfin_sales_data
  WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'
  GROUP BY 3

  UNION ALL

  SELECT
    3 AS sort_key,
    'FY25' AS year,
    bill_from_state,
    ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount
  FROM dwh_d2c_metrics.bizfin_sales_data
  WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'
  GROUP BY 3

  UNION ALL

  SELECT
    4 AS sort_key,
    'FY26' AS year,
    bill_from_state,
    ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount
  FROM dwh_d2c_metrics.bizfin_sales_data
  WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'
  GROUP BY 3

    UNION ALL

    SELECT
    5 AS sort_key,
    'H1-FY26' AS year,
    bill_from_state,
    ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount
  FROM dwh_d2c_metrics.bizfin_sales_data
  WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2025-04-01' AND DATE '2025-09-30'
  GROUP BY 3

    UNION ALL

    SELECT
    6 AS sort_key,
    'H1-FY27' AS year,
    bill_from_state,
    ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount
  FROM dwh_d2c_metrics.bizfin_sales_data
  WHERE TO_DATE(invoice_date, 'dd-MM-yyyy') BETWEEN DATE '2026-04-01' AND DATE '2026-09-30'
  GROUP BY 3
),
classified AS (
  SELECT
    sort_key,
    year,
    bill_from_state,
    base_amount,
    CASE
      WHEN bill_from_state IN ('Andhra Pradesh', 'Karnataka', 'Tamil Nadu', 'Tamilnadu', 'Telangana', 'Pondicherry', 'Hyderabad') THEN 'South'
      WHEN bill_from_state IN ('Delhi', 'Haryana', 'Punjab', 'Uttar Pradesh', 'Rajasthan', 'Jammu and Kashmir', 'Uttarakhand', 'Chandigarh', 'Himachal Pradesh', 'Jammu') THEN 'North'
      WHEN bill_from_state IN ('Madhya Pradesh', 'Maharashtra', 'Gujarat', 'Goa', 'Daman and Diu') THEN 'West'
      WHEN bill_from_state IN ('Bihar', 'West Bengal', 'Odisha', 'Assam', 'Jharkhand', 'Chhattisgarh', 'Mizoram', 'Meghalaya', 'Arunachal Pradesh', 'Manipur', 'Tripura', 'Nagaland', 'Sikkim', 'Andaman and Nicobar') THEN 'East'
      WHEN bill_from_state IS NULL THEN NULL
      ELSE 'Unmapped state'
    END AS region
  FROM source_by_state
),
mapped AS (
   SELECT
    year,
    region,
    SUM(base_amount) AS mapped_amount
  FROM classified
  WHERE region IS NOT NULL
  GROUP BY year, region
),
null_pool AS (
  SELECT
    year,
    COALESCE(SUM(base_amount), 0) AS null_amount
  FROM classified
  WHERE bill_from_state IS NULL
  GROUP BY 1
),
fy_totals AS (
  SELECT
    year,
    SUM(base_amount) AS total_amount
  FROM classified
  GROUP BY 1
),
region_output AS (
  SELECT
    m.year,
    m.region,
    m.mapped_amount + COALESCE(n.null_amount * m.mapped_amount / NULLIF(SUM(m.mapped_amount) OVER (PARTITION BY m.year), 0), 0) AS base_amount,
    t.total_amount
  FROM mapped m
  LEFT JOIN null_pool n ON n.year = m.year
  JOIN fy_totals t ON t.year = m.year
)

SELECT
  year,
  region,
  (base_amount * 1.000) / NULLIF(total_amount, 0) AS percentage
FROM region_output
ORDER BY year, region
