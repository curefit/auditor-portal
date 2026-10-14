WITH base AS (
    SELECT
        CASE
            WHEN order_date BETWEEN DATE('2022-04-01') AND DATE('2023-03-31') THEN 'FY23'
            WHEN order_date BETWEEN DATE('2023-04-01') AND DATE('2024-03-31') THEN 'FY24'
            WHEN order_date BETWEEN DATE('2024-04-01') AND DATE('2025-03-31') THEN 'FY25'
            WHEN order_date BETWEEN DATE('2025-04-01') AND DATE('2026-03-31') THEN 'FY26'
        END AS fy,
        CASE
            WHEN is_fs_member = 1 THEN 'CROSS-SELL'
            WHEN is_fs_member = 0 THEN 'NON-FS-MEMBER'
        END AS cross_sell_vs_1p,
        gmv
    FROM dwh_fitness_metrics.cross_sell_orders
    WHERE is_cancelled = 0
      AND order_date BETWEEN DATE('2022-04-01') AND DATE('2026-03-31')
      AND is_fs_member IN (0, 1)
),
grouped AS (
    SELECT
        fy,
        cross_sell_vs_1p,
        SUM(gmv) AS total_gmv
    FROM base
    WHERE fy IS NOT NULL
    GROUP BY 1, 2
)

SELECT fy AS financial_year, pct_gmv AS cross_sell_percentage
FROM 
(
SELECT
    fy,
    cross_sell_vs_1p,
    ROUND(total_gmv, 0) AS total_gmv,
    ROUND(
        100.0 * total_gmv / SUM(total_gmv) OVER (PARTITION BY fy),
        2
    ) AS pct_gmv
FROM grouped
)
WHERE cross_sell_vs_1p = 'CROSS-SELL'
ORDER BY fy
