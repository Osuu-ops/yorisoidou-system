param(
  [int]$PrNumber,
  [string]$BundlePath
)
Set-StrictMode -Version Latest
# --- guard: repoSlug must be defined (Actions: GITHUB_REPOSITORY) ---
if (-not (Get-Variable -Name repoSlug -Scope Script -ErrorAction SilentlyContinue)) { $script:repoSlug = $null }
if (-not $script:repoSlug -or [string]::IsNullOrWhiteSpace([string]$script:repoSlug)) {
  $script:repoSlug = $env:GITHUB_REPOSITORY
}
if (-not $script:repoSlug -or [string]::IsNullOrWhiteSpace([string]$script:repoSlug)) {
  try { $script:repoSlug = (gh repo view --json nameWithOwner --jq '.nameWithOwner') } catch {}
}
if (-not $script:repoSlug -or [string]::IsNullOrWhiteSpace([string]$script:repoSlug)) {
  throw "repoSlug is not set (expected env:GITHUB_REPOSITORY or gh repo view)"
}
# ---------------------------------------------------------------
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"
function Fail($m){ throw $m }
function Info($m){ Write-Host ("[INFO] {0}" -f $m) }
# defaults (NO default assignment in param)
if (-not $PSBoundParameters.ContainsKey("PrNumber")) { $PrNumber = 0 }
if (-not $PSBoundParameters.ContainsKey("BundlePath") -or [string]::IsNullOrWhiteSpace($BundlePath)) { $BundlePath = "docs/MEP/MEP_BUNDLE.md" }
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Fail "Not a git repository" }
Set-Location $root
if (-not (Test-Path $BundlePath)) { Fail ("Bundled not found: " + $BundlePath) }
$bundle = Get-Content $BundlePath -Raw
if ($bundle -notmatch '(?m)^BUNDLE_VERSION\s*=\s*(.+)$') { Fail "BUNDLE_VERSION not found" }
$bundleVersion = ($Matches[1]).Trim()
# Resolve target PR (0 = latest merged into main)
if ($PrNumber -eq 0) {
  $prJson = gh pr list --state merged --base main --limit 1 --json number,mergedAt,mergeCommit,url | ConvertFrom-Json
  if (-not $prJson) { Fail "No merged PR found for base=main" }
  $pr = $prJson[0]
} else {
  $pr = gh pr view $PrNumber --json number,mergedAt,mergeCommit,url | ConvertFrom-Json
}
$prNum       = [int]$pr.number
$mergedAt    = $pr.mergedAt
# --- mergeCommit resolve (robust) ---
$mergeCommit = $null
# gh json may return mergeCommit as:
# - object: { oid = "..." }
# - string: "..."
if ($pr.PSObject.Properties.Name -contains 'mergeCommit') {
  $mc = $pr.mergeCommit
  if ($mc -is [string]) {
    $mergeCommit = $mc
  } elseif ($mc -and ($mc.PSObject.Properties.Name -contains 'oid')) {
    $mergeCommit = $mc.oid
  } elseif ($mc -and ($mc.PSObject.Properties.Name -contains 'sha')) {
    $mergeCommit = $mc.sha
  }
}
# final fallback: GraphQL pullRequest.mergeCommit.oid
if ([string]::IsNullOrWhiteSpace($mergeCommit)) {
  $owner,$name = $repoSlug.Split('/')
  $q = 'query($owner:String!,$name:String!,$number:Int!){repository(owner:$owner,name:$name){pullRequest(number:$number){mergeCommit{oid}}}}'
  $g = gh api graphql -f query="$q" -F owner=$owner -F name=$name -F number=$PrNumber | ConvertFrom-Json
  $mergeCommit = $g.data.repository.pullRequest.mergeCommit.oid
}
if ([string]::IsNullOrWhiteSpace($mergeCommit)) { throw "mergeCommit not found for PR #$PrNumber" }
$url         = $pr.url
# Idempotency: if PR already mentioned, skip
$already = Select-String -InputObject $bundle -Pattern ("PR\s*#\s*{0}\b" -f $prNum) -AllMatches
if ($already) {
  Info ("PR #{0} already exists in {1}. Skip." -f $prNum, $BundlePath)
  exit 0
}
$detailLine = "* - PR #$prNum | mergedAt=$mergedAt | mergeCommit=$mergeCommit | BUNDLE_VERSION=$bundleVersion | audit=OK,WB0000 | $url"
$appendLine = "PR #$prNum | audit=OK,WB0000 | appended_at=$(Get-Date -Format o) | via=mep_append_evidence_line_full.ps1"
Add-Content -Path $BundlePath -Value $detailLine
Add-Content -Path $BundlePath -Value $appendLine
Info ("Appended full evidence for PR #" + $prNum + " -> " + $BundlePath)


