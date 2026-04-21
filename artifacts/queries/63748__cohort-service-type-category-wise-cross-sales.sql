SELECT cohort, majority_service, category, ROUND(SUM(gmv)) AS total_gmv
FROM dwh_fitness_metrics.cross_sell_orders
WHERE TRUE
      AND is_fs_member = 1
      AND is_cancelled = 0
      AND order_date >= DATE('2018-01-01')
     [[AND {{service_type}}]]
     [[AND {{cohort}}]]
     [[AND {{category}}]]
     [[AND order_date BETWEEN {{start_order_date}} AND {{end_order_date}}]]
GROUP BY 1,2,3
ORDER BY 1, 2, 4 DESC
