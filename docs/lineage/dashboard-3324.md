# PR DASHBOARD

- Root key: `dashboard-3324`
- Metabase type: `dashboard`
- Root ID: `3324`
- Source URL: `https://metabase.curefit.co/dashboard/3324-pr-dashboard?business_line=&center_name=&center_service_id=&city_name=&ownership_type=&report_end_date=2025-12-31&report_start_date=2022-04-01&service_type=`
- Tables detected: `2`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|raw_csv|output_preview_html|lineage_preview_html`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `56424` `PR BY PRODUCT` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/56424__pr-by-product.sql`](../../artifacts/queries/56424__pr-by-product.sql)
  Result CSV: [`results/dashboard-3324__56424__pr-by-product.csv`](../../artifacts/results/dashboard-3324__56424__pr-by-product.csv)
  Preview: [`previews/dashboard-3324__56424__pr-by-product.html`](../../artifacts/previews/dashboard-3324__56424__pr-by-product.html)
- Card `56862` `PR BY CITY` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/56862__pr-by-city.sql`](../../artifacts/queries/56862__pr-by-city.sql)
  Result CSV: [`results/dashboard-3324__56862__pr-by-city.csv`](../../artifacts/results/dashboard-3324__56862__pr-by-city.csv)
  Preview: [`previews/dashboard-3324__56862__pr-by-city.html`](../../artifacts/previews/dashboard-3324__56862__pr-by-city.html)
- Card `56863` `PR BY OWNERSHIP TYPE` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/56863__pr-by-ownership-type.sql`](../../artifacts/queries/56863__pr-by-ownership-type.sql)
  Result CSV: [`results/dashboard-3324__56863__pr-by-ownership-type.csv`](../../artifacts/results/dashboard-3324__56863__pr-by-ownership-type.csv)
  Preview: [`previews/dashboard-3324__56863__pr-by-ownership-type.html`](../../artifacts/previews/dashboard-3324__56863__pr-by-ownership-type.html)
- Card `56865` `PR BY PRODUCT x CITY` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/56865__pr-by-product-x-city.sql`](../../artifacts/queries/56865__pr-by-product-x-city.sql)
  Result CSV: [`results/dashboard-3324__56865__pr-by-product-x-city.csv`](../../artifacts/results/dashboard-3324__56865__pr-by-product-x-city.csv)
  Preview: [`previews/dashboard-3324__56865__pr-by-product-x-city.html`](../../artifacts/previews/dashboard-3324__56865__pr-by-product-x-city.html)
- Card `56866` `PR BY PRODUCT x OWNERSHIP TYPE` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/56866__pr-by-product-x-ownership-type.sql`](../../artifacts/queries/56866__pr-by-product-x-ownership-type.sql)
  Result CSV: [`results/dashboard-3324__56866__pr-by-product-x-ownership-type.csv`](../../artifacts/results/dashboard-3324__56866__pr-by-product-x-ownership-type.csv)
  Preview: [`previews/dashboard-3324__56866__pr-by-product-x-ownership-type.html`](../../artifacts/previews/dashboard-3324__56866__pr-by-product-x-ownership-type.html)
- Card `56867` `PR BY PRODUCT x OWNERSHIP TYPE x CITY` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/56867__pr-by-product-x-ownership-type-x-city.sql`](../../artifacts/queries/56867__pr-by-product-x-ownership-type-x-city.sql)
  Result CSV: [`results/dashboard-3324__56867__pr-by-product-x-ownership-type-x-city.csv`](../../artifacts/results/dashboard-3324__56867__pr-by-product-x-ownership-type-x-city.csv)
  Preview: [`previews/dashboard-3324__56867__pr-by-product-x-ownership-type-x-city.html`](../../artifacts/previews/dashboard-3324__56867__pr-by-product-x-ownership-type-x-city.html)
- Card `56868` `PR BY CENTER` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/56868__pr-by-center.sql`](../../artifacts/queries/56868__pr-by-center.sql)
  Result CSV: [`results/dashboard-3324__56868__pr-by-center.csv`](../../artifacts/results/dashboard-3324__56868__pr-by-center.csv)
  Preview: [`previews/dashboard-3324__56868__pr-by-center.html`](../../artifacts/previews/dashboard-3324__56868__pr-by-center.html)
