WITH freebie_data AS 
 (
    SELECT *
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE order_date >= DATE('2018-01-01')
    [[ AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}} ]]
    [[ AND {{coupon_code}}]]
    AND {{is_freebie_order}}
),

freebie_user_date AS 
(   
    SELECT user_id AS min_user_id, MIN(order_timestamp) AS min_order_timestamp
    FROM 
    freebie_data
    GROUP BY 1
),

order_data_freebie_users AS 
(
    SELECT *
    FROM dwh_fitness_metrics.cross_sell_orders nc
    JOIN freebie_user_date fbd ON nc.user_id = fbd.min_user_id
         AND order_timestamp  > min_order_timestamp
    WHERE order_date >= DATE('2018-01-01')
)

SELECT COUNT(DISTINCT user_id) AS user_count
FROM 
order_data_freebie_users
WHERE is_freebie_order = 0
