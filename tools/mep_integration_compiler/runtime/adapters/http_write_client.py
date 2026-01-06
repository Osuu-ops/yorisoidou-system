# -*- coding: utf-8 -*-
from __future__ import annotations

import json
import os
import urllib.parse
import urllib.request
from dataclasses import dataclass
from typing import Any, Dict, Optional

from .http_header_provider import HttpSheetsHeaderProvider
from .sheets_header_fetcher import validate_sheet_schema
from ..ledger_recovery_queue import RECOVERY_QUEUE_COLUMNS
from ..ledger_request import REQUEST_COLUMNS


ENV_WRITE_ENDPOINT = "MEP_SHEETS_WRITE_ENDPOINT"


def _json_loads_maybe(s: str) -> Any:
    try:
        return json.loads(s)
    except Exception:
        return None


@dataclass
class HttpSheetsWriteClient:
    """
    Write-path client (Phase-2) over HTTP.

    This client is SAFE by construction:
    - Always validates sheet schema (B11/B9/B8) before any write attempt.
    - Supports dry-run mode (default) to prevent accidental writes.

    Endpoint is not committed; provide endpoint_url or env MEP_SHEETS_WRITE_ENDPOINT.

    Expected write endpoint contract (to be implemented in GAS later):
      POST JSON:
        {
          "op": "upsert",
          "sheetName": "Recovery_Queue" | "Request",
          "keyField": "rqKey" | "requestKey",
          "row": { ... }   # dict keyed by schema columns
        }

      Response JSON:
        { "ok": true, "op": "inserted|updated|deduped", "key": "...", "sheetName": "...", "message": "" }
    """
    header_provider: HttpSheetsHeaderProvider
    endpoint_url: str = ""
    timeout_seconds: int = 30
    user_agent: str = "MEP-SheetsWriteClient/1.0"

    def _endpoint(self) -> str:
        ep = (self.endpoint_url or "").strip()
        if ep:
            return ep
        ep = (os.environ.get(ENV_WRITE_ENDPOINT) or "").strip()
        if ep:
            return ep
        raise RuntimeError(f"Write endpoint not set. Provide endpoint_url or set env {ENV_WRITE_ENDPOINT}.")

    def _post_json(self, payload: Dict[str, Any]) -> Dict[str, Any]:
        ep = self._endpoint()
        data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        req = urllib.request.Request(ep, data=data, method="POST")
        req.add_header("Content-Type", "application/json; charset=utf-8")
        req.add_header("Accept", "application/json")
        req.add_header("User-Agent", self.user_agent)

        with urllib.request.urlopen(req, timeout=self.timeout_seconds) as resp:
            raw = resp.read().decode("utf-8", errors="replace")
        obj = _json_loads_maybe(raw)
        if not isinstance(obj, dict):
            raise ValueError("Write endpoint did not return JSON dict")
        return obj

    def _ensure_schema(self, spreadsheet_id: str, sheet_name: str, kind: str) -> None:
        validate_sheet_schema(self.header_provider, spreadsheet_id=spreadsheet_id, sheet_name=sheet_name, kind=kind)

    def upsert_recovery_queue_row(self, *, spreadsheet_id: str, row: Dict[str, Any], dry_run: bool = True) -> Dict[str, Any]:
        self._ensure_schema(spreadsheet_id, "Recovery_Queue", "RECOVERY_QUEUE")
        if dry_run:
            return {"ok": True, "dry_run": True, "sheetName": "Recovery_Queue", "keyField": "rqKey", "key": str(row.get("rqKey", "")).strip()}

        return self._post_json({
            "op": "upsert",
            "sheetName": "Recovery_Queue",
            "keyField": "rqKey",
            "row": row,
        })

    def upsert_request_open_row(self, *, spreadsheet_id: str, row: Dict[str, Any], dry_run: bool = True) -> Dict[str, Any]:
        self._ensure_schema(spreadsheet_id, "Request", "REQUEST")
        if dry_run:
            return {"ok": True, "dry_run": True, "sheetName": "Request", "keyField": "requestKey", "key": str(row.get("requestKey", "")).strip()}

        return self._post_json({
            "op": "upsert_open_dedupe",
            "sheetName": "Request",
            "keyField": "requestKey",
            "row": row,
        })
