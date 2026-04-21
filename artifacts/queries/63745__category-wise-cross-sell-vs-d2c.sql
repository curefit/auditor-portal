WITH combined_data AS 
(
    SELECT 'CROSS-SELL' AS member_type,category, ROUND(SUM(gmv)) AS gmv
    FROM 
    dwh_fitness_metrics.cross_sell_orders
    WHERE TRUE
         AND is_fs_member= 1
         AND is_cancelled = 0
         AND order_date >= DATE('2018-01-01')
         [[AND {{source}}]]
         [[AND {{category}}]]
         [[AND {{cohort}}]]
         [[AND {{service_type}}]]
         [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}} ]]
    GROUP BY 1,2
         
    UNION ALL 
    
    SELECT 'NON-FS-MEMBER' AS member_type,category, ROUND(SUM(gmv)) AS gmv
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
         [[ AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}} ]] 
    GROUP BY 1,2
)

SELECT 
    member_type,
    category,
    gmv
FROM combined_data
ORDER BY 
    SUM(gmv) OVER (PARTITION BY category) DESC, 
    category
