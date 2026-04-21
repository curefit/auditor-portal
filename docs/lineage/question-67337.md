# # Installs by type & source - Duplicate

- Root key: `question-67337`
- Metabase type: `question`
- Root ID: `67337`
- Source URL: `https://metabase.curefit.co/question/67337-installs-by-type-source-duplicate?Time_Granularity=Month&From=2022-04-01&To=2025-12-31&City=&Campaign=&Value_Type=Users`
- Tables detected: `1`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `67337` `# Installs by type & source - Duplicate` (role: `root_question`, parent: `root`)
  SQL: [`queries/67337__installs-by-type-source-duplicate.sql`](../../artifacts/queries/67337__installs-by-type-source-duplicate.sql)
  Result CSV: [`results/question-67337__67337__installs-by-type-source-duplicate.csv`](../../artifacts/results/question-67337__67337__installs-by-type-source-duplicate.csv)
  Preview: [`previews/question-67337__67337__installs-by-type-source-duplicate.html`](../../artifacts/previews/question-67337__67337__installs-by-type-source-duplicate.html)

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `dwh_growth_mart.growth_install_fact` | `table` | `67337` | Acquisition or traffic dataset used for install or funnel metrics. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |

## Query File References

- Card `67337`: [`queries/67337__installs-by-type-source-duplicate.sql`](../../artifacts/queries/67337__installs-by-type-source-duplicate.sql)

## Evidence Files

- Result CSV for card `67337`: [`results/question-67337__67337__installs-by-type-source-duplicate.csv`](../../artifacts/results/question-67337__67337__installs-by-type-source-duplicate.csv)
- Preview for card `67337`: [`previews/question-67337__67337__installs-by-type-source-duplicate.html`](../../artifacts/previews/question-67337__67337__installs-by-type-source-duplicate.html)
- Lineage preview for card `67337`: [`previews/question-67337__67337__installs-by-type-source-duplicate__lineage.html`](../../artifacts/previews/question-67337__67337__installs-by-type-source-duplicate__lineage.html)
