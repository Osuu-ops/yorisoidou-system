Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"

param(
  [int]$PrNumber = 0,
  [string]$BundlePath = "docs/MEP/MEP_BUNDLE.md"
)

function Fail($m){ throw $m }
function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Fail "Not a git repository" }
Set-Location $root

if (-not (Test-Path $BundlePath)) { Fail ("Bundled not found: " + $BundlePath) }
$bundle = Get-Content $BundlePath -Raw

if ($bundle -notmatch '(m)^BUNDLE_VERSION\s*=\s*(.+)$') { Fail "BUNDLE_VERSION not found" }
$bundleVersion = ($Matches[1]).Trim()

# Resolve target PR (0 = latest merged)
if ($PrNumber -eq 0) {
  $prJson = gh pr list --state merged --limit 1 --json number,mergedAt,mergeCommit,url | ConvertFrom-Json
  if (-not $prJson) { Fail "No merged PR found" }
  $pr = $prJson[0]
} else {
  $pr = gh pr view $PrNumber --json number,mergedAt,mergeCommit,url | ConvertFrom-Json
}

$prNum       = [int]$pr.number
$mergedAt    = $pr.mergedAt
$mergeCommit = $pr.mergeCommit.oid
$url         = $pr.url

# Idempotency: if appended_at(full) already exists, skip
if ($bundle -match ("(m)^PR\s+#" + $prNum + "\s+\|\s+audit=OK,WB0000\s+\|\s+appended_at=.*\|\s+via=mep_append_evidence_line_full\.ps1\s*$")) {
  Info ("Full evidence already exists for PR #" + $prNum + ". Skip.")
  exit 0
}

$detailLine = "* - PR #$prNum | mergedAt=$mergedAt | mergeCommit=$mergeCommit | BUNDLE_VERSION=$bundleVersion | audit=OK,WB0000 | $url"
$appendLine = "PR #$prNum | audit=OK,WB0000 | appended_at=$(Get-Date -Format o) | via=mep_append_evidence_line_full.ps1"

Add-Content -Path $BundlePath -Value $detailLine
Add-Content -Path $BundlePath -Value $appendLine

Info ("Appended full evidence for PR #" + $prNum)
