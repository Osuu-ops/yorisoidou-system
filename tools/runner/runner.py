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
    # WORK view with optional guidance
    lines = []
    lines.append("# HANDOFF_WORK")
    lines.append(f"NEXT_ACTION: {next_action}")
    lines.append(f"REASON_CODE: {reason_code}")
    lines.append(f"STOP_CLASS: {stop_class}")
    # options (if present)
    opts = lr.get("options") or []
    if isinstance(opts, list) and len(opts) > 0:
        lines.append("")
        lines.append("OPTIONS:")
        for o in opts:
            try:
                lines.append(f"- {o.get('id','')}: {o.get('label','')} -> {o.get('action','')}")
            except Exception:
                continue
    # candidate list (if present)
    cands = lr.get("delete_candidates_sample") or []
    if isinstance(cands, list) and len(cands) > 0:
        lines.append("")
        lines.append("DELETE_CANDIDATES_SAMPLE:")
        for x in cands[:10]:
            lines.append(f"- {x}")
    write_md(HANDOFF_WORK_MD, "\n".join(lines))def boot() -> int:
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
def pr_create(run_id: str) -> int:
    # Phase2.5 minimal: create/open PR for canonical branch and persist evidence pointers
    branch = f"mep/run_{run_id}"
    if RUN_STATE.exists():
        rs = load_json(RUN_STATE)
    else:
        rs = default_run_state()
    rs["run_id"] = run_id
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "PR_CREATE", "outcome": "OK"}
    rs["next_action"] = "STATUS"
    def _run(cmd: list[str]) -> str:
        import subprocess
        p = subprocess.run(cmd, capture_output=True, text=True)
        if p.returncode != 0:
            raise RuntimeError(p.stderr.strip() or "command failed")
        return p.stdout
    repo = os.environ.get("GH_REPO","")
    if not repo:
        rs["last_result"]["action"] = {"name": "PR_CREATE", "outcome": "FAIL"}
        rs["last_result"]["stop_class"] = "HARD"
        rs["last_result"]["reason_code"] = "REPO_NOT_SET"
        rs["next_action"] = "SET_GH_REPO"
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"]}, ensure_ascii=False))
        return 1
    # Ensure local branch exists (idempotent)
    try:
        _run(["git","rev-parse","--verify",branch])
    except Exception:
        _run(["git","checkout","-b",branch])
        _run(["git","push","-u","origin",branch])
    else:
        # ensure remote exists
        try:
            _run(["git","ls-remote","--exit-code","--heads","origin",branch])
        except Exception:
            _run(["git","push","-u","origin",branch])
    # If open PR exists for branch, use it
    open_json = _run(["gh","pr","list","--repo",repo,"--head",branch,"--state","open","--json","number,url","-q","."])
    open_prs = json.loads(open_json) if open_json.strip() else []
    if len(open_prs) > 1:
        rs["last_result"]["stop_class"] = "HARD"
        rs["last_result"]["reason_code"] = "MULTIPLE_PR_FOR_ONE_RUN"
        rs["next_action"] = "MANUAL_RESOLUTION_REQUIRED"
        rs["last_result"]["evidence"] = {"branch_name": branch}
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"],"branch_name":branch}, ensure_ascii=False))
        return 1
    if len(open_prs) == 1:
        pr_url = open_prs[0].get("url")
        rs["last_result"]["evidence"] = {"branch_name": branch, "pr_url": pr_url}
        rs["last_result"]["stop_class"] = ""
        rs["last_result"]["reason_code"] = ""
        rs["next_action"] = "STATUS"
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"OK","branch_name":branch,"pr_url":pr_url}, ensure_ascii=False))
        return 0
    # Create PR (idempotent-ish: if fails because exists, probe again)
    title = f"MEP RUN {run_id}"
    body = f"Runner created PR for RUN_ID={run_id}"
    try:
        pr_url = _run(["gh","pr","create","--repo",repo,"--head",branch,"--base","main","--title",title,"--body",body]).strip()
    except Exception:
        # re-probe
        open_json = _run(["gh","pr","list","--repo",repo,"--head",branch,"--state","open","--json","number,url","-q","."])
        open_prs = json.loads(open_json) if open_json.strip() else []
        if len(open_prs) == 1:
            pr_url = open_prs[0].get("url")
        else:
            rs["last_result"]["stop_class"] = "WAIT"
            rs["last_result"]["reason_code"] = "EVIDENCE_REQUIRED_BUT_UNAVAILABLE"
            rs["next_action"] = "PROVIDE_EVIDENCE_OR_ABORT"
            rs["last_result"]["evidence"] = {"branch_name": branch}
            write_json(RUN_STATE, rs); update_compiled(rs)
            print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"],"branch_name":branch}, ensure_ascii=False))
            return 2
    rs["last_result"]["evidence"] = {"branch_name": branch, "pr_url": pr_url}
    rs["last_result"]["stop_class"] = ""
    rs["last_result"]["reason_code"] = ""
    rs["next_action"] = "STATUS"
    write_json(RUN_STATE, rs); update_compiled(rs)
    print(json.dumps({"state":"OK","branch_name":branch,"pr_url":pr_url}, ensure_ascii=False))
    return 0
