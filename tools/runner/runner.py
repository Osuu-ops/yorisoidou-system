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
import re
import secrets

THIS_DIR = Path(__file__).resolve().parent
if str(THIS_DIR) not in sys.path:
    sys.path.insert(0, str(THIS_DIR))

from live_state import update_live_state
from progress_journal import append_journal_event, new_event_id


def _resolve_portfolio_id_for_ledger(portfolio_id: str, allow_unselected: bool, rs: dict) -> str:
    """
    Auto-resolve portfolio_id to avoid UNSELECTED collisions.
    Priority:
      1) explicit non-UNSELECTED
      2) last_result.evidence.pr_url -> PR_<n>
      3) restart_bridge.source_issue_number -> ISSUE_<n>
      4) COORD_MAIN
    UNSELECTED is forbidden unless allow_unselected=True.
    """
    pid = (portfolio_id or "").strip()
    if pid and pid != "UNSELECTED":
        return pid
    ev = ((rs or {}).get("last_result") or {}).get("evidence") or {}
    pr_url = str(ev.get("pr_url") or "").strip()
    m = re.search(r"/pull/(?P<n>\d+)\b", pr_url)
    if m:
        return f"PR_{m.group('n')}"
    rb = (rs or {}).get("restart_bridge") or {}
    issue = str(rb.get("source_issue_number") or "").strip()
    if issue.isdigit():
        return f"ISSUE_{issue}"
    # fallback (valid + stable)
    if allow_unselected:
        return "UNSELECTED"
    return "COORD_MAIN"



