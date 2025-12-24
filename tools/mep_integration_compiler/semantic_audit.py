#!/usr/bin/env python3
import sys
import json
from pathlib import Path

FORBIDDEN_CONCEPT_WORDS = [
    "OK",
    "NG",
    "停止",
    "遷移",
]

def main():
    if len(sys.argv) != 2:
        print(json.dumps({"results": [], "summary": {"ok": 0, "ng": 0}}))
        return

    input_list = Path(sys.argv[1]).read_text(encoding="utf-8").splitlines()
    results = []

    for file_path in input_list:
        path = Path(file_path)
        text = path.read_text(encoding="utf-8", errors="ignore")

        result = "OK"
        reason = "NONE"

        # Concept 判定（簡易：foundation/Z 系は Concept 扱い）
        if "Z_AXIOMS_CANON.md" in file_path:
            for w in FORBIDDEN_CONCEPT_WORDS:
                if w in text:
                    result = "NG"
                    reason = "CONTROL_MIXED"
                    break

        results.append({
            "file": file_path,
            "category": "Concept" if "Z_AXIOMS_CANON.md" in file_path else "Other",
            "result": result,
            "reason_code": reason
        })

    summary = {
        "ok": sum(1 for r in results if r["result"] == "OK"),
        "ng": sum(1 for r in results if r["result"] == "NG"),
    }

    print(json.dumps({"results": results, "summary": summary}, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()
