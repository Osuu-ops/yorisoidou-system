<#
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・StrictMode耐性）
- diff取得 → Scope-IN候補生成 → 承認①（任意） → ScopeFile（CURRENT_SCOPE）更新
- 意味判断/マスタ改変はしない（候補列挙のみ）
#>
param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$BaseRef = "origin/main"
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $ProgressPreference="SilentlyContinue"
function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail([string]$m){ throw $m }
try { $repoRoot = (git rev-parse --show-toplevel 2>$null).Trim() } catch { Fail "Not a git repository." }
if (-not $repoRoot) { Fail "repoRoot is empty." }
Set-Location $repoRoot
Info "repoRoot=$repoRoot"
# baseRef verify/fallback
$baseRef = $BaseRef
try { git rev-parse --verify $baseRef *> $null } catch { $baseRef = "main" }
Info "baseRef=$baseRef"
# Scope file absolute path
$scopePath = Join-Path $repoRoot $ScopeFile
# changed files (rename included)
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
# ALWAYS array
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if ($changedArr.Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
# candidate bullets
$candidate = New-Object System.Collections.Generic.List[string]
foreach ($p in $changedArr) { $candidate.Add(("- {0}" -f $p)) }
Write-Host ""
Write-Host "===== Scope-IN Candidate (bullet-only) ====="
if ($candidate.Count -gt 0) { $candidate | ForEach-Object { Write-Host $_ } } else { Write-Host "- (none)" }
Write-Host "==========================================="
Write-Host ""
# approval①
if (-not $ApprovalYes) {
  $ans = Read-Host "Approval① (type YES to apply to ScopeFile, otherwise abort)"
  if ($ans -ne "YES") { Fail "Approval① denied (input was not YES)." }
} else {
  Info "Approval① bypassed (-ApprovalYes)."
}
# ensure scope dir
$scopeDir = Split-Path $scopePath -Parent
if (!(Test-Path $scopeDir)) { New-Item -ItemType Directory -Path $scopeDir -Force | Out-Null }
# create scope file if missing (minimal scaffold)
if (!(Test-Path $scopePath)) {
  Info "ScopeFile not found. Creating: $scopePath"
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    "## 変更対象（Scope-IN）"
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8 -NoNewline
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# find "## 変更対象（Scope-IN）"
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*##\s*変更対象（Scope-IN）\s*$') { $startIdx = $i; break }
}
# end at next "## " or EOF
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j] -match '^\s*##\s+') { $endIdx = $j; break }
  }
}
function Add-NonEmpty([System.Collections.Generic.List[string]]$list, [string]$s) {
  if ($null -ne $s -and $s -ne "") { $list.Add($s) }
}
$new = New-Object System.Collections.Generic.List[string]
if ($startIdx -lt 0) {
  foreach($ln in $lines){ Add-NonEmpty $new $ln }
  Add-NonEmpty $new "## 変更対象（Scope-IN）"
  if ($candidate.Count -gt 0) { foreach($c in $candidate){ Add-NonEmpty $new $c } } else { Add-NonEmpty $new "- (none)" }
} else {
  for ($k=0; $k -le $startIdx; $k++) { Add-NonEmpty $new $lines[$k] }
  if ($candidate.Count -gt 0) { foreach($c in $candidate){ Add-NonEmpty $new $c } } else { Add-NonEmpty $new "- (none)" }
  for ($k=$endIdx; $k -lt $lines.Count; $k++) { Add-NonEmpty $new $lines[$k] }
}
# enforce: Scope-IN bullets only, and remove blank lines
$enforce = New-Object System.Collections.Generic.List[string]
$inScope = $false
foreach ($ln in $new) {
  if ($ln -match '^\s*##\s*変更対象（Scope-IN）\s*$') { $inScope = $true; $enforce.Add($ln); continue }
  if ($ln -match '^\s*##\s+' -and $ln -notmatch '^\s*##\s*変更対象（Scope-IN）\s*$') { $inScope = $false; $enforce.Add($ln); continue }
  if ($inScope) { if ($ln -notmatch '^\s*-\s+') { Fail "Non-bullet line detected under Scope-IN: $ln" } }
  $enforce.Add($ln)
}
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8 -NoNewline
Info "Updated ScopeFile: $scopePath"