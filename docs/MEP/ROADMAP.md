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
B-4 Self-heal 完全版（reason_code辞書→自動復帰）：post-writeback + loop owned phase resume 接続済 / `WAIT_LOOP_ENGINE` は canonical engine run の completion refresh と durable pointer 追跡まで接続済 / child engine success は child run_state.next_action / loop_state を解釈して close せず親 state に反映 / 主要 manual reason_code は canonical self-heal mapping を拡張済 / structural/manual hard stop の一部は `status` へ canonical 化済 / governance / PR lifecycle reason_code の一部は `status` / `pr-create` / `merge-finish` へ canonical 化済 / `WAIT_LOOP_ENGINE` の unresolved / child-state-unavailable は retry境界つき deterministic recovery へ整理済 / persistent loop structural reason は hard stop 維持理由と canonical inspection=status を明文化済 / environment / patch prerequisite hard stop は canonical observation=status に整理済 / loop_state と handoff は durable-first に整理済 / full completion 未
---
## Loop Canonical（現在）
- Entry: `.github/workflows/mep_loop_entry.yml`
- Engine: `.github/workflows/mep_loop_engine_v2.yml` (`workflow_dispatch`)
- Legacy v1: `.github/workflows/mep_loop_engine.yml.txt`（sealed）
- v2 wiring: `tools/checks/ssot_scan.py` / `tools/checks/conflict_scan.py` / `tools/extract/extract_generate.py` を呼ぶ
- Scope note: EXTRACT は write + writeback stage 接続済。post-writeback と loop owned phase resume は canonical loop entry 経由で接続済。`WAIT_LOOP_ENGINE` は canonical engine run url/status/conclusion と durable artifact pointer を保持し、completed 時は child run_state.next_action / loop_state を解釈して親 state を継続または完了へ分岐する。主要 manual reason_code は `pr-probe` / `loop-resume` / `loop-wait-refresh` / `status` / `pr-create` / `merge-finish` などの canonical self-heal command に寄せ、governance / PR lifecycle reason_code の一部も同じ辞書で吸収し、`WAIT_LOOP_ENGINE` の unresolved / child-state-unavailable も retry境界つき deterministic recovery に整理し、persistent loop structural reason は hard stop のまま `status` を canonical inspection command に固定し、environment / patch prerequisite hard stop も `status` を canonical observation command に固定し、loop_state と handoff は durable pointer を主表示・workspace path を補助表示に整理したが、full self-heal completion は未
---
## 運用完成線（固定）
- 通常運用は canonical loop / writeback / handoff まで自動継続する
- persistent structural loop reason と environment / patch prerequisite は仕様上の停止境界として扱う
- 停止境界の canonical inspection は `python tools/runner/runner.py status`
- `STATUS.md` / `HANDOFF_AUDIT.md` / `HANDOFF_WORK.md` は `STOP_BOUNDARY` を表示する
---
## 現在地（固定）
CURRENT_PHASE: A_DONE -> 次は B-1
NEXT_ITEM: B-1 SSOT_SCAN
更新: 2026-02-15T14:09:16Z
