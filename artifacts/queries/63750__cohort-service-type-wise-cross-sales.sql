SELECT cohort, majority_service, SUM(gmv) AS total_gmv
FROM dwh_fitness_metrics.cross_sell_orders
WHERE TRUE
      AND is_fs_member = 1
      AND is_cancelled = 0
      AND order_date >= DATE('2018-01-01')
     [[AND {{cohort}}]]
     [[AND {{service_type}}]]
     [[AND order_date BETWEEN {{start_order_date}} AND {{end_order_date}}]]
GROUP BY 1,2
ORDER BY 1, 3 DESC
