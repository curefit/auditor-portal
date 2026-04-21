SELECT 'CROSS-SELL' AS cross_sell_vs_1p, ROUND(SUM(gmv)) AS total_gmv
FROM 
dwh_fitness_metrics.cross_sell_orders
WHERE TRUE
     AND is_fs_member= 1
     AND order_date >= DATE('2018-01-01')
     AND is_cancelled = 0 
     [[AND {{source}}]]
     [[AND {{category}}]]
     [[AND {{cohort}}]]
     [[AND {{service_type}}]]
     [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]

UNION ALL 

SELECT 'NON-FS-MEMBER' AS cross_sell_vs_1p, ROUND(SUM(gmv)) AS total_gmv
FROM 
dwh_fitness_metrics.cross_sell_orders
WHERE TRUE
     AND is_fs_member= 0
     AND is_cancelled = 0
     AND order_date >= DATE('2018-01-01')
     [[AND {{source}}]]
     [[AND {{category}}]]
     [[AND {{cohort}}]]
     [[AND {{service_type}}]]
     [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
