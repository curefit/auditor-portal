SELECT 
    business_unit, ROUND(SUM(CAST(REPLACE(total_amount, ',', '') AS DOUBLE))) AS total_amount, ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
    ROUND(SUM(nlc)) AS total_nlc,
    SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS units,
    ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc)) AS gm,
   (ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc))) * 1.000/ ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS gm_percent
FROM {{#75683-raw-data}}
WHERE 1 = 1 
[[ AND business_category IN (SELECT business_category FROM pk_fitstore_unicommerce.item_details_summary WHERE {{category}}) ]]
[[ AND article_type IN (SELECT article_type FROM pk_fitstore_unicommerce.item_details_summary WHERE {{article_type}}) ]]
[[ AND bus_sub_category IN (SELECT article_type FROM pk_fitstore_unicommerce.item_details_summary WHERE {{sub_category}}) ]]
[[ AND DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN {{start_date}} AND {{end_date}} ]]
[[ AND CASE WHEN {{consider_purchase}} = 'Yes' THEN TRUE ELSE is_purchase_data = 'NO' END]]
GROUP BY 1
ORDER BY 1
