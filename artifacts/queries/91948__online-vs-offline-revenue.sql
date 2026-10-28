WITH b2c_union AS (

 --    /* Elite & Pro - legacy */
 --    SELECT
 --        fy,
 --        order_id,
 --        CAST(earned AS DOUBLE) AS earned,
 --        'elite-pro' AS business_line
 --    FROM pk_revenue_analysis.consolidated_b2c_elite_and_pro
 --    WHERE COALESCE(fy, '') NOT LIKE '%25-26%'
 --      AND COALESCE(purchase_date, DATE '2022-01-01') >= DATE '1900-01-01'

 --    UNION ALL

 --    /* Elite & Pro - 2026 */
 --    SELECT
 --        fy,
 --        order_id,
 --        CAST(earned AS DOUBLE) AS earned,
 --        'elite-pro' AS business_line
 --    FROM pk_revenue_analysis.consolidated_b2c_elite_and_pro_2026
 --    WHERE COALESCE(purchase_date, DATE '2022-01-01') >= DATE '1900-01-01'

	-- UNION ALL
	/* Elite & Pro - 2025 H1 */
    SELECT
        '25-26 H1' fy,
        order_id,
        CAST(earned AS DOUBLE) AS earned,
        'elite-pro' AS business_line
    FROM pk_revenue_analysis.consolidated_b2c_elitepro_h1
    WHERE COALESCE(purchase_date, DATE '2022-01-01') >= DATE '1900-01-01'

	UNION ALL

    /* Elite & Pro - 2026 H1 */
    SELECT
        '26-27 H1' fy,
        order_id,
        CAST(earned AS DOUBLE) AS earned,
        'elite-pro' AS business_line
    FROM pk_revenue_analysis.consolidated_b2c_elitepro_fy27h1
    WHERE COALESCE(purchase_date, DATE '2022-01-01') >= DATE '1900-01-01'

    UNION ALL

    -- /* PT - legacy */
    -- SELECT
    --     fy,
    --     order_id,
    --     CAST(earned AS DOUBLE) AS earned,
    --     'pt' AS business_line
    -- FROM pk_revenue_analysis.consolidated_b2c_pt
    -- WHERE COALESCE(fy, '') NOT LIKE '%25-26%'

    -- UNION ALL

 --    /* PT - 2026 */
 --    SELECT
 --        fy,
 --        order_id,
 --        CAST(earned AS DOUBLE) AS earned,
 --        'pt' AS business_line
 --    FROM pk_revenue_analysis.consolidated_b2c_pt_2026 
 --    WHERE COALESCE(purchase_date, DATE '2022-01-01') >= DATE '1900-01-01'

	-- UNION ALL

    /* PT - 2025 H1 */
    SELECT
        '25-26 H1' fy,
        CAST(order_id AS VARCHAR) order_id,
        CAST(earned AS DOUBLE) AS earned,
        'pt' AS business_line
    FROM pk_revenue_analysis.consolidated_b2c_pt_h1
    WHERE COALESCE(purchase_date, DATE '2022-01-01') >= DATE '1900-01-01'

	UNION ALL

    /* PT - 2026 H1*/
    SELECT
        '26-27 H1' fy,
        CAST(order_id AS VARCHAR) order_id,
        CAST(earned AS DOUBLE) AS earned,
        'pt' AS business_line
    FROM pk_revenue_analysis.consolidated_b2c_pt_fy27h1
    WHERE COALESCE(purchase_date, DATE '2022-01-01') >= DATE '1900-01-01'

    -- UNION ALL

    -- /* Play - legacy */
    -- SELECT
    --     fy,
    --     order_id,
    --     CAST(earned AS DOUBLE) AS earned,
    --     'play' AS business_line
    -- FROM pk_revenue_analysis.consolidated_b2c_play
    -- WHERE COALESCE(fy, '') NOT LIKE '%25-26%'

    -- UNION ALL

    -- /* Play - 2026 */
    -- SELECT
    --     fy,
    --     order_id,
    --     CAST(earned AS DOUBLE) AS earned,
    --     'play' AS business_line
    -- FROM pk_revenue_analysis.consolidated_b2c_play_2026
    -- WHERE COALESCE(purchase_date, DATE '2022-01-01') >= DATE '1900-01-01'

	UNION ALL

    /* Play - 2025 H1 */
    SELECT
        '25-26 H1' fy,
        order_id,
        CAST(earned AS DOUBLE) AS earned,
        'play' AS business_line
    FROM pk_revenue_analysis.consolidated_b2c_play_h1
    WHERE COALESCE(purchase_date, DATE '2022-01-01') >= DATE '1900-01-01'

	UNION ALL

    /* Play - 2026 H1 */
    SELECT
        '26-27 H1' fy,
        order_id,
        CAST(earned AS DOUBLE) AS earned,
        'play' AS business_line
    FROM pk_revenue_analysis.consolidated_b2c_play_fy27h1
    WHERE COALESCE(purchase_date, DATE '2022-01-01') >= DATE '1900-01-01'

    -- UNION ALL

    /* Lux
       Replace the table below with the Lux source table if it is separate.
       The current query you provided does not contain a Lux table.
    */
	
    -- SELECT
    --     fy,
    --     order_id,
    --     CAST(earned AS DOUBLE) AS earned,
    --     'lux' AS business_line
    -- FROM pk_revenue_analysis.consolidated_b2c_lux
    -- WHERE COALESCE(fy, '') NOT LIKE '%25-26%'
    --   AND COALESCE(purchase_date, DATE '2022-01-01') >= DATE '1900-01-01'

	-- UNION ALL
	--  /* Lux - 2026 */
 --    SELECT
 --        fy,
 --        order_id,
 --        CAST(earned AS DOUBLE) AS earned,
 --        'lux' AS business_line
 --    FROM pk_revenue_analysis.consolidated_b2c_lux_2026
 --    WHERE COALESCE(purchase_date, DATE '2022-01-01') >= DATE '1900-01-01'

	UNION ALL
	 /* Lux - 2025 H1 */
    SELECT
        '25-26 H1' fy,
        order_id,
        CAST(earned AS DOUBLE) AS earned,
        'lux' AS business_line
    FROM pk_revenue_analysis.consolidated_b2c_lux_h1
    WHERE COALESCE(purchase_date, DATE '2022-01-01') >= DATE '1900-01-01'

	UNION ALL
	 /* Lux - 2026 H1 */
    SELECT
        '26-27 H1' fy,
        order_id,
        CAST(earned AS DOUBLE) AS earned,
        'lux' AS business_line
    FROM pk_revenue_analysis.consolidated_b2c_lux_fy27h1
    WHERE COALESCE(purchase_date, DATE '2022-01-01') >= DATE '1900-01-01'
),


