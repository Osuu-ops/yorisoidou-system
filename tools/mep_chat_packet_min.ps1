$ErrorActionPreference = "Stop"
try { chcp 65001 | Out-Null } catch {}
$utf8 = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $utf8
[Console]::InputEncoding  = $utf8
$OutputEncoding = $utf8

$repoRoot = (git rev-parse --show-toplevel 2>$null)
if (-not $repoRoot) { throw "Not inside a git repo." }

$head = (git -C $repoRoot rev-parse HEAD).Trim()
$remote = (git -C $repoRoot remote get-url origin).Trim()

function ReadFile([string]$rel) {
  $p = Join-Path $repoRoot $rel
  if (-not (Test-Path $p)) { return $null }
  return (Get-Content -LiteralPath $p -Encoding UTF8 -Raw)
}

$paths = @(
  "docs/MEP/START_HERE.md",
  
  "docs/MEP/CHAT_STYLE_CONTRACT.md",
  "docs/MEP/STATE_CURRENT.md",
  "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  "platform/MEP/03_BUSINESS/よりそい堂/master_spec",
  "platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md",
  "docs/MEP/RUNBOOK.md"
)

Write-Output "# CHAT_PACKET_MIN (MEP)  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Output ""
Write-Output "## META"
Write-Output "- repo: $remote"
Write-Output "- head: $head"
Write-Output ""
Write-Output "## BOOT RULE"
Write-Output "- New chat (memory=0): do NOT request 10+ files. Ask to paste this packet again if needed."
Write-Output "- Provide one-paste PowerShell blocks."
Write-Output ""

foreach ($rel in $paths) {
  $txt = ReadFile $rel
  if ($null -ne $txt -and $txt.Trim().Length -gt 0) {
    Write-Output ("--- BEGIN FILE: {0} ---" -f $rel)
    Write-Output "```"
    $norm = $txt -replace "`r`n","`n" -replace "`r","`n"
    Write-Output $norm.TrimEnd()
    Write-Output "```"
    Write-Output ("--- END FILE: {0} ---" -f $rel)
    Write-Output ""
  }
}
Write-Output "## END"

