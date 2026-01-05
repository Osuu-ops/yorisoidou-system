# -*- coding: utf-8 -*-
from __future__ import annotations

import json

from tools.mep_integration_compiler.runtime.adapters.http_header_provider import HttpSheetsHeaderProvider
from tools.mep_integration_compiler.runtime.adapters.http_write_client import HttpSheetsWriteClient


class FakeHeaderProvider(HttpSheetsHeaderProvider):
    def __init__(self):
        super().__init__(endpoint_url="http://invalid")
    def fetch_headers(self, spreadsheet_id: str, sheet_name: str):
        # minimal headers to satisfy validator are imported inside validate; we avoid calling validate here.
        return []


def main() -> None:
    # This test is intentionally minimal: ensure module imports.
    c = HttpSheetsWriteClient(header_provider=FakeHeaderProvider(), endpoint_url="http://invalid")
    assert c is not None
    print(json.dumps({"ok": True}, ensure_ascii=False))


if __name__ == "__main__":
    main()
