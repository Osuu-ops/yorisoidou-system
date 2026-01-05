# STATE_CURRENT (MEP)

## Doc status registry（重複防止）
- docs/MEP/DOC_REGISTRY.md を最初に確認する (ACTIVE/STABLE/GENERATED)
- STABLE/GENERATED は原則触らない（目的明示の専用PRのみ）

## CURRENT_SCOPE (canonical)
- platform/MEP/03_BUSINESS/よりそい堂/**

## Guards / Safety
- Required checks は「PRで必ず表示されるチェック名」のみに限定する（schedule/dispatch専用チェック名を入れると永久BLOCKEDになり得る）。
- Text Integrity Guard (PR): enabled
- Halfwidth Kana Guard: enabled
- UTF-8/LF stabilization: enabled (.gitattributes/.editorconfig)

## Current objective
- 2026-01-06: (GAS) WRITE endpoint is B21 (B20 + compat: status<->requestStatus sync + request.list_status): https://script.google.com/macros/s/AKfycbw2moBfgg13VaxGPNQDj-2vGzai5GZXHGpZP4bkNib3h12mVsldCCkwAfEvVAgbCs2-3Q/exec
- 2026-01-06: (GAS) B21 verified: status and requestStatus kept in sync (OPEN/RESOLVED/CANCELLED); list_status works; resolve-after-cancel rejected on https://script.google.com/macros/s/AKfycbw2moBfgg13VaxGPNQDj-2vGzai5GZXHGpZP4bkNib3h12mVsldCCkwAfEvVAgbCs2-3Q/exec
- 2026-01-06: (NEXT) B22: TBD (define next theme)
- 2026-01-06: (GAS) B20 verified: cancel_request sets CANCELLED; resolve after cancel rejected (ok=false); Request.get reflects CANCELLED on https://script.google.com/macros/s/AKfycbwkdXO0x3SPLgvCSvn11NakOKDXCsROJCPZpDQKiyN1JGV0TwN1v-2Z7YyJd-EC4fNhwg/exec
- 2026-01-06: (NEXT) B21: TBD (define next theme)
- 2026-01-06: (GAS) B19 verified: default strict NOT_FOUND_RECOVERY (no Recovery create) + opt-in autoCreateRecovery created Recovery_Queue then LINKED on https://script.google.com/macros/s/AKfycbxTpul-Tdtce5V-MOTVofNumceEpEaQKD70fT66PL1mPo2YpTa0D6XmKehmoJwPj5HhJA/exec
- 2026-01-06: (NEXT) B20: TBD (define next theme)
- 2026-01-06: (PR #562) master_spec: ledger reflection for delete/FREEZE/Request(FIX) (v1.0) — ledger columns/keys + minimal rules
- 2026-01-06: (GAS) B18 verified: READ ops returned expected rows (rqKey/requestKey) on https://script.google.com/macros/s/AKfycby-lrrbKhIJHMNV85bzwUAFhNuffbTxuBzLHGTtmIJM2vxy4XdI95cxUkbsCz_bw59uZw/exec
- 2026-01-06: (NEXT) B19: TBD (define next theme)
- 2026-01-06: (NEXT) B18: add READ ops for verification/troubleshooting (recovery_queue.get/list_unlinked, request.get/list_open)
- 2026-01-06: (GAS) B17-1 verified: Request.upsert_open_dedupe links Recovery_Queue.requestRef when recoveryRqKey (==rqKey) is provided; policy A = overwrite forbidden (CONFLICT).
- 2026-01-06: (GAS) B17-1 linkageStatus fixed: LINKED | NOT_FOUND_RECOVERY | CONFLICT | ERROR; dryRun=true => op=noop (no writes).
- 2026-01-06: (GAS) Spreadsheet ID (Ledger): 1VWqQXs9HAvZQ7K9fKXa4M0BHrvvsZW8qZBJHqoCCE3I (Sheets: Recovery_Queue / Request)
- 2026-01-06: (NEXT) B17: Recovery_Queue ↔ Request linkage (requestRef/recoveryRqKey) in write endpoint
- 2026-01-05: (PR #509) tools/mep_integration_compiler/collect_changed_files.py: accept tab-less git diff -z output (rename/copy parsing robustness)
- Build and refine Yorisoidou BUSINESS master_spec and UI spec under the above scope.
- 2026-01-05: (PR #479) Decision-first（採用/不採用→採用後のみ実装）を正式採用
- 2026-01-05: (PR #483) Phase-2 Integration Contract（Todoist×ClickUp×Ledger）を business_spec に追加

## How to start a new conversation
Tell the assistant:
- "Read docs/MEP/START_HERE.md and proceed."
- (If memory=0 / new chat) paste CHAT_PACKET_MIN first (tools/mep_chat_packet_min.ps1 output).






