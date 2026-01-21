<!-- BEGIN: EVIDENCE_SUB_MEP_WRITEBACK_PLAN (MEP) -->
## CARD: SUB_MEP / WRITEBACK PLAN（EVIDENCE 子MEP：証跡貼り戻し分離計画）  [Draft]

### 目的
EVIDENCE 子MEPの証跡貼り戻し（writeback）を、親MEPから独立させる。
親MEP Bundled は「参照のみ」を維持し、証跡は子MEP Bundled に集約する。

### 貼り戻し先（固定）
- 子MEP Bundled：
  - `docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md`
- 子MEP側の証跡セクション：
  - `### 証跡ログ（自動貼り戻し）`

### 証跡の必須要素（固定）
- PR番号
- mergedAt
- mergeCommit
- 子MEP BUNDLE_VERSION（子MEP内の確定値）
- 監査結果（audit=OK/NG, WBコード）
- PR URL

### 実行主体（固定）
- 子MEP writeback は「子MEP専用の workflow / script」によって実行する。
- 親MEPの writeback（`docs/MEP/MEP_BUNDLE.md` 向け）は子MEP Bundled を更新しない。
- 更新経路は常に PR → main → Bundled。手編集はしない。

### 親MEPとの関係（固定）
- 親MEP側は参照カード（`EVIDENCE_SUB_MEP_REFERENCE`）のみを保持する。
- 子MEPの詳細仕様・証跡は親MEPへ複製しない（重複禁止）。

### 破損検知（DIRTY扱い・固定）
- 以下を検出した場合は DIRTY（入った扱い禁止）：
  - `PR #@{` を含む行
  - `mergedAt=` が空
  - `mergeCommit=` が空
- 復旧は「壊れ行の除去」＋「正規行を1本に収束」。

### 禁止事項
- 親MEP writeback で子MEP Bundled を更新すること
- 同一PRの証跡行が複数本になること（必ず1本に収束）
- 親MEPと子MEPで同一決定を重複記載すること

### 次アクション
- 子MEP writeback の workflow 名と生成物（yaml / ps1）を別カードで固定する
- 子MEP Bundled に「子MEP BUNDLE_VERSION の生成/更新規約」を別カードで固定する

<!-- END: EVIDENCE_SUB_MEP_WRITEBACK_PLAN (MEP) -->
