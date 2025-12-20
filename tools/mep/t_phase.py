# tools/mep/t_phase.py
import json
from datetime import datetime, timezone
from pathlib import Path

STATE_PATH = Path("state/spec_status.json")

def utc_now_iso():
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")

def load_state():
    if not STATE_PATH.exists():
        raise FileNotFoundError(f"Missing: {STATE_PATH}")
    with STATE_PATH.open("r", encoding="utf-8") as f:
        return json.load(f)

def save_state(state):
    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    with STATE_PATH.open("w", encoding="utf-8") as f:
        json.dump(state, f, ensure_ascii=False, indent=2)

def run_T():
    state = load_state()

    # --- 初回T判定（ここが今回の「書く場所」）---
    first_t_done = bool(state.get("first_t_done", False))
    if not first_t_done:
        # 初回Tは必ずNG（Cへ進まない）
        state["first_t_done"] = True
        state.setdefault("recommendation", {})
        state["recommendation"]["notes"] = "initial T completed; result=NG; specs(if any) are dormant"
        state["last_run"] = {"phase": "T", "at": utc_now_iso()}
        save_state(state)
        print("T: initial run -> NG (first_t_done updated).")
        return 1  # 1=NG

    # --- 2回目以降のT（ここは後で拡張）---
    state["last_run"] = {"phase": "T", "at": utc_now_iso()}
    save_state(state)
    print("T: subsequent run -> (placeholder) NG/OK logic to be implemented.")
    return 1  # いまは一旦NG返し（後でOK判定実装）

if __name__ == "__main__":
    exit(run_T())
