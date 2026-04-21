# #Footfalls - Grained

- Root key: `question-55566`
- Metabase type: `question`
- Root ID: `55566`
- Source URL: `https://metabase.curefit.co/question/55566-footfalls-grained?Start_Date=2023-01-01&End_Date=2024-11-12&grain=quarter`
- Tables detected: `4`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `55566` `#Footfalls - Grained` (role: `root_question`, parent: `root`)
  SQL: [`queries/55566__footfalls-grained.sql`](../../artifacts/queries/55566__footfalls-grained.sql)
  Result CSV: [`results/question-55566__55566__footfalls-grained.csv`](../../artifacts/results/question-55566__55566__footfalls-grained.csv)
  Preview: [`previews/question-55566__55566__footfalls-grained.html`](../../artifacts/previews/question-55566__55566__footfalls-grained.html)

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `base` | `table` | `55566` | Base dataset that anchors the row set for this query. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |
| `dwh_fitness_mart.booking_fact` | `table` | `55566` | Activity/booking dataset used to measure usage, attendance, or visits. It appears through a JOIN clause. | - |
| `dwh_fitness_mart.center_dim` | `table` | `55566` | Location lookup used to attach center, city, or operating-unit attributes. It appears through a LEFT JOIN clause. | - |
| `dwh_fitness_mart.membership_dim` | `table` | `55566` | Membership context used for pack, user, or active-membership logic. It appears in the primary FROM clause. | - |

## Query File References

- Card `55566`: [`queries/55566__footfalls-grained.sql`](../../artifacts/queries/55566__footfalls-grained.sql)

## Evidence Files

- Result CSV for card `55566`: [`results/question-55566__55566__footfalls-grained.csv`](../../artifacts/results/question-55566__55566__footfalls-grained.csv)
- Preview for card `55566`: [`previews/question-55566__55566__footfalls-grained.html`](../../artifacts/previews/question-55566__55566__footfalls-grained.html)
- Lineage preview for card `55566`: [`previews/question-55566__55566__footfalls-grained__lineage.html`](../../artifacts/previews/question-55566__55566__footfalls-grained__lineage.html)
