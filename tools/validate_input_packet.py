#!/usr/bin/env python3
import sys, hashlib
from pathlib import Path
REQUIRED_KEYS = [
    "PACKET_VERSION:",
    "LANE:",
    "ISSUE_NUMBER:",
    "ISSUE_URL:",
    "RUN_URL:",
    "SAFE_MODE: STANDALONE_PRE_8GATE",
    "DOES_NOT_TRIGGER_8GATE: true",
    "MERGED_DRAFT_SHA256:"
]
def stop(msg):
    print("STOP_HARD:", msg)
    sys.exit(1)
def main():
    if len(sys.argv) != 2:
        stop("packet_path required")
    p = Path(sys.argv[1])
    if not p.exists():
        stop("INPUT_PACKET not found")
    text = p.read_text(encoding="utf-8")
    for k in REQUIRED_KEYS:
        if k not in text:
            stop(f"Missing required key: {k}")
    # Extract declared sha
    sha_line = [l for l in text.splitlines() if l.startswith("MERGED_DRAFT_SHA256:")]
    if not sha_line:
        stop("SHA256 line missing")
    sha_value = sha_line[0].split(":",1)[1].strip()
    # Validate against sibling MERGED_DRAFT.md bytes (matches standalone generator)
    merged = p.parent / "MERGED_DRAFT.md"
    if not merged.exists():
        stop("MERGED_DRAFT.md not found next to INPUT_PACKET.md")
    merged_bytes = merged.read_bytes()
    computed = hashlib.sha256(merged_bytes).hexdigest()
    if computed != sha_value:
        stop("SHA256 mismatch (MERGED_DRAFT.md bytes)")
    print("PACKET_VALID")
    sys.exit(0)
if __name__ == "__main__":
    main()
