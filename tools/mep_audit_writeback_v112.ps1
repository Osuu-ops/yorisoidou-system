# v1.12 writeback audit (minimal): WIP-025/026 judge by canonical merge line only
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\mep_ssot_v112_lib.ps1"
param(
  [Parameter(Mandatory=$true)][int]$PrNumber
)
$repoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
if (-not $repoRoot){ throw 'Not a git repo' }
$parent = Join-Path $repoRoot 'docs/MEP/MEP_BUNDLE.md'
$evidence = Join-Path $repoRoot 'docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md'
$sha = MepV112-GetMergeCommitSha $PrNumber
$rx = MepV112-GetProofLineRegex $sha $PrNumber
$okParent = MepV112-HasProofLine $parent $rx
$okEvidence = MepV112-HasProofLine $evidence $rx
if (-not $okParent -or -not $okEvidence){
  Write-Host 'STATE=STOP REASON=PROOF_LINE_MISSING NEXT=SYNC_MAIN_OR_WAIT_WRITEBACK' -ForegroundColor Yellow
  Write-Host ("PARENT=" + $okParent + " EVIDENCE=" + $okEvidence + " PROOF_REGEX=" + $rx)
  exit 2
}
Write-Host 'STATE=ALL_DONE REASON=PROOF_LINES_PRESENT NEXT=NONE' -ForegroundColor Green
Write-Host ("MERGE_COMMIT_SHA=" + $sha + " PR=" + $PrNumber)
exit 0
