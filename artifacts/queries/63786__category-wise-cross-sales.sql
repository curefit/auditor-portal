WITH final_data AS 
(
    SELECT category, ROUND(SUM(gmv)) AS total_gmv
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE TRUE
          AND is_fs_member = 1
          AND order_date >= DATE('2018-01-01')
          AND is_cancelled = 0
         [[AND {{source}}]]
         [[AND {{category}}]]
         [[AND {{cohort}}]]
         [[AND {{service_type}}]]
         [[AND order_date BETWEEN {{start_order_date}} AND {{end_order_date}}]]
    GROUP BY category
)

SELECT category, total_gmv, total_gmv * 1.000/SUM(total_gmv) OVER() AS percentage
FROM 
final_data
ORDER BY 2 DESC
