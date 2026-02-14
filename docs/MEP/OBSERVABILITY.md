# Observability (Run/PR)
目的:
- v2入口のrun_idから、PR_URL/PR状態までを一括で観測する
ツール:
- tools/runner/mep_observe_run.ps1
使い方（PowerShell）:
1) repo指定（例）
- $env:GH_REPO="Osuu-ops/yorisoidou-system"
2) run_id を入れて観測
- pwsh -File tools/runner/mep_observe_run.ps1 -RunId 22023302204
出力:
- RUN_URL / RUN_STATUS / RUN_CONCLUSION
- PR_URL / PR_NUM / PR_STATE / PR_MERGED_AT