def _warn_if_ledger_dirty(ledger_path: str) -> None:
    """
    Safety guard: if CHAT_CHAIN_LEDGER.md was appended but not committed,
    warn loudly so operator knows it will NOT be recoverable elsewhere unless merged via PR.
    """
    import subprocess, sys
    try:
        r = subprocess.run(
            ["git", "status", "--porcelain", "--", ledger_path],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, encoding="utf-8", errors="replace", check=False
        )
        if r.stdout.strip():
            repo_root = None
            try:
                rr = subprocess.run(['git','rev-parse','--show-toplevel'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, encoding="utf-8", errors="replace", check=False)
                if rr.stdout.strip():
                    repo_root = rr.stdout.strip()
            except Exception:
                repo_root = None
            sys.stderr.write(
                f"[WARN] CHAT_CHAIN_LEDGER is dirty: {ledger_path}\n"
                f"       This boot/ledger update will NOT be recoverable elsewhere unless you PR+merge it.\n"
            )
    except Exception:
        return

try:
    import yaml  # type: ignore
except Exception:
    print("STOP_HARD: PYTHON_DEP_MISSING (pyyaml)", file=sys.stderr)
    raise
REPO_ROOT = Path(__file__).resolve().parents[2]
MEP_DIR = REPO_ROOT / "mep"
DOCS_MEP = REPO_ROOT / "docs" / "MEP"
LIVE_STATE_JSON = DOCS_MEP / "LIVE_STATE.json"
PROGRESS_JOURNAL_JSONL = DOCS_MEP / "PROGRESS_JOURNAL.jsonl"
ARCHIVE_CATALOG_JSONL = DOCS_MEP / "ARCHIVE" / "CATALOG.jsonl"
CLAIMS_JSONL = DOCS_MEP / "CLAIMS" / "CLAIMS.jsonl"
CLAIMS_OPEN_INDEX_JSON = DOCS_MEP / "CLAIMS" / "OPEN_INDEX.json"
BOOT_SPEC = MEP_DIR / "boot_spec.yaml"
POLICY = MEP_DIR / "policy.yaml"
RUN_STATE = MEP_DIR / "run_state.json"
STATUS_MD = DOCS_MEP / "STATUS.md"
HANDOFF_AUDIT_MD = DOCS_MEP / "HANDOFF_AUDIT.md"
HANDOFF_WORK_MD = DOCS_MEP / "HANDOFF_WORK.md"


def _evidence_from_rs(rs: dict, note: str = "") -> dict:
    ev = ((rs or {}).get("last_result") or {}).get("evidence") or {}
    return {
        "pr_url": ev.get("pr_url") or "",
        "workflow_run_url": ev.get("workflow_run_url") or "",
        "commit_sha": ev.get("commit_sha") or "",
        "note": note,
    }


def checkpoint_live_state(
    *,
    run_id: str,
    portfolio_id: str,
    mode: str,
    primary_anchor: str,
    phase: str,
    next_item: str,
    stop_kind: str,
    reason_code: str,
    evidence: dict,
    step: str,
    result: str,
) -> None:
    payload = {
        "updated_at_utc": utc_now_z(),
        "run_id": run_id or "",
        "portfolio_id": portfolio_id or "UNSELECTED",
        "mode": mode or "",
        "primary_anchor": primary_anchor or "",
        "current_phase": phase or "",
        "next_item": next_item or "",
        "stop_kind": stop_kind or "",
        "reason_code": reason_code or "",
        "evidence": evidence or {},
    }
    update_live_state(LIVE_STATE_JSON, payload)
    append_journal_event(
        PROGRESS_JOURNAL_JSONL,
        {
            "ts_utc": utc_now_z(),
            "event_id": new_event_id(),
            "run_id": run_id or "",
            "portfolio_id": portfolio_id or "UNSELECTED",
            "mode": mode or "",
            "primary_anchor": primary_anchor or "",
            "phase": phase or "",
            "step": step,
            "result": result,
            "reason_code": reason_code or "",
            "evidence": evidence or {},
        },
    )


def _resolve_run_id_fallback(run_id: str) -> str:
    rid = (run_id or "").strip()
    if rid:
        return rid
    try:
        import json
        rs = Path("mep/run_state.json")
        if rs.exists():
            obj = json.loads(rs.read_text(encoding="utf-8"))
            rid2 = str(obj.get("run_id","") or "").strip()
            if rid2:
                return rid2
    except Exception:
        pass
    return "RUN_UNSET"
def _heartbeat_entry(cmd: str, step: str, run_id: str = "", note: str = "cmd_entry") -> None:
    # WARN-only: never block runner main flow
    try:
        rid = _resolve_run_id_fallback(run_id)
        checkpoint_live_state(
            run_id=rid,
            portfolio_id="UNSELECTED",
            mode="EXEC_MODE",
            primary_anchor=f"CMD:{cmd}",
            phase=cmd,
            next_item="CMD_ENTRY",
            stop_kind="",
            reason_code="",
            evidence={"pr_url":"","workflow_run_url":"","commit_sha":git_head_sha() if "git_head_sha" in globals() else "", "note": note},
            step=step,
            result="OK",
        )
    except Exception as ex:
        print(f"WARN: HEARTBEAT_WRITE_FAILED ({ex})", file=sys.stderr)
def _gate_checkpoint_start(gate_name: str, run_id: str = "") -> None:
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    checkpoint_live_state(
        run_id=run_id or (rs.get("run_id") or ""),
        portfolio_id="UNSELECTED",
        mode="EXEC_MODE",
        primary_anchor="",
        phase=gate_name,
        next_item="RUN_GATE",
        stop_kind="",
        reason_code="",
        evidence=_evidence_from_rs(rs, note=f"{gate_name} started"),
        step="GATE_START",
        result="OK",
    )


def _gate_checkpoint_end(gate_name: str, run_id: str, exit_code: int) -> None:
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    lr = rs.get("last_result") or {}
    stop_kind = lr.get("stop_class") or ""
    reason = lr.get("reason_code") or ""
    step = "STOP" if stop_kind else "GATE_END"
    result = "STOP" if stop_kind else ("OK" if exit_code == 0 else "NG")
    checkpoint_live_state(
        run_id=run_id or (rs.get("run_id") or ""),
        portfolio_id="UNSELECTED",
        mode="EXEC_MODE",
        primary_anchor="",
        phase=gate_name,
        next_item=rs.get("next_action") or "",
        stop_kind=stop_kind,
        reason_code=reason,
        evidence=_evidence_from_rs(rs, note=f"{gate_name} finished"),
        step=step,
        result=result,
    )




def _ensure_irreversible_after(gate_name: str, run_id: str, result: str) -> None:
    if gate_name not in {"apply-safe", "merge-finish"}:
        return
    after_step = "APPLY_AFTER" if gate_name == "apply-safe" else "MERGE_AFTER"
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    stop_kind = ((rs.get("last_result") or {}).get("stop_class") or "")
    reason_code = ((rs.get("last_result") or {}).get("reason_code") or "")
    checkpoint_live_state(
        run_id=run_id or (rs.get("run_id") or ""),
        portfolio_id="UNSELECTED",
        mode="EXEC_MODE",
        primary_anchor="",
        phase=gate_name,
        next_item=rs.get("next_action") or "",
        stop_kind=stop_kind,
        reason_code=reason_code,
        evidence=_evidence_from_rs(rs, note=f"{after_step} auto checkpoint"),
        step=after_step,
        result=result,
    )
def _run_gate(gate_name: str, fn, run_id: str = "") -> int:
    _gate_checkpoint_start(gate_name, run_id)
    try:
        code = fn()
    except Exception:
        _ensure_irreversible_after(gate_name, run_id, "NG")
        _gate_checkpoint_end(gate_name, run_id, 1)
        raise
    _ensure_irreversible_after(gate_name, run_id, "OK" if code == 0 else "STOP")
    _gate_checkpoint_end(gate_name, run_id, code)
    return code
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

def _get_repo(rs: dict) -> str:
    # Prefer explicit env, then persisted state, then GitHub default env.
    repo = (os.environ.get("GH_REPO") or "").strip()
    if repo:
        return repo
    if isinstance(rs, dict):
        repo2 = (rs.get("gh_repo") or rs.get("repo") or "").strip()
        if repo2:
            return repo2
    repo3 = (os.environ.get("GITHUB_REPOSITORY") or "").strip()
    return repo3

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
    # Clear stale STOP(HARD)/REPO_NOT_SET if repo is now resolvable
    repo = ""
    try:
        repo = _get_repo(rs)
    except Exception:
        repo = ""
    if (rs.get("last_result") or {}).get("reason_code") == "REPO_NOT_SET" and repo:
        rs.setdefault("gh_repo", repo)
        rs.setdefault("repo", repo)
        rs["last_result"]["stop_class"] = ""
        rs["last_result"]["reason_code"] = ""
    write_json(RUN_STATE, rs)
    update_compiled(rs)
    rs = _after_compiled(rs)
    _heartbeat_entry("status", "HEARTBEAT_STATUS", rs.get("run_id",""), "status")

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
    # Clear stale STOP(HARD)/REPO_NOT_SET if repo is now resolvable
    repo = ""
    try:
        repo = _get_repo(rs)
    except Exception:
        repo = ""
    if (rs.get("last_result") or {}).get("reason_code") == "REPO_NOT_SET" and repo:
        rs.setdefault("gh_repo", repo)
        rs.setdefault("repo", repo)
        rs["last_result"]["stop_class"] = ""
        rs["last_result"]["reason_code"] = ""
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
    # Clear stale STOP(HARD)/REPO_NOT_SET if repo is now resolvable
    repo = ""
    try:
        repo = _get_repo(rs)
    except Exception:
        repo = ""
    if (rs.get("last_result") or {}).get("reason_code") == "REPO_NOT_SET" and repo:
        rs.setdefault("gh_repo", repo)
        rs.setdefault("repo", repo)
        rs["last_result"]["stop_class"] = ""
        rs["last_result"]["reason_code"] = ""
    repo = _get_repo(rs)
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
    # Clear stale STOP(HARD)/REPO_NOT_SET if repo is now resolvable
    repo = ""
    try:
        repo = _get_repo(rs)
    except Exception:
        repo = ""
    if (rs.get("last_result") or {}).get("reason_code") == "REPO_NOT_SET" and repo:
        rs.setdefault("gh_repo", repo)
        rs.setdefault("repo", repo)
        rs["last_result"]["stop_class"] = ""
        rs["last_result"]["reason_code"] = ""
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

    # EVIDENCE_FOLLOW_A2
    # Detect stale PR headRefOid vs branch tip and auto-replace PR.
    repo = _get_repo(rs)
    if repo and open_prs:
        try:
            pr_url = open_prs[0].get("url")
            pr_number = open_prs[0].get("number")
            head_ref = branch
            # read PR headRefOid
            pr_head = json.loads(_run(["gh","pr","view",str(pr_number),"--repo",repo,"--json","headRefOid","-q","."]))["headRefOid"]
            # read branch tip from refs
            ref_json = json.loads(_run(["gh","api","-H","Accept: application/vnd.github+json",f"/repos/{repo}/git/matching-refs/heads/{head_ref}"]))
            ref_sha = ref_json[0]["object"]["sha"] if ref_json else ""
            if pr_head and ref_sha and pr_head != ref_sha:
                # create replacement branch from ref_sha
                new_branch = f"{head_ref}_replace"
                _run(["git","fetch","origin"])
                _run(["git","checkout","-B",new_branch,ref_sha])
                _run(["git","push","-u","origin",new_branch,"--force-with-lease"])
                new_pr = _run(["gh","pr","create","--repo",repo,"--head",new_branch,"--base","main","--title",f"REPLACE PR #{pr_number}: stale headRefOid","--body","Auto-replace due to stale headRefOid"])
                rs["last_result"]["evidence"]["pr_url"] = new_pr.strip()
        except Exception:
            pass
def pr_create(run_id: str) -> int:
    branch = f"mep/run_{run_id}"
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    rs["run_id"] = run_id
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "PR_CREATE", "outcome": "OK"}
    rs["next_action"] = "STATUS"
    # Clear stale STOP(HARD)/REPO_NOT_SET if repo is now resolvable
    repo = ""
    try:
        repo = _get_repo(rs)
    except Exception:
        repo = ""
    if (rs.get("last_result") or {}).get("reason_code") == "REPO_NOT_SET" and repo:
        rs.setdefault("gh_repo", repo)
        rs.setdefault("repo", repo)
        rs["last_result"]["stop_class"] = ""
        rs["last_result"]["reason_code"] = ""
    repo = _get_repo(rs)
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
    rs["next_action"] = "STATUS"

    # Clear stale STOP(HARD)/REPO_NOT_SET if repo is now resolvable
    repo = ""
    try:
        repo = _get_repo(rs)
    except Exception:
        repo = ""
    if (rs.get("last_result") or {}).get("reason_code") == "REPO_NOT_SET" and repo:
        rs.setdefault("gh_repo", repo)
        rs.setdefault("repo", repo)
        rs["last_result"]["stop_class"] = ""
        rs["last_result"]["reason_code"] = ""
    # PATCH_TYPE_SCAN_A1: stop early with reason_code instead of failing later.
    # - NEW file patch targeting an existing path => HARD (NEW_FILE_TARGET_EXISTS)
    # - UPDATE patch targeting a missing path => HARD (UPDATE_TARGET_MISSING)
    created_paths = set()

    def _cat_exists(rev: str, p: str) -> bool:
        try:
            _run(["git", "cat-file", "-e", f"{rev}:{p}"])
            return True
        except Exception:
            return False

    def _scan_patch_paths(txt: str):
        out = []
        cur = None
        kind = None
        for line in txt.splitlines():
            if line.startswith("diff --git "):
                if cur and kind:
                    out.append((cur, kind))
                parts = line.split()
                if len(parts) >= 4:
                    b = parts[3][2:] if parts[3].startswith("b/") else parts[3]
                    cur = b
                    kind = None
            elif line.startswith("new file mode") or line.startswith("--- /dev/null"):
                if cur:
                    kind = "NEW"
            elif line.startswith("--- a/") and cur and kind is None:
                kind = "UPD"
        if cur and kind:
            out.append((cur, kind))
        return out

    # evaluate patches against origin/main
    for p in patches:
        txt = p.read_text(encoding="utf-8", errors="replace")
        for (tpath, tkind) in _scan_patch_paths(txt):
            exists_in_base = _cat_exists("origin/main", tpath)
            exists_effective = exists_in_base or (tpath in created_paths)
            if tkind == "NEW":
                if exists_effective:
                    # ASSEMBLE_PR_A2_ALLOW_NEWFILE_EXISTS
                    # Allow continuation: target already exists on origin/main.
                    # apply-safe will normalize/skip/convert NEW-file patches safely.
                    continue
                created_paths.add(tpath)
            elif tkind == "UPD":
                if not exists_effective:
                    rs["last_result"]["stop_class"] = "HARD"
                    rs["last_result"]["reason_code"] = "UPDATE_TARGET_MISSING"
                    rs["next_action"] = "REGENERATE_PATCH_AS_NEWFILE_OR_FIX_PATH"
                    write_json(RUN_STATE, rs); update_compiled(rs)
                    return 1

    # NO_PATCH_RESULTS => NOOP (close deterministically)
    if not patches:
        rs["run_status"] = "DONE"
        rs["last_result"]["stop_class"] = ""
        rs["last_result"]["reason_code"] = "NOOP_NO_PATCH_RESULTS"
        rs["next_action"] = "ALL_DONE"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 0

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
        total_lines += txt.count("\\n") + 1
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
    rs_before = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    checkpoint_live_state(
        run_id=run_id,
        portfolio_id="UNSELECTED",
        mode="EXEC_MODE",
        primary_anchor="",
        phase="apply-safe",
        next_item="APPLY_PATCHES",
        stop_kind="",
        reason_code="",
        evidence=_evidence_from_rs(rs_before, note="before apply-safe irreversible operation"),
        step="APPLY_BEFORE",
        result="OK",
    )
    rs_guard = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    ok, rs_guard = require_handoff_ack(rs_guard)
    if not ok:
        write_json(RUN_STATE, rs_guard); update_compiled(rs_guard)
        return 2

    branch = f"mep/run_{run_id}"
    results_dir = MEP_DIR / "results" / run_id
    patches = sorted(results_dir.glob("*.patch")) if results_dir.exists() else []


    # APPLY_SAFE_A2_NORMALIZE_NEWFILE
    # Normalize "new file" patches whose target already exists on origin/main.
    # - If patch would create a file that already exists, compare content:
    #   - identical => skip (NOOP)
    #   - different => convert to UPDATE patch (git-applyable) and continue
    def _normalize_newfile_patch(patch_text: str):
        import difflib
        import re as _re
        is_new = ("new file mode" in patch_text) or ("\n--- /dev/null\n" in patch_text) or ("\nindex 00000000.." in patch_text)
        if not is_new:
            return patch_text
        mm = _re.search(r"^diff --git a/(.+?) b/(.+?)$", patch_text, flags=_re.M)
        if not mm:
            return patch_text
        target = mm.group(2).strip()
        if not target:
            return patch_text
        # check existence on origin/main
        try:
            _run(["git", "cat-file", "-e", f"origin/main:{target}"])
        except Exception:
            return patch_text  # truly new
        # base content
        try:
            base = _run(["git", "show", f"origin/main:{target}"])
        except Exception:
            base = ""
        # reconstruct "after" content (best-effort for new-file patch)
        after_lines = []
        in_hunk = False
        for line in patch_text.splitlines():
            if line.startswith("+++ b/"):
                in_hunk = True
                continue
            if not in_hunk:
                continue
            if line.startswith("@@"):
                continue
            if line.startswith("diff --git "):
                break
            if line.startswith("new file mode") or line.startswith("index ") or line.startswith("--- "):
                continue
            if line.startswith("\\ No newline at end of file"):
                continue
            if line == "":
                continue
            c = line[0]
            if c == "+" and not line.startswith("+++"):
                after_lines.append(line[1:])
            elif c == " ":
                after_lines.append(line[1:])
            elif c == "-":
                pass
        after = "\n".join(after_lines)
        after = after.replace("\r\n", "\n").replace("\r", "\n")
        # canonicalize: treat trailing newlines as a single \n (prevents false diffs at EOF)
        after = (after.rstrip("\n") + ("\n" if after_lines else ""))
        base_norm = base.replace("\r\n", "\n").replace("\r", "\n")
        base_norm = (base_norm.rstrip("\n") + ("\n" if base_norm else ""))
        if base_norm == after:
            return ""  # identical => skip
        # convert to UPDATE patch (git apply compatible)
        base_lines = base_norm.splitlines(keepends=False)
        after_lines2 = after.splitlines(keepends=False)
        ud = list(difflib.unified_diff(
            base_lines, after_lines2,
            fromfile=f"a/{target}",
            tofile=f"b/{target}",
            lineterm=""
        ))
        out = [f"diff --git a/{target} b/{target}"]
        out.extend(ud)
        return "\n".join(out) + "\n"
    norm = []
    for pp in patches:
        t = pp.read_text(encoding="utf-8", errors="replace")
        nt = _normalize_newfile_patch(t)
        if nt == "":
            continue  # skip NOOP
        if nt != t:
            np = pp.with_name(pp.name + ".normalized.patch")
            np.write_text(nt, encoding="utf-8")
            norm.append(np)
        else:
            norm.append(pp)
    patches = norm
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    rs["run_id"] = run_id
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "APPLY_SAFE", "outcome": "OK"}

    if not patches:
        # NOOP: no patch results -> nothing to apply; close the run deterministically.
        rs["run_status"] = "DONE"
        rs["last_result"]["stop_class"] = ""
        rs["last_result"]["reason_code"] = "NOOP_NO_PATCH_RESULTS"
        rs["next_action"] = "ALL_DONE"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 0

    repo = _get_repo(rs)
    if not repo:
        rs["last_result"]["stop_class"] = "HARD"
        rs["last_result"]["reason_code"] = "REPO_NOT_SET"
        rs["next_action"] = "SET_GH_REPO"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 1

    # Base on origin/main (idempotent)
    _run(["git", "fetch", "origin", "main"])
    _run(["git", "checkout", "-f", "-B", branch, "origin/main"])
    _run(["git", "push", "-u", "origin", branch, "--force-with-lease"])

    for p in patches:
        try:
            _run(["git", "apply", "--check", str(p)])
        except Exception as e:
            rs["last_result"]["stop_class"] = "HARD"
            rs["last_result"]["reason_code"] = "PATCH_DOES_NOT_APPLY"
            rs["next_action"] = "REGENERATE_PATCH_AS_UPDATE"
            rs["last_result"]["evidence"] = {"branch_name": branch, "failing_patch": str(p)}
            write_json(RUN_STATE, rs); update_compiled(rs)
            return 1
    for p in patches:
        _run(["git", "apply", str(p)])

    _run(["git", "add", "-A"])
    _run(["git", "commit", "-m", f"mep: apply patches for {run_id}"])
    _run(["git", "push", "origin", branch, "--force-with-lease"])

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
    rs_before = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    checkpoint_live_state(
        run_id=run_id,
        portfolio_id="UNSELECTED",
        mode="EXEC_MODE",
        primary_anchor="",
        phase="merge-finish",
        next_item="MERGE_PR",
        stop_kind="",
        reason_code="",
        evidence=_evidence_from_rs(rs_before, note="before merge-finish irreversible operation"),
        step="MERGE_BEFORE",
        result="OK",
    )
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
    repo = _get_repo(rs)
    ev = rs.get("last_result", {}).get("evidence", {}) or {}
    pr_url = ev.get("pr_url") or ""
    if not repo or not pr_url:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "EVIDENCE_REQUIRED_BUT_UNAVAILABLE"
        rs["next_action"] = "PROVIDE_EVIDENCE_OR_ABORT"
        write_json(RUN_STATE, rs); update_compiled(rs)
        return 2
    pr_num = int(pr_url.rstrip("/").split("/")[-1])
    # If PR already MERGED, finalize immediately (idempotent)
    try:
        st0 = _run(["gh","pr","view", str(pr_num), "--repo", repo, "--json", "state", "-q", ".state"]).strip()
        if st0 == "MERGED":
            rs["run_status"] = "DONE"
            rs["last_result"]["stop_class"] = ""
            rs["last_result"]["reason_code"] = ""
            rs["next_action"] = "ALL_DONE"
            write_json(RUN_STATE, rs); update_compiled(rs)
            return 0
    except Exception:
        pass

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
        j = _run(["gh", "pr", "view", str(pr_num), "--repo", repo, "--json", "state", "-q", ".state"])
        if j.strip() == "MERGED":
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

    # MERGE_FINISH_A3_AUTODONE
    # If PR already MERGED, automatically finalize run_state (no manual backfill).
    repo = _get_repo(rs)
    if repo:
        try:
            pr_url = rs.get("last_result", {}).get("evidence", {}).get("pr_url")
            if pr_url:
                pr_json = json.loads(_run(["gh","pr","view",pr_url,"--repo",repo,"--json","state,mergeCommit","-q","."]))
                if pr_json.get("state") == "MERGED":
                    merge_oid = (pr_json.get("mergeCommit") or {}).get("oid")
                    rs["last_result"]["action"] = {"name":"MERGE_FINISH","outcome":"OK"}
                    rs["last_result"]["stop_class"] = ""
                    rs["last_result"]["reason_code"] = ""
                    rs["last_result"]["timestamp_utc"] = utc_now_z()
                    rs["last_result"]["evidence"]["commit_sha"] = merge_oid
                    rs["run_status"] = "DONE"
                    rs["next_action"] = "STATUS"
                    write_json(RUN_STATE, rs); update_compiled(rs)
                    return 0
        except Exception:
            pass
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

