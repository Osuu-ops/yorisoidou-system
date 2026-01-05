# -*- coding: utf-8 -*-
from __future__ import annotations

import argparse
import json
from pathlib import Path

from .ledger_request import (
    dump_schema_json,
    load_rows_csv,
    save_rows_csv,
    make_row_from_payload,
    upsert_open_dedupe_by_request_key,
    canonical_json,
)


def main() -> None:
    ap = argparse.ArgumentParser(prog="mep_phase2_request")
    sub = ap.add_subparsers(dest="cmd", required=True)

    s0 = sub.add_parser("schema")
    s0.add_argument("--out", default="", help="optional output path (json)")

    s1 = sub.add_parser("upsert-open-csv")
    s1.add_argument("--csv", required=True)
    s1.add_argument("--payload-json", required=True, help="raw JSON string for PayloadJSON")
    s1.add_argument("--requester", default="")
    s1.add_argument("--memo", default="")
    s1.add_argument("--recovery-rq-key", default="")
    s1.add_argument("--external-ref", default="")

    args = ap.parse_args()

    if args.cmd == "schema":
        txt = dump_schema_json()
        if args.out:
            Path(args.out).write_text(txt, encoding="utf-8")
        print(txt)
        return

    if args.cmd == "upsert-open-csv":
        payload = json.loads(args.payload_json)
        row = make_row_from_payload(
            payload,
            requester=args.requester,
            memo=args.memo,
            recovery_rq_key=args.recovery_rq_key,
            external_ref=args.external_ref,
            request_status="OPEN",
        )

        rows = load_rows_csv(args.csv)
        rows2, op = upsert_open_dedupe_by_request_key(rows, row, append_memo=True)
        save_rows_csv(args.csv, rows2)

        print(json.dumps({"op": op, "requestKey": row["requestKey"], "rows": len(rows2)}, ensure_ascii=False))
        return


if __name__ == "__main__":
    main()
