# BOOT HANDOFF PROTOCOL
## Fixed assets
- Observe tool: `tools/mep_handoff_observe.ps1`
- Human-readable map: `docs/MEP/BOOT_MAP.md`
- Machine-readable map: `docs/MEP/BOOT_MAP.json`
- Ledger (human): `docs/MEP/CHAT_CHAIN_LEDGER.md`
- Ledger (machine, optional): `docs/MEP/CHAT_CHAIN_LEDGER.jsonl`
## Scope note
- `tools/mep_handoff_observe.ps1` is only for boot/handoff recovery.
- Normal human observe/dispatch flow for issue -> run -> PR uses `docs/MEP/HUMAN_POWERSHELL_ENTRY.md` and `tools/mep.ps1`.
## Operating rule
1. Run `tools/mep_handoff_observe.ps1`
2. Paste output to chat
3. If exact exists, chat writes final boot block
4. If exact does not exist, chat writes generation code
5. After generation, paste result and continue
## Matching policy
- EXACT = portfolio_id + main_head
- NEAR = portfolio_id + primary_anchor
- HISTORY = portfolio_id only
## Map policy
- CURRENT = exact adopted boot
- COMPARE = near candidate
- ARCHIVE_CANDIDATE = old history candidate
- BROKEN = placeholder / corrupted row
## Notes
- If jsonl exists, prefer jsonl over markdown for machine judgment.
- Observe tool itself must remain read-only.
- Boot generation / deletion are separate action blocks, not embedded writes in observe mode.
