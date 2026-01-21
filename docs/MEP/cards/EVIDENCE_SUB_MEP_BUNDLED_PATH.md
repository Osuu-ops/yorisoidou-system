<!-- BEGIN: EVIDENCE_SUB_MEP_BUNDLED_PATH (MEP) -->
## CARD: SUB_MEP / BUNDLED PATH（EVIDENCE 子MEP 確定点）  [Draft]

### 目的
EVIDENCE 子MEP の **確定点（Bundled）生成物パス** を固定し、
親MEPから独立して監査・再現・復旧できる状態を作る。

### Bundled 生成物パス（固定）
- 子MEP Bundled:
  - `docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md`

### BUNDLE_VERSION 規約（子MEP）
- 子MEPは **独立した BUNDLE_VERSION** を持つ。
- 親MEPの BUNDLE_VERSION とは直接同期しない。
- 証跡行には以下を必ず含める：
  - 子MEP BUNDLE_VERSION
  - 親PR番号（参照用）

### 親MEPとの関係（固定）
- 親MEP Bundled には以下のみを残す：
  - 子MEPが存在する事実
  - 子MEP Bundled への参照
- 子MEPの詳細仕様・証跡は **親MEPに複製しない**。

### 禁止事項
- 親MEP Bundled に子MEP証跡を直接書き込むこと
- 子MEP Bundled を親MEPの writeback で更新すること
- 子MEP BUNDLE_VERSION を親MEP側で操作すること

### 次アクション
- 子MEP Bundled の **空生成（初回）**
- writeback を子MEP側で通す

<!-- END: EVIDENCE_SUB_MEP_BUNDLED_PATH (MEP) -->
