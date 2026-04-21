WITH grouped_data AS 
(
    SELECT category, article_type, style_id, majority_service, ROUND(SUM(gmv)) AS product_total_gmv
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE TRUE 
        AND is_fs_member = 1
        AND is_cancelled = 0
        [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
        [[AND {{category}}]]
        [[AND {{source}}]]
        [[AND {{cohort}}]]
    GROUP BY 1,2,3,4
),

overall_gmv AS
(
    SELECT ROUND(SUM(gmv)) AS overall_total_gmv
    FROM 
    dwh_fitness_metrics.cross_sell_orders
    WHERE TRUE 
        AND is_fs_member = 1
        AND is_cancelled = 0
        [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
),

ranked_data AS 
(
    SELECT  category, article_type,majority_service, style_id,product_total_gmv, SUM(product_total_gmv) OVER(PARTITION BY category) AS category_total_gmv, cg.overall_total_gmv, ROW_NUMBER() OVER(PARTITION BY category ORDER BY product_total_gmv DESC) AS rnk 
    FROM 
    grouped_data gd
    CROSS JOIN 
    overall_gmv cg
)


SELECT 
    category, article_type, majority_service, style_id, product_total_gmv, category_total_gmv, overall_total_gmv,
    CAST(category_total_gmv/overall_total_gmv AS DOUBLE) * 100 AS overall_category_percentage_contribution, 
    CAST(product_total_gmv/category_total_gmv AS DOUBLE) * 100 AS category__product_percentage_contribution, 
    CAST(product_total_gmv/overall_total_gmv AS DOUBLE) * 100 AS overall_product_percentage_contribution, 
    rnk 
FROM ranked_data 
    WHERE 1 = 1
    [[AND rnk <= {{rank_less_than}}]]
    ORDER BY  overall_category_percentage_contribution DESC, overall_product_percentage_contribution DESC
