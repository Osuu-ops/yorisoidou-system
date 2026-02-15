#!/usr/bin/env python3
import argparse
import hashlib
import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
try:
    import yaml  # type: ignore
except Exception:
    print("STOP_HARD: PYTHON_DEP_MISSING (pyyaml)", file=sys.stderr)
    raise
REPO_ROOT = Path(__file__).resolve().parents[2]
MEP_DIR = REPO_ROOT / "mep"
DOCS_MEP = REPO_ROOT / "docs" / "MEP"
BOOT_SPEC = MEP_DIR / "boot_spec.yaml"
POLICY = MEP_DIR / "policy.yaml"
RUN_STATE = MEP_DIR / "run_state.json"
STATUS_MD = DOCS_MEP / "STATUS.md"
HANDOFF_AUDIT_MD = DOCS_MEP / "HANDOFF_AUDIT.md"
HANDOFF_WORK_MD = DOCS_MEP / "HANDOFF_WORK.md"
def utc_now_z() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
def ensure_parent(p: Path) -> None:
    p.parent.mkdir(parents=True, exist_ok=True)
def load_yaml(p: Path) -> dict:
    with p.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}
def load_json(p: Path) -> dict:
    with p.open("r", encoding="utf-8") as f:
        return json.load(f)
def write_json(p: Path, obj: dict) -> None:
    ensure_parent(p)
    tmp = p.with_suffix(p.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write("\n")
    tmp.replace(p)
def write_md(p: Path, text: str) -> None:
    ensure_parent(p)
    p.write_text(text.rstrip() + "\n", encoding="utf-8")
def default_run_state() -> dict:
    now = utc_now_z()
    return {
        "run_id": "",
        "run_status": "STILL_OPEN",
        "next_action": "BOOT",
        "last_result": {
            "stop_class": "",
            "reason_code": "",
            "next_action": "BOOT",
            "timestamp_utc": now,
            "action": {"name": "BOOT", "outcome": "OK"},
            "evidence": {
                "branch_name": None,
                "pr_url": None,
                "commit_sha": None,
                "workflow_run_url": None,
            },
            "options": [],
            "delete_candidates_sample": [],
        },
        "history": [],
        "updated_at": now,
        "handoff": None,
        "handoff_ack": None,
    }
def update_compiled(rs: dict) -> None:
    run_id = rs.get("run_id") or "NONE"
    run_status = rs.get("run_status", "")
    lr = rs.get("last_result", {}) or {}
    stop_class = lr.get("stop_class", "")
    reason_code = lr.get("reason_code", "")
    next_action = rs.get("next_action", "")
    ts = rs.get("updated_at", "")
    ev = (lr.get("evidence", {}) or {})
    branch_name = ev.get("branch_name") or ""
    pr_url = ev.get("pr_url") or ""
    commit_sha = ev.get("commit_sha") or ""
    wf_url = ev.get("workflow_run_url") or ""
    write_md(
        STATUS_MD,
        f"""# STATUS
RUN_ID: {run_id}
RUN_STATUS: {run_status}
STOP_CLASS: {stop_class}
REASON_CODE: {reason_code}
NEXT_ACTION: {next_action}
TIMESTAMP_UTC: {ts}
EVIDENCE:
- branch_name: {branch_name}
- pr_url: {pr_url}
- commit_sha: {commit_sha}
""",
    )
    write_md(
        HANDOFF_AUDIT_MD,
        f"""# HANDOFF_AUDIT
SSOT_PATHS:
- mep/boot_spec.yaml
- mep/policy.yaml
- mep/run_state.json
LATEST_EVIDENCE_POINTERS:
- pr_url: {pr_url}
- commit_sha: {commit_sha}
- workflow_run_url: {wf_url}
""",
    )
    lines = []
    lines.append("# HANDOFF_WORK")
    lines.append(f"NEXT_ACTION: {next_action}")
    lines.append(f"REASON_CODE: {reason_code}")
    lines.append(f"STOP_CLASS: {stop_class}")
    opts = lr.get("options") or []
    if isinstance(opts, list) and opts:
        lines.append("")
        lines.append("OPTIONS:")
        for o in opts:
            if isinstance(o, dict):
                lines.append(f"- {o.get('id','')}: {o.get('label','')} -> {o.get('action','')}")
    cands = lr.get("delete_candidates_sample") or []
    if isinstance(cands, list) and cands:
        lines.append("")
        lines.append("DELETE_CANDIDATES_SAMPLE:")
        for x in cands[:10]:
            lines.append(f"- {x}")
    write_md(HANDOFF_WORK_MD, "\n".join(lines))
def _run(cmd: list[str]) -> str:
    p = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")
    if p.returncode != 0:
        raise RuntimeError(p.stderr.strip() or "command failed")
    return p.stdout
def _sha256_hex(s: str) -> str:
    return hashlib.sha256(s.encode("utf-8")).hexdigest()
def compute_handoff_digest(head_sha: str, rs: dict) -> str:
    lr = rs.get("last_result", {}) or {}
    parts = [
        head_sha or "",
        rs.get("run_id", "") or "",
        rs.get("run_status", "") or "",
        rs.get("next_action", "") or "",
        lr.get("stop_class", "") or "",
        lr.get("reason_code", "") or "",
        rs.get("updated_at", "") or "",
    ]
    return _sha256_hex("\n".join(parts))
def compiled_min_check() -> tuple[bool, str]:
    try:
        s = STATUS_MD.read_text(encoding="utf-8")
        a = HANDOFF_AUDIT_MD.read_text(encoding="utf-8")
        w = HANDOFF_WORK_MD.read_text(encoding="utf-8")
    except Exception:
        return (False, "COMPILED_READ_FAILED")
    need_status = ["RUN_ID:", "RUN_STATUS:", "STOP_CLASS:", "REASON_CODE:", "NEXT_ACTION:", "TIMESTAMP_UTC:", "EVIDENCE:"]
    if any(x not in s for x in need_status):
        return (False, "COMPILED_TEMPLATE_INCOMPLETE_STATUS")
    need_audit = ["SSOT_PATHS:", "mep/boot_spec.yaml", "mep/policy.yaml", "mep/run_state.json", "LATEST_EVIDENCE_POINTERS:"]
    if any(x not in a for x in need_audit):
        return (False, "COMPILED_TEMPLATE_INCOMPLETE_AUDIT")
    need_work = ["NEXT_ACTION:", "REASON_CODE:", "STOP_CLASS:"]
    if any(x not in w for x in need_work):
        return (False, "COMPILED_TEMPLATE_INCOMPLETE_WORK")
    return (True, "")
def update_handoff_packet_and_ack(rs: dict) -> dict:
    head_sha = _run(["git", "rev-parse", "HEAD"]).strip()
    packet_id = "HP_" + utc_now_z().replace(":", "").replace("-", "")
    rs["handoff"] = {
        "packet_id": packet_id,
        "generated_at_utc": utc_now_z(),
        "head_sha": head_sha,
        "ssot_paths": ["mep/boot_spec.yaml", "mep/policy.yaml", "mep/run_state.json"],
        "compiled_paths": ["docs/MEP/STATUS.md", "docs/MEP/HANDOFF_AUDIT.md", "docs/MEP/HANDOFF_WORK.md"],
        "digest": compute_handoff_digest(head_sha, rs),
    }
    ok, reason = compiled_min_check()
    if ok:
        rs["handoff_ack"] = {
            "status": "ACK",
            "checked_at_utc": utc_now_z(),
            "reason_code": None,
            "packet_id": packet_id,
        }
    else:
        rs["handoff_ack"] = {
            "status": "NACK",
            "checked_at_utc": utc_now_z(),
            "reason_code": reason,
            "packet_id": packet_id,
        }
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "HANDOFF_ACK_REQUIRED"
        rs["next_action"] = "NEED_HANDOFF_ACK"
    return rs
def require_handoff_ack(rs: dict) -> tuple[bool, dict]:
    ha = rs.get("handoff_ack") or {}
    if ha.get("status") == "ACK":
        return (True, rs)
    rs["last_result"]["stop_class"] = "WAIT"
    rs["last_result"]["reason_code"] = "HANDOFF_ACK_REQUIRED"
    rs["next_action"] = "NEED_HANDOFF_ACK"
    return (False, rs)
def _after_compiled(rs: dict) -> dict:
    # ensure compiled exists, then create packet+ack and persist
    rs = update_handoff_packet_and_ack(rs)
    write_json(RUN_STATE, rs)
    update_compiled(rs)
    return rs
def boot() -> int:
    if not BOOT_SPEC.exists():
        ensure_parent(BOOT_SPEC)
        BOOT_SPEC.write_text("# mep/boot_spec.yaml (AUTO GENERATED)\n", encoding="utf-8")
    if not POLICY.exists():
        ensure_parent(POLICY)
        POLICY.write_text("# mep/policy.yaml (AUTO GENERATED)\npaths_allow: []\npaths_deny: []\n", encoding="utf-8")
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "BOOT", "outcome": "OK"}
    rs["next_action"] = "STATUS"
    write_json(RUN_STATE, rs)
    update_compiled(rs)
    rs = _after_compiled(rs)
    print(json.dumps({"run_id": rs.get("run_id", ""), "run_status": rs.get("run_status", ""), "next_action": rs.get("next_action", "")}, ensure_ascii=False))
    return 0
