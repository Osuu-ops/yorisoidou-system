# -*- coding: utf-8 -*-
from __future__ import annotations

import json
import os
import urllib.parse
import urllib.request
from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Sequence

from .sheets_header_fetcher import SheetsHeaderProvider


ENV_ENDPOINT = "MEP_SHEETS_HEADER_ENDPOINT"


def parse_headers_response(payload: Any) -> List[str]:
    """
    Parse endpoint JSON into a header list.

    Supported shapes (minimal/robust):
      - {"headers": ["colA","colB",...]}
      - {"ok": true, "headers": [...]}
      - {"data": {"headers": [...]}}  (optional nesting)
    """
    if payload is None:
        raise ValueError("payload is None")

    obj = payload
    if isinstance(obj, str):
        obj = json.loads(obj)

    if isinstance(obj, dict):
        if "data" in obj and isinstance(obj["data"], dict) and "headers" in obj["data"]:
            obj = obj["data"]
        if "headers" in obj:
            hs = obj["headers"]
            if not isinstance(hs, list):
                raise ValueError("headers must be a list")
            out = []
            for h in hs:
                s = str(h).strip()
                if s:
                    out.append(s)
            return out

    raise ValueError("Unsupported payload shape (expected dict with 'headers' list)")


@dataclass
class HttpSheetsHeaderProvider(SheetsHeaderProvider):
    """
    Read-only HTTP provider.

    Endpoint is NOT hardcoded.
    - Provide endpoint_url explicitly OR set env MEP_SHEETS_HEADER_ENDPOINT.
    - This keeps secrets/URLs out of repo history.

    Request (GET):
      endpoint?spreadsheetId=...&sheetName=...

    Response JSON:
      {"headers": ["rqKey","orderId",...]}  (see parse_headers_response)
    """
    endpoint_url: str = ""
    timeout_seconds: int = 20
    user_agent: str = "MEP-SheetsHeaderProvider/1.0"

    def _endpoint(self) -> str:
        ep = (self.endpoint_url or "").strip()
        if ep:
            return ep
        ep = (os.environ.get(ENV_ENDPOINT) or "").strip()
        if ep:
            return ep
        raise RuntimeError(
            f"Endpoint not set. Provide endpoint_url or set env {ENV_ENDPOINT}."
        )

    def fetch_headers(self, spreadsheet_id: str, sheet_name: str) -> List[str]:
        sid = (spreadsheet_id or "").strip()
        sn = (sheet_name or "").strip()
        if not sid:
            raise ValueError("spreadsheet_id is required")
        if not sn:
            raise ValueError("sheet_name is required")

        ep = self._endpoint()
        qs = urllib.parse.urlencode({"spreadsheetId": sid, "sheetName": sn})
        url = ep + ("&" if "?" in ep else "?") + qs

        req = urllib.request.Request(url, method="GET")
        req.add_header("Accept", "application/json")
        req.add_header("User-Agent", self.user_agent)

        with urllib.request.urlopen(req, timeout=self.timeout_seconds) as resp:
            raw = resp.read().decode("utf-8", errors="replace")

        payload = json.loads(raw)
        return parse_headers_response(payload)
