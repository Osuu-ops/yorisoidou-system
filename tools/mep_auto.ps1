Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$m){ throw $m }
function Info([string]$m){ Write-Host "[AUTO] $m" -ForegroundColor Cyan }

$root = (Get-Location).Path
if (!(Test-Path -LiteralPath (Join-Path $root ".git"))) { Fail "Not a git repo root: $root" }

$preGate = Join-Path $root "tools/pre_gate.ps1"
if (!(Test-Path -LiteralPath $preGate)) { Fail "Missing: tools/pre_gate.ps1" }

$stageTool = Join-Path $root "tools/mep_current_stage.ps1"
if (!(Test-Path -LiteralPath $stageTool)) { Fail "Missing: tools/mep_current_stage.ps1" }

# StrictMode-safe: detect -Once in $args (no param)
$onceFlag = $false
if ($args -and ($args -contains "-Once")) { $onceFlag = $true }

function ReadStage() {
  $p = Join-Path $root ".mep/CURRENT_STAGE.txt"
  if (!(Test-Path -LiteralPath $p)) { Set-Content -LiteralPath $p -Value "PRE_GATE" -Encoding UTF8 -NoNewline }
  (Get-Content -LiteralPath $p -Raw).Trim()
}

function RunPreGate() {
  Info "Run Pre-Gate: tools/pre_gate.ps1"
  & $preGate
  $code = $LASTEXITCODE
  if ($code -ne 0) { Fail "Pre-Gate failed (exit=$code)" }
}

function RunReadOnlySuite() {
  $cands = @(
    (Join-Path $root "scripts/evidence_check.ps1"),
    (Join-Path $root "tools/acceptance_tests.ps1"),
    (Join-Path $root "tools/mep_handoff_guard.ps1")
  )
  foreach ($p in $cands) {
    if (Test-Path -LiteralPath $p) {
      Info ("Run read-only: " + (Split-Path $p -Leaf))
      & $p
      $code = $LASTEXITCODE
      if ($code -ne 0) { Fail ("Read-only check failed (exit=" + $code + "): " + (Split-Path $p -Leaf)) }
    }
  }
}

function RunStage([string]$stage) {
  switch ($stage) {
    "PRE_GATE" { RunPreGate; & $stageTool advance | Out-Null; return }
    "MEP_AUTO" { RunReadOnlySuite; & $stageTool advance | Out-Null; return }
    "DONE"     { Info "CURRENT_STAGE=DONE"; return }
    default    { Fail "Unknown CURRENT_STAGE: $stage" }
  }
}

while ($true) {
  $stage = ReadStage
  Info "CURRENT_STAGE=$stage"
  RunStage $stage
  if ($onceFlag) { break }
  if ((ReadStage) -eq "DONE") { break }
}
Info "AUTO finished (stage=$(ReadStage))"