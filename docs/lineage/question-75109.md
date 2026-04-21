# Memberships by Each Business Line - End of Each Month - including all packs

- Root key: `question-75109`
- Metabase type: `question`
- Root ID: `75109`
- Source URL: `https://metabase.curefit.co/question/75109-memberships-by-each-business-line-end-of-each-month-including-all-packs?start_date=2025-09-01&end_date=2026-01-31`
- Tables detected: `2`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `75109` `Memberships by Each Business Line - End of Each Month - including all packs` (role: `root_question`, parent: `root`)
  SQL: [`queries/75109__memberships-by-each-business-line-end-of-each-month-including-all-packs.sql`](../../artifacts/queries/75109__memberships-by-each-business-line-end-of-each-month-including-all-packs.sql)
  Result CSV: [`results/question-75109__75109__memberships-by-each-business-line-end-of-each-month-including-all-packs.csv`](../../artifacts/results/question-75109__75109__memberships-by-each-business-line-end-of-each-month-including-all-packs.csv)
  Preview: [`previews/question-75109__75109__memberships-by-each-business-line-end-of-each-month-including-all-packs.html`](../../artifacts/previews/question-75109__75109__memberships-by-each-business-line-end-of-each-month-including-all-packs.html)

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `dates` | `cte` | `75109` | Intermediate CTE defined inside the SQL and reused later in the query. | Relation not found in local dbt manifest. |
| `dwh_curefit.dim_date` | `table` | `75109` | Calendar/date spine used to define reporting periods or time buckets. It appears in the primary FROM clause. | - |
| `dwh_fitness_mart.membership_dim` | `table` | `75109` | Membership context used for pack, user, or active-membership logic. It appears in the primary FROM clause. | - |

## Query File References

- Card `75109`: [`queries/75109__memberships-by-each-business-line-end-of-each-month-including-all-packs.sql`](../../artifacts/queries/75109__memberships-by-each-business-line-end-of-each-month-including-all-packs.sql)

## Evidence Files

- Result CSV for card `75109`: [`results/question-75109__75109__memberships-by-each-business-line-end-of-each-month-including-all-packs.csv`](../../artifacts/results/question-75109__75109__memberships-by-each-business-line-end-of-each-month-including-all-packs.csv)
- Preview for card `75109`: [`previews/question-75109__75109__memberships-by-each-business-line-end-of-each-month-including-all-packs.html`](../../artifacts/previews/question-75109__75109__memberships-by-each-business-line-end-of-each-month-including-all-packs.html)
- Lineage preview for card `75109`: [`previews/question-75109__75109__memberships-by-each-business-line-end-of-each-month-including-all-packs__lineage.html`](../../artifacts/previews/question-75109__75109__memberships-by-each-business-line-end-of-each-month-including-all-packs__lineage.html)
