# Gender Split

- Root key: `question-75630`
- Metabase type: `question`
- Root ID: `75630`
- Source URL: `https://metabase.curefit.co/question/75630-gender-split?ed=2023-03-31`
- Tables detected: `10`
- Nested cards detected: `0`
- Evidence status: `query_sql|metadata_json|result_blocked`
- Notes: Relation not found in local dbt manifest.

## Metabase Cards

- Card `75630` `Gender Split` (role: `root_question`, parent: `root`)
  SQL: [`queries/75630__gender-split.sql`](../../artifacts/queries/75630__gender-split.sql)
  Notes: The read operation timed out

## Dependency Lineage

| Dependency | Type | Used By Cards | Inferred Use Case | Notes |
|---|---|---|---|---|
| `BASE` | `table` | `75630` | Joined dataset used to enrich, filter, or aggregate the base query rows. | Relation not found in local dbt manifest. |
| `GENDER_BASE` | `table` | `75630` | Joined dataset used to enrich, filter, or aggregate the base query rows. | Relation not found in local dbt manifest. |
| `age_onboarding` | `table` | `75630` | Joined dataset used to enrich, filter, or aggregate the base query rows. It appears through a LEFT JOIN clause. | Relation not found in local dbt manifest. |
| `birthday_base` | `table` | `75630` | Base dataset that anchors the row set for this query. It appears in the primary FROM clause. | Relation not found in local dbt manifest. |
| `dwh_fitness_mart.membership_dim` | `table` | `75630` | Membership context used for pack, user, or active-membership logic. It appears in the primary FROM clause. | - |
| `pk_cfprodplatforms_rashi.User_Attribute` | `table` | `75630` | Joined dataset used to enrich, filter, or aggregate the base query rows. | Relation not found in local dbt manifest. |
| `pk_cfuserservice_cultapp.User` | `table` | `75630` | Joined dataset used to enrich, filter, or aggregate the base query rows. | - |
| `pk_curefitprod_cfdb.npsresponses` | `table` | `75630` | Feedback dataset used for satisfaction, NPS, or response metrics. It appears in the primary FROM clause. | - |
| `rashi_age` | `table` | `75630` | Joined dataset used to enrich, filter, or aggregate the base query rows. It appears through a LEFT JOIN clause. | Relation not found in local dbt manifest. |
| `user_age` | `table` | `75630` | Joined dataset used to enrich, filter, or aggregate the base query rows. It appears through a LEFT JOIN clause. | Relation not found in local dbt manifest. |

## Query File References

- Card `75630`: [`queries/75630__gender-split.sql`](../../artifacts/queries/75630__gender-split.sql)

## Evidence Files

- No result or preview artifacts were available for this root.