# LEDGER_IN_OUT_V2
def _utc_now_compact() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
def _rand_hex4() -> str:
    return secrets.token_hex(2).upper()
def gen_chat_id() -> str:
    return f"CHAT_{_utc_now_compact()}_{_rand_hex4()}"
def _mep_root_dir() -> Path:
    # runner.py は tools/runner/runner.py にある前提
    return Path(__file__).resolve().parents[2]
def _ledger_path() -> Path:
    return _mep_root_dir() / "docs" / "MEP" / "CHAT_CHAIN_LEDGER.md"
def _fixed_handoff_path() -> Path:
    return _mep_root_dir() / "docs" / "MEP" / "FIXED_HANDOFF.md"
def read_fixed_handoff_version() -> str:
    p = _fixed_handoff_path()
    if not p.exists():
        return "unknown"
    txt = p.read_text(encoding="utf-8", errors="replace")
    m = re.search(r"^##\s*FIXED_HANDOFF_VERSION\s*$\s*^\s*([vV]\d+(?:\.\d+)*)", txt, flags=re.M)
    if m:
        return m.group(1)
    m2 = re.search(r"FIXED_HANDOFF_VERSION\s*[:=]\s*([vV]\d+(?:\.\d+)*)", txt)
    return m2.group(1) if m2 else "unknown"
