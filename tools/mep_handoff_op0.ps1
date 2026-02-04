# PowerShell is @' '@ safe (OP-0 wrapper)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"
function Fail($msg) { Write-Host "[FATAL] $msg" -ForegroundColor Red; exit 2 }
# repo root: tools\.. (no git invocation needed)
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $repoRoot
# base generator (prefer min)
$baseMin  = Join-Path $PSScriptRoot "mep_handoff_min.ps1"
$baseMain = Join-Path $PSScriptRoot "mep_handoff.ps1"
if (Test-Path $baseMin) { $base = $baseMin }
elseif (Test-Path $baseMain) { $base = $baseMain }
else { Fail "base handoff generator not found under tools (mep_handoff_min.ps1 / mep_handoff.ps1)" }
# --- find SOURCE_MD (latest op0_evidence_select_*.md) ---
$sourceMd = Join-Path $env:USERPROFILE "Desktop\MEP_LOGS\OP0_EVIDENCE_EXTRACT\op0_evidence_select_20260204_062145.md"
if (-not (Test-Path $sourceMd)) {
  $dir = Join-Path $env:USERPROFILE "Desktop\MEP_LOGS\OP0_EVIDENCE_EXTRACT"
  if (Test-Path $dir) {
    $latest = Get-ChildItem -Path $dir -Filter "op0_evidence_select_*.md" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latest) { $sourceMd = $latest.FullName }
  }
}
$head = $null
try { $head = (git rev-parse HEAD 2>$null).Trim() } catch { $head = "" }
if (-not (Test-Path $sourceMd)) {
  $op0Text = @"
SOURCE_MD: (not found)
EXTRACT_AT: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ssK")
HEAD(local): $head
（OP-0抜粋未生成：Desktop\MEP_LOGS\OP0_EVIDENCE_EXTRACT\op0_evidence_select_*.md が見つかりません）
"@
} else {
  $op0Text = @"
SOURCE_MD: $sourceMd
EXTRACT_AT: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ssK")
HEAD(local): $head
$(Get-Content -LiteralPath $sourceMd -Raw -Encoding UTF8)
"@
}
# base64 encode excerpt (avoid here-string edge cases)
$op0B64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($op0Text))
$op0 = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($op0B64))
$stamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
$append = @"
【OP-0 一次根拠追記（監査用：抜粋）】
APPENDED_AT: $stamp
$op0
"@
# run base generator (may use Write-Host); do not capture
& $base
# append as pipeline output tail
Write-Output "`r`n`r`n"
Write-Output $append