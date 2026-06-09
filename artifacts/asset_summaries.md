# KPI Dependency and Evidence Summary

## PR DASHBOARD (`dashboard` 3324)

- Source rows: `14`
- Source URL: `https://metabase.curefit.co/dashboard/3324-pr-dashboard?business_line=&center_name=&center_service_id=&city_name=&ownership_type=&report_end_date=2025-12-31&report_start_date=2022-04-01&service_type=`
- Direct cards: `9`
- Nested cards: `0`
- Tables: `2`
- Upstream core objects: `2`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

### Dependency Tree

- Card `56424` `PR BY PRODUCT` (role: `dashboard_card`, parent: `root`)
- Card `56862` `PR BY CITY` (role: `dashboard_card`, parent: `root`)
- Card `56863` `PR BY OWNERSHIP TYPE` (role: `dashboard_card`, parent: `root`)
- Card `56865` `PR BY PRODUCT x CITY` (role: `dashboard_card`, parent: `root`)
- Card `56866` `PR BY PRODUCT x OWNERSHIP TYPE` (role: `dashboard_card`, parent: `root`)
- Card `56867` `PR BY PRODUCT x OWNERSHIP TYPE x CITY` (role: `dashboard_card`, parent: `root`)
- Card `56868` `PR BY CENTER` (role: `dashboard_card`, parent: `root`)
- Card `56869` `PR SERVICE TYPE WEEK TREND LINE` (role: `dashboard_card`, parent: `root`)
- Card `56872` `RESPONSE FUNNEL` (role: `dashboard_card`, parent: `root`)

### Table Dependencies

