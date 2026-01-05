# -*- coding: utf-8 -*-
from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Optional, Dict, Any


class RecoveryCategory(str, Enum):
    BLOCKER = "BLOCKER"
    WARNING = "WARNING"


class RecoveryStatus(str, Enum):
    OPEN = "OPEN"
    RESOLVED = "RESOLVED"
    CANCELLED = "CANCELLED"  # Phase-2 fix: allow cancellation without deleting history


@dataclass(frozen=True)
class RecoveryItem:
    """
    Minimal Recovery Queue record model (Phase-2 contract).
    Ledger is the authority; this object is a pure representation.

    IMPORTANT:
    - status transitions must be "rooted in evidence"
    - UI/tool must not set RESOLVED/CANCELLED by guess
    """
    rq_key: str
    order_id: str
    category: RecoveryCategory
    reason: str
    detected_by: str
    detected_at: Optional[str] = None
    part_id: Optional[str] = None
    details: Optional[str] = None

    status: RecoveryStatus = RecoveryStatus.OPEN
    resolved_at: Optional[str] = None
    resolved_by: Optional[str] = None
    resolution_note: Optional[str] = None

    def to_row(self) -> Dict[str, Any]:
        return {
            "rqKey": self.rq_key,
            "orderId": self.order_id,
            "category": self.category.value,
            "reason": self.reason,
            "detectedBy": self.detected_by,
            "detectedAt": self.detected_at,
            "partId": self.part_id,
            "details": self.details,
            "status": self.status.value,
            "resolvedAt": self.resolved_at,
            "resolvedBy": self.resolved_by,
            "resolutionNote": self.resolution_note,
        }
