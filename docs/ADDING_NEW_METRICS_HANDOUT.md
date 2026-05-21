# Adding New Metrics To The Auditor Portal

This handout is for future metric additions so Codex does not need to rebuild repo context from scratch.

It captures:
- how the portal decides which metrics to show
- which files usually need edits
- the exact workflow used for the Referrals metric (`55835`)
- common failure modes and how to avoid unrelated diffs

## Quick Repo Model

This repo is a static handoff portal, not a live data product.

The flow is:
1. source-of-truth sheet snapshot lives in [artifacts/op_metrics_sheet.csv](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/op_metrics_sheet.csv)
2. card-to-dashboard mapping lives in [artifacts/dashboard_card_mapping.csv](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/dashboard_card_mapping.csv)
3. saved-card SQL exports live in [artifacts/queries](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/queries)
4. saved-card metadata exports live in [artifacts/metadata](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/metadata)
5. the generator at [scripts/generate-catalog.mjs](/Users/shivalingeshaiholli/Projects/auditor-portal/scripts/generate-catalog.mjs:1) builds the portal data
6. the React app reads [auditor-portal/src/catalog.json](/Users/shivalingeshaiholli/Projects/auditor-portal/auditor-portal/src/catalog.json:1)

If a metric is not represented in `catalog.json`, it will not show in the portal UI.

## How A Metric Gets Into The Portal

A DRHP metric shows up only when all of this is true:

1. The row exists in [artifacts/op_metrics_sheet.csv](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/op_metrics_sheet.csv).
2. The `Source` column contains a parseable Metabase link.
3. The relevant card exists in [artifacts/dashboard_card_mapping.csv](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/dashboard_card_mapping.csv).
4. The card has query and metadata artifacts in:
   - [artifacts/queries](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/queries)
   - [artifacts/metadata](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/metadata)
5. [scripts/generate-catalog.mjs](/Users/shivalingeshaiholli/Projects/auditor-portal/scripts/generate-catalog.mjs:163) regenerates [auditor-portal/src/catalog.json](/Users/shivalingeshaiholli/Projects/auditor-portal/auditor-portal/src/catalog.json:1).

## Important Parsing Rule

The op-metrics parser only matches these patterns inside the `Source` column:

- `metabase.curefit.co/question/<id>`
- `metabase.curefit.co/dashboard/<id>`

This is implemented in [scripts/generate-catalog.mjs](/Users/shivalingeshaiholli/Projects/auditor-portal/scripts/generate-catalog.mjs:163).

It does **not** understand encoded links of the form:

- `https://metabase.curefit.co/question?...#<encoded-json>`

That was the main reason the Referrals metric was missing.

## Files Usually Involved

### Required in most cases

- [artifacts/op_metrics_sheet.csv](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/op_metrics_sheet.csv)
- [artifacts/dashboard_card_mapping.csv](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/dashboard_card_mapping.csv)
- one SQL file under [artifacts/queries](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/queries)
- one metadata JSON under [artifacts/metadata](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/metadata)
- [auditor-portal/src/catalog.json](/Users/shivalingeshaiholli/Projects/auditor-portal/auditor-portal/src/catalog.json)

### Generated files that may change, but are not always part of the intended metric diff

- [auditor-portal/public/dbt-config.json](/Users/shivalingeshaiholli/Projects/auditor-portal/auditor-portal/public/dbt-config.json)
- [auditor-portal/public/dbt-models-index.json](/Users/shivalingeshaiholli/Projects/auditor-portal/auditor-portal/public/dbt-models-index.json)
- [auditor-portal/public/dbt-notebooks-index.json](/Users/shivalingeshaiholli/Projects/auditor-portal/auditor-portal/public/dbt-notebooks-index.json)

These three should usually stay untouched for a metric-only change unless there is a deliberate dbt source refresh.

## Standard Workflow

### 1. Find the metric row in `op_metrics_sheet.csv`

Check:
- metric name
- serial number
- current `Source` value
- whether the source points to a Metabase question or dashboard

If the row has no Metabase URL, the portal will ignore it.

### 2. Normalize the source URL

Preferred format:

```text
https://metabase.curefit.co/question/<card_id>-<slug>?...
```

or

```text
https://metabase.curefit.co/dashboard/<dashboard_id>-<slug>?...
```

Avoid encoded `question?...#...` URLs in the sheet snapshot.

### 3. Ensure the card exists in `dashboard_card_mapping.csv`

Add or verify a row with the card id and associated metadata.

Minimum fields to care about:
- `card_id`
- `card_name`
- `dashboard_id`
- `dashboard_name`
- `root_key`

If the card is absent from this mapping, the generator may still miss important context.

### 4. Ensure query and metadata artifacts exist

Expected filenames:

```text
artifacts/queries/<card_id>__<slug>.sql
artifacts/metadata/<card_id>__<slug>.json
```

If these files are missing, the metric can still be partially known, but the portal experience will be incomplete or absent.

### 5. Regenerate the catalog

From repo root:

```bash
node scripts/generate-catalog.mjs
```

Or from the app directory:

```bash
cd auditor-portal
npm run generate
```

