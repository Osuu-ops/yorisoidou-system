# -*- coding: utf-8 -*-
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path

from .http_header_provider import HttpSheetsHeaderProvider
from .http_write_client import HttpSheetsWriteClient


def main() -> None:
    ap = argparse.ArgumentParser(prog="mep_phase2_http_write")
    ap.add_argument("--header-endpoint", default=os.environ.get("MEP_SHEETS_HEADER_ENDPOINT", ""), help="GAS header /exec URL")
    ap.add_argument("--write-endpoint", default=os.environ.get("MEP_SHEETS_WRITE_ENDPOINT", ""), help="GAS write endpoint URL (POST)")
    ap.add_argument("--spreadsheet-id", required=True)
    ap.add_argument("--kind", required=True, choices=["RECOVERY_QUEUE", "REQUEST"])
    ap.add_argument("--row-json", default="", help="Row dict as JSON (use --row-json-file if quoting breaks in PowerShell)")
    ap.add_argument("--row-json-file", default="", help="Path to JSON file containing the row dict (recommended on Windows/PowerShell)")
    ap.add_argument("--dry-run", action="store_true", help="Do not write; only validate schema and show key")
    args = ap.parse_args()

    hp = HttpSheetsHeaderProvider(endpoint_url=args.header_endpoint)
    wc = HttpSheetsWriteClient(header_provider=hp, endpoint_url=args.write_endpoint)
    row_src = (args.row_json or "").strip()
    if args.row_json_file:
        p = Path(args.row_json_file)
        if not p.exists():
            raise SystemExit(f"--row-json-file not found: {args.row_json_file}")
        row_src = p.read_text(encoding="utf-8-sig").strip()
    if not row_src:
        ap.error("one of --row-json or --row-json-file is required")
    row_src = row_src.lstrip("\ufeff")
    row = json.loads(row_src)
    if args.kind == "RECOVERY_QUEUE":
        out = wc.upsert_recovery_queue_row(spreadsheet_id=args.spreadsheet_id, row=row, dry_run=args.dry_run)
    else:
        out = wc.upsert_request_open_row(spreadsheet_id=args.spreadsheet_id, row=row, dry_run=args.dry_run)

    print(json.dumps(out, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()


