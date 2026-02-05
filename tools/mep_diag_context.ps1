param(
  [int]$PrNumber = 0
)
Set-StrictMode -Off
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GH_PAGER="cat"; $env:PAGER="cat"; $env:GIT_PAGER="cat"; $env:GH_NO_UPDATE_NOTIFIER="1"
$EXPECTED_REPO = "Osuu-ops/yorisoidou-system"
$EXPECTED_ORIGIN = "https://github.com/Osuu-ops/yorisoidou-system.git"
function W($s){ Write-Host $s }
function H($s){ Write-Host ""; Write-Host ("==== {0} ====" -f $s) }
H "BASIC"
W ("ts=" + (Get-Date).ToString("o"))
W ("pwd=" + (Get-Location).Path)
W ("ps=" + $PSVersionTable.PSVersion)
# --- mitigate PSReadLine crash (session only) ---
H "PSREADLINE"
try {
  $m = Get-Module -Name PSReadLine -ErrorAction SilentlyContinue
  W ("psreadline_loaded=" + [bool]$m)
  if ($m) {
    W ("psreadline_ver=" + $m.Version)
    try { Remove-Module PSReadLine -Force -ErrorAction SilentlyContinue; W "psreadline_unloaded=OK" } catch { W ("psreadline_unloaded=FAIL " + $_.Exception.Message) }
  }
} catch { W ("psreadline_probe_error=" + $_.Exception.Message) }
# --- repo root ---
H "GIT ROOT"
$repoRoot = $null
try { $repoRoot = (git rev-parse --show-toplevel 2>$null); if($repoRoot){$repoRoot=$repoRoot.Trim()} } catch {}
W ("repoRoot=" + ($repoRoot ? $repoRoot : "<NOT_IN_GIT_REPO>"))
if ($repoRoot) { try { Set-Location $repoRoot } catch {} }
# --- origin repair + show ---
H "GIT ORIGIN"
try {
  $r = (git remote 2>$null)
  $hasOrigin = $false
  if ($r) { if (($r | Select-String -SimpleMatch "origin")) { $hasOrigin = $true } }
  $o = (git remote get-url origin 2>$null); if($o){$o=$o.Trim()}
  W ("origin_before=" + ($o ? $o : "<EMPTY>"))
  if (-not $o -or $o -ne $EXPECTED_ORIGIN) {
    if ($hasOrigin) { git remote set-url origin $EXPECTED_ORIGIN 2>$null | Out-Null } else { git remote add origin $EXPECTED_ORIGIN 2>$null | Out-Null }
  }
  $o2 = (git remote get-url origin 2>$null); if($o2){$o2=$o2.Trim()}
  W ("origin_after=" + ($o2 ? $o2 : "<EMPTY>"))
  W ("origin_is_expected=" + [bool]($o2 -eq $EXPECTED_ORIGIN))
} catch { W ("origin_check_error=" + $_.Exception.Message) }
# --- env vars that can force repo drift ---
H "ENV (DRIFT TRIGGERS)"
$keys = @("GH_REPO","GH_HOST","GH_TOKEN","GITHUB_TOKEN","GITHUB_REPOSITORY","GITHUB_SERVER_URL","MEP_BOT_PAT","MEP_PR_TOKEN","MEP_TOKEN")
foreach ($k in $keys) {
  $v = [Environment]::GetEnvironmentVariable($k)
  if ($v) {
    if ($k -match 'TOKEN|PAT') { W ($k + "=<set:masked>") } else { W ($k + "=" + $v) }
  } else {
    W ($k + "=<unset>")
  }
}
# --- gh repo resolution (unpinned vs pinned) ---
H "GH REPO RESOLUTION"
try { W ("gh_version=" + ((gh --version 2>$null) -join " ")) } catch {}
try { (gh auth status 2>&1) | ForEach-Object { W $_ } } catch {}
$def = ""
$pin = ""
try { $def = ((gh repo view --json nameWithOwner,url 2>&1) -join "`n") } catch { $def = $_.Exception.Message }
try { $pin = ((gh repo view $EXPECTED_REPO --json nameWithOwner,url 2>&1) -join "`n") } catch { $pin = $_.Exception.Message }
W ""
W "--- gh repo view (no --repo) ---"
W $def
W "--- gh repo view (pinned expected) ---"
W $pin
# --- PR resolution test (only if requested) ---
if ($PrNumber -gt 0) {
  H ("PR RESOLUTION TEST pr=" + $PrNumber)
  $u = ""
  $p = ""
  try { $u = ((gh pr view $PrNumber --json number,url,state,headRefName,headRefOid,baseRefName 2>&1) -join "`n") } catch { $u = $_.Exception.Message }
  try { $p = ((gh pr view $PrNumber --repo $EXPECTED_REPO --json number,url,state,headRefName,headRefOid,baseRefName 2>&1) -join "`n") } catch { $p = $_.Exception.Message }
  W "--- gh pr view (no --repo) ---"
  W $u
  W "--- gh pr view (--repo pinned) ---"
  W $p
  W ("repo_drift_detected_by_pr_view_diff=" + [bool]($u -ne $p))
}
H "HOW TO USE"
W "Run (anywhere):"
W "  pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\mep_diag_context.ps1 -PrNumber 1800"
W "If PowerShell is weird, run:"
W "  .\tools\mep_diag_context.cmd 1800"
