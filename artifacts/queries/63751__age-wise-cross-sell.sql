WITH age_calculated AS 
(
    SELECT CASE 
            WHEN birthday != 'NO-BIRTHDAY' THEN DATE_DIFF('MONTH',DATE(CAST(birthday AS TIMESTAMP)),order_date)/12 
            ELSE NULL
            END AS age, 
            user_id, category, gmv
    FROM 
    dwh_fitness_metrics.cross_sell_orders
    WHERE is_fs_member = 1
        AND order_date >= DATE('2018-01-01')
        AND is_cancelled = 0
      [[AND {{source}}]]
      [[AND {{category}}]]
      [[AND {{cohort}}]]
      [[AND {{service_type}}]]
      [[ AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
),

final_data AS
(
    SELECT CASE     WHEN age IS NULL THEN 'NO-AGE'
                    WHEN CAST(age AS DECIMAL) <= 10 THEN '0-10'
                    WHEN CAST(age AS DECIMAL) > 10 and CAST(age AS DECIMAL) <= 20 THEN '11-20'
                    WHEN CAST(age AS DECIMAL) > 20 and CAST(age AS DECIMAL) <= 30 THEN '21-30'
                    WHEN CAST(age AS DECIMAL) > 30 and CAST(age AS DECIMAL) <= 40 THEN '31-40'
                    WHEN CAST(age AS DECIMAL) > 40 and CAST(age AS DECIMAL) <= 50 THEN '41-50'
                    WHEN CAST(age AS DECIMAL) > 50 THEN '50+'
                END AS age,
            COUNT(DISTINCT user_id) AS user_count,
            ROUND(SUM(gmv)) AS total_gmv
    FROM age_calculated
    GROUP BY 1
)

SELECT age, total_gmv, total_gmv * 1.000/SUM(total_gmv) OVER() AS percentage
FROM 
final_data
ORDER BY 2 DESC
