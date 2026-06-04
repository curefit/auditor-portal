# 12M Packs Sold Monthly Jun 2026

- Root key: `question-83969`
- Metabase type: `question`
- Root ID: `83969`
- Source URL: `https://metabase.curefit.co/question/83969-12m-packs-sold-monthly-jun-2026?Start_Date=2023-04-01&End_Date=2026-03-31`
- Tables detected: `4`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|raw_csv`
- Notes: Lineage reflects tables used by card 83969 SQL.

## Metabase Cards

- Card `83969` `12M Packs Sold Monthly Jun 2026` (role: `root_question`, parent: `root`)
  SQL: [`queries/83969__12m-packs-sold-monthly-jun-2026.sql`](../../artifacts/queries/83969__12m-packs-sold-monthly-jun-2026.sql)

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `dwh_fitness_mart.center_dim` | `table` | `83969` | Location lookup used to attach center, city, or operating-unit attributes. | - |
| `dwh_fitness_mart.membership_dim` | `table` | `83969` | Membership context used for pack, user, purchase-date, amount-paid, and duration logic. | - |
| `dwh_fitness_mart.orders_fact` | `table` | `83969` | Order context used for city and retained original pack-grain attribution. | - |
| `pk_curefitplatforms_membershipdb.memberships` | `table` | `83969` | Membership service dates used when transferred or upgraded packs need source-system dates. | Added for the corrected date-source logic. |

## Query File References

- Card `83969`: [`queries/83969__12m-packs-sold-monthly-jun-2026.sql`](../../artifacts/queries/83969__12m-packs-sold-monthly-jun-2026.sql)

## Evidence Files

- CSV: [`results/question-83969__83969__12m-packs-sold-monthly-jun-2026.csv`](../../artifacts/results/question-83969__83969__12m-packs-sold-monthly-jun-2026.csv)
- JSON: [`results/question-83969__83969__12m-packs-sold-monthly-jun-2026.json`](../../artifacts/results/question-83969__83969__12m-packs-sold-monthly-jun-2026.json)
