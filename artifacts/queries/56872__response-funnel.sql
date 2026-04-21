WITH response_data AS (
    SELECT 
        'GYM + GX + SPORTS' AS "Service Type",  -- Aggregated service type
        DATE_TRUNC('month', bf.attendance_time) AS month,
        
        -- Total Footfalls
        COUNT(CASE WHEN bf.attendance_time IS NOT NULL THEN bf.booking_key END) AS total_ff, 
        
        -- Total Responses (AGBT: Rating value 1, 2, 3, 4)
        COUNT(CASE WHEN bf.attendance_time IS NOT NULL AND bf.rating_value IS NOT NULL THEN bf.booking_key END) AS total_rating,
        
        -- BT Responses (Rating value 1, 2)
        COUNT(CASE WHEN bf.attendance_time IS NOT NULL AND bf.rating_value IN (1, 2) THEN bf.booking_key END) AS bt_responses,
        
        -- Verbatim Submissions (Users who provided reviews)
        COUNT(CASE WHEN bf.review IS NOT NULL AND bf.review <> '' THEN bf.booking_key END) AS verbatim_count
    FROM 
        dwh_fitness_mart.booking_fact bf
    JOIN 
        (SELECT * 
         FROM dwh_fitness_mart.center_dim 
         WHERE 1=1
           [[AND {{city_name}}]]
           [[AND {{center_service_id}}]]
           [[AND {{service_type}}]]
           [[AND {{ownership_type}}]]
           [[AND {{business_line}}]]
           [[AND {{center_name}}]]
        ) cd ON bf.center_key = cd.center_key
    WHERE 
        bf.attendance_time BETWEEN {{report_start_date}} AND {{report_end_date}}
        AND bf.attendance_time IS NOT NULL
        AND bf.class_date >= DATE('2022-01-01')
        AND cd.center_type IN ('GYM', 'GX', 'SPORTS')
    GROUP BY 
        DATE_TRUNC('month', bf.attendance_time)  -- Ensure proper grouping
)
SELECT 
    CONCAT('M-', CAST(month AS VARCHAR)) AS "Month", -- Format for month
    total_ff AS "Total Footfalls",
    total_rating AS "Total Ratings (AGBT)",
    bt_responses AS "BT Responses",
    -- CONCAT(
    --     CAST(ROUND((bt_responses * 100.0) / NULLIF(total_rating, 0), 2) AS VARCHAR), '%'
    -- ) AS "BT %",
    format('%.2f%%', coalesce(round(100.0 * bt_responses / nullif(total_rating, 0), 2), 0.0)) as "BT %",
    verbatim_count AS "Verbatim Count",
    -- CONCAT(
    --     CAST(ROUND((total_rating * 100.0) / NULLIF(total_ff, 0), 2) AS VARCHAR), '%'
    -- ) AS "Response Rate (%)" 
    format('%.2f%%', coalesce(round(100.0 * total_rating / nullif(total_ff, 0), 2), 0.0)) as "Response Rate (%)"
FROM response_data
ORDER BY 
    "Month" ASC
