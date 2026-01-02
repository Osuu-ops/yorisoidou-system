# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）

## 変更対象（Scope-IN）
- platform/MEP/03_BUSINESS/よりそい堂/**
- platform/MEP/90_CHANGES/CURRENT_SCOPE.md
- platform/MEP/90_CHANGES/CURRENT_SCOPE.md
- .github/workflows/scope_guard_pr.yml
- .github/workflows/business_packet_guard_pr.yml

## 非対象（Scope-OUT｜明示）
- platform/MEP/01_CORE/**
- platform/MEP/00_GLOBAL/**

## 判断が必要な点（YES/NO）
- なし（必要が生じた場合のみ追記して停止する）
# scope-guard registration test 20260103-000927

## Scope Guard 互換書式（固定）
- Scope Guard は本ファイルの「## 変更対象（Scope-IN）」見出し直下の「- 」箇条書きのみを機械抽出する。
- Scope-IN には glob を使用できる（例：platform/MEP/03_BUSINESS/**）。
- 見出し名の変更、箇条書き形式の変更（番号付き等）は禁止。
- 例外運用を行う場合も、必ず Scope-IN に明示し、PR差分で実施する。
<!-- CI_TOUCH: 2026-01-03T02:01:49 -->

