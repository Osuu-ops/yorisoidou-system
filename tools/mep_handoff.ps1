# PowerShellは @' '@（シングルクォートHere-String）前提
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$min  = Join-Path $here 'mep_handoff_min.ps1'
if (!(Test-Path -LiteralPath $min)) {
  Write-Error "[HANDOFF] missing: tools/mep_handoff_min.ps1"
  exit 2
}
try {
  & $min @args
  exit $LASTEXITCODE
} catch {
  Write-Error ("[HANDOFF] wrapper failed: " + $_.Exception.Message)
  exit 1
}