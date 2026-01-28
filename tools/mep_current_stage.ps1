Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$m){ throw $m }
function Info([string]$m){ Write-Host "[STAGE] $m" -ForegroundColor Cyan }

# Args-based protocol (no param block):
#   .\tools\mep_current_stage.ps1 get
#   .\tools\mep_current_stage.ps1 set <VALUE>
#   .\tools\mep_current_stage.ps1 advance
$op = "get"
$value = ""
if ($args -and $args.Count -ge 1) { $op = [string]$args[0] }
if ($args -and $args.Count -ge 2) { $value = [string]$args[1] }

$root = (Get-Location).Path
if (!(Test-Path -LiteralPath (Join-Path $root ".git"))) { Fail "Not a git repo root: $root" }

$stagePath = Join-Path $root ".mep/CURRENT_STAGE.txt"
$stageDir  = Split-Path -Parent $stagePath
if (!(Test-Path -LiteralPath $stageDir)) { New-Item -ItemType Directory -Path $stageDir | Out-Null }
if (!(Test-Path -LiteralPath $stagePath)) { Set-Content -LiteralPath $stagePath -Value "PRE_GATE" -Encoding UTF8 -NoNewline }

function ReadStage() { (Get-Content -LiteralPath $stagePath -Raw).Trim() }
function WriteStage([string]$s) { Set-Content -LiteralPath $stagePath -Value $s -Encoding UTF8 -NoNewline; $s }

$graph = @{
  "PRE_GATE" = "MEP_AUTO"
  "MEP_AUTO" = "DONE"
  "DONE"     = "DONE"
}

switch ($op) {
  "get" {
    $s = ReadStage
    Info ("CURRENT_STAGE=" + $s)
    exit 0
  }
  "set" {
    if ([string]::IsNullOrWhiteSpace($value)) { Fail "set requires value" }
    $s = WriteStage $value
    Info ("CURRENT_STAGE=" + $s)
    exit 0
  }
  "advance" {
    $cur  = ReadStage
    $next = $graph[$cur]
    if (-not $next) { Fail ("No next stage defined for: " + $cur) }
    $s = WriteStage $next
    Info ("CURRENT_STAGE=" + $cur + " -> " + $s)
    exit 0
  }
  default {
    Fail ("Unknown op: " + $op + " (use get/set/advance)")
  }
}