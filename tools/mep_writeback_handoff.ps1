[CmdletBinding()]
param(
  [Parameter()][string]$BundlePath = "docs/MEP/MEP_BUNDLE.md",
  [Parameter()][string]$OutPath    = "docs/MEP/HANDOFF_NEXT.generated.md",
  [Parameter()][string]$BeginMark  = "<!-- BEGIN: HANDOFF_NEXT (MEP) -->",
  [Parameter()][string]$EndMark    = "<!-- END: HANDOFF_NEXT (MEP) -->",
  [Parameter()][switch]$CI
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$m) { throw $m }

# generate + guard
pwsh -NoProfile -File .\tools\mep_handoff_generate.ps1 -BundlePath $BundlePath -OutPath $OutPath | Write-Output
pwsh -NoProfile -File .\tools\mep_handoff_guard.ps1 -HandoffPath $OutPath | Write-Output

# splice WITHOUT regex timeout: do simple index search
$bundle = Get-Content -LiteralPath $BundlePath -Encoding UTF8 -Raw
$handoff = Get-Content -LiteralPath $OutPath -Encoding UTF8 -Raw

$bi = $bundle.IndexOf($BeginMark)
$ei = $bundle.IndexOf($EndMark)
if ($bi -lt 0) { Fail "BEGIN marker not found in $BundlePath" }
if ($ei -lt 0) { Fail "END marker not found in $BundlePath" }
if ($ei -le $bi) { Fail "Marker order invalid in $BundlePath" }

$before = $bundle.Substring(0, $bi + $BeginMark.Length)
$after  = $bundle.Substring($ei)

$newBundle = $before + "`n" + $handoff.TrimEnd() + "`n" + $after
Set-Content -LiteralPath $BundlePath -Encoding UTF8 -Value $newBundle

# commit + PR
if (-not $CI) { git pull --ff-only origin main | Out-Null }

$ts = (Get-Date).ToUniversalTime().ToString("yyyyMMdd_HHmmss")
$br = "auto/writeback-handoff_$ts"
git checkout -b $br | Out-Null
git add $BundlePath $OutPath | Out-Null
git commit -m "chore(mep): writeback HANDOFF_NEXT to Bundled" | Out-Null
git push -u origin $br | Out-Null

$prUrl = (gh pr create --title "chore(mep): writeback HANDOFF_NEXT" --body "Automated writeback: embed HANDOFF_NEXT into MEP_BUNDLE." --base "main" --head $br)
Write-Output $prUrl
try { gh pr merge --auto --merge $prUrl | Out-Null } catch { Write-Output "[INFO] auto-merge not applied" }
