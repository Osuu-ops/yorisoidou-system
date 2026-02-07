BUNDLE_VERSION = v0.0.0+20260204_035621+main+evidence-child
- 
PR #1081 | mergedAt=01/21/2026 19:58:11 | mergeCommit=fe1ef735bd1cedc57fc81ec6bfa3d72cb469ade7 | BUNDLE_VERSION=v0.0.0+20260121_195833+main+evidence-child | audit=OK,WB0000 | acceptance:SUCCESS, Business Packet Guard (PR):SUCCESS, done_check:SUCCESS, enable_auto_merge:SUCCESS, merge_repair_pr:SKIPPED, semantic-audit-business:SUCCESS, semantic-audit:SUCCESS, suggest:SUCCESS, Text Integrity Guard (PR):SUCCESS | https://github.com/Osuu-ops/yorisoidou-system/pull/1081
- 
PR #1082 | mergedAt=01/21/2026 19:58:51 | mergeCommit=291bd76adc85dd3c7e71d53006374fe77504f372 | BUNDLE_VERSION=v0.0.0+20260122_045853+main+child | audit=OK,WB0000 | acceptance:SUCCESS, Business Packet Guard (PR):SUCCESS, done_check:SUCCESS, enable_auto_merge:SUCCESS, merge_repair_pr:SKIPPED, semantic-audit-business:SUCCESS, semantic-audit:SUCCESS, suggest:SUCCESS, Text Integrity Guard (PR):SUCCESS | https://github.com/Osuu-ops/yorisoidou-system/pull/1082


PR #1353 | audit=OK,WB0000 | appended_at=2026-01-30T18:46:42Z | via=mep_append_evidence_line.ps1

PR #1395 | audit=OK,WB0000 | appended_at=2026-01-31T05:15:56Z | via=mep_append_evidence_line.ps1



-
7e4297e2295791c0815ce3adda98b779324eae94 Merge pull request #1900 from Osuu-ops/fix/op2-handoff-recovery_20260207_073847 (mergedAt: 02/07/2026 00:35:06) https://github.com/Osuu-ops/yorisoidou-system/pull/1900
-
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

PR #0 | audit=OK,WB0000 | appended_at=2026-01-31T14:42:08Z | via=mep_append_evidence_line.ps1


# appended_from_parent_bundle: PR #1567 | appended_at=2026-02-01T19:21:53Z
* - PR #1567 | mergedAt=02/01/2026 17:51:55 | mergeCommit=7c478c619b64273ac49645fb49ccbea88d9ff7a7 | BUNDLE_VERSION=v0.0.0+20260201_182352+main_46ca524 | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1567
PR #1567 | audit=OK,WB0000 | appended_at=2026-02-01T18:23:56.2688033+00:00 | via=mep_append_evidence_line_full.ps1
* - PR #1609 | mergedAt=02/01/2026 19:08:56 | mergeCommit=f543b230d3e86310230f3cceb3bfecd3ccdd7b2f | BUNDLE_VERSION=v0.0.0+20260131_143312+main+evidence-child | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1609

## EVIDENCE_SYNC (auto) : parent->docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md
- syncedAt: 2026-02-03 16:55:42
- source: docs/MEP/MEP_BUNDLE.md
- note: appended parent evidence lines for PR #1675

* - PR #1675 | mergedAt=02/03/2026 05:57:16 | mergeCommit=9f0d626d848ce1cf86fb7582ce2f2f63b27d8efa | BUNDLE_VERSION=v0.0.0+20260203_072104+main_e61b6b1 | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1675
PR #1675 | audit=OK,WB0000 | appended_at=2026-02-03T07:21:07.7141432+00:00 | via=mep_append_evidence_line_full.ps1

* - PR #1693 | mergedAt=02/03/2026 17:57:35 | mergeCommit=549eec03335f7d9c4a29df96d55d06c6611cf43f | BUNDLE_VERSION=v0.0.0+20260204_035621+main+evidence-child | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1693
PR #1693 | audit=OK,WB0000 | appended_at=2026-02-04T04:28:50.6300967+09:00 | via=mep_append_evidence_line_full.ps1
* - PR #1704 | mergedAt=02/03/2026 18:52:34 | mergeCommit=1bce71fccb087093e74433f9254fb1e9d0dc63cf | BUNDLE_VERSION=v0.0.0+20260204_035621+main+evidence-child | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1704
PR #1704 | audit=OK,WB0000 | appended_at=2026-02-04T04:46:31.5962450+09:00 | via=mep_append_evidence_line_full.ps1
* - PR #1710 | mergedAt=02/03/2026 19:25:31 | mergeCommit=34b5a6e00266fd8f344642d85b77e4a3dd574910 | BUNDLE_VERSION=v0.0.0+20260204_035621+main+evidence-child | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1710
PR #1710 | audit=OK,WB0000 | appended_at=2026-02-04T04:46:32.9873243+09:00 | via=mep_append_evidence_line_full.ps1
* - PR #1727 | mergedAt=02/03/2026 20:57:31 | mergeCommit=08230259a2d9ae18ff1f178ec69c37942b88f574 | BUNDLE_VERSION=v0.0.0+20260204_035621+main+evidence-child | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1727
PR #1727 | audit=OK,WB0000 | appended_at=2026-02-04T08:03:13.3012007+09:00 | via=mep_append_evidence_line_full.ps1

