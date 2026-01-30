
# --- create PR for the writeback branch (Mode=pr) ---
try {
  $prTitle = ("Writeback bundle evidence (PrNumber={0})" -f $PrNumber)
  $prBody  = ("Automated writeback bundle evidence. Mode={0} PrNumber={1} BundleScope={2} BundlePath={3}" -f $Mode,$PrNumber,$BundleScope,$BundlePath)
  $prUrl = (gh pr create --title $prTitle --body $prBody --base "main" --head $br)
  if ($prUrl) {
    Write-Host ("[INFO] Created PR: {0}" -f $prUrl)
  } else {
    Write-Host "[WARN] gh pr create returned empty. A PR may already exist."
  }
} catch {
  Write-Host ("[WARN] gh pr create failed: {0}" -f $_.Exception.Message)
}param(
  [int]$PrNumber = 0
  ,[ValidateSet("pr","update")][string]$Mode = "pr"
  ,[string]$BundlePath = "docs/MEP/MEP_BUNDLE.md"
  ,[string]$BundleScope = "parent"
  ,[string]$TargetBranchPrefix = "auto/writeback-bundle"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Info([string]$m){ Write-Host "[INFO] $m" }
function Warn([string]$m){ Write-Host "[WARN] $m" }

# NOTE:
# This is a minimal “unblocker” for writeback workflows.
# Contract: (1) parse OK, (2) if bundle file changed -> create PR branch, else exit 0.

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { throw "Not a git repository." }
Set-Location $root

git fetch --prune origin | Out-Null

$bundleAbs = Join-Path $root $BundlePath
if (-not (Test-Path -LiteralPath $bundleAbs)) { throw "Bundle not found: $BundlePath" }

Info ("Mode={0} PrNumber={1} BundleScope={2}" -f $Mode,$PrNumber,$BundleScope)
Info ("BundlePath={0}" -f $BundlePath)
Info ("TargetBranchPrefix={0}" -f $TargetBranchPrefix)

# detect diff only for target bundle file
$diff = (git status --porcelain -- $BundlePath)
if (-not $diff) {
  Info "No diff for bundle. Exit 0."
  exit 0
}

# branch name
$runId  = $env:GITHUB_RUN_ID
$attempt = $env:GITHUB_RUN_ATTEMPT
if (-not $runId) { $runId = "local" }
if (-not $attempt) { $attempt = "1" }
$stamp = (Get-Date -Format "yyyyMMdd_HHmmss")
$branch = "{0}_{1}_{2}_{3}" -f $TargetBranchPrefix,$runId,$attempt,$stamp

Info ("Diff detected -> create branch: {0}" -f $branch)

git checkout -b $branch | Out-Null
git add -- $BundlePath | Out-Null

# commit (keep deterministic message)
git commit -m ("chore(mep): writeback bundle ({0})" -f $BundleScope) | Out-Null
git push -u origin $branch | Out-Null
# --- create PR for the writeback branch (Mode=pr) ---
try {
  $prTitle = ("Writeback bundle evidence (PrNumber={0})" -f $PrNumber)
  $prBody  = ("Automated writeback bundle evidence. Mode={0} PrNumber={1} BundleScope={2} BundlePath={3}" -f $Mode,$PrNumber,$BundleScope,$BundlePath)
  # NOTE: create PR against main; head is the current writeback branch variable used in this script
  # Try common variable names; fall back to current branch name.
  $head = $null
  foreach ($v in @("br","BR","Branch","branch","TargetBranch","targetBranch")) {
    try {
      $val = Get-Variable -Name $v -ValueOnly -ErrorAction SilentlyContinue
      if ($val) { $head = [string]$val; break }
    } catch {}
  }
  if (-not $head) { $head = (git rev-parse --abbrev-ref HEAD) }

  $prUrl = (gh pr create --title $prTitle --body $prBody --base "main" --head $head)
  if ($prUrl) {
    Write-Host ("[INFO] Created PR: {0}" -f $prUrl)
  } else {
    Write-Host "[WARN] gh pr create returned empty. A PR may already exist."
  }
} catch {
  Write-Host ("[WARN] gh pr create failed: {0}" -f $_.Exception.Message)
}


# create PR (best-effort)
$base = $env:GITHUB_REF_NAME
if (-not $base) { $base = "main" }

try {
  $prUrl = (gh pr create --title ("chore(mep): writeback bundle ({0})" -f $BundleScope) --body ("Automated writeback: {0}" -f $BundlePath) --base $base --head $branch 2>$null)
  if ($prUrl) { Info ("PR created: {0}" -f $prUrl) } else { Warn "PR create returned empty (maybe already exists)." }
} catch {
  Warn ("PR create failed (continuing): " + $_.Exception.Message)
}

exit 0

