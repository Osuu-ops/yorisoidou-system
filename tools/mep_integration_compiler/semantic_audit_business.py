#!/usr/bin/env python3
import re
import sys
from pathlib import Path
import subprocess
import codecs

SYMBOLS_FILE = Path("platform/MEP/01_CORE/definitions/SYMBOLS.md")
REF_RE = re.compile(r'@([A-Z][A-Z0-9_/-]{1,64})')

def decode_git_path(s: str) -> str:
    """
    Git may output paths with:
    - surrounding double quotes
    - octal escapes like \\343\\202\\210...
    We normalize them to real UTF-8 paths.
    """
    s = s.strip()
    if s.startswith('"') and s.endswith('"') and len(s) >= 2:
        s = s[1:-1]

    # If it contains octal escapes, decode using unicode_escape then bytes->utf8
    # Example: \\343\\202\\210 -> bytes 0o343 0o202 0o210
    if re.search(r'(\\[0-7]{3})', s):
        try:
            # turn \343 into the byte with value 0o343, etc.
            raw = codecs.decode(s, 'unicode_escape')
            # raw is a str whose codepoints 0-255 represent the bytes
            b = bytes([ord(ch) for ch in raw])
            s2 = b.decode('utf-8', errors='strict')
            return s2
        except Exception:
            # fallback: keep original
            return s

    return s

def read_inputs_list(inputs_txt: str) -> list[str]:
    p = Path(inputs_txt)
    if not p.exists():
        return []
    lines = []
    for ln in p.read_text(encoding="utf-8", errors="ignore").splitlines():
        ln = ln.strip()
        if not ln:
            continue
        lines.append(decode_git_path(ln))
    return lines

def load_allowed_symbols() -> set[str]:
    if not SYMBOLS_FILE.exists():
        print(f"REF_AUDIT_NG: symbols file not found: {SYMBOLS_FILE}", file=sys.stderr)
        return set()
    text = SYMBOLS_FILE.read_text(encoding="utf-8", errors="ignore")
    allowed = set()
    for m in REF_RE.finditer(text):
        allowed.add(m.group(0))
    return allowed

def extract_refs_from_text(text: str) -> set[str]:
    return set(m.group(0) for m in REF_RE.finditer(text))

def ref_audit_business(changed_files: list[str]) -> int:
    allowed = load_allowed_symbols()
    if not allowed:
        return 1

    unknown = []
    for rel in changed_files:
        fp = Path(rel)
        if not fp.exists():
            # If path decoding failed, report it clearly
            print(f"REF_AUDIT_NG: file path not found: {rel}", file=sys.stderr)
            return 1

        content = fp.read_text(encoding="utf-8", errors="ignore")
        refs = extract_refs_from_text(content)
        for ref in sorted(refs):
            if ref not in allowed:
                unknown.append((rel, ref))

    if unknown:
        print("REF_AUDIT_NG: unknown reference symbol(s) detected", file=sys.stderr)
        print(f"Symbols source of truth: {SYMBOLS_FILE}", file=sys.stderr)
        print("", file=sys.stderr)
        for rel, ref in unknown[:200]:
            print(f"- {rel}: {ref}", file=sys.stderr)
        if len(unknown) > 200:
            print(f"... and {len(unknown) - 200} more", file=sys.stderr)
        return 1

    return 0

def main():
    if len(sys.argv) != 2:
        print("Usage: semantic_audit_business.py <inputs.txt>", file=sys.stderr)
        return 2

    inputs_txt = sys.argv[1]
    changed_files = read_inputs_list(inputs_txt)

    ra = ref_audit_business(changed_files)
    if ra != 0:
        return ra

    base = Path("tools/mep_integration_compiler/semantic_audit.py")
    if not base.exists():
        print(f"ERROR: base audit script not found: {base}", file=sys.stderr)
        return 2

    r = subprocess.run([sys.executable, str(base), inputs_txt])
    return r.returncode

if __name__ == "__main__":
    raise SystemExit(main())
