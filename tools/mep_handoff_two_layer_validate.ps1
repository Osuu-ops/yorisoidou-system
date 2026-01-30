Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding

param(
  [Parameter(Mandatory=$true)]
  [string]$Path
)

function Fail([string]$m){
  Write-Host "[NG] $m"
  exit 2
}

if (-not (Test-Path -LiteralPath $Path)) { Fail "File not found: $Path" }

$text = Get-Content -LiteralPath $Path -Raw

$idxA = $text.IndexOf("[監査用引継ぎ]")
$idxB = $text.IndexOf("[作業用引継ぎ]")

if ($idxA -lt 0) { Fail "WB0001: Missing [監査用引継ぎ]" }
if ($idxB -lt 0) { Fail "WB0001: Missing [作業用引継ぎ]" }
if ($idxB -lt $idxA) { Fail "WB0001: Layer order invalid (作業用 before 監査用)" }

$a = $text.Substring($idxA, $idxB - $idxA)

if ($a -notmatch "(?m)^\s*-\s*BUNDLE_VERSION\s*=") { Fail "WB0001: Audit layer lacks BUNDLE_VERSION line" }
if ($a -notmatch "(?m)PR\s*#\d+") { Fail "WB0001: Audit layer lacks PR #<number> evidence line" }

$forbidden = @("未完タスク","次工程","注意点","TODO","todo","やること")
foreach($w in $forbidden){
  if ($a -match [regex]::Escape($w)) { Fail "WB0001: Audit layer contains non-evidence token: $w" }
}

Write-Host "[OK] Two-layer handoff format validated."
exit 0