-- Purpose:
--   Show GX class utilization by hour of day, split by financial year.
--
-- Business definition:
--   Utilization % = total attended bookings / total scheduled capacity * 100
--
-- Plain-English summary:
--   1. Take all uncancelled scheduled GX classes in the reporting period.
--   2. Count attended bookings for each class.
--   3. Capture each class's scheduled capacity.
--   4. Aggregate attendance and capacity by financial year and class start hour.
--   5. Calculate utilization as total attendance divided by total capacity.
--
-- Auditor note:
--   This query uses weighted utilization:
--     SUM(attendance) / SUM(capacity)
--
--   This is different from averaging each class's utilization percentage.
--   Weighted utilization is the correct method when the definition is:
--     total footfalls / total capacity

WITH class_utilization AS (

    SELECT
        -- Financial year mapping.
        --
        -- FY24 = Apr 2023 to Mar 2024
        -- FY25 = Apr 2024 to Mar 2025
        -- FY26 = Apr 2025 to Mar 2026
        CASE
            WHEN DATE(a.date) BETWEEN DATE('2023-04-01') AND DATE('2024-03-31') THEN 'FY24'
            WHEN DATE(a.date) BETWEEN DATE('2024-04-01') AND DATE('2025-03-31') THEN 'FY25'
            WHEN DATE(a.date) BETWEEN DATE('2025-04-01') AND DATE('2026-03-31') THEN 'FY26'
        END AS fy,

        -- Class start hour.
        -- Example: a class starting at 7:30 is grouped under hour 7.
        EXTRACT(HOUR FROM a.startdatetimeutc) AS class_hour,

        -- One row per scheduled class.
        a.id AS class_id,

        -- Attended bookings for this class.
        -- DISTINCT protects against duplicate booking rows.
        COUNT(
            DISTINCT CASE
                WHEN fb.attendance_time IS NOT NULL
                THEN fb.elite_bookingid
            END
        ) AS attendance,

        -- Scheduled capacity for this class.
        -- MAX is used because joining bookings creates multiple rows per class.
        -- Capacity itself is a class-level value, so MAX collapses it back to
        -- one value per class.
        MAX(a.totalseats) AS capacity

    FROM pk_cultprod_cultapp.cultclass a

    LEFT JOIN dwh_fitness.fitness_bookings fb
        ON a.id = fb.class_id
       AND fb.category = 'ELITE_CENTER'
       AND DATE(fb.class_date) BETWEEN DATE('2023-04-01') AND DATE('2026-03-31')

    WHERE DATE(a.date) BETWEEN DATE('2023-04-01') AND DATE('2026-03-31')
      AND DATE(a.createdat_date) BETWEEN DATE('2023-04-01') AND DATE('2026-03-31')

      -- Exclude cancelled/deleted classes.
      -- These should not contribute attendance or scheduled capacity.
      AND a.deletedat IS NULL

    GROUP BY 1,2,3
),

hourly_utilization AS (

    SELECT
        fy,
        class_hour,

        -- Total attended bookings for this FY-hour bucket.
        SUM(attendance) AS total_attendance,

        -- Total scheduled seats for uncancelled classes in this FY-hour bucket.
        SUM(capacity) AS total_capacity,

        -- Correct utilization definition:
        -- total attendance divided by total capacity.
        100.0 * SUM(attendance) / NULLIF(SUM(capacity), 0) AS utilization_pct

    FROM class_utilization
    WHERE fy IS NOT NULL
    GROUP BY 1,2
)

SELECT
    fy,

    -- Each hourly column is:
    --   total attendance in that FY-hour / total capacity in that FY-hour
    ROUND(MAX(CASE WHEN class_hour = 5 THEN utilization_pct END),1)  AS hr_05,
    ROUND(MAX(CASE WHEN class_hour = 6 THEN utilization_pct END),1)  AS hr_06,
    ROUND(MAX(CASE WHEN class_hour = 7 THEN utilization_pct END),1)  AS hr_07,
    ROUND(MAX(CASE WHEN class_hour = 8 THEN utilization_pct END),1)  AS hr_08,
    ROUND(MAX(CASE WHEN class_hour = 9 THEN utilization_pct END),1)  AS hr_09,
    ROUND(MAX(CASE WHEN class_hour = 10 THEN utilization_pct END),1) AS hr_10,
    ROUND(MAX(CASE WHEN class_hour = 11 THEN utilization_pct END),1) AS hr_11,
    ROUND(MAX(CASE WHEN class_hour = 12 THEN utilization_pct END),1) AS hr_12,
    ROUND(MAX(CASE WHEN class_hour = 13 THEN utilization_pct END),1) AS hr_13,
    ROUND(MAX(CASE WHEN class_hour = 14 THEN utilization_pct END),1) AS hr_14,
    ROUND(MAX(CASE WHEN class_hour = 15 THEN utilization_pct END),1) AS hr_15,
    ROUND(MAX(CASE WHEN class_hour = 16 THEN utilization_pct END),1) AS hr_16,
    ROUND(MAX(CASE WHEN class_hour = 17 THEN utilization_pct END),1) AS hr_17,
    ROUND(MAX(CASE WHEN class_hour = 18 THEN utilization_pct END),1) AS hr_18,
    ROUND(MAX(CASE WHEN class_hour = 19 THEN utilization_pct END),1) AS hr_19,
    ROUND(MAX(CASE WHEN class_hour = 20 THEN utilization_pct END),1) AS hr_20,
    ROUND(MAX(CASE WHEN class_hour = 21 THEN utilization_pct END),1) AS hr_21

