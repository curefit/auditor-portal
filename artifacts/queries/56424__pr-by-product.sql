WITH bt_data AS (
    SELECT 
        'Overall' AS "Service Type",
        DATE_ADD('month', 3, DATE_TRUNC('year', DATE_ADD('month', -3, bf.attendance_time))) AS period,
        -- 'Y' AS period_type,
        SUM(CASE WHEN bf.rating_value IS NOT NULL THEN bf.rating_value END) AS total_rating_value,
        COUNT(DISTINCT CASE WHEN bf.rating_value IS NOT NULL THEN bf.booking_key END) AS total_ratings
    FROM dwh_fitness_mart.booking_fact bf
    JOIN (
        SELECT * FROM dwh_fitness_mart.center_dim 
        WHERE 1=1
        [[AND {{city_name}}]]
        [[AND {{center_service_id}}]]
        [[AND {{service_type}}]]
        [[AND {{ownership_type}}]]
        [[AND {{business_line}}]]
        [[AND {{center_name}}]]
    ) cd ON bf.center_key = cd.center_key
    WHERE 
        bf.attendance_time IS NOT NULL
        AND bf.class_date >= DATE('2022-01-01') -- Partition
        AND bf.attendance_time BETWEEN {{report_start_date}} AND {{report_end_date}}
        AND cd.center_type IN ('GYM', 'GX', 'SPORTS')
    GROUP BY 
        DATE_ADD('month', 3, DATE_TRUNC('year', DATE_ADD('month', -3, bf.attendance_time)))
)

SELECT 
    bt."Service Type",
    CONCAT('FY',DATE_FORMAT(bt.period, '%y'), '-', DATE_FORMAT(DATE_ADD('year', 1, bt.period), '%y') ) AS period,
    ROUND(bt.total_rating_value * 1.00 / NULLIF(bt.total_ratings, 0), 2) AS "Product Rating (PR)"
FROM bt_data bt
ORDER BY 
    -- bt.period_type DESC,
    bt.period

--- commentd query below is kept for reuse later;

