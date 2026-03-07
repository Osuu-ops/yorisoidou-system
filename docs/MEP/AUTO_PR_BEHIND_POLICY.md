# AUTO PR BEHIND Policy (MEP)

## Scope
- Target: `auto/standalone_issue_*` PR created by `mep_standalone_issue_autoloop.yml`
- Goal: keep "PR checks -> auto-merge -> 8-gate" deterministic when `mergeable_state=behind` appears.

## Control Flow
1. Create artifacts PR.
2. Assign controller lock label (`mep:controller=CHAT_<unique_id>`).
3. If `mergeable_state=behind`, call `pulls.updateBranch`.
4. Enable auto-merge (`gh pr merge --squash --auto --delete-branch`).
5. Poll PR state:
- Required checks are source of truth.
- If checks fail: stop hard.
- If checks pending: keep waiting.
- If behind appears again: update-branch and continue.
- When merged: dispatch `mep_8gate_entry_filter.yml` with `packet_path`.

## Reason Codes
- `AUTO_PR_BEHIND_UPDATE_BRANCH_REQUESTED`
- `AUTO_PR_UPDATE_BRANCH_FAILED`
- `AUTO_PR_ENABLE_AUTOMERGE_FAILED`
- `AUTO_PR_CHECKS_MISSING`
- `AUTO_PR_CHECKS_FAILED`
- `AUTO_PR_CLOSED_WITHOUT_MERGE`
- `AUTO_PR_MERGE_TIMEOUT`
- `AUTOLOOP_ENTRY_DISPATCH_FAILED`

## Manual Fallback (minimum)
- If timeout persists: run update-branch manually, then rerun `mep_standalone_issue_autoloop.yml` for the same issue.
- If checks keep failing: fix failing required checks first, then rerun.
