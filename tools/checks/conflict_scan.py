#!/usr/bin/env python3
import json, subprocess, sys
def run(cmd):
    return subprocess.check_output(cmd, text=True).strip()
def main():
    diff_base = sys.argv[1] if len(sys.argv) > 1 else "origin/main"
    diff_head = sys.argv[2] if len(sys.argv) > 2 else "HEAD"
    legacy_paths = [
        "docs/MEP/SSOT/WORK_ID_SSOT.json",
        "docs/MEP/SSOT/WORK_ID_SSOT.schema.json",
        "docs/MEP/SSOT/WORK_ID_SSOT_MASTER.json",
        "docs/MEP/SSOT/WORK_ID_SSOT_MASTER.schema.json",
        "docs/MEP/WORK_ID/",
    ]
    new_paths = [
        "docs/MEP/SSOT/WORK_ITEMS.json",
        "docs/MEP/SSOT/WORK_ITEMS.schema.json",
        "docs/MEP/WORK_ITEMS/",
        "tools/mep_entry.ps1",
    ]
    def norm(p): return p.replace("\\", "/")
    def has_any(files, prefixes):
        for f in files:
            ff = norm(f)
            for p in prefixes:
                pp = norm(p)
                if pp.endswith("/"):
                    if ff.startswith(pp): return True
                else:
                    if ff == pp: return True
        return False
    try:
        out = run(["git", "diff", "--name-only", f"{diff_base}...{diff_head}"])
        files = [x for x in out.splitlines() if x.strip()]
    except Exception:
        files = []
    legacy_touched = has_any(files, legacy_paths)
    new_touched    = has_any(files, new_paths)
    if legacy_touched and new_touched:
        j = {
            "conflictDetected": True,
            "conflictReason": "WB0001_CONFLICT_SCAN_DIFF_SCOPE",
            "conflictDetails": "legacy+new execution-candidate sources modified in same PR (diff-scope).",
            "diffBase": diff_base,
            "diffHead": diff_head,
        }
        print(json.dumps(j, ensure_ascii=False))
        return 1
    j = {"conflictDetected": False, "conflictReason": None, "conflictDetails": "OK (diff-scope).", "diffBase": diff_base, "diffHead": diff_head}
    print(json.dumps(j, ensure_ascii=False))
    return 0
if __name__ == "__main__":
    raise SystemExit(main())