FROM hourly_utilization

GROUP BY fy

ORDER BY fy

-- WITH class_utilization AS (

--     SELECT
--         CASE
--             WHEN DATE(a.date) BETWEEN DATE('2023-04-01') AND DATE('2024-03-31') THEN 'FY24'
--             WHEN DATE(a.date) BETWEEN DATE('2024-04-01') AND DATE('2025-03-31') THEN 'FY25'
--             WHEN DATE(a.date) BETWEEN DATE('2025-04-01') AND DATE('2026-03-31') THEN 'FY26'
--         END AS fy,

--         EXTRACT(HOUR FROM a.startdatetimeutc) AS class_hour,

--         a.id AS class_id,

--         COUNT(
--             DISTINCT CASE
--                 WHEN fb.attendance_time IS NOT NULL
--                 THEN fb.elite_bookingid
--             END
--         ) AS attendance,

--         MAX(a.totalseats) AS capacity

--     FROM pk_cultprod_cultapp.cultclass a

--     LEFT JOIN dwh_fitness.fitness_bookings fb
--         ON a.id = fb.class_id
--        AND fb.category = 'ELITE_CENTER'
--        AND DATE(fb.class_date) BETWEEN DATE('2023-04-01') AND DATE('2026-03-31')

--     WHERE DATE(a.date) BETWEEN DATE('2023-04-01') AND DATE('2026-03-31')
--       AND DATE(a.createdat_date) BETWEEN DATE('2023-04-01') AND DATE('2026-03-31')
--       AND a.deletedat IS NULL

--     GROUP BY 1,2,3
-- ),

-- class_util_pct AS (

--     SELECT
--         fy,
--         class_hour,
--         class_id,
--         100.0 * attendance / NULLIF(capacity,0) AS utilization_pct
--     FROM class_utilization
--     WHERE fy IS NOT NULL
-- )

-- SELECT
--     fy,

--     ROUND(AVG(CASE WHEN class_hour = 5 THEN utilization_pct END),1)  AS hr_05,
--     ROUND(AVG(CASE WHEN class_hour = 6 THEN utilization_pct END),1)  AS hr_06,
--     ROUND(AVG(CASE WHEN class_hour = 7 THEN utilization_pct END),1)  AS hr_07,
--     ROUND(AVG(CASE WHEN class_hour = 8 THEN utilization_pct END),1)  AS hr_08,
--     ROUND(AVG(CASE WHEN class_hour = 9 THEN utilization_pct END),1)  AS hr_09,
--     ROUND(AVG(CASE WHEN class_hour = 10 THEN utilization_pct END),1) AS hr_10,
--     ROUND(AVG(CASE WHEN class_hour = 11 THEN utilization_pct END),1) AS hr_11,
--     ROUND(AVG(CASE WHEN class_hour = 12 THEN utilization_pct END),1) AS hr_12,
--     ROUND(AVG(CASE WHEN class_hour = 13 THEN utilization_pct END),1) AS hr_13,
--     ROUND(AVG(CASE WHEN class_hour = 14 THEN utilization_pct END),1) AS hr_14,
--     ROUND(AVG(CASE WHEN class_hour = 15 THEN utilization_pct END),1) AS hr_15,
--     ROUND(AVG(CASE WHEN class_hour = 16 THEN utilization_pct END),1) AS hr_16,
--     ROUND(AVG(CASE WHEN class_hour = 17 THEN utilization_pct END),1) AS hr_17,
--     ROUND(AVG(CASE WHEN class_hour = 18 THEN utilization_pct END),1) AS hr_18,
--     ROUND(AVG(CASE WHEN class_hour = 19 THEN utilization_pct END),1) AS hr_19,
--     ROUND(AVG(CASE WHEN class_hour = 20 THEN utilization_pct END),1) AS hr_20,
--     ROUND(AVG(CASE WHEN class_hour = 21 THEN utilization_pct END),1) AS hr_21

-- FROM class_util_pct

-- GROUP BY fy

-- ORDER BY fy
