# ERROR_PLAYBOOK

## Purpose
Reason codes for STOP/MERGE decisions and learning registry classification.

## Principles
- Decision is always one of: MERGE / STOP.
- Unknown signatures must default to STOP (prevent contamination).
- Learning is: packet -> classify -> registry entry -> next runs branch deterministically.

## Reason Codes (starter set)
- AUTH_401: Authentication/permission failure
- CI_NO_CHECKS: PR has no checks / workflows not triggered
- MERGE_CONFLICT: Git merge conflict
- PATH_FORBIDDEN: Forbidden path touched
- BUNDLE_CORRUPTION: Bundled evidence format corruption
- IO_NOT_FOUND: Missing file/path
- TOOL_MISSING: Tool/command not found
- UNKNOWN: Not classified yet (must STOP)
