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

    # --- 初回T判定 ---
    first_t_done = bool(state.get("first_t_done", False))

    if not first_t_done:
        # --- dormant ui_spec を生成 ---
        ui_spec_path = Path("spec/ui_spec.md")
        ui_spec_path.parent.mkdir(parents=True, exist_ok=True)

        if not ui_spec_path.exists():
            ui_spec_path.write_text(
                "# UI Spec (dormant)\n\n"
                "## 本書の位置づけ\n"
                "本書は master_spec に基づき T フェーズで自動生成された派生仕様である。\n\n"
                "## 状態\n"
                "- status: dormant\n\n"
                "## 内容\n"
                "(未記入)\n",
                encoding="utf-8"
            )

        # state に登録
        state.setdefault("specs", {})
        state["specs"]["ui_spec.md"] = {
            "state": "dormant",
            "generated_by": "T",
            "path": "spec/ui_spec.md"
        }

        # 初回Tは必ずNG
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
        print("T: initial run -> NG (ui_spec generated as dormant).")
        return 1  # NG

    # --- 2回目以降のT（仮）---
    state["last_run"] = {
        "phase": "T",
        "at": utc_now_iso()
    }
    save_state(state)
    print("T: subsequent run -> NG (placeholder).")
    return 1

if __name__ == "__main__":
    exit(run_T())