-- WITH bt_data AS (
--     -- Monthly Metrics for Individual Service Types
--     SELECT 
--         CASE 
--             WHEN cd.center_type = 'GX' THEN 'GX'
--             WHEN cd.center_type = 'GYM' THEN 'GYM'
--             WHEN cd.center_type = 'SPORTS' THEN 'PLAY'
--             ELSE 'OTHER'
--         END AS "Service Type",
--         DATE_TRUNC('month', bf.attendance_time) AS period,
--         'M' AS period_type,
--         SUM(CASE WHEN bf.rating_value IS NOT NULL THEN bf.rating_value END) AS total_rating_value,
--         COUNT(DISTINCT CASE WHEN bf.rating_value IS NOT NULL THEN bf.booking_key END) AS total_ratings
--     FROM 
--         dwh_fitness_mart.booking_fact bf
--     JOIN 
--         (SELECT * FROM dwh_fitness_mart.center_dim WHERE 1=1
--         [[AND {{city_name}}]]
--         [[AND {{center_service_id}}]]
--         [[AND {{service_type}}]]
--         [[AND {{ownership_type}}]]
--         [[AND {{business_line}}]]
--         [[AND {{center_name}}]]
--         ) cd ON bf.center_key = cd.center_key
--     WHERE 
--         bf.attendance_time IS NOT NULL
--         AND bf.class_date >= DATE('2022-01-01')
--         AND bf.attendance_time BETWEEN {{report_start_date}} AND {{report_end_date}}
--         AND cd.center_type IN ('GYM', 'GX', 'SPORTS')
--     GROUP BY 
--         CASE 
--             WHEN cd.center_type = 'GX' THEN 'GX'
--             WHEN cd.center_type = 'GYM' THEN 'GYM'
--             WHEN cd.center_type = 'SPORTS' THEN 'PLAY'
--             ELSE 'OTHER'
--         END,
--         DATE_TRUNC('month', bf.attendance_time)

--     UNION ALL

--     -- Quarterly Metrics for Individual Service Types
--     SELECT 
--         CASE 
--             WHEN cd.center_type = 'GX' THEN 'GX'
--             WHEN cd.center_type = 'GYM' THEN 'GYM'
--             WHEN cd.center_type = 'SPORTS' THEN 'PLAY'
--             ELSE 'OTHER'
--         END AS "Service Type",
--         DATE_TRUNC('quarter', bf.attendance_time) AS period,
--         'Q' AS period_type,
--         SUM(CASE WHEN bf.rating_value IS NOT NULL THEN bf.rating_value END) AS total_rating_value,
--         COUNT(DISTINCT CASE WHEN bf.rating_value IS NOT NULL THEN bf.booking_key END) AS total_ratings
--     FROM 
--         dwh_fitness_mart.booking_fact bf
--     JOIN 
--         (SELECT * FROM dwh_fitness_mart.center_dim WHERE 1=1
--         [[AND {{city_name}}]]
--         [[AND {{center_service_id}}]]
--         [[AND {{service_type}}]]
--         [[AND {{ownership_type}}]]
--         [[AND {{business_line}}]]
--         [[AND {{center_name}}]]
--         ) cd ON bf.center_key = cd.center_key
--     WHERE 
--         bf.attendance_time IS NOT NULL
--         AND bf.class_date >= DATE('2022-01-01')
--         AND bf.attendance_time BETWEEN {{report_start_date}} AND {{report_end_date}}
--         AND cd.center_type IN ('GYM', 'GX', 'SPORTS')
--     GROUP BY 
--         CASE 
--             WHEN cd.center_type = 'GX' THEN 'GX'
--             WHEN cd.center_type = 'GYM' THEN 'GYM'
--             WHEN cd.center_type = 'SPORTS' THEN 'PLAY'
--             ELSE 'OTHER'
--         END,
--         DATE_TRUNC('quarter', bf.attendance_time)

--     UNION ALL

--     -- Monthly Metrics for GX+GYM
--     SELECT 
--         'GX+GYM' AS "Service Type",
--         DATE_TRUNC('month', bf.attendance_time) AS period,
--         'M' AS period_type,
--         SUM(CASE WHEN bf.rating_value IS NOT NULL THEN bf.rating_value END) AS total_rating_value,
--         COUNT(DISTINCT CASE WHEN bf.rating_value IS NOT NULL THEN bf.booking_key END) AS total_ratings
--     FROM 
--         dwh_fitness_mart.booking_fact bf
--     JOIN 
--         (SELECT * FROM dwh_fitness_mart.center_dim WHERE 1=1
--         [[AND {{city_name}}]]
--         [[AND {{center_service_id}}]]
--         [[AND {{service_type}}]]
--         [[AND {{ownership_type}}]]
--         [[AND {{business_line}}]]
--         [[AND {{center_name}}]]
--         ) cd ON bf.center_key = cd.center_key
--     WHERE 
--         bf.attendance_time IS NOT NULL
--         AND bf.class_date >= DATE('2022-01-01')
--         AND bf.attendance_time BETWEEN {{report_start_date}} AND {{report_end_date}}
--         AND cd.center_type IN ('GYM', 'GX')
--     GROUP BY 
--         DATE_TRUNC('month', bf.attendance_time)

--     UNION ALL

--     -- Quarterly Metrics for GX+GYM
--     SELECT 
--         'GX+GYM' AS "Service Type",
--         DATE_TRUNC('quarter', bf.attendance_time) AS period,
--         'Q' AS period_type,
--         SUM(CASE WHEN bf.rating_value IS NOT NULL THEN bf.rating_value END) AS total_rating_value,
--         COUNT(DISTINCT CASE WHEN bf.rating_value IS NOT NULL THEN bf.booking_key END) AS total_ratings
--     FROM 
--         dwh_fitness_mart.booking_fact bf
--     JOIN 
--         (SELECT * FROM dwh_fitness_mart.center_dim WHERE 1=1
--         [[AND {{city_name}}]]
--         [[AND {{center_service_id}}]]
--         [[AND {{service_type}}]]
--         [[AND {{ownership_type}}]]
--         [[AND {{business_line}}]]
--         [[AND {{center_name}}]]
--         ) cd ON bf.center_key = cd.center_key
--     WHERE 
--         bf.attendance_time IS NOT NULL
--         AND bf.class_date >= DATE('2022-01-01')
--         AND bf.attendance_time BETWEEN {{report_start_date}} AND {{report_end_date}}
--         AND cd.center_type IN ('GYM', 'GX')
--     GROUP BY 
--         DATE_TRUNC('quarter', bf.attendance_time)

--     UNION ALL

--     -- Monthly Metrics for GX+GYM+PLAY
--     SELECT 
--         'GX+GYM+PLAY' AS "Service Type",
--         DATE_TRUNC('month', bf.attendance_time) AS period,
--         'M' AS period_type,
--         SUM(CASE WHEN bf.rating_value IS NOT NULL THEN bf.rating_value END) AS total_rating_value,
--         COUNT(DISTINCT CASE WHEN bf.rating_value IS NOT NULL THEN bf.booking_key END) AS total_ratings
--     FROM 
--         dwh_fitness_mart.booking_fact bf
--     JOIN 
--         (SELECT * FROM dwh_fitness_mart.center_dim WHERE 1=1
--         [[AND {{city_name}}]]
--         [[AND {{center_service_id}}]]
--         [[AND {{service_type}}]]
--         [[AND {{ownership_type}}]]
--         [[AND {{business_line}}]]
--         [[AND {{center_name}}]]
--         ) cd ON bf.center_key = cd.center_key
--     WHERE 
--         bf.attendance_time IS NOT NULL
--         AND bf.class_date >= DATE('2022-01-01')
--         AND bf.attendance_time BETWEEN {{report_start_date}} AND {{report_end_date}}
--         AND cd.center_type IN ('GYM', 'GX', 'SPORTS')
--     GROUP BY 
--         DATE_TRUNC('month', bf.attendance_time)

--     UNION ALL

--     -- Quarterly Metrics for GX+GYM+PLAY
--     SELECT 
--         'GX+GYM+PLAY' AS "Service Type",
--         DATE_TRUNC('quarter', bf.attendance_time) AS period,
--         'Q' AS period_type,
--         SUM(CASE WHEN bf.rating_value IS NOT NULL THEN bf.rating_value END) AS total_rating_value,
--         COUNT(DISTINCT CASE WHEN bf.rating_value IS NOT NULL THEN bf.booking_key END) AS total_ratings
--     FROM 
--         dwh_fitness_mart.booking_fact bf
--     JOIN 
--         (SELECT * FROM dwh_fitness_mart.center_dim WHERE 1=1
--         [[AND {{city_name}}]]
--         [[AND {{center_service_id}}]]
--         [[AND {{service_type}}]]
--         [[AND {{ownership_type}}]]
--         [[AND {{business_line}}]]
--         [[AND {{center_name}}]]
--         ) cd ON bf.center_key = cd.center_key
--     WHERE 
--         bf.attendance_time IS NOT NULL
--         AND bf.class_date >= DATE('2022-01-01')
--         AND bf.attendance_time BETWEEN {{report_start_date}} AND {{report_end_date}}
--         AND cd.center_type IN ('GYM', 'GX', 'SPORTS')
--     GROUP BY 
--         DATE_TRUNC('quarter', bf.attendance_time)
-- )

-- SELECT 
--     bt."Service Type",
--     CONCAT(bt.period_type, '-', DATE_FORMAT(bt.period, '%Y-%m-%d')) AS period,
--     ROUND(bt.total_rating_value * 1.00 / NULLIF(bt.total_ratings, 0), 2) AS "Product Rating (PR)"
-- FROM bt_data bt
-- ORDER BY 
--     bt.period_type DESC,
--     bt.period,
--     CASE
--         WHEN bt."Service Type" = 'GX' THEN 1
--         WHEN bt."Service Type" = 'GYM' THEN 2
--         WHEN bt."Service Type" = 'PLAY' THEN 3
--         WHEN bt."Service Type" = 'GX+GYM' THEN 4
--         WHEN bt."Service Type" = 'GX+GYM+PLAY' THEN 5
--         ELSE 6
--     END