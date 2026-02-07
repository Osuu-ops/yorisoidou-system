
param(
  [Parameter(Mandatory=$true)][int]$PrNumber
)
$repoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
if (-not $repoRoot) { throw "Not a git repo" }
$bundled = Join-Path $repoRoot "docs/MEP/MEP_BUNDLE.md"
$evid    = Join-Path $repoRoot "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"
$mergeSha = (gh pr view $PrNumber --json mergeCommit --jq '.mergeCommit.oid' 2>$null).Trim()
if (-not $mergeSha) { throw "mergeCommit not found for PR #$PrNumber" }
$rx = ('^{0}\s+Merge pull request #{1}\b' -f $mergeSha, $PrNumber)
Write-Host ("MERGE_COMMIT_SHA " + $mergeSha)
Write-Host ("PROOF_REGEX " + $rx)
function FirstMatchLine([string]$path, [string]$pattern){
  if (-not (Test-Path $path)) { return "<missing>" }
  $m = Select-String -LiteralPath $path -Pattern $pattern | Select-Object -First 1
  if ($null -eq $m) { return "<none>" }
  return $m.Line
}
Write-Host ("PARENT_BUNDLED_MATCH " + (FirstMatchLine $bundled $rx))
Write-Host ("EVIDENCE_BUNDLE_MATCH " + (FirstMatchLine $evid $rx))