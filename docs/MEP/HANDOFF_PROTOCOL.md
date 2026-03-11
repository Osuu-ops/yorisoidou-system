# Handoff OS v1 Protocol

## SSOT
- Canonical source of truth is `docs/WORKROOM/WORK_ITEMS/WORK_<ID>/`.
- Canonical derived indexes are `docs/WORKROOM/ACTIVE_INDEX.json`, `docs/WORKROOM/ARCHIVE_INDEX.json`, and `docs/WORKROOM/CONTROL_TOWER.md`.
- `docs/MEP/HANDOFF_*` is compatibility mirror only. Mirror files must never be edited directly.

## Work Layout
- `META.json`: immutable identity + version counters.
- `LIVE_STATE.json`: current location snapshot.
- `EVENT_LOG.jsonl`: append-only journal.
- `GRAPH.json`: branch / owner / handoff topology rebuilt from events.
- `HANDOFF_PACKET.txt`: single packet for next chat.
- `SUMMARY.md`: human-readable derived summary.
- `TXN/txn_<SEQ>.json`: atomic mutation markers.
- `BRANCHES/<BRANCH_ID>/`: branch owner and status artifacts.
- `docs/WORKROOM/LOCKS/WORK_<ID>.lock`: exclusive write lock.

## Invariants
- One work id maps to one canonical location only.
- Mutating commands must run under lock.
- Mutations are `txn PREPARED -> event append -> derived rebuild -> META update -> txn COMMITTED`.
- On failure, continue-by-inference is forbidden. Return `STOP_HARD`.
- `EVENT_LOG.jsonl` is append-only.
- `LIVE_STATE.json`, `GRAPH.json`, `HANDOFF_PACKET.txt`, indexes, and control tower are rebuildable from event log plus meta.
- `archive` is immutable retreat, not deletion.
- `restore` returns archived work as `BLOCKED`; it never auto-resumes execution.

## Fixed IDs
- `WORK_ID=WORK_YYYYMMDD_HHMMSS_<6hex>`
- `SESSION_ID=SESSION_YYYYMMDD_HHMMSS_<6hex>`
- `HANDOFF_ID=HANDOFF_<workid>_<seq>`
- `BRANCH_ID=BRANCH_<slug>_<seq>`

## Fixed Status
- `IN_PROGRESS`
- `HANDOFF_READY`
- `BLOCKED`
- `DONE`
- `ARCHIVED`

## Fixed Event Types
- `SESSION_STARTED`
- `SESSION_ACCEPTED`
- `STATE_UPDATED`
- `PLAN_SET`
- `TASK_SPLIT`
- `TASK_SELECTED`
- `TASK_DROPPED`
- `BRANCH_CREATED`
- `BRANCH_SELECTED`
- `BRANCH_DROPPED`
- `BRANCH_MERGED`
- `OWNER_CHANGED`
- `PR_OPENED`
- `PR_UPDATED`
- `PR_CLOSED`
- `PR_MERGED`
- `BLOCKER_FOUND`
- `BLOCKER_CLEARED`
- `HANDOFF_OUT_CREATED`
- `HANDOFF_OUT_EMITTED`
- `HANDOFF_IN_ACCEPTED`
- `HANDOFF_REJECTED`
- `WORK_COMPLETED`
- `WORK_CLOSED`
- `WORK_ARCHIVED`
- `WORK_RESTORED`
- `STOP_HARD`

## Packet Contract
The only transferable packet is `docs/WORKROOM/WORK_ITEMS/WORK_<ID>/HANDOFF_PACKET.txt`.
`docs/MEP/HANDOFF_PACKET.txt` mirrors the preferred work for compatibility.

Header:
- `[UNIVERSAL_THREAD_PACKET v1]`

Required keys:
- `PACKET_VERSION`
- `WORK_ID`
- `HANDOFF_ID`
- `PACKET_SEQUENCE`
- `STATE_VERSION`
- `THREAD_MODE`
- `STATUS`
- `CURRENT_GOAL`
- `CURRENT_STAGE`
- `CURRENT_STATE`
- `NEXT_ACTION`
- `ACTIVE_OWNER`
- `OWNER_SCOPE_GPT`
- `OWNER_SCOPE_CODEX`
- `OWNER_SCOPE_HUMAN`
- `PRIMARY_BRANCH`
- `LIVE_BRANCHES`
- `CLOSED_BRANCHES`
- `FORBIDDEN_ACTIONS`
- `REQUIRED_EVIDENCE`
- `EVIDENCE_LOG`
- `INPUTS`
- `OUTPUT_TARGET`
- `LAST_SAFE_POINT`
- `REPO`
- `REPO_HEAD`
- `PR_NUMBER`
- `ISSUE_NUMBER`
- `PARENT_HANDOFF_ID`
- `LATEST_HANDOFF_ID`
- `LAST_UPDATE_UTC`
- `HANDOFF_NOTE`

## Accept Compare-And-Swap
Accept is valid only when all conditions match current live state:
- `WORK_ID` exists.
- `HANDOFF_ID == LIVE_STATE.latest_handoff_id`.
- `PACKET_SEQUENCE == LIVE_STATE.latest_packet_sequence`.
- `STATE_VERSION == LIVE_STATE.state_version`.
- `STATUS == HANDOFF_READY`.
- Work is not archived.
- The handoff has not already been accepted.
- Owner does not conflict with the accepting actor.

Mismatch path:
- append `HANDOFF_REJECTED`
- stop with `STOP_HARD`

## Verify / Doctor
`verify` must reject at minimum:
- stale lock
- unresolved prepared txn
- active/archive index mismatch
- control tower mismatch
- state/graph/packet mismatch
- primary branch inconsistency
- missing next action outside `DONE`/`ARCHIVED`
- archived work receiving active mutations
- packet mismatch during `HANDOFF_READY`
- owner scope inconsistency
- incomplete required evidence on `DONE`/`ARCHIVED`

`doctor` may repair:
- stale locks
- prepared txns by marking them `ABORTED`
- missing derived files via rebuild
- active/archive meta placement mismatch

## Entrypoints
- Stateful entry: `tools/mep_handoff_state.ps1`
- Packet shortcut: `tools/mep_handoff.ps1`
- Minimal packet shortcut: `tools/mep_handoff_min.ps1`
- Python core: `tools/mep_handoff_live.py`

## Command Surface
- `start`
- `update`
- `split`
- `select-branch`
- `drop-branch`
- `merge-branch`
- `packet`
- `accept`
- `complete`
- `archive`
- `restore`
- `status`
- `verify`
- `rebuild`
- `doctor`
