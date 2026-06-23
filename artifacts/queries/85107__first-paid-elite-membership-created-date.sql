SELECT
    MIN(membership_created_date) AS first_paid_elite_membership_created_date
FROM dwh_fitness_mart.membership_fact
  WHERE business_line = 'ELITE'
  AND COALESCE(amount_paid, 0) > 0
  AND transaction_date = date('2026-06-16')
