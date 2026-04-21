WITH freebie_data AS (
    SELECT *
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE order_date >= DATE('2018-01-01')
    [[AND order_date BETWEEN {{order_start_date}} AND {{order_end_date}}]]
    AND {{coupon_code}}
    AND {{is_freebie_order}}
),

freebie_user_date AS 
(   
    SELECT user_id AS min_user_id, MIN(order_timestamp) AS min_order_timestamp
    FROM 
    freebie_data
    GROUP BY 1
),

order_data_freebie_users AS (
    SELECT *
    FROM dwh_fitness_metrics.cross_sell_orders nc
    JOIN freebie_user_date fbd ON nc.user_id = fbd.min_user_id
         AND nc.order_timestamp > fbd.min_order_timestamp
    WHERE order_date > DATE('2018-01-01')
),

shopify_event_data AS
(
    SELECT event_userid AS event_userid, event_eventparams_weborigin AS event_source, ts_date AS event_date, event_eventparams_pagecategory, event_eventparams_csproductid
    FROM pk_d2c_cultstore.PAGE_VIEW pv
    JOIN freebie_user_date fbd ON pv.event_userid = fbd.min_user_id
         AND DATE(pv.ts_date) > DATE(fbd.min_order_timestamp)
    WHERE pv.ts_date > DATE('2018-01-01')
),

shopify_home_page_view AS
(   
    SELECT DISTINCT event_userid 
    FROM shopify_event_data
    WHERE event_eventparams_pagecategory = 'homepage'
),

shopify_plp_page_view AS
(
    SELECT DISTINCT event_userid 
    FROM shopify_event_data sd
    WHERE event_eventparams_pagecategory = 'collection page'
),

shopify_pdp_page_view AS 
(
    SELECT DISTINCT event_userid
    FROM shopify_event_data sd
    WHERE event_eventparams_pagecategory = 'product page' 
),

shopify_atc AS 
(
  SELECT DISTINCT event_userid
  FROM pk_d2c_cultstore.atc atc
  JOIN freebie_user_date fbd ON atc.event_userid = fbd.min_user_id
         AND DATE(atc.ts_date) > DATE(fbd.min_order_timestamp)
   WHERE atc.ts_date > DATE('2018-01-01')
),

shopify_checkout AS 
(
  SELECT DISTINCT event_userid
  FROM pk_d2c_cultstore.checkout_clicked ic
  JOIN freebie_user_date fbd ON ic.event_userid = fbd.min_user_id
         AND DATE(ic.ts_date) > DATE(fbd.min_order_timestamp)
  WHERE ic.ts_date > DATE('2018-01-01')
),

custom_event_data AS
(   
    SELECT user_userid AS event_userid, ts_date AS event_date, event_eventparams_weborigin AS event_source, event_eventparams_page_category, event_eventparams_productid
    FROM  pk_curefit_app_events.web_cultsport_page_view wcpv
    JOIN freebie_user_date fbd ON wcpv.user_userid = fbd.min_user_id
         AND DATE(wcpv.ts_date) > DATE(fbd.min_order_timestamp)
    WHERE wcpv.ts_date > DATE('2018-01-01')
),

custom_home_page_view AS
(
    SELECT DISTINCT event_userid 
    FROM custom_event_data
    WHERE event_eventparams_page_category = 'HOME'
),

custom_plp_page_view AS
(
    SELECT DISTINCT event_userid
    FROM custom_event_data ce
    WHERE event_eventparams_page_category = 'PLP'
),

custom_pdp_page_view AS
(
    SELECT DISTINCT event_userid
    FROM custom_event_data ce
    WHERE event_eventparams_page_category = 'PDP'
),

custom_atc AS 
(
    SELECT DISTINCT user_userid AS event_userid
    FROM "pk_cultsport_app_events"."web_cultsport_gearaddtocartclicked" wcatc
    JOIN freebie_user_date fbd ON wcatc.user_userid = fbd.min_user_id
         AND DATE(wcatc.ts_date) > DATE(fbd.min_order_timestamp)
    WHERE wcatc.ts_date > DATE('2018-01-01')
),

custom_checkout AS 
(
    SELECT userid AS event_userid
    FROM  pk_cultsport_app_events_backend.cultsportcartcheckoutitem_backend wcchc
    JOIN freebie_user_date fbd ON wcchc.userid = fbd.min_user_id
         AND DATE(wcchc.event_time) > DATE(fbd.min_order_timestamp)
    WHERE wcchc.event_time_date > DATE('2018-01-01')
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

)


SELECT 'FreeBie People' AS category, COUNT(DISTINCT user_id) AS user_count
FROM freebie_data

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
FROM order_data_freebie_users
WHERE is_freebie_order = 0