- Card `56869` `PR SERVICE TYPE WEEK TREND LINE` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/56869__pr-service-type-week-trend-line.sql`](../../artifacts/queries/56869__pr-service-type-week-trend-line.sql)
  Result CSV: [`results/dashboard-3324__56869__pr-service-type-week-trend-line.csv`](../../artifacts/results/dashboard-3324__56869__pr-service-type-week-trend-line.csv)
  Preview: [`previews/dashboard-3324__56869__pr-service-type-week-trend-line.html`](../../artifacts/previews/dashboard-3324__56869__pr-service-type-week-trend-line.html)
- Card `56872` `RESPONSE FUNNEL` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/56872__response-funnel.sql`](../../artifacts/queries/56872__response-funnel.sql)
  Result CSV: [`results/dashboard-3324__56872__response-funnel.csv`](../../artifacts/results/dashboard-3324__56872__response-funnel.csv)
  Preview: [`previews/dashboard-3324__56872__response-funnel.html`](../../artifacts/previews/dashboard-3324__56872__response-funnel.html)

## Dashboard Mapping

- Dashcard `26096` -> card `56424` `PR BY PRODUCT`
- Dashcard `26097` -> card `56862` `PR BY CITY`
- Dashcard `26098` -> card `56863` `PR BY OWNERSHIP TYPE`
- Dashcard `26099` -> card `56865` `PR BY PRODUCT x CITY`
- Dashcard `26100` -> card `56866` `PR BY PRODUCT x OWNERSHIP TYPE`
- Dashcard `26101` -> card `56867` `PR BY PRODUCT x OWNERSHIP TYPE x CITY`
- Dashcard `26102` -> card `56868` `PR BY CENTER`
- Dashcard `26103` -> card `56869` `PR SERVICE TYPE WEEK TREND LINE`
- Dashcard `26104` -> card `56872` `RESPONSE FUNNEL`

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `bt_data` | `cte` | `56424, 56862, 56863, 56865, 56866, 56867, 56868, 56869` | Intermediate CTE defined inside the SQL and reused later in the query. | Relation not found in local dbt manifest. |
| `pivoted_data` | `cte` | `56869` | Intermediate CTE defined inside the SQL and reused later in the query. | Relation not found in local dbt manifest. |
| `response_data` | `cte` | `56872` | Intermediate CTE defined inside the SQL and reused later in the query. | Relation not found in local dbt manifest. |
| `dwh_fitness_mart.booking_fact` | `table` | `56424, 56862, 56863, 56865, 56866, 56867, 56868, 56869, 56872` | Activity/booking dataset used to measure usage, attendance, or visits. It appears in the primary FROM clause. | - |
| `dwh_fitness_mart.center_dim` | `table` | `56424, 56862, 56863, 56865, 56866, 56867, 56868, 56869, 56872` | Location lookup used to attach center, city, or operating-unit attributes. It appears in the primary FROM clause. | - |

## Query File References

- Card `56424`: [`queries/56424__pr-by-product.sql`](../../artifacts/queries/56424__pr-by-product.sql)
- Card `56862`: [`queries/56862__pr-by-city.sql`](../../artifacts/queries/56862__pr-by-city.sql)
- Card `56863`: [`queries/56863__pr-by-ownership-type.sql`](../../artifacts/queries/56863__pr-by-ownership-type.sql)
- Card `56865`: [`queries/56865__pr-by-product-x-city.sql`](../../artifacts/queries/56865__pr-by-product-x-city.sql)
- Card `56866`: [`queries/56866__pr-by-product-x-ownership-type.sql`](../../artifacts/queries/56866__pr-by-product-x-ownership-type.sql)
- Card `56867`: [`queries/56867__pr-by-product-x-ownership-type-x-city.sql`](../../artifacts/queries/56867__pr-by-product-x-ownership-type-x-city.sql)
- Card `56868`: [`queries/56868__pr-by-center.sql`](../../artifacts/queries/56868__pr-by-center.sql)
- Card `56869`: [`queries/56869__pr-service-type-week-trend-line.sql`](../../artifacts/queries/56869__pr-service-type-week-trend-line.sql)
- Card `56872`: [`queries/56872__response-funnel.sql`](../../artifacts/queries/56872__response-funnel.sql)

## Evidence Files

