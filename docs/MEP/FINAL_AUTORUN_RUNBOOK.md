# FINAL AUTORUN RUNBOOK | Full Automation Wiring (OP-2 + OP-3 + OP-1)
This is the final wiring step after:
- OP-2 (Entry Audit primary evidence) is fixed on main
- OP-1 (Self-converge primary evidence) is fixed on main
- OP-3 (Scope Guard primary evidence) is fixed on main
## What this runner does
- Sync main
- Find the canonical writeback workflow (prefers .github/workflows/mep_writeback_bundle_dispatch_entry.yml)
- Run it on main (workflow_dispatch)
- If a writeback-like PR appears, observe checks and attempt to set auto-merge
- If DESYNC/NO_CHECKS are detected, it stops with a deterministic STOP code so recovery is reproducible
## How to run
From repo root:
- powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\mep_full_auto_runner.ps1
## STOP codes
- STOP_HARD_GH_AUTH: gh auth missing
- WAIT_NO_TARGET_PR: no PR produced by workflow
- WAIT_DESYNC_REISSUE_NEEDED: desync detected (follow OP-1 runbook)
- WAIT_NO_CHECKS_REISSUE_NEEDED: no checks observed (follow OP-1 runbook)
- WAIT_MONITOR: checks visible; monitor merge
NOTE: This runner intentionally does NOT bypass policies. It drives the loop using primary outputs and deterministic STOP points.

## Evidence: Full autorun replay (NO_CHECKS -> REISSUE) | 2026-02-11

- Trigger: workflow_dispatch writeback produced PR #2000 (https://github.com/Osuu-ops/yorisoidou-system/pull/2000)
- STOP: WAIT_NO_CHECKS_REISSUE_NEEDED (NO_CHECKS persisted after push/empty commit)
- Recovery: REISSUE -> PR #2001 (https://github.com/Osuu-ops/yorisoidou-system/pull/2001)
- Result: PR #2001 state=MERGED mergedAt=02/11/2026 13:21:19
- Confirm: HEAD(main)=5e8dcc3252dc071b4da08e4911af8355270c3874



## NO_CHECKS auto-recovery
- Runner now performs: push -> empty commit -> REISSUE automatically, then sets auto-merge when checks are visible.


## CONFLICTING auto-retry
- Runner now closes CONFLICTING PRs and retries workflow_dispatch (bounded attempts) to avoid deadlocks.

