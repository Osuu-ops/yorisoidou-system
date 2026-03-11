# Handoff Official Entrypoint

## Policy
- `tools/mep_handoff_state.ps1` is the operational entrypoint for all handoff state transitions.
- `tools/mep_handoff_live.py` is the single mutation engine.
- `tools/mep_handoff.ps1` and `tools/mep_handoff_min.ps1` are packet-oriented wrappers only.
- `docs/WORKROOM` is the only source of truth.
- `docs/MEP/HANDOFF_*` exists only as compatibility mirror output generated from `docs/WORKROOM`.

## Human Flow
1. Work inside the active chat and update state through the entrypoint.
2. Emit one packet.
3. Paste that packet into the next chat.
4. The next chat accepts the packet before continuing.

## File Targets
- Canonical packet: `docs/WORKROOM/WORK_ITEMS/WORK_<ID>/HANDOFF_PACKET.txt`
- Compatibility packet mirror: `docs/MEP/HANDOFF_PACKET.txt`
- Live work index: `docs/WORKROOM/ACTIVE_INDEX.json`
- Archive index: `docs/WORKROOM/ARCHIVE_INDEX.json`
- Control tower: `docs/WORKROOM/CONTROL_TOWER.md`
