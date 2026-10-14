WITH base AS (
    SELECT
        1 AS sort_key,
        'FY23' AS fy,
        CASE
            WHEN is_fs_member = 1 THEN 'CROSS-SELL'
            WHEN is_fs_member = 0 THEN 'NON-FS-MEMBER'
        END AS cross_sell_vs_1p,
        gmv
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE is_cancelled = 0
      AND order_date BETWEEN DATE '2022-04-01' AND DATE '2023-03-31'

    UNION ALL

    SELECT
        2 AS sort_key,
        'FY24' AS fy,
        CASE
            WHEN is_fs_member = 1 THEN 'CROSS-SELL'
            WHEN is_fs_member = 0 THEN 'NON-FS-MEMBER'
        END AS cross_sell_vs_1p,
        gmv
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE is_cancelled = 0
      AND order_date BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'

    UNION ALL

    SELECT
        3 AS sort_key,
        'FY25' AS fy,
        CASE
            WHEN is_fs_member = 1 THEN 'CROSS-SELL'
            WHEN is_fs_member = 0 THEN 'NON-FS-MEMBER'
        END AS cross_sell_vs_1p,
        gmv
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE is_cancelled = 0
      AND order_date BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'

    UNION ALL

    SELECT
        4 AS sort_key,
        'FY26' AS fy,
        CASE
            WHEN is_fs_member = 1 THEN 'CROSS-SELL'
            WHEN is_fs_member = 0 THEN 'NON-FS-MEMBER'
        END AS cross_sell_vs_1p,
        gmv
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE is_cancelled = 0
      AND order_date BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'

    UNION ALL

    SELECT
        5 AS sort_key,
        'H1-FY26' AS fy,
        CASE
            WHEN is_fs_member = 1 THEN 'CROSS-SELL'
            WHEN is_fs_member = 0 THEN 'NON-FS-MEMBER'
        END AS cross_sell_vs_1p,
        gmv
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE is_cancelled = 0
      AND order_date BETWEEN DATE '2025-04-01' AND DATE '2025-09-30'

    UNION ALL

    SELECT
        6 AS sort_key,
        'H1-FY27' AS fy,
        CASE
            WHEN is_fs_member = 1 THEN 'CROSS-SELL'
            WHEN is_fs_member = 0 THEN 'NON-FS-MEMBER'
        END AS cross_sell_vs_1p,
        gmv
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE is_cancelled = 0
      AND order_date BETWEEN DATE '2026-04-01' AND DATE '2026-09-30'
),
grouped AS (
    SELECT sort_key, fy, cross_sell_vs_1p, SUM(gmv) AS total_gmv
    FROM base
    WHERE cross_sell_vs_1p IS NOT NULL
    GROUP BY 1, 2, 3
)
SELECT financial_year, cross_sell_percentage
FROM (
    SELECT
        sort_key,
        fy AS financial_year,
        cross_sell_vs_1p,
        ROUND(100.0 * total_gmv / SUM(total_gmv) OVER (PARTITION BY fy), 2) AS cross_sell_percentage
    FROM grouped
)
WHERE cross_sell_vs_1p = 'CROSS-SELL'
ORDER BY sort_key
