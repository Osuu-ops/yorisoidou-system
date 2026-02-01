<#
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・StrictMode耐性）
- diff取得 → Scope-IN候補生成 → 承認①（任意） → CURRENT_SCOPE.md更新 → commit/push
- 意味判断/マスタ改変はしない（候補列挙のみ）
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $ProgressPreference="SilentlyContinue"
param(
  [switch]$Once
  [switch]$ApprovalYes
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
$changedArr = $changed.ToArray() | Where-Object { $_ -and ($_ -notmatch '^\s*$') } | Sort-Object -Unique
if (-not $changedArr -or $changedArr.Count -eq 0) {
  Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty."
}
# ---- candidate (bullet-only) ----
$candidate = New-Object System.Collections.Generic.List[string]
foreach ($p in $changedArr) { $candidate.Add(("- {0}" -f $p.Replace('\','/'))) }
Write-Host ""
Write-Host "===== Scope-IN Candidate (bullet-only) ====="
if ($candidate.Count -gt 0) { $candidate | ForEach-Object { Write-Host $_ } } else { Write-Host "- (none)" }
Write-Host "==========================================="
Write-Host ""
# ---- approval① ----
if (-not $ApprovalYes) {
  $ans = Read-Host "Approval① (type YES to apply to CURRENT_SCOPE.md, otherwise abort)"
  if ($ans -ne "YES") { Fail "Approval① denied (input was not YES)." }
} else {
  Info "Approval① bypassed (-ApprovalYes)."
}
# ---- CURRENT_SCOPE.md upsert + replace Scope-IN section ----
$scopePath = Join-Path $repoRoot "CURRENT_SCOPE.md"
if (!(Test-Path $scopePath)) {
  Info "CURRENT_SCOPE.md not found. Creating new file."
  @(
    "# CURRENT_SCOPE"
    "## Scope-IN"
    "- (none)"
  ) | Set-Content -Path $scopePath -Encoding UTF8 -NoNewline
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate Scope-IN header
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*##\s*Scope-IN\s*$') { $startIdx = $i; break }
}
# find end (next "## " or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j] -match '^\s*##\s+') { $endIdx = $j; break }
  }
}
$new = New-Object System.Collections.Generic.List[string]
function Add-NonEmpty([System.Collections.Generic.List[string]]$list, [string]$s) { if ($null -ne $s -and $s -ne "") { $list.Add($s) } }
if ($startIdx -lt 0) {
  foreach($ln in $lines){ Add-NonEmpty $new $ln }
  Add-NonEmpty $new "## Scope-IN"
  if ($candidate.Count -gt 0) { foreach($c in $candidate){ Add-NonEmpty $new $c } } else { Add-NonEmpty $new "- (none)" }
} else {
  for ($k=0; $k -le $startIdx; $k++) { Add-NonEmpty $new $lines[$k] }
  if ($candidate.Count -gt 0) { foreach($c in $candidate){ Add-NonEmpty $new $c } } else { Add-NonEmpty $new "- (none)" }
  for ($k=$endIdx; $k -lt $lines.Count; $k++) { Add-NonEmpty $new $lines[$k] }
}
# enforce bullet-only inside Scope-IN
$enforce = New-Object System.Collections.Generic.List[string]
$inScope = $false
foreach ($ln in $new) {
  if ($ln -match '^\s*##\s*Scope-IN\s*$') { $inScope = $true; $enforce.Add($ln); continue }
  if ($ln -match '^\s*##\s+' -and $ln -notmatch '^\s*##\s*Scope-IN\s*$') { $inScope = $false; $enforce.Add($ln); continue }
  if ($inScope) { if ($ln -notmatch '^\s*-\s+') { Fail "Non-bullet line detected under Scope-IN: $ln" } }
  $enforce.Add($ln)
}
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8 -NoNewline
Info "Updated CURRENT_SCOPE.md (blank-lines removed; bullet-only enforced)."
# ---- git commit/push ----
$branch = (git branch --show-current).Trim()
if (-not $branch) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
git add (Join-Path $repoRoot "tools/mep_unified_entry.ps1") | Out-Null
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(mep): unified operation entry step1 ($ts)"
try { git commit -m $commitMsg | Out-Null } catch { Fail "git commit failed. (Maybe nothing to commit?)" }
Info "Committed: $commitMsg"
try { git push -u origin $branch | Out-Null } catch { Warn "git push failed (check auth/remote)." }
Info "Pushed: $branch"
Info "Unified entry step1 done."