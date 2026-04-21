SELECT *
FROM {{#75683-raw-data}}
WHERE 1 = 1 
[[ AND business_category IN (SELECT business_category FROM pk_fitstore_unicommerce.item_details_summary WHERE {{category}}) ]]
[[ AND article_type IN (SELECT article_type FROM pk_fitstore_unicommerce.item_details_summary WHERE {{article_type}}) ]]
[[ AND bus_sub_category IN (SELECT article_type FROM pk_fitstore_unicommerce.item_details_summary WHERE {{sub_category}}) ]]
[[ AND DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN {{start_date}} AND {{end_date}} ]]
[[ AND CASE WHEN {{consider_purchase}} = 'Yes' THEN TRUE ELSE is_purchase_data = 'NO' END]]