def status() -> int:
    if not RUN_STATE.exists():
        return boot()
    rs = load_json(RUN_STATE)
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "STATUS", "outcome": "OK"}
    rs["next_action"] = "STATUS"
    write_json(RUN_STATE, rs)
    update_compiled(rs)
    rs = _after_compiled(rs)
    print(json.dumps({"run_id": rs.get("run_id", ""), "run_status": rs.get("run_status", ""), "next_action": rs.get("next_action", "")}, ensure_ascii=False))
    return 0
def apply(draft_file: Path) -> int:
    if not draft_file.exists():
        print("STOP_HARD: DRAFT_FILE_NOT_FOUND", file=sys.stderr)
        return 1
    text = draft_file.read_text(encoding="utf-8")
    draft_canonical = text.replace("\r\n", "\n").replace("\r", "\n").strip()
    h = hashlib.sha256(draft_canonical.encode("utf-8")).hexdigest()[:12]
    run_id = f"RUN_{h}"
    inbox = MEP_DIR / "inbox"
    ensure_parent(inbox / "x")
    (inbox / f"draft_{run_id}.md").write_text(text, encoding="utf-8")
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    rs["run_id"] = run_id
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "APPLY", "outcome": "OK"}
    rs["last_result"]["stop_class"] = ""
    rs["last_result"]["reason_code"] = ""
    rs["next_action"] = "STATUS"
    write_json(RUN_STATE, rs)
    update_compiled(rs)
    rs = _after_compiled(rs)
    print(json.dumps({"run_id": run_id, "next_action": rs.get("next_action", "")}, ensure_ascii=False))
    return 0
