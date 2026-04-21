WITH final_data AS 
(
    SELECT  gender,
            COUNT(DISTINCT user_id) AS user_count,
            ROUND(SUM(gmv)) AS total_gmv
    FROM  dwh_fitness_metrics.cross_sell_orders
    WHERE is_fs_member = 1
         AND is_cancelled = 0
         AND order_date >= DATE('2018-01-01')
         [[AND {{source}}]]
         [[AND {{category}}]]
         [[AND {{cohort}}]]
         [[AND {{service_type}}]]
          [[ AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
    GROUP BY 1
)

SELECT gender, total_gmv, total_gmv * 1.000/SUM(total_gmv) OVER() AS percentage
FROM 
final_data
ORDER BY 2 DESC
