# -*- coding: utf-8 -*-
from __future__ import annotations

import argparse
import json
from pathlib import Path

from .ledger_recovery_queue import (
    dump_schema_json,
    load_rows_csv,
    save_rows_csv,
    upsert_rows_by_rqkey,
)
from .recovery_queue import RecoveryItem, RecoveryCategory, RecoveryStatus
from .idempotency import make_recovery_queue_key


def main() -> None:
    ap = argparse.ArgumentParser(prog="mep_phase2_ledger")
    sub = ap.add_subparsers(dest="cmd", required=True)

    s0 = sub.add_parser("schema")
    s0.add_argument("--out", default="", help="optional output path (json)")

    s1 = sub.add_parser("upsert-csv")
    s1.add_argument("--csv", required=True, help="path to recovery_queue.csv")
    s1.add_argument("--order-id", required=True)
    s1.add_argument("--category", required=True, choices=["BLOCKER", "WARNING"])
    s1.add_argument("--reason", required=True)
    s1.add_argument("--detected-by", required=True)
    s1.add_argument("--detected-at", default="")
    s1.add_argument("--part-id", default="")
    s1.add_argument("--details", default="")
    s1.add_argument("--status", default="OPEN", choices=["OPEN", "RESOLVED", "CANCELLED"])
    s1.add_argument("--resolved-at", default="")
    s1.add_argument("--resolved-by", default="")
    s1.add_argument("--resolution-note", default="")

    args = ap.parse_args()

    if args.cmd == "schema":
        txt = dump_schema_json()
        if args.out:
            Path(args.out).write_text(txt, encoding="utf-8")
        print(txt)
        return

    if args.cmd == "upsert-csv":
        rq_key = make_recovery_queue_key(
            order_id=args.order_id,
            category=args.category,
            reason=args.reason,
            detected_by=args.detected_by,
            part_id=(args.part_id or None),
        )

        item = RecoveryItem(
            rq_key=rq_key,
            order_id=args.order_id,
            category=RecoveryCategory(args.category),
            reason=args.reason,
            detected_by=args.detected_by,
            detected_at=(args.detected_at or None),
            part_id=(args.part_id or None),
            details=(args.details or None),
            status=RecoveryStatus(args.status),
            resolved_at=(args.resolved_at or None),
            resolved_by=(args.resolved_by or None),
            resolution_note=(args.resolution_note or None),
        )

        rows = load_rows_csv(args.csv)
        rows2, op = upsert_rows_by_rqkey(rows, item.to_row(), append_details=True)
        save_rows_csv(args.csv, rows2)
        print(json.dumps({"op": op, "rqKey": rq_key, "rows": len(rows2)}, ensure_ascii=False))

        return


if __name__ == "__main__":
    main()
