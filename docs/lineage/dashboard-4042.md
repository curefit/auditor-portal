# IPO Data

- Root key: `dashboard-4042`
- Metabase type: `dashboard`
- Root ID: `4042`
- Source URL: `https://metabase.curefit.co/dashboard/4042-ipo-data?business_unit=&category=&end_date=&period=&start_date=`
- Tables detected: `2`
- Nested cards detected: `1`
- Evidence status: `query_sql|metadata_json || query_sql|metadata_json|result_blocked`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `75736` `Total Amount and Units` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75736__total-amount-and-units.sql`](../../artifacts/queries/75736__total-amount-and-units.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75854` `Month Level Amount and Units` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75854__month-level-amount-and-units.sql`](../../artifacts/queries/75854__month-level-amount-and-units.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75859` `Month_Pincode Level  Units` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75859__month-pincode-level-units.sql`](../../artifacts/queries/75859__month-pincode-level-units.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75860` `Month_Category Level Amount and Units` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75860__month-category-level-amount-and-units.sql`](../../artifacts/queries/75860__month-category-level-amount-and-units.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75863` `Month_Skucode Level  Units` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75863__month-skucode-level-units.sql`](../../artifacts/queries/75863__month-skucode-level-units.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75864` `Month_Business Unit Level Amount and Units` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75864__month-business-unit-level-amount-and-units.sql`](../../artifacts/queries/75864__month-business-unit-level-amount-and-units.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75865` `Business Unit Level Amount and Units` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75865__business-unit-level-amount-and-units.sql`](../../artifacts/queries/75865__business-unit-level-amount-and-units.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75866` `Quarter Level Amount and Units` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75866__quarter-level-amount-and-units.sql`](../../artifacts/queries/75866__quarter-level-amount-and-units.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75867` `Financial Year Level Amount and Units` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75867__financial-year-level-amount-and-units.sql`](../../artifacts/queries/75867__financial-year-level-amount-and-units.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75868` `Month_Category_itemcode Level Amount and Units` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75868__month-category-itemcode-level-amount-and-units.sql`](../../artifacts/queries/75868__month-category-itemcode-level-amount-and-units.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75869` `Category_itemcode Level Amount and Units` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75869__category-itemcode-level-amount-and-units.sql`](../../artifacts/queries/75869__category-itemcode-level-amount-and-units.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75870` `Unique Pincodes` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75870__unique-pincodes.sql`](../../artifacts/queries/75870__unique-pincodes.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75871` `Unique Sku Code` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75871__unique-sku-code.sql`](../../artifacts/queries/75871__unique-sku-code.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75872` `Raw Data - 2` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75872__raw-data-2.sql`](../../artifacts/queries/75872__raw-data-2.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75876` `Financial Year Wise Summary` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75876__financial-year-wise-summary.sql`](../../artifacts/queries/75876__financial-year-wise-summary.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75881` `New Launch SKU` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75881__new-launch-sku.sql`](../../artifacts/queries/75881__new-launch-sku.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75894` `New Launch Style Id` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75894__new-launch-style-id.sql`](../../artifacts/queries/75894__new-launch-style-id.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75906` `Financial Year Wise Summary -  Category Wise` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75906__financial-year-wise-summary-category-wise.sql`](../../artifacts/queries/75906__financial-year-wise-summary-category-wise.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75910` `Month_Bill to Customer Name Level Amount and Units -` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/75910__month-bill-to-customer-name-level-amount-and-units.sql`](../../artifacts/queries/75910__month-bill-to-customer-name-level-amount-and-units.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `76602` `Financial Year Wise Summary -  Category and Channel Wise` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/76602__financial-year-wise-summary-category-and-channel-wise.sql`](../../artifacts/queries/76602__financial-year-wise-summary-category-and-channel-wise.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `76604` `Financial Year Wise Summary -  Channel Type Wise` (role: `dashboard_card`, parent: `root`)
  SQL: [`queries/76604__financial-year-wise-summary-channel-type-wise.sql`](../../artifacts/queries/76604__financial-year-wise-summary-channel-type-wise.sql)
  Notes: HTTP Error 500: Internal Server Error
- Card `75683` `Raw Data` (role: `nested_card`, parent: `75736`)
  SQL: [`queries/75683__raw-data.sql`](../../artifacts/queries/75683__raw-data.sql)

## Dashboard Mapping

- Dashcard `35243` -> card `75736` `Total Amount and Units`
- Dashcard `35320` -> card `75865` `Business Unit Level Amount and Units`
- Dashcard `35321` -> card `75868` `Month_Category_itemcode Level Amount and Units`
- Dashcard `35322` -> card `75869` `Category_itemcode Level Amount and Units`
- Dashcard `35319` -> card `75864` `Month_Business Unit Level Amount and Units`
- Dashcard `35324` -> card `75871` `Unique Sku Code`
- Dashcard `35325` -> card `75872` `Raw Data - 2`
- Dashcard `35318` -> card `75867` `Financial Year Level Amount and Units`
- Dashcard `35314` -> card `75860` `Month_Category Level Amount and Units`
- Dashcard `35315` -> card `75859` `Month_Pincode Level  Units`
- Dashcard `35316` -> card `75863` `Month_Skucode Level  Units`
- Dashcard `35317` -> card `75866` `Quarter Level Amount and Units`
- Dashcard `35313` -> card `75854` `Month Level Amount and Units`
- Dashcard `35323` -> card `75870` `Unique Pincodes`
- Dashcard `35326` -> card `75876` `Financial Year Wise Summary`
- Dashcard `35329` -> card `75881` `New Launch SKU`
- Dashcard `35331` -> card `75894` `New Launch Style Id`
- Dashcard `35338` -> card `75906` `Financial Year Wise Summary -  Category Wise`
- Dashcard `35339` -> card `75910` `Month_Bill to Customer Name Level Amount and Units -`
- Dashcard `35674` -> card `76602` `Financial Year Wise Summary -  Category and Channel Wise`
- Dashcard `35675` -> card `76604` `Financial Year Wise Summary -  Channel Type Wise`

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `sku_launch_date` | `cte` | `75881, 75894` | Intermediate CTE defined inside the SQL and reused later in the query. | Relation not found in local dbt manifest. |
| `metabase.card.75683` | `nested_card` | `75736, 75854, 75859, 75860, 75863, 75864, 75865, 75866, 75867, 75868, 75869, 75870, 75871, 75872, 75876, 75881, 75894, 75906, 75910, 76602, 76604` | Nested Metabase card whose result feeds this query. | Nested Metabase card reference to Raw Data. |
| `pk_fitstore_unicommerce.item_details_summary` | `table` | `75736, 75854, 75859, 75860, 75863, 75864, 75865, 75866, 75867, 75868, 75869, 75870, 75871, 75872, 75876, 75881, 75894, 75906, 75910, 76602, 76604` | Base dataset that anchors the row set for this query. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |
| `stage_dwh.dwh_d2c_metrics_bizfin_sales_data` | `table` | `75683` | Transaction dataset used for order, revenue, or sales measures. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |

## Query File References

- Card `75736`: [`queries/75736__total-amount-and-units.sql`](../../artifacts/queries/75736__total-amount-and-units.sql)
- Card `75683`: [`queries/75683__raw-data.sql`](../../artifacts/queries/75683__raw-data.sql)
- Card `75865`: [`queries/75865__business-unit-level-amount-and-units.sql`](../../artifacts/queries/75865__business-unit-level-amount-and-units.sql)
- Card `75868`: [`queries/75868__month-category-itemcode-level-amount-and-units.sql`](../../artifacts/queries/75868__month-category-itemcode-level-amount-and-units.sql)
- Card `75869`: [`queries/75869__category-itemcode-level-amount-and-units.sql`](../../artifacts/queries/75869__category-itemcode-level-amount-and-units.sql)
- Card `75864`: [`queries/75864__month-business-unit-level-amount-and-units.sql`](../../artifacts/queries/75864__month-business-unit-level-amount-and-units.sql)
- Card `75871`: [`queries/75871__unique-sku-code.sql`](../../artifacts/queries/75871__unique-sku-code.sql)
- Card `75872`: [`queries/75872__raw-data-2.sql`](../../artifacts/queries/75872__raw-data-2.sql)
- Card `75867`: [`queries/75867__financial-year-level-amount-and-units.sql`](../../artifacts/queries/75867__financial-year-level-amount-and-units.sql)
- Card `75860`: [`queries/75860__month-category-level-amount-and-units.sql`](../../artifacts/queries/75860__month-category-level-amount-and-units.sql)
- Card `75859`: [`queries/75859__month-pincode-level-units.sql`](../../artifacts/queries/75859__month-pincode-level-units.sql)
- Card `75863`: [`queries/75863__month-skucode-level-units.sql`](../../artifacts/queries/75863__month-skucode-level-units.sql)
- Card `75866`: [`queries/75866__quarter-level-amount-and-units.sql`](../../artifacts/queries/75866__quarter-level-amount-and-units.sql)
- Card `75854`: [`queries/75854__month-level-amount-and-units.sql`](../../artifacts/queries/75854__month-level-amount-and-units.sql)
- Card `75870`: [`queries/75870__unique-pincodes.sql`](../../artifacts/queries/75870__unique-pincodes.sql)
- Card `75876`: [`queries/75876__financial-year-wise-summary.sql`](../../artifacts/queries/75876__financial-year-wise-summary.sql)
- Card `75881`: [`queries/75881__new-launch-sku.sql`](../../artifacts/queries/75881__new-launch-sku.sql)
- Card `75894`: [`queries/75894__new-launch-style-id.sql`](../../artifacts/queries/75894__new-launch-style-id.sql)
- Card `75906`: [`queries/75906__financial-year-wise-summary-category-wise.sql`](../../artifacts/queries/75906__financial-year-wise-summary-category-wise.sql)
- Card `75910`: [`queries/75910__month-bill-to-customer-name-level-amount-and-units.sql`](../../artifacts/queries/75910__month-bill-to-customer-name-level-amount-and-units.sql)
- Card `76602`: [`queries/76602__financial-year-wise-summary-category-and-channel-wise.sql`](../../artifacts/queries/76602__financial-year-wise-summary-category-and-channel-wise.sql)
- Card `76604`: [`queries/76604__financial-year-wise-summary-channel-type-wise.sql`](../../artifacts/queries/76604__financial-year-wise-summary-channel-type-wise.sql)

## Evidence Files

- No result or preview artifacts were available for this root.
