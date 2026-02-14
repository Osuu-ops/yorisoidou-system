# P4 Thresholds SSOT Operations
対象SSOT:
- docs/MEP/P4_THRESHOLDS_SSOT.md
目的:
- P4 LLM_FENCE の閾値（bytes/files/added/scope/keyword deny）を **単一の正**として固定する
- 閾値変更は **必ずPR経由**で行い、一次根拠（PR/commit）として残す
## 1) 正（Source of Truth）
- 閾値の正: docs/MEP/P4_THRESHOLDS_SSOT.md
- workflow実装は参照側（読み取り側）であり、固定値の二重管理は禁止
## 2) 変更手順（必ずPR）
1. docs/MEP/P4_THRESHOLDS_SSOT.md の値を編集
2. PR作成
3. Required checks 全SUCCESS
4. auto-merge → MERGED
5. main反映を一次根拠として固定
## 3) 変更のルール
- 変更は「最小差分」で行う
- allowlist/denylist を広げる変更は慎重に（レビュー必須）
- deny keyword は secrets/認証情報/危険実行（curl|sh 等）の検出を維持する
## 4) ENVブロック規約（BEGIN_ENV..END_ENV）
- BEGIN_ENV..END_ENV の中は `KEY=VALUE` のみ
- 必須キー:
  - P4_MAX_BYTES
  - P4_MAX_FILES
  - P4_MAX_ADDED
  - P4_ALLOW_REGEX
  - P4_DENY_REGEX
- 空/欠損は STOP_HARD とする（参照側で fail-fast）
## 5) 回帰
- v2入口（mep_llm_dispatch_entry_v2.yml）で
  - NO_DRAFT: 従来ルートが成立
  - WITH_DRAFT: DRAFT→patch→guard→apply→PR→MERGED が成立