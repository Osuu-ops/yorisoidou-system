# PRE-GATE完全自動化：Scope-IN（対象固定）

## 1. IN（対象）
- MEPの **pre-gate / read-only suite** を「毎回ブレずに回す」ために必要な更新
  - 運用ドキュメント（ガード仕様・証跡仕様・実行ルール）
  - それらに付随する workflow / script の **最小修正**（チェックが安定して回る範囲）
- PR→main→Bundled（BUNDLE_VERSION更新）で **証跡を残せる**変更のみ

## 2. OUT（対象外：当面）
- BUSINESSの大規模再編・大量生成・ディレクトリ移動
- Required checks（B運用）への全面移行（別スコープで扱う）
- UI/UX屋上のFULLAUTO拡張（別スコープで扱う）

## 3. 境界・例外
- 既存チェックが SKIPPED になり得る項目は、DoD側で「許容条件」を明文化した場合のみ許容
- 監査一次根拠（Bundled）に載らない状態の主張は確定扱いしない

## 4. 検証（このScopeを担保する方法）
- PR checks が SUCCESS で揃うこと（最低限：acceptance / guard / Scope Guard / Text Integrity Guard）
- Bundledに `audit=OK,WB0000` を含む証跡行が残ること（PR→main→Bundled）
