# PowerShell is @' '@ safe
Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
$OutputEncoding=[Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"
function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok([string]$m){ Write-Host "[ OK ] $m" -ForegroundColor Green }
function Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
# B-LOOP-STOP-CONTRACT:
# - ENTRY_EXIT=0 => end
# - ENTRY_EXIT=1 => stop (retry prohibited)
# - ENTRY_EXIT=2 => stop (approval wait)
$repoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
if(-not $repoRoot){ throw "Not inside git repo." }
$entry = Join-Path $repoRoot "tools\mep_entry.ps1"
if(-not (Test-Path $entry)){ throw "Missing entry: $entry" }
Info "Run Entry Orchestrator (mep_entry.ps1)"
& $entry
$ec = $LASTEXITCODE
if($ec -eq $null){ $ec = 2 }
if($ec -eq 0){
  Ok "ENTRY_EXIT=0 -> END"
  exit 0
}
if($ec -eq 1){
  Warn "ENTRY_EXIT=1 -> STOP (retry prohibited)"
  exit 1
}
Warn "ENTRY_EXIT=2 -> STOP (approval wait)"
exit 2

# --- approval hook (MEP_APPROVE=0) ---
# If ENTRY_EXIT=2 and user provided MEP_APPROVE=0, rerun entry once.
if($ec -eq 2 -and $env:MEP_APPROVE -eq "0"){
  Info "MEP_APPROVE=0 detected -> rerun entry once"
  & $entry
  $ec2 = $LASTEXITCODE
  if($ec2 -eq $null){ $ec2 = 2 }
  if($ec2 -eq 0){ Ok "ENTRY_EXIT=0 -> END"; exit 0 }
  if($ec2 -eq 1){ Warn "ENTRY_EXIT=1 -> STOP (retry prohibited)"; exit 1 }
  Warn "ENTRY_EXIT=2 -> STOP (approval wait)"; exit 2
}
