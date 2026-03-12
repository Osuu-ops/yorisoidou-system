# MASTER_GOAL（固定｜上位目的｜不変）
このファイルは runner 生成物ではない（固定層）。  
チャットの会話文は正にならない。ここが上位目的の正。
## MASTER_GOAL
MEPを「実行（Runner）」「正（SSOT）」「証跡（EVIDENCE）」で分離し、
迷走・忘却・誤修正を構造で防ぎつつ、最終的に **完全自律で回る判断OS** にする。
## 完了条件（2段）
- 運用上の完成（A 完了）：実運用でほぼ無人で回る（事故が reason_code で自動収束）
- 完全OS完成（A+B 完了）：SSOT_SCAN / CONFLICT_SCAN / EXTRACT / Self-heal完全 を統合し、post-writeback + loop owned phase resume、canonical engine run completion 追跡、child run_state 解釈、主要 manual reason_code の canonical self-heal mapping 拡張、structural/manual hard stop の一部 status canonicalization と governance / PR lifecycle reason_code の一部 canonical command 化、`WAIT_LOOP_ENGINE` の unresolved / child-state-unavailable fallback の deterministic recovery まで含めて仕様本体までrunnerが責任を持つ
更新: 2026-02-15T14:09:16Z


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
