# Curefit Auditor Portal

A read-only web portal for auditors that surfaces Metabase metric definitions, SQL queries, dbt model source code, and DRHP operational metrics — all in one place. Nothing in this app executes queries or runs pipelines.

---

## How It Works — End-to-End

```
Google Sheet (DRHP Op. Metrics)        GitHub (dbt-data-models, cf-data-lab)
        │                                          │
        ▼                                          ▼
artifacts/op_metrics_sheet.csv         GITHUB_TOKEN in .env
        │                                          │
        └──────────────┬────────────────────────────┘
                       ▼
          scripts/generate-catalog.mjs
                       │
         ┌─────────────┼──────────────────────┐
         ▼             ▼                      ▼
  src/catalog.json  public/dbt-sql/     public/dbt-notebooks/
  (115 metrics)     (matched .sql)      (matched .ipynb)
         │
         ▼
  auditor-portal (React + Vite)
  └── Metrics page  (DRHP list, Overview panel, SQL viewer)
  └── Model Source Code page  (dbt SQL + cf-data-lab notebooks)
```

---

## Repository Structure

```
curefit-auditor-handoff-repo/
├── .env                          # secrets — never committed
├── .env.example                  # template for .env
├── artifacts/
│   ├── dashboard_card_mapping.csv   # maps every Metabase card to its dashboard
│   ├── op_metrics_sheet.csv         # DRHP op-metrics sheet (re-export from Google Sheets)
│   ├── drhp_metrics_h1.csv          # FY/H1 overlay for existing Metabase-backed metrics
│   ├── drhp_metrics_h1_map.json     # reviewed mapping to existing portal card identities
│   ├── queries/                     # exported SQL per card (*.sql)
│   ├── metadata/                    # Metabase card metadata JSON per card
│   ├── results/                     # sample result CSVs
│   └── previews/                    # output + lineage HTML previews
├── docs/lineage/                    # per-root lineage markdown files
├── scripts/
│   └── generate-catalog.mjs         # THE build script (see below)
└── auditor-portal/
    ├── public/
    │   ├── dbt-config.json           # written by generate-catalog.mjs
    │   ├── dbt-models-index.json     # list of all dbt SQL paths
    │   ├── dbt-notebooks-index.json  # list of all notebook paths
    │   ├── dbt-sql/                  # downloaded dbt SQL files (gitignored)
    │   ├── dbt-notebooks/            # downloaded notebook files (gitignored)
    │   └── handoff/                  # copy of artifacts/ + docs/ for static serving
    └── src/
        ├── catalog.json              # written by generate-catalog.mjs
        ├── types.ts                  # TypeScript types
        ├── pages/
        │   ├── MetricsPage.tsx       # main metrics view
        │   └── DbtModelsPage.tsx     # model source code view
        └── layout/RootLayout.tsx
```

---

## Environment Variables (`.env`)

```env
METABASE_SITE_URL=https://metabase.curefit.co

# Primary dbt repo (SQL model files)
DBT_GITHUB_REPO=https://github.com/curefit/dbt-data-models
DBT_GITHUB_REF=master
DBT_MODELS_PATH=transformatics/models

# Fallback repo (Jupyter notebooks) — used when a table has no match in primary repo
FALLBACK_GITHUB_REPO=https://github.com/curefit/cf-data-lab
FALLBACK_GITHUB_REF=master
FALLBACK_MODELS_PATH=nbs/pinaka_data_models

# GitHub personal access token — required to fetch from private repos at build time
GITHUB_TOKEN=ghp_...
```

The token is only used by `generate-catalog.mjs` at build time. It is **never** sent to the browser.

---

## The Build Script: `scripts/generate-catalog.mjs`

Run with:
```bash
node scripts/generate-catalog.mjs
# or
npm run generate     # if configured in package.json
```

### What it does, step by step:

**1. Reads `artifacts/dashboard_card_mapping.csv`**
Every row is one Metabase card. Columns: `root_key`, `root_asset_id`, `dashboard_id`, `dashboard_name`, `card_id`, `card_name`.

**2. Reads `artifacts/op_metrics_sheet.csv` and the H1 overlay**
The DRHP op-metrics Google Sheet provides the existing metric labels, definitions, units, and card mappings. `artifacts/drhp_metrics_h1.csv` overlays FY24–FY26 and H1 FY26/FY27 values for Metabase-backed metrics only. Its reviewed map preserves portal card IDs, identifies removed metrics, and excludes source-only rows without portal artifacts.

**3. Fetches dbt model file tree from GitHub**
Using the GitHub API and `GITHUB_TOKEN`, fetches the full recursive file tree of `DBT_GITHUB_REPO` at `DBT_MODELS_PATH`. Produces a flat list of `.sql` file paths.

**4. Fetches fallback notebook tree from GitHub**
Same process for `FALLBACK_GITHUB_REPO` at `FALLBACK_MODELS_PATH`. Produces a list of `.ipynb` file paths.

