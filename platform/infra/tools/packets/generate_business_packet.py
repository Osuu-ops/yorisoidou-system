#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import hashlib
import sys
from pathlib import Path

try:
    import yaml  # PyYAML
except Exception:
    print("ERROR: PyYAML is required (pip install pyyaml).", file=sys.stderr)
    raise

GEN_HEADER = """# BUSINESS_PACKET（業務側・新チャット貼り付け用）
# これは自動生成ファイルです。手編集は禁止（差分事故の温床になるため）。
# 更新は workflow_dispatch（Business Packet Update (Dispatch)）で再生成→PR を作成してください。
"""

USAGE = """## 使い方（最小）
- 新チャット1通目に **このファイル全文** を貼る（1枚貼り）。
- 追加提示が必要な場合、AIは REQUEST 形式で最大3件まで。
"""

REQUEST_RULE = """## AIの要求ルール（必須）
### REQUEST
- file: <ファイルパス>
- heading: <見出し名（h2/h3等）>
- reason: <必要理由（1行）>
"""

DEFAULT_CONFIG_NAME = "BUSINESS_PACKET.yml"
DEFAULT_OUTPUT_NAME = "BUSINESS_PACKET.md"

def sha256_text(s: str) -> str:
    return hashlib.sha256(s.encode("utf-8")).hexdigest()

def read_text(p: Path) -> str:
    return p.read_text(encoding="utf-8")

def write_text(p: Path, s: str) -> None:
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(s, encoding="utf-8", newline="\n")

def load_config(biz_dir: Path, config_path: Path | None) -> dict:
    cfg_path = config_path if config_path else biz_dir / DEFAULT_CONFIG_NAME
    if not cfg_path.exists():
        raise FileNotFoundError(f"Config not found: {cfg_path}")
    data = yaml.safe_load(read_text(cfg_path)) or {}
    if "sources" not in data or not isinstance(data["sources"], list):
        raise ValueError("Config must contain 'sources' as a list.")
    return data

def normalize_rel(biz_dir: Path, p: Path) -> str:
    return str(p.resolve().relative_to(biz_dir.resolve())).replace("\\", "/")

def render_section(title: str, relpath: str, body: str) -> str:
    return (
        f"\n---\n\n"
        f"## {title}\n\n"
        f"**path:** `{relpath}`\n\n"
        f"<!-- BEGIN SOURCE:{relpath} -->\n"
        f"```text\n{body}\n```\n"
        f"<!-- END SOURCE:{relpath} -->\n"
    )

def build_packet(biz_dir: Path, cfg: dict) -> str:
    parts: list[str] = []
    parts.append(GEN_HEADER.rstrip("\n"))
    parts.append("")
    parts.append(USAGE.rstrip("\n"))
    parts.append("")
    parts.append(REQUEST_RULE.rstrip("\n"))

    for src in cfg["sources"]:
        if not isinstance(src, dict):
            raise ValueError("Each item in 'sources' must be a mapping.")
        title = src.get("title")
        path = src.get("path")
        required = bool(src.get("required", False))

        if not title or not path:
            raise ValueError("Each source must have 'title' and 'path'.")

        file_path = (biz_dir / path).resolve()
        if not file_path.exists():
            if required:
                raise FileNotFoundError(f"Required source missing: {file_path}")
            continue

        body = read_text(file_path)
        rel = normalize_rel(biz_dir, file_path)
        parts.append(render_section(title, rel, body.rstrip("\n")))

    joined = "\n".join(parts).rstrip("\n") + "\n"
    digest = sha256_text(joined)
    joined += f"\n---\n\n## PACKET_DIGEST\n`sha256:{digest}`\n"
    return joined

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--biz-dir", required=True, help="Business directory (root that contains BUSINESS_PACKET.yml)")
    ap.add_argument("--config", default=None, help="Optional config path override")
    ap.add_argument("--out", default=None, help="Output file path override")
    ap.add_argument("--check", action="store_true", help="Fail if output differs from existing")
    args = ap.parse_args()

    biz_dir = Path(args.biz_dir).resolve()
    if not biz_dir.exists() or not biz_dir.is_dir():
        print(f"ERROR: biz-dir not found or not a directory: {biz_dir}", file=sys.stderr)
        return 2

    cfg_path = Path(args.config).resolve() if args.config else None
    out_path = Path(args.out).resolve() if args.out else (biz_dir / DEFAULT_OUTPUT_NAME)

    try:
        cfg = load_config(biz_dir, cfg_path)
        new_text = build_packet(biz_dir, cfg)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 2

    if args.check:
        if not out_path.exists():
            print(f"ERROR: Output missing: {out_path}", file=sys.stderr)
            return 1
        old_text = read_text(out_path)
        if old_text != new_text:
            print("ERROR: BUSINESS_PACKET is outdated (generated content differs).", file=sys.stderr)
            return 1
        return 0

    write_text(out_path, new_text)
    print(f"OK: wrote {out_path}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
