BUNDLE_VERSION = v0.0.0+20260122_045853+main+child
## CARD: EVIDENCE / WRITEBACK SPEC

[Adopted]
### 証跡ログ（自動貼り戻し）
# （初回は空。以降は EVIDENCE 子MEP writeback により追記される）

### 機械貼り戻し（実装）
- tools/mep_writeback_bundle.ps1（update / pr）
- .github/workflows/mep_writeback_bundle_dispatch.yml（workflow_dispatch）
- PR #1048 | mergedAt=01/21/2026 15:02:00 | mergeCommit=adf666885beb054fdfa3fae31d0af4b37c78c31f | BUNDLE_VERSION=v0.0.0+init | audit=OK,WB0000 | acceptance:SUCCESS, Business Packet Guard (PR):SUCCESS, done_check:SUCCESS, enable_auto_merge:SUCCESS, guard:SUCCESS, merge_repair_pr:SKIPPED, self-heal:SUCCESS, semantic-audit-business:SUCCESS, semantic-audit:SUCCESS, suggest:SUCCESS, Text Integrity Guard (PR):SUCCESS | https://github.com/Osuu-ops/yorisoidou-system/pull/1048
- PR #1049 | mergedAt=01/21/2026 15:40:00 | mergeCommit=194a29a256ae05f126a2c158da45dd7785ed056c | BUNDLE_VERSION=v0.0.0+20260122_004000+fix/bundle-refresh-pr1015+evidence-child | audit=OK,WB0000 | acceptance:IN_PROGRESS, Business Packet Guard (PR):IN_PROGRESS, done_check:SUCCESS, enable_auto_merge:IN_PROGRESS, guard:IN_PROGRESS, merge_repair_pr:SKIPPED, self-heal:IN_PROGRESS, semantic-audit-business:IN_PROGRESS, semantic-audit:IN_PROGRESS, suggest:IN_PROGRESS | https://github.com/Osuu-ops/yorisoidou-system/pull/1049
- PR #1065 | mergedAt=01/21/2026 17:53:21 | mergeCommit=7a498c06bc89d6382867ad4707413d46c0f4af76 | BUNDLE_VERSION=v0.0.0+20260121_183632+main+evidence-child | audit=OK,WB0000 | acceptance:SUCCESS, Business Packet Guard (PR):SUCCESS, Current Scope Format Guard (PR):SUCCESS, done_check:SUCCESS, enable_auto_merge:SUCCESS, merge_repair_pr:SKIPPED, semantic-audit-business:SUCCESS, semantic-audit:SUCCESS, suggest:SUCCESS, Text Integrity Guard (PR):SUCCESS | https://github.com/Osuu-ops/yorisoidou-system/pull/1065
- PR #1069 | mergedAt=01/21/2026 18:52:40 | mergeCommit=373b1c1891dc947c7387c262aa35ae76c598711b | BUNDLE_VERSION=v0.0.0+20260121_185712+main+evidence-child | audit=OK,WB0000 | acceptance:SUCCESS, Business Packet Guard (PR):SUCCESS, Current Scope Format Guard (PR):SUCCESS, done_check:SUCCESS, enable_auto_merge:SUCCESS, merge_repair_pr:SKIPPED, semantic-audit-business:SUCCESS, semantic-audit:SUCCESS, suggest:SUCCESS, Text Integrity Guard (PR):SUCCESS | https://github.com/Osuu-ops/yorisoidou-system/pull/1069
- PR #1073 | mergedAt=01/21/2026 19:01:13 | mergeCommit=6fb2a2327cc80db36ecef5595913ab07dbaf560b | BUNDLE_VERSION=v0.0.0+20260122_043016+main+child | audit=OK,WB0000 | acceptance:SUCCESS, Business Packet Guard (PR):SUCCESS, done_check:SUCCESS, enable_auto_merge:SUCCESS, guard:SUCCESS, merge_repair_pr:SKIPPED, self-heal:SUCCESS, semantic-audit-business:SUCCESS, semantic-audit:SUCCESS, suggest:SUCCESS, Text Integrity Guard (PR):SUCCESS, update-state-summary:SKIPPED | https://github.com/Osuu-ops/yorisoidou-system/pull/1073
- PR #1075 | mergedAt=01/21/2026 19:36:14 | mergeCommit=68b86f044bdb54a448f327b11211af7960750536 | BUNDLE_VERSION=v0.0.0+20260122_043845+main+child | audit=OK,WB0000 | acceptance:SUCCESS, Business Packet Guard (PR):SUCCESS, done_check:SUCCESS, enable_auto_merge:SUCCESS, merge_repair_pr:SKIPPED, semantic-audit-business:SUCCESS, semantic-audit:SUCCESS, suggest:SUCCESS, Text Integrity Guard (PR):SUCCESS | https://github.com/Osuu-ops/yorisoidou-system/pull/1075
- PR #1077 | mergedAt=01/21/2026 19:42:24 | mergeCommit=d5c2facf70bb93ceee4f3e452b0157fe86ad6db2 | BUNDLE_VERSION=v0.0.0+20260121_194444+main+evidence-child | audit=OK,WB0000 | acceptance:SUCCESS, Business Packet Guard (PR):SUCCESS, done_check:SUCCESS, enable_auto_merge:SUCCESS, merge_repair_pr:SKIPPED, semantic-audit-business:SUCCESS, semantic-audit:SUCCESS, suggest:SUCCESS, Text Integrity Guard (PR):SUCCESS | https://github.com/Osuu-ops/yorisoidou-system/pull/1077
- PR #1079 | mergedAt=01/21/2026 19:53:07 | mergeCommit=da393defec73777a5ab9f5038f495a464438659d | BUNDLE_VERSION=v0.0.0+20260122_045338+main+child | audit=OK,WB0000 | acceptance:SUCCESS, Business Packet Guard (PR):SUCCESS, done_check:SUCCESS, enable_auto_merge:SUCCESS, merge_repair_pr:SKIPPED, semantic-audit-business:SUCCESS, semantic-audit:SUCCESS, suggest:SUCCESS, Text Integrity Guard (PR):SUCCESS | https://github.com/Osuu-ops/yorisoidou-system/pull/1079
- PR #1082 | mergedAt=01/21/2026 19:58:51 | mergeCommit=291bd76adc85dd3c7e71d53006374fe77504f372 | BUNDLE_VERSION=v0.0.0+20260122_045853+main+child | audit=OK,WB0000 | acceptance:SUCCESS, Business Packet Guard (PR):SUCCESS, done_check:SUCCESS, enable_auto_merge:SUCCESS, merge_repair_pr:SKIPPED, semantic-audit-business:SUCCESS, semantic-audit:SUCCESS, suggest:SUCCESS, Text Integrity Guard (PR):SUCCESS | https://github.com/Osuu-ops/yorisoidou-system/pull/1082
## CARD: EVIDENCE / CHILD MEP / COMPLETION

