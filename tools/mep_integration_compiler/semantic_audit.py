#!/usr/bin/env python3
import sys
import json
from pathlib import Path

# --- 固定定数 ---
REASON_CODES = {
    "NONE",
    "CATEGORY_MISMATCH",
    "PLACEMENT_VIOLATION",
    "Z_MIXED",
    "CONTROL_MIXED",
    "DETECTION_MIXED",
    "EXECUTION_MIXED",
}

CATEGORY_BY_PATH = {
    "foundation": {"Concept", "Detection"},
    "protocol": {"Control", "Detection"},
}

KEYWORDS = {
    "Concept": ["思想", "定義", "原則", "位置づけ", "〜ではない"],
    "Control": ["フェーズ", "遷移", "state-machine", "制御"],
    "Detection": ["検知", "violation", "true", "false"],
    "Execution": ["実行", "手順", "入力", "出力"],
}

FORBIDDEN = {
    "Concept": ["OK", "NG", "遷移", "停止"],
    "Detection": ["遷移", "停止", "判断"],
    "Control": ["思想", "定義"],
    "Execution": ["思想", "Z", "GUARD"],
}

# --- ユーティリティ ---
def detect_category(text: str):
    scores = {k: 0 for k in KEYWORDS}
    for cat, words in KEYWORDS.items():
        for w in words:
            if w in text:
                scores[cat] += 1
    return max(scores, key=scores.get)

def placement_category(path: Path):
    parts = path.parts
    for p in parts:
        if p in CATEGORY_BY_PATH:
            return CATEGORY_BY_PATH[p]
    return {"Concept", "Control", "Detection", "Execution"}

# --- メイン ---
def main():
    if len(sys.argv) != 2:
        sys.exit(1)

    input_list = Path(sys.argv[1]).read_text().splitlines()
    results = []

    for file_path in input_list:
        path = Path(file_path)
        text = path.read_text(encoding="utf-8", errors="ignore")

        category = detect_category(text)
        allowed = placement_category(path)

        result = "OK"
        reason = "NONE"

        if category not in allowed:
            result = "NG"
            reason = "PLACEMENT_VIOLATION"

        for bad in FORBIDDEN.get(category, []):
            if bad in text:
                result = "NG"
                reason = {
                    "Concept": "CONTROL_MIXED",
                    "Detection": "DETECTION_MIXED",
                    "Control": "CATEGORY_MISMATCH",
                    "Execution": "EXECUTION_MIXED",
                }.get(category, "CATEGORY_MISMATCH")
                break

        results.append({
            "file": file_path,
            "category": category,
            "result": result,
            "reason_code": reason,
        })

    summary = {
        "ok": sum(1 for r in results if r["result"] == "OK"),
        "ng": sum(1 for r in results if r["result"] == "NG"),
    }

    print(json.dumps({"results": results, "summary": summary}, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()
