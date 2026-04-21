# GX formats

- Root key: `question-75654`
- Metabase type: `question`
- Root ID: `75654`
- Source URL: `https://metabase.curefit.co/question/75654-gx-formats?Last_date=2025-12-31`
- Tables detected: `7`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|result_blocked`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `75654` `GX formats` (role: `root_question`, parent: `root`)
  SQL: [`queries/75654__gx-formats.sql`](../../artifacts/queries/75654__gx-formats.sql)
  Notes: The read operation timed out

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `all_sessions_df` | `cte` | `75654` | Intermediate CTE defined inside the SQL and reused later in the query. | Relation not found in local dbt manifest. |
| `User_classes` | `table` | `75654` | Joined dataset used to enrich, filter, or aggregate the base query rows. | Relation not found in local dbt manifest. |
| `base` | `table` | `75654` | Base dataset that anchors the row set for this query. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |
| `dwh_fitness_mart.booking_fact` | `table` | `75654` | Activity/booking dataset used to measure usage, attendance, or visits. It appears through a JOIN clause. | - |
| `dwh_fitness_mart.center_dim` | `table` | `75654` | Location lookup used to attach center, city, or operating-unit attributes. It appears through a LEFT JOIN clause. | - |
| `dwh_fitness_mart.employee_dim` | `table` | `75654` | Joined dataset used to enrich, filter, or aggregate the base query rows. It appears through a LEFT JOIN clause. | - |
| `dwh_fitness_mart.membership_dim` | `table` | `75654` | Membership context used for pack, user, or active-membership logic. It appears in the primary FROM clause. | - |
| `dwh_fitness_mart.workout_dim` | `table` | `75654` | Joined dataset used to enrich, filter, or aggregate the base query rows. It appears through a LEFT JOIN clause. | - |

## Query File References

- Card `75654`: [`queries/75654__gx-formats.sql`](../../artifacts/queries/75654__gx-formats.sql)

## Evidence Files

- No result or preview artifacts were available for this root.
