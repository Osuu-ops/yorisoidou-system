#!/usr/bin/env python3
"""Shared lane resolution logic for MEP workflows/scripts."""

from __future__ import annotations

from typing import Iterable, List

VALID_LANES = ("SYSTEM", "BUSINESS")


class LaneResolutionError(ValueError):
    """Raised when lane cannot be resolved deterministically."""


def _normalize_lane(value: str) -> str:
    lane = (value or "").strip().upper()
    if not lane:
        return ""
    if lane not in VALID_LANES:
        raise LaneResolutionError(f"invalid requested lane: {value!r}")
    return lane


def _label_names(labels: Iterable[object]) -> List[str]:
    names: List[str] = []
    for item in labels or []:
        if isinstance(item, dict):
            names.append(str(item.get("name", "")).strip())
        elif isinstance(item, str):
            names.append(item.strip())
    return [x for x in names if x]


def resolve_lane(labels: Iterable[object], requested_lane: str = "") -> str:
    req = _normalize_lane(requested_lane)
    names = _label_names(labels)
    has_biz = "mep-biz" in names
    has_system = "mep-system" in names

    if has_biz and has_system:
        raise LaneResolutionError("both mep-biz and mep-system labels are present")

    derived = ""
    if has_biz:
        derived = "BUSINESS"
    elif has_system:
        derived = "SYSTEM"

    if req:
        if derived and req != derived:
            raise LaneResolutionError(
                f"requested lane {req} conflicts with labels (derived={derived})"
            )
        return req

    if derived:
        return derived

    raise LaneResolutionError(
        "lane unresolved: set label mep-biz or mep-system, or pass explicit lane input"
    )
