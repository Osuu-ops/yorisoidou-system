<#
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 Scope-IN 更新（ガード準拠）
- diff取得 → Scope-IN候補生成 → 承認①（任意） → SCOPE_FILE更新 → commit/push
- 重要: ガードが読む SCOPE_FILE / 見出し形式に合わせる（ここでは生成・改変はしない）
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $ProgressPreference="SilentlyContinue"
param(
  [switch]$Once,
  [switch]$ApprovalYes,
  # ガード準拠の既定（workflowログ根拠）
  [string]$ScopeFile = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  # ガード準拠（厳密一致）
  [string]$ScopeHeader = "## 変更対象（Scope-IN）"
)
function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail([string]$m){ throw $m }
try { $repoRoot = (git rev-parse --show-toplevel 2>$null).Trim() } catch { Fail "Not a git repository." }
if (-not $repoRoot) { Fail "repoRoot is empty." }
Set-Location $repoRoot
Info "repoRoot=$repoRoot"
# ---- base ref ----
$baseRef = "origin/main"
try { git rev-parse --verify $baseRef *> $null } catch { $baseRef = "main" }
Info "baseRef=$baseRef"
# ---- changed files (rename included) ----
$changed = New-Object System.Collections.Generic.List[string]
$diffRaw = (git diff --name-status "$baseRef...HEAD" 2>$null)
foreach ($line in $diffRaw) {
  if (-not $line) { continue }
  $parts = $line -split "`t"
  if ($parts.Count -ge 2) {
    $status = $parts[0]
    if ($status -like "R*") {
      if ($parts.Count -ge 3) { $changed.Add($parts[2]) }
    } else {
      $changed.Add($parts[1])
    }
  }
}
$changedArr = @($changed.ToArray() | Where-Object { $_ -and ($_ -notmatch '^\s*$') } | ForEach-Object { $_.Replace('\','/') } | Sort-Object -Unique)
if (-not $changedArr -or @($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
# ---- candidate (bullet-only) ----
$candidate = New-Object System.Collections.Generic.List[string]
foreach ($p in $changedArr) { $candidate.Add(("- {0}" -f $p)) }
Write-Host ""
Write-Host "===== Scope-IN Candidate (bullet-only) ====="
if ($candidate.Count -gt 0) { $candidate | ForEach-Object { Write-Host $_ } } else { Write-Host "- (none)" }
Write-Host "==========================================="
Write-Host ""
# ---- approval① ----
if (-not $ApprovalYes) {
  $ans = Read-Host "Approval① (type YES to apply to SCOPE_FILE, otherwise abort)"
  if ($ans -ne "YES") { Fail "Approval① denied (input was not YES)." }
} else {
  Info "Approval① bypassed (-ApprovalYes)."
}
# ---- SCOPE_FILE upsert + replace Scope-IN section ----
$scopePath = Join-Path $repoRoot $ScopeFile
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating new file."
  @(
    "# CURRENT_SCOPE"
    $ScopeHeader
    "- (none)"
  ) | Set-Content -Path $scopePath -Encoding UTF8 -NoNewline
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next "## " or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ")) { $endIdx = $j; break }
  }
}
function Add-NonEmpty([System.Collections.Generic.List[string]]$list, [string]$s) {
  if ($null -ne $s -and $s -ne "") { $list.Add($s) }
}
$new = New-Object System.Collections.Generic.List[string]
if ($startIdx -lt 0) {
  foreach($ln in $lines){ Add-NonEmpty $new $ln }
  Add-NonEmpty $new $ScopeHeader
  if ($candidate.Count -gt 0) { foreach($c in $candidate){ Add-NonEmpty $new $c } } else { Add-NonEmpty $new "- (none)" }
} else {
  for ($k=0; $k -le $startIdx; $k++) { Add-NonEmpty $new $lines[$k] }
  if ($candidate.Count -gt 0) { foreach($c in $candidate){ Add-NonEmpty $new $c } } else { Add-NonEmpty $new "- (none)" }
  for ($k=$endIdx; $k -lt $lines.Count; $k++) { Add-NonEmpty $new $lines[$k] }
}
# enforce bullet-only inside Scope-IN block + remove blank lines
$enforce = New-Object System.Collections.Generic.List[string]
$inScope = $false
foreach ($ln in $new) {
  if ($ln.Trim() -eq $ScopeHeader) { $inScope = $true; $enforce.Add($ln); continue }
  if ($ln.StartsWith("## ") -and $ln.Trim() -ne $ScopeHeader) { $inScope = $false; $enforce.Add($ln); continue }
  if ($inScope) {
    if ($ln -notmatch '^\s*-\s+') { Fail "Non-bullet line detected under Scope-IN: $ln" }
  }
  if ($ln -ne "") { $enforce.Add($ln) }
}
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8 -NoNewline
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- git commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(mep): unified entry scope-in update ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
Info "Unified entry run done."