- `cte` `bt_data` via card `56424` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `bt_data` via card `56862` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `bt_data` via card `56863` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `bt_data` via card `56865` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `bt_data` via card `56866` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `bt_data` via card `56867` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `bt_data` via card `56868` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `bt_data` via card `56869` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `pivoted_data` via card `56869` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `response_data` via card `56872` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_mart.booking_fact` via card `56424` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.booking_fact` via card `56862` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.booking_fact` via card `56863` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.booking_fact` via card `56865` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.booking_fact` via card `56866` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.booking_fact` via card `56867` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.booking_fact` via card `56868` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.booking_fact` via card `56869` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.booking_fact` via card `56872` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.center_dim` via card `56424` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.center_dim` via card `56862` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.center_dim` via card `56863` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.center_dim` via card `56865` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.center_dim` via card `56866` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.center_dim` via card `56867` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.center_dim` via card `56868` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.center_dim` via card `56869` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.center_dim` via card `56872` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`

## Cross Sell Dashboard (`dashboard` 3604)

- Source rows: `25`
- Source URL: `https://metabase.curefit.co/dashboard/3604-cross-sell-dashboard?active_end_date=2026-01-31&active_start_date=2025-04-01&business_line=&category=Indoor+Equipment&category=Indoor_Equipment-Strength&cohort=&compare_with_current_date=1&compare_with_current_month=1&consider_active_time=1&consider_city=0&coupon_code=&current_month_active_vs_expired=&current_month_trend=1&date_filter=Month&date_of_month_end_date=&date_of_month_start_date=&first_membership_created_end_date=&first_membership_created_start_date=&is_freebie_order=1&is_fs_member=1&membership_created_end_date=&membership_created_start_date=&month_end_date=&month_start_date=&no_of_month=2&order_end_date=2026-01-31&order_start_date=2026-01-01&service_type=&source=&store_name=&tab=207-visualization&twelve_month_trend=1`
- Direct cards: `66`
- Nested cards: `0`
- Tables: `13`
- Upstream core objects: `53`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html || query_sql|metadata_json|result_blocked`
- Notes: Relation not found in local dbt manifest.

### Dependency Tree

- Card `63726` `Source Wise Cross Sales` (role: `dashboard_card`, parent: `root`)
- Card `63727` `Service_Type  Wise Cross Sales` (role: `dashboard_card`, parent: `root`)
- Card `63729` `State Wise Cross Sell` (role: `dashboard_card`, parent: `root`)
- Card `63731` `Service_Type_Category  Wise Cross Sell` (role: `dashboard_card`, parent: `root`)
- Card `63733` `New VS Repeat GMV  Summary  – Last 12 Months` (role: `dashboard_card`, parent: `root`)
- Card `63734` `Source_Cohort_Category Wise Cross Sell` (role: `dashboard_card`, parent: `root`)
- Card `63735` `New VS Repeat GMV  Summary` (role: `dashboard_card`, parent: `root`)
- Card `63738` `Cohort  Wise Cross Sales` (role: `dashboard_card`, parent: `root`)
- Card `63743` `Gender Wise Cross Sell` (role: `dashboard_card`, parent: `root`)
- Card `63745` `Category Wise Cross Sell VS D2C` (role: `dashboard_card`, parent: `root`)
- Card `63746` `Gender_Age_Category Wise Cross Sell` (role: `dashboard_card`, parent: `root`)
- Card `63748` `Cohort__Service_Type_Category Wise Cross Sales` (role: `dashboard_card`, parent: `root`)
- Card `63750` `Cohort_Service_Type  Wise Cross Sales` (role: `dashboard_card`, parent: `root`)
- Card `63751` `Age Wise Cross Sell` (role: `dashboard_card`, parent: `root`)
- Card `63753` `Cross-Sell VS D2C Trend – Last 12 Months` (role: `dashboard_card`, parent: `root`)
- Card `63754` `Cohort__Category Wise Cross Sales` (role: `dashboard_card`, parent: `root`)
- Card `63759` `Top Performing Products In Each Category Date Wise` (role: `dashboard_card`, parent: `root`)
- Card `63760` `New VS Repeat  No Of Orders  Summary  – Last 12 Months` (role: `dashboard_card`, parent: `root`)
- Card `63761` `Gender_Age Wise Cross Sell` (role: `dashboard_card`, parent: `root`)
- Card `63763` `Funnel Cross Sales` (role: `dashboard_card`, parent: `root`)
- Card `63767` `Top Performing Products In Each Category` (role: `dashboard_card`, parent: `root`)
- Card `63774` `Gender_Category Wise Cross Sell` (role: `dashboard_card`, parent: `root`)
- Card `63780` `Day_Cohort_Category Wise Cross Sales` (role: `dashboard_card`, parent: `root`)
- Card `63781` `City Wise Cross Sell` (role: `dashboard_card`, parent: `root`)
- Card `63786` `Category Wise Cross Sales` (role: `dashboard_card`, parent: `root`)
- Card `63788` `Age_Category Wise Cross Sell` (role: `dashboard_card`, parent: `root`)
- Card `63791` `New VS Repeat  No Of Orders  Summary` (role: `dashboard_card`, parent: `root`)
- Card `63795` `Quarter Wise Cross Sell User Count` (role: `dashboard_card`, parent: `root`)
- Card `64117` `EBO Cross Sell - Month_Store Wise` (role: `dashboard_card`, parent: `root`)
- Card `64443` `Current Month Day Wise Cross Sell VS D2C` (role: `dashboard_card`, parent: `root`)
- Card `65122` `EBO Cross Sell - Month_Store_Category Wise` (role: `dashboard_card`, parent: `root`)
- Card `65123` `EBO Cross Sell - Store_Category Wise` (role: `dashboard_card`, parent: `root`)
- Card `65124` `EBO Cross Sell - Store Wise` (role: `dashboard_card`, parent: `root`)
- Card `65138` `EBO Cross Sell - Cohort Wise` (role: `dashboard_card`, parent: `root`)
- Card `65159` `EBO Cross Sell - Majority Service Wise` (role: `dashboard_card`, parent: `root`)
- Card `65195` `EBO - Cross Sell VS D2C` (role: `dashboard_card`, parent: `root`)
- Card `65196` `EBO - Category Wise Cross Sell VS D2C` (role: `dashboard_card`, parent: `root`)
- Card `65198` `EBO Cross Sell - Category Wise` (role: `dashboard_card`, parent: `root`)
- Card `65202` `EBO - Cross-Sell Trend – Last 12 Months` (role: `dashboard_card`, parent: `root`)
- Card `65204` `Cross Sell VS D2C` (role: `dashboard_card`, parent: `root`)
- Card `65637` `EBO -  Cross Sell Market Size` (role: `dashboard_card`, parent: `root`)
- Card `66102` `Source Wise Cross Sell VS D2C` (role: `dashboard_card`, parent: `root`)
- Card `66114` `Active VS Expired GMV  Summary` (role: `dashboard_card`, parent: `root`)
- Card `66134` `Active VS Expired GMV  Summary  – Last 12 Months` (role: `dashboard_card`, parent: `root`)
- Card `68048` `Cohort wise comparison` (role: `dashboard_card`, parent: `root`)
- Card `68050` `Platform wise comparison` (role: `dashboard_card`, parent: `root`)
- Card `68051` `Source wise comparison` (role: `dashboard_card`, parent: `root`)
- Card `68052` `Category wise comparison` (role: `dashboard_card`, parent: `root`)
- Card `68056` `Article Type wise comparison` (role: `dashboard_card`, parent: `root`)
- Card `68058` `Majority Service Type wise comparison` (role: `dashboard_card`, parent: `root`)
- Card `68059` `Month Wise Revenue Comparison` (role: `dashboard_card`, parent: `root`)
- Card `68061` `Month Wise Membership Purchase Count` (role: `dashboard_card`, parent: `root`)
- Card `68064` `First Membership Purchase Count` (role: `dashboard_card`, parent: `root`)
- Card `68065` `First Membership Purchase Cohort Wise Count` (role: `dashboard_card`, parent: `root`)
- Card `68066` `Membership Purchase Cohort Wise Count` (role: `dashboard_card`, parent: `root`)
- Card `70058` `User Count FS VS D2C With Filters` (role: `dashboard_card`, parent: `root`)
- Card `70149` `EBO - Store Wise Cross Sell VS D2C` (role: `dashboard_card`, parent: `root`)
- Card `71753` `No of users who used coupons` (role: `dashboard_card`, parent: `root`)
- Card `71754` `Repeat Count` (role: `dashboard_card`, parent: `root`)
- Card `72319` `No Of People Who Have Purchased Before Coupons` (role: `dashboard_card`, parent: `root`)
- Card `72323` `No Of People Who Have Purchased another Item With Coupon` (role: `dashboard_card`, parent: `root`)
- Card `72328` `Coupon Article Type Wise User Count` (role: `dashboard_card`, parent: `root`)
- Card `72382` `Repeat Purchase Category User Count` (role: `dashboard_card`, parent: `root`)
- Card `72383` `Coupon Article_Type Repeat Purchase_Category User Count With Average Values` (role: `dashboard_card`, parent: `root`)
- Card `72384` `Coupon Article_Type Repeat Category  Month Wise User Count` (role: `dashboard_card`, parent: `root`)
- Card `72385` `Coupon Repeat Funnel` (role: `dashboard_card`, parent: `root`)

### Table Dependencies

- `cte` `active_pack` via card `70058` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `age_calculated` via card `63761` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `age_calculated` via card `63746` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `age_calculated` via card `63788` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `age_calculated` via card `63751` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `atc_combined` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `atc_combined` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `attributed_users` via card `65637` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `booking_fact` via card `65637` (lineage: `derived_model_name_match`)
  Upstream core objects: `dwh_fitness_mart.customer_sentiment|pk_cfuserservice_cultapp.user|pk_cultprod_cultapp.attendance|pk_cultprod_cultapp.booking|pk_cultprod_cultapp.city|pk_cultprod_cultapp.cultclass|pk_cultprod_cultapp.cultemployee|pk_cultprod_cultapp.membership|pk_cultprod_cultapp.trainercultclassmap|pk_cultprod_cultapp.waitlist|pk_cultprod_cultapp.workout|pk_cultprod_cultapp.workoutfamilyworkoutmap|pk_curefitprod_center_service.center|pk_curefitprod_gymfit.centerofferings|pk_curefitprod_gymfit.centers|pk_curefitprod_gymfit.checkins|pk_prod_curefit_prod.feedbacks|pk_prod_jogo_jogo_new.all_bookings|pk_prod_jogo_jogo_new.facilities|pk_prod_jogo_jogo_new.facility_sport_mappings|pk_prod_jogo_jogo_new.sports|pk_prod_jogo_jogo_new.users|pk_prod_jogo_jogo_new.waitlist_bookings`
- `cte` `booking_fact` via card `70058` (lineage: `derived_model_name_match`)
  Upstream core objects: `dwh_fitness_mart.customer_sentiment|pk_cfuserservice_cultapp.user|pk_cultprod_cultapp.attendance|pk_cultprod_cultapp.booking|pk_cultprod_cultapp.city|pk_cultprod_cultapp.cultclass|pk_cultprod_cultapp.cultemployee|pk_cultprod_cultapp.membership|pk_cultprod_cultapp.trainercultclassmap|pk_cultprod_cultapp.waitlist|pk_cultprod_cultapp.workout|pk_cultprod_cultapp.workoutfamilyworkoutmap|pk_curefitprod_center_service.center|pk_curefitprod_gymfit.centerofferings|pk_curefitprod_gymfit.centers|pk_curefitprod_gymfit.checkins|pk_prod_curefit_prod.feedbacks|pk_prod_jogo_jogo_new.all_bookings|pk_prod_jogo_jogo_new.facilities|pk_prod_jogo_jogo_new.facility_sport_mappings|pk_prod_jogo_jogo_new.sports|pk_prod_jogo_jogo_new.users|pk_prod_jogo_jogo_new.waitlist_bookings`
- `cte` `center_dim` via card `65637` (lineage: `derived_model_name_match`)
  Upstream core objects: `pk_cultprod_cultapp.address|pk_cultprod_cultapp.center|pk_curefitprod_center_service.center|pk_curefitprod_center_service.center_sku|pk_curefitprod_center_service.sku|pk_curefitprod_gymfit.addresses|pk_curefitprod_gymfit.centers|pk_curefitprod_gymfit.sellers`
- `cte` `center_dim` via card `70058` (lineage: `derived_model_name_match`)
  Upstream core objects: `pk_cultprod_cultapp.address|pk_cultprod_cultapp.center|pk_curefitprod_center_service.center|pk_curefitprod_center_service.center_sku|pk_curefitprod_center_service.sku|pk_curefitprod_gymfit.addresses|pk_curefitprod_gymfit.centers|pk_curefitprod_gymfit.sellers`
- `cte` `checkout_combined` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `checkout_combined` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `city_filtered` via card `70058` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `combined_data` via card `63745` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `combined_data` via card `65196` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `combined_data` via card `66102` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `combined_data` via card `70149` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `combined_user` via card `65637` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `cross_sell_orders` via card `65637` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `cross_sell_orders` via card `68056` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `cross_sell_orders` via card `68058` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `cross_sell_orders` via card `68051` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `cross_sell_orders` via card `68050` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `cross_sell_orders` via card `68052` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `cross_sell_orders` via card `68059` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `cross_sell_orders` via card `68048` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `cross_sell_orders` via card `70058` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `cross_sell_user_gmv` via card `65637` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `current_month_data` via card `70058` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `custom_atc` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `custom_atc` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `custom_checkout` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `custom_checkout` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `custom_event_data` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `custom_event_data` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `custom_home_page_view` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `custom_home_page_view` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `custom_pdp_page_view` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `custom_pdp_page_view` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `custom_plp_page_view` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `custom_plp_page_view` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `dev_users` via card `70058` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `ebo_store` via card `65637` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `filtered_booking_fact` via card `65637` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `filtered_centers` via card `65637` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `final_data` via card `63753` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `final_data` via card `63726` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `final_data` via card `63727` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `final_data` via card `63738` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `final_data` via card `63786` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `final_data` via card `64443` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `final_data` via card `63751` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `final_data` via card `63743` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `final_summary` via card `72323` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_data` via card `72319` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_data` via card `72323` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_data` via card `72382` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_data` via card `72383` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_data` via card `72384` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_data` via card `71754` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_data` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_user_category` via card `72382` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_user_category` via card `72383` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_user_category` via card `72384` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_user_date` via card `72319` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_user_date` via card `72323` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_user_date` via card `72382` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_user_date` via card `72383` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_user_date` via card `72384` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_user_date` via card `71754` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `freebie_user_date` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `fs_cohort_active` via card `65637` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `fs_cohort_expired` via card `65637` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `fs_cohorts` via card `65637` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `fs_cohorts` via card `68061` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `fs_cohorts` via card `68066` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `fs_cohorts` via card `68064` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `fs_cohorts` via card `68065` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `grouped_data` via card `63767` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `grouped_data` via card `63759` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `home_page_view_combined` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `home_page_view_combined` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `membership_dim` via card `65637` (lineage: `derived_model_name_match`)
  Upstream core objects: `dwh_fitness.fitness_attribution_prediction|dwh_fitness_mart.b2b_employee_details|pk_cultprod_cultapp.address|pk_cultprod_cultapp.attendance|pk_cultprod_cultapp.booking|pk_cultprod_cultapp.center|pk_cultprod_cultapp.cultclass|pk_cultprod_cultapp.membership|pk_cultprod_cultapp.membershiptransfer|pk_curefitplatforms_membershipdb.audit_logs|pk_curefitplatforms_membershipdb.benefits|pk_curefitplatforms_membershipdb.memberships|pk_curefitplatforms_membershipdb.pauses|pk_curefitprod_albus_transform.bundle_order_agent_map|pk_curefitprod_albus_transform.mp_bundle_orders|pk_curefitprod_center_service.center|pk_curefitprod_center_service.center_sku|pk_curefitprod_center_service.sku|pk_curefitprod_fitness_accounting_service.user_center_tagging|pk_curefitprod_gymfit.addresses|pk_curefitprod_gymfit.centerofferings|pk_curefitprod_gymfit.centers|pk_curefitprod_gymfit.checkins|pk_curefitprod_gymfit.memberships|pk_curefitprod_gymfit.sellers|pk_curefitprod_yoda.session|pk_prod_coupons_prod.couponconsumptions|pk_prod_curefit_prod.orders|pk_prod_curefit_prod.orders_payments|pk_prod_curefit_prod.orders_payments_refunds|pk_prod_curefit_prod.orders_productsnapshots|pk_prod_enterprise_prod.employeeregistrations|pk_prod_enterprise_prod.programs|pk_prod_jogo_jogo_new.purchases|pk_prod_jogo_jogo_new.subscriptions`
- `cte` `non_attributes_users` via card `65637` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `order_data` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `order_data_freebie_users` via card `72319` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `order_data_freebie_users` via card `72323` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `order_data_freebie_users` via card `72382` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `order_data_freebie_users` via card `72383` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `order_data_freebie_users` via card `72384` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `order_data_freebie_users` via card `71754` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `order_data_freebie_users` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `order_detail` via card `63795` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `overall_gmv` via card `63767` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `overall_gmv` via card `63759` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `pdp_page_view_combined` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `pdp_page_view_combined` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `plp_page_view_combined` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `plp_page_view_combined` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `ranked_data` via card `63767` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `ranked_data` via card `63759` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `shopify_atc` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `shopify_atc` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `shopify_checkout` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `shopify_checkout` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `shopify_event_data` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `shopify_event_data` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `shopify_home_page_view` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `shopify_home_page_view` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `shopify_pdp_page_view` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `shopify_pdp_page_view` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `shopify_plp_page_view` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `shopify_plp_page_view` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `user_city_mapped` via card `70058` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `user_count_details` via card `63795` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `user_details` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `user_details` via card `63795` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `user_details` via card `70058` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_mart.booking_fact` via card `65637` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.booking_fact` via card `70058` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.center_dim` via card `65637` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.center_dim` via card `70058` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.membership_dim` via card `65637` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.membership_dim`
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63753` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63791` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63745` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63726` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63733` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63727` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63738` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63786` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63735` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63760` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63754` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63734` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63767` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63781` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63761` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63729` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63780` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63759` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63748` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63750` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63731` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63746` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63788` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63774` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63795` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `64443` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `65195` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `65159` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `65138` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `64117` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `65196` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `65198` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `65123` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `65124` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `65122` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `65202` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `65204` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `66102` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `66114` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `66134` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `65637` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63751` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `63743` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `68056` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `68058` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `68051` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `68050` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `68052` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `68059` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `68048` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `70058` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `70149` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `71753` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `72319` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `72323` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `72382` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `72328` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `72383` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `72384` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `71754` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.cross_sell_orders` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.fs_cohorts` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.fs_cohorts` via card `63795` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.fs_cohorts` via card `65637` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.fs_cohorts` via card `68061` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.fs_cohorts` via card `68066` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.fs_cohorts` via card `68064` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.fs_cohorts` via card `68065` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_metrics.fs_cohorts` via card `70058` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `gs_d2c.default.cs_dev_users` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `gs_d2c.default.cs_dev_users` via card `63795` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `gs_d2c.default.cs_dev_users` via card `70058` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `gs_d2c.default.ebo_store_location` via card `65637` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_cultsport_app_events.web_cultsport_gearaddtocartclicked` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_cultsport_app_events.web_cultsport_gearaddtocartclicked` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_cultsport_app_events_backend.cultsportcartcheckoutitem_backend` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_cultsport_app_events_backend.cultsportcartcheckoutitem_backend` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_curefit_app_events.web_cultsport_page_view` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_curefit_app_events.web_cultsport_page_view` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_d2c_cultstore.PAGE_VIEW` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_d2c_cultstore.PAGE_VIEW` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_d2c_cultstore.atc` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_d2c_cultstore.atc` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_d2c_cultstore.checkout_clicked` via card `63763` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_d2c_cultstore.checkout_clicked` via card `72385` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.

