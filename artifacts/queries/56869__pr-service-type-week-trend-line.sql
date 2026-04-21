WITH bt_data AS (
    
    SELECT 
        CASE 
            WHEN cd.center_type = 'GX' THEN 'GX'
            WHEN cd.center_type = 'GYM' THEN 'GYM'
            WHEN cd.center_type = 'SPORTS' THEN 'PLAY'
            ELSE 'OTHER'
        END AS "Service Type",
        DATE_TRUNC('week', bf.attendance_time) AS period,
        SUM(CASE WHEN bf.rating_value IS NOT NULL THEN bf.rating_value END) AS total_rating_value, 
        COUNT(CASE WHEN bf.rating_value IS NOT NULL THEN bf.booking_key END) AS total_ratings 
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
    WHERE 
        bf.attendance_time IS NOT NULL
        AND bf.class_date >= DATE('2022-01-01')
        AND bf.booking_date BETWEEN {{report_start_date}} AND {{report_end_date}}
        AND cd.center_type IN ('GYM', 'GX', 'SPORTS')
    GROUP BY 
        CASE 
            WHEN cd.center_type = 'GX' THEN 'GX'
            WHEN cd.center_type = 'GYM' THEN 'GYM'
            WHEN cd.center_type = 'SPORTS' THEN 'PLAY'
            ELSE 'OTHER'
        END,
        DATE_TRUNC('week', bf.attendance_time)
),
pivoted_data AS (
    SELECT 
        DATE_TRUNC('week', period) AS week,
        MAX(CASE WHEN "Service Type" = 'GX' THEN ROUND(total_rating_value * 1.00 / NULLIF(total_ratings, 0), 2) END) AS "GX PR",
        MAX(CASE WHEN "Service Type" = 'GYM' THEN ROUND(total_rating_value * 1.00 / NULLIF(total_ratings, 0), 2) END) AS "GYM PR",
        MAX(CASE WHEN "Service Type" = 'PLAY' THEN ROUND(total_rating_value * 1.00 / NULLIF(total_ratings, 0), 2) END) AS "PLAY PR"
    FROM bt_data
    GROUP BY DATE_TRUNC('week', period)
)
SELECT 
    DATE_FORMAT(week, '%Y-%m') AS "week",
    "GX PR" AS "GX Product Rating",
    "GYM PR" AS "GYM Product Rating",
    "PLAY PR" AS "PLAY Product Rating"
FROM pivoted_data
ORDER BY week ASC
