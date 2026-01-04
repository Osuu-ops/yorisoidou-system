param()

$ErrorActionPreference = "Stop"

# ===== CHAT_PACKET_MIN generator (PS5.1-safe) =====
# - Avoids hardcoding any non-ASCII path literals (prevents mojibake in script parsing)
# - Dynamically resolves BUSINESS master_spec (no extension) under platform/MEP/03_BUSINESS/*/master_spec
# - Includes IDEA_INDEX if present
# - Normalizes embedded content to LF

$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$headSha = (& git rev-parse HEAD).Trim()

$repoUrl = ""
try { $repoUrl = (& git remote get-url origin).Trim() } catch { $repoUrl = "" }

function Resolve-BusinessMasterSpecPath {
  $all = (& git ls-tree --full-tree -r HEAD --name-only) | ForEach-Object { $_.Trim() }

  # Prefer extensionless master_spec (canonical) under BUSINESS
  $cands = @($all | Where-Object { $_ -like "platform/MEP/03_BUSINESS/*/master_spec" })
  if ($cands.Count -eq 0) { throw "Cannot find platform/MEP/03_BUSINESS/*/master_spec (no extension) on HEAD." }

  # If multiple, prefer one whose sibling ui_spec.md exists
  foreach ($p in $cands) {
    $dir = (Split-Path $p -Parent) -replace "\\","/"
    $ui  = "$dir/ui_spec.md"
    if ($all -contains $ui) { return $p }
  }

  # Fallback: first candidate
  return $cands[0]
}

$msPath = Resolve-BusinessMasterSpecPath
$msDir  = (Split-Path $msPath -Parent) -replace "\\","/"
$uiPath = "$msDir/ui_spec.md"

# Base embed list (fixed order)
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
    $raw = $raw -replace "`r`n", "`n"
    $raw = $raw -replace "`r", "`n"
    Write-Output $raw
  } else {
    Write-Output ("(MISSING) {0}" -f $f)
  }

  Write-Output ("--- END FILE: {0} ---" -f $f)
  Write-Output ""
}

Write-Output "## END"