## IPO Data (`dashboard` 4042)

- Source rows: `23|24`
- Source URL: `https://metabase.curefit.co/dashboard/4042-ipo-data?business_unit=&category=&end_date=&period=&start_date=`
- Direct cards: `21`
- Nested cards: `1`
- Tables: `2`
- Upstream core objects: `0`
- Evidence status: `query_sql|metadata_json || query_sql|metadata_json|result_blocked`
- Notes: Relation not found in local dbt manifest.

### Dependency Tree

- Card `75736` `Total Amount and Units` (role: `dashboard_card`, parent: `root`)
- Card `75854` `Month Level Amount and Units` (role: `dashboard_card`, parent: `root`)
- Card `75859` `Month_Pincode Level  Units` (role: `dashboard_card`, parent: `root`)
- Card `75860` `Month_Category Level Amount and Units` (role: `dashboard_card`, parent: `root`)
- Card `75863` `Month_Skucode Level  Units` (role: `dashboard_card`, parent: `root`)
- Card `75864` `Month_Business Unit Level Amount and Units` (role: `dashboard_card`, parent: `root`)
- Card `75865` `Business Unit Level Amount and Units` (role: `dashboard_card`, parent: `root`)
- Card `75866` `Quarter Level Amount and Units` (role: `dashboard_card`, parent: `root`)
- Card `75867` `Financial Year Level Amount and Units` (role: `dashboard_card`, parent: `root`)
- Card `75868` `Month_Category_itemcode Level Amount and Units` (role: `dashboard_card`, parent: `root`)
- Card `75869` `Category_itemcode Level Amount and Units` (role: `dashboard_card`, parent: `root`)
- Card `75870` `Unique Pincodes` (role: `dashboard_card`, parent: `root`)
- Card `75871` `Unique Sku Code` (role: `dashboard_card`, parent: `root`)
- Card `75872` `Raw Data - 2` (role: `dashboard_card`, parent: `root`)
- Card `75876` `Financial Year Wise Summary` (role: `dashboard_card`, parent: `root`)
- Card `75881` `New Launch SKU` (role: `dashboard_card`, parent: `root`)
- Card `75894` `New Launch Style Id` (role: `dashboard_card`, parent: `root`)
- Card `75906` `Financial Year Wise Summary -  Category Wise` (role: `dashboard_card`, parent: `root`)
- Card `75910` `Month_Bill to Customer Name Level Amount and Units -` (role: `dashboard_card`, parent: `root`)
- Card `76602` `Financial Year Wise Summary -  Category and Channel Wise` (role: `dashboard_card`, parent: `root`)
- Card `76604` `Financial Year Wise Summary -  Channel Type Wise` (role: `dashboard_card`, parent: `root`)
  - Card `75683` `Raw Data` (role: `nested_card`, parent: `75736`)

