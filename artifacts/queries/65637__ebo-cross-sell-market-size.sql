WITH center_dim AS 
(
    SELECT center_key, locality, center_name, latitude, longitude
    FROM 
    dwh_fitness_mart.center_dim
    WHERE LOWER(center_name) NOT LIKE '%sport%'
        AND LOWER(center_name) NOT LIKE '%store%'
        AND center_type <> 'BREAKAGE'
        AND center_type <> 'SPORTS'
),

ebo_store AS 
(
    SELECT store_name, CAST(latitude AS DOUBLE) AS latitude, CAST(longitude AS DOUBLE) AS longitude
    FROM gs_d2c.default.ebo_store_location
),

fs_cohorts AS 
(
    SELECT *
    FROM 
    dwh_fitness_metrics.fs_cohorts
    WHERE 1 = 1
    [[AND month >= DATE_TRUNC('MONTH',{{Fs_start_date}})]]
    AND month >= DATE('2018-01-01')
),

membership_dim AS 
(
    SELECT attributed_center_key, user_id
    FROM 
    (
        SELECT attributed_center_key, user_id, ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY membership_created_time DESC, membership_key DESC) AS rnk
        FROM 
        dwh_fitness_mart.membership_dim
        WHERE business_line IN ('PRO','ELITE')
              AND membership_created_date < CURRENT_DATE - INTERVAL '1' DAY
              AND CASE 
                    WHEN {{is_lifetime}} = 1 THEN TRUE
                    [[ELSE user_id IN (SELECT DISTINCT user_id FROM fs_cohorts WHERE month BETWEEN DATE_TRUNC('MONTH',{{Fs_start_date}}) AND DATE_TRUNC('MONTH',{{Fs_end_date}}))]]
                  END
    )
    WHERE rnk = 1
),

attributed_users AS 
(
    SELECT attributed_center_key, user_id
    FROM 
    membership_dim
    WHERE attributed_center_key NOT IN (SELECT center_key FROM dwh_fitness_mart.center_dim WHERE center_type = 'BREAKAGE')
    AND attributed_center_key IS NOT NULL
),

non_attributes_users AS 
(
    SELECT user_id
    FROM 
    membership_dim
    WHERE attributed_center_key IN (SELECT center_key FROM dwh_fitness_mart.center_dim WHERE center_type = 'BREAKAGE')
    OR attributed_center_key IS NULL
),

booking_fact AS 
(
  SELECT *, ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY total_class DESC, latest_class_attended DESC) AS rnk 
  FROM 
    (
        SELECT nau.user_id, bf.center_key, COUNT(*) total_class, MAX(attendance_time) AS latest_class_attended
        FROM 
        dwh_fitness_mart.booking_fact bf
        JOIN non_attributes_users nau ON nau.user_id = bf.user_id
        WHERE attendance_time IS NOT NULL 
        AND class_date IS NOT NULL 
        GROUP BY 1,2
    ) t
),

filtered_centers AS 
(
    SELECT cd.center_key, cd.locality, cd.center_name, es.store_name, es.latitude AS ebo_latitude, es.longitude AS ebo_longitude, cd.latitude AS center_latitude, cd.longitude AS center_longitude,
           great_circle_distance(es.latitude, es.longitude, cd.latitude, cd.longitude) AS distance_km,
           ROW_NUMBER() OVER(PARTITION BY center_key ORDER BY great_circle_distance(es.latitude, es.longitude, cd.latitude, cd.longitude)) AS rnk
    FROM 
    center_dim cd
    JOIN ebo_store es ON great_circle_distance(es.latitude, es.longitude, cd.latitude, cd.longitude) <= {{displacement_distance_within}}
),

filtered_booking_fact AS 
(
    SELECT bf.center_key AS attributed_center_key, bf.user_id
    FROM 
    booking_fact bf
    JOIN filtered_centers fc ON fc.center_key = bf.center_key
    WHERE bf.rnk = 1
    GROUP BY 1,2
),

combined_user AS 
(
    SELECT * FROM attributed_users
     
    UNION ALL 
    
    SELECT * FROM filtered_booking_fact
),

fs_cohort_active AS 
(
    SELECT user_id
    FROM 
    fs_cohorts
    WHERE month  = DATE_TRUNC('MONTH',CURRENT_DATE)
    AND CASE 
            WHEN {{is_lifetime}} = 1 THEN cohort LIKE '%Active%' OR cohort LIKE '%MP%' 
            ELSE user_id IN (SELECT DISTINCT user_id FROM fs_cohorts WHERE (cohort LIKE '%Active%' OR cohort LIKE '%MP%')
                                                                            [[AND month BETWEEN DATE_TRUNC('MONTH',{{Fs_start_date}}) AND DATE_TRUNC('MONTH',{{Fs_end_date}})]])
        END
),

