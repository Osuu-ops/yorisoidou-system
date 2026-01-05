# -*- coding: utf-8 -*-
from __future__ import annotations

from typing import Dict, Any, List, Optional

# This module implements the Phase-2 "Request linkage" guidance as code:
# - PRICE未確定(BP) -> Request.Category=UF07 (targetType=PART_ID)
# - LOCATION不整合 / 抽出不備 / 写真不足 / 監督判断 -> Request.Category=REVIEW (targetType=Order_ID)
# It does NOT write to ledger; it only suggests payloads.

def _req_common(payload_version: str, category: str, target_type: str, target_id: str) -> Dict[str, Any]:
    return {
        "payloadVersion": payload_version,
        "category": category,
        "targetType": target_type,
        "targetId": target_id,
    }


def suggest_requests_for_recovery(
    reason: str,
    order_id: str,
    part_id: Optional[str] = None,
    memo: Optional[str] = None,
) -> List[Dict[str, Any]]:
    """
    Returns a list of Request payload JSON dicts (Category-specific) to be recorded with RequestStatus=OPEN.
    The caller must enforce:
      - do not create duplicates if an OPEN Request already exists (idempotent)
      - do not auto-RESOLVE without evidence
    """
    if not reason or not order_id:
        raise ValueError("reason and order_id are required")

    r = reason.strip()
    out: List[Dict[str, Any]] = []

    # PRICE missing (BP) => UF07
    if r in ("PRICE未確定", "ALERT_PRICE_MISSING", "PRICE_MISSING"):
        if not part_id:
            # If we can't identify PART_ID, we cannot create UF07 safely -> suggest REVIEW
            payload = _req_common("1.0", "REVIEW", "Order_ID", order_id)
            payload.update({
                "reviewType": "MISSING_INFO",
                "requestSummary": "PRICE未確定（PART_ID特定不可のためREVIEWへ回収）",
                "memo": memo or "",
                "rootCauseKind": "ALERT_LABEL",
                "rootCauseValues": ["ALERT_PRICE_MISSING"],
            })
            out.append(payload)
            return out

        payload = _req_common("1.0", "UF07", "PART_ID", part_id)
        payload.update({
            "partId": part_id,
            # price is intentionally absent here (it must be confirmed input, not guessed)
            "memo": memo or "PRICE確定入力が必要（推測代入禁止）",
        })
        out.append(payload)
        return out

    # Location / extraction / photo / generic supervisor judgement => REVIEW
    payload = _req_common("1.0", "REVIEW", "Order_ID", order_id)

    if r in ("LOCATION不整合", "LOCATION_MISMATCH"):
        payload.update({
            "reviewType": "INCONSISTENCY",
            "requestSummary": "LOCATION不整合（在庫戻し/整合の監督回収）",
            "memo": memo or "",
        })
        out.append(payload)
        return out

    if r in ("抽出不備", "EXTRACTION_ERROR"):
        payload.update({
            "reviewType": "INCONSISTENCY",
            "requestSummary": "完了コメント抽出不備（未使用部材/書式の回収）",
            "memo": memo or "",
        })
        out.append(payload)
        return out

    if r in ("写真不足", "PHOTO_INSUFFICIENT", "ALERT_PHOTO_INSUFFICIENT"):
        payload.update({
            "reviewType": "MISSING_INFO",
            "requestSummary": "写真不足（追補回収）",
            "memo": memo or "",
            "rootCauseKind": "PHOTO_FLAG",
            "rootCauseValues": ["PHOTO_INSUFFICIENT"],
        })
        out.append(payload)
        return out

    # Default: REVIEW as a safe sink
    payload.update({
        "reviewType": "HEALTH_CHECK",
        "requestSummary": f"Recovery Queue 回収: {r}",
        "memo": memo or "",
    })
    out.append(payload)
    return out
