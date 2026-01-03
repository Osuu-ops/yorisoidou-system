#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]  # repo root
DOCS = ROOT / "docs" / "MEP"

STATE_CURRENT = DOCS / "STATE_CURRENT.md"
INDEX = DOCS / "INDEX.md"
RUNBOOK = DOCS / "RUNBOOK.md"
PLAYBOOK = DOCS / "PLAYBOOK.md"
CONTRACT = DOCS / "AI_OUTPUT_CONTRACT_POWERSHELL.md"
OUT = DOCS / "STATE_SUMMARY.md"


def read_text(p: Path) -> str:
    if not p.exists():
        return ""
    return p.read_text(encoding="utf-8", errors="replace").replace("\r\n", "\n")


def extract_top_headings(md: str) -> list[str]:
    # Capture H1/H2 headings only, ignore code fences (we avoid them in these docs anyway).
    lines = md.splitlines()
    out: list[str] = []
    for ln in lines:
        if ln.startswith("# "):
            out.append(ln[2:].strip())
        elif ln.startswith("## "):
            out.append(ln[3:].strip())
    # Deduplicate while preserving order
    seen = set()
    uniq = []
    for h in out:
        if h not in seen:
            seen.add(h)
            uniq.append(h)
    return uniq


def extract_cards(md: str) -> list[str]:
    # Cards are headings like "## CARD-xx: ..."
    cards = []
    for m in re.finditer(r"^##\s+(CARD-[0-9]{2}:[^\n]+)$", md, flags=re.MULTILINE):
        cards.append(m.group(1).strip())
    return cards


def extract_first_paragraph_under_heading(md: str, heading_prefix: str) -> str:
    # Find a heading that starts with heading_prefix (e.g., "目的")
    # Return the first non-empty paragraph after it (up to blank line).
    lines = md.splitlines()
    idx = None
    for i, ln in enumerate(lines):
        if ln.startswith("## ") and ln[3:].strip().startswith(heading_prefix):
            idx = i
            break
    if idx is None:
        return ""
    # Collect paragraph
    para = []
    for ln in lines[idx + 1:]:
        if ln.strip() == "":
            if para:
                break
            continue
        if ln.startswith("#"):
            break
        para.append(ln.rstrip())
    return "\n".join(para).strip()


def render() -> str:
    state_md = read_text(STATE_CURRENT)
    index_md = read_text(INDEX)
    runbook_md = read_text(RUNBOOK)
    playbook_md = read_text(PLAYBOOK)

    purpose = extract_first_paragraph_under_heading(state_md, "目的")
    state_heads = extract_top_headings(state_md)
    index_heads = extract_top_headings(index_md)
    run_cards = extract_cards(runbook_md)
    play_cards = extract_cards(playbook_md)

    lines: list[str] = []
    lines.append("# STATE_SUMMARY（現在地サマリ） v1.0")
    lines.append("")
    lines.append("本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。")
    lines.append("本書は **時刻やランID等を含めず**、入力が変わらない限り差分が出ないことを前提とする。")
    lines.append("生成: `docs/MEP/build_state_summary.py`")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## 目的（STATE_CURRENTから要約）")
    if purpose:
        lines.append(purpose)
    else:
        lines.append("- （未取得）STATE_CURRENT.md の「目的」節を確認")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## 参照導線（固定）")
    lines.append("- CHAT_PACKET: `docs/MEP/CHAT_PACKET.md`（新チャット開始入力）")
    lines.append("- 現在地: `docs/MEP/STATE_CURRENT.md`（唯一の現在地）")
    lines.append("- 次の指示: `docs/MEP/PLAYBOOK.md`")
    lines.append("- 復旧: `docs/MEP/RUNBOOK.md`")
    lines.append("- 出力契約: `docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md`（PowerShell単一コピペ一本道）")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## STATE_CURRENT の主要見出し")
    if state_heads:
        for h in state_heads[:40]:
            lines.append(f"- {h}")
    else:
        lines.append("- （未取得）STATE_CURRENT.md を確認")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## PLAYBOOK カード一覧")
    if play_cards:
        for c in play_cards:
            lines.append(f"- {c}")
    else:
        lines.append("- （未取得）PLAYBOOK.md を確認")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## RUNBOOK カード一覧")
    if run_cards:
        for c in run_cards:
            lines.append(f"- {c}")
    else:
        lines.append("- （未取得）RUNBOOK.md を確認")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## INDEX の主要見出し")
    if index_heads:
        for h in index_heads[:40]:
            lines.append(f"- {h}")
    else:
        lines.append("- （未取得）INDEX.md を確認")
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    out = render()
    OUT.write_text(out, encoding="utf-8", newline="\n")
    print(f"Generated: {OUT}")


if __name__ == "__main__":
    main()