def pr_probe(run_id: str) -> int:
    branch = f"mep/run_{run_id}"
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    rs["run_id"] = run_id
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "PR_PROBE", "outcome": "OK"}
    rs["next_action"] = "STATUS"
    repo = os.environ.get("GH_REPO", "")
    if not repo:
        rs["last_result"]["stop_class"] = "HARD"
        rs["last_result"]["reason_code"] = "REPO_NOT_SET"
        rs["next_action"] = "SET_GH_REPO"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 1
    try:
        open_json = _run(["gh", "pr", "list", "--repo", repo, "--head", branch, "--state", "all", "--json", "number,url", "-q", "."])
        closed_json = _run(["gh", "pr", "list", "--repo", repo, "--head", branch, "--state", "closed", "--json", "number,url", "-q", "."])
        open_prs = json.loads(open_json) if open_json.strip() else []
        closed_prs = json.loads(closed_json) if closed_json.strip() else []
    except Exception:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "EVIDENCE_REQUIRED_BUT_UNAVAILABLE"
        rs["next_action"] = "PROVIDE_EVIDENCE_OR_ABORT"
        rs["last_result"]["evidence"] = {"branch_name": branch}
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 2
    ev = rs["last_result"].get("evidence", {}) or {}
    ev["branch_name"] = branch
    if len(open_prs) == 1:
        ev["pr_url"] = open_prs[0].get("url")
        rs["last_result"]["evidence"] = ev
        rs["last_result"]["stop_class"] = ""
        rs["last_result"]["reason_code"] = ""
        rs["next_action"] = "STATUS"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 0
    if len(open_prs) == 0 and len(closed_prs) >= 1:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "PR_CLOSED_FOR_RUN"
        rs["next_action"] = "OPEN_NEW_PR_FOR_RUN"
        rs["last_result"]["evidence"] = ev
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 2
    if len(open_prs) == 0 and len(closed_prs) == 0:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "PR_NOT_FOUND_FOR_RUN"
        rs["next_action"] = "CREATE_PR_FOR_RUN"
        rs["last_result"]["evidence"] = ev
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 2
    rs["last_result"]["stop_class"] = "HARD"
    rs["last_result"]["reason_code"] = "MULTIPLE_PR_FOR_ONE_RUN"
    rs["next_action"] = "MANUAL_RESOLUTION_REQUIRED"
    rs["last_result"]["evidence"] = ev
    write_json(RUN_STATE, rs); update_compiled(rs)
    return 1
