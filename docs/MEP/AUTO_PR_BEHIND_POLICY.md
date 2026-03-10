# AUTO PR BEHIND Policy (MEP)

## Scope
- Canonical standalone entry: `.github/workflows/mep_standalone_autoloop_dispatch.yml`
- Runtime engine: `.github/workflows/mep_standalone_autoloop_dispatch_v2.yml`
- Target PR: `auto/standalone_dispatch_*`
- Goal: keep "PR checks -> auto-merge -> restart bridge" deterministic when `mergeable_state=behind` appears.

## Lane Resolution (strict)
1. Use explicit `lane` input (`SYSTEM` or `BUSINESS`) when provided.
2. Otherwise derive from issue labels.
- `mep-biz` -> `BUSINESS`
- `mep-system` -> `SYSTEM`
3. If unresolved or conflicting labels, stop hard.
- No implicit `SYSTEM` fallback.

## Control Flow
1. Create artifacts PR.
2. If `mergeable_state=behind`, call `pulls.updateBranch`.
3. Enable auto-merge (`gh pr merge --squash --auto --delete-branch`).
4. Poll PR state:
- Required checks are source of truth.
- If checks fail: stop hard.
- If checks pending: keep waiting.
- If behind appears again: update-branch and continue.
5. When merged: write restart bridge to SSOT (`mep/run_state.json`).

## Reason Codes
- `AUTO_PR_BEHIND_UPDATE_BRANCH_REQUESTED`
- `AUTO_PR_UPDATE_BRANCH_FAILED`
- `AUTO_PR_ENABLE_AUTOMERGE_FAILED`
- `AUTO_PR_CHECKS_MISSING`
- `AUTO_PR_CHECKS_FAILED`
- `AUTO_PR_CLOSED_WITHOUT_MERGE`
- `AUTO_PR_MERGE_TIMEOUT`

## Legacy Entry Status
- `.github/workflows/mep_standalone_issue_autoloop.yml`: sealed
- `.github/workflows/mep_dispatch_from_issue.yml`: sealed
- `.github/workflows/mep_standalone_issue_autoloop_dispatch.yml`: wrapper to canonical
- These names remain only for deprecation tracking. Do not dispatch them directly.

## Manual Fallback (minimum)
- If timeout persists: run update-branch manually, then rerun canonical standalone workflow for the same issue.
- Recommended human entry:
  - `pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\mep.ps1 dispatch-standalone -IssueNumber <n> -Lane <SYSTEM|BUSINESS>`
- If checks keep failing: fix failing required checks first, then rerun.
