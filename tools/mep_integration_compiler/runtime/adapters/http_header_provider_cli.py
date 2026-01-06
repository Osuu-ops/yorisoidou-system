# -*- coding: utf-8 -*-
from __future__ import annotations

import argparse
import json

from .http_header_provider import HttpSheetsHeaderProvider
from .sheets_header_fetcher import validate_sheet_schema


def main() -> None:
    ap = argparse.ArgumentParser(prog="mep_phase2_http_header_check")
    ap.add_argument("--endpoint", default="", help="Optional endpoint URL. If omitted, use env MEP_SHEETS_HEADER_ENDPOINT.")
    ap.add_argument("--spreadsheet-id", required=True)
    ap.add_argument("--sheet-name", required=True)
    ap.add_argument("--kind", required=True, help="RECOVERY_QUEUE or REQUEST")
    args = ap.parse_args()

    provider = HttpSheetsHeaderProvider(endpoint_url=args.endpoint)
    validate_sheet_schema(
        provider,
        spreadsheet_id=args.spreadsheet_id,
        sheet_name=args.sheet_name,
        kind=args.kind,
    )
    print(json.dumps({"ok": True}, ensure_ascii=False))


if __name__ == "__main__":
    main()
