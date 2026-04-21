SELECT 'Active' AS active_vs_expired, ROUND(SUM(gmv)) AS total_gmv
FROM dwh_fitness_metrics.cross_sell_orders
WHERE TRUE
      AND is_fs_member  = 1
      AND cohort NOT LIKE '%Expired%'
      AND order_date >= DATE('2018-01-01')
      AND is_cancelled = 0
     [[AND {{source}}]]
     [[AND {{category}}]]
     [[AND {{cohort}}]]
     [[AND {{service_type}}]]
     [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]

UNION ALL 

SELECT 'Expired' AS active_vs_expired, ROUND(SUM(gmv)) AS total_gmv
FROM dwh_fitness_metrics.cross_sell_orders
WHERE TRUE
      AND is_fs_member  = 1
      AND cohort LIKE '%Expired%'
      AND order_date >= DATE('2018-01-01')
      AND is_cancelled = 0
     [[AND {{source}}]]
     [[AND {{category}}]]
     [[AND {{cohort}}]]
     [[AND {{service_type}}]]
     [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
