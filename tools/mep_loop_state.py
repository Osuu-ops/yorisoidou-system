#!/usr/bin/env python3
import argparse
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

THIS_DIR = Path(__file__).resolve().parent
RUNNER_DIR = THIS_DIR / "runner"
for candidate in (THIS_DIR, RUNNER_DIR):
    if str(candidate) not in sys.path:
        sys.path.insert(0, str(candidate))

from runner import update_compiled

REPO_ROOT = THIS_DIR.parent
RUN_STATE = REPO_ROOT / "mep" / "run_state.json"


def utc_now_z() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8", newline="\n") as fh:
        json.dump(payload, fh, ensure_ascii=False, indent=2)
        fh.write("\n")
    tmp.replace(path)


def default_run_state() -> dict:
    now = utc_now_z()
    return {
        "gh_repo": "",
        "repo": "",
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
                "branch_name": "",
                "pr_url": "",
                "commit_sha": "",
                "workflow_run_url": "",
            },
            "options": [],
            "delete_candidates_sample": [],
        },
        "history": [],
        "updated_at": now,
        "handoff": None,
        "handoff_ack": None,
    }


def workflow_run_url(repo: str, workflow_run_id: str) -> str:
    if not repo or not workflow_run_id:
        return ""
    return f"https://github.com/{repo}/actions/runs/{workflow_run_id}"


def normalize_stop_class(outcome: str, stop_class: str) -> str:
    normalized = (stop_class or "").strip().upper()
    if normalized:
        return normalized
    if outcome == "STOP":
        return "HARD"
    if outcome == "WAIT":
        return "WAIT"
    return ""


def build_parser() -> argparse.ArgumentParser:
    ap = argparse.ArgumentParser()
    ap.add_argument("--phase", required=True)
    ap.add_argument("--phase-status", required=True)
    ap.add_argument("--next-action", required=True)
    ap.add_argument("--reason-code", required=True)
    ap.add_argument("--outcome", default="OK")
    ap.add_argument("--stop-class", default="")
    ap.add_argument("--run-status", default="STILL_OPEN")
    ap.add_argument("--phase-result-path", default="")
    ap.add_argument("--phase-summary-path", default=".mep/phase_summary.md")
    ap.add_argument("--phase-pointers-json", default=".mep/loop_phase_pointers.json")
    ap.add_argument("--restart-packet-path", default=".mep/RESTART_PACKET.txt")
    ap.add_argument("--workflow-path", default=".github/workflows/mep_loop_engine_v2.yml")
    ap.add_argument("--workflow-run-id", default=os.environ.get("GITHUB_RUN_ID", ""))
    ap.add_argument("--repo", default=os.environ.get("GITHUB_REPOSITORY", ""))
    ap.add_argument("--branch-name", default=os.environ.get("GITHUB_REF_NAME", ""))
    ap.add_argument("--commit-sha", default=os.environ.get("GITHUB_SHA", ""))
    ap.add_argument("--iter", default="")
    ap.add_argument("--max-iter", default="")
    ap.add_argument("--sleep-seconds", default="")
    ap.add_argument("--pr-url", default="")
    ap.add_argument("--controller-label", default=os.environ.get("MEP_CONTROLLER_LABEL", ""))
    ap.add_argument("--expected-controller-label", default=os.environ.get("MEP_EXPECTED_CONTROLLER_LABEL", ""))
    ap.add_argument("--compile-docs", action="store_true")
    return ap


