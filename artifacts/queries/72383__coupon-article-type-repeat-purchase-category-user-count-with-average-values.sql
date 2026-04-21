WITH freebie_data AS (
    SELECT *
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE order_date >= DATE('2018-01-01')
    [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
    AND {{coupon_code}}
    AND {{is_freebie_order}}
),

freebie_user_date AS 
(   
    SELECT user_id AS min_user_id, MIN(order_timestamp) AS min_order_timestamp
    FROM 
    freebie_data
    GROUP BY 1
),

freebie_user_category AS (
    SELECT 
        user_id AS freebie_user_id,
        article_type AS freebie_article_type
    FROM freebie_data
    GROUP BY 1,2
),

order_data_freebie_users AS 
(
    SELECT *,MIN(CASE WHEN is_freebie_order = 0 THEN DATE(order_date) ELSE DATE('2100-01-01') END) OVER(PARTITION BY user_id) AS min_repeat_date
    FROM dwh_fitness_metrics.cross_sell_orders nc
    JOIN freebie_user_date fbd ON nc.user_id = fbd.min_user_id
         AND order_timestamp > min_order_timestamp
    JOIN freebie_user_category fat ON fat.freebie_user_id = nc.user_id
    WHERE order_date >= DATE('2018-01-01')
)


SELECT freebie_article_type, category, COUNT(DISTINCT user_id) AS user_count, COUNT(DISTINCT order_id) AS order_count, SUM(gmv) AS total_gmv, AVG(gmv) AS average_gmv, AVG(DATE_DIFF('DAY',min_order_timestamp,min_repeat_date)) AS avg_date_dff
FROM 
order_data_freebie_users
WHERE is_freebie_order = 0
GROUP BY 1,2
ORDER BY 1,5 DESC
