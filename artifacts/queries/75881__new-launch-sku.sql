WITH sku_launch_date AS (
    SELECT
        item_code AS sku_code,
        MIN(DATE(DATE_PARSE(invoice_date, '%d-%m-%Y'))) AS launch_date
    FROM {{#75683-raw-data}}
    WHERE 1 = 1
        [[ AND business_category IN (SELECT business_category FROM pk_fitstore_unicommerce.item_details_summary WHERE {{category}}) ]]
        [[ AND article_type IN (SELECT article_type FROM pk_fitstore_unicommerce.item_details_summary WHERE {{article_type}}) ]]
        [[ AND bus_sub_category IN (SELECT bus_sub_category FROM pk_fitstore_unicommerce.item_details_summary WHERE {{sub_category}}) ]]
    GROUP BY 1
)

SELECT year, sku_count
FROM (
    SELECT
        1 AS sort_key,
        'FY23' AS year,
        COUNT(DISTINCT sku_code) AS sku_count
    FROM sku_launch_date
    WHERE launch_date BETWEEN DATE '2022-04-01' AND DATE '2023-03-31'

    UNION ALL

    SELECT
        2 AS sort_key,
        'FY24' AS year,
        COUNT(DISTINCT sku_code) AS sku_count
    FROM sku_launch_date
    WHERE launch_date BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'

    UNION ALL

    SELECT
        3 AS sort_key,
        'FY25' AS year,
        COUNT(DISTINCT sku_code) AS sku_count
    FROM sku_launch_date
    WHERE launch_date BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'

    UNION ALL

    SELECT
        5 AS sort_key,
        'FY26' AS year,
        COUNT(DISTINCT sku_code) AS sku_count
    FROM sku_launch_date
    WHERE launch_date BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'
) t
ORDER BY sort_key
