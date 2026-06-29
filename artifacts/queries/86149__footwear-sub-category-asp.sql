SELECT
    year,
	business_category,
	ROUND(base_amount * 1.000/total_units) AS asp
FROM 
(
    SELECT
        business_category,
        'FY26' AS year,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units
    FROM dwh_d2c_metrics.bizfin_sales_data
    WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'
         AND business_category IN ('Avant Footwear','CS Footwear')
		AND manual_channel_type IN ('1P','3P','EBO')
    GROUP BY 1
) t
WHERE 1 = 1
ORDER BY business_category
