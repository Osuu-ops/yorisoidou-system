#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Collect changed files between base and head using `git diff -z`,
then classify into:
- CORE / BUSINESS
- text vs binary (by extension allowlist)
Outputs:
  out_dir/
    core_all.txt
    core_audit.txt
    core_binary.txt
    core_deleted.txt
    biz_all.txt
    biz_audit.txt
    biz_binary.txt
    biz_deleted.txt
    counts.json
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import List, Tuple, Dict, Optional


TEXT_EXTS = {
    ".md", ".txt", ".yaml", ".yml", ".json",
    # 追加したい場合はここに足す（最小差分で運用開始するため、最初は控えめ）
}

@dataclass
class Change:
    status: str   # A, M, R, D, C
    path: str     # new path for R/C, normal path for A/M/D

def run_git_diff_name_status_z(base: str, head: str) -> bytes:
    # -z: NUL区切り
    # --name-status: status + path
    # --diff-filter=ACMRD: 追加/コピー/変更/リネーム/削除（必要なら拡張）
    cmd = [
        "git", "-c", "core.quotepath=false",
        "diff", "--name-status", "-z", "--diff-filter=ACMRD",
        base, head
    ]
    p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    if p.returncode != 0:
        raise RuntimeError(f"git diff failed: {p.stderr.decode('utf-8', errors='replace')}")
    return p.stdout

def parse_name_status_z(blob: bytes) -> List[Change]:
    """
    Format (NUL-delimited):
      Typical:
        <status>\t<path>\0
        R100\t<old>\0<new>\0
      But some git/env combos may output tab-less tokens under -z, e.g.:
        R100\0<old>\0<new>\0
        M\0<path>\0
    We'll normalize to Change(status, path=new_or_path).
    """
    parts = blob.split(b"\0")
    i = 0
    out: List[Change] = []

    while i < len(parts):
        token = parts[i]
        i += 1
        if not token:
            continue

        try:
            s = token.decode("utf-8", errors="surrogateescape")
        except Exception:
            s = token.decode("utf-8", errors="replace")

        if "\t" in s:
            # token is like b"M\tpath" or b"R100\told"
            status_field, p1 = s.split("\t", 1)
            status = status_field[:1]  # R100 -> R

            if status in ("R", "C"):
                # next NUL entry is new path
                if i >= len(parts):
                    break
                newp_b = parts[i]
                i += 1
                try:
                    newp = newp_b.decode("utf-8", errors="surrogateescape")
                except Exception:
                    newp = newp_b.decode("utf-8", errors="replace")
                out.append(Change(status=status, path=newp))
            else:
                out.append(Change(status=status, path=p1))
            continue

        # Tab-less fallback under -z:
        # - "R100" then <old>\0<new>\0
        # - "M"   then <path>\0 (etc.)
        status = s[:1]
        if not status:
            continue

        if status in ("R", "C"):
            # expect old and new paths as next two entries
            if i + 1 >= len(parts):
                break
            _oldp_b = parts[i]       # ignored
            newp_b = parts[i + 1]
            i += 2
            try:
                newp = newp_b.decode("utf-8", errors="surrogateescape")
            except Exception:
                newp = newp_b.decode("utf-8", errors="replace")
            out.append(Change(status=status, path=newp))
            continue

        # expect next entry to be the path
        if i >= len(parts):
            break
        p1_b = parts[i]
        i += 1
        try:
            p1 = p1_b.decode("utf-8", errors="surrogateescape")
        except Exception:
            p1 = p1_b.decode("utf-8", errors="replace")
        out.append(Change(status=status, path=p1))

    return out

def is_under(path: str, root: str) -> bool:
    # root like "platform/MEP/01_CORE/"
    rp = root.rstrip("/") + "/"
    return path.startswith(rp)

def is_text_path(path: str) -> bool:
    ext = Path(path).suffix.lower()
    return ext in TEXT_EXTS

def write_list(path: Path, lines: List[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("".join([l + "\n" for l in lines]), encoding="utf-8")

def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", required=True, help="base commit sha")
    ap.add_argument("--head", required=True, help="head commit sha")
    ap.add_argument("--core-root", default="platform/MEP/01_CORE", help="CORE root path")
    ap.add_argument("--biz-root", default="platform/MEP/03_BUSINESS", help="BUSINESS root path")
    ap.add_argument("--out-dir", default=".mep/tmp", help="output directory")
    args = ap.parse_args()

    base = args.base
    head = args.head
    core_root = args.core_root
    biz_root = args.biz_root
    out_dir = Path(args.out_dir)

    blob = run_git_diff_name_status_z(base, head)
    changes = parse_name_status_z(blob)

    # classify
    def collect_for(root: str) -> Dict[str, List[str]]:
        all_existing: List[str] = []
        audit: List[str] = []
        binary: List[str] = []
        deleted: List[str] = []

        for ch in changes:
            if not is_under(ch.path, root):
                continue

            # deletion: file doesn't exist in HEAD
            if ch.status == "D":
                deleted.append(ch.path)
                continue

            all_existing.append(ch.path)

            if is_text_path(ch.path):
                audit.append(ch.path)
            else:
                binary.append(ch.path)

        # uniq preserve order
        def uniq(xs: List[str]) -> List[str]:
            seen = set()
            out = []
            for x in xs:
                if x in seen:
                    continue
                seen.add(x)
                out.append(x)
            return out

        return {
            "all": uniq(all_existing),
            "audit": uniq(audit),
            "binary": uniq(binary),
            "deleted": uniq(deleted),
        }

    core = collect_for(core_root)
    biz = collect_for(biz_root)

    # write outputs (互換重視で「パスだけ」の行形式)
    write_list(out_dir / "core_all.txt", core["all"])
    write_list(out_dir / "core_audit.txt", core["audit"])
    write_list(out_dir / "core_binary.txt", core["binary"])
    write_list(out_dir / "core_deleted.txt", core["deleted"])

    write_list(out_dir / "biz_all.txt", biz["all"])
    write_list(out_dir / "biz_audit.txt", biz["audit"])
    write_list(out_dir / "biz_binary.txt", biz["binary"])
    write_list(out_dir / "biz_deleted.txt", biz["deleted"])

    counts = {
        "core": {
            "all_count": len(core["all"]),
            "audit_count": len(core["audit"]),
            "binary_count": len(core["binary"]),
            "deleted_count": len(core["deleted"]),
        },
        "business": {
            "all_count": len(biz["all"]),
            "audit_count": len(biz["audit"]),
            "binary_count": len(biz["binary"]),
            "deleted_count": len(biz["deleted"]),
        },
        "meta": {
            "base": base,
            "head": head,
            "core_root": core_root,
            "biz_root": biz_root,
            "text_exts": sorted(TEXT_EXTS),
        }
    }
    (out_dir / "counts.json").write_text(json.dumps(counts, ensure_ascii=False, indent=2), encoding="utf-8")

    print(json.dumps(counts, ensure_ascii=False))

if __name__ == "__main__":
    main()
