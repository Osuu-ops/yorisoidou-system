#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / "docs" / "MEP"
INP = DOCS / "RUNBOOK.md"
OUT = DOCS / "RUNBOOK_SUMMARY.md"

def read_text(p: Path) -> str:
    if not p.exists():
        return ""
    return p.read_text(encoding="utf-8", errors="replace").replace("\r\n", "\n")

def cards(md: str) -> list[str]:
    xs = []
    for m in re.finditer(r"^##\s+(CARD-[0-9]{2}:[^\n]+)$", md, flags=re.MULTILINE):
        xs.append(m.group(1).strip())
    return xs

def render() -> str:
    md = read_text(INP)
    cs = cards(md)
    lines = []
    lines.append("# RUNBOOK_SUMMARY（復旧サマリ） v1.0")
    lines.append("")
    lines.append("本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。")
    lines.append("生成: docs/MEP/build_runbook_summary.py")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## カード一覧")
    if cs:
        for c in cs:
            lines.append(f"- {c}")
    else:
        lines.append("- （未取得）RUNBOOK.md を確認")
    lines.append("")
    return "\n".join(lines) + "\n"

def main() -> None:
    OUT.write_text(render(), encoding="utf-8", newline="\n")
    print(f"Generated: {OUT}")

if __name__ == "__main__":
    main()
