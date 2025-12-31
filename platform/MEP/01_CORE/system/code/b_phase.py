# 参照定義ファイル：
# MEP/definitions/SYMBOLS.md
#
# 本ファイル内に出現する参照記号は、
# 個別宣言や列挙を行わず、
# 上記参照定義ファイルを唯一の正として解決する。
#
# 本ファイルは参照関係の宣言・管理を行わない。



# tools/mep/b_phase.py
import json
from datetime import datetime, timezone
from pathlib import Path
import sys

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

def run_B():
    if len(sys.argv) < 2:
        print("B: no spec specified (usage: python tools/mep/b_phase.py ui_spec.md)")
        return 1

    target_spec = sys.argv[1]
    state = load_state()

    specs = state.get("specs", {})
    if target_spec not in specs:
        print(f"B: spec not found: {target_spec}")
        return 1

    if specs[target_spec]["state"] == "active":
        print(f"B: spec already active: {target_spec}")
        return 0

    # dormant -> active
    specs[target_spec]["state"] = "active"
    state.setdefault("active_specs", [])
    if target_spec not in state["active_specs"]:
        state["active_specs"].append(target_spec)

    state["last_run"] = {
        "phase": "B",
        "at": utc_now_iso()
    }

    save_state(state)
    print(f"B: spec activated -> {target_spec}")
    return 0

if __name__ == "__main__":
    exit(run_B())
