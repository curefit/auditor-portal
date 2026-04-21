# Pauses Extensions

- Root key: `question-75628`
- Metabase type: `question`
- Root ID: `75628`
- Source URL: `https://metabase.curefit.co/question/75628-pauses-extensions?ed=2025-12-31`
- Tables detected: `5`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `75628` `Pauses Extensions` (role: `root_question`, parent: `root`)
  SQL: [`queries/75628__pauses-extensions.sql`](../../artifacts/queries/75628__pauses-extensions.sql)
  Result CSV: [`results/question-75628__75628__pauses-extensions.csv`](../../artifacts/results/question-75628__75628__pauses-extensions.csv)
  Preview: [`previews/question-75628__75628__pauses-extensions.html`](../../artifacts/previews/question-75628__75628__pauses-extensions.html)

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `parent_child_map` | `cte` | `75628` | Intermediate CTE defined inside the SQL and reused later in the query. | Relation not found in local dbt manifest. |
| `base` | `table` | `75628` | Base dataset that anchors the row set for this query. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |
| `dwh_fitness_bi.pause_and_extension_fact` | `table` | `75628` | Joined dataset used to enrich, filter, or aggregate the base query rows. It appears through a LEFT JOIN clause. | Relation not found in local dbt manifest. |
| `dwh_fitness_mart.membership_dim` | `table` | `75628` | Membership context used for pack, user, or active-membership logic. It appears in the primary FROM clause. | - |
| `dwh_fitness_mart.orders_fact` | `table` | `75628` | Transaction dataset used for order, revenue, or sales measures. It appears through a LEFT JOIN clause. | - |
| `pk_curefitplatforms_membershipdb.memberships` | `table` | `75628` | Membership context used for pack, user, or active-membership logic. It appears in the primary FROM clause. | - |

## Query File References

- Card `75628`: [`queries/75628__pauses-extensions.sql`](../../artifacts/queries/75628__pauses-extensions.sql)

## Evidence Files

- Result CSV for card `75628`: [`results/question-75628__75628__pauses-extensions.csv`](../../artifacts/results/question-75628__75628__pauses-extensions.csv)
- Preview for card `75628`: [`previews/question-75628__75628__pauses-extensions.html`](../../artifacts/previews/question-75628__75628__pauses-extensions.html)
- Lineage preview for card `75628`: [`previews/question-75628__75628__pauses-extensions__lineage.html`](../../artifacts/previews/question-75628__75628__pauses-extensions__lineage.html)
