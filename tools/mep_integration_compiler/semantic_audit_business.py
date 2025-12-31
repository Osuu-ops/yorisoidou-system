#!/usr/bin/env python3
import re
import sys
from pathlib import Path
import subprocess

# --- Config ---
SYMBOLS_FILE = Path("platform/MEP/01_CORE/definitions/SYMBOLS.md")

# We only treat UPPERCASE @TOKENS as "MEP references"
# (avoids @copilot / @someone etc.)
REF_RE = re.compile(r'@([A-Z][A-Z0-9_/-]{1,64})')

def read_inputs_list(inputs_txt: str) -> list[str]:
    p = Path(inputs_txt)
    if not p.exists():
        return []
    lines = [ln.strip() for ln in p.read_text(encoding="utf-8", errors="ignore").splitlines()]
    return [ln for ln in lines if ln]

def load_allowed_symbols() -> set[str]:
    if not SYMBOLS_FILE.exists():
        # If symbols file is missing, we must fail-safe (NG)
        print(f"REF_AUDIT_NG: symbols file not found: {SYMBOLS_FILE}", file=sys.stderr)
        return set()

    text = SYMBOLS_FILE.read_text(encoding="utf-8", errors="ignore")
    # Collect all @TOKENS that appear in SYMBOLS.md
    allowed = set()
    for m in REF_RE.finditer(text):
        allowed.add(m.group(0))  # include '@' prefix
    return allowed

def extract_refs_from_text(text: str) -> set[str]:
    found = set()
    for m in REF_RE.finditer(text):
        found.add(m.group(0))
    return found

def ref_audit_business(changed_files: list[str]) -> int:
    allowed = load_allowed_symbols()
    if not allowed:
        # symbols missing => NG
        return 1

    unknown = []  # (file, ref)
    for rel in changed_files:
        fp = Path(rel)
        if not fp.exists():
            continue
        # only audit text files that we can read as text
        try:
            content = fp.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue

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

    # 1) Reference audit first (BUSINESS-only rule)
    ra = ref_audit_business(changed_files)
    if ra != 0:
        return ra

    # 2) Run existing semantic audit (pass-through)
    base = Path("tools/mep_integration_compiler/semantic_audit.py")
    if not base.exists():
        print(f"ERROR: base audit script not found: {base}", file=sys.stderr)
        return 2

    r = subprocess.run([sys.executable, str(base), inputs_txt])
    return r.returncode

if __name__ == "__main__":
    raise SystemExit(main())
