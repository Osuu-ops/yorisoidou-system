<!-- BEGIN: DIFF_POLICY_BOUNDARY_AUDIT (MEP) -->
## CARD: DIFF_POLICY / BOUNDARY AUDIT（差分運用・境界監査）  [Draft]

### 基本
- 大置換・全文書き換えは禁止。更新は **差分（最小パッチ）** を原則とする。

### 境界監査（最小）
- BEGIN/END は必ず対で存在し、片側欠損は DIRTY（停止）。
- 同一BEGINの重複定義は禁止（検出したらNG）。
<!-- END: DIFF_POLICY_BOUNDARY_AUDIT (MEP) -->
