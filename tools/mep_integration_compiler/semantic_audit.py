#!/usr/bin/env python3
import sys
import json
from pathlib import Path

# Concept文書で禁止する語（確実にNGを出す）
FORBIDDEN_CONCEPT_WORDS = [
    "OK",
    "NG",
    "停止",
    "遷移",
]

def is_concept(path: str) -> bool:
    return path.endswith("Z_AXIOMS_CANON.md")

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
        category = "Other"

        if is_concept(file_path):
            category = "Concept"
            for w in FORBIDDEN_CONCEPT_WORDS:
                if w in text:
                    result = "NG"
                    reason = "CONTROL_MIXED"
                    break

        results.append({
            "file": file_path,
            "category": category,
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
