# Monthly active memberships ELITE, PRO, PLAY, LUX

- Root key: `question-75114`
- Metabase type: `question`
- Root ID: `75114`
- Source URL: `https://metabase.curefit.co/question/75114-monthly-active-memberships-elite-pro-play-lux?Start_Date=2023-04-01&end_date=2025-12-31`
- Tables detected: `2`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|result_blocked`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `75114` `Monthly active memberships ELITE, PRO, PLAY, LUX` (role: `root_question`, parent: `root`)
  SQL: [`queries/75114__monthly-active-memberships-elite-pro-play-lux.sql`](../../artifacts/queries/75114__monthly-active-memberships-elite-pro-play-lux.sql)
  Notes: The read operation timed out

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `activeMemberships` | `cte` | `75114` | Intermediate CTE defined inside the SQL and reused later in the query. | Relation not found in local dbt manifest. |
| `liveMemberships` | `cte` | `75114` | Intermediate CTE defined inside the SQL and reused later in the query. | Relation not found in local dbt manifest. |
| `dwh_curefit.dim_date` | `table` | `75114` | Calendar/date spine used to define reporting periods or time buckets. | - |
| `dwh_fitness_mart.membership_dim` | `table` | `75114` | Membership context used for pack, user, or active-membership logic. It appears through a LEFT JOIN clause. | - |

## Query File References

- Card `75114`: [`queries/75114__monthly-active-memberships-elite-pro-play-lux.sql`](../../artifacts/queries/75114__monthly-active-memberships-elite-pro-play-lux.sql)

## Evidence Files

- No result or preview artifacts were available for this root.