def assemble_pr(run_id: str) -> int:
    # Phase3 minimal: scan results patches and validate (no PR update yet)
    results_dir = MEP_DIR / "results" / run_id
    if not results_dir.exists():
        # STOP_WAIT: nothing to assemble
        rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
        rs["run_id"] = run_id
        rs["updated_at"] = utc_now_z()
        rs["last_result"]["timestamp_utc"] = rs["updated_at"]
        rs["last_result"]["action"] = {"name": "ASSEMBLE_PR", "outcome": "FAIL"}
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "NO_PATCH_RESULTS"
        rs["next_action"] = "WAIT_FOR_WORKER_RESULTS"
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"],"next_action":rs["next_action"]}, ensure_ascii=False))
        return 2
    patches = sorted(results_dir.glob("*.patch"))
    if not patches:
        rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
        rs["run_id"] = run_id
        rs["updated_at"] = utc_now_z()
        rs["last_result"]["timestamp_utc"] = rs["updated_at"]
        rs["last_result"]["action"] = {"name": "ASSEMBLE_PR", "outcome": "FAIL"}
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "NO_PATCH_RESULTS"
        rs["next_action"] = "WAIT_FOR_WORKER_RESULTS"
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"],"next_action":rs["next_action"]}, ensure_ascii=False))
        return 2
    # read policy limits (required)
    pol = load_yaml(POLICY) if POLICY.exists() else {}
    limits = (pol.get("limits") or {})
    max_bytes = int(limits.get("patch_max_bytes", 0) or 0)
    max_lines = int(limits.get("patch_max_lines", 0) or 0)
    if max_bytes <= 0 or max_lines <= 0:
        rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
        rs["run_id"] = run_id
        rs["updated_at"] = utc_now_z()
        rs["last_result"]["timestamp_utc"] = rs["updated_at"]
        rs["last_result"]["action"] = {"name": "ASSEMBLE_PR", "outcome": "FAIL"}
        rs["last_result"]["stop_class"] = "HARD"
        rs["last_result"]["reason_code"] = "POLICY_SCHEMA_INVALID"
        rs["next_action"] = "FIX_POLICY_SCHEMA"
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"],"next_action":rs["next_action"]}, ensure_ascii=False))
        return 1
    # validate all patches
    total_bytes = 0
    total_lines = 0
    deny_patterns = [
        "GIT binary patch",
        "Binary files ",
        "deleted file mode",
        "rename from",
        "rename to",
        "old mode",
        "new mode",
    ]
    for p in patches:
        txt = p.read_text(encoding="utf-8", errors="replace")
        total_bytes += len(txt.encode("utf-8", errors="replace"))
        total_lines += txt.count("\n") + 1
        for pat in deny_patterns:
            if pat in txt:
                rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
                rs["run_id"] = run_id
                rs["updated_at"] = utc_now_z()
                rs["last_result"]["timestamp_utc"] = rs["updated_at"]
                rs["last_result"]["action"] = {"name": "ASSEMBLE_PR", "outcome": "FAIL"}
                rs["last_result"]["stop_class"] = "HARD"
                rs["last_result"]["reason_code"] = "DANGEROUS_DIFF_FORBIDDEN"
                rs["next_action"] = "SPLIT_PATCH_OR_REDUCE_SCOPE"
                write_json(RUN_STATE, rs); update_compiled(rs)
                print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"],"file":str(p)}, ensure_ascii=False))
                return 1
    if total_bytes > max_bytes or total_lines > max_lines:
        rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
        rs["run_id"] = run_id
        rs["updated_at"] = utc_now_z()
        rs["last_result"]["timestamp_utc"] = rs["updated_at"]
        rs["last_result"]["action"] = {"name": "ASSEMBLE_PR", "outcome": "FAIL"}
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "PATCH_TOO_LARGE"
        rs["next_action"] = "SPLIT_PATCH_OR_REDUCE_SCOPE"
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"],"bytes":total_bytes,"lines":total_lines}, ensure_ascii=False))
        return 2
    # OK (still no PR update in Phase3 minimal)
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    rs["run_id"] = run_id
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "ASSEMBLE_PR", "outcome": "OK"}
    rs["last_result"]["stop_class"] = ""
    rs["last_result"]["reason_code"] = ""
    rs["next_action"] = "READY_TO_APPLY_SAFE_PATH"
    write_json(RUN_STATE, rs); update_compiled(rs)
    print(json.dumps({"state":"OK","patches":len(patches),"bytes":total_bytes,"lines":total_lines,"next_action":rs["next_action"]}, ensure_ascii=False))
    return 0
