# -*- coding: utf-8 -*-
from __future__ import annotations

import json

from tools.mep_integration_compiler.runtime.adapters.sheets_header_fetcher import validate_sheet_schema
from tools.mep_integration_compiler.runtime.adapters.sheets_schema_check import expected_headers


class FakeProvider:
    def __init__(self, headers):
        self._headers = headers

    def fetch_headers(self, spreadsheet_id: str, sheet_name: str):
        return list(self._headers)


def main() -> None:
    # Pass case
    p1 = FakeProvider(expected_headers("RECOVERY_QUEUE"))
    validate_sheet_schema(p1, spreadsheet_id="dummy", sheet_name="Recovery_Queue", kind="RECOVERY_QUEUE")

    p2 = FakeProvider(expected_headers("REQUEST"))
    validate_sheet_schema(p2, spreadsheet_id="dummy", sheet_name="Request", kind="REQUEST")

    # Fail case (missing last column)
    bad = expected_headers("REQUEST")[:-1]
    p3 = FakeProvider(bad)
    try:
        validate_sheet_schema(p3, spreadsheet_id="dummy", sheet_name="Request", kind="REQUEST")
        raise AssertionError("Expected schema mismatch")
    except ValueError:
        pass

    print(json.dumps({"ok": True}, ensure_ascii=False))


if __name__ == "__main__":
    main()
