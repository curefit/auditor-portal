WITH cross_sell_orders AS 
(
    SELECT *
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE 1 = 1
    AND is_cancelled = 0
    AND 
        CASE 
            WHEN {{compare_with_current_month}} = 1 THEN 1 = 1 [[ AND month >= DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL  '1' MONTH * {{no_of_month}}) ]]
            ELSE 1 = 1 [[ AND month BETWEEN DATE_TRUNC('MONTH',{{month_start_date}}) AND DATE_TRUNC('MONTH', {{month_end_date}}) ]]
        END
    AND 
        CASE
            WHEN {{compare_with_current_date}} = 1 THEN DAY(order_date) < DAY(CURRENT_DATE)
            ELSE 1 = 1 [[ AND DAY(order_date) BETWEEN {{date_of_month_start_date}} AND {{date_of_month_end_date}} ]]
        END
    [[AND {{is_fs_member}}]]
    [[AND {{source}}]]
    [[AND {{category}}]]
    [[AND {{cohort}}]]
    [[AND {{service_type}}]]
)

SELECT month, article_type, ROUND(SUM(gmv)) AS total_gmv, COUNT(DISTINCT CASE WHEN DAY_OF_WEEK(order_date) IN (6,7) THEN order_date ELSE NULL END) AS total_weekends
FROM cross_sell_orders
GROUP BY 1, 2
ORDER BY 1, 3 DESC