- Result CSV for card `56424`: [`results/dashboard-3324__56424__pr-by-product.csv`](../../artifacts/results/dashboard-3324__56424__pr-by-product.csv)
- Preview for card `56424`: [`previews/dashboard-3324__56424__pr-by-product.html`](../../artifacts/previews/dashboard-3324__56424__pr-by-product.html)
- Lineage preview for card `56424`: [`previews/dashboard-3324__56424__pr-by-product__lineage.html`](../../artifacts/previews/dashboard-3324__56424__pr-by-product__lineage.html)
- Result CSV for card `56862`: [`results/dashboard-3324__56862__pr-by-city.csv`](../../artifacts/results/dashboard-3324__56862__pr-by-city.csv)
- Preview for card `56862`: [`previews/dashboard-3324__56862__pr-by-city.html`](../../artifacts/previews/dashboard-3324__56862__pr-by-city.html)
- Lineage preview for card `56862`: [`previews/dashboard-3324__56862__pr-by-city__lineage.html`](../../artifacts/previews/dashboard-3324__56862__pr-by-city__lineage.html)
- Result CSV for card `56863`: [`results/dashboard-3324__56863__pr-by-ownership-type.csv`](../../artifacts/results/dashboard-3324__56863__pr-by-ownership-type.csv)
- Preview for card `56863`: [`previews/dashboard-3324__56863__pr-by-ownership-type.html`](../../artifacts/previews/dashboard-3324__56863__pr-by-ownership-type.html)
- Lineage preview for card `56863`: [`previews/dashboard-3324__56863__pr-by-ownership-type__lineage.html`](../../artifacts/previews/dashboard-3324__56863__pr-by-ownership-type__lineage.html)
- Result CSV for card `56865`: [`results/dashboard-3324__56865__pr-by-product-x-city.csv`](../../artifacts/results/dashboard-3324__56865__pr-by-product-x-city.csv)
- Preview for card `56865`: [`previews/dashboard-3324__56865__pr-by-product-x-city.html`](../../artifacts/previews/dashboard-3324__56865__pr-by-product-x-city.html)
- Lineage preview for card `56865`: [`previews/dashboard-3324__56865__pr-by-product-x-city__lineage.html`](../../artifacts/previews/dashboard-3324__56865__pr-by-product-x-city__lineage.html)
- Result CSV for card `56866`: [`results/dashboard-3324__56866__pr-by-product-x-ownership-type.csv`](../../artifacts/results/dashboard-3324__56866__pr-by-product-x-ownership-type.csv)
- Preview for card `56866`: [`previews/dashboard-3324__56866__pr-by-product-x-ownership-type.html`](../../artifacts/previews/dashboard-3324__56866__pr-by-product-x-ownership-type.html)
- Lineage preview for card `56866`: [`previews/dashboard-3324__56866__pr-by-product-x-ownership-type__lineage.html`](../../artifacts/previews/dashboard-3324__56866__pr-by-product-x-ownership-type__lineage.html)
- Result CSV for card `56867`: [`results/dashboard-3324__56867__pr-by-product-x-ownership-type-x-city.csv`](../../artifacts/results/dashboard-3324__56867__pr-by-product-x-ownership-type-x-city.csv)
- Preview for card `56867`: [`previews/dashboard-3324__56867__pr-by-product-x-ownership-type-x-city.html`](../../artifacts/previews/dashboard-3324__56867__pr-by-product-x-ownership-type-x-city.html)
- Lineage preview for card `56867`: [`previews/dashboard-3324__56867__pr-by-product-x-ownership-type-x-city__lineage.html`](../../artifacts/previews/dashboard-3324__56867__pr-by-product-x-ownership-type-x-city__lineage.html)
- Result CSV for card `56868`: [`results/dashboard-3324__56868__pr-by-center.csv`](../../artifacts/results/dashboard-3324__56868__pr-by-center.csv)
- Preview for card `56868`: [`previews/dashboard-3324__56868__pr-by-center.html`](../../artifacts/previews/dashboard-3324__56868__pr-by-center.html)
- Lineage preview for card `56868`: [`previews/dashboard-3324__56868__pr-by-center__lineage.html`](../../artifacts/previews/dashboard-3324__56868__pr-by-center__lineage.html)
- Result CSV for card `56869`: [`results/dashboard-3324__56869__pr-service-type-week-trend-line.csv`](../../artifacts/results/dashboard-3324__56869__pr-service-type-week-trend-line.csv)
- Preview for card `56869`: [`previews/dashboard-3324__56869__pr-service-type-week-trend-line.html`](../../artifacts/previews/dashboard-3324__56869__pr-service-type-week-trend-line.html)
- Lineage preview for card `56869`: [`previews/dashboard-3324__56869__pr-service-type-week-trend-line__lineage.html`](../../artifacts/previews/dashboard-3324__56869__pr-service-type-week-trend-line__lineage.html)
- Result CSV for card `56872`: [`results/dashboard-3324__56872__response-funnel.csv`](../../artifacts/results/dashboard-3324__56872__response-funnel.csv)
- Preview for card `56872`: [`previews/dashboard-3324__56872__response-funnel.html`](../../artifacts/previews/dashboard-3324__56872__response-funnel.html)
- Lineage preview for card `56872`: [`previews/dashboard-3324__56872__response-funnel__lineage.html`](../../artifacts/previews/dashboard-3324__56872__response-funnel__lineage.html)
