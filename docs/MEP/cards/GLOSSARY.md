<!-- BEGIN: GLOSSARY (MEP) -->
## CARD: GLOSSARY（用語集）  [Draft]

### 基本用語（固定）
- MEP：運用・採用ルートの仕様束。Bundled を最終確定点として持つ。
- Bundled：採用済み仕様・証跡の単一集約点。監査・復旧・再開の唯一の参照元。
- Card：BEGIN/END 境界を持つ最小成果物。採用可否は acceptance-tests で判定。
- Draft：未確定状態。拡張・修正が許可される。
- Adopted：採用確定状態。原則として直接変更禁止。
- Gate：採用可否を決める機械判定点。非通過の場合は DIRTY 停止。
- acceptance-tests：採用ルート入口の最小検証。exit code で OK/NG。
- Writeback：PR → main → Bundled への証跡貼り戻し処理。
- Evidence：PR番号・mergeCommit・BUNDLE_VERSION 等の監査情報。
- DIRTY：不整合検出時の停止状態。復旧カードなしに再開不可。
- Recovery：DIRTY からの再開手順。最小ステップでのみ許可。
- Parent MEP：子MEPを参照・統合する上位MEP。
- Sub MEP：独立した責務を持つ分離MEP。親MEPからは参照のみ。

<!-- END: GLOSSARY (MEP) -->
