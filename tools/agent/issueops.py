#!/usr/bin/env python3
import datetime as dt
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RUN_STATE_PATH = ROOT / "mep/run_state.json"
STATUS_PATH = ROOT / "docs/MEP/STATUS.md"
AUDIT_PATH = ROOT / "docs/MEP/HANDOFF_AUDIT.md"
WORK_PATH = ROOT / "docs/MEP/HANDOFF_WORK.md"
INBOX_DIR = ROOT / "mep/inbox"


def run(cmd):
    return subprocess.run(cmd, check=True, text=True, capture_output=True)


def utc_now():
    return dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def canonicalize(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n").strip()


def calc_run_id(canonical_draft: str) -> str:
    h = hashlib.sha256(canonical_draft.encode("utf-8")).hexdigest()[:12]
    return f"RUN_{h}"


def gh_json(args):
    completed = run(["gh", "api", *args])
    return json.loads(completed.stdout)


def load_event():
    event_path = os.environ["GITHUB_EVENT_PATH"]
    with open(event_path, "r", encoding="utf-8") as f:
        return json.load(f)


def should_run(issue, latest_comment_body):
    body_trimmed = (issue.get("body") or "").strip()
    body_trigger = body_trimmed.endswith("/mep run")
    comment_trigger = "/mep run" in (latest_comment_body or "")
    return body_trigger or comment_trigger


def fetch_latest_comment(repo, issue_number):
    comments = gh_json([f"repos/{repo}/issues/{issue_number}/comments", "--paginate", "-f", "per_page=1", "-f", "page=1"])
    if comments:
        return comments[-1].get("body") or ""
    return ""


def update_run_state(run_id, outcome, reason_code, next_action, workflow_run_url, pr_url):
    now = utc_now()
    state = {}
    if RUN_STATE_PATH.exists():
        state = json.loads(RUN_STATE_PATH.read_text(encoding="utf-8"))

    state["run_id"] = run_id
    state["run_status"] = "STILL_OPEN" if outcome == "PASS" else "STOPPED"
    state["next_action"] = next_action
    state["last_result"] = {
        "stop_class": "" if outcome == "PASS" else outcome,
        "reason_code": reason_code,
        "next_action": next_action,
        "timestamp_utc": now,
        "action": {"name": "ISSUEOPS_BOOT", "outcome": "OK" if outcome == "PASS" else "NG"},
        "evidence": {
            "branch_name": f"mep/issueops-run-{run_id.lower()}",
            "pr_url": pr_url,
            "commit_sha": None,
            "workflow_run_url": workflow_run_url,
        },
    }
    state["updated_at"] = now
    RUN_STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    RUN_STATE_PATH.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    STATUS_PATH.write_text(
        "\n".join([
            "# STATUS",
            "",
            f"RUN_ID: {run_id}",
            "",
            "RUN_STATUS: STILL_OPEN" if outcome == "PASS" else "RUN_STATUS: STOPPED",
            "",
            f"STOP_CLASS: {'' if outcome == 'PASS' else outcome}",
            "",
            f"REASON_CODE: {reason_code}",
            "",
            f"NEXT_ACTION: {next_action}",
            "",
            f"TIMESTAMP_UTC: {now}",
            "",
            "EVIDENCE:",
            f"- pr_url: {pr_url or ''}",
            f"- workflow_run_url: {workflow_run_url or ''}",
            "",
        ]),
        encoding="utf-8",
    )

    AUDIT_PATH.write_text(
        "\n".join([
            "# HANDOFF_AUDIT",
            "",
            "SSOT_PATHS:",
            "- mep/run_state.json",
            "- mep/inbox/",
            "- docs/MEP/STATUS.md",
            "",
            "LATEST_EVIDENCE_POINTERS:",
            f"- pr_url: {pr_url or ''}",
            "- commit_sha: ",
            f"- workflow_run_url: {workflow_run_url or ''}",
            "",
        ]),
        encoding="utf-8",
    )

    WORK_PATH.write_text(
        "\n".join([
            "# HANDOFF_WORK",
            "",
            f"NEXT_ACTION: {next_action}",
            f"REASON_CODE: {reason_code}",
            f"STOP_CLASS: {'' if outcome == 'PASS' else outcome}",
            "",
        ]),
        encoding="utf-8",
    )


def write_draft(run_id, issue_body):
    canonical = canonicalize(issue_body)
    INBOX_DIR.mkdir(parents=True, exist_ok=True)
    p = INBOX_DIR / f"draft_{run_id}.md"
    p.write_text(canonical + "\n", encoding="utf-8")


def git_pr_flow(repo, run_id, issue_number):
    branch = f"mep/issueops-run-{run_id.lower()}"
    run(["git", "checkout", "-b", branch])
    run(["git", "add", "mep/inbox", "mep/run_state.json", "docs/MEP/STATUS.md", "docs/MEP/HANDOFF_AUDIT.md", "docs/MEP/HANDOFF_WORK.md"])
    run(["git", "commit", "-m", f"chore(mep): issueops intake {run_id} (issue #{issue_number})"])
    run(["git", "push", "-u", "origin", branch])
    pr = run([
        "gh", "pr", "create",
        "--repo", repo,
        "--base", "main",
        "--head", branch,
        "--title", f"chore(mep): IssueOps intake {run_id}",
        "--body", f"Auto-generated by IssueOps from issue #{issue_number}.\n\n- run_id: {run_id}\n",
    ])
    return pr.stdout.strip(), branch


def post_issue_comment(repo, issue_number, run_id, outcome, reason_code, next_action, pr_url):
    workflow_run_url = f"{os.environ.get('GITHUB_SERVER_URL','https://github.com')}/{repo}/actions/runs/{os.environ.get('GITHUB_RUN_ID','')}"
    body = "\n".join([
        f"RUN_ID={run_id}",
        f"OUTCOME={outcome}",
        f"REASON_CODE={reason_code}",
        f"NEXT_ACTION={next_action}",
        f"PR_URL={pr_url or ''}",
        f"EVIDENCE={workflow_run_url}",
    ])
    run(["gh", "issue", "comment", str(issue_number), "--repo", repo, "--body", body])
    return workflow_run_url


def main():
    repo = os.environ["GITHUB_REPOSITORY"]
    event = load_event()
    issue = event.get("issue", {})
    issue_number = issue.get("number")
    if not issue_number:
        print("No issue context.")
        return 0

    latest_comment_body = fetch_latest_comment(repo, issue_number)
    if not should_run(issue, latest_comment_body):
        print("No /mep run trigger found.")
        return 0

    issue_body = issue.get("body") or ""
    run_id = calc_run_id(canonicalize(issue_body))

    try:
        write_draft(run_id, issue_body)
        workflow_run_url = f"{os.environ.get('GITHUB_SERVER_URL','https://github.com')}/{repo}/actions/runs/{os.environ.get('GITHUB_RUN_ID','')}"
        update_run_state(run_id, "PASS", "ISSUEOPS_BOOTSTRAP_OK", "OPEN_PR", workflow_run_url, None)
        pr_url, _ = git_pr_flow(repo, run_id, issue_number)
        update_run_state(run_id, "PASS", "ISSUEOPS_BOOTSTRAP_OK", "WAIT_PR_CHECKS", workflow_run_url, pr_url)
        run(["git", "add", "mep/run_state.json", "docs/MEP/STATUS.md", "docs/MEP/HANDOFF_AUDIT.md", "docs/MEP/HANDOFF_WORK.md"])
        run(["git", "commit", "-m", f"chore(mep): update issueops evidence {run_id}"])
        run(["git", "push"])
        post_issue_comment(repo, issue_number, run_id, "PASS", "ISSUEOPS_BOOTSTRAP_OK", "WAIT_PR_CHECKS", pr_url)
        return 0
    except Exception as e:
        reason = "STATE_UPDATE_FAILED"
        outcome = "STOP_HARD"
        next_action = "FIX_WORKFLOW_PERMISSIONS"
        try:
            workflow_run_url = f"{os.environ.get('GITHUB_SERVER_URL','https://github.com')}/{repo}/actions/runs/{os.environ.get('GITHUB_RUN_ID','')}"
            update_run_state(run_id, outcome, reason, next_action, workflow_run_url, None)
        except Exception:
            reason = "STATE_UPDATE_FAILED"
        post_issue_comment(repo, issue_number, run_id, outcome, reason, next_action, None)
        print(f"Error: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
