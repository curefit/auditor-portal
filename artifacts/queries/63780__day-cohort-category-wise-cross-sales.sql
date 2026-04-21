SELECT 
    CASE 
        WHEN {{date_filter}} = 'Year' THEN CAST(year(order_date) AS VARCHAR)
        WHEN {{date_filter}} = 'Month' THEN format_datetime(order_date, 'MMMM') || ' - ' || CAST(year(order_date) AS VARCHAR)
        WHEN {{date_filter}} = 'Quarter' THEN 'Q' || CAST(quarter(order_date) AS VARCHAR) || ' - ' || CAST(year(order_date) AS VARCHAR)
    END AS order_date,
    CASE
        WHEN {{date_filter}} = 'Year' THEN date_trunc('year', order_date)
        WHEN {{date_filter}} = 'Month' THEN date_trunc('month', order_date)
        WHEN {{date_filter}} = 'Quarter' THEN date_trunc('quarter', order_date)
    END AS sort_key,
    cohort,
    category,
    ROUND(SUM(gmv)) AS total_gmv
FROM dwh_fitness_metrics.cross_sell_orders
WHERE TRUE
      AND is_fs_member= 1
      AND order_date >= DATE('2018-01-01')
      AND is_cancelled = 0
     [[ AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}} ]]
     [[AND {{cohort}}]]
     [[AND {{category}}]]
GROUP BY 1,2,3,4
ORDER BY sort_key, 5 DESC
