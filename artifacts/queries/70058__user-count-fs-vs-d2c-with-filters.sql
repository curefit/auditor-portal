WITH booking_fact AS 
(
    SELECT user_id, MAX_BY(center_key, total_class) AS center_key
    FROM 
    (
        SELECT user_id, center_key, COUNT(DISTINCT class_date) AS total_class
        FROM dwh_fitness_mart.booking_fact
        WHERE attendance_time IS NOT NULL 
        AND class_date IS NOt NULL 
        GROUP BY 1, 2
    )
    GROUP BY 1
),

center_dim AS 
(
    SELECT center_key, city_name 
    FROM 
    dwh_fitness_mart.center_dim
),

user_city_mapped AS 
(
    SELECT user_id, city_name
    FROM booking_fact bf 
    LEFT JOIN center_dim cd ON bf.center_key = cd.center_key
),

city_filtered AS 
(
    SELECT user_id
    FROM user_city_mapped
    WHERE city_name IN (SELECT city_name FROM dwh_fitness_mart.center_dim WHERE {{city_name}})
),

dev_users AS 
(
  SELECT DISTINCT user_id
  FROM gs_d2c.default.cs_dev_users
),

active_pack AS 
(
  SELECT DISTINCT c.user_id
  FROM dwh_fitness_metrics.fs_cohorts c
  WHERE c.active_vs_expired = 'Active'
    AND c.month >= DATE('2018-01-01')
    [[AND c.month BETWEEN DATE_TRUNC('month', {{active_start_date}}) AND DATE_TRUNC('month', {{active_end_date}})]]
),

current_month_data AS 
(
  SELECT user_id
  FROM dwh_fitness_metrics.fs_cohorts 
  WHERE month = DATE_TRUNC('month', CURRENT_DATE)
    AND user_id NOT IN (SELECT user_id FROM dev_users)
    AND ( {{consider_city}} = 0 OR user_id IN (SELECT user_id FROM city_filtered) )
    [[AND {{current_month_active_vs_expired}}]]
),

user_details AS 
(
  SELECT DISTINCT user_id
  FROM dwh_fitness_metrics.fs_cohorts 
  WHERE user_id IN (SELECT user_id FROM current_month_data)
    AND month >= DATE('2018-01-01')
    AND ( {{consider_active_time}} = 0 OR user_id IN (SELECT user_id FROM active_pack) )
    [[AND first_membership_created_date >= {{first_membership_created_start_date}}]]
    [[AND first_membership_created_date <= {{first_membership_created_end_date}}]]
    [[AND membership_created_date       >= {{membership_created_start_date}}]]
    [[AND membership_created_date       <= {{membership_created_end_date}}]]
    [[AND {{business_line}}]]
),

cross_sell_orders AS 
(
  SELECT DISTINCT user_id
  FROM dwh_fitness_metrics.cross_sell_orders 
  WHERE order_date >= DATE('2018-01-01')
  [[AND {{category}}]]
  [[AND {{purchase_time_cohort}}]]
  [[AND order_date >= {{order_start_date}} ]]
  [[AND order_date <= {{order_end_date}}]]
  [[AND {{is_freebie}}]]
)

SELECT 'D2C (BUYERS)' AS source,
       COUNT(DISTINCT u.user_id) AS user_count
FROM user_details u
WHERE EXISTS (SELECT 1 FROM cross_sell_orders x WHERE x.user_id = u.user_id)
 
UNION ALL

SELECT 'FITNESS-SERVICE (NON-BUYERS)' AS source,
       COUNT(DISTINCT u.user_id) AS user_count
FROM user_details u
WHERE NOT EXISTS (SELECT 1 FROM cross_sell_orders x WHERE x.user_id = u.user_id)
