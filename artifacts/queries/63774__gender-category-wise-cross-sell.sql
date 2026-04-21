SELECT  gender,
        category,
        COUNT(DISTINCT user_id) AS user_count,
        SUM(gmv) AS total_gmv
FROM dwh_fitness_metrics.cross_sell_orders
WHERE is_fs_member = 1
      AND is_cancelled = 0
      [[ AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
      [[ AND {{category}}]]
      AND order_date > DATE('2018-01-01')
GROUP BY 1,2
ORDER BY 3 DESC
