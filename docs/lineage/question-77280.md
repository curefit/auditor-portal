# Memberships by Each Business Line - End of Each Month - including all packs -city level

- Root key: `question-77280`
- Metabase type: `question`
- Root ID: `77280`
- Source URL: `https://metabase.curefit.co/question/77280-memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level?start_date=2025-09-12&end_date=2026-03-12`
- Tables detected: `3`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `77280` `Memberships by Each Business Line - End of Each Month - including all packs -city level` (role: `root_question`, parent: `root`)
  SQL: [`queries/77280__memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level.sql`](../../artifacts/queries/77280__memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level.sql)
  Result CSV: [`results/question-77280__77280__memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level.csv`](../../artifacts/results/question-77280__77280__memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level.csv)
  Preview: [`previews/question-77280__77280__memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level.html`](../../artifacts/previews/question-77280__77280__memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level.html)

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `dates` | `cte` | `77280` | Intermediate CTE defined inside the SQL and reused later in the query. | Relation not found in local dbt manifest. |
| `dwh_curefit.dim_date` | `table` | `77280` | Calendar/date spine used to define reporting periods or time buckets. It appears in the primary FROM clause. | - |
| `dwh_fitness_mart.center_dim` | `table` | `77280` | Location lookup used to attach center, city, or operating-unit attributes. It appears through a LEFT JOIN clause. | - |
| `dwh_fitness_mart.membership_dim` | `table` | `77280` | Membership context used for pack, user, or active-membership logic. It appears in the primary FROM clause. | - |

## Query File References

- Card `77280`: [`queries/77280__memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level.sql`](../../artifacts/queries/77280__memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level.sql)

## Evidence Files

- Result CSV for card `77280`: [`results/question-77280__77280__memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level.csv`](../../artifacts/results/question-77280__77280__memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level.csv)
- Preview for card `77280`: [`previews/question-77280__77280__memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level.html`](../../artifacts/previews/question-77280__77280__memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level.html)
- Lineage preview for card `77280`: [`previews/question-77280__77280__memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level__lineage.html`](../../artifacts/previews/question-77280__77280__memberships-by-each-business-line-end-of-each-month-including-all-packs-city-level__lineage.html)
