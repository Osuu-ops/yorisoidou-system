# Observability (Run/PR)
目的:
- canonical standalone workflow や downstream run の `run_id` から、PR URL / PR 状態までを一括で観測する
正本PS:
- `tools/mep.ps1 run-status`
使い方（PowerShell）:
1) repo指定（例）
- `$env:GH_REPO="Osuu-ops/yorisoidou-system"`
2) `run_id` を入れて観測
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\mep.ps1 run-status -RunId 22023302204`
出力:
- `RUN_URL` / `RUN_STATUS` / `RUN_CONCLUSION`
- `PR_URL` / `PR_NUMBER` / `PR_STATE` / `PR_MERGE_STATE`
- `NEXT_ACTION`
互換:
- `tools/runner/mep_observe_run.ps1` は `tools/mep.ps1 run-status` への wrapper。
