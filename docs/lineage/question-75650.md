# Same city vs other city - Modified

- Root key: `question-75650`
- Metabase type: `question`
- Root ID: `75650`
- Source URL: `https://metabase.curefit.co/question/75650-same-city-vs-other-city-modified?Last_date=2026-02-09`
- Tables detected: `4`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|result_blocked`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `75650` `Same city vs other city - Modified` (role: `root_question`, parent: `root`)
  SQL: [`queries/75650__same-city-vs-other-city-modified.sql`](../../artifacts/queries/75650__same-city-vs-other-city-modified.sql)
  Notes: The read operation timed out

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `base` | `table` | `75650` | Base dataset that anchors the row set for this query. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |
| `dwh_fitness_mart.booking_fact` | `table` | `75650` | Activity/booking dataset used to measure usage, attendance, or visits. It appears through a JOIN clause. | - |
| `dwh_fitness_mart.center_dim` | `table` | `75650` | Location lookup used to attach center, city, or operating-unit attributes. It appears through a JOIN clause. | - |
| `dwh_fitness_mart.membership_dim` | `table` | `75650` | Membership context used for pack, user, or active-membership logic. It appears in the primary FROM clause. | - |

## Query File References

- Card `75650`: [`queries/75650__same-city-vs-other-city-modified.sql`](../../artifacts/queries/75650__same-city-vs-other-city-modified.sql)

## Evidence Files

- No result or preview artifacts were available for this root.
