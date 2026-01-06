# MEP_PWSH_GUARD
# Purpose: prevent running MEP operations under Windows PowerShell 5.1 (Desktop) which causes encoding/stderr/CLI edge issues.
# Behavior:
# - If already pwsh (Core) => no-op
# - If Desktop => re-exec current script in pwsh and exit with same code
param(
  [Parameter(ValueFromRemainingArguments=$true)]
  [string[]] $ArgsForward
)

$ErrorActionPreference = "Stop"

if ($PSVersionTable.PSEdition -eq "Core") { return }

$pwshExe = Join-Path $env:ProgramFiles "PowerShell\7\pwsh.exe"
if (-not (Test-Path $pwshExe)) {
  throw "MEP_PWSH_GUARD: pwsh not found at: $pwshExe"
}

if (-not $PSCommandPath) {
  throw "MEP_PWSH_GUARD: PSCommandPath is empty (cannot re-exec). Run from a script file."
}

& $pwshExe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath @ArgsForward
exit $LASTEXITCODE
