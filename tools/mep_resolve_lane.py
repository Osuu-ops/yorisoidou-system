#!/usr/bin/env python3
"""Resolve lane from issue JSON + optional explicit lane input."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from mep_lane import LaneResolutionError, resolve_lane


def _stop(msg: str) -> int:
    print(f"STOP_HARD: {msg}", file=sys.stderr)
    return 1


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--issue-json-path", required=True, help="Path to issue JSON")
    ap.add_argument(
        "--requested-lane",
        default="",
        help="Optional explicit lane (SYSTEM|BUSINESS)",
    )
    args = ap.parse_args()

    p = Path(args.issue_json_path)
    if not p.exists():
        return _stop(f"issue json not found: {p}")

    try:
        issue = json.loads(p.read_text(encoding="utf-8"))
    except Exception as exc:
        return _stop(f"issue json parse error: {exc}")

    labels = issue.get("labels") or []
    try:
        lane = resolve_lane(labels, requested_lane=args.requested_lane)
    except LaneResolutionError as exc:
        return _stop(str(exc))

    print(lane)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