fs_cohort_expired AS 
(
    SELECT user_id
    FROM 
    fs_cohorts
    WHERE month  = DATE_TRUNC('MONTH',CURRENT_DATE)
    AND CASE 
            WHEN {{is_lifetime}} = 1 THEN cohort LIKE '%Expired%'
            ELSE user_id NOT IN (SELECT DISTINCT user_id FROM fs_cohorts WHERE (cohort LIKE '%Active%' OR cohort LIKE '%MP%')
                                                                                [[AND month BETWEEN DATE_TRUNC('MONTH',{{Fs_start_date}}) AND DATE_TRUNC('MONTH',{{Fs_end_date}})]])
        END
),

cross_sell_orders AS 
(
    SELECT DISTINCT channel, user_id
    FROM 
    dwh_fitness_metrics.cross_sell_orders 
    WHERE 1 = 1
    [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
    AND order_date > DATE('2018-01-01')
)

,cross_sell_user_gmv AS 
(
    SELECT
        user_id,
        SUM(gmv) AS overall_gmv,
        SUM(CASE WHEN channel = 'EBO' THEN gmv ELSE 0 END) AS ebo_gmv
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE 1=1
      [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
      AND order_date > DATE('2018-01-01')
    GROUP BY 1
)

SELECT fc.store_name, 
        COUNT(DISTINCT cu.user_id) AS fs_user_count,
        COUNT(DISTINCT fsa.user_id) AS active_fs_user_count, COUNT(DISTINCT fse.user_id) AS expired_fs_user_count,
        COUNT(DISTINCT fsa.user_id) * 1.000/COUNT(DISTINCT cu.user_id) AS active_fs_percentage,
        COUNT(DISTINCT cso.user_id) AS overall_ordered_user, COUNT(DISTINCT cso.user_id) * 1.000/COUNT(DISTINCT cu.user_id) AS overall_converted_percentage,
        COUNT(DISTINCT CASE WHEN cso.channel = 'EBO' THEN cso.user_id ELSE NULL END) AS ebo_ordered_user,  COUNT(DISTINCT CASE WHEN cso.channel = 'EBO' THEN cso.user_id ELSE NULL END) * 1.000/COUNT(DISTINCT cu.user_id) AS ebo_converted_percentage,
        COUNT(DISTINCT csoa.user_id) AS active_ordered_user, COUNT(DISTINCT csoa.user_id) * 1.000/COUNT(DISTINCT fsa.user_id) AS active_user_converted_percentage,
        COUNT(DISTINCT csoe.user_id) AS expired_ordered_user, COUNT(DISTINCT csoe.user_id) * 1.000/COUNT(DISTINCT fse.user_id) AS expired_user_converted_percentage,
        COUNT(DISTINCT CASE WHEN csoa.channel = 'EBO' THEN csoa.user_id ELSE NULL END) AS active_ebo_ordered_user,  COUNT(DISTINCT CASE WHEN csoa.channel = 'EBO' THEN csoa.user_id ELSE NULL END) * 1.000/COUNT(DISTINCT cu.user_id) AS active_ebo_converted_percentage,
        COUNT(DISTINCT CASE WHEN csoe.channel = 'EBO' THEN csoe.user_id ELSE NULL END) AS expired_ebo_ordered_user,  COUNT(DISTINCT CASE WHEN csoe.channel = 'EBO' THEN csoe.user_id ELSE NULL END) * 1.000/COUNT(DISTINCT cu.user_id) AS expired_ebo_converted_percentage,
        round(SUM(CASE WHEN fsa.user_id IS NOT NULL THEN COALESCE(csg.overall_gmv,0) ELSE 0 END),0) AS active_overall_gmv,
        round(SUM(CASE WHEN fse.user_id IS NOT NULL THEN COALESCE(csg.overall_gmv,0) ELSE 0 END),0) AS expired_overall_gmv,
        round(SUM(CASE WHEN fsa.user_id IS NOT NULL THEN COALESCE(csg.ebo_gmv,0) ELSE 0 END),0)     AS active_ebo_gmv,
        round(SUM(CASE WHEN fse.user_id IS NOT NULL THEN COALESCE(csg.ebo_gmv,0) ELSE 0 END),0)     AS expired_ebo_gmv,
        ARRAY_AGG(DISTINCT fc.center_key) AS filtered_center_key,
        ARRAY_AGG(DISTINCT fc.center_name) AS filtered_center_name,
        COUNT(DISTINCT fc.center_key) AS total_filtered_centers
FROM
filtered_centers fc
LEFT JOIN combined_user cu ON fc.center_key = cu.attributed_center_key
LEFT JOIN cross_sell_orders cso ON cu.user_id = cso.user_id
LEFT JOIN fs_cohort_active fsa ON cu.user_id = fsa.user_id
LEFT JOIN fs_cohort_expired fse ON cu.user_id = fse.user_id
LEFT JOIN cross_sell_orders csoa ON fsa.user_id = csoa.user_id
LEFT JOIN cross_sell_orders csoe ON fse.user_id = csoe.user_id
LEFT JOIN cross_sell_user_gmv csg ON cu.user_id = csg.user_id
WHERE fc.rnk = 1
GROUP BY 1   
ORDER BY 2 DESC
