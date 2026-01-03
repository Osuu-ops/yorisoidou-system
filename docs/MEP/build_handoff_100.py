#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations
from pathlib import Path
import hashlib
import re

ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / "docs" / "MEP"

STATE_SUMMARY = DOCS / "STATE_SUMMARY.md"
PLAYBOOK_SUMMARY = DOCS / "PLAYBOOK_SUMMARY.md"
RUNBOOK_SUMMARY = DOCS / "RUNBOOK_SUMMARY.md"

OUT = DOCS / "HANDOFF_100.md"

MAX_ARCHIVE_ENTRIES = 10

CURRENT_BEGIN = "<!-- HANDOFF_CURRENT_BEGIN -->"
CURRENT_END = "<!-- HANDOFF_CURRENT_END -->"
ARCHIVE_BEGIN = "<!-- HANDOFF_ARCHIVE_BEGIN -->"
ARCHIVE_END = "<!-- HANDOFF_ARCHIVE_END -->"


def read_text(p: Path) -> str:
    if not p.exists():
        return ""
    return p.read_text(encoding="utf-8", errors="replace").replace("\r\n", "\n")


def sha256_hex(s: str) -> str:
    return hashlib.sha256(s.encode("utf-8")).hexdigest()


def hof_id_from_current_body(current_body: str) -> str:
    # Stable ID: hash of CURRENT body (excluding ID line)
    h = sha256_hex(current_body)
    return "HOF:" + h[:12]


def extract_block(text: str, begin: str, end: str) -> str | None:
    m = re.search(re.escape(begin) + r"(.*?)" + re.escape(end), text, flags=re.DOTALL)
    if not m:
        return None
    return m.group(1)


def set_block(text: str, begin: str, end: str, body: str) -> str:
    pat = re.escape(begin) + r".*?" + re.escape(end)
    repl = begin + "\n" + body.rstrip("\n") + "\n" + end
    if re.search(pat, text, flags=re.DOTALL):
        return re.sub(pat, repl, text, flags=re.DOTALL)
    if not text.endswith("\n"):
        text += "\n"
    return text + "\n" + repl + "\n"


def compact_lines(md: str, max_lines: int = 18) -> str:
    # Compact preview for overview (deterministic)
    out = []
    for ln in md.splitlines():
        ln2 = ln.rstrip()
        if not ln2:
            continue
        out.append(ln2)
        if len(out) >= max_lines:
            break
    return "\n".join(out)


def render_current_body_without_meta() -> str:
    state = read_text(STATE_SUMMARY).strip()
    pb = read_text(PLAYBOOK_SUMMARY).strip()
    rb = read_text(RUNBOOK_SUMMARY).strip()

    # Overview is compact, the rest can stay detailed enough to be self-sufficient.
    ov_state = compact_lines(state, 14) if state else "- （未生成）STATE_SUMMARY.md を確認"
    ov_pb = compact_lines(pb, 12) if pb else "- （未生成）PLAYBOOK_SUMMARY.md を確認"
    ov_rb = compact_lines(rb, 12) if rb else "- （未生成）RUNBOOK_SUMMARY.md を確認"

    lines: list[str] = []
    lines.append("# HANDOFF_100（引継ぎ100点・新チャット1通目に貼る1枚）")
    lines.append("")
    lines.append("## CURRENT（貼るのはここだけ）")
    lines.append("")
    lines.append("新チャット1通目は **この CURRENT ブロックだけ**を貼る。")
    lines.append("追加が必要と言われた場合のみ `REQUEST_BUNDLE_SYSTEM` または `REQUEST_BUNDLE_BUSINESS` を貼る。")
    lines.append("")
    lines.append("### ルール（最優先）")
    lines.append("- 開始直後に UPGRADE_GATE を必ず適用（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）")
    lines.append("- 追加情報が必要な場合のみ REQUEST 形式（最大3件）で要求")
    lines.append("- AI出力は PowerShell単一コピペ一本道（ID手入力禁止、ghで自動解決）")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("### HANDOFF_OVERVIEW（概要：貼った瞬間に前提が分かる）")
    lines.append("（このブロックは要点。詳細は下の各SUMMARY／束を参照。）")
    lines.append("")
    lines.append("■ 現在地（STATE_SUMMARY 抜粋）")
    lines.append(ov_state)
    lines.append("")
    lines.append("■ 次の一手（PLAYBOOK_SUMMARY 抜粋）")
    lines.append(ov_pb)
    lines.append("")
    lines.append("■ 異常時（RUNBOOK_SUMMARY 抜粋）")
    lines.append(ov_rb)
    lines.append("")
    lines.append("■ 追加束（必要な場合のみ）")
    lines.append("- docs/MEP/REQUEST_BUNDLE_SYSTEM.md")
    lines.append("- docs/MEP/REQUEST_BUNDLE_BUSINESS.md")
    lines.append("")
    lines.append("■ 参照（唯一の正）")
    lines.append("- docs/MEP/UPGRADE_GATE.md")
    lines.append("- docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md")
    lines.append("- docs/MEP/STATE_CURRENT.md / PLAYBOOK.md / RUNBOOK.md / INDEX.md")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("### 現在地（STATE_SUMMARY全文）")
    lines.append(state if state else "- （未生成）STATE_SUMMARY.md を確認")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("### 次の一手（PLAYBOOK_SUMMARY全文）")
    lines.append(pb if pb else "- （未生成）PLAYBOOK_SUMMARY.md を確認")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("### 異常時（RUNBOOK_SUMMARY全文）")
    lines.append(rb if rb else "- （未生成）RUNBOOK_SUMMARY.md を確認")
    lines.append("")
    return "\n".join(lines) + "\n"


