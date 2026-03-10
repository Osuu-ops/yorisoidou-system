# MEP Gate0/Entry Auto-Connect Contract

This document fixes the responsibility split for the unattended SYSTEM L1 path.

## Primary unattended path
1. `MEP Standalone Issue AutoLoop (Dual: SYSTEM/BUSINESS)` starts from issue (`mep-loop`) or its dispatch bridge.
2. Artifacts are generated and stored through PR (`auto/standalone_issue_*`).
3. Required checks must exist and pass before merge. Missing checks are hard-stop.
4. After merge, Gate0 audit is executed on `origin/main` (packet + draft + lane + issue consistency).
5. Gate0 dispatches `MEP 8-Gate Entry (Packet Filter)` with machine-readable bridge fields.
6. Entry validates packet contract and invokes `MEP 8-Gate Downstream`.
7. Downstream executes Gate1..Gate8 and emits restart packet + cycle evidence.

## Bridge payload (normalized)
- `packet_path`
- `source_entry_run_id`
- `source_issue_number`
- `source_lane`

## Evidence contract after Gate8
- `pr_url`
- `commit_sha`
- `workflow_run_url`
- `stop_class`
- `reason_code`
- `next_action`
- restart packet text file
- cycle evidence JSON file

## Manual maintenance paths (kept intentionally)
- `.github/workflows/mep_gate0_audit_compile_dispatch.yml` (`workflow_dispatch`)
- `.github/workflows/mep_8gate_entry_filter.yml` (`workflow_dispatch`)
- `.github/workflows/mep_8gate_downstream.yml` (`workflow_dispatch`)

Manual paths are fallback only; they are not required for the normal unattended issue cycle.
