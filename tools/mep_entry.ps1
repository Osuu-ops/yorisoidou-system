<#
MEP Entry (入口)
- Pre-Gate を先に通す
- その後、既存の MEP 実行スクリプトがあれば自動検出して実行する
規約:
- Pre-Gate NG: exit 2
- Pre-Gate OK + MEP runner OK: exit 0
- Tooling error: exit 1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Boom([string]$m){ Write-Error $m; exit 1 }
function Info([string]$m){ Write-Host "[ENTRY] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  $pregate = Join-Path $root "tools/mep_pregate.ps1"
  if (!(Test-Path $pregate)) { Boom "Missing: tools/mep_pregate.ps1" }

  Info "Running Pre-Gate..."
  & $pregate
  $pg = $LASTEXITCODE
  if ($pg -ne 0) { exit $pg }

  $toolsDir = Join-Path $root "tools"
  $runner = $null
  $preferred = @((Join-Path $toolsDir "mep_autopilot.ps1"), (Join-Path $toolsDir "mep_gate.ps1"))
  foreach ($p in $preferred) { if (Test-Path $p) { $runner = $p; break } }

  if (-not $runner -and (Test-Path $toolsDir)) {
    $cands = Get-ChildItem -Path $toolsDir -File -Filter "*.ps1" |
      Where-Object { $_.Name -match "mep_(gate|runner|autopilot)" -and $_.Name -notmatch "entry|pregate" } |
      Sort-Object Name
    if ($cands.Count -gt 0) { $runner = $cands[0].FullName }
  }

  if ($runner) {
    Info ("Running MEP runner: " + (Split-Path $runner -Leaf))
    & $runner
    exit $LASTEXITCODE
  } else {
    Info "No MEP runner found. Pre-Gate OK only."
    exit 0
  }
}
catch {
  Boom $_.Exception.Message
}