def git_head_sha() -> str:
    try:
        return _run(["git","rev-parse","HEAD"]).strip()
    except Exception:
        return ""
def ledger_append(entry: dict) -> None:
    p = _ledger_path()
    p.parent.mkdir(parents=True, exist_ok=True)
    line = json.dumps(entry, ensure_ascii=False)
    with open(p, "a", encoding="utf-8", newline="\n") as f:
        f.write(line + "\n")
def ledger_in(parent_chat_id: str, portfolio_id: str, mode: str, primary_anchor: str, current_phase: str, next_item: str) -> int:
    this_id = gen_chat_id()
    entry = {
        "kind": "CHECKPOINT_IN",
        "this_chat_id": this_id,
        "parent_chat_id": parent_chat_id,
        "portfolio_id": portfolio_id or "UNSELECTED",
        "checked_at_utc": utc_now_z(),
        "main_head": git_head_sha(),
        "fixed_handoff_version": read_fixed_handoff_version(),
        "mode": mode or "UNSPECIFIED",
        "primary_anchor": primary_anchor or "UNSPECIFIED",
        "current_phase": current_phase or "UNSPECIFIED",
        "next_item": next_item or "UNSPECIFIED",
    }
    ledger_append(entry)
    checkpoint_live_state(
        run_id=this_id,
        portfolio_id=portfolio_id,
        mode=mode,
        primary_anchor=primary_anchor,
        phase=current_phase,
        next_item=next_item,
        stop_kind="",
        reason_code="",
        evidence={"pr_url": "", "workflow_run_url": "", "commit_sha": entry.get("main_head") or "", "note": "ledger-in completed"},
        step="ENTRY",
        result="OK",
    )
    print(json.dumps({"kind":"CHECKPOINT_IN","this_chat_id": this_id}, ensure_ascii=False))
    return 0
