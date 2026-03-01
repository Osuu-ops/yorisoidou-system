#!/usr/bin/env python3
import json
import os
import subprocess
import sys
from pathlib import Path
REPO = Path(__file__).resolve().parents[2]
RUN_STATE = REPO / "mep" / "run_state.json"
RUNNER = REPO / "tools" / "runner" / "runner.py"
def stop_wait(code: str, msg: str):
  print(f"STOP_WAIT: {code}\n{msg}", file=sys.stderr)
  return 2
def stop_hard(code: str, msg: str):
  print(f"STOP_HARD: {code}\n{msg}", file=sys.stderr)
  return 1
def _run(cmd: list[str]) -> int:
  p = subprocess.run(cmd, text=True, encoding="utf-8", errors="replace")
  return p.returncode
def main() -> int:
  if not RUN_STATE.exists():
    return stop_hard("RUN_STATE_MISSING", "mep/run_state.json not found")
  try:
    rs = json.loads(RUN_STATE.read_text(encoding="utf-8"))
  except Exception as e:
    return stop_hard("RUN_STATE_INVALID_JSON", str(e))
  run_id = str(rs.get("run_id") or "").strip()
  next_action = str(rs.get("next_action") or "").strip()
  lr = rs.get("last_result") or {}
  stop_class = str(lr.get("stop_class") or "").strip()
  reason_code = str(lr.get("reason_code") or "").strip()
  if not next_action:
    return stop_hard("NEXT_ACTION_MISSING", "run_state.next_action is empty")
  # map next_action -> runner command
  # NOTE: conservative mapping. Unknown -> WAIT (human decision)
  cmd = None
  # Typical flow points
  if next_action in {"WAIT_PR_CHECKS", "WAIT_FOR_CHECKS", "WAIT_FOR_MERGE", "WAIT_PR_MERGE"}:
    if not run_id:
      return stop_wait("RUN_ID_MISSING", f"next_action={next_action} requires run_id")
    cmd = ["python", str(RUNNER), "merge-finish", "--run-id", run_id]
  elif next_action in {"CREATE_PR_FOR_RUN", "OPEN_NEW_PR_FOR_RUN"}:
    if not run_id:
      return stop_wait("RUN_ID_MISSING", f"next_action={next_action} requires run_id")
    cmd = ["python", str(RUNNER), "pr-create", "--run-id", run_id]
  elif next_action in {"READY_TO_APPLY_SAFE_PATH"}:
    if not run_id:
      return stop_wait("RUN_ID_MISSING", f"next_action={next_action} requires run_id")
    cmd = ["python", str(RUNNER), "apply-safe", "--run-id", run_id]
  elif next_action in {"STATUS", "BOOT"}:
    cmd = ["python", str(RUNNER), "status"]
  elif next_action in {"ALL_DONE"}:
    cmd = ["python", str(RUNNER), "compact"]
  else:
    return stop_wait("UNKNOWN_NEXT_ACTION", f"next_action={next_action} stop_class={stop_class} reason_code={reason_code}")
  # pass GH_REPO if present in run_state
  gh_repo = (rs.get("gh_repo") or rs.get("repo") or os.environ.get("GH_REPO") or "").strip()
  env = dict(os.environ)
  if gh_repo:
    env["GH_REPO"] = gh_repo
  print("AUTO_RESUME:", " ".join(cmd))
  p = subprocess.run(cmd, env=env, text=True, encoding="utf-8", errors="replace")
  return p.returncode
if __name__ == "__main__":
  raise SystemExit(main())
