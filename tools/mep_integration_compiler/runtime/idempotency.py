# -*- coding: utf-8 -*-
from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Optional

# NOTE: This module is pure/side-effect free.
# It exists to make Phase-2 contract executable in code:
# - IdempotencyKey (eventType + primaryId + eventAt + optional sourceId)
# - ResyncKey uses requestedId (NOT requestedAt) to avoid re-send duplication
# - RecoveryQueue key is deterministic and stable (no timestamps unless explicitly part of identity)


_ISO_Z_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z$")


def _sha256_hex(s: str) -> str:
    return hashlib.sha256(s.encode("utf-8")).hexdigest()


def normalize_event_at_iso(event_at: str) -> str:
    """
    Normalize an event timestamp to ISO-8601 Zulu form:
      YYYY-MM-DDTHH:MM:SSZ
    Accepts:
      - already Z form
      - naive ISO (assumed local/UTC is not inferred; we normalize conservatively)
      - datetime parseable strings
    If parsing fails, returns the original string (caller may treat as invalid and recover via Recovery Queue).
    """
    if not event_at:
        return event_at
    s = event_at.strip()
    if _ISO_Z_RE.match(s):
        return s
    try:
        # Try parse common ISO formats
        dt = datetime.fromisoformat(s.replace("Z", "+00:00"))
        if dt.tzinfo is None:
            # If tz missing, treat as UTC to avoid local ambiguity in keying
            dt = dt.replace(tzinfo=timezone.utc)
        dt = dt.astimezone(timezone.utc).replace(microsecond=0)
        return dt.strftime("%Y-%m-%dT%H:%M:%SZ")
    except Exception:
        return s


def make_idempotency_key(
    event_type: str,
    primary_id: str,
    event_at: str,
    source_id: Optional[str] = None,
) -> str:
    """
    Phase-2 contract:
      idempotencyKey = Hash(eventType + primaryId + eventAt + sourceId?)
    - eventAt should be a stable "event confirmed at" time.
    - sourceId is optional; include when available.
    """
    if not event_type or not primary_id or not event_at:
        raise ValueError("event_type, primary_id, event_at are required")

    event_at_n = normalize_event_at_iso(event_at)
    parts = [event_type.strip(), primary_id.strip(), event_at_n.strip()]
    if source_id:
        parts.append(source_id.strip())

    raw = "|".join(parts)
    return _sha256_hex(raw)


def make_resync_key(
    order_id: str,
    target: str,
    reason: str,
    requested_id: str,
) -> str:
    """
    Phase-2 contract (as fixed in PR #513):
      resyncKey = Hash(Order_ID + target + reason + requestedId)
    requestedId is REQUIRED to prevent "requestedAt-only" duplication.
    """
    if not order_id or not target or not reason or not requested_id:
        raise ValueError("order_id, target, reason, requested_id are required (requested_id is mandatory)")

    raw = "|".join([order_id.strip(), target.strip(), reason.strip(), requested_id.strip()])
    return _sha256_hex(raw)


def make_recovery_queue_key(
    order_id: str,
    category: str,
    reason: str,
    detected_by: str,
    part_id: Optional[str] = None,
) -> str:
    """
    Phase-2 contract:
      rqKey = Hash(Order_ID + category + reason + detectedBy + (PART_ID?))
    This intentionally excludes detectedAt to keep the identity stable across retries.
    """
    if not order_id or not category or not reason or not detected_by:
        raise ValueError("order_id, category, reason, detected_by are required")

    parts = [order_id.strip(), category.strip(), reason.strip(), detected_by.strip()]
    if part_id:
        parts.append(part_id.strip())
    raw = "|".join(parts)
    return _sha256_hex(raw)