### Table Dependencies

- `cte` `sku_launch_date` via card `75881` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `sku_launch_date` via card `75894` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `nested_card` `metabase.card.75683` via card `75736` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75865` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75868` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75869` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75864` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75871` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75872` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75867` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75860` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75859` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75863` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75866` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75854` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75870` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75876` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75881` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75894` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75906` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `75910` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `76602` (lineage: `metabase_card_reference`)
- `nested_card` `metabase.card.75683` via card `76604` (lineage: `metabase_card_reference`)
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75736` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75865` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75868` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75869` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75864` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75871` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75872` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75867` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75860` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75859` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75863` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75866` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75854` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75870` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75876` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75881` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75894` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75906` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `75910` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `76602` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_fitstore_unicommerce.item_details_summary` via card `76604` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `stage_dwh.dwh_d2c_metrics_bizfin_sales_data` via card `75683` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.

## Which of these below- mentioned statements best describes your fitness history. (`question` 47810)

- Source rows: `6`
- Source URL: `https://metabase.curefit.co/question/47810-which-of-these-below-mentioned-statements-best-describes-your-fitness-history`
- Direct cards: `1`
- Nested cards: `0`
- Tables: `1`
- Upstream core objects: `1`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`

### Dependency Tree

- Card `47810` `Which of these below- mentioned statements best describes your fitness history.` (role: `root_question`, parent: `root`)

### Table Dependencies

- `table` `pk_curefitprod_cfdb.npsresponses` via card `47810` (lineage: `source_table`)
  Upstream core objects: `pk_curefitprod_cfdb.npsresponses`

## #Footfalls - Grained (`question` 55566)

- Source rows: `4|21`
- Source URL: `https://metabase.curefit.co/question/55566-footfalls-grained?Start_Date=2023-01-01&End_Date=2024-11-12&grain=quarter`
- Direct cards: `1`
- Nested cards: `0`
- Tables: `4`
- Upstream core objects: `3`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

