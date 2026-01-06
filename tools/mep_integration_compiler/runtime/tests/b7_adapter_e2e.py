# -*- coding: utf-8 -*-
from __future__ import annotations

import json
from pathlib import Path

from tools.mep_integration_compiler.runtime.adapters.csv_adapter import CsvLedgerAdapter
from tools.mep_integration_compiler.runtime.idempotency import make_recovery_queue_key, make_resync_key
from tools.mep_integration_compiler.runtime.recovery_queue import RecoveryItem, RecoveryCategory, RecoveryStatus
from tools.mep_integration_compiler.runtime.ledger_recovery_queue import load_rows_csv as load_rq
from tools.mep_integration_compiler.runtime.ledger_request import load_rows_csv as load_req, make_row_from_payload
from tools.mep_integration_compiler.runtime.request_linkage import suggest_requests_for_recovery
from tools.mep_integration_compiler.runtime.ledger_adapter import EvidenceRequired


ROOT = Path(".mep/tmp/b7_adapter_e2e")
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

    adapter = CsvLedgerAdapter(recovery_queue_csv=str(RQ_CSV), request_csv=str(REQ_CSV))

    order_id = "ORDER-20260105-00001-UP-AA001-0001"
    part_id = "BP-202601-AA01-PA01"

    # 1) Recovery upsert (OPEN)
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
    r1 = adapter.upsert_recovery(item.to_row())
    assert_eq(r1.op, "inserted", "Recovery first upsert op")
    assert_eq(len(load_rq(str(RQ_CSV))), 1, "Recovery rows after insert")

    # 2) Recovery re-observation (same rqKey => update, no duplication)
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
    r2 = adapter.upsert_recovery(item2.to_row())
    assert_eq(r2.op, "updated", "Recovery second upsert op")
    assert_eq(len(load_rq(str(RQ_CSV))), 1, "Recovery must not duplicate")

    # 3) Request linkage suggestion (PRICE未確定 -> UF07)
    payloads = suggest_requests_for_recovery("PRICE未確定", order_id, part_id, memo="価格確定入力を依頼")
    assert_eq(len(payloads), 1, "UF07 suggestion count")
    p = payloads[0]

    req_row = make_row_from_payload(
        p,
        requester="system",
        memo="auto",
        recovery_rq_key=rq_key,
        request_status="OPEN",
    )
    q1 = adapter.upsert_request_open_dedupe(req_row)
    assert_eq(q1.op, "inserted", "Request first upsert op")
    assert_eq(len(load_req(str(REQ_CSV))), 1, "Request rows after insert")

    # 4) Request duplicate OPEN (same payload => dedupe)
    req_row2 = make_row_from_payload(
        p,
        requester="system",
        memo="追記メモ",
        recovery_rq_key=rq_key,
        request_status="OPEN",
    )
    q2 = adapter.upsert_request_open_dedupe(req_row2)
    assert_eq(q2.op, "deduped", "Request dedupe op")
    assert_eq(len(load_req(str(REQ_CSV))), 1, "Request must not duplicate OPEN")

    # 5) Recovery close evidence required
    try:
        adapter.close_recovery(rq_key, "RESOLVED", "", "manager", "nope")
        raise AssertionError("Expected EvidenceRequired when resolved_at missing")
    except EvidenceRequired:
        pass

    # 6) Recovery close OK
    c1 = adapter.close_recovery(rq_key, "RESOLVED", "2026-01-05T10:40:00Z", "manager", "UF07で価格確定済み")
    assert_eq(c1.op, "updated", "Recovery close op")
    assert_eq(len(load_rq(str(RQ_CSV))), 1, "Recovery close must not duplicate")

    # 7) ResyncKey requires requestedId
    try:
        make_resync_key(order_id, "Order", "BLOCKER解消後再投影", "")
        raise AssertionError("Expected failure when requestedId missing")
    except ValueError:
        pass

    print(json.dumps(
        {
            "ok": True,
            "paths": {
                "recovery_queue_csv": str(RQ_CSV),
                "request_csv": str(REQ_CSV),
            }
        },
        ensure_ascii=False,
        indent=2
    ))


if __name__ == "__main__":
    main()
