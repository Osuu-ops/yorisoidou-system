#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations
from pathlib import Path
import hashlib
import fnmatch

ROOT = Path(__file__).resolve().parents[2]
REPO = ROOT
DOCS = ROOT / "docs" / "MEP"

SYS_LIST = DOCS / "request_bundle_sources_system.txt"
BIZ_LIST = DOCS / "request_bundle_sources_business.txt"

OUT_SYS = DOCS / "REQUEST_BUNDLE_SYSTEM.md"
OUT_BIZ = DOCS / "REQUEST_BUNDLE_BUSINESS.md"

# Safety caps (deterministic)
MAX_FILES = 300
MAX_TOTAL_BYTES = 2_000_000          # per bundle (raw bytes, before markdown framing)
MAX_FILE_BYTES = 250_000             # skip very large single files

def read_text(p: Path) -> str:
    return p.read_text(encoding="utf-8", errors="replace").replace("\r\n", "\n")

def sha256_text(s: str) -> str:
    return hashlib.sha256(s.encode("utf-8")).hexdigest()

def is_glob(s: str) -> bool:
    return any(ch in s for ch in ["*", "?", "["])

def expand_line(line: str) -> list[Path]:
    # Supports literal repo-relative paths OR glob patterns (including **)
    rel = line.strip()
    if not rel:
        return []
    if not is_glob(rel):
        return [REPO / rel]
    # glob: use Path.glob from repo root
    # Path.glob expects patterns relative to the base Path
    matches = sorted(REPO.glob(rel))
    return [m for m in matches if m.is_file()]

def load_paths(list_file: Path) -> list[Path]:
    if not list_file.exists():
        return []
    out: list[Path] = []
    for ln in read_text(list_file).splitlines():
        ln = ln.strip()
        if not ln or ln.startswith("#"):
            continue
        out.extend(expand_line(ln))

    # De-dup and sort (deterministic)
    uniq = sorted({p.resolve() for p in out})
    return uniq

def fence_block(text: str) -> str:
    # Use fenced block to avoid per-line prefix bloat
    return "```text\n" + text + "\n```\n"

def render_bundle(title: str, list_file: Path, out_path: Path) -> str:
    paths = load_paths(list_file)

    included: list[Path] = []
    missing: list[Path] = []
    skipped_large: list[Path] = []
    skipped_cap: list[Path] = []

    total = 0
    for p in paths:
        if not p.exists():
            missing.append(p)
            continue
        b = p.read_bytes()
        sz = len(b)
        if sz > MAX_FILE_BYTES:
            skipped_large.append(p)
            continue
        if len(included) >= MAX_FILES or (total + sz) > MAX_TOTAL_BYTES:
            skipped_cap.append(p)
            continue
        included.append(p)
        total += sz

    lines: list[str] = []
    lines.append(f"# {title} v1.1")
    lines.append("")
    lines.append("本書は、AIが追加で要求しがちなファイル群を「1枚」に束ねた生成物である。")
    lines.append("新チャットで REQUEST が発生した場合は、原則として本書を貼れば追加要求を抑止できる。")
    lines.append("本書は時刻・ランID等を含めず、入力ファイルが同じなら差分が出ないことを前提とする。")
    lines.append(f"生成: {DOCS / 'build_request_bundle.py'}")
    lines.append(f"ソース定義: {list_file}")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## 収録ファイル一覧（存在するもの）")
    if included:
        for p in included:
            lines.append(f"- {p.relative_to(REPO)}")
    else:
        lines.append("- （なし）")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## 収録上限（固定）")
    lines.append(f"- MAX_FILES: {MAX_FILES}")
    lines.append(f"- MAX_TOTAL_BYTES: {MAX_TOTAL_BYTES}")
    lines.append(f"- MAX_FILE_BYTES: {MAX_FILE_BYTES}")
    lines.append(f"- included_total_bytes: {total}")
    lines.append("")
    if skipped_large:
        lines.append("## スキップ（単体が大きすぎる）")
        for p in skipped_large:
            lines.append(f"- {p.relative_to(REPO)}")
        lines.append("")
    if skipped_cap:
        lines.append("## スキップ（上限到達）")
        for p in skipped_cap:
            lines.append(f"- {p.relative_to(REPO)}")
        lines.append("")
    if missing:
        lines.append("## 欠落（指定されたが存在しない）")
        for p in missing:
            lines.append(f"- {p.relative_to(REPO)}")
        lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## 本文（ファイル内容を連結）")
    lines.append("注意：本書は貼り付け専用の束であり、ここに含まれる内容を編集対象にしない（編集は元ファイルで行う）。")
    lines.append("")

    for p in included:
        rel = p.relative_to(REPO)
        body = read_text(p)
        h = sha256_text(body)
        lines.append("---")
        lines.append("")
        lines.append(f"### FILE: {rel}")
        lines.append(f"- sha256: {h}")
        lines.append(f"- bytes: {len(body.encode('utf-8'))}")
        lines.append("")
        lines.append(fence_block(body.rstrip("\n")))
        lines.append("")

    return "\n".join(lines) + "\n"

def main() -> None:
    OUT_SYS.write_text(render_bundle("REQUEST_BUNDLE_SYSTEM（追加要求ファイル束）", SYS_LIST, OUT_SYS), encoding="utf-8", newline="\n")
    print(f"Generated: {OUT_SYS}")
    OUT_BIZ.write_text(render_bundle("REQUEST_BUNDLE_BUSINESS（追加要求ファイル束）", BIZ_LIST, OUT_BIZ), encoding="utf-8", newline="\n")
    print(f"Generated: {OUT_BIZ}")

if __name__ == "__main__":
    main()