### Dependency Tree

- Card `55566` `#Footfalls - Grained` (role: `root_question`, parent: `root`)

### Table Dependencies

- `table` `base` via card `55566` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_mart.booking_fact` via card `55566` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.center_dim` via card `55566` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.membership_dim` via card `55566` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.membership_dim`

## # Installs by type & source - Duplicate (`question` 67337)

- Source rows: `15|17`
- Source URL: `https://metabase.curefit.co/question/67337-installs-by-type-source-duplicate?Time_Granularity=Month&From=2022-04-01&To=2025-12-31&City=&Campaign=&Value_Type=Users`
- Direct cards: `1`
- Nested cards: `0`
- Tables: `1`
- Upstream core objects: `0`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

### Dependency Tree

- Card `67337` `# Installs by type & source - Duplicate` (role: `root_question`, parent: `root`)

### Table Dependencies

- `table` `dwh_growth_mart.growth_install_fact` via card `67337` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.

## Memberships by Each Business Line - End of Each Month - including all packs (`question` 75109)

- Source rows: `1`
- Source URL: `https://metabase.curefit.co/question/75109-memberships-by-each-business-line-end-of-each-month-including-all-packs?start_date=2025-09-01&end_date=2026-01-31`
- Direct cards: `1`
- Nested cards: `0`
- Tables: `2`
- Upstream core objects: `2`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

