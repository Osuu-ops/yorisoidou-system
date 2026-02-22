#!/usr/bin/env python3
import json
import secrets
from datetime import datetime, timezone
from pathlib import Path

JOURNAL_SCHEMA_VERSION = "v1"


def utc_now_z() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def new_event_id() -> str:
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    return f"EVT_{ts}_{secrets.token_hex(4)}"


def _default_event() -> dict:
    return {
        "schema_version": JOURNAL_SCHEMA_VERSION,
        "ts_utc": "",
        "event_id": "",
        "run_id": "",
        "portfolio_id": "UNSELECTED",
        "mode": "",
        "primary_anchor": "",
        "phase": "",
        "step": "",
        "result": "",
        "reason_code": "",
        "evidence": {
            "pr_url": "",
            "workflow_run_url": "",
            "commit_sha": "",
            "note": "",
        },
    }


def _normalize_event(event: dict) -> dict:
    default = _default_event()
    out = {**default, **(event or {})}
    evidence = event.get("evidence") if isinstance(event, dict) else {}
    out["evidence"] = {**default["evidence"], **(evidence or {})}
    out["schema_version"] = JOURNAL_SCHEMA_VERSION
    if not out.get("ts_utc"):
        out["ts_utc"] = utc_now_z()
    if not out.get("event_id"):
        out["event_id"] = new_event_id()
    return out


def append_journal_event(path: Path, event: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    record = _normalize_event(event)
    line = json.dumps(record, ensure_ascii=False)
    with path.open("a", encoding="utf-8", newline="\n") as f:
        f.write(line + "\n")
        f.flush()
