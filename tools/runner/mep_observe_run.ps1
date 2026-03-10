param(
  [Parameter(Mandatory=$true)][long]$RunId,
  [string]$Repo = $env:GH_REPO,
  [switch]$Watch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$target = Join-Path (Split-Path -Parent $PSScriptRoot) 'mep.ps1'
if (-not (Test-Path $target)) {
  throw "missing canonical entry: $target"
}

$pwshExe = Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'
if (-not (Test-Path $pwshExe)) {
  throw "pwsh not found: $pwshExe"
}

Write-Host "[DEPRECATED] tools/runner/mep_observe_run.ps1 -> tools/mep.ps1 run-status"
$invokeArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $target, 'run-status', '-RunId', "$RunId")
if ($Repo) { $invokeArgs += @('-Repo', $Repo) }
if ($Watch) { $invokeArgs += '-Watch' }
& $pwshExe @invokeArgs
exit $LASTEXITCODE
