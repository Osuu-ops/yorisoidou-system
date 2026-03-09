#!/usr/bin/env python3
import hashlib
import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path

from mep_lane import LaneResolutionError, resolve_lane


def utc_z() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def norm(s: str) -> str:
    return (s or "").replace("\r\n", "\n").replace("\r", "\n")


def extract_draft(body: str) -> str:
    """
    Prefer '## DRAFT' section in Issue BODY.
    If missing, use full body.
    Also strips leading fenced yaml block if present.
    """
    b = norm(body)
    # strip leading fenced yaml if present
    b2 = b
    m = re.match(r"(?s)^\s*```yaml.*?```\s*\n?", b2)
    if m:
        b2 = b2[m.end():]
    # find ## DRAFT
    mm = re.search(r"(?im)^\s*##\s*DRAFT\s*$", b2)
    if not mm:
        return b2.strip()
    # everything after the heading line
    after = b2[mm.end():]
    return after.strip()


def read_existing_flag(pkt_path: Path, key: str) -> str:
    try:
        t = pkt_path.read_text(encoding="utf-8")
    except Exception:
        return ""
    for ln in t.splitlines():
        if ln.strip().startswith(key + ":"):
            return ln.split(":", 1)[1].strip()
    return ""


def main() -> int:
    event_path = os.environ.get("GITHUB_EVENT_PATH", "") or ""
    if not event_path:
        raise SystemExit("GITHUB_EVENT_PATH missing")
    ev = json.loads(Path(event_path).read_text(encoding="utf-8"))
    issue = ev.get("issue") or {}
    num = issue.get("number")
    if num is None:
        env_n = os.environ.get("ISSUE_NUMBER") or os.environ.get("INPUT_ISSUE_NUMBER")
        if env_n and str(env_n).strip().isdigit():
            num = int(env_n)
    if num is None:
        raise SystemExit("issue.number missing")
    num = int(num)
    title = (issue.get("title") or "").strip()
    labels = issue.get("labels") or []

    requested_lane = os.environ.get("MEP_REQUESTED_LANE", "")
    try:
        lane = resolve_lane(labels, requested_lane=requested_lane)
    except LaneResolutionError as exc:
        raise SystemExit(f"STOP_HARD: {exc}")

    repo = os.environ.get("GH_REPO", "") or os.environ.get("GITHUB_REPOSITORY", "")
    issue_url = issue.get("html_url", "") or (("https://github.com/" + repo + "/issues/" + str(num)) if repo else "")
    run_url = os.environ.get("GITHUB_RUN_URL", "") or ""
    body_raw = issue.get("body") or ""
    draft = extract_draft(body_raw)
    outdir = Path("docs") / "MEP" / "ARTIFACTS" / lane / f"ISSUE_{num}"
    outdir.mkdir(parents=True, exist_ok=True)

    # AUDIT.md (audit the DRAFT extracted from issue body)
    audit = []
    audit.append("# AUDIT")
    audit.append(f"ISSUE: #{num}")
    audit.append(f"LANE: {lane}")
    audit.append(f"TITLE: {title}")
    audit.append(f"TIMESTAMP_UTC: {utc_z()}")
    audit.append("")
    audit.append("## Checks (minimal)")
    audit.append("- Non-empty body: " + ("OK" if draft.strip() else "NG"))
    audit.append("- Size (chars): " + str(len(draft)))
    audit.append("- Lane selection: strict (mep-biz/mep-system or explicit lane)")
    (outdir / "AUDIT.md").write_text("\n".join(audit).rstrip() + "\n", encoding="utf-8")

    # MERGED_DRAFT.md (single draft body)
    merged = []
    merged.append("# MERGED_DRAFT")
    merged.append(f"ISSUE: #{num}")
    merged.append(f"LANE: {lane}")
    merged.append(f"TIMESTAMP_UTC: {utc_z()}")
    merged.append("")
    merged.append(draft.rstrip())
    merged_path = outdir / "MERGED_DRAFT.md"
    merged_path.write_text("\n".join(merged).rstrip() + "\n", encoding="utf-8")
    sha256 = hashlib.sha256(merged_path.read_bytes()).hexdigest()

    # Preserve DOES_NOT_TRIGGER_8GATE from existing packet if present; default false
    pkt_path = outdir / "INPUT_PACKET.md"
    prev = read_existing_flag(pkt_path, "DOES_NOT_TRIGGER_8GATE").lower()
    does_not_trigger_val = "false"
    if prev in ("true", "false"):
        does_not_trigger_val = prev

    # INPUT_PACKET.md
    packet = []
    packet.append("PACKET_VERSION: v1")
    packet.append(f"LANE: {lane}")
    packet.append(f"ISSUE_NUMBER: {num}")
    packet.append(f"ISSUE_URL: {issue_url}")
    packet.append(f"RUN_URL: {run_url}")
    packet.append("SAFE_MODE: STANDALONE_PRE_8GATE")
    packet.append("DOES_NOT_TRIGGER_8GATE: " + does_not_trigger_val)
    packet.append(f"MERGED_DRAFT_SHA256: {sha256}")
    packet.append("")
    packet.append("## Payload")
    packet.append(draft.rstrip())
    (outdir / "INPUT_PACKET.md").write_text("\n".join(packet).rstrip() + "\n", encoding="utf-8")

    # RUN_SUMMARY.md
    summary = []
    summary.append("# RUN_SUMMARY")
    summary.append(f"ISSUE: #{num}")
    summary.append(f"LANE: {lane}")
    summary.append(f"TIMESTAMP_UTC: {utc_z()}")
    summary.append(f"RUN_URL: {run_url}")
    summary.append("")
    summary.append("Generated files:")
    summary.append("- AUDIT.md")
    summary.append("- MERGED_DRAFT.md")
    summary.append("- INPUT_PACKET.md")
    summary.append("- RUN_SUMMARY.md")
    summary.append("- RESTART_PACKET.txt")
    (outdir / "RUN_SUMMARY.md").write_text("\n".join(summary).rstrip() + "\n", encoding="utf-8")

    # RESTART_PACKET.txt
    rp = []
    rp.append("RESTART_PACKET")
    rp.append(f"ISSUE={num}")
    rp.append(f"LANE={lane}")
    rp.append(f"TIMESTAMP_UTC={utc_z()}")
    rp.append(f"ARTIFACT_DIR=docs/MEP/ARTIFACTS/{lane}/ISSUE_{num}/")
    rp.append("NEXT=OPTIONAL: feed INPUT_PACKET.md into 8-gate entry (separate workflow)")
    (outdir / "RESTART_PACKET.txt").write_text("\n".join(rp).rstrip() + "\n", encoding="utf-8")

    print("OK: artifacts written to", str(outdir))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
