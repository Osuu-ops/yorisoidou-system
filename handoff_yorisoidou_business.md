# 引継ぎメモ：よりそい堂 BUSINESS

## 1. Bundled基準（唯一の真実）
- 真実の確定は PR → main → Bundled（BUNDLE_VERSION確認）のみ
- writeback は workflow_dispatch
- BUSINESS master canonical（current）:
  platform/MEP/03_BUSINESS/よりそい堂/master_spec

### Bundled証跡（EVIDENCE child）
- BUNDLE_VERSION: v0.0.0+20260122_055822+main+parent
- PR #1086 | mergedAt=01/21/2026 20:29:27 | mergeCommit=9eb1e3566bd3a74b700aa34c5de4133fcc60b840
- writeback PR #1102 | mergedAt=2026-01-21T21:03:23Z | mergeCommit=576345d11d95df435938ae1c1fa7dcd15ff38f87

## 2. 作業メモ（Bundled外・監査対象外）
- writeback で PR を指定する場合、workflow inputs は `inputs.pr_number`（`0` は latest merged PR を自動選択）。
- tools/mep_writeback_bundle.ps1 は PrNumber=0 のとき latest merged PR 1件のみを拾う（明示指定で個別回収可能）。