ledger_credit AS (
    SELECT
        CAST(order_id AS VARCHAR) AS order_id,

      CASE
    WHEN MAX(
        CASE
            WHEN LOWER(
                COALESCE(
                    selected_payment_mode,
                    group_order_payment_mode,
                    max_payment_channel,
                    group_order_payment_channel,
                    payment_gateway,
                    pg_method,
                    method_detail
                )
            ) LIKE '%cash%'
            OR LOWER(
                COALESCE(
                    selected_payment_mode,
                    group_order_payment_mode,
                    max_payment_channel,
                    group_order_payment_channel,
                    payment_gateway,
                    pg_method,
                    method_detail
                )
            ) LIKE '%manual%'
            THEN 1
            ELSE 0
        END
    ) = 1
    THEN 'cash'

    WHEN MAX(
        CASE
            WHEN LOWER(
                COALESCE(
                    selected_payment_mode,
                    group_order_payment_mode,
                    max_payment_channel,
                    group_order_payment_channel,
                    payment_gateway,
                    pg_method,
                    method_detail
                )
            ) LIKE '%pos%'
            THEN 1
            ELSE 0
        END
    ) = 1
    THEN 'pos'

    ELSE 'online'
END AS order_payment_type

    FROM dwh_finance.consolidated_ledger_v2
    WHERE revenue_type = 'Credit'
      AND order_id IS NOT NULL
    GROUP BY CAST(order_id AS VARCHAR)
)

SELECT
    b.fy,
    b.business_line,
    COALESCE(l.order_payment_type, 'online') AS order_payment_type,
    SUM(b.earned) AS earned
FROM b2c_union b
LEFT JOIN ledger_credit l
    ON CAST(b.order_id AS VARCHAR) = l.order_id
GROUP BY
    b.fy,
    b.business_line,
    COALESCE(l.order_payment_type, 'online')
ORDER BY
    b.fy,
    b.business_line,
    order_payment_type