def render_current_with_id() -> str:
    # Build body first, then compute ID, then prepend stable meta lines
    body = render_current_body_without_meta()
    hid = hof_id_from_current_body(body)

    meta = []
    meta.append(f"HANDOFF_ID: {hid}")
meta.append("HANDOFF_TRIGGER: ユーザーが『引継ぎ』と言ったら、AIは次の1行だけを返す（説明なし）： .\\tools\\mep_handoff.ps1")
meta.append("HANDOFF_TRIGGER_BUNDLE: 追加が必要なら次の1行だけを返す： Get-Content docs/MEP/REQUEST_BUNDLE_SYSTEM.md -Raw -Encoding UTF8  /  Get-Content docs/MEP/REQUEST_BUNDLE_BUSINESS.md -Raw -Encoding UTF8")
    meta.append("CONTINUE_TARGET: (AUTO) 旧チャットの続きは「open PR / 直近の失敗チェック / PLAYBOOK次の一手」で確定する。")
    meta.append("NOTE: IDだけ貼る場合は、この3行（HANDOFF_ID/CONTINUE_TARGET/概要）を一緒に貼ると前提が即時共有できる。")
    meta.append("")
    return "\n".join(meta) + body


def render_archive_entry(prev_current: str) -> str:
    h = sha256_hex(prev_current)
    lines: list[str] = []
    lines.append(f"### ARCHIVE_ENTRY sha256:{h}")
    lines.append("")
    lines.append("（過去のCURRENTスナップショット。通常は貼らない。）")
    lines.append("")
    for ln in prev_current.strip().splitlines():
        lines.append("> " + ln)
    lines.append("")
    return "\n".join(lines)


def trim_archive(archive_body: str) -> str:
    parts = re.split(r"(?m)^### ARCHIVE_ENTRY sha256:", archive_body)
    if len(parts) <= 1:
        return archive_body.strip() + "\n" if archive_body.strip() else ""
    head = parts[0]
    entries = ["### ARCHIVE_ENTRY sha256:" + p for p in parts[1:]]
    entries = [e.strip() for e in entries if e.strip()]
    if len(entries) > MAX_ARCHIVE_ENTRIES:
        entries = entries[:MAX_ARCHIVE_ENTRIES]
    out = (head.strip() + "\n\n" if head.strip() else "") + "\n\n".join(entries) + "\n"
    return out


def main() -> None:
    existing = read_text(OUT)
    new_current = render_current_with_id()

    # ensure markers exist
    if CURRENT_BEGIN not in existing or CURRENT_END not in existing or ARCHIVE_BEGIN not in existing or ARCHIVE_END not in existing:
        skeleton = ""
        skeleton = set_block(skeleton, CURRENT_BEGIN, CURRENT_END, new_current)
        skeleton = set_block(skeleton, ARCHIVE_BEGIN, ARCHIVE_END, "（ARCHIVEは自動生成。通常は参照しない。）\n")
        OUT.write_text(skeleton, encoding="utf-8", newline="\n")
        print(f"Generated (fresh markers): {OUT}")
        return

    prev_current = extract_block(existing, CURRENT_BEGIN, CURRENT_END) or ""
    archive_body = extract_block(existing, ARCHIVE_BEGIN, ARCHIVE_END) or ""

    # If current changed, append previous snapshot to archive
    if prev_current.strip() and sha256_hex(prev_current) != sha256_hex(new_current):
        entry = render_archive_entry(prev_current)
        archive_body = entry + "\n\n" + archive_body

    archive_body = trim_archive(archive_body)

    out = existing
    out = set_block(out, CURRENT_BEGIN, CURRENT_END, new_current)
    out = set_block(out, ARCHIVE_BEGIN, ARCHIVE_END, archive_body)

    OUT.write_text(out, encoding="utf-8", newline="\n")
    print(f"Generated: {OUT}")


if __name__ == "__main__":
    main()

