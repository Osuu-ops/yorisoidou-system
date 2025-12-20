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

    first_t_done = bool(state.get("first_t_done", False))
    specs = state.get("specs", {})
    active_specs = state.get("active_specs", [])

    # --- 初回T：必ずNG（dormant生成のみ想定）---
    if not first_t_done:
        state["first_t_done"] = True
        state.setdefault("recommendation", {})
        state["recommendation"]["notes"] = (
            "initial T completed; result=NG; specs(if any) are dormant"
        )
        state["last_run"] = {
            "phase": "T",
            "at": utc_now_iso()
        }
        save_state(state)
        print("T: initial run -> NG")
        return 1

    # --- 2回目以降のT：active spec 前提で判定 ---
    if not active_specs:
        state.setdefault("recommendation", {})
        state["recommendation"]["notes"] = (
            "no active specs; result=NG"
        )
        state["last_run"] = {
            "phase": "T",
            "at": utc_now_iso()
        }
        save_state(state)
        print("T: NG (no active specs)")
        return 1

    # active spec がすべて state=active か確認
    for spec_name in active_specs:
        spec_info = specs.get(spec_name)
        if not spec_info or spec_info.get("state") != "active":
            state.setdefault("recommendation", {})
            state["recommendation"]["notes"] = (
                f"spec not active or missing: {spec_name}; result=NG"
            )
            state["last_run"] = {
                "phase": "T",
                "at": utc_now_iso()
            }
            save_state(state)
            print(f"T: NG (spec not active: {spec_name})")
            return 1

    # --- ここまで来たらOK ---
    state.setdefault("recommendation", {})
    state["recommendation"]["notes"] = (
        "all active specs valid; result=OK"
    )
    state["last_run"] = {
        "phase": "T",
        "at": utc_now_iso()
    }
    save_state(state)
    print("T: OK (ready for C)")
    return 0

if __name__ == "__main__":
    exit(run_T())
