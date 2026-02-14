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
