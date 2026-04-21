SELECT COUNT(distinct user_id) AS user_count
FROM dwh_fitness_metrics.cross_sell_orders
WHERE order_date >= DATE('2018-01-01')
[[ AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}} ]]
[[ AND {{coupon_code}} ]]
AND {{is_freebie_order}}