### Dependency Tree

- Card `75109` `Memberships by Each Business Line - End of Each Month - including all packs` (role: `root_question`, parent: `root`)

### Table Dependencies

- `cte` `dates` via card `75109` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_curefit.dim_date` via card `75109` (lineage: `source_table`)
  Upstream core objects: `dwh_curefit.dim_date`
- `table` `dwh_fitness_mart.membership_dim` via card `75109` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.membership_dim`

## Monthly active memberships ELITE, PRO, PLAY, LUX (`question` 75114)

- Source rows: `3`
- Source URL: `https://metabase.curefit.co/question/75114-monthly-active-memberships-elite-pro-play-lux?Start_Date=2023-04-01&end_date=2025-12-31`
- Direct cards: `1`
- Nested cards: `0`
- Tables: `2`
- Upstream core objects: `2`
- Evidence status: `query_sql|metadata_json|result_blocked`
- Notes: Relation not found in local dbt manifest.

### Dependency Tree

- Card `75114` `Monthly active memberships ELITE, PRO, PLAY, LUX` (role: `root_question`, parent: `root`)

### Table Dependencies

- `cte` `activeMemberships` via card `75114` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `cte` `liveMemberships` via card `75114` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_curefit.dim_date` via card `75114` (lineage: `source_table`)
  Upstream core objects: `dwh_curefit.dim_date`
- `table` `dwh_fitness_mart.membership_dim` via card `75114` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.membership_dim`

## Pauses Extensions (`question` 75628)

