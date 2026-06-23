SELECT
	business_category,
	MIN(DATE(DATE_PARSE(invoice_date, '%d-%m-%Y'))) AS launch_date
FROM  dwh_d2c_metrics.bizfin_sales_data
GROUP BY 1
ORDER BY 2