def apply_safe(run_id: str) -> int:
    # Phase3.5: apply patches to branch and update/open PR (safe path via PR)
    branch = f"mep/run_{run_id}"
    results_dir = MEP_DIR / "results" / run_id
    patches = sorted(results_dir.glob("*.patch")) if results_dir.exists() else []
    if not patches:
        rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
        rs["run_id"] = run_id
        rs["updated_at"] = utc_now_z()
        rs["last_result"]["timestamp_utc"] = rs["updated_at"]
        rs["last_result"]["action"] = {"name": "APPLY_SAFE", "outcome": "FAIL"}
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "NO_PATCH_RESULTS"
        rs["next_action"] = "WAIT_FOR_WORKER_RESULTS"
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"]}, ensure_ascii=False))
        return 2
    def _run(cmd: list[str]) -> str:
        import subprocess
        p = subprocess.run(cmd, capture_output=True, text=True)
        if p.returncode != 0:
            raise RuntimeError(p.stderr.strip() or "command failed")
        return p.stdout
    repo = os.environ.get("GH_REPO","")
    if not repo:
        rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
        rs["run_id"] = run_id
        rs["updated_at"] = utc_now_z()
        rs["last_result"]["timestamp_utc"] = rs["updated_at"]
        rs["last_result"]["action"] = {"name": "APPLY_SAFE", "outcome": "FAIL"}
        rs["last_result"]["stop_class"] = "HARD"
        rs["last_result"]["reason_code"] = "REPO_NOT_SET"
        rs["next_action"] = "SET_GH_REPO"
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"]}, ensure_ascii=False))
        return 1
    # checkout branch (create if missing)
    try:
        _run(["git","checkout",branch])
    except Exception:
        _run(["git","checkout","-b",branch])
        _run(["git","push","-u","origin",branch])
    # apply all patches
    for p in patches:
        _run(["git","apply","--check",str(p)])
    for p in patches:
        _run(["git","apply",str(p)])
    # commit + push
    _run(["git","add","-A"])
    _run(["git","commit","-m",f"mep: apply patches for {run_id}"])
    _run(["git","push","origin",branch])
    # open PR exists?
    open_json = _run(["gh","pr","list","--repo",repo,"--head",branch,"--state","open","--json","number,url","-q","."])
    open_prs = json.loads(open_json) if open_json.strip() else []
    if len(open_prs) > 1:
        rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
        rs["run_id"] = run_id
        rs["updated_at"] = utc_now_z()
        rs["last_result"]["timestamp_utc"] = rs["updated_at"]
        rs["last_result"]["action"] = {"name": "APPLY_SAFE", "outcome": "FAIL"}
        rs["last_result"]["stop_class"] = "HARD"
        rs["last_result"]["reason_code"] = "MULTIPLE_PR_FOR_ONE_RUN"
        rs["next_action"] = "MANUAL_RESOLUTION_REQUIRED"
        rs["last_result"]["evidence"] = {"branch_name": branch}
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"]}, ensure_ascii=False))
        return 1
    if len(open_prs) == 1:
        pr_url = open_prs[0].get("url")
    else:
        title = f"MEP RUN {run_id} (apply)"
        body = f"Runner applied patches and updated branch for RUN_ID={run_id}"
        pr_url = _run(["gh","pr","create","--repo",repo,"--head",branch,"--base","main","--title",title,"--body",body]).strip()
    # commit sha
    sha = _run(["git","rev-parse","HEAD"]).strip()
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    rs["run_id"] = run_id
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "APPLY_SAFE", "outcome": "OK"}
    rs["last_result"]["stop_class"] = ""
    rs["last_result"]["reason_code"] = ""
    rs["last_result"]["evidence"] = {"branch_name": branch, "pr_url": pr_url, "commit_sha": sha}
    rs["next_action"] = "STATUS"
    write_json(RUN_STATE, rs); update_compiled(rs)
    print(json.dumps({"state":"OK","branch_name":branch,"pr_url":pr_url,"commit_sha":sha}, ensure_ascii=False))
    return 0