- Source rows: `12`
- Source URL: `https://metabase.curefit.co/question/75628-pauses-extensions?ed=2025-12-31`
- Direct cards: `1`
- Nested cards: `0`
- Tables: `5`
- Upstream core objects: `30`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

### Dependency Tree

- Card `75628` `Pauses Extensions` (role: `root_question`, parent: `root`)

### Table Dependencies

- `cte` `parent_child_map` via card `75628` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `base` via card `75628` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_bi.pause_and_extension_fact` via card `75628` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_mart.membership_dim` via card `75628` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.membership_dim`
- `table` `dwh_fitness_mart.orders_fact` via card `75628` (lineage: `derived_model`)
  Upstream core objects: `pk_cultprod_cultapp.address|pk_cultprod_cultapp.booking|pk_cultprod_cultapp.center|pk_cultprod_cultapp.city|pk_cultprod_cultapp.cultclass|pk_cultprod_cultapp.membership|pk_cultprod_cultapp.preregistrationoffer|pk_curefitplatforms_membershipdb.memberships|pk_curefitprod_center_service.center|pk_curefitprod_center_service.center_sku|pk_curefitprod_center_service.sku|pk_curefitprod_gymfit.addresses|pk_curefitprod_gymfit.centers|pk_curefitprod_gymfit.sellers|pk_oms_analytics.payment_success|pk_prod_curefit_prod.offers|pk_prod_curefit_prod.orders|pk_prod_curefit_prod.orders_offersinfo|pk_prod_curefit_prod.orders_payments|pk_prod_curefit_prod.orders_payments_onuspayments|pk_prod_curefit_prod.orders_payments_refunds|pk_prod_curefit_prod.orders_products|pk_prod_curefit_prod.orders_productsnapshots|pk_prod_curefit_prod.orders_productsnapshots_option_offersinfo|pk_prod_curefit_prod.orders_statushistory|pk_prod_curefit_prod.referrals|pk_prod_curefit_prod.referrals_refereerewards|pk_prod_curefit_prod.referrals_statushistory|pk_walletprod_wallet_prod.wallet_refund`
- `table` `pk_curefitplatforms_membershipdb.memberships` via card `75628` (lineage: `source_table`)
  Upstream core objects: `pk_curefitplatforms_membershipdb.memberships`

## Gender Split (`question` 75630)

- Source rows: `7`
- Source URL: `https://metabase.curefit.co/question/75630-gender-split?ed=2023-03-31`
- Direct cards: `1`
- Nested cards: `0`
- Tables: `10`
- Upstream core objects: `3`
- Evidence status: `query_sql|metadata_json|result_blocked`
- Notes: Relation not found in local dbt manifest.

### Dependency Tree

- Card `75630` `Gender Split` (role: `root_question`, parent: `root`)

### Table Dependencies

- `table` `BASE` via card `75630` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `GENDER_BASE` via card `75630` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `age_onboarding` via card `75630` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `birthday_base` via card `75630` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_mart.membership_dim` via card `75630` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.membership_dim`
- `table` `pk_cfprodplatforms_rashi.User_Attribute` via card `75630` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_cfuserservice_cultapp.User` via card `75630` (lineage: `source_table`)
  Upstream core objects: `pk_cfuserservice_cultapp.user`
- `table` `pk_curefitprod_cfdb.npsresponses` via card `75630` (lineage: `source_table`)
  Upstream core objects: `pk_curefitprod_cfdb.npsresponses`
- `table` `rashi_age` via card `75630` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `user_age` via card `75630` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.

## Same center vs other center (`question` 75647)

- Source rows: `9`
- Source URL: `https://metabase.curefit.co/question/75647-same-center-vs-other-center?Last_date=2026-02-09`
- Direct cards: `1`
- Nested cards: `0`
- Tables: `4`
- Upstream core objects: `3`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

### Dependency Tree

- Card `75647` `Same center vs other center` (role: `root_question`, parent: `root`)

### Table Dependencies

- `table` `base` via card `75647` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_mart.booking_fact` via card `75647` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.center_dim` via card `75647` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.membership_dim` via card `75647` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.membership_dim`

## Same city vs other city - Modified (`question` 75650)

- Source rows: `10`
- Source URL: `https://metabase.curefit.co/question/75650-same-city-vs-other-city-modified?Last_date=2026-02-09`
- Direct cards: `1`
- Nested cards: `0`
- Tables: `4`
- Upstream core objects: `3`
- Evidence status: `query_sql|metadata_json|result_blocked`
- Notes: Relation not found in local dbt manifest.

### Dependency Tree

- Card `75650` `Same city vs other city - Modified` (role: `root_question`, parent: `root`)

### Table Dependencies

- `table` `base` via card `75650` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_mart.booking_fact` via card `75650` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.center_dim` via card `75650` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.membership_dim` via card `75650` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.membership_dim`

## GX formats (`question` 75654)

- Source rows: `11`
- Source URL: `https://metabase.curefit.co/question/75654-gx-formats?Last_date=2025-12-31`
- Direct cards: `1`
- Nested cards: `0`
- Tables: `7`
- Upstream core objects: `13`
- Evidence status: `query_sql|metadata_json|result_blocked`
- Notes: Relation not found in local dbt manifest.

