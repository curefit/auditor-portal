WITH freebie_data AS 
 (
    SELECT *
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE order_date >= DATE('2018-01-01')
    [[ AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}} ]]
    AND {{coupon_code}}
    AND {{is_freebie_order}}
),

freebie_user_date AS 
(   
    SELECT user_id AS min_user_id, MIN_BY(unique_order_id, order_timestamp) AS min_order_id
    FROM 
    freebie_data
    GROUP BY 1
),

order_data_freebie_users AS 
(
    SELECT *
    FROM dwh_fitness_metrics.cross_sell_orders nc
    JOIN freebie_user_date fbd ON nc.user_id = fbd.min_user_id
    WHERE unique_order_id = min_order_id
    [[ AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}} ]]
    AND order_date >= DATE('2018-01-01')
),

final_summary AS 
(
    SELECT order_id, user_id
    FROM 
    order_data_freebie_users
    GROUP BY order_id,user_id
    HAVING COUNT(DISTINCT sku_code) > 1
)

SELECT COUNT(DISTINCT user_id) AS user_count
FROM 
final_summary
