#!/usr/bin/env python3
import sys, hashlib, re
from pathlib import Path
REQUIRED_KEYS = [
    "PACKET_VERSION:",
    "LANE:",
    "ISSUE_NUMBER:",
    "ISSUE_URL:",
    "RUN_URL:",
    "SAFE_MODE: STANDALONE_PRE_8GATE",
    "MERGED_DRAFT_SHA256:",
]
def stop(msg: str) -> None:
    print("STOP_HARD:", msg)
    raise SystemExit(1)
def main() -> int:
    if len(sys.argv) != 2:
        stop("packet_path required")
    p = Path(sys.argv[1])
    if not p.exists():
        stop("INPUT_PACKET not found")
    text = p.read_text(encoding="utf-8")
    # required headers (string contains check)
    for k in REQUIRED_KEYS:
        if k not in text:
            stop(f"Missing required key: {k}")
    # DOES_NOT_TRIGGER_8GATE must exist; value must be true/false
    m = re.search(r"(?m)^\s*DOES_NOT_TRIGGER_8GATE:\s*(\S+)\s*$", text)
    if not m:
        stop("Missing required key: DOES_NOT_TRIGGER_8GATE")
    v = (m.group(1) or "").strip().lower()
    if v not in ("true", "false"):
        stop("Invalid value for DOES_NOT_TRIGGER_8GATE (expected true/false)")
    # Extract declared sha
    sha_line = [l for l in text.splitlines() if l.startswith("MERGED_DRAFT_SHA256:")]
    if not sha_line:
        stop("SHA256 line missing")
    sha_value = sha_line[0].split(":", 1)[1].strip()
    # Validate against sibling MERGED_DRAFT.md bytes
    merged = p.parent / "MERGED_DRAFT.md"
    if not merged.exists():
        stop("MERGED_DRAFT.md not found next to INPUT_PACKET.md")
    # Normalize line endings before hashing to avoid CRLF/LF platform mismatch
merged_text = merged.read_text(encoding="utf-8")
normalized = merged_text.replace("\r\n", "\n").replace("\r", "\n")
computed = hashlib.sha256(normalized.encode("utf-8")).hexdigest()
    if computed != sha_value:
        stop("SHA256 mismatch (MERGED_DRAFT.md bytes)")
    print("PACKET_VALID")
    return 0
if __name__ == "__main__":
    raise SystemExit(main())
