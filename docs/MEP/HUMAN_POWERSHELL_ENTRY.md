# MEP Human PowerShell Entry

## Purpose
- Canonical human PowerShell entry for Codex-first operation: `tools/mep.ps1`
- PowerShell remains observe + `workflow_dispatch` only.
- File edits, patches, commits, and large refactors remain Codex-only.

## Canonical Entry
Run from repo root:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\mep.ps1 issue-status -IssueNumber 2920
```

## Core Commands
- `issue-status -IssueNumber <n> [-Lane SYSTEM|BUSINESS]`
  - Show issue URL, labels, strict lane result, artifact presence, latest run/PR URL, and next action.
- `dispatch-standalone -IssueNumber <n> [-Lane SYSTEM|BUSINESS] [-Watch]`
  - Dispatch the canonical standalone workflow: `.github/workflows/mep_standalone_autoloop_dispatch.yml`
- `run-status -RunId <id> [-Watch]`
  - Show workflow run status and related PR if one is visible in logs.
- `pr-status -PrNumber <n> [-Watch]`
  - Show PR state, merge state, required-check summary, and next action.

## Lane Rule
- Explicit `-Lane SYSTEM|BUSINESS` wins when valid.
- Otherwise labels are used.
- `mep-biz` -> `BUSINESS`
- `mep-system` -> `SYSTEM`
- No implicit `SYSTEM` fallback.
- Unresolved or conflicting lane is `STOP_HARD`.

## Special-Purpose Tools Kept Separate
- `tools/mep_handoff_observe.ps1`
  - Boot/handoff read-only observe tool.
- `tools/mep_handoff_state.ps1`
  - Boot/handoff state tracker and packet helper.
- `tools/runner/bootstrap_exec.ps1`
  - EXEC boot bootstrap only.
- `tools/runner/bootstrap.ps1`
  - DRAFT boot bootstrap only.

## Deprecated / Legacy
- `tools/runner/mep_observe_run.ps1`
  - Wrapper to `tools/mep.ps1 run-status`.
- `tools/mep_issue2400_structural_evidence.ps1`
  - Legacy sealed script with obsolete workflow assumptions.

## Notes
- This entry is for human observe/dispatch flow after Codex has prepared or updated code.
- For canonical standalone artifact generation, this entry only dispatches `.github/workflows/mep_standalone_autoloop_dispatch.yml`.