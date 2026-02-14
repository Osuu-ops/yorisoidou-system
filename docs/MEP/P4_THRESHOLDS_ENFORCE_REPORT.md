# P4 Thresholds Enforce Report (v0)
目的:
- P4閾値（bytes/files/added）が SSOT に集約されていることを監査する
- 参照側（workflow/runner）に固定値が散在しないことを確認する
監査ツール:
- tools/runner/p4_thresholds_audit.ps1
運用:
- 監査はローカルで実行できる（CI必須にはしない＝既存Required checksを壊さない）
- 監査で検出が出た場合、該当箇所を SSOT参照へ統一する（PRで実施）
実行例（PowerShell）:
- pwsh -File tools/runner/p4_thresholds_audit.ps1
  - exit 0: OK
  - exit 2: hardcode検出（要修正）