Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

param(
  [ValidateSet("get","set","advance")]
  [string]$op = "get",
  [string]$value = ""
)

function Fail([string]$m){ throw $m }
function Info([string]$m){ Write-Host "[STAGE] $m" -ForegroundColor Cyan }

$root = (Get-Location).Path
if (!(Test-Path -LiteralPath (Join-Path $root ".git"))) { Fail "Not a git repo root: $root" }

$stagePath = Join-Path $root ".mep/CURRENT_STAGE.txt"
if (!(Test-Path -LiteralPath $stagePath)) { Set-Content -LiteralPath $stagePath -Value "PRE_GATE" -Encoding UTF8 -NoNewline }

function ReadStage() { (Get-Content -LiteralPath $stagePath -Raw).Trim() }
function WriteStage([string]$s) { Set-Content -LiteralPath $stagePath -Value $s -Encoding UTF8 -NoNewline; $s }

# Minimal stage graph (extend later safely)
$graph = @{
  "PRE_GATE" = "MEP_AUTO"
  "MEP_AUTO" = "DONE"
  "DONE"     = "DONE"
}

switch ($op) {
  "get" {
    $s = ReadStage
    Info "CURRENT_STAGE=$s"
    exit 0
  }
  "set" {
    if ([string]::IsNullOrWhiteSpace($value)) { Fail "set requires -value" }
    $s = WriteStage $value
    Info "CURRENT_STAGE=$s"
    exit 0
  }
  "advance" {
    $cur = ReadStage
    $next = $graph[$cur]
    if (-not $next) { Fail "No next stage defined for: $cur" }
    $s = WriteStage $next
    Info "CURRENT_STAGE=$cur -> $s"
    exit 0
  }
}