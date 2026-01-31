# WORK_ITEM: よりそい堂 BUSINESS / 完成（運用可能）へ

## 運用固定化
- 手動実行は **.github/workflows/mep_writeback_bundle_manual.yml** のみを正規経路とする。
- 旧経路（dispatcher 直叩き等、422 を出していた経路）は **運用対象外**（禁止）。
- reusable workflow **.github/workflows/mep_writeback_bundle_dispatch.yml** は manual dispatcher からのみ呼ぶ。
## 根拠（Bundled）
- 完成定義（全BUSINESS共通）：platform/MEP/01_CORE/cards/BUSINESS_DONE_DEFINITION.md
- Bundled参照カード：BUSINESS_DONE_DEFINITION_BUNDLED_REF（Adopted）

## 目的
- 「完成＝運用可能（仕事として回せる）」の完了条件を満たすまで、未達を潰す

## 未達の洗い出し（チェック→PR化）
- RuntimeSelfTest（UF01/UF06/UF07/UF08/WORK_DONE/RESYNC）をテストIDで一巡し、増殖なし（冪等）を確認
- BLOCKER/WARNING → Recovery Queue（OPEN→解消→記録）が運用で回ることを確認
- Ledger→Todoist/ClickUp 投影が再現可能（同一Ledger状態→同一表示へ収束）を確認
- Authority（管理UI/会話ログから確定値を作らない）が守られることを確認

## 次のPR（最初の1本）
- 「RuntimeSelfTest（テストID一巡）の手順/チェックリスト」をカード化して固定（1テーマ=1PR）

## Done
- 上の未達が全て満たされ、PR→main→Bundledで証跡が残る
