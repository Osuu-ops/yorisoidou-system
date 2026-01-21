<!-- BEGIN: BUSINESS_UNIT_BUNDLE_SPEC (MEP) -->
## CARD: BUSINESS_UNIT / BUNDLE SPEC（ドメイン単位の束ね仕様）  [Draft]

### 目的
- BUSINESS側の例外・分岐・用語・台帳参照の増加により、全体BUNDLEのみでは参照コストと混線リスクが上がる。
- ドメイン（業務単位）ごとの束ねを持ち、再開・実装・監査を高速化する。

### 3階層（推奨）
- GLOBAL（全体BUNDLE）：MEP契約・Gate・状態タグ・安全規約など共通
- BUSINESS_UNIT（業務単位BUNDLE）：ドメイン固有（前提/用語/台帳/境界/DoD/例外）
- WORK_ITEM（作業単位ミニBUNDLE/CURRENT）：1テーマの目的/前提/採用済み/未決/次アクションのみ

### 起動投入モデル（単一投入の維持）
- 起動時に `GLOBAL + 対象UNIT + 対象WORK_ITEM` を結合した STARTUP_BUNDLE（単一）を生成して投入する。

### 分割原則（汚染防止）
- 層の優先順位固定：GLOBAL > UNIT > WORK_ITEM（下位が上位を上書き禁止）
- 重複禁止：同一決定は1か所のみ（例：状態タグ/Gate/確定定義はGLOBALのみ）
- 参照固定：UNIT/WORK_ITEMは参照するGLOBALのBUNDLE_VERSION（またはcommit）を明記
- 生成物の手編集禁止：更新はPR→main→Bundledでのみ行う
<!-- END: BUSINESS_UNIT_BUNDLE_SPEC (MEP) -->
