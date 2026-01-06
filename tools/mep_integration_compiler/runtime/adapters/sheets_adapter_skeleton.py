# -*- coding: utf-8 -*-
from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, Optional

from ..ledger_adapter import LedgerAdapter, UpsertResult, EvidenceRequired, LedgerError


@dataclass
class SheetsLedgerAdapterSkeleton:
    """
    Google Sheets adapter skeleton (Phase-2).

    PURPOSE:
    - Provide a stable, interface-compliant boundary for future GAS / Sheets I/O.
    - NO external dependencies (google client libs) and NO credentials here.
    - Actual I/O implementation is a later theme and must remain deterministic + auditable.

    This class is intentionally "NotImplemented" for all I/O methods.
    It exists to fix:
      - method names
      - parameters
      - evidence rules
      - sheet/table naming conventions
    """

    spreadsheet_id: str
    # Sheet/tab names (defaults align with Phase-2 specs)
    recovery_queue_sheet: str = "Recovery_Queue"
    request_sheet: str = "Request"
    # Optional: where to store logs/index rows if needed later
    logs_index_sheet: str = "logs_index"

    def _not_impl(self, msg: str) -> None:
        raise NotImplementedError(
            "SheetsLedgerAdapterSkeleton: I/O not implemented. " + msg +
            " (This skeleton is the contract boundary only.)"
        )

    # ===== LedgerAdapter: Recovery Queue =====
    def upsert_recovery(self, row: Dict[str, Any]) -> UpsertResult:
        # row must follow ledger_recovery_queue.RECOVERY_QUEUE_COLUMNS
        self._not_impl("upsert_recovery")
        return UpsertResult(op="noop", key=str(row.get("rqKey", "")).strip())

    def get_recovery_by_rqkey(self, rq_key: str) -> Optional[Dict[str, Any]]:
        self._not_impl("get_recovery_by_rqkey")
        return None

    def close_recovery(
        self,
        rq_key: str,
        status: str,
        resolved_at: str,
        resolved_by: str = "",
        resolution_note: str = "",
    ) -> UpsertResult:
        rk = (rq_key or "").strip()
        st = (status or "").strip().upper()
        ra = (resolved_at or "").strip()

        if not rk:
            raise ValueError("rq_key is required")
        if st not in ("RESOLVED", "CANCELLED"):
            raise ValueError("status must be RESOLVED or CANCELLED")
        if not ra:
            # Evidence-based close is mandatory (Phase-2 contract)
            raise EvidenceRequired("resolved_at is required for RESOLVED/CANCELLED")

        self._not_impl("close_recovery")
        return UpsertResult(op="noop", key=rk)

    # ===== LedgerAdapter: Request (OPEN dedupe) =====
    def upsert_request_open_dedupe(self, row: Dict[str, Any]) -> UpsertResult:
        # row must follow ledger_request.REQUEST_COLUMNS
        self._not_impl("upsert_request_open_dedupe")
        return UpsertResult(op="noop", key=str(row.get("requestKey", "")).strip())

    def find_open_request_by_key(self, request_key: str) -> Optional[Dict[str, Any]]:
        self._not_impl("find_open_request_by_key")
        return None
