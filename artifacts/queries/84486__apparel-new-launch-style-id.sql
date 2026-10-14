WITH sku_launch_date AS (
    SELECT
        style_id AS style_id,
        MIN(TO_DATE(invoice_date, 'dd-MM-yyyy')) AS launch_date
    FROM  dwh_d2c_metrics.bizfin_sales_data
    WHERE 1 = 1
        AND business_category = 'Apparel'
    GROUP BY 1
)

SELECT year, style_id_count
FROM (
    SELECT
        1 AS sort_key,
        'FY23' AS year,
        COUNT(DISTINCT style_id) AS style_id_count
    FROM sku_launch_date
    WHERE launch_date BETWEEN DATE '2022-04-01' AND DATE '2023-03-31'

    UNION ALL

    SELECT
        2 AS sort_key,
        'FY24' AS year,
        COUNT(DISTINCT style_id) AS style_id_count
    FROM sku_launch_date
    WHERE launch_date BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'

    UNION ALL

    SELECT
        3 AS sort_key,
        'FY25' AS year,
        COUNT(DISTINCT style_id) AS style_id_count
    FROM sku_launch_date
    WHERE launch_date BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'

    UNION ALL

    SELECT
        4 AS sort_key,
        'FY26' AS year,
        COUNT(DISTINCT style_id) AS style_id_count
    FROM sku_launch_date
    WHERE launch_date BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'

    UNION ALL

    SELECT
        5 AS sort_key,
        'H1-FY26' AS year,
        COUNT(DISTINCT style_id) AS style_id_count
    FROM sku_launch_date
    WHERE launch_date BETWEEN DATE '2025-04-01' AND DATE '2025-09-30'

    UNION ALL

    SELECT
        6 AS sort_key,
        'H1-FY27' AS year,
        COUNT(DISTINCT style_id) AS style_id_count
    FROM sku_launch_date
    WHERE launch_date BETWEEN DATE '2026-04-01' AND DATE '2026-09-30'
) t
ORDER BY sort_key
