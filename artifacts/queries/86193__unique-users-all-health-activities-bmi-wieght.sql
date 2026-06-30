WITH bca_users AS (
    SELECT DISTINCT ua.user_id AS user_id
    FROM pk_cultprod_user_fitness.user_assessment ua
    LEFT JOIN pk_cultprod_user_fitness.user_stage usg
        ON ua.id = usg.user_assessment_id
       AND usg.created_on_date BETWEEN [[{{Start}} --]] DATE('2024-01-01')
                                   AND [[{{end}} --]] CURRENT_DATE
       AND usg.created_on_hour > 0
    LEFT JOIN pk_cultprod_user_fitness.user_step us
        ON ua.id = us.user_assessment_id
       AND usg.id = us.user_stage_id
       AND us.created_on_date BETWEEN [[{{Start}} --]] DATE('2024-01-01')
                                  AND [[{{end}} --]] CURRENT_DATE
       AND us.created_on_hour > 0
    LEFT JOIN pk_cultprod_user_fitness.step step
        ON step.id = us.step_id
    LEFT JOIN pk_cultprod_user_fitness.stage stage
        ON stage.id = usg.stage_id
    WHERE ua.status = 'COMPLETED'
      AND ua.created_on_date BETWEEN [[{{Start}} --]] DATE('2024-01-01')
                                 AND [[{{end}} --]] CURRENT_DATE
      AND ua.created_on_hour > 0
      AND step.name = 'BODY_FAT'
      AND stage.name IN ('BCA', 'INBODY_BCA')
),

activity_users AS (
    SELECT DISTINCT userid AS user_id
    FROM pk_prod_curefit_prod.activitystores ac
    WHERE activitytype IN (
        'WALK',
        'SLEEP',
        'CALORIES_BURNT',
        'HEART_RATE',
        'HEART_RATE_VARIABILITY',
        'HEALTH_METRIC_TIME_SERIES',
        'RESTING_HEART_RATE'
    )
      AND DATE(ac.createddate_date) BETWEEN [[{{Start}} --]] DATE('2024-01-01')
                                        AND [[{{end}} --]] CURRENT_DATE
),


bmi as
(

SELECT * FROM (
SELECT DISTINCT date(user_metric.metric_date) metric_date,
       name,
       user_id,
       value,
       unit,
       ROW_NUMBER() OVER(partition BY user_id,DATE(metric_date) ORDER BY metric_date desc) rk

FROM pk_curefitprod_metric_service.user_metric user_metric
JOIN pk_curefitprod_metric_service.metric metric ON metric_id = metric.id
WHERE  date(user_metric.metric_date)   BETWEEN [[{{Start}} --]] DATE('2024-01-01')
                                        AND [[{{end}} --]] CURRENT_DATE
AND  date(user_metric.created_at_date)   BETWEEN [[{{Start}} --]] DATE('2024-01-01')
                                        AND [[{{end}} --]] CURRENT_DATE

and metric_id IN (1)
and is_self = 1
)
where rk = 1
),

weight as
(

SELECT * FROM (
SELECT DISTINCT date(user_metric.metric_date) metric_date,
       name,
       user_id,
       value,
       unit,
       ROW_NUMBER() OVER(partition BY user_id,DATE(metric_date) ORDER BY metric_date desc) rk

FROM pk_curefitprod_metric_service.user_metric user_metric
JOIN pk_curefitprod_metric_service.metric metric ON metric_id = metric.id
WHERE  date(user_metric.metric_date)   BETWEEN [[{{Start}} --]] DATE('2024-01-01')
                                        AND [[{{end}} --]] CURRENT_DATE
AND  date(user_metric.created_at_date)   BETWEEN [[{{Start}} --]] DATE('2024-01-01')
                                        AND [[{{end}} --]] CURRENT_DATE
and metric_id IN (3)
and is_self = 1
)
where rk = 1
)


SELECT
        -- Commented for future usecase
            -- COUNT(DISTINCT CASE WHEN source = 'bca' THEN user_id END) AS bca_users,
            -- COUNT(DISTINCT CASE WHEN source = 'activity' THEN user_id END) AS activity_users,
            -- COUNT(DISTINCT CASE WHEN source = 'weight' THEN user_id END) AS weight_users,
            -- COUNT(DISTINCT CASE WHEN source = 'bmi' THEN user_id END) AS bmi_users,
    COUNT(DISTINCT user_id) AS total_unique_users

FROM (
    SELECT user_id, 'bca' AS source FROM bca_users
    UNION ALL
    SELECT user_id, 'activity' AS source FROM activity_users
    UNION ALL
    SELECT user_id, 'weight' AS source FROM weight
    UNION ALL
    SELECT user_id, 'bmi' AS source FROM bmi
) t