def ledger_out(this_chat_id: str, portfolio_id: str, mode: str, primary_anchor: str, current_phase: str, next_item: str) -> int:
    if not this_chat_id:
        this_chat_id = gen_chat_id()
    next_id = gen_chat_id()
    entry = {
        "kind": "CHECKPOINT_OUT",
        "this_chat_id": this_chat_id,
        "next_chat_id": next_id,
        "portfolio_id": portfolio_id or "UNSELECTED",
        "checked_at_utc": utc_now_z(),
        "main_head": git_head_sha(),
        "fixed_handoff_version": read_fixed_handoff_version(),
        "mode": mode or "UNSPECIFIED",
        "primary_anchor": primary_anchor or "UNSPECIFIED",
        "current_phase": current_phase or "UNSPECIFIED",
        "next_item": next_item or "UNSPECIFIED",
    }
    ledger_append(entry)
    parent_jsonl = json.dumps(entry, ensure_ascii=False)
    boot = "\n".join([
        "[MEP_BOOT]",
        f"PARENT_CHAT_ID: {next_id}",
        f"PARENT_CHECKPOINT_OUT_JSONL: {parent_jsonl}",
        "@github docs/MEP/FIXED_HANDOFF.md を読み、PARENT_CHAT_IDに一致するCHECKPOINT_OUTを docs/MEP/CHAT_CHAIN_LEDGER.md から復元して開始せよ。",
        "開始後、このチャットの THIS_CHAT_ID を生成し、CHECKPOINT_IN を台帳へ追記せよ。",
        ""
    ])
    print(json.dumps({"kind":"CHECKPOINT_OUT","this_chat_id": this_chat_id, "next_chat_id": next_id}, ensure_ascii=False))
    print(boot)
    return 0





