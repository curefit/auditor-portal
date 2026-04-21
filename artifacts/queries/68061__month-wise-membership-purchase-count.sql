WITH fs_cohorts AS 
(
    SELECT *
    FROM 
    dwh_fitness_metrics.fs_cohorts
    WHERE 1 = 1
    AND month >= DATE('2018-01-01')
    AND 
        CASE 
            WHEN {{compare_with_current_month}} = 1 THEN 1 = 1 [[ AND DATE_TRUNC('MONTH',membership_created_date) >= DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL  '1' MONTH * {{no_of_month}}) ]]
            ELSE 1 = 1 [[ AND DATE_TRUNC('MONTH',membership_created_date) BETWEEN DATE_TRUNC('MONTH',{{month_start_date}}) AND DATE_TRUNC('MONTH', {{month_end_date}}) ]]
        END
    AND 
        CASE
            WHEN {{compare_with_current_date}} = 1 THEN DAY(membership_created_date) < DAY(CURRENT_DATE)
            ELSE 1 = 1 [[ AND DAY(membership_created_date) BETWEEN {{date_of_month_start_date}} AND {{date_of_month_end_date}} ]]
        END
)

SELECT DATE_TRUNC('MONTH',membership_created_date) AS month, COUNT(DISTINCT user_id) AS user_count
FROM 
fs_cohorts
GROUP BY 1
ORDER BY 1
