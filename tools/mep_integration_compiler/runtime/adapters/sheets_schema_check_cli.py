# -*- coding: utf-8 -*-
from __future__ import annotations

import argparse
import json
import sys
from typing import List

from .sheets_schema_check import check_headers


def main() -> None:
    ap = argparse.ArgumentParser(prog="mep_phase2_sheets_schema_check")
    ap.add_argument("--kind", required=True, help="RECOVERY_QUEUE or REQUEST")
    ap.add_argument("--headers-json", required=True, help="JSON array of header strings")
    args = ap.parse_args()

    headers: List[str] = json.loads(args.headers_json)
    r = check_headers(args.kind, headers)

    out = {
        "ok": r.ok,
        "kind": r.sheet_kind,
        "missing": r.missing,
        "extra": r.extra,
        "order_mismatch": r.order_mismatch,
        "message": r.message,
    }
    print(json.dumps(out, ensure_ascii=False, indent=2))
    if not r.ok:
        sys.exit(2)


if __name__ == "__main__":
    main()
