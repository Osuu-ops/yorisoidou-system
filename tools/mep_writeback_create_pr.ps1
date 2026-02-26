param(
  [Parameter(Mandatory=$true)]
  [string]$BundlePath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Info([string]$m){ Write-Host ("[INFO] {0}" -f $m) }
function Warn([string]$m){ Write-Host ("[WARN] {0}
function Resolve-FullRepo(){
  $r = ($env:GITHUB_REPOSITORY ?? "").Trim()
  if ($r) { return $r }
  try { return (gh repo view --json nameWithOwner -q .nameWithOwner).Trim() } catch {}
  return ""
}
function AutoClose-StaleWritebackPrs([string]$keepHead){
  $fullRepo = Resolve-FullRepo
  if (-not $fullRepo) { Warn "AUTO_CLOSE_SKIP: cannot resolve repo"; return }
  # Close other open writeback PRs to avoid pile-up
  $lines = $null
  try {
    $lines = gh pr list -R $fullRepo --state open --json number,headRefName,title --jq '.[] | select(.title|startswith("Writeback bundle evidence")) | "\(.number)\t\(.headRefName)"' 2>$null
  } catch {
    Warn ("AUTO_CLOSE_LIST_FAILED: " + param(
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
# ---- ensure BUNDLE_VERSION main_<hash> matches the commit that contains it (race-proof) ----
try {
  $bundlePathResolved = $BundlePath
  if (-not $bundlePathResolved) { $bundlePathResolved = "docs/MEP/MEP_BUNDLE.md" }
  pwsh -NoProfile -File tools/mep_fix_bundle_version_suffix_to_head.ps1 -BundlePath $bundlePathResolved
} catch {
  Write-Host "[WARN] mep_fix_bundle_version_suffix_to_head.ps1 failed: $($_.Exception.Message)"
}
# ------------------------------------------------------------------------------

git push -u origin $newHead | Out-Null
Ensure-PrForHead $newHead


.Exception.Message)
    return
  }
  $arr = @()
  if ($lines) { $arr = @($lines) }
  foreach($ln in $arr){
    $cols = $ln -split "`t"
    if($cols.Count -ge 2){
      $n = [int]$cols[0]
      $h = [string]$cols[1]
      if($h -and ($h -ne $keepHead)){
        try {
          gh pr close -R $fullRepo $n --comment ("Auto-close: stale writeback PR; keep head=" + $keepHead) 1>$null 2>$null
        } catch {}
      }
    }
  }
}
" -f $m) }
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
# ---- ensure BUNDLE_VERSION main_<hash> matches the commit that contains it (race-proof) ----
try {
  $bundlePathResolved = $BundlePath
  if (-not $bundlePathResolved) { $bundlePathResolved = "docs/MEP/MEP_BUNDLE.md" }
  pwsh -NoProfile -File tools/mep_fix_bundle_version_suffix_to_head.ps1 -BundlePath $bundlePathResolved
} catch {
  Write-Host "[WARN] mep_fix_bundle_version_suffix_to_head.ps1 failed: $($_.Exception.Message)"
}
# ------------------------------------------------------------------------------

git push -u origin $newHead | Out-Null
Ensure-PrForHead $newHead


