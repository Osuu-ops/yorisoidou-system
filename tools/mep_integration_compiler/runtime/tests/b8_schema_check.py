# -*- coding: utf-8 -*-
from __future__ import annotations

import json

from tools.mep_integration_compiler.runtime.adapters.sheets_schema_check import check_headers
from tools.mep_integration_compiler.runtime.ledger_recovery_queue import RECOVERY_QUEUE_COLUMNS
from tools.mep_integration_compiler.runtime.ledger_request import REQUEST_COLUMNS


def main() -> None:
    # Exact match should pass
    r1 = check_headers("RECOVERY_QUEUE", RECOVERY_QUEUE_COLUMNS)
    assert r1.ok, r1.message

    r2 = check_headers("REQUEST", REQUEST_COLUMNS)
    assert r2.ok, r2.message

    # Missing column should fail
    bad = list(REQUEST_COLUMNS[:-1])
    r3 = check_headers("REQUEST", bad)
    assert (not r3.ok) and r3.missing, "Expected missing column failure"

    # Order mismatch should fail (strict)
    swapped = list(RECOVERY_QUEUE_COLUMNS)
    if len(swapped) >= 2:
        swapped[0], swapped[1] = swapped[1], swapped[0]
    r4 = check_headers("RECOVERY_QUEUE", swapped)
    assert (not r4.ok) and r4.order_mismatch, "Expected order mismatch failure"

    print(json.dumps({"ok": True}, ensure_ascii=False))


if __name__ == "__main__":
    main()
