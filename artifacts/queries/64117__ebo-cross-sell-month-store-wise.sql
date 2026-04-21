SELECT DATE_TRUNC('MONTH',order_date) AS month, store_name, COUNT(DISTINCT order_id) AS order_count, ROUND(SUM(gmv)) AS total_gmv
FROM 
dwh_fitness_metrics.cross_sell_orders
WHERE channel = 'EBO'
AND is_fs_member = 1
AND is_cancelled = 0
[[AND {{store_name}}]]
[[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
GROUP BY 1,2
ORDER BY 4 DESC
