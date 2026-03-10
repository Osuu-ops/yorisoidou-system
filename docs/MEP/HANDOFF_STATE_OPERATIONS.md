# MEP Handoff State Operations

## Purpose
`tools/mep_handoff_state.ps1` provides near-real-time handoff tracking with append-only events and a derived state snapshot.

It adds four safety layers:
- Auto sync from `CHECKPOINT_OUT` to Boot state (`BOOT_SYNCED`)
- Auto ack when `CHECKPOINT_IN` is detected for `next_chat_id` (`BOOT_ACKED`)
- TTL-based stale detection (`BOOT_EXPIRED`)
- One-paste handoff packet output (`-Action packet`)

## Scope note
- `tools/mep_handoff_state.ps1` is for handoff state only.
- For issue status, canonical standalone dispatch, run tracking, and PR tracking, use `tools/mep.ps1`.

## Files
- `docs/MEP/HANDOFF_EVENTS.jsonl`: append-only event log
- `docs/MEP/HANDOFF_STATE.json`: derived current snapshot
- `docs/MEP/CHAT_CHAIN_LEDGER.jsonl` and `docs/MEP/CHAT_CHAIN_LEDGER.md`: source ledger

## Daily Operation (Recommended)
1. Open one terminal and keep watcher running:
   `powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action watch -IntervalSec 5 -TtlMinutes 120`
2. In your normal work terminal(s), continue running your existing MEP scripts that append `CHECKPOINT_IN/OUT` to ledger.
3. Verify current health any time:
   `powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action status`

## One-Paste Handoff Packet
Run this at handoff timing:
`powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action packet`

Optional (attach chat-only delta + advice + cautions + recommended route in the same packet):
`powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action packet -Note "progress..." -Advice "advice..." -Cautions "do not..." -RecommendedRoute "phase -> item"`

Behavior:
- If a Boot exists for the target portfolio, packet outputs `REUSE_EXISTING_BOOT` with:
  - Boot data
  - `chat_only_delta`, `advice`, `cautions`, `recommended_route` sections
  - roadmap (`current_phase` / `next_item`)
- If no Boot exists, packet outputs `GENERATE_NEW_BOOT` with `next_powershell` generation block.
  - Runner is used when Python launcher exists.
  - Otherwise manual PowerShell fallback block is printed.

## Action Reference
- `-Action status`: sync + auto-ack + expire + print summary
- `-Action sync`: sync only + print summary
- `-Action ack`: add `BOOT_ACKED` for one boot
- `-Action close`: add `BOOT_CLOSED` for one boot
- `-Action expire`: force expiration check + print summary
- `-Action watch`: polling monitor for near-real-time changes
- `-Action packet`: print one paste-ready handoff block (Boot + delta + advice + cautions + recommended route + roadmap + generation instruction if needed)

## Notes
- Events are idempotent per `event_type + boot_id`.
- `observe` script remains read-only. State transitions are handled by this script.
- If no `-PortfolioId` is passed, portfolio is resolved from `mep/run_state.json` when possible.
