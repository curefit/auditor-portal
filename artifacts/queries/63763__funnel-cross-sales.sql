WITH user_details AS 
(
    SELECT month, cohort, membership_created_date, first_membership_created_date, user_id
    FROM 
    dwh_fitness_metrics.fs_cohorts
     WHERE 1 = 1
    [[AND first_membership_created_date >= {{first_membership_created_start_date}}]]
    [[AND first_membership_created_date <= {{first_membership_created_end_date}}]]
    AND month = DATE_TRUNC('MONTH',CURRENT_DATE)
    AND user_id NOT IN (SELECT user_id FROM gs_d2c.default.cs_dev_users)
),

shopify_event_data AS
(
    SELECT event_userid AS event_userid, event_eventparams_weborigin AS event_source, ts_date AS event_date, event_eventparams_pagecategory, event_eventparams_csproductid
    FROM pk_d2c_cultstore.PAGE_VIEW
    WHERE event_userid IN (SELECT DISTINCT user_id FROM user_details)
    AND ts_date > DATE('2024-01-01')
),

shopify_home_page_view AS
(   
    SELECT event_userid 
    FROM shopify_event_data
    WHERE event_eventparams_pagecategory = 'homepage'
),

shopify_plp_page_view AS
(
    SELECT event_userid 
    FROM shopify_event_data sd
    WHERE event_eventparams_pagecategory = 'collection page'
),

shopify_pdp_page_view AS 
(
    SELECT event_userid
    FROM shopify_event_data sd
    WHERE event_eventparams_pagecategory = 'product page' 
),

shopify_atc AS 
(
  SELECT event_userid
  FROM pk_d2c_cultstore.atc
  WHERE event_userid IN (SELECT DISTINCT user_id FROM user_details)
  AND ts_date > {{first_membership_created_start_date}}
),

shopify_checkout AS 
(
  SELECT event_userid
  FROM pk_d2c_cultstore.checkout_clicked
  WHERE event_userid IN (SELECT DISTINCT user_id FROM user_details)
  AND ts_date > {{first_membership_created_start_date}}
),

custom_event_data AS
(   
    SELECT user_userid AS event_userid, ts_date AS event_date, event_eventparams_weborigin AS event_source, event_eventparams_page_category, event_eventparams_productid
    FROM  pk_curefit_app_events.web_cultsport_page_view
    WHERE user_userid IN (SELECT DISTINCT user_id FROM user_details)
    AND ts_date > {{first_membership_created_start_date}}
),

custom_home_page_view AS
(
    SELECT event_userid 
    FROM custom_event_data
    WHERE event_eventparams_page_category = 'HOME'
),

custom_plp_page_view AS
(
    SELECT event_userid
    FROM custom_event_data ce
    WHERE event_eventparams_page_category = 'PLP'
),

custom_pdp_page_view AS
(
    SELECT event_userid
    FROM custom_event_data ce
    WHERE event_eventparams_page_category = 'PDP'
),

custom_atc AS 
(
    SELECT user_userid AS event_userid
    FROM "pk_cultsport_app_events"."web_cultsport_gearaddtocartclicked"
    WHERE user_userid IN (SELECT DISTINCT user_id FROM user_details)
    AND ts_date > {{first_membership_created_start_date}}
),

custom_checkout AS 
(
    SELECT userid AS event_userid
    FROM  pk_cultsport_app_events_backend.cultsportcartcheckoutitem_backend
    WHERE userid IN (SELECT DISTINCT user_id FROM user_details)
    AND event_time_date > {{first_membership_created_start_date}}
),

home_page_view_combined AS 
(
    SELECT * FROM shopify_home_page_view
    
    UNION ALL
    
    SELECT * FROM custom_home_page_view
),

plp_page_view_combined AS 
(
    SELECT * FROM shopify_plp_page_view
    
    UNION ALL
    
    SELECT * FROM custom_plp_page_view
),

pdp_page_view_combined AS 
(
    SELECT * FROM shopify_pdp_page_view
    
    UNION ALL
    
    SELECT * FROM custom_pdp_page_view
),

atc_combined AS 
(
    SELECT * FROM shopify_atc
    
    UNION ALL 
    
    SELECT * FROM custom_atc
),

checkout_combined AS 
(
    SELECT * FROM shopify_checkout
    
    UNION ALL 
    
    SELECT * FROM custom_checkout
),

order_data AS
(
    SELECT * FROM dwh_fitness_metrics.cross_sell_orders
    WHERE user_id IN (SELECT DISTINCT user_id FROM user_details)
          [[ AND {{category}} ]]
          [[ AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}} ]]
          AND order_date IS NOT NULL 
          AND CASE 
                WHEN {{include_ebo}} = 0 THEN source <> 'EBO'
                ELSE TRUE 
             END
          AND CASE 
                WHEN {{include_freebie}} = 1 THEN TRUE
                ELSE is_freebie_order = 0 
              END 
)

SELECT 'Fitness People' AS category, COUNT(DISTINCT user_id) AS user_count
FROM user_details

UNION ALL

SELECT 'Home Page View' AS category, COUNT(DISTINCT event_userid) AS user_count
FROM home_page_view_combined

UNION ALL

SELECT 'Plp Page View' AS category, COUNT(DISTINCT event_userid) AS user_count
FROM plp_page_view_combined

UNION ALL

SELECT 'Pdp Page View' AS category, COUNT(DISTINCT event_userid) AS user_count
FROM pdp_page_view_combined

UNION ALL

SELECT 'ATC' AS category, COUNT(DISTINCT event_userid) AS user_count
FROM atc_combined

UNION ALL 

SELECT 'Checkout Clicked' AS category, COUNT(DISTINCT event_userid) AS user_count
FROM checkout_combined

UNION ALL

SELECT 'Orders' AS category, COUNT(DISTINCT user_id) AS user_count
FROM order_data

--27116
