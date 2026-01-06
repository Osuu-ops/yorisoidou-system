# -*- coding: utf-8 -*-
from __future__ import annotations

import json
from pathlib import Path

from tools.mep_integration_compiler.runtime.idempotency import make_recovery_queue_key, make_resync_key
from tools.mep_integration_compiler.runtime.recovery_queue import RecoveryItem, RecoveryCategory, RecoveryStatus
from tools.mep_integration_compiler.runtime.request_linkage import suggest_requests_for_recovery
from tools.mep_integration_compiler.runtime.ledger_recovery_queue import (
    load_rows_csv as load_rq,
    save_rows_csv as save_rq,
    upsert_rows_by_rqkey as upsert_rq,
)
from tools.mep_integration_compiler.runtime.ledger_request import (
    load_rows_csv as load_req,
    save_rows_csv as save_req,
    make_row_from_payload,
    upsert_open_dedupe_by_request_key,
)

ROOT = Path(".mep/tmp/b4_e2e")
RQ_CSV = ROOT / "recovery_queue.csv"
REQ_CSV = ROOT / "request.csv"


def reset_workspace() -> None:
    ROOT.mkdir(parents=True, exist_ok=True)
    if RQ_CSV.exists():
        RQ_CSV.unlink()
    if REQ_CSV.exists():
        REQ_CSV.unlink()


def assert_eq(a, b, msg: str) -> None:
    if a != b:
        raise AssertionError(f"{msg}: expected={b} actual={a}")


def main() -> None:
    reset_workspace()

    order_id = "ORDER-20260105-00001-UP-AA001-0001"
    part_id = "BP-202601-AA01-PA01"

    # --- 1) Create/Upsert Recovery Queue item (BLOCKER: PRICE未確定) ---
    rq_key = make_recovery_queue_key(order_id, "BLOCKER", "PRICE未確定", "WORK_DONE", part_id)
    item = RecoveryItem(
        rq_key=rq_key,
        order_id=order_id,
        category=RecoveryCategory.BLOCKER,
        reason="PRICE未確定",
        detected_by="WORK_DONE",
        detected_at="2026-01-05T10:30:00Z",
        part_id=part_id,
        details="BPのPRICE未確定。経費確定不可。",
        status=RecoveryStatus.OPEN,
    )

    rows = load_rq(str(RQ_CSV))
    rows2, op = upsert_rq(rows, item.to_row(), append_details=True)
    save_rq(str(RQ_CSV), rows2)
    assert_eq(op, "inserted", "RQ first upsert should insert")
    assert_eq(len(rows2), 1, "RQ rows after insert")

    # --- 2) Re-observation must NOT duplicate (same rqKey) ---
    item2 = RecoveryItem(
        rq_key=rq_key,
        order_id=order_id,
        category=RecoveryCategory.BLOCKER,
        reason="PRICE未確定",
        detected_by="WORK_DONE",
        detected_at="2026-01-05T10:31:00Z",
        part_id=part_id,
        details="再観測: まだPRICE未確定。",
        status=RecoveryStatus.OPEN,
    )
    rows = load_rq(str(RQ_CSV))
    rows3, op2 = upsert_rq(rows, item2.to_row(), append_details=True)
    save_rq(str(RQ_CSV), rows3)
    assert_eq(op2, "updated", "RQ second upsert should update")
    assert_eq(len(rows3), 1, "RQ must not duplicate on same rqKey")

    # --- 3) Request linkage suggestion: PRICE未確定 -> UF07 (OPEN) ---
    payloads = suggest_requests_for_recovery("PRICE未確定", order_id, part_id, memo="価格確定入力を依頼")
    assert_eq(len(payloads), 1, "UF07 suggestion should produce 1 payload")
    p = payloads[0]
    row = make_row_from_payload(p, requester="system", memo="auto", recovery_rq_key=rq_key, request_status="OPEN")

    req_rows = load_req(str(REQ_CSV))
    req_rows2, rop = upsert_open_dedupe_by_request_key(req_rows, row, append_memo=True)
    save_req(str(REQ_CSV), req_rows2)
    assert_eq(rop, "inserted", "Request first upsert should insert")
    assert_eq(len(req_rows2), 1, "Request rows after insert")

    # --- 4) Duplicate OPEN request with same payload must dedupe ---
    row2 = make_row_from_payload(p, requester="system", memo="追記メモ", recovery_rq_key=rq_key, request_status="OPEN")
    req_rows = load_req(str(REQ_CSV))
    req_rows3, rop2 = upsert_open_dedupe_by_request_key(req_rows, row2, append_memo=True)
    save_req(str(REQ_CSV), req_rows3)
    assert_eq(rop2, "deduped", "Request second upsert should dedupe")
    assert_eq(len(req_rows3), 1, "Request must not duplicate OPEN by requestKey")

    # --- 5) Closing Recovery item requires evidence (resolvedAt) ---
    try:
        bad_close = item.to_row()
        bad_close["status"] = "RESOLVED"
        bad_close["resolvedAt"] = ""
        rows = load_rq(str(RQ_CSV))
        upsert_rq(rows, bad_close, append_details=False)
        raise AssertionError("Expected failure when closing without resolvedAt")
    except ValueError:
        pass

    # --- 6) Valid close with resolvedAt ---
    good_close = item.to_row()
    good_close["status"] = "RESOLVED"
    good_close["resolvedAt"] = "2026-01-05T10:40:00Z"
    good_close["resolvedBy"] = "manager"
    good_close["resolutionNote"] = "UF07で価格確定済み"
    rows = load_rq(str(RQ_CSV))
    rows4, op4 = upsert_rq(rows, good_close, append_details=False)
    save_rq(str(RQ_CSV), rows4)
    assert_eq(len(rows4), 1, "RQ close must not duplicate")
    assert_eq(op4, "updated", "RQ close is update")

    # --- 7) ResyncKey must require requestedId ---
    try:
        make_resync_key(order_id, "Order", "BLOCKER解消後再投影", "")
        raise AssertionError("Expected failure when requestedId missing for resyncKey")
    except ValueError:
        pass

    result = {
        "ok": True,
        "paths": {
            "recovery_queue_csv": str(RQ_CSV),
            "request_csv": str(REQ_CSV),
        }
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
