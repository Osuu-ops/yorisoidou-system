#!/usr/bin/env python3
import argparse
import hashlib
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
try:
    import yaml  # type: ignore
except Exception as e:
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
    return {
        "run_id": "",
        "run_status": "STILL_OPEN",
        "next_action": "BOOT",
        "last_result": {
            "stop_class": "",
            "reason_code": "",
            "next_action": "BOOT",
            "timestamp_utc": utc_now_z(),
            "action": {"name": "BOOT", "outcome": "OK"},
            "evidence": {
                "branch_name": None,
                "pr_url": None,
                "commit_sha": None,
                "workflow_run_url": None,
            },
        },
        "work_summary": {"total": "unknown", "ready": "unknown", "in_progress": "unknown", "done": "unknown", "stop": "unknown"},
        "history": [],
        "updated_at": utc_now_z(),
        "last_good": None,
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
    write_md(STATUS_MD, f"""# STATUS
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
""")
    write_md(HANDOFF_AUDIT_MD, f"""# HANDOFF_AUDIT
SSOT_PATHS:
- mep/boot_spec.yaml
- mep/policy.yaml
- mep/run_state.json
LATEST_EVIDENCE_POINTERS:
- pr_url: {pr_url}
- commit_sha: {commit_sha}
- workflow_run_url: {wf_url}
""")
    write_md(HANDOFF_WORK_MD, f"""# HANDOFF_WORK
NEXT_ACTION: {next_action}
REASON_CODE: {reason_code}
STOP_CLASS: {stop_class}
""")
def boot() -> int:
    # existence checks (auto-generate minimal if missing)
    if not BOOT_SPEC.exists():
        ensure_parent(BOOT_SPEC)
        BOOT_SPEC.write_text('# mep/boot_spec.yaml (AUTO GENERATED)\n', encoding="utf-8")
    if not POLICY.exists():
        ensure_parent(POLICY)
        POLICY.write_text('# mep/policy.yaml (AUTO GENERATED)\npaths_allow: []\npaths_deny: []\n', encoding="utf-8")
    if RUN_STATE.exists():
        rs = load_json(RUN_STATE)
    else:
        rs = default_run_state()
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "BOOT", "outcome": "OK"}
    rs["next_action"] = "STATUS"
    write_json(RUN_STATE, rs)
    update_compiled(rs)
    print(json.dumps({
        "run_id": rs.get("run_id",""),
        "run_status": rs.get("run_status",""),
        "last_result.stop_class": rs.get("last_result",{}).get("stop_class",""),
        "last_result.reason_code": rs.get("last_result",{}).get("reason_code",""),
        "next_action": rs.get("next_action",""),
    }, ensure_ascii=False))
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
    print(json.dumps({
        "run_id": rs.get("run_id",""),
        "run_status": rs.get("run_status",""),
        "last_result.stop_class": rs.get("last_result",{}).get("stop_class",""),
        "last_result.reason_code": rs.get("last_result",{}).get("reason_code",""),
        "next_action": rs.get("next_action",""),
    }, ensure_ascii=False))
    return 0
def apply(draft_file: Path) -> int:
    if not draft_file.exists():
        print("STOP_HARD: DRAFT_FILE_NOT_FOUND", file=sys.stderr)
        return 1
    text = draft_file.read_text(encoding="utf-8")
    draft_canonical = text.replace("\r\n","\n").replace("\r","\n").strip()
    h = hashlib.sha256(draft_canonical.encode("utf-8")).hexdigest()[:12]
    run_id = f"RUN_{h}"
    inbox = MEP_DIR / "inbox"
    ensure_parent(inbox / "x")
    (inbox / f"draft_{run_id}.md").write_text(text, encoding="utf-8")
    if RUN_STATE.exists():
        rs = load_json(RUN_STATE)
    else:
        rs = default_run_state()
    rs["run_id"] = run_id
    rs["run_status"] = rs.get("run_status") or "STILL_OPEN"
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "APPLY", "outcome": "OK"}
    rs["last_result"]["reason_code"] = ""
    rs["last_result"]["stop_class"] = ""
    rs["next_action"] = "STATUS"
    write_json(RUN_STATE, rs)
    update_compiled(rs)
    print(json.dumps({"run_id": run_id, "next_action": rs["next_action"]}, ensure_ascii=False))
    return 0
