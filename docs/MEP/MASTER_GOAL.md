# MASTER_GOAL（固定｜上位目的｜不変）
このファイルは runner 生成物ではない（固定層）。  
チャットの会話文は正にならない。ここが上位目的の正。
## MASTER_GOAL
MEPを「実行（Runner）」「正（SSOT）」「証跡（EVIDENCE）」で分離し、
迷走・忘却・誤修正を構造で防ぎつつ、最終的に **完全自律で回る判断OS** にする。
## 完了条件（2段）
- 運用上の完成（A 完了）：実運用でほぼ無人で回る（事故が reason_code で自動収束）
- 完全OS完成（A+B 完了）：SSOT_SCAN / CONFLICT_SCAN / EXTRACT / Self-heal完全 を統合し、仕様本体までrunnerが責任を持つ
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
