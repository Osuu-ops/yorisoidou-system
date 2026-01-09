param(
  [Parameter(Mandatory=$false)][string]$ArtifactPath = "mep/MEP_ARTIFACT.md"
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Fail([string]$code, [string]$msg) {
  Write-Host ("{0}: {1}" -f $code, $msg)
  exit 2
}

function Read-Text([string]$p) {
  if (-not (Test-Path $p)) { Fail "AT1000" ("Artifact file not found: {0}" -f $p) }
  return Get-Content -Raw -Encoding UTF8 $p
}

$txt = Read-Text $ArtifactPath

# E: DIRTY stop + conflict markers
if ($txt -match '<<<<<<<|>>>>>>>') { Fail "AT1501" "Conflict markers detected." }

# Parse required headers (top-level keys)
$required = @("ArtifactKind","StatusTag","Scope","Evidence","Changes","Unfinalized","Risks","Next")

$matches = [regex]::Matches(
  $txt,
  '^(ArtifactKind|StatusTag|Scope|Evidence|Changes|Unfinalized|Risks|Next):\s*(.*)$',
  [Text.RegularExpressions.RegexOptions]::Multiline
)

$map = @{}
foreach ($m in $matches) {
  $k = $m.Groups[1].Value
  if ($map.ContainsKey($k)) { Fail "AT1002" ("Duplicate header: {0}" -f $k) }
  $map[$k] = $m.Groups[2].Value.Trim()
}

foreach ($k in $required) {
  if (-not $map.ContainsKey($k)) { Fail "AT1001" ("Missing required header: {0}" -f $k) }
}

$StatusTag = $map["StatusTag"]
$allowed = @("Draft","Adopted","PR Open","Merged to main","Bundled","Completed Gate","DIRTY")
if ($allowed -notcontains $StatusTag) { Fail "AT1003" ("Invalid StatusTag: {0}" -f $StatusTag) }
if ($StatusTag -eq "DIRTY") { Fail "AT1501" "StatusTag DIRTY is a hard stop." }

# Evidence: scan Evidence section lines until next top-level header
$lines = $txt -split "`r?`n"
$idx = -1
for ($i=0; $i -lt $lines.Length; $i++) { if ($lines[$i] -match '^Evidence:\s*$') { $idx = $i; break } }
if ($idx -lt 0) { Fail "AT1101" "Evidence section not found." }

$bvFound = $false
for ($j=$idx+1; $j -lt $lines.Length; $j++) {
  if ($lines[$j] -match '^(ArtifactKind|StatusTag|Scope|Evidence|Changes|Unfinalized|Risks|Next):\s*') { break }
  if ($lines[$j] -match 'BUNDLE_VERSION:\s*v\d+\.\d+\.\d+\+\d{8}_\d{6}\+main_[0-9a-f]{7,40}') { $bvFound = $true; break }
}
if (-not $bvFound) { Fail "AT1101" "Missing BUNDLE_VERSION in Evidence." }

# C: Draft contamination block
if ($StatusTag -eq "Draft") {
  $unfHeader = $map["Unfinalized"]
  if ($unfHeader -eq "None") { Fail "AT1301" "Draft requires Unfinalized != None." }
  if ($txt -match '確定|採用済み|反映済み') { Fail "AT1301" "Draft contains definitive claims." }
}

# D: Evidence convergence guard (simple)
if ($txt -match 'source of truth|唯一の正' -and $txt -notmatch 'BUNDLE') {
  Fail "AT1401" "Non-bundle source-of-truth referenced."
}

# B: Boundary audit (reserved) — enforce BEGIN/END pairing if used
$beginCount = ([regex]::Matches($txt, '^\s*BEGIN\b', [Text.RegularExpressions.RegexOptions]::Multiline)).Count
$endCount   = ([regex]::Matches($txt, '^\s*END\b',   [Text.RegularExpressions.RegexOptions]::Multiline)).Count
if (($beginCount -gt 0) -or ($endCount -gt 0)) {
  if ($beginCount -ne 1 -or $endCount -ne 1) { Fail "AT1201" "BEGIN/END boundary missing or duplicated." }
}

Write-Host "PASS"
exit 0