def pr_create(run_id: str) -> int:
    branch = f"mep/run_{run_id}"
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    rs["run_id"] = run_id
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "PR_CREATE", "outcome": "OK"}
    rs["next_action"] = "STATUS"
    repo = os.environ.get("GH_REPO", "")
    if not repo:
        rs["last_result"]["stop_class"] = "HARD"
        rs["last_result"]["reason_code"] = "REPO_NOT_SET"
        rs["next_action"] = "SET_GH_REPO"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 1
    try:
        _run(["git", "rev-parse", "--verify", branch])
    except Exception:
        _run(["git","checkout","-B",branch])
        _run(["git", "push", "-u", "origin", branch])
    else:
        try:
            _run(["git", "ls-remote", "--exit-code", "--heads", "origin", branch])
        except Exception:
            _run(["git", "push", "-u", "origin", branch])
    open_json = _run(["gh", "pr", "list", "--repo", repo, "--head", branch, "--state", "all", "--json", "number,url", "-q", "."])
    open_prs = json.loads(open_json) if open_json.strip() else []
    if len(open_prs) > 1:
        rs["last_result"]["stop_class"] = "HARD"
        rs["last_result"]["reason_code"] = "MULTIPLE_PR_FOR_ONE_RUN"
        rs["next_action"] = "MANUAL_RESOLUTION_REQUIRED"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 1
    if len(open_prs) == 1:
        pr_url = open_prs[0].get("url")
        rs["last_result"]["evidence"] = {"branch_name": branch, "pr_url": pr_url}
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 0
    title = f"MEP RUN {run_id}"
    body = f"Runner created PR for RUN_ID={run_id}"
    pr_url = _run(["gh", "pr", "create", "--repo", repo, "--head", branch, "--base", "main", "--title", title, "--body", body]).strip()
    rs["last_result"]["evidence"] = {"branch_name": branch, "pr_url": pr_url}
    write_json(RUN_STATE, rs); update_compiled(rs)
    return 0