def merge_finish(run_id: str) -> int:
    # Phase4 minimal: wait checks, request auto-merge, wait merged, mark DONE
    def _run(cmd: list[str]) -> str:
        import subprocess
        p = subprocess.run(cmd, capture_output=True, text=True)
        if p.returncode != 0:
            raise RuntimeError(p.stderr.strip() or "command failed")
        return p.stdout
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    rs["run_id"] = run_id
    rs["updated_at"] = utc_now_z()
    rs["last_result"]["timestamp_utc"] = rs["updated_at"]
    rs["last_result"]["action"] = {"name": "MERGE_FINISH", "outcome": "OK"}
    ev = rs.get("last_result", {}).get("evidence", {}) or {}
    pr_url = ev.get("pr_url") or ""
    if not pr_url:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "EVIDENCE_REQUIRED_BUT_UNAVAILABLE"
        rs["next_action"] = "PROVIDE_EVIDENCE_OR_ABORT"
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"],"next_action":rs["next_action"]}, ensure_ascii=False))
        return 2
    try:
        pr_num = int(pr_url.rstrip("/").split("/")[-1])
    except Exception:
        rs["last_result"]["stop_class"] = "HARD"
        rs["last_result"]["reason_code"] = "EVIDENCE_MALFORMED"
        rs["next_action"] = "FIX_EVIDENCE"
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"]}, ensure_ascii=False))
        return 1
    repo = os.environ.get("GH_REPO","")
    if not repo:
        rs["last_result"]["stop_class"] = "HARD"
        rs["last_result"]["reason_code"] = "REPO_NOT_SET"
        rs["next_action"] = "SET_GH_REPO"
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"]}, ensure_ascii=False))
        return 1
    # wait checks (up to ~30min)
    for _ in range(360):
        out = _run(["gh","pr","checks",str(pr_num),"--repo",repo])
        if "0 pending checks" in out and "0 failing" in out:
            break
        import time; time.sleep(5)
    else:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "CHECKS_TIMEOUT"
        rs["next_action"] = "WAIT_FOR_CHECKS"
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"]}, ensure_ascii=False))
        return 2
    # request auto-merge
    _run(["gh","pr","merge",str(pr_num),"--repo",repo,"--auto","--squash"])
    # wait merged
    for _ in range(360):
        j = _run(["gh","pr","view",str(pr_num),"--repo",repo,"--json","state,mergedAt,url","-q","{state:.state,mergedAt:(.mergedAt//\"\"),url:.url}"])
        if '"state":"MERGED"' in j:
            break
        import time; time.sleep(5)
    else:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "MERGE_TIMEOUT"
        rs["next_action"] = "WAIT_FOR_MERGE"
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"]}, ensure_ascii=False))
        return 2
    rs["run_status"] = "DONE"
    rs["last_result"]["stop_class"] = ""
    rs["last_result"]["reason_code"] = ""
    rs["next_action"] = "ALL_DONE"
    write_json(RUN_STATE, rs); update_compiled(rs)
    print(json.dumps({"state":"OK","pr_url":pr_url,"run_status":rs["run_status"]}, ensure_ascii=False))
    return 0
