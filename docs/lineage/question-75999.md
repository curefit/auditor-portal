# Page Ids Traffic

- Root key: `question-75999`
- Metabase type: `question`
- Root ID: `75999`
- Source URL: `https://metabase.curefit.co/question/75999-page-ids-traffic?Start=2022-04-01&End=2025-12-31&Time_Granularity=Month`
- Tables detected: `2`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|result_blocked`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `75999` `Page Ids Traffic` (role: `root_question`, parent: `root`)
  SQL: [`queries/75999__page-ids-traffic.sql`](../../artifacts/queries/75999__page-ids-traffic.sql)
  Notes: The read operation timed out

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `base` | `table` | `75999` | Base dataset that anchors the row set for this query. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |
| `pk_curefit_app_events.page_view` | `table` | `75999` | Acquisition or traffic dataset used for install or funnel metrics. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |

## Query File References

- Card `75999`: [`queries/75999__page-ids-traffic.sql`](../../artifacts/queries/75999__page-ids-traffic.sql)

## Evidence Files

- No result or preview artifacts were available for this root.