### Dependency Tree

- Card `75654` `GX formats` (role: `root_question`, parent: `root`)

### Table Dependencies

- `cte` `all_sessions_df` via card `75654` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `User_classes` via card `75654` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `base` via card `75654` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_fitness_mart.booking_fact` via card `75654` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.booking_fact`
- `table` `dwh_fitness_mart.center_dim` via card `75654` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.employee_dim` via card `75654` (lineage: `derived_model`)
  Upstream core objects: `pk_cultprod_cultapp.center|pk_cultprod_cultapp.cultemployee|pk_cultprod_cultapp.employeehomecentermapping|pk_curefitplatforms_identitydb.identity|pk_curefitplatforms_watchmen.membership|pk_hrms_neo_cult.designation|pk_hrms_neo_cult.employee|pk_hrms_neo_cult.exit_details|pk_hrms_neo_cult.job_details`
- `table` `dwh_fitness_mart.membership_dim` via card `75654` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.membership_dim`
- `table` `dwh_fitness_mart.workout_dim` via card `75654` (lineage: `derived_model`)
  Upstream core objects: `pk_cultprod_cultapp.cultemployee|pk_cultprod_cultapp.workout`

## 'At Home' footfalls (`question` 75753)

- Source rows: `5|22`
- Source URL: `https://metabase.curefit.co/question/75753-at-home-footfalls?grain=month`
- Direct cards: `1`
- Nested cards: `0`
- Tables: `2`
- Upstream core objects: `2`
- Evidence status: `query_sql|metadata_json|result_blocked`

### Dependency Tree

- Card `75753` `'At Home' footfalls` (role: `root_question`, parent: `root`)

### Table Dependencies

- `table` `dwh_fitness_mart.membership_dim` via card `75753` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.membership_dim`
- `table` `dwh_live.live_bookings` via card `75753` (lineage: `source_table`)
  Upstream core objects: `dwh_live.live_bookings`

## Page Ids Traffic (`question` 75999)

- Source rows: `16|18`
- Source URL: `https://metabase.curefit.co/question/75999-page-ids-traffic?Start=2022-04-01&End=2025-12-31&Time_Granularity=Month`
- Direct cards: `1`
- Nested cards: `0`
- Tables: `2`
- Upstream core objects: `0`
- Evidence status: `query_sql|metadata_json|result_blocked`
- Notes: Relation not found in local dbt manifest.

### Dependency Tree

- Card `75999` `Page Ids Traffic` (role: `root_question`, parent: `root`)

### Table Dependencies

- `table` `base` via card `75999` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `pk_curefit_app_events.page_view` via card `75999` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.

## 12M Packs Sold Monthly Jun 2026 (`question` 83969)

- Source rows: `8`
- Source URL: `https://metabase.curefit.co/question/83969-12m-packs-sold-monthly-jun-2026?Start_Date=2023-04-01&End_Date=2026-03-31`
- Direct cards: `1`
- Nested cards: `0`
- Tables: `4`
- Upstream core objects: `4`
- Evidence status: `query_sql|metadata_json|raw_csv`
- Notes: Lineage reflects tables used by card 83969 SQL.

### Dependency Tree

- Card `83969` `12M Packs Sold Monthly Jun 2026` (role: `root_question`, parent: `root`)

### Table Dependencies

- `table` `dwh_fitness_mart.center_dim` via card `83969` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.membership_dim` via card `83969` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.membership_dim`
- `table` `dwh_fitness_mart.orders_fact` via card `83969` (lineage: `derived_model`)
  Upstream core objects: `dwh_fitness_mart.orders_fact`
- `table` `pk_curefitplatforms_membershipdb.memberships` via card `83969` (lineage: `source_table`)
  Upstream core objects: `pk_curefitplatforms_membershipdb.memberships`

## Memberships by Each Business Line - End of Each Month - including all packs -city level (`question` 77280)

- Source rows: `2`
- Source URL: `https://metabase.curefit.co/question/77280-memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level?start_date=2025-09-12&end_date=2026-03-12`
- Direct cards: `1`
- Nested cards: `0`
- Tables: `3`
- Upstream core objects: `3`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

### Dependency Tree

- Card `77280` `Memberships by Each Business Line - End of Each Month - including all packs -city level` (role: `root_question`, parent: `root`)

### Table Dependencies

- `cte` `dates` via card `77280` (lineage: `unresolved`)
  Unresolved reason: Relation not found in local dbt manifest.
- `table` `dwh_curefit.dim_date` via card `77280` (lineage: `source_table`)
  Upstream core objects: `dwh_curefit.dim_date`
- `table` `dwh_fitness_mart.center_dim` via card `77280` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.center_dim`
- `table` `dwh_fitness_mart.membership_dim` via card `77280` (lineage: `source_table`)
  Upstream core objects: `dwh_fitness_mart.membership_dim`
