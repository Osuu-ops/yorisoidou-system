import os
import re
from pathlib import Path
REPO_ROOT = Path(os.environ.get("GITHUB_WORKSPACE", ".")).resolve()
def fix_heredoc_indent(text: str) -> tuple[str, int]:
    """
    Fix lines between <<'PY' and PY so they keep the same leading indentation
    as the heredoc start line. This prevents YAML block scalar from being broken
    by column-1 Python lines (import ...).
    Returns (new_text, num_changes).
    """
    lines = text.splitlines(True)  # keep newlines
    out = []
    in_here = False
    indent = ""
    changes = 0
    start_pat = re.compile(r"^(?P<sp>\s*).*<<'PY'\s*$")
    for ln in lines:
        if not in_here:
            m = start_pat.match(ln.rstrip("\r\n"))
            if m:
                in_here = True
                indent = m.group("sp")
                out.append(ln)
                continue
            out.append(ln)
            continue
        # in heredoc
        stripped = ln.rstrip("\r\n")
        if stripped.strip() == "PY":
            # ensure end marker is indented
            if not stripped.startswith(indent):
                ln = indent + stripped.strip() + ("\r\n" if ln.endswith("\r\n") else "\n")
                changes += 1
            out.append(ln)
            in_here = False
            indent = ""
            continue
        # body line: ensure it starts with indent (do not trim content)
        if not stripped.startswith(indent):
            ln = indent + stripped + ("\r\n" if ln.endswith("\r\n") else "\n")
            changes += 1
        out.append(ln)
    return ("".join(out), changes)
def normalize_newlines(text: str) -> tuple[str, int]:
    # Convert CRLF to LF (actionlint prefers LF; avoids diff noise)
    if "\r\n" in text:
        return (text.replace("\r\n", "\n"), 1)
    return (text, 0)
def process_file(p: Path) -> int:
    raw = p.read_text(encoding="utf-8", errors="replace")
    new, c1 = fix_heredoc_indent(raw)
    new, c2 = normalize_newlines(new)
    if (c1 + c2) > 0 and new != raw:
        p.write_text(new, encoding="utf-8", newline="\n")
    return c1 + c2
def main():
    wf_dir = REPO_ROOT / ".github" / "workflows"
    if not wf_dir.exists():
        print("NO_WORKFLOWS_DIR")
        return 0
    total_changes = 0
    touched = 0
    for p in wf_dir.rglob("*.yml"):
        # skip the autofix workflow itself to avoid loops
        if p.name == "workflow_autofix_pr.yml":
            continue
        ch = process_file(p)
        if ch > 0:
            touched += 1
            total_changes += ch
    print(f"AUTOFIX_TOUCHED_FILES={touched}")
    print(f"AUTOFIX_CHANGES={total_changes}")
    return 0
if __name__ == "__main__":
    raise SystemExit(main())
