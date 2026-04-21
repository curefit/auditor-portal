SELECT article_type, COUNT(distinct user_id) AS user_count
FROM dwh_fitness_metrics.cross_sell_orders
    WHERE is_freebie_order = 1
            AND order_date >= DATE('2018-01-01')
            AND {{coupon_code}}
            AND {{is_freebie_order}}
            AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}
GROUP BY 1
ORDER BY 2 DESC