def main() -> int:
    args = build_parser().parse_args()
    now = utc_now_z()
    rs = load_json(RUN_STATE) if RUN_STATE.exists() else default_run_state()
    existing_loop = rs.get("loop_state") if isinstance(rs.get("loop_state"), dict) else {}
    existing_results = existing_loop.get("phase_results") if isinstance(existing_loop.get("phase_results"), dict) else {}
    repo = (args.repo or rs.get("gh_repo") or rs.get("repo") or "").strip()
    workflow_run_id = str(args.workflow_run_id or "").strip()
    loop_run_id = f"RUN_LOOP_{workflow_run_id}" if workflow_run_id else (str(rs.get("run_id") or "").strip() or "RUN_LOOP_UNSET")
    wf_url = workflow_run_url(repo, workflow_run_id)
    phase = args.phase.strip()
    stop_class = normalize_stop_class(args.outcome.strip().upper(), args.stop_class)
    evidence = {
        "branch_name": (args.branch_name or "").strip(),
        "pr_url": (args.pr_url or "").strip(),
        "commit_sha": (args.commit_sha or "").strip(),
        "workflow_run_url": wf_url,
        "phase": phase,
        "phase_status": (args.phase_status or "").strip(),
        "phase_result_path": (args.phase_result_path or "").strip(),
        "phase_summary_path": (args.phase_summary_path or "").strip(),
        "phase_pointers_json": (args.phase_pointers_json or "").strip(),
        "loop_workflow": (args.workflow_path or "").strip(),
        "restart_packet_path": (args.restart_packet_path or "").strip(),
    }
    phase_results = dict(existing_results)
    phase_results[phase] = {
        "status": evidence["phase_status"],
        "outcome": (args.outcome or "").strip().upper(),
        "stop_class": stop_class,
        "reason_code": (args.reason_code or "").strip(),
        "result_path": evidence["phase_result_path"],
        "updated_at": now,
    }
    controller_label = (args.controller_label or existing_loop.get("controller_label") or "").strip()
    expected_controller_label = (args.expected_controller_label or existing_loop.get("expected_controller_label") or "").strip()
    rs["gh_repo"] = repo or rs.get("gh_repo") or rs.get("repo") or ""
    rs["repo"] = repo or rs.get("repo") or rs.get("gh_repo") or ""
    rs["run_id"] = loop_run_id
    rs["run_status"] = (args.run_status or "STILL_OPEN").strip()
    rs["next_action"] = (args.next_action or "").strip()
    rs["updated_at"] = now
    rs["last_result"] = {
        "stop_class": stop_class,
        "reason_code": (args.reason_code or "").strip(),
        "next_action": rs["next_action"],
        "timestamp_utc": now,
        "action": {"name": phase, "outcome": (args.outcome or "").strip().upper()},
        "evidence": evidence,
        "options": (rs.get("last_result") or {}).get("options") or [],
        "delete_candidates_sample": (rs.get("last_result") or {}).get("delete_candidates_sample") or [],
    }
    rs["loop_state"] = {
        "schema_version": "v1",
        "mode": "CANONICAL_LOOP_ENGINE_V2",
        "workflow": (args.workflow_path or "").strip(),
        "workflow_run_id": workflow_run_id,
        "workflow_run_url": wf_url,
        "branch_name": evidence["branch_name"],
        "commit_sha": evidence["commit_sha"],
        "iter": str(args.iter or ""),
        "max_iter": str(args.max_iter or ""),
        "sleep_seconds": str(args.sleep_seconds or ""),
        "controller_label": controller_label,
        "expected_controller_label": expected_controller_label,
        "current_phase": phase,
        "next_action": rs["next_action"],
        "phase_status": evidence["phase_status"],
        "reason_code": (args.reason_code or "").strip(),
        "phase_result_path": evidence["phase_result_path"],
        "phase_summary_path": evidence["phase_summary_path"],
        "phase_pointers_json": evidence["phase_pointers_json"],
        "restart_packet_path": evidence["restart_packet_path"],
        "resume_via_workflow": existing_loop.get("resume_via_workflow") or "",
        "resume_from_iter": existing_loop.get("resume_from_iter") or "",
        "resume_target_iter": existing_loop.get("resume_target_iter") or "",
        "updated_at": now,
        "phase_results": phase_results,
    }
    write_json(RUN_STATE, rs)
    if args.compile_docs:
        update_compiled(rs)
    print(json.dumps({
        "run_id": rs["run_id"],
        "phase": phase,
        "next_action": rs["next_action"],
        "reason_code": rs["last_result"]["reason_code"],
        "workflow_run_url": wf_url,
    }, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

