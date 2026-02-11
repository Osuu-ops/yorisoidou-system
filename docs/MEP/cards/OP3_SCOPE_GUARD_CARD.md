# CARD | OP-3 Scope Guard (Non-Interference)
## MUST
- Classify changes: ALLOW / DENY / EXCEPTION
- If ambiguous -> STOP
- If required checks naming mismatch -> STOP_HARD
## DENY examples
- Business + System mixed in one PR
- Protected paths touched without explicit exception evidence
## EXCEPTION
- Allowed only when explicitly declared and evidenced
## Output
- Changed files list
- Classification + reason
- STOP code/state when blocked
