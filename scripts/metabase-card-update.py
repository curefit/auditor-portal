#!/usr/bin/env python3
"""
Update an existing Metabase native SQL card using the staged OAuth helper.

Cheat-code note:
    - stage the OAuth helper at /private/tmp/metabase_api.py
    - edit/export a local SQL artifact
    - run this script to push that SQL back onto the saved Metabase card

Usage:
    python3 scripts/metabase-card-update.py <card_id> <sql_file> [base_metadata_json]
"""

from __future__ import annotations

import importlib.util
import json
import pathlib
import sys


HELPER_PATH = pathlib.Path("/private/tmp/metabase_api.py")


def load_helper():
    if not HELPER_PATH.exists():
        raise SystemExit(f"Missing staged helper at {HELPER_PATH}")
    spec = importlib.util.spec_from_file_location("metabase_api", HELPER_PATH)
    if spec is None or spec.loader is None:
        raise SystemExit(f"Unable to load helper from {HELPER_PATH}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main() -> int:
    if len(sys.argv) not in (3, 4):
        print(__doc__.strip(), file=sys.stderr)
        return 1

    card_id = int(sys.argv[1])
    sql_path = pathlib.Path(sys.argv[2]).resolve()
    sql = sql_path.read_text(encoding="utf-8").strip()
    base_metadata_path = pathlib.Path(sys.argv[3]).resolve() if len(sys.argv) == 4 else None

    helper = load_helper()
    helper.validate_sql(sql)

    existing = helper._api_request("GET", f"/card/{card_id}")
    query_source = existing
    if base_metadata_path is not None:
        query_source = json.loads(base_metadata_path.read_text(encoding="utf-8"))

    dataset_query = dict(query_source.get("dataset_query") or {})
    if isinstance(dataset_query.get("stages"), list) and dataset_query["stages"]:
        stages = [dict(stage) for stage in dataset_query["stages"]]
        first_stage = dict(stages[0])
        first_stage["native"] = sql
        stages[0] = first_stage
        dataset_query["stages"] = stages
    else:
        native = dict(dataset_query.get("native") or {})
        native["query"] = sql
        dataset_query["native"] = native
        dataset_query.setdefault("type", existing.get("query_type", "native"))
        dataset_query.setdefault("database", existing.get("database_id"))

    payload = {
        "name": existing["name"],
        "description": existing.get("description"),
        "display": existing.get("display", "table"),
        "dataset_query": dataset_query,
        "visualization_settings": existing.get("visualization_settings", {}),
        "collection_id": existing.get("collection_id"),
        "collection_position": existing.get("collection_position"),
        "cache_ttl": existing.get("cache_ttl"),
        "parameter_mappings": existing.get("parameter_mappings", []),
        "result_metadata": existing.get("result_metadata"),
        "query_type": existing.get("query_type"),
    }
    payload = {k: v for k, v in payload.items() if v is not None}

    updated = helper._api_request("PUT", f"/card/{card_id}", data=payload)
    print(json.dumps({
        "id": updated.get("id", card_id),
        "name": updated.get("name", existing.get("name")),
        "display": updated.get("display", existing.get("display", "table")),
        "collection_id": updated.get("collection_id", existing.get("collection_id")),
        "url": f"{helper._current_base_url()}/question/{card_id}",
    }, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
