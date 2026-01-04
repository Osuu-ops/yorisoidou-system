# PATCH: derive BUSINESS master_spec from STATE_CURRENT (CURRENT_SCOPE)
$STATE_CURRENT_PATH = "docs/MEP/STATE_CURRENT.md"
if (-not (Test-Path $STATE_CURRENT_PATH)) { throw "Missing: docs/MEP/STATE_CURRENT.md" }

$state = Get-Content -LiteralPath $STATE_CURRENT_PATH -Raw -Encoding UTF8

# Extract first scope line like: - platform/MEP/03_BUSINESS/<NAME>/**
$scopeLine = ($state -split "
" | Where-Object { $_ -match '^\s*-\s*platform/MEP/03_BUSINESS/.+/\*\*' } | Select-Object -First 1)
if (-not $scopeLine) { throw "Cannot derive BUSINESS scope from STATE_CURRENT.md" }

$scopeLine = $scopeLine.Trim()
# Remove leading "- " then strip trailing "/**"
$scopePath = ($scopeLine -replace '^\s*-\s*', '')
$scopePath = ($scopePath -replace '/\*\*\s*$', '')

# Canonical master_spec is under that folder
$BUSINESS_MASTER_SPEC = Join-Path $scopePath "master_spec"
if (-not (Test-Path $BUSINESS_MASTER_SPEC)) {
  throw "Cannot find BUSINESS master_spec at derived path: $BUSINESS_MASTER_SPEC"
}
# END PATCH
param()

$ErrorActionPreference = "Stop"

# CHAT_PACKET_MIN generator (PS5.1-safe)
# - No hardcoded non-ASCII path literals
# - Dynamically resolves BUSINESS master_spec under platform/MEP/03_BUSINESS/*/master_spec
# - Includes IDEA_INDEX if present
# - Normalizes embedded text to LF

$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$headSha = (& git rev-parse HEAD).Trim()

$repoUrl = ""
try { $repoUrl = (& git remote get-url origin).Trim() } catch { $repoUrl = "" }

function Resolve-BusinessMasterSpecPath {
  $all = (& git ls-tree --full-tree -r HEAD --name-only) | ForEach-Object { $_.Trim() }
  $cands = @($all | Where-Object { $_ -like "platform/MEP/03_BUSINESS/*/master_spec" })
  if ($cands.Count -eq 0) { throw "Cannot find BUSINESS master_spec under platform/MEP/03_BUSINESS/*/master_spec." }
  foreach ($p in $cands) {
    $dir = (Split-Path $p -Parent) -replace "\\","/"
    $ui  = "$dir/ui_spec.md"
    if ($all -contains $ui) { return $p }
  }
  return $cands[0]
}

$msPath = Resolve-BusinessMasterSpecPath
$msDir  = (Split-Path $msPath -Parent) -replace "\\","/"
$uiPath = "$msDir/ui_spec.md"

$files = New-Object System.Collections.Generic.List[string]
$files.Add("docs/MEP/START_HERE.md")
$files.Add("docs/MEP/CHAT_STYLE_CONTRACT.md")
$files.Add("docs/MEP/STATE_CURRENT.md")
$files.Add("platform/MEP/90_CHANGES/CURRENT_SCOPE.md")
$files.Add($msPath)
$files.Add($uiPath)
$files.Add("docs/MEP/RUNBOOK.md")
if (Test-Path "docs/MEP/IDEA_INDEX.md") { $files.Add("docs/MEP/IDEA_INDEX.md") }

Write-Output ("# CHAT_PACKET_MIN (MEP)  {0}" -f $ts)
Write-Output ""
Write-Output "## META"
if ($repoUrl) { Write-Output ("- repo: {0}" -f $repoUrl) } else { Write-Output "- repo: (unknown)" }
Write-Output ("- head: {0}" -f $headSha)
Write-Output ""
Write-Output "## BOOT RULE"
Write-Output "- New chat (memory=0): do NOT request 10+ files. Ask to paste this packet again if needed."
Write-Output "- Provide one-paste PowerShell blocks."
Write-Output ""
Write-Output "## NOTES"
Write-Output "- If IDEA_INDEX is present, ideas captured in this repo will be visible in this packet."
Write-Output ""

foreach ($f in $files) {
  Write-Output ("--- BEGIN FILE: {0} ---" -f $f)
  if (Test-Path $f) {
    $raw = Get-Content -LiteralPath $f -Raw -Encoding UTF8
    if ($null -eq $raw) { $raw = "" }
    $raw = $raw -replace "`r`n","`n"
    $raw = $raw -replace "`r","`n"
    Write-Output $raw
  } else {
    Write-Output ("(MISSING) {0}" -f $f)
  }
  Write-Output ("--- END FILE: {0} ---" -f $f)
  Write-Output ""
}

Write-Output "## END"