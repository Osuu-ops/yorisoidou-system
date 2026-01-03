#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / "docs" / "MEP"

STATE_SUMMARY = DOCS / "STATE_SUMMARY.md"
PLAYBOOK_SUMMARY = DOCS / "PLAYBOOK_SUMMARY.md"
RUNBOOK_SUMMARY = DOCS / "RUNBOOK_SUMMARY.md"
UPGRADE_GATE = DOCS / "UPGRADE_GATE.md"
CONTRACT = DOCS / "AI_OUTPUT_CONTRACT_POWERSHELL.md"
OUT = DOCS / "HANDOFF_100.md"


def read_text(p: Path) -> str:
    if not p.exists():
        return ""
    return p.read_text(encoding="utf-8", errors="replace").replace("\r\n", "\n").strip()


def main() -> None:
    lines: list[str] = []
    lines.append("# HANDOFF_100（引継ぎ100点・新チャット1通目に貼る1枚） v1.0")
    lines.append("")
    lines.append("本書は、MEP運用の「唯一の正（docs/MEP）」から生成された引継ぎ文である。")
    lines.append("新チャット開始は原則として本書 1枚だけを貼る。")
    lines.append("")
    lines.append("## ルール（最優先）")
    lines.append("- 開始直後に UPGRADE_GATE を必ず適用（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）")
    lines.append("- 追加情報が必要な場合のみ REQUEST 形式（最大3件）で要求")
    lines.append("- AI出力は PowerShell単一コピペ一本道（ID手入力禁止、ghで自動解決）")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Start（貼る順序）")
    lines.append("- この HANDOFF_100 を貼る（= これ1枚）")
    lines.append("- それでも足りない場合のみ、次を貼る：REQUEST_BUNDLE_SYSTEM または REQUEST_BUNDLE_BUSINESS")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## 現在地（STATE_SUMMARY）")
    lines.append(read_text(STATE_SUMMARY) or "- （未生成）STATE_SUMMARY.md を確認")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## 次の一手（PLAYBOOK_SUMMARY）")
    lines.append(read_text(PLAYBOOK_SUMMARY) or "- （未生成）PLAYBOOK_SUMMARY.md を確認")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## 異常時（RUNBOOK_SUMMARY）")
    lines.append(read_text(RUNBOOK_SUMMARY) or "- （未生成）RUNBOOK_SUMMARY.md を確認")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## 参照（唯一の正）")
    lines.append("- docs/MEP/UPGRADE_GATE.md")
    lines.append("- docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md")
    lines.append("- docs/MEP/STATE_CURRENT.md / PLAYBOOK.md / RUNBOOK.md / INDEX.md")
    lines.append("")
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print(f"Generated: {OUT}")


if __name__ == "__main__":
    main()
