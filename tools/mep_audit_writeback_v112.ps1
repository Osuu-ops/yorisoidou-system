param(
  [Parameter(Mandatory=$true)][int]$PrNumber
)
# v1.12 writeback audit (minimal):
# - PrNumber=0  => SKIPPED (pregate non-interactive default)
# - PrNumber>0  => extract MERGE_COMMIT_SHA via mep_snapshot_proofline_v112.ps1, then verify sha exists in both Bundles
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"
if ($PrNumber -eq 0) {
  Write-Host 'STATE=SKIPPED REASON=PRNUMBER_0 NEXT=NONE' -ForegroundColor Yellow
  exit 0
}
. "$PSScriptRoot\mep_ssot_v112_lib.ps1"
$repoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
if (-not $repoRoot){ throw 'Not a git repo' }
$parent   = Join-Path $repoRoot 'docs/MEP/MEP_BUNDLE.md'
$evidence = Join-Path $repoRoot 'docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md'
if (-not (Test-Path -LiteralPath $parent))  { throw "Missing: $parent" }
if (-not (Test-Path -LiteralPath $evidence)) { throw "Missing: $evidence" }
$proofTool = Join-Path $repoRoot 'tools/mep_snapshot_proofline_v112.ps1'
if (-not (Test-Path -LiteralPath $proofTool)) { throw "Missing: $proofTool" }
# proofline tool should print MERGE_COMMIT_SHA=...
$proofOut = & $proofTool -PrNumber $PrNumber 2>&1
$proofTxt = (@($proofOut) | ForEach-Object { "$_" }) -join "`n"
$sha = ""
$m = [regex]::Match($proofTxt, '(?m)^\s*MERGE_COMMIT_SHA\s*=\s*([0-9a-f]{7,40})\s*$')
if ($m.Success) { $sha = $m.Groups[1].Value.Trim() }
if (-not $sha) {
  throw ("Could not extract MERGE_COMMIT_SHA from proof tool output.`n--- proof output ---`n" + $proofTxt)
}
$parentTxt   = Get-Content -LiteralPath $parent -Raw -Encoding UTF8
$evidenceTxt = Get-Content -LiteralPath $evidence -Raw -Encoding UTF8
$okParent   = ($parentTxt -match [regex]::Escape($sha))
$okEvidence = ($evidenceTxt -match [regex]::Escape($sha))
if (-not $okParent -or -not $okEvidence){
  Write-Host 'STATE=STOP REASON=PROOF_LINES_MISSING NEXT=FIX_WRITEBACK' -ForegroundColor Red
  Write-Host ("MERGE_COMMIT_SHA=" + $sha + " PR=" + $PrNumber)
  Write-Host ("PARENT_HAS_SHA=" + $okParent)
  Write-Host ("EVIDENCE_HAS_SHA=" + $okEvidence)
  exit 2
}
Write-Host 'STATE=ALL_DONE REASON=PROOF_LINES_PRESENT NEXT=NONE' -ForegroundColor Green
Write-Host ("MERGE_COMMIT_SHA=" + $sha + " PR=" + $PrNumber)
exit 0
