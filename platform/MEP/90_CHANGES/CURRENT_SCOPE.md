# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）

## 変更対象（Scope-IN）
- .github/workflows/required_checks_drift_guard_manual.yml
- platform/MEP/03_BUSINESS/よりそい堂/**
- platform/MEP/90_CHANGES/CURRENT_SCOPE.md
- .github/workflows/scope_guard_pr.yml
- .github/workflows/business_packet_guard_pr.yml
- .github/workflows/self_heal_auto_prs.yml
- .github/workflows/chat_packet_update_schedule.yml
- .github/workflows/chat_packet_self_heal.yml
- docs/MEP/**
- .github/workflows/*.yml
- platform/MEP/01_CORE/_SCOPE_SUGGEST_FORCE_20260103-135009.txt
- platform/MEP/90_CHANGES/_SCOPE_SUGGEST_DOD_20260103-072904.txt
- tools/mep_handoff.ps1
- tools/mep_idea_capture.ps1
- tools/mep_idea_list.ps1
- tools/mep_idea_pick.ps1
- tools/mep_idea_finalize.ps1
- tools/mep_idea_receipt.ps1
- tools/mep_chat_packet_min.ps1
- .github/ISSUE_TEMPLATE/mep_dispatch.yml
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








