# CST - Class data

- Root key: `question-30893`
- Metabase type: `question`
- Root ID: `30893`
- Source URL: `https://metabase.curefit.co/question/30893-cst-class-data?start=2026-03-01&workout=&cluster=&center_name=&city=&end=2026-03-12`
- Tables detected: `16`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `30893` `CST - Class data` (role: `root_question`, parent: `root`)
  SQL: [`queries/30893__cst-class-data.sql`](../../artifacts/queries/30893__cst-class-data.sql)
  Result CSV: [`results/question-30893__30893__cst-class-data.csv`](../../artifacts/results/question-30893__30893__cst-class-data.csv)
  Preview: [`previews/question-30893__30893__cst-class-data.html`](../../artifacts/previews/question-30893__30893__cst-class-data.html)

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `base` | `table` | `30893` | Base dataset that anchors the row set for this query. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |
| `dwh_fitness.fitness_bookings` | `table` | `30893` | Activity/booking dataset used to measure usage, attendance, or visits. It appears through a LEFT JOIN clause. | Relation not found in local dbt manifest. |
| `dwh_fitness_mart.employee_dim` | `table` | `30893` | Base dataset that anchors the row set for this query. It appears in the primary FROM clause. | - |
| `pk_cultprod_cultapp.Cultclassoos` | `table` | `30893` | Joined dataset used to enrich, filter, or aggregate the base query rows. | - |
| `pk_cultprod_cultapp.Toainstance` | `table` | `30893` | Joined dataset used to enrich, filter, or aggregate the base query rows. | Relation not found in local dbt manifest. |
| `pk_cultprod_cultapp.WorkoutFamily` | `table` | `30893` | Joined dataset used to enrich, filter, or aggregate the base query rows. | Relation not found in local dbt manifest. |
| `pk_cultprod_cultapp.WorkoutFamilyWorkoutMap` | `table` | `30893` | Joined dataset used to enrich, filter, or aggregate the base query rows. | - |
| `pk_cultprod_cultapp.center` | `table` | `30893` | Location lookup used to attach center, city, or operating-unit attributes. It appears in the primary FROM clause. | - |
| `pk_cultprod_cultapp.city` | `table` | `30893` | Location lookup used to attach center, city, or operating-unit attributes. It appears through a LEFT JOIN clause. | - |
| `pk_cultprod_cultapp.cultclass` | `table` | `30893` | Base dataset that anchors the row set for this query. It appears in the primary FROM clause. | - |
| `pk_cultprod_cultapp.cultemployee` | `table` | `30893` | Joined dataset used to enrich, filter, or aggregate the base query rows. It appears through a LEFT JOIN clause. | - |
| `pk_cultprod_cultapp.locationhierarchy` | `table` | `30893` | Joined dataset used to enrich, filter, or aggregate the base query rows. It appears through a LEFT JOIN clause. | Relation not found in local dbt manifest. |
| `pk_cultprod_cultapp.trainercultclassmap` | `table` | `30893` | Joined dataset used to enrich, filter, or aggregate the base query rows. It appears through a LEFT JOIN clause. | - |
| `pk_cultprod_cultapp.waitlist` | `table` | `30893` | Base dataset that anchors the row set for this query. It appears in the primary FROM clause. | - |
| `pk_cultprod_cultapp.workout` | `table` | `30893` | Joined dataset used to enrich, filter, or aggregate the base query rows. It appears through a LEFT JOIN clause. | - |
| `pk_curefitprod_center_service.center` | `table` | `30893` | Location lookup used to attach center, city, or operating-unit attributes. It appears through a LEFT JOIN clause. | - |

## Query File References

- Card `30893`: [`queries/30893__cst-class-data.sql`](../../artifacts/queries/30893__cst-class-data.sql)

## Evidence Files

- Result CSV for card `30893`: [`results/question-30893__30893__cst-class-data.csv`](../../artifacts/results/question-30893__30893__cst-class-data.csv)
- Preview for card `30893`: [`previews/question-30893__30893__cst-class-data.html`](../../artifacts/previews/question-30893__30893__cst-class-data.html)
- Lineage preview for card `30893`: [`previews/question-30893__30893__cst-class-data__lineage.html`](../../artifacts/previews/question-30893__30893__cst-class-data__lineage.html)
