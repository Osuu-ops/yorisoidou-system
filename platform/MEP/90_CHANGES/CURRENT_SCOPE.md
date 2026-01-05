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
- tools/mep_pwsh_guard.ps1
- tools/mep_autopilot.ps1
- tools/mep_integration_compiler/collect_changed_files.py
- tools/mep_integration_compiler/runtime/__init__.py
- tools/mep_integration_compiler/runtime/__pycache__/__init__.cpython-314.pyc
- tools/mep_integration_compiler/runtime/__pycache__/cli.cpython-314.pyc
- tools/mep_integration_compiler/runtime/__pycache__/idempotency.cpython-314.pyc
- tools/mep_integration_compiler/runtime/__pycache__/recovery_queue.cpython-314.pyc
- tools/mep_integration_compiler/runtime/__pycache__/request_linkage.cpython-314.pyc
- tools/mep_integration_compiler/runtime/cli.py
- tools/mep_integration_compiler/runtime/idempotency.py
- tools/mep_integration_compiler/runtime/recovery_queue.py
- tools/mep_integration_compiler/runtime/request_linkage.py
- tools/mep_integration_compiler/runtime/README_B2_LEDGER.md
- tools/mep_integration_compiler/runtime/__pycache__/ledger_cli.cpython-314.pyc
- tools/mep_integration_compiler/runtime/__pycache__/ledger_recovery_queue.cpython-314.pyc
- tools/mep_integration_compiler/runtime/ledger_cli.py
- tools/mep_integration_compiler/runtime/ledger_recovery_queue.py
- tools/mep_integration_compiler/runtime/README_B3_REQUEST.md
- tools/mep_integration_compiler/runtime/__pycache__/ledger_request.cpython-314.pyc
- tools/mep_integration_compiler/runtime/__pycache__/ledger_request_cli.cpython-314.pyc
- tools/mep_integration_compiler/runtime/ledger_request.py
- tools/mep_integration_compiler/runtime/ledger_request_cli.py
- tools/mep_integration_compiler/runtime/tests/README_B4_E2E.md
- tools/mep_integration_compiler/runtime/tests/b4_csv_e2e.py
- tools/mep_integration_compiler/runtime/README_B5_LEDGER_ADAPTER.md
- tools/mep_integration_compiler/runtime/__pycache__/ledger_adapter.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/__init__.py
- tools/mep_integration_compiler/runtime/adapters/__pycache__/__init__.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/__pycache__/csv_adapter.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/csv_adapter.py
- tools/mep_integration_compiler/runtime/ledger_adapter.py
- tools/mep_integration_compiler/runtime/README_B6_SHEETS_ADAPTER.md
- tools/mep_integration_compiler/runtime/adapters/__pycache__/sheets_adapter_skeleton.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/sheets_adapter_skeleton.py
- tools/mep_integration_compiler/runtime/tests/README_B7_ADAPTER_E2E.md
- tools/mep_integration_compiler/runtime/tests/__pycache__/b7_adapter_e2e.cpython-314.pyc
- tools/mep_integration_compiler/runtime/tests/b7_adapter_e2e.py
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








