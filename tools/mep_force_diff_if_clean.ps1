Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
param(
  [string]$MarkerPath = "docs/MEP_SUB/HEALTH/engine_v2_force_diff.txt"
)
$porc = (git status --porcelain | Out-String).Trim()
if(-not [string]::IsNullOrWhiteSpace($porc)){
  Write-Host "FORCE_DIFF_SKIP (workspace dirty)"
  exit 0
}
$dir = Split-Path -Parent $MarkerPath
if(-not [string]::IsNullOrWhiteSpace($dir) -and -not (Test-Path -LiteralPath $dir)){
  New-Item -ItemType Directory -Path $dir -Force | Out-Null
}
$runId = $env:GITHUB_RUN_ID
if([string]::IsNullOrWhiteSpace($runId)){ $runId = "unknown" }
$sha = (git rev-parse HEAD 2>$null)
if([string]::IsNullOrWhiteSpace($sha)){ $sha = "unknown" }
("force-diff {0} run_id={1} sha={2}" -f (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK"), $runId, $sha) |
  Out-File -LiteralPath $MarkerPath -Encoding UTF8
git add $MarkerPath | Out-Null
$porc2 = (git status --porcelain | Out-String).Trim()
if([string]::IsNullOrWhiteSpace($porc2)){
  Write-Host "FORCE_DIFF_FAILED (still clean)"
  exit 0
}
Write-Host "FORCE_DIFF_OK (staged)"
exit 0