**5. Parses SQL lineage for every card**
For each card's exported SQL (`artifacts/queries/`), extracts all `schema.table` references using regex. For each referenced table, attempts to find a matching dbt `.sql` file using exact name matching (e.g. `membership_dim.sql`). If no dbt match, tries the fallback notebook index using the pattern `schema.table_name.ipynb`. Returns `sqlLineageRelations[]` per card.

**6. Downloads matched source files**
- Matched dbt `.sql` files → `auditor-portal/public/dbt-sql/`
- Matched `.ipynb` notebooks → `auditor-portal/public/dbt-notebooks/`

These are served statically so the browser can load file contents without needing GitHub auth.

**7. Writes output files**
- `auditor-portal/src/catalog.json` — the main data file imported by the React app. Contains all 115 entries with paths, lineage relations, sheet metadata, and dbt source links.
- `auditor-portal/public/dbt-config.json` — repo config for the Model Source Code page.
- `auditor-portal/public/dbt-models-index.json` — full list of dbt SQL paths.
- `auditor-portal/public/dbt-notebooks-index.json` — full list of notebook paths.
- `auditor-portal/public/handoff/` — static copy of `artifacts/` and `docs/` for in-browser access.

---

## Running the Portal Locally

```bash
# 1. Install dependencies
npm install

# 2. Create .env (copy from .env.example and fill in your GITHUB_TOKEN)
cp .env.example .env

# 3. Generate the catalog (downloads dbt SQL + notebooks, writes catalog.json)
node scripts/generate-catalog.mjs

# 4. Start the dev server (does not regenerate tracked files)
cd auditor-portal && npm run dev
# → http://localhost:5173
```

Re-run step 3 deliberately whenever tracked artifacts or the H1 overlay change. `npm run dev` and `npm run build` do not generate tracked files.

---

## Updating the DRHP Op-Metrics Sheet

The portal reads from the local CSV snapshot at `artifacts/op_metrics_sheet.csv`.

**To update when the Google Sheet changes:**
1. Open the Google Sheet → File → Download → Comma Separated Values (.csv)
2. Replace `artifacts/op_metrics_sheet.csv` with the new file
3. Run `node scripts/generate-catalog.mjs`
4. Restart / rebuild the portal

Only rows where the **Source** column contains a `metabase.curefit.co` link are shown. Rows without Metabase links (e.g. Finance-sourced metrics, social media followers) are ignored.

---

## Adding New Metabase Cards

1. Add a row to `artifacts/dashboard_card_mapping.csv` with the card's `card_id`, `card_name`, `dashboard_id`, `dashboard_name`, and `root_key`.
2. Export the card's SQL to `artifacts/queries/<card_id>__<card-slug>.sql`
3. Export the card's metadata to `artifacts/metadata/<card_id>__<card-slug>.json`
4. Run `node scripts/generate-catalog.mjs`

---

## Refreshing Sample Result Files

The portal does not generate sample result files in the browser. It only links static files already present under `artifacts/results/`.

To refresh those files while preserving portal behavior:

```bash
# Preview date normalization and matched files without changing anything
node scripts/refresh-result-files.mjs --dry-run

# Refresh every result bundle in place
node scripts/refresh-result-files.mjs --write

# Refresh a subset
node scripts/refresh-result-files.mjs --write --only question-75109
node scripts/refresh-result-files.mjs --write --only dashboard-3604
```

Rules:
- Only date parameters are auto-updated.
- Non-date parameters are preserved as-is by default.
- Reviewed exceptions belong in `artifacts/result_refresh_overrides.json`.
- After refreshing result files, rerun `node scripts/generate-catalog.mjs` to copy updated artifacts into the portal's static handoff bundle.

---

## Current Status (as of last generate run)

| Check | Count |
|-------|-------|
| Total Metabase cards | 115 |
| DRHP-tagged cards | 106 |
| Cards with exported SQL | 113 / 115 |
| Cards with metadata JSON | 113 / 115 |
| Cards with SQL lineage parsed | 113 / 115 |
| dbt SQL files cached locally | 27 |
| Notebook files cached locally | 4 |
| **Missing artifacts** | **2 cards** (79589, 74738 — added after initial export) |

### Known gaps

**Cards missing exported SQL/metadata (need re-export):**
- `79589` — "adhoc 20-04-2026" → DRHP: BT rating + #Customers fill feedback form
- `74738` — "How much data from wearbles v3" → DRHP: # Health activities tracked

**Unmatched table references (34 unique tables):**
These appear in Metabase SQL but have no corresponding dbt model file or notebook. They are raw source tables (e.g. `pk_cultprod_cultapp.*`, `pk_curefit_app_events.*`, `gs_d2c.default.*`) that are ingested directly from Pinecone/production databases rather than built by dbt. This is expected — the portal shows them as unlinked relations.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 18 + TypeScript + Vite |
| Styling | Tailwind CSS |
| Routing | React Router v6 |
| Build script | Node.js ESM (`generate-catalog.mjs`) |
| Data sources | Metabase API exports, GitHub API, Google Sheets CSV |
| Hosting | Static site (Netlify / GitHub Pages / S3+CloudFront) |