### 目的（この子MEPで何を独立させるか）
- EVIDENCE（証跡・貼り戻し・監査根拠）を子MEP単位で管理し、親MEP(main)の修正と分離して衝突を避ける。

### 接続と切り離し（運用ルール）
- 切り離し（独立運用）：
  - 変更・議論・仕様更新は基本この子MEP配下で完結させる（docs/MEP_SUB/EVIDENCE と businesses/evidence）。
- 接続（統合 / writeback）：
  - 証跡の「Bundled への固定」は workflow_dispatch で writeback を回し、生成PRを main にマージする。
  - evidence writeback は docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md に集約する（現行仕様の範囲で運用）。

### 管理対象（TARGETSと整合）
- businesses/evidence/TARGETS.yml に列挙された対象が、この子MEPの管理範囲（Scope）になる。

### 成功条件（この子MEPが“完成”と言える状態）
- [ ] EVIDENCE 子MEPの bundle に「目的 / 接続・切り離し / 管理対象 / 変更手順」が明記されている
- [ ] Evidence writeback が main 上で再現可能で、生成PRがマージ可能（監査ログが残る）
- [ ] businesses/evidence/TARGETS.yml が存在し、Scopeが運用できる

### 次にやること（最短）
1. businesses/evidence/TARGETS.yml の targets を実態に合わせて埋める
2. EVIDENCEのカード（仕様・運用・監査の粒度）を追加していく
3. 必要があれば「親MEPへ戻す情報」と「子MEPに留める情報」をルール化する

## CARD: EVIDENCE / OPS (TARGETS & WRITEBACK)  [Draft]

### 対象
- businesses/evidence/TARGETS.yml
- docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md

### 運用原則
- 証跡の真実は PR → main → Bundled（BUNDLE_VERSION）のみ
- 会話・手編集は採用対象外

### TARGETS 更新ルール
- 追加のみ（既存キーの削除・意味変更は禁止）
- 不明は unknown として明示し、推測で埋めない
- 採用は PR 作成をもって成立とする

### writeback 手順（PowerShell完結）
1) main にマージ済み PR を対象に writeback を実行  
   - Mode=pr / PrNumber 指定 / BundleScope=child
2) 生成された運搬PRを main にマージ
3) Bundled 上で BUNDLE_VERSION と証跡行を確認

### 監査観測点（最小）
- BUNDLE_VERSION が更新されていること
- 証跡ログに対象 PR 行が1本のみ存在すること
- mergedAt / mergeCommit が空でないこと

### 停止条件
- writeback 失敗、証跡欠損、重複行検出時は DIRTY とし次工程へ進まない
