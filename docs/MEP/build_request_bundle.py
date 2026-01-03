#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations
from pathlib import Path
import hashlib

ROOT = Path(__file__).resolve().parents[2]
REPO = ROOT
DOCS = ROOT / "docs" / "MEP"

SYS_LIST = DOCS / "request_bundle_sources_system.txt"
BIZ_LIST = DOCS / "request_bundle_sources_business.txt"

OUT_SYS = DOCS / "REQUEST_BUNDLE_SYSTEM.md"
OUT_BIZ = DOCS / "REQUEST_BUNDLE_BUSINESS.md"


def read_text(p: Path) -> str:
    return p.read_text(encoding="utf-8", errors="replace").replace("\r\n", "\n")


def sha256_text(s: str) -> str:
    return hashlib.sha256(s.encode("utf-8")).hexdigest()


def load_paths(list_file: Path) -> list[Path]:
    if not list_file.exists():
        return []
    paths: list[Path] = []
    for ln in read_text(list_file).splitlines():
        ln = ln.strip()
        if not ln or ln.startswith("#"):
            continue
        paths.append(REPO / ln)
    return paths


def render_bundle(title: str, list_file: Path, out_path: Path) -> str:
    paths = load_paths(list_file)

    included: list[Path] = []
    missing: list[Path] = []
    for p in paths:
        if p.exists():
            included.append(p)
        else:
            missing.append(p)

    lines: list[str] = []
    lines.append(f"# {title} v1.0")
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
            rel = p.relative_to(REPO)
            lines.append(f"- {rel}")
    else:
        lines.append("- （なし）")
    lines.append("")
    if missing:
        lines.append("---")
        lines.append("")
        lines.append("## 欠落ファイル（指定されたが存在しない）")
        for p in missing:
            rel = p.relative_to(REPO)
            lines.append(f"- {rel}")
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
        # Content as quoted block to avoid markdown fence accidents
        for ln in body.splitlines():
            lines.append("> " + ln)
        lines.append("")

    return "\n".join(lines) + "\n"


def main() -> None:
    OUT_SYS.write_text(render_bundle("REQUEST_BUNDLE_SYSTEM（追加要求ファイル束）", SYS_LIST, OUT_SYS), encoding="utf-8", newline="\n")
    print(f"Generated: {OUT_SYS}")
    OUT_BIZ.write_text(render_bundle("REQUEST_BUNDLE_BUSINESS（追加要求ファイル束）", BIZ_LIST, OUT_BIZ), encoding="utf-8", newline="\n")
    print(f"Generated: {OUT_BIZ}")


if __name__ == "__main__":
    main()
