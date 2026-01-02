# CURRENT_SCOPE（今回の作業宣言｜唯一の正）

## 目的
完了：tictactoe master_spec の同梱注記／入力(1〜3)明記／Acceptance追加を main へ反映済み。
03_BUSINESS/tictactoe を差し込み対象として、監査（B運用2チェック＋TIG）を通る最小差分で整形し、生成テストに進む。

## 変更対象（Scope-IN）
- "platform/MEP/03_BUSINESS/\343\202\210\343\202\212\343\201\235\343\201\204\345\240\202/**"
- (this file) CURRENT_SCOPE.md

## 非対象（Scope-OUT｜明示）
- platform/MEP/01_CORE/**
- platform/MEP/00_GLOBAL/**
- .github/**（CI/TIGは今回変更しない）

## 判断が必要な点（YES/NO）
- なし（必要が生じた場合のみ追記して停止する）
# scope-guard registration test 20260103-000927
<<<<<<< HEAD
<!-- CI_TOUCH: 2026-01-03T01:44:25 -->
=======

## Scope Guard 互換書式（固定）

- Scope Guard は本ファイルの「## 変更対象（Scope-IN）」見出し直下の「- 」箇条書きのみを機械抽出する。
- Scope-IN には glob を使用できる（例：platform/MEP/03_BUSINESS/**）。
- 見出し名の変更、箇条書き形式の変更（番号付き等）は禁止。
- 例外運用を行う場合も、必ず Scope-IN に明示し、PR差分で実施する。
>>>>>>> origin/main
