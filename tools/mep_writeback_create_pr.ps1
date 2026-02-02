param(
  [Parameter(Mandatory=$true)]
  [string]$BundlePath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Info([string]$m){ Write-Host ("[INFO] {0}" -f $m) }
function Warn([string]$m){ Write-Host ("[WARN] {0}" -f $m) }
$head = (git rev-parse --abbrev-ref HEAD).Trim()
Info ("HEAD=" + $head)
function Ensure-PrForHead([string]$h){
  $exists = $null
  try { $exists = gh pr list --state open --head $h --json number --jq '.[0].number' 2>$null } catch {}
  if ($exists) { Info ("PR already exists for head " + $h + ": #" + $exists); return }
  $runId = $env:GITHUB_RUN_ID; if (-not $runId) { $runId = "0" }
  $title = ("Writeback bundle evidence ({0})" -f $h)
  $body  = ("Automated writeback: created from branch {0} (run_id={1})" -f $h, $runId)
  $url = gh pr create --title $title --body $body --base "main" --head $h
  Info ("Created PR: " + $url)
}
if ($head -like "auto/writeback-bundle_*") {
  Ensure-PrForHead $head
  exit 0
}
$dirty = ([string](git status --porcelain)).Trim()
if (-not $dirty) {
  Info "Working tree clean; nothing to write back."
  exit 0
}
$runId = $env:GITHUB_RUN_ID; if (-not $runId) { $runId = "0" }
$prNo  = $env:PR_NUMBER;    if (-not $prNo)  { $prNo  = "0" }
$ts = (Get-Date -Format "yyyyMMdd_HHmmss")
$newHead = ("auto/writeback-bundle_{0}_{1}_{2}" -f $runId, $prNo, $ts)
Warn ("Not on auto/writeback-bundle_*; creating branch " + $newHead)
git switch -c $newHead | Out-Null
git add -- $BundlePath | Out-Null
$dirty2 = ([string](git status --porcelain)).Trim()
if (-not $dirty2) {
  Info "No staged changes for bundle; skip push/PR."
  exit 0
}
$msg = ("chore(mep): writeback bundle evidence (PR #{0}) (run {1})" -f $prNo, $runId)
git commit -m $msg | Out-Null
git push -u origin $newHead | Out-Null
Ensure-PrForHead $newHead

