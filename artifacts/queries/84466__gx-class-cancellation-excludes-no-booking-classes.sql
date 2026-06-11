/*
Purpose:
Calculate GX class cancellation % by financial year, excluding classes that
do not have a relevant member booking.

Business interpretation:
A class should be considered for cancellation reporting only if it had a
relevant booking. Classes with no relevant booking are excluded because the
business does not treat them as true cancelled classes.

Why this is conservative:
For cancelled classes, we only count bookings that line up with the class
cancellation event. This avoids counting classes as cancelled just because
they had some historical booking activity.
*/

WITH eligible_classes AS (

    /*
    Step 1:
    Build one clean row per class.

    We start from the class table and join to the bookings table to check
    whether the class had a relevant booking.
    */
    SELECT
        a.id,
        DATE(a.date) AS class_date,
        a.isactive

    FROM pk_cultprod_cultapp.cultclass a

    JOIN dwh_fitness.fitness_bookings b
        ON a.id = b.class_id

       /*
       Keep only GX / center class bookings.
       */
       AND b.category = 'ELITE_CENTER'

       /*
       Required booking date filter.
       This keeps the scan limited to the FY24-FY26 reporting window.
       */
       AND b.class_date BETWEEN DATE '2023-04-01' AND DATE '2026-03-31'

    WHERE DATE(a.date) BETWEEN DATE '2023-04-01' AND DATE '2026-03-31'

      /*
      Exclude deleted class records.
      */
      AND a.deletedat IS NULL

      /*
      Existing data-quality filter from the original card.
      */
      AND DATE(a.createdat_date) >= DATE '2019-01-01'

    /*
    One class can have multiple bookings, so group to avoid duplicate class rows.
    */
    GROUP BY 1, 2, 3

    /*
    Eligibility rule:
    Keep only classes with relevant bookings.

    For active classes:
    A booking is relevant only if the booking status is BOOKED.

    For cancelled classes:
    A booking is relevant only if the booking update timestamp matches the
    class cancellation timestamp.

    Reason:
    This follows the CST class-data logic and prevents cancelled classes with
    unrelated booking history from inflating the cancellation percentage.
    */
    HAVING COUNT(DISTINCT CASE
        WHEN a.isactive = 1
         AND b.status = 'BOOKED'
        THEN b.elite_bookingid

        WHEN a.isactive = 0
         AND a.updatedat = b.updated_at
        THEN b.elite_bookingid
    END) > 0
)

SELECT
    /*
    FY24 cancellation %:
    cancelled eligible classes in FY24
    divided by
    total eligible classes in FY24.
    */
    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN isactive = 0
             AND class_date BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'
            THEN id
        END)
        /
        NULLIF(
            COUNT(DISTINCT CASE
                WHEN class_date BETWEEN DATE '2023-04-01' AND DATE '2024-03-31'
                THEN id
            END),
            0
        ),
        2
    ) AS FY24_Cancelled_Pct,

    /*
    FY25 cancellation %.
    */
    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN isactive = 0
             AND class_date BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'
            THEN id
        END)
        /
        NULLIF(
            COUNT(DISTINCT CASE
                WHEN class_date BETWEEN DATE '2024-04-01' AND DATE '2025-03-31'
                THEN id
            END),
            0
        ),
        2
    ) AS FY25_Cancelled_Pct,

    /*
    FY26 cancellation %.
    */
    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN isactive = 0
             AND class_date BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'
            THEN id
        END)
        /
        NULLIF(
            COUNT(DISTINCT CASE
                WHEN class_date BETWEEN DATE '2025-04-01' AND DATE '2026-03-31'
                THEN id
            END),
            0
        ),
        2
    ) AS FY26_Cancelled_Pct

FROM eligible_classes
