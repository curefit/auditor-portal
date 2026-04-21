# Daily metrics - Tanmai v2 - With end date

- Root key: `question-76611`
- Metabase type: `question`
- Root ID: `76611`
- Source URL: `https://metabase.curefit.co/question/76611-daily-metrics-tanmai-v2-with-end-date?Start_Date=2023-04-01&End_Date=2026-03-31`
- Tables detected: `6`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|result_blocked`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `76611` `Daily metrics - Tanmai v2 - With end date` (role: `root_question`, parent: `root`)
  SQL: [`queries/76611__daily-metrics-tanmai-v2-with-end-date.sql`](../../artifacts/queries/76611__daily-metrics-tanmai-v2-with-end-date.sql)
  Notes: The read operation timed out

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `dwh_fitness.fitness_orders` | `table` | `76611` | Transaction dataset used for order, revenue, or sales measures. It appears through a LEFT JOIN clause. | Relation not found in local dbt manifest. |
| `dwh_fitness_mart.center_dim` | `table` | `76611` | Location lookup used to attach center, city, or operating-unit attributes. It appears through a LEFT JOIN clause. | - |
| `dwh_fitness_mart.membership_dim` | `table` | `76611` | Membership context used for pack, user, or active-membership logic. It appears in the primary FROM clause. | - |
| `dwh_fitness_mart.orders_fact` | `table` | `76611` | Transaction dataset used for order, revenue, or sales measures. It appears through a LEFT JOIN clause. | - |
| `pk_prod_curefit_prod.orders` | `table` | `76611` | Transaction dataset used for order, revenue, or sales measures. It appears in the primary FROM clause. | - |
| `pk_prod_curefit_prod.orders_payments` | `table` | `76611` | Transaction dataset used for order, revenue, or sales measures. It appears through a LEFT JOIN clause. | - |

## Query File References

- Card `76611`: [`queries/76611__daily-metrics-tanmai-v2-with-end-date.sql`](../../artifacts/queries/76611__daily-metrics-tanmai-v2-with-end-date.sql)

## Evidence Files

- No result or preview artifacts were available for this root.
