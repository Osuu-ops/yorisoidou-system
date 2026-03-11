# Handoff State Operations

## Official State Root
- SSOT: `docs/WORKROOM/WORK_ITEMS/WORK_<ID>/`
- Derived index: `docs/WORKROOM/ACTIVE_INDEX.json`
- Derived index: `docs/WORKROOM/ARCHIVE_INDEX.json`
- Derived view: `docs/WORKROOM/CONTROL_TOWER.md`
- Compatibility mirror only: `docs/MEP/HANDOFF_*`

## Entrypoints
- Main PowerShell entry: `tools/mep_handoff_state.ps1`
- Packet shortcut: `tools/mep_handoff.ps1`
- Minimal packet shortcut: `tools/mep_handoff_min.ps1`
- Python core: `tools/mep_handoff_live.py`

## Actions
- `-Action start`: create a new tracked work item and initial branch.
- `-Action update`: append a boundary event and rebuild derived state.
- `-Action split`: create a new branch path under the current work.
- `-Action select-branch`: move the primary branch to a chosen live branch.
- `-Action drop-branch`: close a non-primary branch as dropped.
- `-Action merge-branch`: close a branch as merged back into a target branch.
- `-Action packet`: emit a universal packet and move to `HANDOFF_READY`.
- `-Action accept`: CAS-accept a packet and transfer active ownership.
- `-Action complete`: mark the work `DONE` after evidence validation.
- `-Action archive`: move a verified done work into immutable archive.
- `-Action restore`: return archived work to active area as `BLOCKED`.
- `-Action status`: print active work summary or a specific work summary.
- `-Action verify`: validate SSOT, derived files, packet, indexes, and locks.
- `-Action rebuild`: rebuild derived files from event log and meta.
- `-Action doctor`: repair stale locks, prepared txns, and missing derived artifacts.

## Minimal Examples
```powershell
powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action start -Actor CODEX -CurrentGoal "Build handoff OS" -CurrentStage "implementation" -CurrentState "starting" -NextAction "Create packet"
powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action update -Actor CODEX -WorkId WORK_... -EventType PLAN_SET -CurrentState "plan-fixed" -NextAction "Split branch"
powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action split -Actor CODEX -WorkId WORK_... -BranchName "experiment-a"
powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action packet -Actor CODEX -WorkId WORK_... -ToActor GPT
powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action accept -Actor GPT -WorkId WORK_... -PacketPath docs\WORKROOM\WORK_ITEMS\WORK_...\HANDOFF_PACKET.txt
powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action complete -Actor CODEX -WorkId WORK_...
powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action archive -Actor CODEX -WorkId WORK_...
powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action restore -Actor GPT -WorkId WORK_...
powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action verify
```

## Operational Notes
- Human handoff always uses one packet only.
- New chats should accept the packet before continuing work.
- `docs/MEP/HANDOFF_PACKET.txt` is a mirror, not the write target.
- If `verify` returns `STOP_HARD`, do not continue by inference. Use `doctor` or explicit human intervention.
