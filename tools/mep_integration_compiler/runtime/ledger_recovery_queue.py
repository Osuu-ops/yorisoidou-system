# -*- coding: utf-8 -*-
from __future__ import annotations

import csv
import json
from dataclasses import asdict
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from .recovery_queue import RecoveryItem, RecoveryStatus, RecoveryCategory


# Phase-2 Ledger schema (Recovery Queue sheet columns).
# Authority is Ledger; UI/task systems are projections (refs only).
RECOVERY_QUEUE_COLUMNS: List[str] = [
    # identity / linkage
    "rqKey",
    "orderId",
    "partId",
    "category",      # BLOCKER / WARNING
    "reason",

    # detection
    "detectedBy",    # WORK_DONE / UF06 / UF07 / manual / etc.
    "detectedAt",
    "details",

    # state
    "status",        # OPEN / RESOLVED / CANCELLED
    "resolvedAt",
    "resolvedBy",
    "resolutionNote",

    # projection refs (optional)
    "taskIdTodoist",
    "taskIdClickUp",
    "taskUrl",

    # request linkage refs (optional; idempotent suppression is handled by caller)
    "requestRef",    # e.g., Request row key / URL / id
]


REQUIRED_COLUMNS: Tuple[str, ...] = (
    "rqKey",
    "orderId",
    "category",
    "reason",
    "detectedBy",
    "status",
)


def empty_row() -> Dict[str, Any]:
    return {c: "" for c in RECOVERY_QUEUE_COLUMNS}


def normalize_row(row: Dict[str, Any]) -> Dict[str, Any]:
    """
    Normalize to the schema columns. Unknown keys are ignored.
    Missing known keys are filled with empty string.
    """
    out = empty_row()
    for k, v in row.items():
        if k in out:
            out[k] = "" if v is None else v
    return out


def validate_row(row: Dict[str, Any]) -> None:
    for k in REQUIRED_COLUMNS:
        v = row.get(k, "")
        if v is None or str(v).strip() == "":
            raise ValueError(f"RecoveryQueue row missing required field: {k}")


def to_row(item: RecoveryItem) -> Dict[str, Any]:
    """
    Convert RecoveryItem to a Ledger row dict following RECOVERY_QUEUE_COLUMNS.
    """
    row = empty_row()
    row["rqKey"] = item.rq_key
    row["orderId"] = item.order_id
    row["partId"] = item.part_id or ""
    row["category"] = item.category.value if hasattr(item.category, "value") else str(item.category)
    row["reason"] = item.reason
    row["detectedBy"] = item.detected_by
    row["detectedAt"] = item.detected_at or ""
    row["details"] = item.details or ""
    row["status"] = item.status.value if hasattr(item.status, "value") else str(item.status)
    row["resolvedAt"] = item.resolved_at or ""
    row["resolvedBy"] = item.resolved_by or ""
    row["resolutionNote"] = item.resolution_note or ""
    # refs left blank by default
    validate_row(row)
    return row


def _append_details(old: str, new: str) -> str:
    old_s = (old or "").strip()
    new_s = (new or "").strip()
    if not new_s:
        return old_s
    if not old_s:
        return new_s
    if new_s in old_s:
        return old_s
    return old_s + "\n---\n" + new_s


def upsert_rows_by_rqkey(
    rows: List[Dict[str, Any]],
    incoming: Dict[str, Any],
    *,
    append_details: bool = True,
) -> Tuple[List[Dict[str, Any]], str]:
    """
    Idempotent upsert into rows by rqKey.

    Contract intent:
    - Same rqKey must NOT create a new row (no duplication).
    - For OPEN rows, details may be appended on re-observation.
    - RESOLVED/CANCELLED require resolvedAt (evidence-based transition).
    """
    inc = normalize_row(incoming)
    validate_row(inc)

    rk = str(inc["rqKey"]).strip()
    if not rk:
        raise ValueError("rqKey is required")

    # Enforce evidence when closing
    st = str(inc.get("status", "")).strip().upper()
    if st in (RecoveryStatus.RESOLVED.value, RecoveryStatus.CANCELLED.value):
        ra = str(inc.get("resolvedAt", "")).strip()
        if not ra:
            raise ValueError("resolvedAt is required when status is RESOLVED/CANCELLED")

    out: List[Dict[str, Any]] = []
    updated = False

    for r in rows:
        rr = normalize_row(r)
        if str(rr.get("rqKey", "")).strip() != rk:
            out.append(rr)
            continue

        # merge fields (prefer incoming non-empty, preserve required)
        merged = rr.copy()

        for k in RECOVERY_QUEUE_COLUMNS:
            if k == "details" and append_details:
                merged["details"] = _append_details(merged.get("details", ""), inc.get("details", ""))
                continue

            v = inc.get(k, "")
            if v is None:
                continue
            vs = str(v).strip() if isinstance(v, str) else v
            if isinstance(v, str):
                if vs != "":
                    merged[k] = v
            else:
                merged[k] = v

        # status transitions: do not auto-reopen a closed item
        old_st = str(rr.get("status", "")).strip().upper()
        new_st = str(merged.get("status", "")).strip().upper()

        if old_st in (RecoveryStatus.RESOLVED.value, RecoveryStatus.CANCELLED.value) and new_st == RecoveryStatus.OPEN.value:
            merged["status"] = rr.get("status", RecoveryStatus.OPEN.value)

        validate_row(merged)
        out.append(merged)
        updated = True

    if not updated:
        out.append(inc)

    return out, ("updated" if updated else "inserted")


def load_rows_csv(path: str) -> List[Dict[str, Any]]:
    p = Path(path)
    if not p.exists():
        return []
    with p.open("r", encoding="utf-8", newline="") as f:
        rd = csv.DictReader(f)
        return [normalize_row(dict(r)) for r in rd]


def save_rows_csv(path: str, rows: List[Dict[str, Any]]) -> None:
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    with p.open("w", encoding="utf-8", newline="") as f:
        wr = csv.DictWriter(f, fieldnames=RECOVERY_QUEUE_COLUMNS)
        wr.writeheader()
        for r in rows:
            rr = normalize_row(r)
            wr.writerow({k: rr.get(k, "") for k in RECOVERY_QUEUE_COLUMNS})


def dump_schema_json() -> str:
    return json.dumps(
        {
            "columns": RECOVERY_QUEUE_COLUMNS,
            "required": list(REQUIRED_COLUMNS),
            "status_enum": [s.value for s in RecoveryStatus],
            "category_enum": [c.value for c in RecoveryCategory],
        },
        ensure_ascii=False,
        indent=2,
    )
