WITH user_details AS 
(
    SELECT DISTINCT user_id
    FROM 
    dwh_fitness_metrics.fs_cohorts
    WHERE user_id NOT IN (SELECT user_id FROM gs_d2c.default.cs_dev_users)
    AND month = DATE_TRUNC('MONTH', CURRENT_DATE)
),

order_detail AS 
(
    SELECT user_id, MIN(order_date) AS min_order_date
    FROM  dwh_fitness_metrics.cross_sell_orders
    WHERE user_id IN (SELECT DISTINCT user_id FROM user_details)
    AND order_date >= DATE('2018-01-01')
    GROUP BY 1
),

user_count_details AS
(
    SELECT DATE_TRUNC('QUARTER',min_order_date) AS month, COUNT(DISTINCT user_id) AS user_count
    FROM 
    order_detail
    GROUP BY 1
)


SELECT month, SUM(user_count) OVER(ORDER BY month) AS user_count 
FROM 
user_count_details
