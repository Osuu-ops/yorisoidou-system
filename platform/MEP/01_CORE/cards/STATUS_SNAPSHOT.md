## CARD: STATUS_SNAPSHOT (mep status / snapshot)

### Purpose
Provide a single command snapshot of "current truth" without relying on chat context.

### Must Output (minimum)
- repo: owner/name + current branch
- HEAD commit
- Bundled: docs/MEP/MEP_BUNDLE.md BUNDLE_VERSION
- clean/dirty status
- latest merged PR (best-effort via gh) and its mergeCommit/mergedAt
- optional: last 20 commits summary (oneline)

### Non-Goals
- No mutation (read-only).
- No inference beyond printed evidence.

### Implementation
- tools/mep_status_snapshot.ps1
