BUNDLE_VERSION = v0.0.0+20260131_143312+main+evidence-child
BUNDLE_VERSION = v0.0.0+20260131_142601+main+evidence-child
BUNDLE_VERSION = v0.0.0+20260130_141541+main+evidence-child

- 
PR #1081 | mergedAt=01/21/2026 19:58:11 | mergeCommit=fe1ef735bd1cedc57fc81ec6bfa3d72cb469ade7 | BUNDLE_VERSION=v0.0.0+20260121_195833+main+evidence-child | audit=OK,WB0000 | acceptance:SUCCESS, Business Packet Guard (PR):SUCCESS, done_check:SUCCESS, enable_auto_merge:SUCCESS, merge_repair_pr:SKIPPED, semantic-audit-business:SUCCESS, semantic-audit:SUCCESS, suggest:SUCCESS, Text Integrity Guard (PR):SUCCESS | https://github.com/Osuu-ops/yorisoidou-system/pull/1081
- 
PR #1082 | mergedAt=01/21/2026 19:58:51 | mergeCommit=291bd76adc85dd3c7e71d53006374fe77504f372 | BUNDLE_VERSION=v0.0.0+20260122_045853+main+child | audit=OK,WB0000 | acceptance:SUCCESS, Business Packet Guard (PR):SUCCESS, done_check:SUCCESS, enable_auto_merge:SUCCESS, merge_repair_pr:SKIPPED, semantic-audit-business:SUCCESS, semantic-audit:SUCCESS, suggest:SUCCESS, Text Integrity Guard (PR):SUCCESS | https://github.com/Osuu-ops/yorisoidou-system/pull/1082


PR #1353 | audit=OK,WB0000 | appended_at=2026-01-30T18:46:42Z | via=mep_append_evidence_line.ps1

PR #1395 | audit=OK,WB0000 | appended_at=2026-01-31T05:15:56Z | via=mep_append_evidence_line.ps1



## CARD: EVIDENCE / PRE_GATE / SCOPE_IN & DOD  [Draft]

### 目的
- PRE_GATE 完全自動化の前提（Scope-IN / Done Definition）を、EVIDENCE_BUNDLE 側の一次根拠として固定する。

### Scope-IN（このカードが扱う範囲）
- 対象: PRE_GATE の「自動化前提」を満たすための定義と観測点（Scope-IN / DoD / Stop条件 / Evidence参照）。
- 対象外: 実装コード詳細、個別PRの作業ログ、親Bundled側の追跡。

### Done Definition（DoD）
- [ ] EVIDENCE_BUNDLE に本カードが存在し、PR→main で固定されている。
- [ ] 子EVIDENCE_BUNDLEの最新 BUNDLE_VERSION と「最新 appended 証跡行（appended_at + via=mep_append_evidence_line.ps1）」が機械抽出で再現できる。
- [ ] Scope-IN / DoD / Stop条件が、このカード内で自己完結している（外部会話に依存しない）。

### 監査観測点（最小）
- 子EVIDENCE_BUNDLE: 先頭の BUNDLE_VERSION
- 子EVIDENCE_BUNDLE: 最新 appended 証跡行（PR #... | appended_at=... | via=mep_append_evidence_line.ps1）
- 親Bundled: BUNDLE_VERSION（基準点のみ。appended_at追跡はしない）

### Stop条件（DIRTY 扱い）
- 衝突マーカー（<<<<<<< / ======= / >>>>>>>）を検出した場合
- 証跡行の欠落（appended_at / via が無い、または最新抽出が不能）を検出した場合
- 証跡行の重複・順序崩れが疑われる場合（復元・整流を優先し、次工程へ進まない）

### Evidence参照（一次根拠）
- EVIDENCE_BUNDLE: docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md
- 親Bundled基準点: docs/MEP/MEP_BUNDLE.md（BUNDLE_VERSIONのみ）

