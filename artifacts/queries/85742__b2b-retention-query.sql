WITH b2b_client_base AS
(
    -- Step 1:
    -- Get client-level memberships by financial year.
    -- Financial year is Apr to Mar.
    SELECT 
        account.ID,
        account.name AS client_name,

        -- Month of opportunity close date
        date_trunc('month', date(closedate)) AS close_month,

        -- Map close date to financial year
        CASE 
            WHEN date(closedate) BETWEEN date('2022-04-01') AND date('2023-03-31') THEN 'FY23'
            WHEN date(closedate) BETWEEN date('2023-04-01') AND date('2024-03-31') THEN 'FY24'
            WHEN date(closedate) BETWEEN date('2024-04-01') AND date('2025-03-31') THEN 'FY25'
            WHEN date(closedate) BETWEEN date('2025-04-01') AND date('2026-03-31') THEN 'FY26'
        END AS period,

        -- Total memberships sold
        SUM(s.quantity_c) AS memberships

    FROM pk_curefit_salesforce.account -- client data
    JOIN pk_curefit_salesforce.Opportunity -- contracts data
        ON account.id = Opportunity.accountid
    JOIN pk_curefit_salesforce.Sales_Split__C s -- products data with corresponding membership quantities
        ON Opportunity.ID = s.Opportunity_C

    WHERE 
        -- Include data from FY23 onwards.
        -- FY23 is needed because FY24 retention uses FY23 as base.
        date_trunc('year', date(closedate)) >= date '2022-01-01'

        -- Remove test / dummy clients
        AND lower(account.name) NOT LIKE '%test%'
        AND lower(account.name) NOT LIKE '%dummy%'

        -- Remove non-membership line items
        AND UPPER(s.name) NOT LIKE '%FEE%'
        AND UPPER(s.name) NOT LIKE '%EQUIPMENT%'
        AND UPPER(s.name) NOT LIKE '%DIETICIAN%'
        AND UPPER(s.name) NOT LIKE '%THERAPY%'
        AND UPPER(s.name) NOT LIKE '%DIAGNOSTIC%'
        AND UPPER(s.name) NOT LIKE '%TOURNAMENT%'
        AND UPPER(s.name) NOT LIKE '%ENGAGEMENT%'
        AND UPPER(s.name) NOT LIKE '%CHALLENGE%'
        AND UPPER(s.name) NOT LIKE '%SETUP%'
        AND UPPER(s.name) NOT LIKE '%REGISTRATION%'
        AND UPPER(s.name) NOT LIKE '%ONETIME%'

    GROUP BY 1,2,3,4
),

fy_pivot AS 
(
    -- Step 2:
    -- Convert rows into one row per client.
    -- Each client gets separate membership columns for FY23, FY24, FY25, FY26.
    SELECT 
        client_name,

        SUM(CASE WHEN period = 'FY23' THEN memberships ELSE 0 END) AS fy23_memberships,
        SUM(CASE WHEN period = 'FY24' THEN memberships ELSE 0 END) AS fy24_memberships,
        SUM(CASE WHEN period = 'FY25' THEN memberships ELSE 0 END) AS fy25_memberships,
        SUM(CASE WHEN period = 'FY26' THEN memberships ELSE 0 END) AS fy26_memberships

    FROM b2b_client_base
    WHERE period IS NOT NULL
    GROUP BY 1
),

retention_base AS
(
    -- Step 3:
    -- Keep one row per client with memberships across years.
    -- A client is considered active in an FY if memberships > 0.
    SELECT
        client_name,
        fy23_memberships,
        fy24_memberships,
        fy25_memberships,
        fy26_memberships
    FROM fy_pivot
)

-- Step 4:
-- Calculate retention for each FY.
-- Logic:
-- For FY24 retention:
--   Base = FY23 memberships of clients active in FY23
--   Retained = FY23 memberships of clients active in both FY23 and FY24
--   Retention % = Retained / Base
--
-- Same logic is repeated for FY25 and FY26.

SELECT
    'FY24' AS retention_period,

    -- FY23 memberships are the base for FY24 retention
	-- SUM(CASE WHEN fy23_memberships > 0 THEN fy23_memberships ELSE 0 END) AS base_memberships,

    -- Count FY23 memberships only for clients who also came back in FY24
    -- SUM(CASE WHEN fy23_memberships > 0 AND fy24_memberships > 0 THEN fy23_memberships ELSE 0 END) AS retained_memberships,

    -- FY24 retention %
    1.0 * SUM(CASE WHEN fy23_memberships > 0 AND fy24_memberships > 0 THEN fy23_memberships ELSE 0 END)
        / NULLIF(SUM(CASE WHEN fy23_memberships > 0 THEN fy23_memberships ELSE 0 END), 0) AS retention_pct
FROM retention_base

UNION ALL

SELECT
    'FY25' AS retention_period,

    -- FY24 memberships are the base for FY25 retention
    -- SUM(CASE WHEN fy24_memberships > 0 THEN fy24_memberships ELSE 0 END) AS base_memberships,


    -- Count FY24 memberships only for clients who also came back in FY25
    -- SUM(CASE WHEN fy24_memberships > 0 AND fy25_memberships > 0 THEN fy24_memberships ELSE 0 END) AS retained_memberships,

    -- FY25 retention %
    1.0 * SUM(CASE WHEN fy24_memberships > 0 AND fy25_memberships > 0 THEN fy24_memberships ELSE 0 END)
        / NULLIF(SUM(CASE WHEN fy24_memberships > 0 THEN fy24_memberships ELSE 0 END), 0) AS retention_pct

FROM retention_base

UNION ALL

SELECT
    'FY26' AS retention_period,

    -- FY25 memberships are the base for FY26 retention
    -- SUM(CASE WHEN fy25_memberships > 0 THEN fy25_memberships ELSE 0 END) AS base_memberships,
    
    -- Count FY25 memberships only for clients who also came back in FY26
    -- SUM(CASE WHEN fy25_memberships > 0 AND fy26_memberships > 0 THEN fy25_memberships ELSE 0 END) AS retained_memberships,

    -- FY26 retention %
    1.0 * SUM(CASE WHEN fy25_memberships > 0 AND fy26_memberships > 0 THEN fy25_memberships ELSE 0 END)
        / NULLIF(SUM(CASE WHEN fy25_memberships > 0 THEN fy25_memberships ELSE 0 END), 0) AS retention_pct
FROM retention_base

ORDER BY 1
