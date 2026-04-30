SELECT
  CASE
    WHEN bf.class_date >= DATE '2023-04-01' AND bf.class_date < DATE '2024-04-01' THEN 'FY24'
    WHEN bf.class_date >= DATE '2024-04-01' AND bf.class_date < DATE '2025-04-01' THEN 'FY25'
    WHEN bf.class_date >= DATE '2025-04-01' AND bf.class_date < DATE '2026-04-01' THEN 'FY26'
  END AS fiscal_year,
  COUNT(DISTINCT CASE WHEN bf.rating_value IN (1, 2) THEN bf.booking_key END) AS bt_responses,
  COUNT(DISTINCT CASE WHEN bf.rating_value IN (1, 2, 3, 4) THEN bf.booking_key END) AS total_responses,
  100.0 * COUNT(DISTINCT CASE WHEN bf.rating_value IN (1, 2) THEN bf.booking_key END)
    / NULLIF(COUNT(DISTINCT CASE WHEN bf.rating_value IN (1, 2, 3, 4) THEN bf.booking_key END), 0) AS bt_pct
FROM dwh_fitness_mart.booking_fact bf
WHERE bf.class_date >= DATE '2023-04-01'
  AND bf.class_date < DATE '2026-04-01'
GROUP BY 1
ORDER BY 1
