# ROADMAP_INDEX（固定｜全体地図｜母数固定）
このファイルは runner 生成物ではない（固定層）。  
「今どこ？」ではなく「全体のどこ？」を固定する。
---
## PHASE A：自動化の穴埋め（運用上の完成）
A-0 Runner/ACK 基盤：成立（既存）
A-1 PATCH型検査＋reason_code化：DONE（PR #2258, mergeCommit cd89534d…）
A-2 EVIDENCE_FOLLOW 整流（stale PR headRefOid → replace PR 自動）：DONE（PR #2259, mergeCommit 178b652f…）
A-3 merge-finish 自動DONE確定（手動バックフィル排除）：DONE（PR #2260, mergeCommit 5986dab1…）
A-4 apply-safe push non-FF 自動吸収：DONE（PR #2257, mergeCommit daf53fde…）
A-5 Runner PyCompile Guard：DONE（PR #2254, mergeCommit 952c980c…）
=> **PHASE A は完了（運用上の完成）**
---
## PHASE B：完全OS化（仕様本体の統合）
B-1 SSOT_SCAN：loop v2 から接続済 / phase state persisted / full completion 未
B-2 CONFLICT_SCAN：loop v2 から接続済 / phase state persisted / full completion 未
B-3 EXTRACT生成（LEDGER/INPUT_PACKET/health/cards）：write 接続済 / phase state persisted / writeback stage 接続済 / full completion 未
B-4 Self-heal 完全版（reason_code辞書→自動復帰）：post-writeback + loop owned phase resume 接続済 / `WAIT_LOOP_ENGINE` は canonical engine run と durable pointer 追跡まで接続済 / full completion 未
---
## Loop Canonical（現在）
- Entry: `.github/workflows/mep_loop_entry.yml`
- Engine: `.github/workflows/mep_loop_engine_v2.yml` (`workflow_dispatch`)
- Legacy v1: `.github/workflows/mep_loop_engine.yml.txt`（sealed）
- v2 wiring: `tools/checks/ssot_scan.py` / `tools/checks/conflict_scan.py` / `tools/extract/extract_generate.py` を呼ぶ
- Scope note: EXTRACT は write + writeback stage 接続済。post-writeback と loop owned phase resume は canonical loop entry 経由で接続済。`WAIT_LOOP_ENGINE` は canonical engine run url と durable artifact pointer を保持する。full self-heal completion は未
---
## 現在地（固定）
CURRENT_PHASE: A_DONE -> 次は B-1
NEXT_ITEM: B-1 SSOT_SCAN
更新: 2026-02-15T14:09:16Z
