# MEP SYSTEM MAP v1.0（固定図｜母数固定｜Runner-led）
目的：MEP全体を層（Layer）で固定し、拡張しても崩れない全体地図を提供する。
実行の正は runner と SSOT（mep/run_state.json）。本図は人間の再開・監査・拡張判断のために用いる。
## 正の入口 / 正のSSOT
- 実行入口（正）: python tools/runner/runner.py <cmd>
- 機械SSOT（正）: mep/run_state.json
- 人間用再開口: docs/MEP/HANDOFF_WORK.md
- 監査用: docs/MEP/HANDOFF_AUDIT.md
- 現在地表示: docs/MEP/STATUS.md
## 層構造（固定）
Layer0: GitHub入口/起動
Layer1: Runner Execution（完成：boot/status/apply/pr-probe/pr-create/assemble-pr/apply-safe/merge-finish/compact）
Layer2: SSOT統合/検査（SSOT_SCAN / CONFLICT_SCAN：未統合）
Layer3: Extract/派生生成（DECISION_LEDGER/INPUT_PACKET/health/cards：未実装）
Layer4: Self-heal（最小版→完全版へ）
Layer5: Governance（契約/停止/証跡/圧縮）
## 未統合レイヤー（固定）
A) SSOT_SCAN：MEP_SSOT_MASTER(Q整合/RULE-0単一解化/PATCH競合/business-system混在)
B) CONFLICT_SCAN：旧WORK_ID系 vs 新RUN系 / forbidden path / allowed_paths逸脱
C) EXTRACT生成：DECISION_LEDGER.md / INPUT_PACKET.md / health.md / cards
D) Self-heal完全版：push retry / gh fallback / check再取得 / reason_code→自動復帰
