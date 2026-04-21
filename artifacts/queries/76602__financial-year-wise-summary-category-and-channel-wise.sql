SELECT
    manual_channel_type,
    account_channel_type,
    business_category,
    year,
    total_amount,
    base_amount,
    total_nlc,
    total_units,
    gm,
    gm_percent,
    total_unique_sku_code,
    total_unique_styleid,
    total_unique_pincode
FROM (
    SELECT
        1 AS sort_key,
        manual_channel_type,
        account_channel_type,
        business_category,
        'FY23' AS year,
        ROUND(SUM(CAST(REPLACE(total_amount, ',', '') AS DOUBLE))) AS total_amount,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        ROUND(SUM(nlc)) AS total_nlc,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc)) AS gm,
        (ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc))) * 1.000/ ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS gm_percent,
        COUNT(DISTINCT item_code) AS total_unique_sku_code,
        COUNT(DISTINCT style_id) AS total_unique_styleid,
        COUNT(DISTINCT bill_to_pincode) AS total_unique_pincode
    FROM {{#75683-raw-data}}
    WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2022-04-01' AND DATE '2023-03-31'
        [[ AND business_category IN (SELECT business_category FROM pk_fitstore_unicommerce.item_details_summary WHERE {{category}}) ]]
        [[ AND article_type IN (SELECT article_type FROM pk_fitstore_unicommerce.item_details_summary WHERE {{article_type}}) ]]
        [[ AND bus_sub_category IN (SELECT bus_sub_category FROM pk_fitstore_unicommerce.item_details_summary WHERE {{sub_category}}) ]]
        [[ AND CASE WHEN {{consider_purchase}} = 'Yes' THEN TRUE ELSE is_purchase_data = 'NO' END]]
    GROUP BY 1, 2, 3, 4, 5

    UNION ALL

    SELECT
        2 AS sort_key,
        manual_channel_type,
        account_channel_type,
        business_category,
        'FY24' AS year,
        ROUND(SUM(CAST(REPLACE(total_amount, ',', '') AS DOUBLE))) AS total_amount,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        ROUND(SUM(nlc)) AS total_nlc,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc)) AS gm,
        (ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc))) * 1.000/ ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS gm_percent,
        COUNT(DISTINCT item_code) AS total_unique_sku_code,
        COUNT(DISTINCT style_id) AS total_unique_styleid,
        COUNT(DISTINCT bill_to_pincode) AS total_unique_pincode
    FROM {{#75683-raw-data}}
    WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'
        [[ AND business_category IN (SELECT business_category FROM pk_fitstore_unicommerce.item_details_summary WHERE {{category}}) ]]
        [[ AND article_type IN (SELECT article_type FROM pk_fitstore_unicommerce.item_details_summary WHERE {{article_type}}) ]]
        [[ AND bus_sub_category IN (SELECT bus_sub_category FROM pk_fitstore_unicommerce.item_details_summary WHERE {{sub_category}}) ]]
        [[ AND CASE WHEN {{consider_purchase}} = 'Yes' THEN TRUE ELSE is_purchase_data = 'NO' END]]
    GROUP BY 1, 2, 3, 4, 5

    UNION ALL

    SELECT
        3 AS sort_key,
        manual_channel_type,
        account_channel_type,
        business_category,
        'FY25' AS year,
        ROUND(SUM(CAST(REPLACE(total_amount, ',', '') AS DOUBLE))) AS total_amount,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        ROUND(SUM(nlc)) AS total_nlc,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc)) AS gm,
        (ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc))) * 1.000/ ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS gm_percent,
        COUNT(DISTINCT item_code) AS total_unique_sku_code,
        COUNT(DISTINCT style_id) AS total_unique_styleid,
        COUNT(DISTINCT bill_to_pincode) AS total_unique_pincode
    FROM {{#75683-raw-data}}
    WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'
        [[ AND business_category IN (SELECT business_category FROM pk_fitstore_unicommerce.item_details_summary WHERE {{category}}) ]]
        [[ AND article_type IN (SELECT article_type FROM pk_fitstore_unicommerce.item_details_summary WHERE {{article_type}}) ]]
        [[ AND bus_sub_category IN (SELECT bus_sub_category FROM pk_fitstore_unicommerce.item_details_summary WHERE {{sub_category}}) ]]
        [[ AND CASE WHEN {{consider_purchase}} = 'Yes' THEN TRUE ELSE is_purchase_data = 'NO' END]]
    GROUP BY 1, 2, 3, 4, 5
    
    UNION ALL 
    
    SELECT
        5 AS sort_key,
        manual_channel_type,
        account_channel_type,
        business_category,
        'FY26' AS year,
        ROUND(SUM(CAST(REPLACE(total_amount, ',', '') AS DOUBLE))) AS total_amount,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS base_amount,
        ROUND(SUM(nlc)) AS total_nlc,
        SUM(CAST(REPLACE(quantity_invoiced, ',', '') AS DOUBLE)) AS total_units,
        ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc)) AS gm,
        (ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) - ROUND(SUM(nlc))) * 1.000/ ROUND(SUM(CAST(REPLACE(base_amount, ',', '') AS DOUBLE))) AS gm_percent,
        COUNT(DISTINCT item_code) AS total_unique_sku_code,
        COUNT(DISTINCT style_id) AS total_unique_styleid,
        COUNT(DISTINCT bill_to_pincode) AS total_unique_pincode
    FROM {{#75683-raw-data}}
    WHERE DATE(DATE_PARSE(invoice_date, '%d-%m-%Y')) BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'
        [[ AND business_category IN (SELECT business_category FROM pk_fitstore_unicommerce.item_details_summary WHERE {{category}}) ]]
        [[ AND article_type IN (SELECT article_type FROM pk_fitstore_unicommerce.item_details_summary WHERE {{article_type}}) ]]
        [[ AND bus_sub_category IN (SELECT bus_sub_category FROM pk_fitstore_unicommerce.item_details_summary WHERE {{sub_category}}) ]]
        [[ AND CASE WHEN {{consider_purchase}} = 'Yes' THEN TRUE ELSE is_purchase_data = 'NO' END]]
    GROUP BY 1, 2, 3, 4, 5
) t
WHERE 1 = 1
[[AND year = {{year}}]]
ORDER BY manual_channel_type, account_channel_type, business_category, sort_key
