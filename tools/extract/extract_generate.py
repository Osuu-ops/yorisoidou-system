#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
from datetime import datetime, timezone
REPO = Path(__file__).resolve().parents[2]
RUN_STATE = REPO / "mep" / "run_state.json"
OUT_DIR = REPO / "docs" / "MEP" / "EXTRACT"
EXPECTED_FILES = [
  "HEALTH.md",
  "DECISION_LEDGER.md",
  "INPUT_PACKET.md",
  "CARDS.md",
]
def utc_now_z() -> str:
  return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00","Z")
def read_json(p: Path) -> dict:
  return json.loads(p.read_text(encoding="utf-8"))
def write_text(p: Path, s: str, dry: bool):
  if dry:
    return
  p.parent.mkdir(parents=True, exist_ok=True)
  p.write_text(s.rstrip() + "\n", encoding="utf-8")
def stop(code: str, msg: str):
  raise SystemExit(f"STOP_HARD: {code}\n{msg}")
def main():
  ap = argparse.ArgumentParser()
  ap.add_argument("--dry-run", action="store_true")
  args = ap.parse_args()
  if not RUN_STATE.exists():
    stop("RUN_STATE_MISSING", "mep/run_state.json not found")
  rs = {}
  try:
    rs = read_json(RUN_STATE)
  except Exception as e:
    stop("RUN_STATE_INVALID_JSON", str(e))
  run_id = (rs.get("run_id") or "").strip()
  next_action = (rs.get("next_action") or "").strip()
  lr = rs.get("last_result") or {}
  stop_class = (lr.get("stop_class") or "").strip()
  reason_code = (lr.get("reason_code") or "").strip()
  ev = (lr.get("evidence") or {})
  gen = utc_now_z()
  base = f"""# EXTRACT_HEALTH
generated_at_utc: {gen}
run_id: {run_id or "RUN_UNSET"}
next_action: {next_action or "UNSET"}
stop_class: {stop_class or "NONE"}
reason_code: {reason_code or "NONE"}
EVIDENCE:
- pr_url: {ev.get("pr_url","") or ""}
- workflow_run_url: {ev.get("workflow_run_url","") or ""}
- commit_sha: {ev.get("commit_sha","") or ""}
"""
  ledger = f"""# DECISION_LEDGER (EXTRACT)
generated_at_utc: {gen}
This is a machine-generated extract (B-3).
Source SSOT:
- mep/run_state.json
DECISIONS:
- next_action: {next_action or "UNSET"}
- stop: {stop_class or "NONE"} / {reason_code or "NONE"}
"""
  pkt = f"""# INPUT_PACKET (EXTRACT)
generated_at_utc: {gen}
SSOT_PATHS:
- mep/boot_spec.yaml
- mep/policy.yaml
- mep/run_state.json
RUN_ID: {run_id or "RUN_UNSET"}
NEXT_ACTION: {next_action or "UNSET"}
"""
  cards = f"""# CARDS (EXTRACT INDEX)
generated_at_utc: {gen}
- CARD: HEALTH -> docs/MEP/EXTRACT/HEALTH.md
- CARD: DECISION_LEDGER -> docs/MEP/EXTRACT/DECISION_LEDGER.md
- CARD: INPUT_PACKET -> docs/MEP/EXTRACT/INPUT_PACKET.md
- CARD: CARDS -> docs/MEP/EXTRACT/CARDS.md
"""
  write_text(OUT_DIR / "HEALTH.md", base, args.dry_run)
  write_text(OUT_DIR / "DECISION_LEDGER.md", ledger, args.dry_run)
  write_text(OUT_DIR / "INPUT_PACKET.md", pkt, args.dry_run)
  write_text(OUT_DIR / "CARDS.md", cards, args.dry_run)
  payload = {
    "generated_at_utc": gen,
    "mode": "dry-run" if args.dry_run else "write",
    "run_state_path": RUN_STATE.as_posix().replace(REPO.as_posix() + "/", ""),
    "out_dir": OUT_DIR.as_posix().replace(REPO.as_posix() + "/", ""),
    "files": [str((OUT_DIR / name).as_posix().replace(REPO.as_posix() + "/", "")) for name in EXPECTED_FILES],
  }
  print(json.dumps(payload, ensure_ascii=False))
  print("EXTRACT_GENERATE_OK")
  return 0
if __name__ == "__main__":
  raise SystemExit(main())
