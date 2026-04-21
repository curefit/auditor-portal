WITH bt_data AS (
    -- Monthly Metrics by City
    SELECT 
        CASE 
            WHEN cd.city_name = 'Bangalore' THEN '1. Bangalore'
            WHEN cd.city_name = 'Hyderabad' THEN '2. Hyderabad'
            WHEN cd.city_name = 'Gurgaon' THEN '3. NCR'
            WHEN cd.city_name IN ('Mumbai', 'Navi_Mumbai_and_Thane') THEN '4. Mumbai'
            WHEN cd.city_name = 'Pune' THEN '5. Pune'
            WHEN cd.city_name = 'Chennai' THEN '6. Chennai'
            ELSE '7. Others'
        END AS "City",
        DATE_TRUNC('month', bf.attendance_time) AS period,
        'M' AS period_type,
        SUM(CASE WHEN bf.rating_value IS NOT NULL THEN bf.rating_value END) AS total_rating_value, -- Total Rating Value
        COUNT(DISTINCT CASE WHEN bf.rating_value IS NOT NULL THEN bf.booking_key END) AS total_ratings -- Total Ratings Count
    FROM 
        dwh_fitness_mart.booking_fact bf
    JOIN 
        (SELECT * FROM dwh_fitness_mart.center_dim WHERE 1=1
        [[AND {{service_type}}]]
        [[AND {{ownership_type}}]]
        [[AND {{business_line}}]]
        [[AND {{center_name}}]]
        [[AND {{center_service_id}}]]
        ) cd ON bf.center_key = cd.center_key
    WHERE 
        bf.attendance_time IS NOT NULL
        AND bf.class_date >= DATE('2022-01-01')
        AND bf.booking_date BETWEEN {{report_start_date}} AND {{report_end_date}}
    GROUP BY 
        CASE 
            WHEN cd.city_name = 'Bangalore' THEN '1. Bangalore'
            WHEN cd.city_name = 'Hyderabad' THEN '2. Hyderabad'
            WHEN cd.city_name = 'Gurgaon' THEN '3. NCR'
            WHEN cd.city_name IN ('Mumbai', 'Navi_Mumbai_and_Thane') THEN '4. Mumbai'
            WHEN cd.city_name = 'Pune' THEN '5. Pune'
            WHEN cd.city_name = 'Chennai' THEN '6. Chennai'
            ELSE '7. Others'
        END,
        DATE_TRUNC('month', bf.attendance_time)

    UNION ALL

    -- Quarterly Metrics by City
    SELECT 
        CASE 
            WHEN cd.city_name = 'Bangalore' THEN '1. Bangalore'
            WHEN cd.city_name = 'Hyderabad' THEN '2. Hyderabad'
            WHEN cd.city_name = 'Gurgaon' THEN '3. NCR'
            WHEN cd.city_name IN ('Mumbai', 'Navi_Mumbai_and_Thane') THEN '4. Mumbai'
            WHEN cd.city_name = 'Pune' THEN '5. Pune'
            WHEN cd.city_name = 'Chennai' THEN '6. Chennai'
            ELSE '7. Others'
        END AS "City",
        DATE_TRUNC('quarter', bf.attendance_time) AS period,
        'Q' AS period_type,
        SUM(CASE WHEN bf.rating_value IS NOT NULL THEN bf.rating_value END) AS total_rating_value,
        COUNT(DISTINCT CASE WHEN bf.rating_value IS NOT NULL THEN bf.booking_key END) AS total_ratings
    FROM 
        dwh_fitness_mart.booking_fact bf
    JOIN 
        (SELECT * FROM dwh_fitness_mart.center_dim WHERE 1=1
        [[AND {{service_type}}]]
        [[AND {{ownership_type}}]]
        [[AND {{business_line}}]]
        [[AND {{center_name}}]]
        [[AND {{center_service_id}}]]
        ) cd ON bf.center_key = cd.center_key
    WHERE 
        bf.attendance_time IS NOT NULL
        AND bf.class_date >= DATE('2022-01-01')
        AND bf.booking_date BETWEEN {{report_start_date}} AND {{report_end_date}}
    GROUP BY 
        CASE 
            WHEN cd.city_name = 'Bangalore' THEN '1. Bangalore'
            WHEN cd.city_name = 'Hyderabad' THEN '2. Hyderabad'
            WHEN cd.city_name = 'Gurgaon' THEN '3. NCR'
            WHEN cd.city_name IN ('Mumbai', 'Navi_Mumbai_and_Thane') THEN '4. Mumbai'
            WHEN cd.city_name = 'Pune' THEN '5. Pune'
            WHEN cd.city_name = 'Chennai' THEN '6. Chennai'
            ELSE '7. Others'
        END,
        DATE_TRUNC('quarter', bf.attendance_time)
)

SELECT 
    bt."City",
    CONCAT(bt.period_type, '-', CAST(CAST(bt.period AS DATE) AS VARCHAR)) AS period,  -- Cast the DATE to VARCHAR for CONCAT
    ROUND(bt.total_rating_value * 1.00 / NULLIF(bt.total_ratings, 0), 2) AS "Product Rating (PR)"
FROM bt_data bt
ORDER BY 
    bt.period_type DESC,
    bt.period,
    CASE
        WHEN bt."City" = '1. Bangalore' THEN 1
        WHEN bt."City" = '2. Hyderabad' THEN 2
        WHEN bt."City" = '3. NCR' THEN 3
        WHEN bt."City" = '4. Mumbai' THEN 4
        WHEN bt."City" = '5. Pune' THEN 5
        WHEN bt."City" = '6. Chennai' THEN 6
        ELSE 7
    END
