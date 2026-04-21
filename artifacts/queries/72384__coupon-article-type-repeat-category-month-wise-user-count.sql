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
    SELECT *, MIN(CASE WHEN is_freebie_order = 0 THEN DATE(order_date) ELSE DATE('2100-01-01') END) OVER(PARTITION BY user_id) AS min_repeat_orders
    FROM dwh_fitness_metrics.cross_sell_orders nc
    JOIN freebie_user_date fbd ON nc.user_id = fbd.min_user_id
         AND order_timestamp > min_order_timestamp
    JOIN freebie_user_category fat ON fat.freebie_user_id = nc.user_id
    WHERE order_date >= DATE('2018-01-01')
)

SELECT 
    freebie_article_type, 
    category,
    COUNT(DISTINCT CASE WHEN DATE_DIFF('DAY', DATE(min_order_timestamp), min_repeat_orders) BETWEEN 0 AND 29 THEN user_id END) AS "Month 0",
    COUNT(DISTINCT CASE WHEN DATE_DIFF('DAY', DATE(min_order_timestamp), min_repeat_orders) BETWEEN 30 AND 59 THEN user_id END) AS "Month 1",
    COUNT(DISTINCT CASE WHEN DATE_DIFF('DAY', DATE(min_order_timestamp), min_repeat_orders) BETWEEN 60 AND 89 THEN user_id END) AS "Month 2",
    COUNT(DISTINCT CASE WHEN DATE_DIFF('DAY', DATE(min_order_timestamp), min_repeat_orders) BETWEEN 90 AND 119 THEN user_id END) AS "Month 3",
    COUNT(DISTINCT CASE WHEN DATE_DIFF('DAY', DATE(min_order_timestamp), min_repeat_orders) BETWEEN 120 AND 149 THEN user_id END) AS "Month 4",
    COUNT(DISTINCT CASE WHEN DATE_DIFF('DAY', DATE(min_order_timestamp), min_repeat_orders) BETWEEN 150 AND 179 THEN user_id END) AS "Month 5",
    COUNT(DISTINCT CASE WHEN DATE_DIFF('DAY', DATE(min_order_timestamp), min_repeat_orders) BETWEEN 180 AND 209 THEN user_id END) AS "Month 6",
    COUNT(DISTINCT CASE WHEN DATE_DIFF('DAY', DATE(min_order_timestamp), min_repeat_orders) BETWEEN 210 AND 239 THEN user_id END) AS "Month 7",
    COUNT(DISTINCT CASE WHEN DATE_DIFF('DAY', DATE(min_order_timestamp), min_repeat_orders) BETWEEN 240 AND 269 THEN user_id END) AS "Month 8",
    COUNT(DISTINCT CASE WHEN DATE_DIFF('DAY', DATE(min_order_timestamp), min_repeat_orders) BETWEEN 270 AND 299 THEN user_id END) AS "Month 9",
    COUNT(DISTINCT CASE WHEN DATE_DIFF('DAY', DATE(min_order_timestamp), min_repeat_orders) BETWEEN 300 AND 329 THEN user_id END) AS "Month 10",
    COUNT(DISTINCT CASE WHEN DATE_DIFF('DAY', DATE(min_order_timestamp), min_repeat_orders) BETWEEN 330 AND 359 THEN user_id END) AS "Month 11",
    COUNT(DISTINCT CASE WHEN DATE_DIFF('DAY', DATE(min_order_timestamp), min_repeat_orders) BETWEEN 360 AND 389 THEN user_id END) AS "Month 12",
    COUNT(DISTINCT CASE WHEN DATE_DIFF('DAY', DATE(min_order_timestamp), min_repeat_orders) >= 390 THEN user_id END) AS "Month 12+"
FROM 
order_data_freebie_users
WHERE is_freebie_order = 0
GROUP BY 1,2
ORDER BY 1 DESC
