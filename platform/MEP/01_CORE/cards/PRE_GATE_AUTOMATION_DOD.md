# PRE-GATE完全自動化：DoD（完成定義）

## 1. Done（成立条件：必須）
- PRが main にマージされ、Bundled（MEP_BUNDLE.md）の先頭 `BUNDLE_VERSION = ...` が更新されている
- Bundled内に、対象PRの証跡行として以下を含む行が存在する
  - `audit=OK,WB0000`
  - `acceptance:SUCCESS`
  - `guard:SUCCESS`
  - `Scope Guard (PR):SUCCESS`
  - `Text Integrity Guard (PR):SUCCESS`

## 2. 例外（SKIPPED許容の条件）
- `merge_repair_pr:SKIPPED` は既存運用上の発生があり得るため、他の必須がSUCCESSなら許容
- その他のSKIPPED許容は、ここへ追記してからのみ許容（追記もPR→main→Bundledが前提）

## 3. 監査一次根拠
- 会話やメモは確定根拠にしない
- 確定は **PR → main → Bundled** の証跡でのみ成立
