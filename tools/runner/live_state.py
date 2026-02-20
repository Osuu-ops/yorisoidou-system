#!/usr/bin/env python3
import json
from pathlib import Path

LIVE_STATE_SCHEMA_VERSION = "v1"


def _default_live_state() -> dict:
    return {
        "schema_version": LIVE_STATE_SCHEMA_VERSION,
        "updated_at_utc": "",
        "run_id": "",
        "portfolio_id": "UNSELECTED",
        "mode": "",
        "primary_anchor": "",
        "current_phase": "",
        "next_item": "",
        "stop_kind": "",
        "reason_code": "",
        "evidence": {
            "pr_url": "",
            "workflow_run_url": "",
            "commit_sha": "",
            "note": "",
        },
    }


def _normalize_live_state(payload: dict) -> dict:
    default = _default_live_state()
    out = {**default, **(payload or {})}
    evidence = payload.get("evidence") if isinstance(payload, dict) else {}
    out["evidence"] = {**default["evidence"], **(evidence or {})}
    out["schema_version"] = LIVE_STATE_SCHEMA_VERSION
    return out


def update_live_state(path: Path, payload: dict) -> None:
    """Atomic replace write for LIVE_STATE.json."""
    path.parent.mkdir(parents=True, exist_ok=True)
    data = _normalize_live_state(payload)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")
        f.flush()
    tmp.replace(path)
