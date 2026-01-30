param(
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