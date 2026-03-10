# RESTART_PACKET Contract
Canonical restart contract for standalone artifacts, `mep/run_state.json.restart_bridge`, and 8-gate downstream restart output.

## Canonical Fields
- `CONTRACT_VERSION`: fixed `v1`
- `STATUS`: restart packet readiness. Current emitters write `READY`.
- `REASON_CODE`: machine-readable cause for this restart state.
- `NEXT_ACTION`: next machine action implied by this packet.
- `ISSUE_NUMBER`: source issue number.
- `LANE`: `SYSTEM` or `BUSINESS`.
- `SOURCE_PHASE`: emitter phase, for example `STANDALONE_ARTIFACT` or `GATE8_DOWNSTREAM`.
- `SOURCE_WORKFLOW`: canonical workflow or script path that emitted the record.
- `SOURCE_RUN_ID`: workflow run identifier when available.
- `SOURCE_RUN_URL`: workflow run URL when available.
- `SOURCE_PR_URL`: PR URL when available. This may be blank before a PR exists.
- `PACKET_PATH`: canonical `INPUT_PACKET.md` path for this issue/lane.
- `ARTIFACT_DIR`: canonical artifact directory for this issue/lane.
- `RESTART_PACKET_PATH`: path of the emitted restart packet artifact or mirror.
- `GENERATED_AT_UTC`: UTC timestamp in `YYYY-MM-DDTHH:MM:SSZ`.

## Canonical Storage
- Standalone artifact output: `docs/MEP/ARTIFACTS/<LANE>/ISSUE_<n>/RESTART_PACKET.txt`
- SSOT mirror: `mep/run_state.json.restart_bridge`
- 8-gate downstream output: `.mep/restart/ISSUE_<n>_RESTART_PACKET.txt`

## Producer Rules
- Standalone artifact generation emits `SOURCE_PHASE=STANDALONE_ARTIFACT` and `NEXT_ACTION=DISPATCH_8GATE_ENTRY`.
- Standalone bridge persists the same contract into `mep/run_state.json.restart_bridge`.
- 8-gate downstream emits `SOURCE_PHASE=GATE8_DOWNSTREAM` and `NEXT_ACTION=RESTART_PACKET_READY`.

## Consumer Rules
- `tools/runner/runner.py` reads `mep/run_state.json.restart_bridge` as the runtime mirror of this contract.
- `run_state.next_action` remains the runner control field and is not the canonical restart handoff definition.
- Legacy aliases (`source_issue_number`, `source_standalone_run_id`, `source_standalone_run_url`, `artifact_pr_url`, `restart_packet`) remain only for compatibility until handoff-side readers migrate.
