# Auditor Usage Guide

This repository is meant to be shared with the auditor team when they need:

- the Metabase query or dashboard code
- direct lineage for each KPI/query
- a readable explanation of dependencies and their role in the query
- result files and HTML previews

This repository does **not** include copied dbt dependency code. It focuses on the front-end Metabase layer and the evidence around it.

## Recommended Reading Order

1. `README.md`
2. `docs/ROOT_INDEX.md`
3. `docs/lineage/<root>.md`
4. `artifacts/root_asset_summary.csv`
5. `artifacts/node_dependency_detail.csv`
6. `artifacts/queries/`
7. `artifacts/results/`
8. `artifacts/previews/`

## Main Areas

### `docs/ROOT_INDEX.md`

This is the table of contents for all questions and dashboards.

### `docs/lineage/`

Each file explains one root asset:

- what the root is
- which Metabase cards are involved
- which dependencies were found
- what each dependency is doing in the query
- which evidence files exist

### `artifacts/queries/`

Contains the extracted SQL for Metabase cards.

### `artifacts/results/`

Contains raw result CSV/JSON where execution succeeded.

### `artifacts/previews/`

Contains HTML previews for query output and lineage tables.

### `artifacts/metadata/`

Contains raw Metabase JSON for cards and dashboards.

## How To Audit One KPI

1. Find the root in `docs/ROOT_INDEX.md`.
2. Open the matching lineage file in `docs/lineage/`.
3. Review the direct card list and dependency table.
4. Open the linked SQL files in `artifacts/queries/`.
5. Open result files and previews from the linked artifacts.
6. If the root is a dashboard, review how it expands to underlying cards.

## Status Notes

- `cte` means an intermediate SQL CTE, not a physical warehouse object.
- `nested_card` means a Metabase card reference like `{{#75683-raw-data}}`.
- `unresolved` means the dependency was observed in SQL but its local lineage could not be fully resolved from the original extract.
- `result_blocked` means SQL and metadata were captured, but the result execution itself failed or timed out in Metabase.
