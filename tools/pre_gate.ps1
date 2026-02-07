# MEP Pre-Gate (入口の手前)
# exit 0: OK
# exit 1: FAIL (hard)
# exit 2: NG (approval/inputs mismatch)
# NOTE: Child scripts are executed via "powershell -File" to preserve "param()" semantics.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }
function Warn([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Yellow }
function Fail([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Red }
function Invoke-ChildFile {
  param(
    [Parameter(Mandatory)][string]$File,
    [string[]]$Args = @()
  )
  if (-not (Test-Path -LiteralPath $File)) { throw "Missing child file: $File" }
  $exe = (Get-Command powershell).Source
  $argList = @('-NoProfile','-ExecutionPolicy','Bypass','-File', $File) + $Args
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $exe
  $psi.Arguments = ($argList | ForEach-Object {
    # simple quoting
    if ($_ -match '\s|"') { '"' + ($_ -replace '"','\"') + '"' } else { $_ }
  }) -join ' '
  $psi.WorkingDirectory = (Split-Path -Parent $File)
  $psi.UseShellExecute = $false
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.CreateNoWindow = $true
  $p = New-Object System.Diagnostics.Process
  $p.StartInfo = $psi
  [void]$p.Start()
  $stdout = $p.StandardOutput.ReadToEnd()
  $stderr = $p.StandardError.ReadToEnd()
  $p.WaitForExit()
  if ($stdout -and $stdout.Trim().Length -gt 0) { $stdout.TrimEnd() | Out-Host }
  if ($stderr -and $stderr.Trim().Length -gt 0) { $stderr.TrimEnd() | Out-Host }
  return [pscustomobject]@{ ExitCode = $p.ExitCode; Stdout=$stdout; Stderr=$stderr }
}
# --- probe / root ---
$root = (git rev-parse --show-toplevel).Trim()
if (-not $root) { throw "rev-parse failed." }
$tools = Join-Path $root 'tools'
$bundled = Join-Path $root 'docs/MEP/MEP_BUNDLE.md'
Info "[PROBE] PSScriptRoot=$PSScriptRoot"
Info "[PROBE] root=$root"
Info "[PROBE] bundled=$bundled"
Info ("[PROBE] bundled_exists=" + (Test-Path -LiteralPath $bundled))
# Bundled must exist (as your current pregate expects)
if (-not (Test-Path -LiteralPath $bundled)) {
  Fail "Bundled missing -> FAIL(1)"
  exit 1
}
# Find read-only audit candidates (same intent as existing pregate)
$audits = Get-ChildItem -Path $tools -File -Filter *.ps1 |
  Where-Object { $_.Name -match 'mep_.*(audit|readonly)' -and $_.Name -notmatch 'entry|pregate' } |
  Sort-Object FullName
if (-not $audits -or @($audits).Count -eq 0) {
  Fail "No read-only audit candidates found -> FAIL(1)"
  exit 1
}
Info "Found read-only audit candidates:"
$audits | ForEach-Object { "  - $($_.FullName)" } | Out-Host
# Run audits sequentially (hard stop on nonzero)
foreach ($a in $audits) {
  Info ("Running: " + $a.Name)
  $r = Invoke-ChildFile -File $a.FullName
  if ($r.ExitCode -eq 0) { continue }
  if ($r.ExitCode -eq 2) {
    Warn ("Audit returned NG(2): " + $a.Name)
    exit 2
  }
  Fail ("Audit returned FAIL({0}): {1}" -f $r.ExitCode, $a.Name)
  exit 1
}
Info "OK (pregate passed)"
exit 0
