<#
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化
- diff取得 → Scope-IN候補生成 → 承認① → CURRENT_SCOPE.md更新 → commit/push →（任意）Gate/CI/writeback起動
- マスタ内容変更・意味判断はしない（候補提示＋Yes/Noのみ）
- blank-lines: 最終出力は空行ゼロ（ただしファイル内のコメント等の空行は許容）
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
  [int]$WritebackPrNumber = 0,
  [switch]$ApprovalYes = $false  # 付けた場合は承認①プロンプトを省略（YES扱い）
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
$changed = @()
$diffRaw = (git diff --name-status "$baseRef...HEAD" 2>$null)
foreach ($line in $diffRaw) {
  if (-not $line) { continue }
  $parts = $line -split "`t"
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

# ---- bullet-only candidate ----
$candidate = @()
foreach ($p in $changed) { $candidate += ("- {0}" -f $p.Replace('\','/')) }

Write-Host ""
Write-Host "===== Scope-IN Candidate (bullet-only) ====="
if ($candidate.Count -gt 0) { $candidate | ForEach-Object { Write-Host $_ } } else { Write-Host "- (none)" }
Write-Host "==========================================="
Write-Host ""

# ---- approval① ----
if (-not [bool]$ApprovalYes) {
  $ans = Read-Host "Approval① (type YES to apply to CURRENT_SCOPE.md, otherwise abort)"
  if ($ans -ne "YES") { Fail "Approval① denied (input was not YES)." }
} else {
  Info "Approval① bypassed (-ApprovalYes)."
}

# ---- CURRENT_SCOPE.md upsert ----
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

# find "## Scope-IN"
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*##\s*Scope-IN\s*$') { $startIdx = $i; break }
}

function Add-CandidateLines([System.Collections.Generic.List[string]]$list, [string[]]$cand){
  if ($cand -and $cand.Count -gt 0) { foreach($c in $cand){ $list.Add($c) } }
  else { $list.Add("- (none)") }
}

if ($startIdx -lt 0) {
  $new = New-Object System.Collections.Generic.List[string]
  foreach($ln in $lines){ if ($ln -ne "") { $new.Add($ln) } }
  $new.Add("## Scope-IN")
  Add-CandidateLines -list $new -cand $candidate
  $out = $new.ToArray()
} else {
  $endIdx = $lines.Count
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j] -match '^\s*##\s+') { $endIdx = $j; break }
  }

  $new = New-Object System.Collections.Generic.List[string]
  for ($k=0; $k -le $startIdx; $k++) { if ($lines[$k] -ne "") { $new.Add($lines[$k]) } }
  Add-CandidateLines -list $new -cand $candidate
  for ($k=$endIdx; $k -lt $lines.Count; $k++) { if ($lines[$k] -ne "") { $new.Add($lines[$k]) } }
  $out = $new.ToArray()
}

# enforce: Scope-IN section must be bullet-only
$enforce = New-Object System.Collections.Generic.List[string]
$inScope = $false
foreach ($ln in $out) {
  if ($ln -match '^\s*##\s*Scope-IN\s*$') { $inScope = $true; $enforce.Add($ln); continue }
  if ($ln -match '^\s*##\s+' -and $ln -notmatch '^\s*##\s*Scope-IN\s*$') { $inScope = $false; $enforce.Add($ln); continue }
  if ($inScope) {
    if ($ln -notmatch '^\s*-\s+') { Fail "Non-bullet line detected under Scope-IN: $ln" }
  }
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
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1

  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found in known candidates. Skipping writeback."
  } else {
    $wfPathRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Triggering workflow_dispatch: $wfPathRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfPathRel -f pr_number=$WritebackPrNumber | Out-Null }
    catch { Warn "gh workflow run failed. Check gh auth / permissions / workflow name." }
  }
}

Info "Unified entry step1 done."