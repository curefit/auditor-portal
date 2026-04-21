# 'At Home' footfalls

- Root key: `question-75753`
- Metabase type: `question`
- Root ID: `75753`
- Source URL: `https://metabase.curefit.co/question/75753-at-home-footfalls?grain=month`
- Tables detected: `2`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|result_blocked`

## Metabase Cards

- Card `75753` `'At Home' footfalls` (role: `root_question`, parent: `root`)
  SQL: [`queries/75753__at-home-footfalls.sql`](../../artifacts/queries/75753__at-home-footfalls.sql)
  Notes: The read operation timed out

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `dwh_fitness_mart.membership_dim` | `table` | `75753` | Membership context used for pack, user, or active-membership logic. It appears in the primary FROM clause. | - |
| `dwh_live.live_bookings` | `table` | `75753` | Activity/booking dataset used to measure usage, attendance, or visits. It appears through a LEFT JOIN clause. | - |

## Query File References

- Card `75753`: [`queries/75753__at-home-footfalls.sql`](../../artifacts/queries/75753__at-home-footfalls.sql)

## Evidence Files

- No result or preview artifacts were available for this root.
