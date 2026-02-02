Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new($false)
$OutputEncoding=[Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"
$reporter = Join-Path $PSScriptRoot "mep_reporter.ps1"
if (-not (Test-Path -LiteralPath $reporter)) { throw "Missing reporter: $reporter" }
. $reporter
function Invoke-Child {
  param([Parameter(Mandatory)][string]$File,[string[]]$Args=@())
  $pwsh = (Get-Command pwsh -ErrorAction Stop).Source
  $argList = @("-NoProfile","-File",$File) + $Args
  $out = & $pwsh @argList 2>&1 | Out-String
  $ec  = $LASTEXITCODE
  return [pscustomobject]@{ ExitCode=[int]$ec; Output=$out.TrimEnd() }
}
function Get-RepoRoot { $r=(git rev-parse --show-toplevel 2>$null); if(-not $r){ throw "Not a git repo." }; $r.Trim() }
$root = Get-RepoRoot
Set-Location $root
$preGate = Join-Path $root "tools\pre_gate.ps1"
if (-not (Test-Path -LiteralPath $preGate)) { throw "Missing: $preGate" }
$pre = Invoke-Child -File $preGate
if ($pre.ExitCode -ne 0) {
  $reason = "PREGATE_FAIL_" + $pre.ExitCode
  $exitCode = 1
  if ($pre.Output -match "Working tree is dirty") {
    $reason = "WORKTREE_DIRTY"
    $exitCode = 1
  }
  elseif ($pre.Output -match "mep_doneB_audit\.ps1" -and $pre.Output -match "PrNumber not provided") {
    $reason = "AUDIT_NEEDS_PRNUMBER"
    $exitCode = 2
  }
  elseif ($pre.ExitCode -eq 2) {
    $reason = "PREGATE_NG"
    $exitCode = 2
  }
  Write-MepRun -Source DRAFT -PreGateResult FAIL -PreGateReason $reason -GateMax 10 -GateOkUpto 0 -GateStopAt 0 -ExitCode $exitCode -StopReason $reason -GateMatrix @{}
  exit $exitCode
}
Write-MepRun -Source DRAFT -PreGateResult OK -PreGateReason "" -GateMax 10 -GateOkUpto 0 -GateStopAt 0 -ExitCode 2 -StopReason "PREGATE_OK_NEED_NEXT" -GateMatrix @{0="STOP"}
exit 2