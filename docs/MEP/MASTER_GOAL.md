# MASTER_GOAL（固定｜上位目的｜不変）
このファイルは runner 生成物ではない（固定層）。  
チャットの会話文は正にならない。ここが上位目的の正。
## MASTER_GOAL
MEPを「実行（Runner）」「正（SSOT）」「証跡（EVIDENCE）」で分離し、
迷走・忘却・誤修正を構造で防ぎつつ、最終的に **完全自律で回る判断OS** にする。
## 完了条件（2段）
- 運用上の完成（A 完了）：通常運用はほぼ無人で回り、仕様上の停止境界は `status` で観測して人判断へ渡す
- 完全OS完成（A+B 完了）：SSOT_SCAN / CONFLICT_SCAN / EXTRACT / Self-heal完全 を統合し、post-writeback + loop owned phase resume、canonical engine run completion 追跡、child run_state 解釈、主要 manual reason_code の canonical self-heal mapping 拡張、structural/manual hard stop の一部 status canonicalization と governance / PR lifecycle reason_code の一部 canonical command 化、persistent loop structural reason の hard stop 維持理由と canonical inspection=status の明文化、environment / patch prerequisite hard stop の canonical observation=status 整理、`WAIT_LOOP_ENGINE` の unresolved / child-state-unavailable fallback の deterministic recovery と、loop_state / handoff の durable-first cleanup まで含めて仕様本体までrunnerが責任を持つ
更新: 2026-02-15T14:09:16Z

## 実運用完成線（固定）
- 自動継続範囲: post-writeback resume、loop owned phase resume、durable-first handoff、governance / PR lifecycle reason_code の主要 canonical mapping まで
- 仕様上の停止境界: `LOOP_ENGINE_RUN_UNRESOLVED_PERSISTENT`、`LOOP_ENGINE_CHILD_STATE_UNAVAILABLE_PERSISTENT`、`REPO_NOT_SET`、`PATCH_DOES_NOT_APPLY`
- 停止境界の canonical inspection: `python tools/runner/runner.py status`
- full self-heal は未完: persistent structural loop reason の自動復旧や patch / environment 自動修復までは含まない

## 残る未完（backlog 3群）
- persistent structural loop boundary: `LOOP_ENGINE_RUN_UNRESOLVED_PERSISTENT` と `LOOP_ENGINE_CHILD_STATE_UNAVAILABLE_PERSISTENT` は bounded retry exhaustion 後の停止境界として維持する
- evidence / PR ambiguity: truly ambiguous な複数 open PR や evidence 不足は canonical command を持つが、最終判断は人が行う
- environment / patch prerequisite: `REPO_NOT_SET` と `PATCH_DOES_NOT_APPLY` は canonical observation=`status` まで整理済みで、自動修復は未実装

## 運用メモ
- 通常運用は完成とみなす
- full self-heal は backlog として扱う
- 以後の追加自動化は micro PR 単位ではなく、backlog 群ごとにまとめて着手する


## UPDATE（Adopted）：完全自動ループ網羅（自動完了）
MEPは、人間操作なしで end-to-end の閉ループを完了する（SUCCESS または STOP で自動終端し、証跡と再開情報を残す）。
### 単一実行契約（Execution Contract）
- I/O（入力→出力）を固定
- reason_code / STOP_CLASS を固定
- 証跡（EVIDENCE / LEDGER）を固定
- 冪等性（同じ入力で同じ収束）を保証
- 収束（無限修復しない）を保証
### 最小必須8ゲート（網羅の定義）
1. BOOT/ENTRY
2. SSOT_SCAN
3. CONFLICT_SCAN
4. APPLY/GENERATE
5. PR_CREATE
6. PR_CHECKS（Required checks）
7. MERGE_FINISH
8. RESTART_PACKET

## UPDATE（Adopted）：単体AUTO_LOOP（SYSTEM/BUSINESS両対応）の完了条件（成果物→ダウンロード→次ゲート）
最優先：まず「完成成果物」を生成し、人間がローカルへ落とせる形（Actions Artifacts / Repo files）で提供する。
この流れが成立した後にのみ、次ゲート（8ゲート入口）へ止まらず進む自動化へ接続する。
### 単体AUTO_LOOP（8ゲート非接続・安全分離）
入力：GitHub Issue（label: `mep-loop`）
レーン選択：
- label `mep-biz` があれば BUSINESS
- それ以外は SYSTEM
出力：
- Actions Artifacts（ユーザーがダウンロード可能）
- Repo上の成果物（PRで一次根拠化）
- Issueコメント「できました」＋Run/Artifacts/パス提示
必須成果物（レーン別フォルダを必ず生成）：
- docs/MEP/ARTIFACTS/SYSTEM/ISSUE_<n>/AUDIT.md
- docs/MEP/ARTIFACTS/SYSTEM/ISSUE_<n>/MERGED_DRAFT.md（草案本文1つ）
- docs/MEP/ARTIFACTS/SYSTEM/ISSUE_<n>/INPUT_PACKET.md（8ゲート入口へ差し込み可能）
- docs/MEP/ARTIFACTS/SYSTEM/ISSUE_<n>/RUN_SUMMARY.md
- docs/MEP/ARTIFACTS/SYSTEM/ISSUE_<n>/RESTART_PACKET.txt（canonical restart contract。詳細は docs/MEP/RESTART_PACKET_CONTRACT.md）
- docs/MEP/ARTIFACTS/BUSINESS/ISSUE_<n>/AUDIT.md
- docs/MEP/ARTIFACTS/BUSINESS/ISSUE_<n>/MERGED_DRAFT.md（草案本文1つ）
- docs/MEP/ARTIFACTS/BUSINESS/ISSUE_<n>/INPUT_PACKET.md（8ゲート入口へ差し込み可能）
- docs/MEP/ARTIFACTS/BUSINESS/ISSUE_<n>/RUN_SUMMARY.md
- docs/MEP/ARTIFACTS/BUSINESS/ISSUE_<n>/RESTART_PACKET.txt（canonical restart contract。詳細は docs/MEP/RESTART_PACKET_CONTRACT.md）
### 接続条件（次ゲートへ入る前提）
- 単体AUTO_LOOPが上記成果物を生成し、ユーザーがダウンロードできること
- INPUT_PACKET.md が生成済みであること
- 8ゲート入口は別ワークフローで受け、単体AUTO_LOOPからは呼ばない（安全）
