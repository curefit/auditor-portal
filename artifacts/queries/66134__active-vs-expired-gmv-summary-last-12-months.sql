SELECT 'Active' AS active_vs_expired,
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
        ROUND(SUM(gmv)) AS total_gmv
FROM dwh_fitness_metrics.cross_sell_orders
WHERE TRUE
      AND is_fs_member  = 1
      AND is_cancelled = 0
      AND cohort NOT LIKE '%Expired%'
     [[AND {{source}}]]
     [[AND {{category}}]]
     [[AND {{cohort}}]]
     [[AND {{service_type}}]]
      AND CASE 
            WHEN {{twelve_month_trend}} = 1 THEN order_date BETWEEN DATE_TRUNC('MONTH',CURRENT_DATE) - INTERVAL '13' MONTH AND DATE_TRUNC('MONTH',CURRENT_DATE) - INTERVAL '1' DAY
            ELSE {{twelve_month_trend}} = 0 [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
          END
GROUP BY 1,2,3


UNION ALL 

SELECT 'Expired' AS active_vs_expired,
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
        ROUND(SUM(gmv)) AS total_gmv
FROM dwh_fitness_metrics.cross_sell_orders
WHERE TRUE
      AND is_fs_member  = 1
      AND is_cancelled = 0
      AND cohort LIKE '%Expired%'
     [[AND {{source}}]]
     [[AND {{category}}]]
     [[AND {{cohort}}]]
     [[AND {{service_type}}]]
     AND CASE 
            WHEN {{twelve_month_trend}} = 1 THEN order_date BETWEEN DATE_TRUNC('MONTH',CURRENT_DATE) - INTERVAL '13' MONTH AND DATE_TRUNC('MONTH',CURRENT_DATE) - INTERVAL '1' DAY
            ELSE {{twelve_month_trend}} = 0 [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
         END
GROUP BY 1,2,3
    
ORDER BY 3
