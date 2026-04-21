SELECT 'CROSS-SELL', ROUND(SUM(gmv)) AS total_gmv
FROM 
dwh_fitness_metrics.cross_sell_orders
WHERE TRUE
      AND is_fs_member= 1
      AND is_cancelled = 0
      AND channel = 'EBO'
      [[AND {{category}}]]
      [[AND {{cohort}}]]
      [[AND {{service_type}}]]
      [[AND {{store_name}}]]
     [[ AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}} ]]
     
UNION ALL 

SELECT 'NON-FS-MEMBER', ROUND(SUM(gmv)) AS total_gmv
FROM 
dwh_fitness_metrics.cross_sell_orders
WHERE TRUE
      AND is_fs_member= 0
      AND is_cancelled = 0
      AND channel = 'EBO'
      [[AND {{category}}]]
      [[AND {{cohort}}]]
      [[AND {{service_type}}]]
      [[AND {{store_name}}]]
     [[ AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}} ]]
