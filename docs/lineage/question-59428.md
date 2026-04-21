# NPS by Product - New

- Root key: `question-59428`
- Metabase type: `question`
- Root ID: `59428`
- Source URL: `https://metabase.curefit.co/question/59428-nps-by-product-new?city_name=&end_date=2026-02-09&activity_status=actual-active&business_line=&service_type=&ownership_type=&center_name=&start_date=2025-12-01&sub_service_type=&center_service_id=`
- Tables detected: `5`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `59428` `NPS by Product - New` (role: `root_question`, parent: `root`)
  SQL: [`queries/59428__nps-by-product-new.sql`](../../artifacts/queries/59428__nps-by-product-new.sql)
  Result CSV: [`results/question-59428__59428__nps-by-product-new.csv`](../../artifacts/results/question-59428__59428__nps-by-product-new.csv)
  Preview: [`previews/question-59428__59428__nps-by-product-new.html`](../../artifacts/previews/question-59428__59428__nps-by-product-new.html)

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `individual_nps` | `cte` | `59428` | Intermediate CTE defined inside the SQL and reused later in the query. | Relation not found in local dbt manifest. |
| `platform_nps` | `cte` | `59428` | Intermediate CTE defined inside the SQL and reused later in the query. | Relation not found in local dbt manifest. |
| `combinations_base` | `table` | `59428` | Base dataset that anchors the row set for this query. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |
| `dwh_fitness_mart.center_dim` | `table` | `59428` | Location lookup used to attach center, city, or operating-unit attributes. It appears in the primary FROM clause. | - |
| `dwh_fitness_metrics.footfall_by_service_type` | `table` | `59428` | Base dataset that anchors the row set for this query. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |
| `dwh_fitness_metrics.nps_responses_base` | `table` | `59428` | Feedback dataset used for satisfaction, NPS, or response metrics. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |
| `nps_base` | `table` | `59428` | Feedback dataset used for satisfaction, NPS, or response metrics. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |

## Query File References

- Card `59428`: [`queries/59428__nps-by-product-new.sql`](../../artifacts/queries/59428__nps-by-product-new.sql)

## Evidence Files

- Result CSV for card `59428`: [`results/question-59428__59428__nps-by-product-new.csv`](../../artifacts/results/question-59428__59428__nps-by-product-new.csv)
- Preview for card `59428`: [`previews/question-59428__59428__nps-by-product-new.html`](../../artifacts/previews/question-59428__59428__nps-by-product-new.html)
- Lineage preview for card `59428`: [`previews/question-59428__59428__nps-by-product-new__lineage.html`](../../artifacts/previews/question-59428__59428__nps-by-product-new__lineage.html)
