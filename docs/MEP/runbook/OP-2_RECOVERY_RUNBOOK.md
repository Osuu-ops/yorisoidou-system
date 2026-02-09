# OP-2 Recovery Runbook (handoff破損時の最小復帰)
このドキュメントは **OP-2（未完→一次根拠化）** の最小成果物。
目的は、handoff が破損/欠損しても、次回入口で **SSOT_SCAN → CONFLICT_SCAN** を必ず通し、
「現在地・未完・次工程」を一次出力（git/gh）で復元できる状態を維持すること。
---
## 前提（入口固定）
- 対象ブランチ: main
- 一次根拠: git / gh の一次出力のみ
- 推測値の埋め込み禁止（Version/Commit/PR/Path 等）
---
## 入力（最低限）
- REPO_ORIGIN（git remote）
- HEAD(main)（git rev-parse HEAD）
- PARENT_BUNDLED（docs/MEP/MEP_BUNDLE.md 等）
- EVIDENCE_BUNDLE（docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md 等）
- SSOT（所在を main から確定して読む）
---
## 手順（最小）
### 1) main を origin/main に同期
- git fetch/pull を実行し、HEAD(main) を一次出力で確定する
### 2) Bundled/EVIDENCE を一次出力で抽出
- PARENT_BUNDLE_VERSION: PARENT_BUNDLED 実体から抽出
- PARENT_BUNDLED_LAST_COMMIT: git log -1 -- <PARENT_BUNDLED>
- EVIDENCE_BUNDLE_VERSION: EVIDENCE_BUNDLE 実体から抽出
- EVIDENCE_BUNDLE_LAST_COMMIT: git log -1 -- <EVIDENCE_BUNDLE>
### 3) SSOT_SCAN（所在→内容の読み取り）
- main から SSOT ファイルを特定（パスを一次出力で確定）
- SSOT の「入口契約（SSOT_SCAN/CONFLICT_SCAN を含む）」を読み、入口の必須工程を確定する
### 4) CONFLICT_SCAN（旧経路/新経路の並立検知）
- 旧WORK_ID系と新SSOT/WORK_ITEMS系が同時に“実行候補”として並立する場合は STOP（Machine-Only STOP）
- DoD未達段階で封印はしない（誤誘導防止）
### 5) 復帰出力（人間用）
- 現在地（HEAD / Bundled / Evidence / SSOT）を列挙
- 未完（OP-2/OP-3…）と次工程を列挙
- 進捗率は分母固定まで算出しない
---
## DoD（OP-2）
- 本runbook と card が main に存在する（PR→merge）
- 次回入口で「SSOT_SCAN→CONFLICT_SCAN を通す」ことが一次根拠として参照できる