### 6. Validate locally

```bash
cd auditor-portal
npm run dev
```

Then check:
- the metric appears in the Metrics list
- the right card id is attached
- `View SQL` works
- the metric detail panel loads metadata correctly

## Referrals Example

Metric:
- DRHP metric `43`
- `Referrals -- % of pack revenue through referrals`
- Metabase card `55835`

### What was wrong

1. The sheet row used an encoded `question?...#...` URL, which the parser ignored.
2. Card `55835` was missing from [artifacts/dashboard_card_mapping.csv](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/dashboard_card_mapping.csv).
3. The repo did not have exported artifacts for this card in:
   - [artifacts/queries](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/queries)
   - [artifacts/metadata](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/metadata)

### What fixed it

1. Replaced the sheet URL with:

```text
https://metabase.curefit.co/question/55835-referral-revenue?start_date=2023-04-01&end_date=2024-03-31
```

2. Added the mapping row for `55835`.
3. Added:
   - [artifacts/queries/55835__referral-revenue.sql](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/queries/55835__referral-revenue.sql:1)
   - [artifacts/metadata/55835__referral-revenue.json](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/metadata/55835__referral-revenue.json:1)
4. Updated [auditor-portal/src/catalog.json](/Users/shivalingeshaiholli/Projects/auditor-portal/auditor-portal/src/catalog.json:1) so the new metric appeared in the UI.

### Final intended diff for Referrals

- [artifacts/op_metrics_sheet.csv](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/op_metrics_sheet.csv)
- [artifacts/dashboard_card_mapping.csv](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/dashboard_card_mapping.csv)
- [artifacts/queries/55835__referral-revenue.sql](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/queries/55835__referral-revenue.sql:1)
- [artifacts/metadata/55835__referral-revenue.json](/Users/shivalingeshaiholli/Projects/auditor-portal/artifacts/metadata/55835__referral-revenue.json:1)
- [auditor-portal/src/catalog.json](/Users/shivalingeshaiholli/Projects/auditor-portal/auditor-portal/src/catalog.json:1)

## When Query/Metadata Exports Are Missing

If the card export is not already present in the repo:

1. first check whether the Metabase source URL contains enough information to reconstruct the SQL and metadata
2. if yes, create local artifacts as a temporary handoff fix
3. clearly note in the metadata JSON that it was reconstructed locally
4. prefer replacing reconstructed artifacts with real exports later if possible

This is exactly what was done for Referrals `55835`.

## Common Failure Modes

### Metric still does not show after editing the sheet

Check:
- source URL is parseable as `/question/<id>` or `/dashboard/<id>`
- the `Sl.No` column is numeric
- the card id exists in `dashboard_card_mapping.csv`
- query and metadata files exist
- `catalog.json` was regenerated

### Generator produces unrelated dbt file changes

This can happen if generation runs without the same dbt GitHub context or token used previously.

Watch for accidental diffs in:
- [auditor-portal/public/dbt-config.json](/Users/shivalingeshaiholli/Projects/auditor-portal/auditor-portal/public/dbt-config.json)
- [auditor-portal/public/dbt-models-index.json](/Users/shivalingeshaiholli/Projects/auditor-portal/auditor-portal/public/dbt-models-index.json)
- [auditor-portal/public/dbt-notebooks-index.json](/Users/shivalingeshaiholli/Projects/auditor-portal/auditor-portal/public/dbt-notebooks-index.json)

For a metric-only change, these should usually be restored unless the task explicitly includes dbt index refresh.

### `catalog.json` changes too broadly

This usually means generation drifted because of missing dbt context.

Expected for a simple new metric:
- one new or updated metric entry
- top-level `count` changes if this is a truly new card

Unexpected:
- unrelated metrics losing dbt links
- unrelated lineage arrays changing

If that happens, rebuild `catalog.json` from the branch-base version and keep only the intended metric changes.

### Clicking a dbt model locally shows HTML instead of SQL

That is usually not a metric bug.

It means local static dbt caches are missing:
- `auditor-portal/public/dbt-sql/`
- `auditor-portal/public/dbt-notebooks/`

In that case Vite serves `index.html`, and the modal renders raw HTML text.

## Safe Review Checklist Before Raising PR

- metric appears in localhost
- card id is correct
- SQL and metadata open correctly
- only intended files changed
- no unrelated dbt public index drift
- no unrelated lineage removals inside `catalog.json`

## Recommended Minimal Diff Strategy

For most new metric additions, aim to keep the PR limited to:

1. sheet row update
2. mapping row update
3. query artifact
4. metadata artifact
5. minimal catalog update

That is the cleanest pattern for incremental portal maintenance.

## Handy Commands

Repo root:

```bash
node scripts/generate-catalog.mjs
git diff -- artifacts/op_metrics_sheet.csv artifacts/dashboard_card_mapping.csv auditor-portal/src/catalog.json
```

Local app:

```bash
cd auditor-portal
npm run dev
```

## One-Line Operating Principle

If a new metric is present in the sheet but missing in the portal, first verify the sheet source URL, then the mapping row, then the query/metadata artifacts, and only after that inspect the generated catalog.
