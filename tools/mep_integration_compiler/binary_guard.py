#!/usr/bin/env python3
import sys
import hashlib
from pathlib import Path

def load_allowlist(path: Path) -> dict[str, str]:
    allow = {}
    if not path.exists():
        return allow
    for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        # split: "<hash>  <path>"
        parts = line.split()
        if len(parts) < 2:
            continue
        h = parts[0]
        p = " ".join(parts[1:]).strip()
        allow[p] = h
    return allow

def sha256_file(fp: Path) -> str:
    h = hashlib.sha256()
    with fp.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def main():
    if len(sys.argv) != 3:
        print("Usage: binary_guard.py <nontext_paths.txt> <allowlist.sha256>", file=sys.stderr)
        return 2

    list_file = Path(sys.argv[1])
    allow_file = Path(sys.argv[2])

    if not list_file.exists():
        print(f"[binary_guard] no list file: {list_file} (treat as OK)")
        return 0

    paths = [p.strip() for p in list_file.read_text(encoding="utf-8", errors="ignore").splitlines() if p.strip()]
    if not paths:
        print("[binary_guard] no non-text changes (OK)")
        return 0

    allow = load_allowlist(allow_file)

    missing = []
    mismatch = []
    for p in paths:
        fp = Path(p)
        if not fp.exists():
            # If file was deleted/renamed, it shouldn't be in AM list. But tolerate.
            continue
        actual = sha256_file(fp)
        expected = allow.get(p)
        if expected is None:
            missing.append((p, actual))
        elif expected.lower() != actual.lower():
            mismatch.append((p, expected, actual))

    if missing or mismatch:
        print("BINARY_GUARD_NG", file=sys.stderr)
        if missing:
            print("\n[Missing allowlist entries]", file=sys.stderr)
            for p, h in missing:
                print(f"{h}  {p}", file=sys.stderr)
        if mismatch:
            print("\n[Hash mismatch]", file=sys.stderr)
            for p, exp, act in mismatch:
                print(f"{p}\n  expected: {exp}\n  actual:   {act}", file=sys.stderr)
        print(f"\nAllowlist file: {allow_file}", file=sys.stderr)
        return 1

    print("[binary_guard] all non-text assets are allowlisted (OK)")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
