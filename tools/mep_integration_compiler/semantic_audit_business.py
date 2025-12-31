#!/usr/bin/env python3
import sys
from pathlib import Path
import subprocess

def main():
    if len(sys.argv) != 2:
        print("Usage: semantic_audit_business.py <inputs.txt>", file=sys.stderr)
        return 2

    inputs = sys.argv[1]
    script = Path("tools/mep_integration_compiler/semantic_audit.py")

    if not script.exists():
        print(f"ERROR: base audit script not found: {script}", file=sys.stderr)
        return 2

    # pass-through (business rules can diverge later)
    r = subprocess.run([sys.executable, str(script), inputs])
    return r.returncode

if __name__ == "__main__":
    raise SystemExit(main())