----
SYNC_FROM_PARENT_BUNDLED | copied_at=2026-02-04T20:10:44.2074935+09:00 | via=manual_patch_child_evidence_from_parent.ps1
* - PR #1738 | mergedAt=02/04/2026 00:13:51 | mergeCommit=14c5e8c1041cc5279f4af963219ad3f22af2597e | BUNDLE_VERSION=v0.0.0+20260204_193735+main_8f9f7b3 | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1738
PR #1738 | audit=OK,WB0000 | appended_at=2026-02-04T19:41:23.7134606+09:00 | via=mep_append_evidence_line_full.ps1
* - PR #1756 | mergedAt=02/04/2026 01:47:35 | mergeCommit=d5ed639376636bc2809e9a3afdfbaa5a6e71d713 | BUNDLE_VERSION=v0.0.0+20260204_193735+main_8f9f7b3 | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1756
PR #1756 | audit=OK,WB0000 | appended_at=2026-02-04T19:41:25.2069529+09:00 | via=mep_append_evidence_line_full.ps1
----


----
SYNC_FROM_PARENT_BUNDLED | copied_at=2026-02-05T00:31:25.6470179+09:00 | via=manual_patch_child_evidence_from_parent.ps1
* - PR #1774 | mergedAt=02/04/2026 12:40:10 | mergeCommit=4916caadb5ea2b1139f5f9090e0ad3fc4bc739b9 | BUNDLE_VERSION=v0.0.0+20260204_152004+main_3c08faa | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1774
PR #1774 | audit=OK,WB0000 | appended_at=2026-02-04T15:20:06.9751060+00:00 | via=mep_append_evidence_line_full.ps1
----

* - PR #1805 | mergedAt=02/04/2026 15:44:51 | mergeCommit=0a7dbeaad72102a01bbd03632b456810f1ef8a48 | BUNDLE_VERSION=v0.0.0+20260204_035621+main+evidence-child | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1805
PR #1805 | audit=OK,WB0000 | appended_at=2026-02-04T15:45:13.1362640+00:00 | via=mep_append_evidence_line_full.ps1
* - PR #1808 | mergedAt=02/04/2026 18:03:15 | mergeCommit=6d5ced12d5b526cfa3d769a2a83e5479726884a0 | BUNDLE_VERSION=v0.0.0+20260204_035621+main+evidence-child | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1808
PR #1808 | audit=OK,WB0000 | appended_at=2026-02-04T18:30:27.3402441+00:00 | via=mep_append_evidence_line_full.ps1
* - PR #1825 | mergedAt=02/04/2026 21:29:12 | mergeCommit=40573b377431d4ea5ae9407b8188fe8d289884d7 | BUNDLE_VERSION=v0.0.0+20260204_035621+main+evidence-child | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1825
PR #1825 | audit=OK,WB0000 | appended_at=2026-02-04T21:34:10.9531132+00:00 | via=mep_append_evidence_line_full.ps1
* - PR #1826 | mergedAt=02/04/2026 22:37:33 | mergeCommit=081286735d61866409198bb8357c9e54e3845233 | BUNDLE_VERSION=v0.0.0+20260204_035621+main+evidence-child | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1826
PR #1826 | audit=OK,WB0000 | appended_at=2026-02-05T11:16:00.8932387+00:00 | via=mep_append_evidence_line_full.ps1
* - PR #1834 | mergedAt=02/05/2026 20:44:38 | mergeCommit=6f933d513e2cba7c0c1ca3f026e47bf0c955150a | BUNDLE_VERSION=v0.0.0+20260204_035621+main+evidence-child | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1834
PR #1834 | audit=OK,WB0000 | appended_at=2026-02-05T20:46:29.4597118+00:00 | via=mep_append_evidence_line_full.ps1
* - PR #1848 | mergedAt=02/06/2026 07:10:09 | mergeCommit=1d7daf6112e388fe9a8cce16032b0d1e345038f2 | BUNDLE_VERSION=v0.0.0+20260204_035621+main+evidence-child | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1848
PR #1848 | audit=OK,WB0000 | appended_at=2026-02-06T07:52:54.1260122+00:00 | via=mep_append_evidence_line_full.ps1


* - PR #1846 | mergedAt=02/06/2026 07:31:52 | mergeCommit=0d8fd8d3b71b9ee83bccd4a2fb28dad8ddf91d0a | BUNDLE_VERSION=v0.0.0+20260204_035621+main+evidence-child | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1846
PR #1846 | audit=OK,WB0000 | appended_at=2026-02-06T07:37:57.7387869+00:00 | via=mep_append_evidence_line_full.ps1

<!-- OP-1: evidence-follow-definition (SSOT) -->
## OP-1（推奨仕様）EVIDENCE追随の定義（SSOT）
- 追随判定の一次根拠は **EVIDENCE_BUNDLE（docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md）内の証跡行** とする。
- **EVIDENCE_BUNDLE_VERSION は補助情報（best-effort）** とし、更新されない場合でも追随失敗（STOP）とは扱わない。
- 運用上の同一性確認は、PR番号 / mergeCommit / HEAD の一致を正とする。

* - PR #1869 | mergedAt=02/06/2026 19:13:10 | mergeCommit=f733f7cb9aac750d2418f6c54f98eaacd7e96e29 | BUNDLE_VERSION=v0.0.0+20260204_035621+main+evidence-child | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1869
PR #1869 | audit=OK,WB0000 | appended_at=2026-02-06T20:31:34.8185939+00:00 | via=mep_append_evidence_line_full.ps1
PR #1869 | audit=OK,WB0000 | appended_at=2026-02-06T20:32:36.1932837+00:00 | via=mep_append_evidence_line_full.ps1
