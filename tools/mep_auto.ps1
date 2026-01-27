Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

param(
  [switch]$Once
)

function Fail([string]$m){ throw $m }
function Info([string]$m){ Write-Host "[AUTO] $m" -ForegroundColor Cyan }

$root = (Get-Location).Path
if (!(Test-Path -LiteralPath (Join-Path $root ".git"))) { Fail "Not a git repo root: $root" }

$preGate = Join-Path $root "tools/pre_gate.ps1"
if (!(Test-Path -LiteralPath $preGate)) { Fail "Missing single-truth Pre-Gate: tools/pre_gate.ps1" }

$stageTool = Join-Path $root "tools/mep_current_stage.ps1"
if (!(Test-Path -LiteralPath $stageTool)) { Fail "Missing: tools/mep_current_stage.ps1" }

function ReadStage() {
  $p = Join-Path $root ".mep/CURRENT_STAGE.txt"
  if (!(Test-Path -LiteralPath $p)) { Set-Content -LiteralPath $p -Value "PRE_GATE" -Encoding UTF8 -NoNewline }
  (Get-Content -LiteralPath $p -Raw).Trim()
}

function RunPreGate() {
  Info "Run Pre-Gate (single truth): tools/pre_gate.ps1"
  & $preGate
  $code = $LASTEXITCODE
  if ($code -ne 0) { Fail "Pre-Gate failed (exit=$code)" }
}

function RunStage([string]$stage) {
  switch ($stage) {
    "PRE_GATE" {
      RunPreGate
      & $stageTool -op advance | Out-Null
      return
    }
    "MEP_AUTO" {
      # If autopilot exists, run it. Otherwise just advance to DONE.
      $autopilot = Join-Path $root "tools/mep_autopilot.ps1"
      if (Test-Path -LiteralPath $autopilot) {
        Info "Run tools/mep_autopilot.ps1"
        & $autopilot
        $code = $LASTEXITCODE
        if ($code -ne 0) { Fail "mep_autopilot failed (exit=$code)" }
      } else {
        Info "No mep_autopilot.ps1 found; skipping."
      }
      & $stageTool -op advance | Out-Null
      return
    }
    "DONE" {
      Info "CURRENT_STAGE=DONE"
      return
    }
    default {
      Fail "Unknown CURRENT_STAGE: $stage"
    }
  }
}

while ($true) {
  $stage = ReadStage
  Info "CURRENT_STAGE=$stage"
  RunStage $stage
  if ($Once) { break }
  if ((ReadStage) -eq "DONE") { break }
}
Info "AUTO finished (stage=$(ReadStage))"