def _append_jsonl(path: Path, obj: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    line = json.dumps(obj, ensure_ascii=False)
    with path.open("a", encoding="utf-8", newline="\n") as f:
        f.write(line + "\n")
        f.flush()


def _read_jsonl(path: Path) -> list[dict]:
    if not path.exists():
        return []
    out = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            out.append(json.loads(line))
        except Exception:
            continue
    return out


def _claim_event_id() -> str:
    return f"CLM_{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')}_{secrets.token_hex(4)}"


def claim_add(portfolio_id: str, run_id: str, mode: str, primary_anchor: str, claim_type: str, dod_ref: str, evidence_required: list[str], evidence_present: dict, note: str, session_id: str, related_archive_id: str) -> int:
    ev_required = [str(x).strip() for x in (evidence_required or []) if str(x).strip()]
    ev_present = evidence_present if isinstance(evidence_present, dict) else {}
    rec = {
        "schema_version": "v1",
        "ts_utc": utc_now_z(),
        "claim_id": _claim_event_id(),
        "portfolio_id": portfolio_id or "UNSELECTED",
        "run_id": run_id or "",
        "mode": mode or "",
        "primary_anchor": primary_anchor or "",
        "claim_status": "CLAIMED",
        "claim_type": claim_type or "DONE",
        "dod_ref": dod_ref or "",
        "evidence_required": ev_required,
        "evidence_present": ev_present,
        "note": note or "",
        "session_id": session_id or "",
        "related_archive_id": related_archive_id or "",
    }
    _append_jsonl(CLAIMS_JSONL, rec)
    print(json.dumps(rec, ensure_ascii=False))
    return 0


def _verify_evidence_key(key: str, val) -> bool:
    if val is None:
        return False
    txt = str(val).strip()
    if not txt:
        return False
    if key == "pr_url":
        return txt.startswith("http") and "/pull/" in txt
    if key == "workflow_run_url":
        return txt.startswith("http") and "/actions/runs/" in txt
    if key == "commit_sha":
        try:
            _run(["git", "rev-parse", "--verify", f"{txt}^{{commit}}"])
            return True
        except Exception:
            return False
    if key == "bundle_path":
        return (REPO_ROOT / txt).exists() or Path(txt).exists()
    return bool(txt)


def _latest_claim_states(portfolio_id: str = "") -> dict[str, dict]:
    latest = {}
    for rec in _read_jsonl(CLAIMS_JSONL):
        cid = rec.get("claim_id") or ""
        if not cid:
            continue
        if portfolio_id and rec.get("portfolio_id") != portfolio_id:
            continue
        latest[cid] = rec
    return latest


def _render_open_index(latest: dict[str, dict]) -> dict:
    items = []
    for cid, rec in sorted(latest.items(), key=lambda kv: kv[1].get("ts_utc", ""), reverse=True):
        status = rec.get("claim_status") or ""
        if status not in {"CLAIMED", "FAILED"}:
            continue
        items.append({
            "claim_id": cid,
            "portfolio": rec.get("portfolio_id") or "UNSELECTED",
            "type": rec.get("claim_type") or "",
            "status": status,
            "note": rec.get("note") or "",
            "required": rec.get("evidence_required") or [],
            "present": rec.get("evidence_present") or {},
            "anchor": rec.get("primary_anchor") or "",
            "needs_attention": True,
        })
    return {"schema_version": "v1", "generated_at_utc": utc_now_z(), "needs_attention": items}


def reconcile_claims(portfolio_id: str = "", limit: int = 0) -> int:
    latest = _latest_claim_states(portfolio_id)
    target = [r for r in latest.values() if r.get("claim_status") == "CLAIMED"]
    if limit and limit > 0:
        target = target[:limit]
    for rec in target:
        required = rec.get("evidence_required") or []
        present = rec.get("evidence_present") or {}
        ok = all(_verify_evidence_key(k, present.get(k)) for k in required)
        upd = dict(rec)
        upd["ts_utc"] = utc_now_z()
        upd["claim_status"] = "VERIFIED" if ok else "FAILED"
        upd["note"] = (rec.get("note") or "") + (" | reconciled:ok" if ok else " | reconciled:failed")
        _append_jsonl(CLAIMS_JSONL, upd)
        latest[rec["claim_id"]] = upd
    open_idx = _render_open_index(latest)
    write_json(CLAIMS_OPEN_INDEX_JSON, open_idx)
    print(json.dumps(open_idx, ensure_ascii=False))
    return 0


def claims_list(status: str = "", portfolio_id: str = "") -> int:
    if not CLAIMS_OPEN_INDEX_JSON.exists():
        write_json(CLAIMS_OPEN_INDEX_JSON, {"schema_version": "v1", "generated_at_utc": utc_now_z(), "needs_attention": []})
    obj = load_json(CLAIMS_OPEN_INDEX_JSON)
    arr = obj.get("needs_attention") or []
    if status:
        arr = [x for x in arr if (x.get("status") or "") == status]
    if portfolio_id:
        arr = [x for x in arr if (x.get("portfolio") or "") == portfolio_id]
    print(json.dumps({"schema_version": "v1", "generated_at_utc": obj.get("generated_at_utc"), "needs_attention": arr}, ensure_ascii=False))
    return 0


def archive_add(archive_id: str, portfolio_id: str, top_goal: str, primary_anchor: str, path: str, claim_status: str, claim_id: str, needs_attention: bool, tags: list[str], keywords: list[str]) -> int:
    rec = {
        "schema_version": "v1",
        "archive_id": archive_id,
        "ts_utc": utc_now_z(),
        "portfolio_id": portfolio_id or "UNSELECTED",
        "primary_anchor": primary_anchor or "",
        "claim_status": (claim_status if claim_status in {"NONE", "CLAIMED", "VERIFIED", "FAILED"} else "NONE"),
        "claim_id": claim_id or "",
        "needs_attention": bool(needs_attention),
        "top_goal": top_goal or "",
        "tags": tags or [],
        "keywords": keywords or [],
        "path": path or f"docs/MEP/ARCHIVE/SESSIONS/{archive_id}.json",
    }
    _append_jsonl(ARCHIVE_CATALOG_JSONL, rec)
    print(json.dumps(rec, ensure_ascii=False))
    return 0


def archive_search(query: str = "", portfolio_id: str = "", needs_attention_only: bool = False) -> int:
    rows = _read_jsonl(ARCHIVE_CATALOG_JSONL)
    out = []
    q = (query or "").lower().strip()
    for r in rows:
        if portfolio_id and r.get("portfolio_id") != portfolio_id:
            continue
        if needs_attention_only and not bool(r.get("needs_attention")):
            continue
        hay = " ".join([
            str(r.get("archive_id") or ""),
            str(r.get("claim_id") or ""),
            str(r.get("top_goal") or ""),
            " ".join(r.get("tags") or []),
            " ".join(r.get("keywords") or []),
            str(r.get("primary_anchor") or ""),
            str(r.get("claim_status") or ""),
        ]).lower()
        if q and q not in hay:
            continue
        out.append({
            "archive_id": r.get("archive_id") or "",
            "portfolio_id": r.get("portfolio_id") or "UNSELECTED",
            "top_goal": r.get("top_goal") or "",
            "tags": r.get("tags") or [],
            "claim_status": r.get("claim_status") or "NONE",
            "needs_attention": bool(r.get("needs_attention")),
            "primary_anchor": r.get("primary_anchor") or "",
            "ts_utc": r.get("ts_utc") or "",
        })
    print(json.dumps({"results": out}, ensure_ascii=False))
    return 0


def archive_restore(archive_id: str) -> int:
    rows = _read_jsonl(ARCHIVE_CATALOG_JSONL)
    hit = None
    for r in reversed(rows):
        if r.get("archive_id") == archive_id:
            hit = r
            break
    if not hit:
        print("STOP_HARD: ARCHIVE_ID_NOT_FOUND", file=sys.stderr)
        return 1
    src = REPO_ROOT / (hit.get("path") or "")
    if not src.exists():
        print("STOP_HARD: ARCHIVE_PATH_NOT_FOUND", file=sys.stderr)
        return 1
    dst = DOCS_MEP / "ARCHIVE" / "RESTORED" / f"{archive_id}.json"
    dst.parent.mkdir(parents=True, exist_ok=True)
    src.replace(dst)
    try:
        obj = json.loads(dst.read_text(encoding="utf-8"))
    except Exception:
        obj = {}
    if isinstance(obj, dict):
        update_live_state(LIVE_STATE_JSON, obj)
    reconcile_claims(hit.get("portfolio_id") or "", 0)
    print(json.dumps({"restored_archive_id": archive_id, "restored_to": str(dst.relative_to(REPO_ROOT))}, ensure_ascii=False))
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

    ap_li = sub.add_parser("ledger-in")
    ap_li.add_argument("--parent-chat-id", required=True)
    ap_li.add_argument("--portfolio-id", default="")
    ap_li.add_argument("--mode", default="UNSPECIFIED")
    ap_li.add_argument("--primary-anchor", default="UNSPECIFIED")
    ap_li.add_argument("--current-phase", default="UNSPECIFIED")
    ap_li.add_argument("--next-item", default="UNSPECIFIED")
    ap_lo = sub.add_parser("ledger-out")
    ap_lo.add_argument("--this-chat-id", default="")
    ap_lo.add_argument("--portfolio-id", default="")
    ap_lo.add_argument("--mode", default="UNSPECIFIED")
    ap_lo.add_argument("--primary-anchor", default="UNSPECIFIED")
    ap_lo.add_argument("--current-phase", default="UNSPECIFIED")
    ap_lo.add_argument("--next-item", default="UNSPECIFIED")

    ap_claim = sub.add_parser("claim-add")
    ap_claim.add_argument("--portfolio-id", default="")
    ap_claim.add_argument("--run-id", default="")
    ap_claim.add_argument("--mode", default="")
    ap_claim.add_argument("--primary-anchor", default="")
    ap_claim.add_argument("--claim-type", default="DONE")
    ap_claim.add_argument("--dod-ref", required=True)
    ap_claim.add_argument("--evidence-required", default="")
    ap_claim.add_argument("--evidence-present-json", default="{}")
    ap_claim.add_argument("--note", default="")
    ap_claim.add_argument("--session-id", default="")
    ap_claim.add_argument("--related-archive-id", default="")

    ap_rec = sub.add_parser("reconcile-claims")
    ap_rec.add_argument("--portfolio-id", default="")
    ap_rec.add_argument("--limit", type=int, default=0)

    ap_cl = sub.add_parser("claims-list")
    ap_cl.add_argument("--status", default="")
    ap_cl.add_argument("--portfolio-id", default="")

    ap_aa = sub.add_parser("archive-add")
    ap_aa.add_argument("--archive-id", required=True)
    ap_aa.add_argument("--portfolio-id", default="")
    ap_aa.add_argument("--top-goal", default="")
    ap_aa.add_argument("--primary-anchor", default="")
    ap_aa.add_argument("--path", default="")
    ap_aa.add_argument("--claim-status", default="NONE")
    ap_aa.add_argument("--claim-id", default="")
    ap_aa.add_argument("--needs-attention", action="store_true")
    ap_aa.add_argument("--tags", default="")
    ap_aa.add_argument("--keywords", default="")

    ap_as = sub.add_parser("archive-search")
    ap_as.add_argument("--query", default="")
    ap_as.add_argument("--portfolio-id", default="")
    ap_as.add_argument("--needs-attention-only", action="store_true")

    ap_ar = sub.add_parser("archive-restore")
    ap_ar.add_argument("--archive-id", required=True)

    args = ap.parse_args()

    _heartbeat_entry(args.cmd, "HEARTBEAT_CMD_START", "", "cmd_entry")
    try:
        if args.cmd == "boot":
            return boot()
        if args.cmd == "status":
            return status()
        if args.cmd == "apply":
            return apply(Path(args.draft_file))
        if args.cmd == "pr-probe":
            return _run_gate("pr-probe", lambda: pr_probe(args.run_id), args.run_id)
        if args.cmd == "pr-create":
            return _run_gate("pr-create", lambda: pr_create(args.run_id), args.run_id)
        if args.cmd == "assemble-pr":
            return _run_gate("assemble-pr", lambda: assemble_pr(args.run_id), args.run_id)
        if args.cmd == "apply-safe":
            return _run_gate("apply-safe", lambda: apply_safe(args.run_id), args.run_id)
        if args.cmd == "merge-finish":
            return _run_gate("merge-finish", lambda: merge_finish(args.run_id), args.run_id)
        if args.cmd == "compact":
            return _run_gate("compact", compact)

        if args.cmd == "ledger-in":
            rc = ledger_in(args.parent_chat_id, args.portfolio_id, args.mode, args.primary_anchor, args.current_phase, args.next_item)
            _warn_if_ledger_dirty('docs/MEP/CHAT_CHAIN_LEDGER.md')
            return rc
        if args.cmd == "ledger-out":
            # portfolio_id: forbid only when user explicitly passed UNSELECTED
            explicit_pid = getattr(args, "portfolio_id", None)
            if explicit_pid is not None and str(explicit_pid).strip() == "UNSELECTED" and not getattr(args, "allow_unselected", False):
                print("STOP_HARD: PORTFOLIO_ID_UNSELECTED_FORBIDDEN", file=sys.stderr)
                return 1

            rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
            pid = _resolve_portfolio_id_for_ledger(getattr(args,"portfolio_id",""), getattr(args,"allow_unselected", False), rs)
            # forbid explicit UNSELECTED unless explicitly allowed

            args.portfolio_id = pid
            return ledger_out(args.this_chat_id, args.portfolio_id, args.mode, args.primary_anchor, args.current_phase, args.next_item)
        if args.cmd == "claim-add":
            evidence_required = [x.strip() for x in (args.evidence_required or "").split(",") if x.strip()]
            try:
                evidence_present = json.loads(args.evidence_present_json or "{}")
            except Exception:
                evidence_present = {}
            return claim_add(args.portfolio_id, args.run_id, args.mode, args.primary_anchor, args.claim_type, args.dod_ref, evidence_required, evidence_present, args.note, args.session_id, args.related_archive_id)
        if args.cmd == "reconcile-claims":
            return reconcile_claims(args.portfolio_id, args.limit)
        if args.cmd == "claims-list":
            return claims_list(args.status, args.portfolio_id)
        if args.cmd == "archive-add":
            tags = [x.strip() for x in (args.tags or "").split(",") if x.strip()]
            keywords = [x.strip() for x in (args.keywords or "").split(",") if x.strip()]
            path = args.path or f"docs/MEP/ARCHIVE/SESSIONS/{args.archive_id}.json"
            return archive_add(args.archive_id, args.portfolio_id, args.top_goal, args.primary_anchor, path, args.claim_status, args.claim_id, args.needs_attention, tags, keywords)
        if args.cmd == "archive-search":
            return archive_search(args.query, args.portfolio_id, args.needs_attention_only)
        if args.cmd == "archive-restore":
            return archive_restore(args.archive_id)
        return 1
    except Exception as ex:
        print(f"STOP_HARD: STATE_WRITE_FAILED ({ex})", file=sys.stderr)
        _warn_if_ledger_dirty('docs/MEP/CHAT_CHAIN_LEDGER.md')
        return 1
if __name__ == "__main__":
    sys.exit(main())

# mep: ci-retrigger 2026-02-15T11:16:08Z








