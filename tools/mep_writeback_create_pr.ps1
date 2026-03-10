param(
  [Parameter(Mandatory=$true)]
  [ValidateNotNullOrEmpty()]
  [string]$BundlePath,

  [Parameter()]
  [string[]]$AdditionalPaths = @()
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Info([string]$m){ Write-Host ("[INFO] {0}" -f $m) }
function Warn([string]$m){ Write-Host ("[WARN] {0}" -f $m) }
function StopHard([string]$m){ throw ("STOP_HARD: " + $m) }

function Resolve-WritebackPaths {
  param(
    [Parameter(Mandatory=$true)]
    [string]$PrimaryPath,

    [Parameter()]
    [string[]]$MorePaths = @()
  )

  $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
  $resolved = New-Object System.Collections.Generic.List[string]
  foreach ($candidate in @($PrimaryPath) + @($MorePaths)) {
    $path = [string]$candidate
    if ([string]::IsNullOrWhiteSpace($path)) { continue }
    $path = $path.Trim()
    if ($seen.Add($path)) {
      [void]$resolved.Add($path)
    }
  }
  return ,$resolved.ToArray()
}

function Assert-ControllerLock {
  $label = [string]$env:MEP_CONTROLLER_LABEL
  $expected = [string]$env:MEP_EXPECTED_CONTROLLER_LABEL
  if ([string]::IsNullOrWhiteSpace($label)) { StopHard "PR_CONTROLLER_LOCK_MISSING" }
  if ($label -notmatch '^mep:controller=CHAT_[A-Za-z0-9_]+$') { StopHard "PR_CONTROLLER_LOCK_INVALID_FORMAT" }
  if (-not [string]::IsNullOrWhiteSpace($expected) -and $label -ne $expected) {
    StopHard ("PR_CONTROLLER_LOCK_MISMATCH expected=" + $expected + " actual=" + $label)
  }
  Info ("Controller lock OK: " + $label)
}

function Resolve-FullRepo {
  $r = [string]($env:GITHUB_REPOSITORY)
  if (-not [string]::IsNullOrWhiteSpace($r)) { return $r.Trim() }
  try {
    $v = (gh repo view --json nameWithOwner -q .nameWithOwner 2>$null)
    if (-not [string]::IsNullOrWhiteSpace($v)) { return $v.Trim() }
  } catch {}
  return ""
}

function Ensure-PrForHead([string]$head, [string]$base, [string]$title, [string]$body){
  $exists = $null
  try { $exists = gh pr list --state open --head $head --base $base --json number,url --jq '.[0].url' 2>$null } catch {}
  if (-not [string]::IsNullOrWhiteSpace([string]$exists)) {
    Info ("PR already exists for head " + $head + ": " + $exists.Trim())
    return $exists.Trim()
  }
  $url = gh pr create --base $base --head $head --title $title --body $body
  Info ("Created PR: " + $url)
  return $url
}

Assert-ControllerLock

$writebackPaths = Resolve-WritebackPaths -PrimaryPath $BundlePath -MorePaths $AdditionalPaths
Info ("WritebackPaths=" + ($writebackPaths -join ', '))
foreach ($path in $writebackPaths) {
  if (-not (Test-Path -LiteralPath $path)) {
    StopHard ("WRITEBACK_PATH_MISSING: " + $path)
  }
}

$repo = Resolve-FullRepo
if ($repo) { Info ("Repo=" + $repo) } else { Warn "Repo unresolved; using gh defaults" }

$head = (git rev-parse --abbrev-ref HEAD).Trim()
$base = "main"
$runId = [string]$env:GITHUB_RUN_ID; if ([string]::IsNullOrWhiteSpace($runId)) { $runId = "0" }
$prNo  = [string]$env:PR_NUMBER;     if ([string]::IsNullOrWhiteSpace($prNo))  { $prNo  = "0" }

if ($head -like "auto/writeback-bundle_*") {
  $title = ("Writeback bundle evidence ({0})" -f $head)
  $body  = ("Automated writeback: created from branch {0} (run_id={1})" -f $head, $runId)
  [void](Ensure-PrForHead -head $head -base $base -title $title -body $body)
  exit 0
}

$dirty = ((& git status --porcelain -- @writebackPaths) | Out-String).Trim()
if (-not $dirty) {
  Info "Working tree clean for writeback paths; nothing to write back."
  exit 0
}

$ts = (Get-Date -Format "yyyyMMdd_HHmmss")
$newHead = ("auto/writeback-bundle_{0}_{1}_{2}" -f $runId, $prNo, $ts)
Warn ("Not on auto/writeback-bundle_*; creating branch " + $newHead)

git switch -c $newHead | Out-Null

& git add -- @writebackPaths | Out-Null
$staged = ((& git diff --cached --name-only -- @writebackPaths) | Out-String).Trim()
if (-not $staged) {
  Info "No staged changes for writeback paths; skip push/PR."
  exit 0
}

$msg = ("chore(mep): writeback bundle evidence (PR #{0}) (run {1})" -f $prNo, $runId)
git commit -m $msg | Out-Null

try {
  pwsh -NoProfile -File tools/mep_fix_bundle_version_suffix_to_head.ps1 -BundlePath $BundlePath
  $suffixChanged = ((& git status --porcelain -- @writebackPaths) | Out-String).Trim()
  if ($suffixChanged) {
    & git add -- @writebackPaths | Out-Null
    git commit -m ("chore(mep): align bundle version suffix to HEAD ({0})" -f $runId) | Out-Null
  }
} catch {
  Warn ("mep_fix_bundle_version_suffix_to_head.ps1 failed: " + $_.Exception.Message)
}

git push -u origin $newHead | Out-Null
$title = ("Writeback bundle evidence ({0})" -f $newHead)
$body  = ("Automated writeback: created from branch {0} (run_id={1})" -f $newHead, $runId)
[void](Ensure-PrForHead -head $newHead -base $base -title $title -body $body)
