WITH bt_data AS (
    -- Monthly Metrics for Centers
    SELECT 
        CONCAT(CAST(cd.center_service_id AS VARCHAR), ' - ', cd.center_name) AS "Center",
        DATE_TRUNC('month', bf.booking_date) AS period,
        'M' AS period_type,
        SUM(bf.rating_value) AS total_rating_value,  -- Sum of rating values
        COUNT(DISTINCT CASE WHEN bf.rating_value IS NOT NULL THEN bf.booking_key END) AS total_ratings -- Count of ratings
    FROM 
        dwh_fitness_mart.booking_fact bf
    JOIN 
        (SELECT * FROM dwh_fitness_mart.center_dim WHERE 1=1
        [[AND {{city_name}}]]
        [[AND {{center_service_id}}]]
        [[AND {{service_type}}]]
        [[AND {{ownership_type}}]]
        [[AND {{business_line}}]]
        [[AND {{center_name}}]]
        ) cd ON bf.center_key = cd.center_key
    WHERE 1=1
        AND bf.class_date >= DATE('2022-01-01')
        AND bf.booking_date BETWEEN {{report_start_date}} AND {{report_end_date}}
        AND bf.attendance_time IS NOT NULL
    GROUP BY 
        CONCAT(CAST(cd.center_service_id AS VARCHAR), ' - ', cd.center_name),
        DATE_TRUNC('month', bf.booking_date)

    UNION ALL

    -- Quarterly Metrics for Centers
    SELECT 
        CONCAT(CAST(cd.center_service_id AS VARCHAR), ' - ', cd.center_name) AS "Center",
        DATE_TRUNC('quarter', bf.booking_date) AS period,
        'Q' AS period_type,
        SUM(bf.rating_value) AS total_rating_value,  -- Sum of rating values
        COUNT(DISTINCT CASE WHEN bf.rating_value IS NOT NULL THEN bf.booking_key END) AS total_ratings -- Count of ratings
    FROM 
        dwh_fitness_mart.booking_fact bf
    JOIN 
        (SELECT * FROM dwh_fitness_mart.center_dim WHERE 1=1
        [[AND {{city_name}}]]
        [[AND {{center_service_id}}]]
        [[AND {{service_type}}]]
        [[AND {{ownership_type}}]]
        [[AND {{business_line}}]]
        [[AND {{center_name}}]]
        ) cd ON bf.center_key = cd.center_key
    WHERE 1=1
        AND bf.class_date >= DATE('2022-01-01')
        AND bf.booking_date BETWEEN {{report_start_date}} AND {{report_end_date}}
        AND bf.attendance_time IS NOT NULL
    GROUP BY 
        CONCAT(CAST(cd.center_service_id AS VARCHAR), ' - ', cd.center_name),
        DATE_TRUNC('quarter', bf.booking_date)
)
SELECT 
    bt."Center",
    CONCAT(bt.period_type, '-', CAST(CAST(bt.period AS DATE) AS VARCHAR)) AS period,  -- Format period for quarters and months
    ROUND(bt.total_rating_value * 1.00 / NULLIF(bt.total_ratings, 0), 2) AS "Product Rating (PR)" -- Calculate Product Rating
FROM bt_data bt
ORDER BY 
    bt.period_type DESC,
    bt.period,
    bt."Center"
