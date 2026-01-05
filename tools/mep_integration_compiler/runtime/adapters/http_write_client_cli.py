# -*- coding: utf-8 -*-
from __future__ import annotations

import argparse
import json
import os

from .http_header_provider import HttpSheetsHeaderProvider
from .http_write_client import HttpSheetsWriteClient


def main() -> None:
    ap = argparse.ArgumentParser(prog="mep_phase2_http_write")
    ap.add_argument("--header-endpoint", default=os.environ.get("MEP_SHEETS_HEADER_ENDPOINT", ""), help="GAS header /exec URL")
    ap.add_argument("--write-endpoint", default=os.environ.get("MEP_SHEETS_WRITE_ENDPOINT", ""), help="GAS write endpoint URL (POST)")
    ap.add_argument("--spreadsheet-id", required=True)
    ap.add_argument("--kind", required=True, choices=["RECOVERY_QUEUE", "REQUEST"])
    ap.add_argument("--row-json", required=True, help="Row dict as JSON")
    ap.add_argument("--dry-run", action="store_true", help="Do not write; only validate schema and show key")
    args = ap.parse_args()

    hp = HttpSheetsHeaderProvider(endpoint_url=args.header_endpoint)
    wc = HttpSheetsWriteClient(header_provider=hp, endpoint_url=args.write_endpoint)

    row = json.loads(args.row_json)
    if args.kind == "RECOVERY_QUEUE":
        out = wc.upsert_recovery_queue_row(spreadsheet_id=args.spreadsheet_id, row=row, dry_run=args.dry_run)
    else:
        out = wc.upsert_request_open_row(spreadsheet_id=args.spreadsheet_id, row=row, dry_run=args.dry_run)

    print(json.dumps(out, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
