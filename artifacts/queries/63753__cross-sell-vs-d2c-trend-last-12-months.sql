WITH final_data AS 
(
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
        CASE 
            WHEN is_fs_member = 0 THEN 'NON-FS MEMBER'
            WHEN is_fs_member = 1 THEN 'CROSS-SELL'
        END AS is_fs_member,
        ROUND(SUM(gmv)) AS gmv
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE TRUE
          [[AND {{source}}]]
          [[AND {{category}}]]
          [[AND {{cohort}}]]
          [[AND {{service_type}}]]
          AND is_cancelled = 0
          AND CASE 
                WHEN {{twelve_month_trend}} = 1 THEN order_date BETWEEN DATE_TRUNC('MONTH',CURRENT_DATE) - INTERVAL '13' MONTH AND DATE_TRUNC('MONTH',CURRENT_DATE) - INTERVAL '1' DAY
                ELSE {{twelve_month_trend}} = 0 [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
              END
    GROUP BY 1,2,3
)

SELECT *, gmv/SUM(gmv) OVER(PARTITION BY order_date) AS percentage, ROUND(SUM(gmv) OVER(PARTITION BY order_date)) AS total_gmv
FROM final_data
ORDER BY sort_key