def assemble_pr(run_id: str) -> int:
    results_dir = MEP_DIR / "results" / run_id
    patches = sorted(results_dir.glob("*.patch")) if results_dir.exists() else []
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    rs["run_id"] = run_id
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "ASSEMBLE_PR", "outcome": "OK"}
    if not patches:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "NO_PATCH_RESULTS"
        rs["next_action"] = "WAIT_FOR_WORKER_RESULTS"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 2
    pol = load_yaml(POLICY) if POLICY.exists() else {}
    limits = (pol.get("limits") or {})
    max_bytes = int(limits.get("patch_max_bytes", 0) or 0)
    max_lines = int(limits.get("patch_max_lines", 0) or 0)
    if max_bytes <= 0 or max_lines <= 0:
        rs["last_result"]["stop_class"] = "HARD"
        rs["last_result"]["reason_code"] = "POLICY_SCHEMA_INVALID"
        rs["next_action"] = "FIX_POLICY_SCHEMA"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 1
    total_bytes = 0
    total_lines = 0
    deny = ["GIT binary patch", "Binary files ", "deleted file mode", "rename from", "rename to", "old mode", "new mode"]
    for p in patches:
        txt = p.read_text(encoding="utf-8", errors="replace")
        total_bytes += len(txt.encode("utf-8", errors="replace"))
        total_lines += txt.count("\n") + 1
        for pat in deny:
            if pat in txt:
                rs["last_result"]["stop_class"] = "HARD"
                rs["last_result"]["reason_code"] = "DANGEROUS_DIFF_FORBIDDEN"
                rs["next_action"] = "SPLIT_PATCH_OR_REDUCE_SCOPE"
                write_json(RUN_STATE, rs); update_compiled(rs)
                return 1
    if total_bytes > max_bytes or total_lines > max_lines:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "PATCH_TOO_LARGE"
        rs["next_action"] = "SPLIT_PATCH_OR_REDUCE_SCOPE"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 2
    rs["last_result"]["stop_class"] = ""
    rs["last_result"]["reason_code"] = ""
    rs["next_action"] = "READY_TO_APPLY_SAFE_PATH"
    write_json(RUN_STATE, rs); update_compiled(rs)
    return 0
def apply_safe(run_id: str) -> int:
    rs_guard = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    ok, rs_guard = require_handoff_ack(rs_guard)
    if not ok:
        write_json(RUN_STATE, rs_guard); update_compiled(rs_guard)
        return 2
    branch = f"mep/run_{run_id}"
    results_dir = MEP_DIR / "results" / run_id
    patches = sorted(results_dir.glob("*.patch")) if results_dir.exists() else []
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    rs["run_id"] = run_id
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "APPLY_SAFE", "outcome": "OK"}
    if not patches:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "NO_PATCH_RESULTS"
        rs["next_action"] = "WAIT_FOR_WORKER_RESULTS"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 2
    repo = os.environ.get("GH_REPO", "")
    if not repo:
        rs["last_result"]["stop_class"] = "HARD"
        rs["last_result"]["reason_code"] = "REPO_NOT_SET"
        rs["next_action"] = "SET_GH_REPO"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 1
        # APPLY_SAFE_BASE_ORIGIN_MAIN
        _run(["git","fetch","origin","main"])
        # APPLY_SAFE_BASE_ORIGIN_MAIN
        _run(["git","fetch","origin","main"])
        _run(["git","checkout","-f","-B",branch,"origin/main"])
        _run(["git","push","-u","origin",branch,"--force-with-lease"])
    for p in patches:
        _run(["git", "apply", "--check", str(p)])
    for p in patches:
        _run(["git", "apply", str(p)])
    _run(["git", "add", "-A"])
    _run(["git", "commit", "-m", f"mep: apply patches for {run_id}"])
    _run(["git","push","origin",branch,"--force-with-lease"])
    open_json = _run(["gh", "pr", "list", "--repo", repo, "--head", branch, "--state", "all", "--json", "number,url", "-q", "."])
    open_prs = json.loads(open_json) if open_json.strip() else []
    if len(open_prs) > 1:
        rs["last_result"]["stop_class"] = "HARD"
        rs["last_result"]["reason_code"] = "MULTIPLE_PR_FOR_ONE_RUN"
        rs["next_action"] = "MANUAL_RESOLUTION_REQUIRED"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 1
    if len(open_prs) == 1:
        pr_url = open_prs[0].get("url")
    else:
        title = f"MEP RUN {run_id} (apply)"
        body = f"Runner applied patches and updated branch for RUN_ID={run_id}"
        pr_url = _run(["gh", "pr", "create", "--repo", repo, "--head", branch, "--base", "main", "--title", title, "--body", body]).strip()
    sha = _run(["git", "rev-parse", "HEAD"]).strip()
    rs["last_result"]["evidence"] = {"branch_name": branch, "pr_url": pr_url, "commit_sha": sha}
    rs["last_result"]["stop_class"] = ""
    rs["last_result"]["reason_code"] = ""
    rs["next_action"] = "STATUS"
    write_json(RUN_STATE, rs); update_compiled(rs)
    return 0