def compact() -> int:
    # Phase5 full: history retention + pinned_overflow + keep_runs overflow handling
    # Safety: deletion is performed ONLY when retention.allow_delete == true.
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
    # history append (best-effort)
    hist = rs.get("history") or []
    if not isinstance(hist, list):
        hist = []
    lr = rs.get("last_result") or {}
    ev = lr.get("evidence") or {}
    hist.append({
        "run_id": rs.get("run_id","") or "",
        "result_state": rs.get("run_status","") or "",
        "stop_class": lr.get("stop_class","") or "",
        "reason_code": lr.get("reason_code","") or "",
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
    # pinned overflow
    if len(pinned_runs) > pinned_max:
        rs["last_result"]["stop_class"] = "WAIT"
        rs["last_result"]["reason_code"] = "PINNED_OVERFLOW"
        rs["next_action"] = "RESOLVE_PINNED_OVERFLOW"
        rs["last_result"]["options"] = [
            {"id":"A","label":"Reduce pinned_runs in mep/policy.yaml retention.pinned_runs","action":"EDIT_POLICY"},
            {"id":"B","label":"Increase retention.pinned_max (with justification)","action":"EDIT_POLICY"},
        ]
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"STOP","reason_code":rs["last_result"]["reason_code"],"next_action":rs["next_action"]}, ensure_ascii=False))
        return 2
    # detect run_ids present in filesystem (results/work_items only; inbox drafts are preserved)
    inbox = (MEP_DIR / "inbox")
    work_items = (MEP_DIR / "work_items")
    results = (MEP_DIR / "results")
    def _scan_dir(d: Path) -> set[str]:
        out=set()
        if not d.exists():
            return out
        for p in d.iterdir():
            if p.is_dir() and p.name.startswith("RUN_"):
                out.add(p.name)
        return out
    run_ids = set()
    run_ids |= _scan_dir(work_items)
    run_ids |= _scan_dir(results)
    # current run protected
    current = rs.get("run_id","") or ""
    protected = set([current]) | set(pinned_runs)
    # build candidates using history timestamps (oldest first), fallback to lexicographic
    def _ts(x: dict) -> str:
        return str(x.get("timestamp_utc","") or "")
    seen = set()
    ordered = []
    for h in sorted(hist, key=_ts):
        rid = h.get("run_id","") or ""
        if not rid or rid in seen:
            continue
        seen.add(rid)
        if rid in run_ids and rid not in protected:
            ordered.append(rid)
    # add any remaining (unknown history) as lexicographic tail
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
                {"id":"A","label":"Set retention.allow_delete: true to allow auto deletion of results/work_items only","action":"EDIT_POLICY"},
                {"id":"B","label":"Increase retention.keep_runs to avoid deletion","action":"EDIT_POLICY"},
            ]
            write_json(RUN_STATE, rs); update_compiled(rs)
            print(json.dumps({
                "state":"STOP",
                "reason_code":rs["last_result"]["reason_code"],
                "next_action":rs["next_action"],
                "run_count_detected":len(run_ids),
                "keep_runs":keep_runs,
                "delete_candidates_sample":to_delete[:10],
            }, ensure_ascii=False))
            return 2
        # allow_delete==true : delete results/work_items only
        for rid in to_delete:
            for d in (results / rid, work_items / rid):
                if d.exists() and d.is_dir():
                    for child in d.rglob("*"):
                        if child.is_file():
                            child.unlink()
                    for child in sorted([x for x in d.rglob("*") if x.is_dir()], key=lambda x: len(str(x)), reverse=True):
                        try: child.rmdir()
                        except Exception: pass
                    try: d.rmdir()
                    except Exception: pass
        rs["last_result"]["stop_class"] = ""
        rs["last_result"]["reason_code"] = ""
        rs["next_action"] = "STATUS"
        write_json(RUN_STATE, rs); update_compiled(rs)
        print(json.dumps({"state":"OK","deleted_count":len(to_delete),"deleted_run_ids":to_delete}, ensure_ascii=False))
        return 0
    rs["last_result"]["stop_class"] = ""
    rs["last_result"]["reason_code"] = ""
    rs["next_action"] = "STATUS"
    write_json(RUN_STATE, rs); update_compiled(rs)
    print(json.dumps({"state":"OK","run_count_detected":len(run_ids),"keep_runs":keep_runs}, ensure_ascii=False))
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