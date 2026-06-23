WITH first_paid_user_date AS (
    SELECT
        user_id,
        MIN(membership_created_date) AS first_paid_membership_created_date
    FROM dwh_fitness_mart.membership_fact
    WHERE COALESCE(amount_paid, 0) > 0
      AND user_id IS NOT NULL
	  AND transaction_date = date('2026-06-16')
    GROUP BY 1
),
daily_new_paid_users AS (
    SELECT
        first_paid_membership_created_date AS milestone_date,
        COUNT(DISTINCT user_id) AS new_paid_users
    FROM first_paid_user_date
    GROUP BY 1
),
running_paid_users AS (
    SELECT
        milestone_date,
        new_paid_users,
        SUM(new_paid_users) OVER (
            ORDER BY milestone_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_paid_users
    FROM daily_new_paid_users
)
SELECT
    MIN(milestone_date) AS date_100k_paid_users_reached
FROM running_paid_users
WHERE cumulative_paid_users >= 100000
