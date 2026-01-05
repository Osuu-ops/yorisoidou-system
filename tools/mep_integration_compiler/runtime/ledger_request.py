# -*- coding: utf-8 -*-
from __future__ import annotations

import csv
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple


# Phase-2 Ledger schema (Request sheet columns).
# Canonical meaning is in master_spec 3.7 / 3.7.2.
REQUEST_COLUMNS: List[str] = [
    # identity / dedupe
    "requestKey",        # deterministic hash for OPEN dedupe
    "timestamp",         # ISO8601Z (record creation time)

    # classification
    "category",          # FIX / DOC / UF07 / UF08 / NOTE_ADD / REVIEW
    "targetType",        # Order_ID / PART_ID / CU_ID / UP_ID / NONE
    "targetId",          # value consistent with targetType

    # payload
    "payloadJson",       # canonical JSON string (sorted keys)

    # operator/context
    "requester",
    "memo",

    # state
    "requestStatus",     # OPEN / RESOLVED / CANCELLED
    "resolvedAt",
    "resolvedBy",
    "resolutionNote",

    # linkage refs (optional)
    "recoveryRqKey",     # optional: link to Recovery Queue rqKey
    "externalRef",       # optional: url/id in external systems
]

REQUIRED_COLUMNS: Tuple[str, ...] = (
    "requestKey",
    "timestamp",
    "category",
    "targetType",
    "targetId",
    "payloadJson",
    "requestStatus",
)

REQUEST_STATUS_OPEN = "OPEN"
REQUEST_STATUS_RESOLVED = "RESOLVED"
REQUEST_STATUS_CANCELLED = "CANCELLED"


def _sha256_hex(s: str) -> str:
    return hashlib.sha256(s.encode("utf-8")).hexdigest()


def _now_iso_z() -> str:
    dt = datetime.now(timezone.utc).replace(microsecond=0)
    return dt.strftime("%Y-%m-%dT%H:%M:%SZ")


def empty_row() -> Dict[str, Any]:
    return {c: "" for c in REQUEST_COLUMNS}


def normalize_row(row: Dict[str, Any]) -> Dict[str, Any]:
    out = empty_row()
    for k, v in row.items():
        if k in out:
            out[k] = "" if v is None else v
    return out


def validate_row(row: Dict[str, Any]) -> None:
    for k in REQUIRED_COLUMNS:
        v = row.get(k, "")
        if v is None or str(v).strip() == "":
            raise ValueError(f"Request row missing required field: {k}")


def canonical_json(obj: Any) -> str:
    """
    Canonical JSON representation:
    - sort_keys=True
    - ensure_ascii=False
    - separators to stabilize
    """
    return json.dumps(obj, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def make_request_key(payload: Dict[str, Any]) -> str:
    """
    Phase-2 B3 dedupe contract (OPEN dedupe):
    requestKey = Hash(canonical(payload))

    payload MUST include:
      - payloadVersion
      - category
      - targetType
      - targetId
    Optional fields included as-is (canonical-json stabilized).
    """
    if not isinstance(payload, dict):
        raise ValueError("payload must be a dict")

    for k in ("payloadVersion", "category", "targetType", "targetId"):
        if k not in payload or payload[k] is None or str(payload[k]).strip() == "":
            raise ValueError(f"payload missing required key: {k}")

    raw = canonical_json(payload)
    return _sha256_hex(raw)


def make_row_from_payload(
    payload: Dict[str, Any],
    *,
    requester: str = "",
    memo: str = "",
    recovery_rq_key: str = "",
    external_ref: str = "",
    request_status: str = REQUEST_STATUS_OPEN,
    timestamp: Optional[str] = None,
) -> Dict[str, Any]:
    key = make_request_key(payload)
    row = empty_row()
    row["requestKey"] = key
    row["timestamp"] = (timestamp or _now_iso_z())
    row["category"] = str(payload["category"])
    row["targetType"] = str(payload["targetType"])
    row["targetId"] = str(payload["targetId"])
    row["payloadJson"] = canonical_json(payload)
    row["requester"] = requester or ""
    row["memo"] = memo or ""
    row["requestStatus"] = request_status
    row["resolvedAt"] = ""
    row["resolvedBy"] = ""
    row["resolutionNote"] = ""
    row["recoveryRqKey"] = recovery_rq_key or ""
    row["externalRef"] = external_ref or ""
    validate_row(row)
    return row


def _append_memo(old: str, new: str) -> str:
    old_s = (old or "").strip()
    new_s = (new or "").strip()
    if not new_s:
        return old_s
    if not old_s:
        return new_s
    if new_s in old_s:
        return old_s
    return old_s + "\n---\n" + new_s


def upsert_open_dedupe_by_request_key(
    rows: List[Dict[str, Any]],
    incoming: Dict[str, Any],
    *,
    append_memo: bool = True,
) -> Tuple[List[Dict[str, Any]], str]:
    """
    B3 contract:
    - If an OPEN row with same requestKey exists => do NOT insert new row (dedupe).
      Optionally append memo/externalRef/recoveryRqKey when provided.
    - Otherwise insert as a new OPEN row.

    Note:
    - This function does not auto-close or modify RESOLVED/CANCELLED except for non-destructive linkage refs.
    """
    inc = normalize_row(incoming)
    validate_row(inc)

    rk = str(inc.get("requestKey", "")).strip()
    if not rk:
        raise ValueError("requestKey is required")

    out: List[Dict[str, Any]] = []
    deduped = False

    for r in rows:
        rr = normalize_row(r)

        if str(rr.get("requestKey", "")).strip() != rk:
            out.append(rr)
            continue

        status = str(rr.get("requestStatus", "")).strip().upper()
        if status == REQUEST_STATUS_OPEN:
            merged = rr.copy()

            # Only safe enrichments
            if append_memo:
                merged["memo"] = _append_memo(merged.get("memo", ""), inc.get("memo", ""))

            for k in ("recoveryRqKey", "externalRef", "requester"):
                v = str(inc.get(k, "")).strip()
                if v:
                    merged[k] = inc.get(k, "")

            validate_row(merged)
            out.append(merged)
            deduped = True
            continue

        # Existing is closed: keep as-is; allow a new OPEN later (separate row) if required by caller.
        out.append(rr)

    if not deduped:
        out.append(inc)
        return out, "inserted"

    return out, "deduped"


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
        wr = csv.DictWriter(f, fieldnames=REQUEST_COLUMNS)
        wr.writeheader()
        for r in rows:
            rr = normalize_row(r)
            wr.writerow({k: rr.get(k, "") for k in REQUEST_COLUMNS})


def dump_schema_json() -> str:
    return json.dumps(
        {
            "columns": REQUEST_COLUMNS,
            "required": list(REQUIRED_COLUMNS),
            "requestStatus_enum": [REQUEST_STATUS_OPEN, REQUEST_STATUS_RESOLVED, REQUEST_STATUS_CANCELLED],
        },
        ensure_ascii=False,
        indent=2,
    )
