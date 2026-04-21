# Auditor Metabase Lineage Handoff

Generated at 2026-04-21T07:59:32.681686+00:00

This repository is an auditor-facing package built from the Metabase dependency/evidence extract. It includes:

- front-end Metabase query/dashboard code
- per-root lineage documents
- dependency inventory
- result files and preview artifacts
- raw Metabase metadata

This repository intentionally does **not** include copied dbt dependency code.

## Quick Start

1. Read `AUDITOR_USAGE_GUIDE.md`
2. Open `docs/ROOT_INDEX.md`
3. Open `artifacts/root_asset_summary.csv`
4. Open the per-root lineage file under `docs/lineage/`

## Contents

- `AUDITOR_USAGE_GUIDE.md`: detailed instructions for auditors
- `docs/ROOT_INDEX.md`: clickable index of all question/dashboard roots
- `docs/lineage/`: one markdown lineage file per root asset
- `artifacts/queries/`: extracted Metabase SQL
- `artifacts/results/`: result CSV/JSON where query execution succeeded
- `artifacts/previews/`: HTML previews for outputs and lineage
- `artifacts/metadata/`: raw Metabase card/dashboard metadata
- `artifacts/*.csv`: dependency and dashboard mapping trackers

## Counts

- Questions: 16
- Dashboards: 3
- Unique roots: 19

## Important Scope Notes

- No full dependency-code bundle is included.
- Nested Metabase references are preserved in the lineage docs.
- Some result executions were blocked by Metabase timeouts or server errors.
