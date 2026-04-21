SELECT state_name, ROUND(SUM(gmv)) AS total_gmv
FROM dwh_fitness_metrics.cross_sell_orders
WHERE TRUE
      AND is_fs_member = 1
      AND is_cancelled = 0
     [[AND order_date BETWEEN {{start_order_date}} AND {{end_order_date}}]]
GROUP BY state_name
ORDER BY 2 DESC
