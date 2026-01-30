# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）

## 変更対象（Scope-IN）
- START_HERE.md
- .mep/CURRENT_STAGE.txt
- .github/ISSUE_TEMPLATE/mep_dispatch.yml
- .github/workflows/dispatch_smoke.yml
- .github/workflows/ux_rooftop_full_auto_dispatch.yml
- .github/workflows/ux_rooftop_full_auto_dispatch_v2.yml
- .mep/artifacts/*.md
- docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md
- platform/MEP/90_CHANGES/CURRENT_SCOPE.md
- .github/workflows/mep_writeback_bundle_dispatch_v3.yml
- tools/mep_handoff_audit.ps1
- .github/workflows/mep_bundle_autofix.yml
- .mep/allowlists/business.sha256
- .github/workflows/mep_gate_min5.yml
- .github/workflows/mep_semantic_audit.yml
- tools/mep_writeback_bundle.ps1
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














## Child MEPs
- EVIDENCE -> docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md




