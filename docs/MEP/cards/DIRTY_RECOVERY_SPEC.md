<!-- BEGIN: DIRTY_RECOVERY_SPEC (MEP) -->
## CARD: DIRTY / RECOVERY（停止・復旧仕様）  [Draft]

### DIRTY条件（最小）
- 受入テストNG（形式/禁止事項/境界崩壊）
- BEGIN/END の片側欠損
- 証跡が残せない（PR/mergeCommit/BUNDLE_VERSION 不明）

### 取るべきログ（最小）
- 対象ファイル名
- 検出コード（NG理由）
- 直前の差分（最小）

### 復旧カード（フォーマット最小）
- 現状（何が起きたか）
- 影響範囲
- 次にやる手順（1ステップ）
- 再開条件（何が揃えば進めるか）
<!-- END: DIRTY_RECOVERY_SPEC (MEP) -->
