<!-- BEGIN: SUB_MEP_CANDIDATES (MEP) -->
## CARD: SUB_MEP / CANDIDATES（子MEP候補と初回切り出し対象）  [Draft]

### 目的
子MEP分離を安全に進めるため、分離候補と初回の切り出し対象を先に固定する。

### 子MEP候補（固定）
- ACCEPTANCE Sub MEP
  - 対象カード群：ACCEPTANCE_TESTS_SPEC / SINGLE_ARTIFACT_FORMAT
- EVIDENCE Sub MEP
  - 対象カード群：EVIDENCE_WRITEBACK_SPEC
- RECOVERY Sub MEP
  - 対象カード群：DIRTY_RECOVERY_SPEC / DIFF_POLICY_BOUNDARY_AUDIT

### 初回切り出し対象（固定）
- EVIDENCE Sub MEP
  - 理由：確定点（PR→main→Bundled）と監査根拠の一本化が他領域の土台となるため。

### 親MEPに残す責務（固定）
- 入口統合（起動投入モデル）
- 子MEP参照カードの保持
- 束ね識別基準（Bundled先頭の BUNDLE_VERSION）

### 禁止事項
- 親MEPと子MEPでの同一決定の重複
- 子MEP内部仕様を親MEP側で直接更新すること
- 分離後の証跡欠落（入った扱い禁止）

### 次アクション
- EVIDENCE Sub MEP 用ルートカードを作成
- 親MEP側を参照カードへ置換（差分最小）

<!-- END: SUB_MEP_CANDIDATES (MEP) -->
