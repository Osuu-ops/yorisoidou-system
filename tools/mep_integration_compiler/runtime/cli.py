# -*- coding: utf-8 -*-
from __future__ import annotations

import argparse
import json
from typing import Optional

from .idempotency import make_idempotency_key, make_resync_key, make_recovery_queue_key
from .request_linkage import suggest_requests_for_recovery

def main() -> None:
    ap = argparse.ArgumentParser(prog="mep_phase2_runtime")
    sub = ap.add_subparsers(dest="cmd", required=True)

    s1 = sub.add_parser("idempotency-key")
    s1.add_argument("--event-type", required=True)
    s1.add_argument("--primary-id", required=True)
    s1.add_argument("--event-at", required=True)
    s1.add_argument("--source-id", default=None)

    s2 = sub.add_parser("resync-key")
    s2.add_argument("--order-id", required=True)
    s2.add_argument("--target", required=True)
    s2.add_argument("--reason", required=True)
    s2.add_argument("--requested-id", required=True)

    s3 = sub.add_parser("rq-key")
    s3.add_argument("--order-id", required=True)
    s3.add_argument("--category", required=True)
    s3.add_argument("--reason", required=True)
    s3.add_argument("--detected-by", required=True)
    s3.add_argument("--part-id", default=None)

    s4 = sub.add_parser("suggest-requests")
    s4.add_argument("--reason", required=True)
    s4.add_argument("--order-id", required=True)
    s4.add_argument("--part-id", default=None)
    s4.add_argument("--memo", default=None)

    args = ap.parse_args()

    if args.cmd == "idempotency-key":
        k = make_idempotency_key(args.event_type, args.primary_id, args.event_at, args.source_id)
        print(k)
        return
    if args.cmd == "resync-key":
        k = make_resync_key(args.order_id, args.target, args.reason, args.requested_id)
        print(k)
        return
    if args.cmd == "rq-key":
        k = make_recovery_queue_key(args.order_id, args.category, args.reason, args.detected_by, args.part_id)
        print(k)
        return
    if args.cmd == "suggest-requests":
        xs = suggest_requests_for_recovery(args.reason, args.order_id, args.part_id, args.memo)
        print(json.dumps(xs, ensure_ascii=False, indent=2))
        return

if __name__ == "__main__":
    main()