def pr_probe(run_id: str) -> int:
    # Phase2 minimal: identify branch/pr and persist evidence pointers (no PR creation)
    # Spec 5.3: canonical branch = mep/run_<RUN_ID>
    branch = f"mep/run_{run_id}"
    # load run_state (or init)
    if RUN_STATE.exists():
        rs = load_json(RUN_STATE)
    else:
        rs = default_run_state()
    rs["run_id"] = run_id
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "PR_PROBE", "outcome": "OK"}
    rs["next_action"] = "STATUS"
    # gh pr list (open and closed)
    # NOTE: this is observation only; creation is later phase.
    def _run(cmd: list[str]) -> str:
        import subprocess
        p = subprocess.run(cmd, capture_output=True, text=True)
        if p.returncode != 0:
            raise RuntimeError(p.stderr.strip() or "gh failed")
        return p.stdout
    try:
        open_json = _run(["gh","pr","list","--repo",os.environ.get("GH_REPO",""),"--head",branch,"--state","open","--json","number,url","-q","."])
        closed_json = _run(["gh","pr","list","--repo",os.environ.get("GH_REPO",""),"--head",branch,"--state","closed","--json","number,url","-q","."])
        open_prs = json.loads(open_json) if open_json.strip() else []
        closed_prs = json.loads(closed_json) if closed_json.strip() else []
    except Exception as e:
        rs["last_result"]["action"] = {"name": "PR_PROBE", "outcome": "FAIL"}
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "EVIDENCE_REQUIRED_BUT_UNAVAILABLE"
        rs["next_action"] = "PROVIDE_EVIDENCE_OR_ABORT"
        write_json(RUN_STATE, rs)
        update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"],"next_action":rs["next_action"]}, ensure_ascii=False))
        return 2
    # decide evidence pointers
    ev = rs["last_result"].get("evidence", {}) or {}
    ev["branch_name"] = branch
    if len(open_prs) == 1:
        ev["pr_url"] = open_prs[0].get("url")
        rs["last_result"]["stop_class"] = ""
        rs["last_result"]["reason_code"] = ""
        rs["next_action"] = "STATUS"
        rs["last_result"]["evidence"] = ev
        write_json(RUN_STATE, rs)
        update_compiled(rs)
        print(json.dumps({"state":"OK","branch_name":branch,"pr_url":ev["pr_url"]}, ensure_ascii=False))
        return 0
    if len(open_prs) == 0 and len(closed_prs) >= 1:
        # Spec 5.3: closed only => STOP_WAIT PR_CLOSED_FOR_RUN (open new PR later phase)
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "PR_CLOSED_FOR_RUN"
        rs["next_action"] = "OPEN_NEW_PR_FOR_RUN"
        rs["last_result"]["evidence"] = ev
        write_json(RUN_STATE, rs)
        update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"],"next_action":rs["next_action"],"branch_name":branch}, ensure_ascii=False))
        return 2
    if len(open_prs) == 0 and len(closed_prs) == 0:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "PR_NOT_FOUND_FOR_RUN"
        rs["next_action"] = "CREATE_PR_FOR_RUN"
        rs["last_result"]["evidence"] = ev
        write_json(RUN_STATE, rs)
        update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"],"next_action":rs["next_action"],"branch_name":branch}, ensure_ascii=False))
        return 2
    # multiple PRs => HARD
    rs["last_result"]["stop_class"] = "HARD"
    rs["last_result"]["reason_code"] = "MULTIPLE_PR_FOR_ONE_RUN"
    rs["next_action"] = "MANUAL_RESOLUTION_REQUIRED"
    rs["last_result"]["evidence"] = ev
    write_json(RUN_STATE, rs)
    update_compiled(rs)
    print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"],"next_action":rs["next_action"],"branch_name":branch}, ensure_ascii=False))
    return 1
def main() -> int:
    ap = argparse.ArgumentParser(prog="runner.py")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("boot")
    sub.add_parser("status")
    ap_apply = sub.add_parser("apply")
    ap_apply.add_argument("--draft-file", required=True)
    args = ap.parse_args()
    if args.cmd == "boot":
        return boot()
    if args.cmd == "status":
        return status()
    if args.cmd == "apply":
        return apply(Path(args.draft_file))
    if args.cmd == "pr-probe":
        return pr_probe(args.run_id)    return 1
if __name__ == "__main__":
    sys.exit(main())