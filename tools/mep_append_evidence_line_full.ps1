Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

param(
  [Parameter(Mandatory=$false)][int]$PrNumber = 0,
  [Parameter(Mandatory=$false)][string]$BundlePath = "docs/MEP/MEP_BUNDLE.md",
  [Parameter(Mandatory=$false)][ValidateSet("OK","NG")][string]$Audit = "OK",
  [Parameter(Mandatory=$false)][string]$WB = "WB0000",
  [Parameter(Mandatory=$false)][string]$Repo = ""
)

function Info([string]$m){ Write-Host ("[INFO] " + $m) }
function Warn([string]$m){ Write-Host ("[WARN] " + $m) }
function Fail([string]$m){ throw $m }

if (-not $Repo) {
  try {
    $u = (git remote get-url origin).Trim()
    if ($u -match "github\.com[/:]([^/]+)/([^/.]+)(:\.git)$") {
      $Repo = ("{0}/{1}" -f $Matches[1], $Matches[2])
    }
  } catch {}
}
if (-not $Repo) { Fail "Repo could not be inferred. Pass -Repo owner/name." }

if (-not (Test-Path $BundlePath)) { Fail "BundlePath not found: $BundlePath" }

# Read current BUNDLE_VERSION (first line + possible wrap)
$bvLine = (Select-String -Path $BundlePath -Pattern "^BUNDLE_VERSION\s*=" -Context 0,2 | Select-Object -First 1)
if (-not $bvLine) { Fail "BUNDLE_VERSION line not found in $BundlePath" }
$bvText = $bvLine.Line
# handle wrapped next line (common in this repo)
$bvNext = $null
try {
  $all = Get-Content -Path $BundlePath -Encoding utf8
  $idx = $bvLine.LineNumber - 1
  if ($idx -ge 0 -and $idx+1 -lt $all.Count) {
    if ($all[$idx] -match "^BUNDLE_VERSION\s*=\s*v0\.0\.0\+$" -and $all[$idx+1] -match "^\d{8}_\d{6}\+main") {
      $bvText = ($all[$idx] + $all[$idx+1]).Replace("`r","")
    }
  }
} catch {}
# normalize: "BUNDLE_VERSION = v0.0.0+...."
$bvVal = $null
if ($bvText -match "BUNDLE_VERSION\s*=\s*(.+)$") { $bvVal = $Matches[1].Trim() }
if (-not $bvVal) { Fail "Could not parse BUNDLE_VERSION value." }

# If PrNumber=0: auto-select latest merged PR into main
if ($PrNumber -eq 0) {
  # Search merged PRs, newest first
  $q = "repo:$Repo is:pr is:merged base:main sort:updated-desc"
  $j = gh api graphql -f query="query(\$q:String!){ search(query:\$q, type:ISSUE, first:20){ nodes { ... on PullRequest { number mergedAt mergeCommit { oid } url } } } }" -f q="$q" | ConvertFrom-Json
  $node = $j.data.search.nodes | Where-Object { $_.mergedAt } | Select-Object -First 1
  if (-not $node) { Fail "No merged PR found to auto-select." }
  $PrNumber = [int]$node.number
}

# Fetch PR details
$pr = gh api "repos/$Repo/pulls/$PrNumber" | ConvertFrom-Json
if (-not $pr.merged_at) { Fail "PR #$PrNumber is not merged (merged_at is null)." }

# Format mergedAt to match existing style "MM/dd/yyyy HH:mm:ss"
$dt = [DateTime]::Parse($pr.merged_at).ToLocalTime()
$mergedAt = $dt.ToString("MM/dd/yyyy HH:mm:ss")
$mergeCommit = [string]$pr.merge_commit_sha
$url = [string]$pr.html_url

# Read file
$lines = Get-Content -Path $BundlePath -Encoding utf8

# Idempotency: skip if already present (either detailed list or appended_at)
$already = $false
if ($lines -match ("PR\s*#"+$PrNumber+"\b")) { $already = $true }

if ($already) {
  Info ("Skip: PR #{0} already appears somewhere in Bundled." -f $PrNumber)
  exit 0
}

# Build two lines:
# 1) detailed list line (keep same bullet prefix as existing evidence list: "  * - PR #...")
$detailed = ("  * - PR #{0} | mergedAt={1} | mergeCommit={2} | BUNDLE_VERSION={3} | audit={4},{5} | {6}" -f $PrNumber, $mergedAt, $mergeCommit, $bvVal, $Audit, $WB, $url)

# 2) appended_at line (flat)
$nowUtc = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
$appended = ("PR #{0} | audit={1},{2} | appended_at={3} | via=mep_append_evidence_line_full.ps1" -f $PrNumber, $Audit, $WB, $nowUtc)

# Insert detailed line after the last existing detailed evidence list line if possible.
# Find last line that looks like "  * - PR #123 ..."
$idxList = -1
for ($i=0; $i -lt $lines.Count; $i++){
  if ($lines[$i] -match "^\s*\*\s*-\s*PR\s*#\d+") { $idxList = $i }
}
if ($idxList -ge 0) {
  $lines = @($lines[0..$idxList] + $detailed + $lines[($idxList+1)..($lines.Count-1)])
} else {
  # fallback: append near end with a separator
  $lines += ""
  $lines += $detailed
}

# Insert appended_at after last appended_at/audit marker line if exists; else append to end.
$idxApp = -1
for ($i=0; $i -lt $lines.Count; $i++){
  if ($lines[$i] -match "^PR\s*#\d+\s*\|\s*audit=") { $idxApp = $i }
}
if ($idxApp -ge 0) {
  $lines = @($lines[0..$idxApp] + $appended + $lines[($idxApp+1)..($lines.Count-1)])
} else {
  $lines += ""
  $lines += $appended
}

# Write back
Set-Content -Path $BundlePath -Value $lines -Encoding utf8
Info ("Appended: detailed+appended_at for PR #{0}" -f $PrNumber)
