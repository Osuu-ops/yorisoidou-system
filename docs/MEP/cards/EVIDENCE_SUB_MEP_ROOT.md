<!-- BEGIN: EVIDENCE_SUB_MEP_ROOT (MEP) -->
## CARD: SUB_MEP / ROOT（EVIDENCE 子MEP：公式説明・境界）  [Draft]

### 目的
EVIDENCE（証跡貼り戻し）領域を、親MEPから独立運用できる 子MEP として切り出すためのルート定義を固定する。

### 対象領域（固定）
- 証跡貼り戻し（Writeback）
- 証跡の必須要素（PR/mergedAt/mergeCommit/BUNDLE_VERSION/audit/URL）
- 証跡ログ破損検知（DIRTY扱い）

### 子MEP内の対象カード群（固定）
- EVIDENCE_WRITEBACK_SPEC（証跡貼り戻し仕様）[Adopted]
- （必要に応じて）証跡破損ガード系カード（同一領域に限定）

### 親MEP側の責務（固定）
- 子MEPへの参照カードのみ保持（内容を重複記載しない）
- 入口統合（起動投入モデル）は親MEPが担当
- 束ね識別の基準（Bundled先頭の BUNDLE_VERSION）

### 子MEP側の確定点（固定）
- 子MEPの確定点は 子MEP Bundled に置く。
- 親MEP Bundled には「分離事実」と「参照」だけを残す。

### 禁止事項
- 親MEPと子MEPで同一決定を重複記載すること（重複禁止）
- 子MEP内部仕様を親MEP側で直接更新すること
- 分離後に証跡が欠落すること（入った扱い禁止）

### 更新経路（固定）
- 更新は常に PR → main → Bundled の経路で行い、手編集はしない。

### 次アクション
- 子MEP Bundled の生成物パスを決める（別カードで固定）
- 親MEP側に参照カード（EVIDENCE Sub MEP を参照するだけ）を追加する
<!-- END: EVIDENCE_SUB_MEP_ROOT (MEP) -->
