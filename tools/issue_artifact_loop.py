#!/usr/bin/env python3
import json, os
from pathlib import Path
from datetime import datetime, timezone
def utc_z():
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00","Z")
def norm(s: str) -> str:
    return (s or "").replace("\r\n","\n").replace("\r","\n")
def lane_from_labels(labels) -> str:
    names = [x.get("name","") for x in (labels or []) if isinstance(x, dict)]
    return "BUSINESS" if "mep-biz" in names else "SYSTEM"
def main():
    event_path = os.environ.get("GITHUB_EVENT_PATH","")
    if not event_path:
        raise SystemExit("GITHUB_EVENT_PATH missing")
    ev = json.loads(Path(event_path).read_text(encoding="utf-8"))
    issue = ev.get("issue") or {}
    num = int(issue.get("number"))
    title = (issue.get("title") or "").strip()
    body  = norm(issue.get("body") or "")
    labels = issue.get("labels") or []
    lane = lane_from_labels(labels)
    outdir = Path("docs")/"MEP"/"ARTIFACTS"/lane/f"ISSUE_{num}"
    outdir.mkdir(parents=True, exist_ok=True)
    # AUDIT
    audit = []
    audit.append("# AUDIT")
    audit.append(f"ISSUE: #{num}")
    audit.append(f"LANE: {lane}")
    audit.append(f"TITLE: {title}")
    audit.append(f"TIMESTAMP_UTC: {utc_z()}")
    audit.append("")
    audit.append("## Checks (minimal)")
    audit.append("- Non-empty body: " + ("OK" if body.strip() else "NG"))
    audit.append("- Size (chars): " + str(len(body)))
    audit.append("- Label mep-loop required: OK (workflow gating)")
    audit.append("- Lane selection: mep-biz => BUSINESS else SYSTEM")
    (outdir/"AUDIT.md").write_text("\n".join(audit).rstrip()+"\n", encoding="utf-8")
    # MERGED_DRAFT (single-body snapshot)
    merged = []
    merged.append("# MERGED_DRAFT")
    merged.append(f"ISSUE: #{num}")
    merged.append(f"LANE: {lane}")
    merged.append(f"TIMESTAMP_UTC: {utc_z()}")
    merged.append("")
    merged.append(body.rstrip())
    (outdir/"MERGED_DRAFT.md").write_text("\n".join(merged).rstrip()+"\n", encoding="utf-8")
        import hashlib
    merged_path = outdir/"MERGED_DRAFT.md"
    merged_bytes = merged_path.read_bytes()
    sha256 = hashlib.sha256(merged_bytes).hexdigest()
    packet = []
    packet.append("PACKET_VERSION: v1")
    packet.append(f"LANE: {lane}")
    packet.append(f"ISSUE_NUMBER: {num}")
    packet.append(f"ISSUE_URL: {issue.get('html_url','')}")
    packet.append(f"RUN_URL: {run_url}")
    packet.append("SAFE_MODE: STANDALONE_PRE_8GATE")
    packet.append("DOES_NOT_TRIGGER_8GATE: true")
    packet.append(f"MERGED_DRAFT_SHA256: {sha256}")
    packet.append("")
    packet.append("## Payload")
    packet.append(body.rstrip())
    (outdir/"INPUT_PACKET.md").write_text("\n".join(packet).rstrip()+"\n", encoding="utf-8")    # RUN_SUMMARY
    run_url = os.environ.get("GITHUB_RUN_URL","")
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
    (outdir/"RUN_SUMMARY.md").write_text("\n".join(summary).rstrip()+"\n", encoding="utf-8")
    # RESTART_PACKET
    rp = []
    rp.append("RESTART_PACKET")
    rp.append(f"ISSUE={num}")
    rp.append(f"LANE={lane}")
    rp.append(f"TIMESTAMP_UTC={utc_z()}")
    rp.append(f"ARTIFACT_DIR=docs/MEP/ARTIFACTS/{lane}/ISSUE_{num}/")
    rp.append("NEXT=OPTIONAL: feed INPUT_PACKET.md into 8-gate entry (separate workflow)")
    (outdir/"RESTART_PACKET.txt").write_text("\n".join(rp).rstrip()+"\n", encoding="utf-8")
if __name__ == "__main__":
    main()