def merge_finish(run_id: str) -> int:
    rs_guard = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    ok, rs_guard = require_handoff_ack(rs_guard)
    if not ok:
        write_json(RUN_STATE, rs_guard); update_compiled(rs_guard)
        return 2
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    rs["run_id"] = run_id
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "MERGE_FINISH", "outcome": "OK"}
    repo = os.environ.get("GH_REPO", "")
    ev = rs.get("last_result", {}).get("evidence", {}) or {}
    pr_url = ev.get("pr_url") or ""
    if not repo or not pr_url:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "EVIDENCE_REQUIRED_BUT_UNAVAILABLE"
        rs["next_action"] = "PROVIDE_EVIDENCE_OR_ABORT"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 2
    pr_num = int(pr_url.rstrip("/").split("/")[-1])
    for _ in range(360):
        out = _run(["gh", "pr", "checks", str(pr_num), "--repo", repo])
        if "0 pending checks" in out and "0 failing" in out:
            break
        time.sleep(5)
    else:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "CHECKS_TIMEOUT"
        rs["next_action"] = "WAIT_FOR_CHECKS"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 2
    _run(["gh", "pr", "merge", str(pr_num), "--repo", repo, "--auto", "--squash"])
    for _ in range(360):
        j = _run(["gh", "pr", "view", str(pr_num), "--repo", repo, "--json", "state", "-q", "{state:.state}"])
        if '"state":"MERGED"' in j:
            break
        time.sleep(5)
    else:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "MERGE_TIMEOUT"
        rs["next_action"] = "WAIT_FOR_MERGE"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 2
    rs["run_status"] = "DONE"
    rs["last_result"]["stop_class"] = ""
    rs["last_result"]["reason_code"] = ""
    rs["next_action"] = "ALL_DONE"
    write_json(RUN_STATE, rs); update_compiled(rs)
    return 0
