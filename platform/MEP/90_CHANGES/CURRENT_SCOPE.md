# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）
## 変更対象（Scope-IN）
- .github/workflows/self_heal_auto_prs.yml
- .gitignore
- tools/mep_auto_loop.ps1
- tools/mep_reporter.ps1
- platform/MEP/90_CHANGES/CURRENT_SCOPE.md
- tools/mep_entry.ps1
- tools/mep_append_evidence_line_full.ps1
- .github/workflows/mep_writeback_bundle_dispatch.yml
- tools/mep_writeback_create_pr.ps1
- .github/workflows/mep_writeback_bundle_dispatch_entry.yml
- docs/MEP/MEP_BUNDLE.md
- .github/workflows/business_non_interference_guard.yml
## 非対象（Scope-OUT｜明示）
- platform/MEP/01_CORE/**
- platform/MEP/00_GLOBAL/**
## 判断が必要な点（YES/NO）
- なし（必要が生じた場合のみ追記して停止する）
## Scope Guard 互換書式（固定）
- Scope Guard は本ファイルの「## 変更対象（Scope-IN）」見出し直下の「- 」箇条書きのみを機械抽出する。
- Scope-IN には glob を使用できる（例：platform/MEP/03_BUSINESS/**）。
- 見出し名の変更、箇条書き形式の変更（番号付き等）は禁止。
- 例外運用を行う場合も、必ず Scope-IN に明示し、PR差分で実施する。
## Child MEPs
- EVIDENCE -> docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md

