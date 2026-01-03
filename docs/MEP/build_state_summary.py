#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / "docs" / "MEP"

STATE_CURRENT = DOCS / "STATE_CURRENT.md"
INDEX = DOCS / "INDEX.md"
RUNBOOK = DOCS / "RUNBOOK.md"
PLAYBOOK = DOCS / "PLAYBOOK.md"
CONTRACT = DOCS / "AI_OUTPUT_CONTRACT_POWERSHELL.md"
UPGRADE_GATE = DOCS / "UPGRADE_GATE.md"
OUT = DOCS / "STATE_SUMMARY.md"


def read_text(p: Path) -> str:
    if not p.exists():
        return ""
    return p.read_text(encoding="utf-8", errors="replace").replace("\r\n", "\n")


def h1_h2(md: str) -> list[str]:
    out: list[str] = []
    for ln in md.splitlines():
        if ln.startswith("# "):
            out.append(ln[2:].strip())
        elif ln.startswith("## "):
            out.append(ln[3:].strip())
    seen = set()
    uniq = []
    for x in out:
        if x not in seen:
            seen.add(x)
            uniq.append(x)
    return uniq


def cards(md: str) -> list[str]:
    xs = []
    for m in re.finditer(r"^##\s+(CARD-[0-9]{2}:[^\n]+)$", md, flags=re.MULTILINE):
        xs.append(m.group(1).strip())
    return xs


def first_para_under_heading(md: str, heading_prefix: str) -> str:
    lines = md.splitlines()
    idx = None
    for i, ln in enumerate(lines):
        if ln.startswith("## ") and ln[3:].strip().startswith(heading_prefix):
            idx = i
            break
    if idx is None:
        return ""
    buf = []
    for ln in lines[idx + 1:]:
        if ln.strip() == "":
            if buf:
                break
            continue
        if ln.startswith("#"):
            break
        buf.append(ln.rstrip())
    return "\n".join(buf).strip()


def render() -> str:
    state_md = read_text(STATE_CURRENT)
    index_md = read_text(INDEX)
    run_md = read_text(RUNBOOK)
    play_md = read_text(PLAYBOOK)

    purpose = first_para_under_heading(state_md, "目的（不変）") or first_para_under_heading(state_md, "目的")
    state_heads = h1_h2(state_md)
    index_heads = h1_h2(index_md)
    run_cards = cards(run_md)
    play_cards = cards(play_md)

    lines: list[str] = []
    lines.append("# STATE_SUMMARY（現在地サマリ） v1.1")
    lines.append("")
    lines.append("本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。")
    lines.append("本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。")
    lines.append("生成: docs/MEP/build_state_summary.py")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Start Pack（新チャット開始入力：最小）")
    lines.append("- まず本書（STATE_SUMMARY.md）だけを貼って開始する。")
    lines.append("- 追加が必要な場合のみ、AIは REQUEST 形式（最大3件）で要求する。")
    lines.append("- 原則の追加入力は次の順：CHAT_PACKET → STATE_CURRENT → PLAYBOOK/RUNBOOK。")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Upgrade Gate（開始直後に必ず実施する固定ゲート）")
    lines.append("- AIは着手前に必ず実施：矛盾検出 → 観測コマンド提示 → 次の一手カード確定。")
    lines.append("- 仕様（唯一の正）：docs/MEP/UPGRADE_GATE.md（存在しない場合は作成PRを起案）。")
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
    lines.append("- CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）")
    lines.append("- 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）")
    lines.append("- 次の指示: docs/MEP/PLAYBOOK.md")
    lines.append("- 復旧: docs/MEP/RUNBOOK.md")
    lines.append("- 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）")
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
    lines.append("## STATE_CURRENT の主要見出し")
    if state_heads:
        for h in state_heads[:40]:
            lines.append(f"- {h}")
    else:
        lines.append("- （未取得）STATE_CURRENT.md を確認")
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
    return "\n".join(lines) + "\n"


def main() -> None:
    OUT.write_text(render(), encoding="utf-8", newline="\n")
    print(f"Generated: {OUT}")


if __name__ == "__main__":
    main()
