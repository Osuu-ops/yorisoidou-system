[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [string]$OutDir = ".\.mep-selftest",

  [Parameter(Mandatory=$false)]
  [string]$LedgerPath = "",

  [Parameter(Mandatory=$false)]
  [switch]$SecondPass
)

if (-not $PSCommandPath) {
  Write-Error "This script must be executed as a .ps1 file. Do not paste into an interactive shell."
  exit 1
}

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function New-Dir([string]$p) {
  if (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

function Write-Log([string]$path, [string]$msg) {
  $ts = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffK")
  Add-Content -LiteralPath $path -Value "[$ts] $msg"
}

function Run-TestId([string]$testId, [string]$logPath) {
  Write-Log $logPath "START testId=$testId ledger=$LedgerPath"

  if ($testId -eq "UF01") {
    & python -m tools.mep_integration_compiler.runtime.tests.b4_csv_e2e 2>&1 | Tee-Object -FilePath $logPath -Append
  }
  elseif ($testId -eq "UF06") {
    & python -m tools.mep_integration_compiler.runtime.tests.b7_adapter_e2e 2>&1 | Tee-Object -FilePath $logPath -Append
  }
  else {
    Write-Log $logPath "SKIP no dedicated runner for testId=$testId (covered by e2e)"
  }

  Write-Log $logPath "END   testId=$testId"
}

New-Dir $OutDir
$runId = (Get-Date).ToString("yyyyMMdd_HHmmss")
$suffix = $(if ($SecondPass) { "_second" } else { "" })
$logPath = Join-Path $OutDir ("runtime-selftest_{0}{1}.log" -f $runId, $suffix)

Write-Log $logPath "RUN_BEGIN outDir=$OutDir secondPass=$SecondPass"

if ($LedgerPath -ne "") {
  if (-not (Test-Path -LiteralPath $LedgerPath)) { throw "LedgerPath not found: $LedgerPath" }
  Write-Log $logPath "LedgerPath=$LedgerPath"
} else {
  Write-Log $logPath "LedgerPath=NOT_SET"
}

$testIds = @("UF01","UF06","UF07","UF08","WORK_DONE","RESYNC")
foreach ($id in $testIds) { Run-TestId -testId $id -logPath $logPath }

Write-Log $logPath "RUN_END"
Write-Host ("Log: {0}" -f $logPath)

if (-not $SecondPass) {
  Write-Host "Tip: run a second pass to check idempotency:"
  Write-Host ("  pwsh {0} -OutDir {1} -LedgerPath {2} -SecondPass" -f $PSCommandPath, $OutDir, $(if ($LedgerPath -ne "") { $LedgerPath } else { "<ledger>" }))
}

