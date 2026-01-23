[CmdletBinding()]
param(
  [Parameter()][string]$HandoffPath = "docs/MEP/HANDOFF_NEXT.generated.md"
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string[]]$msgs) {
  $msgs | ForEach-Object { Write-Output ("[NG] {0}" -f $_) }
  exit 1
}

if (-not (Test-Path -LiteralPath $HandoffPath)) { Fail @("Handoff file missing: $HandoffPath") }

$txt = Get-Content -LiteralPath $HandoffPath -Encoding UTF8
$errs = @()

if (-not ($txt | Select-String -Pattern '## 引継ぎ文兼 指令書' -SimpleMatch)) { $errs += "Header missing" }
if (-not ($txt | Select-String -Pattern 'BUNDLE_VERSION\s*=')) { $errs += "BUNDLE_VERSION missing" }
if (-not ($txt | Select-String -Pattern '進捗台帳（機械生成）：' -SimpleMatch)) { $errs += "Progress ledger section missing" }
if (-not ($txt | Select-String -Pattern '\* OK（audit=OK,WB0000）')) { $errs += "OK section missing" }
if (-not ($txt | Select-String -Pattern '\* NG（audit=NG）')) { $errs += "NG section missing" }
if ($txt | Select-String -Pattern '^\[STATUS=') { $errs += "Meta status line found (must not be embedded)" }

if ($errs.Count -gt 0) { Fail $errs }

Write-Output "[OK] handoff format passes: $HandoffPath"
exit 0
