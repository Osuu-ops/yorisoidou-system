# -*- coding: utf-8 -*-
from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, Optional

from ..ledger_adapter import LedgerAdapter, UpsertResult, EvidenceRequired
from ..ledger_recovery_queue import load_rows_csv as load_rq, save_rows_csv as save_rq, upsert_rows_by_rqkey
from ..ledger_request import load_rows_csv as load_req, save_rows_csv as save_req, upsert_open_dedupe_by_request_key


@dataclass
class CsvLedgerAdapter:
    """
    Deterministic adapter using CSV files.
    Intended for B4/B5 local tests and future wiring verification.

    Paths:
      - recovery_queue_csv: Recovery Queue ledger table (CSV)
      - request_csv: Request ledger table (CSV)
    """
    recovery_queue_csv: str
    request_csv: str

    def upsert_recovery(self, row: Dict[str, Any]) -> UpsertResult:
        rows = load_rq(self.recovery_queue_csv)
        rows2, op = upsert_rows_by_rqkey(rows, row, append_details=True)
        save_rq(self.recovery_queue_csv, rows2)
        return UpsertResult(op=op, key=str(row.get("rqKey", "")).strip())

    def get_recovery_by_rqkey(self, rq_key: str) -> Optional[Dict[str, Any]]:
        rk = (rq_key or "").strip()
        if not rk:
            return None
        rows = load_rq(self.recovery_queue_csv)
        for r in rows:
            if str(r.get("rqKey", "")).strip() == rk:
                return r
        return None

    def close_recovery(self, rq_key: str, status: str, resolved_at: str, resolved_by: str = "", resolution_note: str = "") -> UpsertResult:
        rk = (rq_key or "").strip()
        st = (status or "").strip().upper()
        ra = (resolved_at or "").strip()
        if not rk:
            raise ValueError("rq_key is required")
        if st not in ("RESOLVED", "CANCELLED"):
            raise ValueError("status must be RESOLVED or CANCELLED")
        if not ra:
            raise EvidenceRequired("resolved_at is required for RESOLVED/CANCELLED")

        existing = self.get_recovery_by_rqkey(rk)
        if not existing:
            raise ValueError("rqKey not found")

        upd = dict(existing)
        upd["status"] = st
        upd["resolvedAt"] = ra
        upd["resolvedBy"] = resolved_by or ""
        upd["resolutionNote"] = resolution_note or ""

        rows = load_rq(self.recovery_queue_csv)
        rows2, op = upsert_rows_by_rqkey(rows, upd, append_details=False)
        save_rq(self.recovery_queue_csv, rows2)
        return UpsertResult(op=op, key=rk)

    def upsert_request_open_dedupe(self, row: Dict[str, Any]) -> UpsertResult:
        rows = load_req(self.request_csv)
        rows2, op = upsert_open_dedupe_by_request_key(rows, row, append_memo=True)
        save_req(self.request_csv, rows2)
        return UpsertResult(op=op, key=str(row.get("requestKey", "")).strip())

    def find_open_request_by_key(self, request_key: str) -> Optional[Dict[str, Any]]:
        rk = (request_key or "").strip()
        if not rk:
            return None
        rows = load_req(self.request_csv)
        for r in rows:
            if str(r.get("requestKey", "")).strip() == rk and str(r.get("requestStatus", "")).strip().upper() == "OPEN":
                return r
        return None
