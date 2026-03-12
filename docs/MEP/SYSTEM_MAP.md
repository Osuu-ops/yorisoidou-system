# MEP SYSTEM MAP v1.0（固定図｜母数固定｜Runner-led）
目的：MEP全体を層（Layer）で固定し、拡張しても崩れない全体地図を提供する。
実行の正は runner と SSOT（mep/run_state.json）。本図は人間の再開・監査・拡張判断のために用いる。
## 正の入口 / 正のSSOT
- 実行入口（正）: python tools/runner/runner.py <cmd>
- Loop entry（GitHub）: .github/workflows/mep_loop_entry.yml
- Loop engine（canonical）: .github/workflows/mep_loop_engine_v2.yml (workflow_dispatch from loop entry)
- Loop engine v1: .github/workflows/mep_loop_engine.yml.txt（sealed legacy）
- 機械SSOT（正）: mep/run_state.json
- 人間用再開口: docs/MEP/HANDOFF_WORK.md
- 監査用: docs/MEP/HANDOFF_AUDIT.md
- 現在地表示: docs/MEP/STATUS.md
## 層構造（固定）
Layer0: GitHub入口/起動
Layer1: Runner Execution（完成：boot/status/apply/pr-probe/pr-create/assemble-pr/apply-safe/merge-finish/compact）
Layer2: SSOT統合/検査（loop v2 から既存 SSOT_SCAN / CONFLICT_SCAN 実装を呼出し。phase state は run_state へ保存。全体統合は未）
Layer3: Extract/派生生成（loop v2 から extract_generate に write 接続。phase state は run_state へ保存。canonical EXTRACT outputs は writeback stage 対象。full completion は未）
Layer4: Self-heal（post-writeback + loop owned phase resume は canonical loop entry 経由で接続済。`WAIT_LOOP_ENGINE` は canonical engine run の completion 観測と durable pointer を保持し、child run_state.next_action / loop_state を親 refresh で解釈。主要 manual reason_code は canonical self-heal command に拡張写像済で、structural/manual hard stop の一部は `status` へ canonical 化済、governance / PR lifecycle reason_code の一部も `status` / `pr-create` / `merge-finish` へ canonical 化済、persistent loop structural reason は hard stop のまま `status` を canonical inspection command に固定し、`WAIT_LOOP_ENGINE` の unresolved / child-state-unavailable も retry境界つき deterministic recovery に整理済で、loop_state と handoff は durable pointer を主表示・workspace path を補助表示に整理済で、STATUS / HANDOFF は `STOP_BOUNDARY` を表示するが、full completion は未）
Layer5: Governance（契約/停止/証跡/圧縮）
## 運用停止境界（固定）
- 停止境界: `LOOP_ENGINE_RUN_UNRESOLVED_PERSISTENT`、`LOOP_ENGINE_CHILD_STATE_UNAVAILABLE_PERSISTENT`、`REPO_NOT_SET`、`PATCH_DOES_NOT_APPLY`
- これらは bounded retry exhaustion または prerequisite 不足後の仕様上の停止境界であり、自動復旧へは戻さない
- canonical inspection: `python tools/runner/runner.py status`

## 運用完成 / 未完 の線引き
- 運用完成: canonical loop / writeback / handoff までの通常運用は可能
- 停止境界: `STATUS.md` / `HANDOFF_AUDIT.md` / `HANDOFF_WORK.md` の `STOP_BOUNDARY` で判別する
- 未完 backlog:
  - persistent structural loop boundary
  - evidence / PR ambiguity の truly ambiguous case
  - environment / patch prerequisite の自動修復

## 未統合レイヤー（固定）
A) SSOT_SCAN：MEP_SSOT_MASTER(Q整合/RULE-0単一解化/PATCH競合/business-system混在)
B) CONFLICT_SCAN：旧WORK_ID系 vs 新RUN系 / forbidden path / allowed_paths逸脱
C) EXTRACT生成：DECISION_LEDGER.md / INPUT_PACKET.md / health.md / cards
D) Self-heal完全版：push retry / gh fallback / check再取得 / reason_code→自動復帰（主要 manual reason_code mapping、structural/manual hard stop の一部 status 化、governance / PR lifecycle reason_code の一部 canonical command 化、persistent loop structural reason の hard stop 維持理由と canonical inspection=status 明文化、environment / patch prerequisite hard stop の canonical observation=status 整理、loop_state / handoff の durable-first cleanup までは拡張済、全辞書化は未）
