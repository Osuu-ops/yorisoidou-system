#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations
from pathlib import Path
import hashlib
import re

ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / "docs" / "MEP"
VAULT = DOCS / "IDEA_VAULT.md"
OUT = DOCS / "IDEA_INDEX.md"

MAX_LIST = 50

def read_text(p: Path) -> str:
    if not p.exists():
        return ""
    return p.read_text(encoding="utf-8", errors="replace").replace("\r\n", "\n")

def one_line(s: str, limit: int = 90) -> str:
    s = re.sub(r"\s+", " ", s.strip())
    if len(s) > limit:
        return s[:limit-1] + "…"
    return s

def parse_active(md: str) -> list[dict]:
    m = re.search(r"(?s)^##\s+ACTIVE.*?(?=^##\s+ARCHIVE|\Z)", md, flags=re.MULTILINE)
    if not m:
        return []
    active = m.group(0)

    blocks = re.findall(r"(?s)(^###\s+IDEA_ID:.*?)(?=^###\s+IDEA_ID:|\Z)", active, flags=re.MULTILINE)
    out = []
    for b in blocks:
        idm = re.search(r"(?m)^###\s+IDEA_ID:\s*(IDEA:[0-9a-fA-F]{12}|IDEA:[^\s]+)\s*$", b)
        idea_id = idm.group(1).strip() if idm else "IDEA:UNKNOWN"

        titlem = re.search(r"(?m)^\-\s*TITLE:\s*(.+)\s*$", b)
        title = titlem.group(1).strip() if titlem else "(no title)"

        descm = re.search(r"(?m)^\-\s*DESC:\s*(.+)\s*$", b)
        if descm:
            desc = descm.group(1).strip()
        else:
            # fallback: first BODY bullet line
            bodym = re.search(r"(?m)^\-\s*BODY:\s*$([\s\S]+)", b)
            desc = ""
            if bodym:
                for ln in bodym.group(1).splitlines():
                    ln = ln.strip()
                    if ln.startswith("-"):
                        desc = ln.lstrip("-").strip()
                        break
            desc = desc or title

        out.append({"id": idea_id, "title": title, "desc": one_line(desc)})
    return out

def main() -> None:
    md = read_text(VAULT)
    items = parse_active(md)[:MAX_LIST]

    lines = []
    lines.append("# IDEA_INDEX（統合用：番号で選ぶ一覧） v1.0")
    lines.append("")
    lines.append("本書は IDEA_VAULT（ACTIVE）から生成される一覧である。")
    lines.append("統合時は番号（1,2,3...）で指定する。内部IDは表示するが、指定には使わない。")
    lines.append("生成: docs/MEP/build_idea_index.py")
    lines.append("")
    lines.append("---")
    lines.append("")
    if not items:
        lines.append("（ACTIVEに候補なし）")
    else:
        for i, it in enumerate(items, start=1):
            lines.append(f"{i}. {it['desc']}  [{it['id']}]")
    lines.append("")
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print(f"Generated: {OUT}")

if __name__ == "__main__":
    main()
