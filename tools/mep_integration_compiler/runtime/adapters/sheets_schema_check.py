# -*- coding: utf-8 -*-
from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, List, Optional, Sequence, Tuple

from ..ledger_recovery_queue import RECOVERY_QUEUE_COLUMNS
from ..ledger_request import REQUEST_COLUMNS


@dataclass(frozen=True)
class HeaderCheckResult:
    ok: bool
    sheet_kind: str
    expected: List[str]
    actual: List[str]
    missing: List[str]
    extra: List[str]
    order_mismatch: bool
    message: str


def _normalize_headers(headers: Sequence[str]) -> List[str]:
    return [str(h).strip() for h in headers if str(h).strip() != ""]


def expected_headers(sheet_kind: str) -> List[str]:
    k = (sheet_kind or "").strip().upper()
    if k in ("RECOVERY", "RECOVERY_QUEUE", "RQ"):
        return list(RECOVERY_QUEUE_COLUMNS)
    if k in ("REQUEST", "REQ"):
        return list(REQUEST_COLUMNS)
    raise ValueError(f"Unknown sheet_kind: {sheet_kind}")


def check_headers(sheet_kind: str, actual_headers: Sequence[str]) -> HeaderCheckResult:
    expected = expected_headers(sheet_kind)
    actual = _normalize_headers(actual_headers)

    exp_set = set(expected)
    act_set = set(actual)

    missing = [c for c in expected if c not in act_set]
    extra = [c for c in actual if c not in exp_set]

    # Order mismatch: same set but different order
    order_mismatch = (missing == [] and extra == [] and actual != expected)

    ok = (len(missing) == 0 and len(extra) == 0 and not order_mismatch)

    msg = ""
    if ok:
        msg = "OK: header matches expected schema (exact columns + order)."
    else:
        parts: List[str] = []
        if missing:
            parts.append("missing=" + ",".join(missing))
        if extra:
            parts.append("extra=" + ",".join(extra))
        if order_mismatch:
            parts.append("order_mismatch=true")
        msg = "NG: " + " ".join(parts)

    return HeaderCheckResult(
        ok=ok,
        sheet_kind=(sheet_kind or "").strip(),
        expected=expected,
        actual=actual,
        missing=missing,
        extra=extra,
        order_mismatch=order_mismatch,
        message=msg,
    )
