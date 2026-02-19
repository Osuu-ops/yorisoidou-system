import re
#!/usr/bin/env python3
import json, os, hashlib
from pathlib import Path
from datetime import datetime, timezone

def _read_existing_flag(pkt_path: Path, key: str) -> str:
    try:
        t = pkt_path.read_text(encoding="utf-8")
    except Exception:
        return ""
    for ln in t.splitlines():
        if ln.strip().startswith(key + ":"):
            return ln.split(":", 1)[1].strip()
    return ""

def _read_text(p: str) -> str:
    try:
        return pathlib.Path(p).read_text(encoding="utf-8")
    except Exception:
        return ""
def audit_body_from_artifacts(lane: str, issue_number: int) -> str:
    base = pathlib.Path("docs")/"MEP"/"ARTIFACTS"/lane/(f"ISSUE_{issue_number}")
    t = _read_text(str(base/"MERGED_DRAFT.md")).strip()
    return t


def _read_text(path: str) -> str:
    try:
        return pathlib.Path(path).read_text(encoding="utf-8")
    except Exception:
        return ""
def pick_audit_body(issue_body: str, artifacts_dir: str) -> str:
    # Prefer artifacts MERGED_DRAFT.md (0->8 truth) over Issue body (can be empty)
    if artifacts_dir:
        md = str(pathlib.Path(artifacts_dir) / "MERGED_DRAFT.md")
        t = _read_text(md).strip()
        if t:
            return t
    return (issue_body or "")

import urllib.request
def _api_get_json(url: str, token: str):
    req = urllib.request.Request(url, headers={
        "Accept": "application/vnd.github+json",
        "Authorization": f"token {token}",
        "User-Agent": "mep-standalone-autoloop"
    })
    with urllib.request.urlopen(req, timeout=20) as r:
        return json.loads(r.read().decode("utf-8"))
def pick_body_with_fallback(body: str, repo: str, num: int, token: str) -> str:
    b = (body or "").strip()
    if b:
        return body
    if not (repo and token):
        return body or ""
    try:
        url = f"https://api.github.com/repos/{repo}/issues/{num}/comments?per_page=100"
        comments = _api_get_json(url, token)
        # choose last meaningful comment
        for c in reversed(comments or []):
            t = (c.get("body") or "").strip()
            if not t:
                continue
            # ignore control / bot style comments
            if t.startswith("/mep"):
                continue
            if t.startswith("[MEP]") or t.startswith("[MEP]["):
                continue
            return t
    except Exception:
        return body or ""
    return body or ""
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
    raw_num = issue.get("number")
    if raw_num is None:
        env_n = os.environ.get("ISSUE_NUMBER") or os.environ.get("INPUT_ISSUE_NUMBER")
        if env_n and str(env_n).strip().isdigit():
            raw_num = int(env_n)
        else:
            url = issue.get("html_url","") or ""
            m = re.search(r"/issues/(\d+)", url)
            if m:
                raw_num = int(m.group(1))
    if raw_num is None:
        raise SystemExit("issue.number missing (cannot proceed). keys=" + ",".join(sorted(issue.keys())))
    num = int(raw_num)
    title = (issue.get("title") or "").strip()
    body  = norm(pick_body_with_fallback(issue.get("body") or "", os.environ.get("GH_REPO","") or os.environ.get("GITHUB_REPOSITORY",""), int(num), os.environ.get("GH_TOKEN","")))
    labels = issue.get("labels") or []
    lane = lane_from_labels(labels)
    run_url = os.environ.get("GITHUB_RUN_URL","")
    # issue_url fallback (avoid f-string with escaped quotes; keep it syntax-safe)
    _repo = os.environ.get("GH_REPO","") or os.environ.get("GITHUB_REPOSITORY","")
    issue_url = issue.get("html_url","") or (("https://github.com/" + _repo + "/issues/" + str(num)) if _repo else "")
    outdir = Path("docs")/"MEP"/"ARTIFACTS"/lane/f"ISSUE_{num}"
    outdir.mkdir(parents=True, exist_ok=True)
    # AUDIT.md
    audit = []
    audit.append("# AUDIT")
    audit.append(f"ISSUE: #{num}")
    audit.append(f"LANE: {lane}")
    audit.append(f"TITLE: {title}")
    audit.append(f"TIMESTAMP_UTC: {utc_z()}")
    audit.append("")
    audit.append("## Checks (minimal)")
    audit_body = pick_audit_body(issue.get("body") if isinstance(issue, dict) else "", locals().get("artifacts_dir", ""))
    # audit source: prefer artifacts MERGED_DRAFT.md (0->8 truth)
    try:
        _lane = lane
    except Exception:
        _lane = os.environ.get('LANE','SYSTEM') if 'os' in globals() else 'SYSTEM'
    try:
        _num = int(issue_number)
    except Exception:
        _num = int(os.environ.get('ISSUE_NUMBER','0')) if 'os' in globals() else 0
    audit_body = audit_body_from_artifacts(_lane, _num)
    non_empty = bool(audit_body.strip())
    size_chars = len(audit_body)
    audit.append("- Non-empty body: " + ("OK" if audit_body.strip() else "NG"))
    audit.append("- Size (chars): " + str(len(audit_body)))
    audit.append("- Lane selection: mep-biz => BUSINESS else SYSTEM")
    (outdir/"AUDIT.md").write_text("\n".join(audit).rstrip()+"\n", encoding="utf-8")
    # MERGED_DRAFT.md
    merged = []
    merged.append("# MERGED_DRAFT")
    merged.append(f"ISSUE: #{num}")
    merged.append(f"LANE: {lane}")
    merged.append(f"TIMESTAMP_UTC: {utc_z()}")
    merged.append("")
    merged.append(body.rstrip())
    merged_path = outdir/"MERGED_DRAFT.md"
    merged_path.write_text("\n".join(merged).rstrip()+"\n", encoding="utf-8")
    # READ_BYTES_GUARD__AUTOINSERT
    try:
        _mb = merged_path.read_bytes()
    except FileNotFoundError:
        _mb = b""
    sha256 = hashlib.sha256(_mb).hexdigest()

    # Preserve DOES_NOT_TRIGGER_8GATE from existing packet if present; default false
    pkt_path = dir_path / "INPUT_PACKET.md"
    prev = _read_existing_flag(pkt_path, "DOES_NOT_TRIGGER_8GATE").lower()
    does_not_trigger_val = "false"
    if prev in ("true","false"):
        does_not_trigger_val = prev
    # INPUT_PACKET.md
    packet = []
    packet.append("PACKET_VERSION: v1")
    packet.append(f"LANE: {lane}")
    packet.append(f"ISSUE_NUMBER: {num}")
    packet.append(f"ISSUE_URL: {issue_url}")
    packet.append(f"RUN_URL: {run_url}")
    packet.append("SAFE_MODE: STANDALONE_PRE_8GATE")
    packet.append("DOES_NOT_TRIGGER_8GATE: " + does_not_trigger_val + "")
    packet.append(f"MERGED_DRAFT_SHA256: {sha256}")
    packet.append("")
    packet.append("## Payload")
    packet.append(body.rstrip())
    (outdir/"INPUT_PACKET.md").write_text("\n".join(packet).rstrip()+"\n", encoding="utf-8")
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
    (outdir/"RUN_SUMMARY.md").write_text("\n".join(summary).rstrip()+"\n", encoding="utf-8")
    # RESTART_PACKET.txt
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

