<!-- BEGIN: EVIDENCE_SUB_MEP_REFERENCE (MEP) -->
## CARD: SUB_MEP / REFERENCE（EVIDENCE 子MEP参照）  [Draft]

### 目的
EVIDENCE（証跡管理・writeback）領域が
**親MEPから独立した 子MEP として運用されている事実** を固定し、
参照経路のみを親MEP側に残す。

### 参照先（固定）
- EVIDENCE 子MEP Bundled：
  - `docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md`

### 親MEP側の扱い（固定）
- 親MEPは **参照のみ** を行う
- 証跡仕様・writeback仕様・BUNDLE_VERSION 管理は行わない
- 子MEPの内部変更は親MEPの差分対象外とする

### 子MEP側の責務（再掲しない）
- PR → main → 子MEP Bundled への証跡貼り戻し
- 子MEP独自の BUNDLE_VERSION 管理
- 証跡破損時の DIRTY 判定

### 禁止事項
- 親MEP Bundled に子MEP証跡を直接記載すること
- 親MEP側で子MEPの writeback を実行すること
- 子MEPの BUNDLE_VERSION を親MEP側で操作すること

### 分離確定条件
- 親MEP Bundled に本カードの証跡が存在すること
- 子MEP Bundled が存在し、空でも管理下にあること

<!-- END: EVIDENCE_SUB_MEP_REFERENCE (MEP) -->
