Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$ap = $env:MEP_APPROVE
if($ap -eq "0"){
  Write-Host "[G2][ OK ] Approved (MEP_APPROVE=0) -> continue"
# --- MEP_G2_PROGRESS_ENV_BEGIN ---
try {
  $env:MEP_AUTO_LOOP_EXIT = "0"
  $env:MEP_SRC = if ($env:MEP_SRC) { $env:MEP_SRC } else { "DRAFT" }
  $env:MEP_PRE = if ($env:MEP_PRE) { $env:MEP_PRE } else { "OK" }
  $env:MEP_PROGRESS_EXIT  = "0"
  $env:MEP_PROGRESS_LABEL = "G2/3 CONTINUE (exit=0)"
  $env:MEP_GATES    = "G0,G1,G2,G3"
  $env:MEP_GATES_OK = "G0,G1,G2"
  $reporter = Join-Path $PSScriptRoot "..\mep_reporter.ps1"
  if (Test-Path -LiteralPath $reporter) { try { & $reporter -ExitCode 0 } catch {} }
} catch {}
# --- MEP_G2_PROGRESS_ENV_END ---
exit 0
}
Write-Host "[G2][STOP] Approval required. Set env MEP_APPROVE=0 to proceed."
# --- MEP_G2_PROGRESS_ENV_BEGIN ---
try {
  $env:MEP_AUTO_LOOP_EXIT = "2"
  $env:MEP_SRC = if ($env:MEP_SRC) { $env:MEP_SRC } else { "DRAFT" }
  $env:MEP_PRE = if ($env:MEP_PRE) { $env:MEP_PRE } else { "OK" }
  $env:MEP_PROGRESS_EXIT  = "2"
  $env:MEP_PROGRESS_LABEL = "G2/3 STOP (exit=2)"
  $env:MEP_GATES    = "G0,G1,G2,G3"
  $env:MEP_GATES_OK = "G0,G1"
  $reporter = Join-Path $PSScriptRoot "..\mep_reporter.ps1"
  if (Test-Path -LiteralPath $reporter) { try { & $reporter -ExitCode 2 } catch {} }
} catch {}
# --- MEP_G2_PROGRESS_ENV_END ---
exit 2
