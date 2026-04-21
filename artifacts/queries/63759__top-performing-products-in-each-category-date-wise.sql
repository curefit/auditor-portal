WITH grouped_data AS 
(
    SELECT CASE 
        WHEN {{date_filter}} = 'Year' THEN CAST(year(order_date) AS VARCHAR)
        WHEN {{date_filter}} = 'Month' THEN format_datetime(order_date, 'MMMM') || ' - ' || CAST(year(order_date) AS VARCHAR)
        WHEN {{date_filter}} = 'Quarter' THEN 'Q' || CAST(quarter(order_date) AS VARCHAR) || ' - ' || CAST(year(order_date) AS VARCHAR)
    END AS order_date,
    CASE
        WHEN {{date_filter}} = 'Year' THEN date_trunc('year', order_date)
        WHEN {{date_filter}} = 'Month' THEN date_trunc('month', order_date)
        WHEN {{date_filter}} = 'Quarter' THEN date_trunc('quarter', order_date)
    END AS sort_key,
    category, article_type, majority_service, style_id, ROUND(SUM(gmv)) AS product_total_gmv
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE TRUE 
        AND is_fs_member = 1
        AND is_cancelled = 0
        [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
        [[AND {{category}}]]
        [[AND {{source}}]]
        [[AND {{cohort}}]]
    GROUP BY 1,2,3,4,5,6
),

overall_gmv AS
(
    SELECT  
        CASE 
            WHEN {{date_filter}} = 'Year' THEN CAST(year(order_date) AS VARCHAR)
            WHEN {{date_filter}} = 'Month' THEN format_datetime(order_date, 'MMMM') || ' - ' || CAST(year(order_date) AS VARCHAR)
            WHEN {{date_filter}} = 'Quarter' THEN 'Q' || CAST(quarter(order_date) AS VARCHAR) || ' - ' || CAST(year(order_date) AS VARCHAR)
        END AS order_date_overall,
        ROUND(SUM(gmv)) AS overall_total_gmv
    FROM 
    dwh_fitness_metrics.cross_sell_orders
    WHERE TRUE 
        AND is_fs_member = 1
        AND is_cancelled = 0
        [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
    GROUP BY 1
),

ranked_data AS 
(
    SELECT order_date,sort_key, category, article_type, majority_service, style_id,product_total_gmv, SUM(product_total_gmv) OVER(PARTITION BY category,order_date) AS category_total_gmv, og.overall_total_gmv, ROW_NUMBER() OVER(PARTITION BY order_date,sort_key,category ORDER BY product_total_gmv DESC) AS rnk 
    FROM 
    grouped_data gd
    JOIN 
    overall_gmv og ON gd.order_date = og.order_date_overall
)


SELECT 
    order_date,category, article_type, majority_service, style_id, product_total_gmv, category_total_gmv, overall_total_gmv,
    CAST(category_total_gmv/overall_total_gmv AS DOUBLE) * 100 AS overall_category_percentage_contribution, 
    CAST(product_total_gmv/category_total_gmv AS DOUBLE) * 100 AS category__product_percentage_contribution, 
    CAST(product_total_gmv/overall_total_gmv AS DOUBLE) * 100 AS overall_product_percentage_contribution, 
    rnk 
FROM ranked_data 
    WHERE 1 = 1
    [[AND rnk <= {{rank_less_than}}]]
    ORDER BY sort_key, overall_category_percentage_contribution DESC, overall_product_percentage_contribution DESC
