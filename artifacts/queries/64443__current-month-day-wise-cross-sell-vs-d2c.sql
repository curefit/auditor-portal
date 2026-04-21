WITH final_data AS
(
    SELECT 
        order_date,
        CASE 
            WHEN is_fs_member = 0 THEN 'NON-FS MEMBER'
            WHEN is_fs_member = 1 THEN 'CROSS-SELL'
        END AS is_fs_member, 
        CASE 
            WHEN DAY_OF_WEEK(order_date) IN (6, 7) THEN 1 
            ELSE 0 
        END AS is_weekend,
        WEEK(order_date) - WEEK(DATE_TRUNC('MONTH', order_date)) + 1  AS week_of_month,
        DAY_OF_WEEK(order_date) AS day_of_week,
        FORMAT_DATETIME(order_date, 'EEEE') AS day_name,
        ROUND(SUM(gmv)) AS gmv
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE 1 = 1
         AND is_cancelled = 0
         AND CASE 
                WHEN {{current_month_trend}} = 1 THEN order_date BETWEEN DATE_TRUNC('MONTH',CURRENT_DATE) AND CURRENT_DATE - INTERVAL '1' DAY
                ELSE {{current_month_trend}} = 0 [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
             END
         [[AND {{source}}]]
         [[AND {{category}}]]
         [[AND {{cohort}}]]
         [[AND {{service_type}}]]
         AND order_date <= CURRENT_DATE - INTERVAL '1' DAY
    GROUP BY  1, 2,3, 4, 5, 6
)

SELECT *, ROUND(SUM(gmv) OVER(PARTITION BY order_date)) AS total_gmv
FROM final_data
ORDER BY 1, 2
