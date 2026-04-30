SELECT month,
       CASE WHEN "type" IS NOT NULL THEN "type" ELSE activitytype END activitytype,
       COUNT(DISTINCT userid) users,
       avg(days) days
       
FROM(
select DATE_TRUNC('month',date(ac.createddate_date)) month,
        activitytype,
       "type",
        userid,
       COUNT(*)/COUNT(distinct CASE WHEN activitytype IN ('SLEEP','WALK') THEN DATE(cast(date as timestamp)) else createddate_date END) value,
       COUNT(*),
       COUNT(distinct CASE WHEN activitytype IN ('SLEEP','WALK') THEN DATE(cast(date as timestamp)) else createddate_date END) days

FROM pk_prod_curefit_prod.activitystores ac

left JOIN  pk_prod_curefit_prod.activitystores_meta_healthmetric ashm on ashm.root_ref_id = ac._id and date(ashm.root_createddate_date) = date(ac.createddate_date) and date(ashm.root_createddate_date) >= DATE('2025-01-01')
LEFT JOIN pk_prod_curefit_prod.activitystores_meta_healthmetric_healthmetricinstance ashmi ON ashmi.root_ref_id = ac._id and ashmi.parent_array_index = ashm.array_index and date(ashm.root_createddate_date) = date(ashmi.root_createddate_date) and date(ashmi.root_createddate_date) >= DATE('2025-01-01')
where activitytype IN ('WALK','SLEEP','CALORIES_BURNT','HEART_RATE','HEART_RATE_VARIABILITY','HEALTH_METRIC_TIME_SERIES','RESTING_HEART_RATE') 
and (date IS NOT NULL OR value IS NOT NULL)
and date(ac.createddate_date) BETWEEN {{start}} AND {{end}}
GROUP BY 1,2,3,4
)
GROUP BY 1,2
