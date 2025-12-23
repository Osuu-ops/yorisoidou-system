# 参照定義ファイル：
# MEP/definitions/SYMBOLS.md
#
# 本ファイル内に出現する参照記号は、
# 個別宣言や列挙を行わず、
# 上記参照定義ファイルを唯一の正として解決する。
#
# 本ファイルは参照関係の宣言・管理を行わない。



# tools/mep/c_phase.py
import json
from pathlib import Path
from datetime import datetime, timezone

STATE_PATH = Path("state/spec_status.json")
OUTPUT_DIR = Path("generated")

def utc_now_iso():
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")

def load_state():
    if not STATE_PATH.exists():
        raise FileNotFoundError(f"Missing: {STATE_PATH}")
    with STATE_PATH.open("r", encoding="utf-8") as f:
        return json.load(f)

def run_C():
    state = load_state()

    active_specs = state.get("active_specs", [])
    specs = state.get("specs", {})

    if not active_specs:
        print("C: no active specs -> abort")
        return 1

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # 検証用：active spec 一覧を書き出す
    output_path = OUTPUT_DIR / "generation_result.txt"
    with output_path.open("w", encoding="utf-8") as f:
        f.write("C PHASE GENERATION RESULT\n")
        f.write(f"generated_at: {utc_now_iso()}\n\n")
        f.write("ACTIVE SPECS:\n")
        for spec_name in active_specs:
            spec_info = specs.get(spec_name, {})
            f.write(f"- {spec_name} ({spec_info.get('path')})\n")

    state["last_run"] = {
        "phase": "C",
        "at": utc_now_iso()
    }

    with STATE_PATH.open("w", encoding="utf-8") as f:
        json.dump(state, f, ensure_ascii=False, indent=2)

    print(f"C: generation completed -> {output_path}")
    return 0

if __name__ == "__main__":
    exit(run_C())
