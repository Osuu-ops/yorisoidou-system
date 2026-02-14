# P3_REASON_CODE_SSOT（Dispatch Entry v2）
対象：.github/workflows/mep_llm_dispatch_entry_v2.yml
## 出力フォーマット（必須）
- STOP_KIND=<WAIT|HARD>
- REASON_CODE=<固定キー>
- NEXT=<次アクション固定>
## REASON_CODE 一覧（固定）
### HARD
- P3_PUSH_FAILED : git push が失敗（認証/権限/ネットワーク）
  - NEXT=RETRY_DISPATCH_AFTER_TOKEN_CHECK
- P3_PR_CREATE_FAILED : PR作成が失敗
  - NEXT=RETRY_DISPATCH_OR_OPEN_MANUAL_PR
- P3_REQUIRED_CHECKS_SSOT_PARSE_FAILED : REQUIRED_CHECKS_SSOT が読めない/空
  - NEXT=FIX_SSOT_FORMAT
- P3_PR_NUMBER_PARSE_FAILED : PR_URL から番号抽出失敗
  - NEXT=FIX_PR_URL_PARSE
### WAIT
- P3_NO_CHECKS_TIMEOUT : required checks が期限までにSUCCESSにならない
  - NEXT=RETRY_DISPATCH_LATER
- P3_AUTOMERGE_REQUEST_FAILED : auto-merge要求が失敗（Ruleset/権限）
  - NEXT=RETRY_MERGE_REQUEST
## 備考
- v2入口を正とする（ENTRY_CANONICAL.md参照）
---
## Addendum: v2 DRAFT->PATCH flow (P4 thresholds SSOT) reason_code candidates
この節は v2入口に統合された DRAFT->PATCH フローで発生し得る停止を、運用品質のために固定する。
### STOP_HARD（即停止・再実行しても改善しない類）
- OPENAI_API_KEY_MISSING
  - secrets.OPENAI_API_KEY 未設定
- DRAFT_EMPTY
  - DRAFT_START..DRAFT_END があるが本文が空
- P4_THRESHOLDS_SSOT_NOT_FOUND / P4_THRESHOLDS_ENV_BLOCK_EMPTY / P4_THRESHOLDS_MISSING_KEY
  - SSOT破損・欠損（BEGIN_ENV..END_ENV）
- BINARY_DIFF_FORBIDDEN
  - binary patch 検出（禁止）
- DANGEROUS_DIFF_FORBIDDEN
  - delete/rename/mode 変更検出（禁止）
- DANGEROUS_KEYWORD_DETECTED
  - deny keyword 検出（secrets/Authorization Bearer/curl|sh等）
- SCOPE_VIOLATION
  - allowlist外パスへの差分
- PATCH_TOO_LARGE / TOO_MANY_FILES / TOO_MANY_ADDED_LINES
  - 閾値超過（SSOTの上限）
### STOP_SOFT（再実行で改善し得る類）
- PATCH_EMPTY_OR_INVALID
  - unified diff が空/壊れている等（プロンプト調整で改善し得る）
- APPLY_CHECK_FAILED
  - git apply --check が失敗（文脈差分/パッチ精度の問題）
### NOTE（運用）
- reason_code はログ・再開パケットの NEXT 決定に利用する
- 変更はSSOTへ追記し、workflow側は参照する
