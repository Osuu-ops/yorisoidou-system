<#
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化
- diff取得 → Scope-IN候補生成 → 承認① → CURRENT_SCOPE.md更新 → commit/push →（任意）Gate/CI/writeback起動
- マスタ内容変更・意味判断はしない（候補提示＋Yes/Noのみ）
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $ProgressPreference="SilentlyContinue"

param(
  [switch]$Once,
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0
)

function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail([string]$m){ throw $m }

try { $repoRoot = (git rev-parse --show-toplevel 2>$null).Trim() } catch { Fail "Not a git repository." }
if (-not $repoRoot) { Fail "repoRoot is empty." }
Set-Location $repoRoot
Info "repoRoot=$repoRoot"

# ---- diff -> candidate ----
# 基準は origin/main（存在しなければ main）に寄せる
$baseRef = "origin/main"
try { git rev-parse --verify $baseRef *> $null } catch { $baseRef = "main" }
Info "baseRef=$baseRef"

# 変更ファイル抽出（renameも含める）
$changed = @()
$diffRaw = (git diff --name-status "$baseRef...HEAD" 2>$null)
foreach ($line in $diffRaw) {
  if (-not $line) { continue }
  $parts = $line -split "`t"
  # name-status: M\tpath / A\tpath / D\tpath / R100\told\tnew
  if ($parts.Count -ge 2) {
    $status = $parts[0]
    if ($status -like "R*") {
      if ($parts.Count -ge 3) { $changed += $parts[2] }
    } else {
      $changed += $parts[1]
    }
  }
}
$changed = $changed | Where-Object { $_ -and ($_ -notmatch '^\s*$') } | Sort-Object -Unique
if (-not $changed -or $changed.Count -eq 0) {
  Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty."
}

# bullet-only / 空行ゼロ
$candidate = @()
foreach ($p in $changed) {
  $candidate += ("- {0}" -f $p.Replace('\','/'))
}

# ---- approval(承認①) ----
Write-Host ""
Write-Host "===== Scope-IN Candidate (bullet-only) ====="
if ($candidate.Count -gt 0) { $candidate | ForEach-Object { Write-Host $_ } } else { Write-Host "- (none)" }
Write-Host "==========================================="
Write-Host ""
$ans = Read-Host "Approval① (type YES to apply to CURRENT_SCOPE.md, otherwise abort)"
if ($ans -ne "YES") { Fail "Approval① denied (input was not YES)." }

# ---- CURRENT_SCOPE.md update (create if missing) ----
$scopePath = Join-Path $repoRoot "CURRENT_SCOPE.md"
if (!(Test-Path $scopePath)) {
  Info "CURRENT_SCOPE.md not found. Creating new file."
  @(
    "# CURRENT_SCOPE"
    ""
    "## Scope-IN"
    "- (none)"
  ) | Set-Content -Path $scopePath -Encoding UTF8 -NoNewline
}

$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }

# Section replace: "## Scope-IN" 〜 次の "## " 直前まで
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*##\s*Scope-IN\s*$') { $startIdx = $i; break }
}
if ($startIdx -lt 0) {
  # append new section
  $new = @()
  $new += $lines
  if ($new.Count -gt 0 -and $new[-1] -ne "") { $new += "" }
  $new += "## Scope-IN"
  $new += ($candidate.Count -gt 0  $candidate : @("- (none)"))
  $out = $new
} else {
  $endIdx = $lines.Count
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j] -match '^\s*##\s+') { $endIdx = $j; break }
  }
  $head = @()
  if ($startIdx -gt 0) { $head = $lines[0..($startIdx)] } else { $head = @($lines[0]) }
  $tail = @()
  if ($endIdx -lt $lines.Count) { $tail = $lines[$endIdx..($lines.Count-1)] }

  $out = @()
  $out += $head
  $out += ($candidate.Count -gt 0  $candidate : @("- (none)"))
  if ($tail.Count -gt 0) { $out += $tail }
}

# 空行ゼロ（完全除去）
$out = $out | Where-Object { $_ -ne "" }

# bullet-only enforce（Scope-IN配下はすべて "- " 始まり）
$enforce = @()
$inScope = $false
foreach ($ln in $out) {
  if ($ln -match '^\s*##\s*Scope-IN\s*$') { $inScope = $true; $enforce += $ln; continue }
  if ($ln -match '^\s*##\s+' -and $ln -notmatch '^\s*##\s*Scope-IN\s*$') { $inScope = $false; $enforce += $ln; continue }
  if ($inScope) {
    if ($ln -notmatch '^\s*-\s+') { Fail "Non-bullet line detected under Scope-IN: $ln" }
  }
  $enforce += $ln
}

$enforce | Set-Content -Path $scopePath -Encoding UTF8 -NoNewline
Info "Updated CURRENT_SCOPE.md (blank-lines removed; bullet-only enforced)."

# ---- git commit/push ----
$branch = (git branch --show-current).Trim()
if (-not $branch) { Fail "Current branch name is empty." }

git add $scopePath | Out-Null
git add (Join-Path $repoRoot "tools/mep_unified_entry.ps1") 2>$null | Out-Null

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(mep): unified operation entry (step1) $ts"
try { git commit -m $commitMsg | Out-Null } catch { Fail "git commit failed. (Maybe nothing to commit)" }
Info "Committed: $commitMsg"

try { git push -u origin $branch | Out-Null } catch { Warn "git push failed (check auth/remote). Continuing." }

# ---- optional: run gate / writeback (best-effort) ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) {
    Info "Running tools/mep_entry.ps1 -Once"
    & $gate -Once
  } else {
    Warn "tools/mep_entry.ps1 not found. Skipping gate."
  }
}

if ($RunWriteback) {
  # workflow name candidates (repo側の実名に依存するため、存在チェックしてから実行)
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1

  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found in known candidates. Skipping writeback."
  } else {
    $wfPathRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Triggering workflow_dispatch: $wfPathRel (pr_number=$WritebackPrNumber)"
    try {
      gh workflow run $wfPathRel -f pr_number=$WritebackPrNumber | Out-Null
    } catch {
      Warn "gh workflow run failed. Check gh auth / permissions / workflow name."
    }
  }
}

Info "Unified entry step1 done (file created + CURRENT_SCOPE updated + commit/push attempted)."