def compact() -> int:
    rs_guard = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    ok, rs_guard = require_handoff_ack(rs_guard)
    if not ok:
        write_json(RUN_STATE, rs_guard); update_compiled(rs_guard)
        return 2
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "COMPACTION", "outcome": "OK"}
    pol = load_yaml(POLICY) if POLICY.exists() else {}
    retention = (pol.get("retention") or {})
    keep_runs = int(retention.get("keep_runs", 20) or 20)
    history_k = int(retention.get("history_k", 10) or 10)
    pinned_runs = retention.get("pinned_runs", []) or []
    pinned_max = int(retention.get("pinned_max", 50) or 50)
    allow_delete = bool(retention.get("allow_delete", False))
    hist = rs.get("history") or []
    if not isinstance(hist, list):
        hist = []
    lr = rs.get("last_result") or {}
    ev = lr.get("evidence") or {}
    hist.append({
        "run_id": rs.get("run_id", "") or "",
        "result_state": rs.get("run_status", "") or "",
        "stop_class": lr.get("stop_class", "") or "",
        "reason_code": lr.get("reason_code", "") or "",
        "evidence": {
            "pr_url": ev.get("pr_url"),
            "commit_sha": ev.get("commit_sha"),
            "workflow_run_url": ev.get("workflow_run_url"),
            "branch_name": ev.get("branch_name"),
        },
        "timestamp_utc": lr.get("timestamp_utc") or rs.get("updated_at") or utc_now_z(),
    })
    if len(hist) > history_k:
        hist = hist[-history_k:]
    rs["history"] = hist
    if len(pinned_runs) > pinned_max:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "PINNED_OVERFLOW"
        rs["next_action"] = "RESOLVE_PINNED_OVERFLOW"
        rs["last_result"]["options"] = [
            {"id": "A", "label": "Reduce retention.pinned_runs in mep/policy.yaml", "action": "EDIT_POLICY"},
            {"id": "B", "label": "Increase retention.pinned_max in mep/policy.yaml", "action": "EDIT_POLICY"},
        ]
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 2
    work_items = (MEP_DIR / "work_items")
    results = (MEP_DIR / "results")
    def _scan_dir(d: Path) -> set[str]:
        out = set()
        if not d.exists():
            return out
        for p in d.iterdir():
            if p.is_dir() and p.name.startswith("RUN_"):
                out.add(p.name)
        return out
    run_ids = set()
    run_ids |= _scan_dir(work_items)
    run_ids |= _scan_dir(results)
    current = rs.get("run_id", "") or ""
    protected = set([current]) | set(pinned_runs)
    def _ts(x: dict) -> str:
        return str(x.get("timestamp_utc", "") or "")
    seen = set()
    ordered = []
    for h in sorted(hist, key=_ts):
        rid = h.get("run_id", "") or ""
        if not rid or rid in seen:
            continue
        seen.add(rid)
        if rid in run_ids and rid not in protected:
            ordered.append(rid)
    tail = sorted([r for r in run_ids if r not in protected and r not in ordered])
    ordered += tail
    if len(run_ids) > keep_runs:
        overflow = len(run_ids) - keep_runs
        to_delete = ordered[:overflow]
        rs["last_result"]["delete_candidates_sample"] = to_delete[:10]
        if not allow_delete:
            rs["last_result"]["stop_class"] = "WAIT"
            rs["last_result"]["reason_code"] = "RETENTION_ACTION_REQUIRED"
            rs["next_action"] = "SET_retention.allow_delete_true_OR_REDUCE_KEEP_RUNS"
            rs["last_result"]["options"] = [
                {"id": "A", "label": "Set retention.allow_delete: true (delete results/work_items only)", "action": "EDIT_POLICY"},
                {"id": "B", "label": "Increase retention.keep_runs to avoid deletion", "action": "EDIT_POLICY"},
            ]
            write_json(RUN_STATE, rs); update_compiled(rs)
            return 2
        for rid in to_delete:
            for d in (results / rid, work_items / rid):
                if d.exists() and d.is_dir():
                    for child in d.rglob("*"):
                        if child.is_file():
                            child.unlink()
                    for child in sorted([x for x in d.rglob("*") if x.is_dir()], key=lambda x: len(str(x)), reverse=True):
                        try:
                            child.rmdir()
                        except Exception:
                            pass
                    try:
                        d.rmdir()
                    except Exception:
                        pass
        rs["last_result"]["stop_class"] = ""
        rs["last_result"]["reason_code"] = ""
        rs["next_action"] = "STATUS"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 0
    rs["last_result"]["stop_class"] = ""
    rs["last_result"]["reason_code"] = ""
    rs["next_action"] = "STATUS"
    write_json(RUN_STATE, rs); update_compiled(rs)
    return 0
def main() -> int:
    ap = argparse.ArgumentParser(prog="runner.py")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("boot")
    sub.add_parser("status")
    ap_apply = sub.add_parser("apply")
    ap_apply.add_argument("--draft-file", required=True)
    ap_probe = sub.add_parser("pr-probe")
    ap_probe.add_argument("--run-id", required=True)
    ap_create = sub.add_parser("pr-create")
    ap_create.add_argument("--run-id", required=True)
    ap_asm = sub.add_parser("assemble-pr")
    ap_asm.add_argument("--run-id", required=True)
    ap_safe = sub.add_parser("apply-safe")
    ap_safe.add_argument("--run-id", required=True)
    ap_finish = sub.add_parser("merge-finish")
    ap_finish.add_argument("--run-id", required=True)
    sub.add_parser("compact")
    args = ap.parse_args()
    if args.cmd == "boot":
        return boot()
    if args.cmd == "status":
        return status()
    if args.cmd == "apply":
        return apply(Path(args.draft_file))
    if args.cmd == "pr-probe":
        return pr_probe(args.run_id)
    if args.cmd == "pr-create":
        return pr_create(args.run_id)
    if args.cmd == "assemble-pr":
        return assemble_pr(args.run_id)
    if args.cmd == "apply-safe":
        return apply_safe(args.run_id)
    if args.cmd == "merge-finish":
        return merge_finish(args.run_id)
    if args.cmd == "compact":
        return compact()
    return 1
if __name__ == "__main__":
    sys.exit(main())

# mep: ci-retrigger 2026-02-15T11:16:08Z

