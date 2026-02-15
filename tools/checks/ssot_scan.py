#!/usr/bin/env python3
import json, re, sys
from pathlib import Path
def main():
    ssot_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("docs/MEP/MEP_SSOT_MASTER.md")
    findings = []
    if not ssot_path.exists():
        findings.append({"type":"SSOT_NOT_FOUND","severity":"STOP","detail":f"SSOT not found: {ssot_path.as_posix()}"})
        out = {"ssot_scan_status":"STOP","ssot_scan_findings_count":len(findings),"ssot_path":ssot_path.as_posix(),"findings":findings}
        print(json.dumps(out, ensure_ascii=False))
        return 1
    txt = ssot_path.read_text(encoding="utf-8", errors="replace")
    # Q numbers + ranges (Q121〜Q128)
    qs = set()
    for m in re.finditer(r"\bQ(\d+)\b", txt):
        try: qs.add(int(m.group(1)))
        except: pass
    for m in re.finditer(r"\bQ(\d+)\s*[〜~-]\s*Q(\d+)\b", txt):
        try:
            a = int(m.group(1)); b = int(m.group(2))
            lo, hi = (a, b) if a <= b else (b, a)
            for q in range(lo, hi + 1): qs.add(q)
        except:
            pass
    if len(qs) >= 2:
        lo, hi = min(qs), max(qs)
        missing = [q for q in range(lo, hi + 1) if q not in qs]
        if missing:
            findings.append({"type":"Q_MISSING","severity":"STOP","detail":f"Missing Q numbers between {lo}..{hi}: " + ",".join(str(x) for x in missing[:200])})
    # Supersedes refs + cycle detect (line-based; conservative)
    ref_qs = set()
    edges = {}
    for line in txt.splitlines():
        mself = re.search(r"\bQ(\d+)\b", line)
        cur = int(mself.group(1)) if mself else None
        m1 = re.search(r"Supersedes:\s*Q(\d+)", line)
        m2 = re.search(r"Superseded by:\s*Q(\d+)", line)
        for mm in (m1, m2):
            if mm:
                ref = int(mm.group(1))
                ref_qs.add(ref)
                if cur is not None:
                    if (cur is not None) and (ref != cur): edges.setdefault(cur, set()).add(ref)
    missing_refs = [rq for rq in sorted(ref_qs) if rq not in qs]
    if missing_refs:
        findings.append({"type":"SUPERSEDE_REF_MISSING","severity":"STOP","detail":"Referenced Q not found: " + ",".join(str(x) for x in missing_refs[:200])})
    seen, stack = set(), set()
    cycle = []
    def dfs(n):
        nonlocal cycle
        seen.add(n); stack.add(n)
        for nxt in edges.get(n, set()):
            if nxt not in seen:
                if dfs(nxt):
                    cycle.append(n); return True
            elif nxt in stack:
                cycle = [nxt, n]; return True
        stack.remove(n)
        return False
    for n in sorted(edges.keys()):
        if n not in seen and dfs(n):
            break
    if cycle:
        findings.append({"type":"SUPERSEDE_CYCLE","severity":"STOP","detail":"Cycle detected: " + " -> ".join("Q"+str(x) for x in cycle[:50])})
    status = "GO" if not any(f.get("severity") == "STOP" for f in findings) else "STOP"
    out = {
        "ssot_scan_status": status,
        "ssot_scan_findings_count": len(findings),
        "ssot_path": ssot_path.as_posix(),
        "findings": findings,
    }
    print(json.dumps(out, ensure_ascii=False))
    return 0 if status == "GO" else 1
if __name__ == "__main__":
    raise SystemExit(main())

