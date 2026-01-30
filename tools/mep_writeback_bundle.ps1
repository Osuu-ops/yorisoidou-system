param(
  [int]$PrNumber = 0,
  [ValidateSet("pr","update")][string]$Mode = "pr",
  [string]$BundlePath = "docs/MEP/MEP_BUNDLE.md",
  [string]$BundleScope = "parent"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Info([string]$m){ Write-Host "[INFO] $m" }
function Warn([string]$m){ Write-Host "[WARN] $m" }

# repo root
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { throw "Not a git repository." }
Set-Location $root

# Ensure base refs exist
git fetch --prune origin | Out-Null

# Sanity: target file exists
$bundled = Join-Path $root $BundlePath
if (-not (Test-Path $bundled)) { throw "Bundled not found: $BundlePath" }

# NOTE:
# This script is a minimal “unblocker” to restore workflow execution.
# It intentionally avoids complex MEP logic; its only contract is: parse OK + create PR when bundle changes.

# If you have a generator step elsewhere, it should have already updated $BundlePath before calling us.
# We just detect diff and open PR.
$diff = git status --porcelain -- $BundlePath
if (-not $diff) {
  Info "No diff in $BundlePath. Nothing to write back. Exit 0."
  exit 0
}

$runId = $env:GITHUB_RUN_ID
if (-not $runId) { $runId = "local" }
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$branch = "auto/writeback-bundle_${runId}_${stamp}"

Info "Diff detected in $BundlePath -> create writeback PR branch: $branch"
git checkout -b $branch | Out-Null
git add -- $BundlePath | Out-Null
git commit -m "chore(mep): writeback bundle update ($BundleScope)" | Out-Null
git push -u origin $branch | Out-Null

# Create PR (best-effort; do not fail if PR already exists)
$base = $env:GITHUB_REF_NAME
if (-not $base) { $base = "main" }

try {
  $prUrl = (gh pr create --title "chore(mep): writeback bundle update ($BundleScope)" --body "Automated writeback: $BundlePath" --base $base --head $branch 2>$null)
  if ($prUrl) { Info "PR created: $prUrl" } else { Warn "PR create returned empty (maybe already exists)." }
} catch {
  Warn ("PR create failed (continuing): " + $_.Exception.Message)
}

exit 0