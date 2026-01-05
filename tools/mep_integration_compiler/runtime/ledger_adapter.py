# -*- coding: utf-8 -*-
from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, Optional, Protocol, Tuple


class LedgerError(RuntimeError):
    pass


class EvidenceRequired(LedgerError):
    pass


@dataclass(frozen=True)
class UpsertResult:
    op: str  # inserted/updated/deduped
    key: str
    extra: Optional[Dict[str, Any]] = None


class LedgerAdapter(Protocol):
    """
    Phase-2 I/O boundary.
    This is an INTERFACE ONLY; implementations may target:
      - Google Sheets (GAS)
      - Local CSV (deterministic tests)
      - In-memory mocks

    Contract constraints:
      - Ledger is authority.
      - Upserts must be idempotent (no duplication).
      - Closing (RESOLVED/CANCELLED) requires evidence fields.
    """

    # Recovery Queue (rqKey identity)
    def upsert_recovery(self, row: Dict[str, Any]) -> UpsertResult: ...
    def get_recovery_by_rqkey(self, rq_key: str) -> Optional[Dict[str, Any]]: ...
    def close_recovery(self, rq_key: str, status: str, resolved_at: str, resolved_by: str = "", resolution_note: str = "") -> UpsertResult: ...

    # Request (OPEN dedupe by requestKey)
    def upsert_request_open_dedupe(self, row: Dict[str, Any]) -> UpsertResult: ...
    def find_open_request_by_key(self, request_key: str) -> Optional[Dict[str, Any]]: ...
