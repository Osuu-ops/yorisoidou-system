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
- tools/mep_integration_compiler/runtime/README_B8_SHEETS_SCHEMA_CHECK.md
- tools/mep_integration_compiler/runtime/adapters/__pycache__/sheets_schema_check.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/__pycache__/sheets_schema_check_cli.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/sheets_schema_check.py
- tools/mep_integration_compiler/runtime/adapters/sheets_schema_check_cli.py
- tools/mep_integration_compiler/runtime/tests/__pycache__/b8_schema_check.cpython-314.pyc
- tools/mep_integration_compiler/runtime/tests/b8_schema_check.py
- tools/mep_integration_compiler/runtime/README_B9_SHEETS_READONLY_BOUNDARY.md
- tools/mep_integration_compiler/runtime/adapters/__pycache__/sheets_header_fetcher.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/sheets_header_fetcher.py
- tools/mep_integration_compiler/runtime/tests/__pycache__/b9_sheets_readonly_boundary.cpython-314.pyc
- tools/mep_integration_compiler/runtime/tests/b9_sheets_readonly_boundary.py
- tools/mep_integration_compiler/runtime/README_B10_HTTP_HEADER_PROVIDER.md
- tools/mep_integration_compiler/runtime/adapters/__pycache__/http_header_provider.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/__pycache__/http_header_provider_cli.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/http_header_provider.py
- tools/mep_integration_compiler/runtime/adapters/http_header_provider_cli.py
- tools/mep_integration_compiler/runtime/tests/__pycache__/b10_http_provider_parse.cpython-314.pyc
- tools/mep_integration_compiler/runtime/tests/b10_http_provider_parse.py
- tools/mep_integration_compiler/runtime/README_B12_HTTP_WRITE_CLIENT.md
- tools/mep_integration_compiler/runtime/adapters/__pycache__/http_write_client.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/__pycache__/http_write_client_cli.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/http_write_client.py
- tools/mep_integration_compiler/runtime/adapters/http_write_client_cli.py
- tools/mep_integration_compiler/runtime/tests/__pycache__/b12_http_write_import.cpython-314.pyc
- tools/mep_integration_compiler/runtime/tests/b12_http_write_import.py
- tools/chat_packet_intake/analyze_issue.py
- business/master_spec.md
- business/ui_spec.md
- business/business_master.md
- business/business_spec.md
- business/ui_master.md
- seed/doc_templates.csv
- seed/settings.csv
- seed/status.csv
- seed/type.csv
- seed/parts_category.csv
- seed/price_list.csv
- seed/work_menu.csv
- seed/SEED_MANIFEST.csv
- seed/contact_channel.csv
- seed/payment_channel.csv
- seed/payment_method.csv
- seed/location_code.csv
- seed/work_menu_type_link.csv
- seed/work_type_map.csv
- gas/uf06/README_UF06_QUEUE.md
- gas/uf06/ledger_adapter.gs
- gas/uf06/uf06_queue.gs
- gas/uf06/uf06_app.gs
- gas/ui/uf06_deliver.html
- gas/ui/uf06_order.html
- gas/uf06/README_UF06_SELFTEST.md
- gas/uf06/uf06_selftest.gs
- gas/uf06/README_ORCHESTRATOR_RO.md
- gas/uf06/orchestrator_ro.gs
- mep/ACCEPTANCE_TESTS_SPEC.md
- mep/MEP_ARTIFACT.md
- mep/SINGLE_ARTIFACT_FORMAT.md
- tools/acceptance_tests.ps1
- gas/uf06/README_ORCHESTRATOR_WRITE.md
- gas/uf06/orchestrator_write.gs
- tools/mep_writeback_bundle.ps1
- gas/uf06/README_ORCHESTRATOR_DELIVER_WRITE.md
- gas/uf06/orchestrator_deliver_write.gs
- tools/mep_bundle_autofix.ps1
- businesses/REGISTRY.yml
- businesses/yorisoidou/GATES.yml
- businesses/yorisoidou/README.md
- businesses/yorisoidou/TARGETS.yml
- businesses/yorisoidou/TEMPLATE.md
- tools/mep_business_new.ps1
- tools/mep_repair_evidence_line.ps1
- tools/mep_repair_evidence_log.ps1
- tools/mep_acceptance_tests.ps1
- tools/mep_bump_bundle_version.ps1
- MEP_MT5_LOG_DUMP_AND_SCAN.ps1
- platform/MEP/01_CORE/cards/EVIDENCE_SUB_MEP_ROOT.md
- docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md
- .gitignore
- tools/mep_diagnose_writeback.ps1
- businesses/evidence/TARGETS.yml
- platform/MEP/03_BUSINESS/q/MEP_SUB/MEP_BUNDLE.md
- platform/MEP/03_BUSINESS/q/TARGETS.yml
- platform/MEP/03_BUSINESS/q/business_spec.md
- platform/MEP/01_CORE/cards/BUSINESS_DONE_DEFINITION.md
- platform/MEP/03_BUSINESS/yorisoidou/CMEP/02_MEP_SCRIPTS/.gitkeep
- tools/mep/New-MEPBusiness.ps1
- platform/MEP/03_BUSINESS/yorisoidou/CMEP/02_MEP_SCRIPTS/KEEP.md
- tools/mep_orchestrator.ps1
- tools/yorisoidou/run-runtime-selftest.ps1
- tools/yorisoidou/**
- .mep/tmp/b4_e2e/recovery_queue.csv
- .mep/tmp/b4_e2e/request.csv
- .mep/tmp/b7_adapter_e2e/recovery_queue.csv
- .mep/tmp/b7_adapter_e2e/request.csv
- .mep-selftest/runtime-selftest_20260125_193056.log
- .mep-selftest/runtime-selftest_20260125_193057_second.log
- tools/mep_pr_audit_merge.ps1
- .github/workflows/mep_writeback_bundle_dispatch.yml.bak
- .editorconfig
- .gitattributes
- .github/ISSUE_TEMPLATE/mep_dispatch.yml
- .github/workflows/dispatch_smoke.yml.bak.20260113-021811
- .github/workflows/ux_rooftop_full_auto_dispatch.yml.bak.20260113-021811
- .github/workflows/ux_rooftop_full_auto_dispatch_v2.yml.bak.20260113-021811
- .mep/artifacts/artifact_20260112-180343.md
- .mep/artifacts/artifact_20260112-182405.md
- gas/clasp_webapp/src/A1_WriteEndpoint_LedgerApply.js
- gas/uf06/README_UF06.md
- gas/uf06/parts_dict.gs
- gas/uf06/task_title_projector.gs
- handoff_yorisoidou_business.md
- platform/MEP/03_BUSINESS/tictactoe/master_spec.md
- scripts/evidence_check.ps1
- tools/mep.ps1
- tools/mep_bundle_update_ai_learn_ref.ps1
- tools/mep_entry.ps1
- tools/mep_gate_doctor.ps1
- tools/mep_handoff.ps1.bak.20260107-013624
- tools/mep_handoff_generate.ps1
- tools/mep_handoff_guard.ps1
- tools/mep_learn_quick.ps1
- tools/mep_learn_register.ps1
- tools/mep_pregate.ps1
- tools/mep_writeback_handoff.ps1
- tools/mep_auto.ps1
- tools/mep_current_stage.ps1
- tools/pre_gate.ps1
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


