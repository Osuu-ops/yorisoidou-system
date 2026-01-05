# -*- coding: utf-8 -*-
from __future__ import annotations

from dataclasses import dataclass
from typing import List, Protocol, Sequence

from .sheets_schema_check import check_headers


class SheetsHeaderProvider(Protocol):
    """
    Read-only boundary for fetching a sheet's header row.
    This keeps Phase-2 safe by separating:
      - transport/auth (future theme)
      - schema validation (B8)
    """
    def fetch_headers(self, spreadsheet_id: str, sheet_name: str) -> List[str]: ...


@dataclass
class SheetsHeaderProviderSkeleton:
    """
    Skeleton that defines the callpoint but performs no I/O.
    Implementations will be added later (GAS/HTTP or Google API client).
    """
    def fetch_headers(self, spreadsheet_id: str, sheet_name: str) -> List[str]:
        raise NotImplementedError("SheetsHeaderProviderSkeleton: fetch_headers I/O not implemented")


def validate_sheet_schema(
    provider: SheetsHeaderProvider,
    *,
    spreadsheet_id: str,
    sheet_name: str,
    kind: str,  # RECOVERY_QUEUE or REQUEST
) -> None:
    """
    Fetch the header row (read-only), then validate against the Phase-2 schema (B8).
    Raises SystemExit(2) semantics are not used here; callers decide how to handle NG.
    """
    headers = provider.fetch_headers(spreadsheet_id, sheet_name)
    r = check_headers(kind, headers)
    if not r.ok:
        raise ValueError(
            f"Sheet schema mismatch: kind={kind} sheet={sheet_name} "
            f"missing={r.missing} extra={r.extra} order_mismatch={r.order_mismatch}"
        )
