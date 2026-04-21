# Same center vs other center

- Root key: `question-75647`
- Metabase type: `question`
- Root ID: `75647`
- Source URL: `https://metabase.curefit.co/question/75647-same-center-vs-other-center?Last_date=2026-02-09`
- Tables detected: `4`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `75647` `Same center vs other center` (role: `root_question`, parent: `root`)
  SQL: [`queries/75647__same-center-vs-other-center.sql`](../../artifacts/queries/75647__same-center-vs-other-center.sql)
  Result CSV: [`results/question-75647__75647__same-center-vs-other-center.csv`](../../artifacts/results/question-75647__75647__same-center-vs-other-center.csv)
  Preview: [`previews/question-75647__75647__same-center-vs-other-center.html`](../../artifacts/previews/question-75647__75647__same-center-vs-other-center.html)

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `base` | `table` | `75647` | Base dataset that anchors the row set for this query. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |
| `dwh_fitness_mart.booking_fact` | `table` | `75647` | Activity/booking dataset used to measure usage, attendance, or visits. It appears through a JOIN clause. | - |
| `dwh_fitness_mart.center_dim` | `table` | `75647` | Location lookup used to attach center, city, or operating-unit attributes. It appears through a JOIN clause. | - |
| `dwh_fitness_mart.membership_dim` | `table` | `75647` | Membership context used for pack, user, or active-membership logic. It appears in the primary FROM clause. | - |

## Query File References

- Card `75647`: [`queries/75647__same-center-vs-other-center.sql`](../../artifacts/queries/75647__same-center-vs-other-center.sql)

## Evidence Files

- Result CSV for card `75647`: [`results/question-75647__75647__same-center-vs-other-center.csv`](../../artifacts/results/question-75647__75647__same-center-vs-other-center.csv)
- Preview for card `75647`: [`previews/question-75647__75647__same-center-vs-other-center.html`](../../artifacts/previews/question-75647__75647__same-center-vs-other-center.html)
- Lineage preview for card `75647`: [`previews/question-75647__75647__same-center-vs-other-center__lineage.html`](../../artifacts/previews/question-75647__75647__same-center-vs-other-center__lineage.html)
