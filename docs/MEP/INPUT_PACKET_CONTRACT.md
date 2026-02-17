# INPUT_PACKET Contract (NORMATIVE)
This file defines the fixed interface between Standalone AutoLoop and 8-Gate Entry.
Required headers (exact keys):
PACKET_VERSION: v1
LANE: SYSTEM | BUSINESS
ISSUE_NUMBER:
ISSUE_URL:
RUN_URL:
SAFE_MODE: STANDALONE_PRE_8GATE
DOES_NOT_TRIGGER_8GATE: true
MERGED_DRAFT_SHA256:
Rules:
- 8-Gate must only read INPUT_PACKET.md.
- If any required key missing → STOP_HARD.
- Standalone loop never calls 8-Gate.
- 8-Gate entry must validate SHA256 before execution.
