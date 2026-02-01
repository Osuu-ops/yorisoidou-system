
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
# - （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
# - Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_SCOPEIN_HEADER_SHIM_V1 ###
$__p = 0
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__p) | Out-Null
  }
} catch {}
if ($__p -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') { [int]::TryParse($Matches[1], [ref]$__p) | Out-Null }
  } catch {}
}
if ($__p -gt 0) {
  Write-Host "## Scope-IN candidates"
}
### DONEB_SCOPEIN_HEADER_SHIM_V1 ###


### DONEB_PRNUMBER_SHIM_V9 ###
$__DoneB_PrNumber = 0
try { if ($PSBoundParameters.ContainsKey('PrNumber')) { [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null } } catch {}
if ($__DoneB_PrNumber -le 0) { try { $line = [string]$MyInvocation.Line; if ($line -match '(i)\-PrNumber\s+(\d+)') { [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null } } catch {} }
if ($__DoneB_PrNumber -le 0) { for ($i = 0; $i -lt $args.Count; $i++) { if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) { [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null; break } } }
if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) { $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and ($_.Length -gt 0) } | Sort-Object -Unique) }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V9 ###


### DONEB_PRNUMBER_SHIM_V3 ###
$__DoneB_PrNumber = 0
try { if ($PSBoundParameters.ContainsKey('PrNumber')) { [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null } } catch {}
if ($__DoneB_PrNumber -le 0) { try { $line = [string]$MyInvocation.Line; if ($line -match '(i)\-PrNumber\s+(\d+)') { [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null } } catch {} }
if ($__DoneB_PrNumber -le 0) { for ($i = 0; $i -lt $args.Count; $i++) { if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) { [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null; break } } }
if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and ($_.Length -gt 0) } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V3 ###


### DONEB_PRNUMBER_SHIM_V3 ###
$__DoneB_PrNumber = 0
try { if ($PSBoundParameters.ContainsKey('PrNumber')) { [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null } } catch {}
if ($__DoneB_PrNumber -le 0) { try { $line = [string]$MyInvocation.Line; if ($line -match '(i)\-PrNumber\s+(\d+)') { [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null } } catch {} }
if ($__DoneB_PrNumber -le 0) { for ($i = 0; $i -lt $args.Count; $i++) { if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) { [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null; break } } }
if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and ($_.Length -gt 0) } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V3 ###


### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Placed after param(). Keep syntax ultra-simple to avoid parser issues.


MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and $_ .Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done."_DoneB_PrNumber = 0

# 1) bound param
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and $_ .Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done."_DoneB_PrNumber) | Out-Null
  }
} catch {}

# 2) invocation line
if (
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and $_ .Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done."_DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and $_ .Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done."_DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# 3) args scan
if (
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and $_ .Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done."_DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and $_ .Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done."_DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if (
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and $_ .Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done."_DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and $_ .Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done."_DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and $_ .Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done."_DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json

    $files = @()
    if ($obj -and $obj.files) {
      $files = @(
        $obj.files |
          ForEach-Object { 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and $_ .Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".path } |
          Where-Object { 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and $_ .Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done." -and (
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and $_ .Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Length -gt 0) } |
          Sort-Object -Unique
      )
    }

    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and 
MEP 運転完成フェーズ（Unified Operation Entry） - STEP1 入口一本化（最小・確定版）
# - diff取得 → Scope-IN候補生成 → 承認①（YES/NO） → SCOPE_FILE更新 → commit/push
- （任意）Gate / writeback を呼ぶのはオプション（意味判断はしない）
- Scope Guard が読む SCOPE_FILE と見出し（## 変更対象（Scope-IN））に厳密準拠

param(
  [switch]$Once,
  [switch]$ApprovalYes,
  [string]$ScopeFile   = "platform/MEP/90_CHANGES/CURRENT_SCOPE.md",
  [string]$ScopeHeader = "## 変更対象（Scope-IN）",
  [string]$BaseRef     = "origin/main",
  [switch]$RunGate,
  [switch]$RunWriteback,
  [int]$WritebackPrNumber = 0,
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0
)

### DONEB_PRNUMBER_SHIM_V2 ###
# DoneB②③: -PrNumber non-interactive route (Scope-IN candidates; bullet-only)
# Must be placed AFTER param() and BEFORE any other executable code.
$__DoneB_PrNumber = 0

# prefer bound param if present
try {
  if ($PSBoundParameters.ContainsKey('PrNumber')) {
    [int]::TryParse([string]$PSBoundParameters['PrNumber'], [ref]$__DoneB_PrNumber) | Out-Null
  }
} catch {}

# fallback: parse invocation line
if ($__DoneB_PrNumber -le 0) {
  try {
    $line = [string]$MyInvocation.Line
    if ($line -match '(i)\-PrNumber\s+(\d+)') {
      [int]::TryParse($Matches[1], [ref]$__DoneB_PrNumber) | Out-Null
    }
  } catch {}
}

# final fallback: args scan
if ($__DoneB_PrNumber -le 0) {
  for ($i = 0; $i -lt $args.Count; $i++) {
    if ([string]$args[$i] -ieq '-PrNumber' -and ($i + 1) -lt $args.Count) {
      [int]::TryParse([string]$args[$i+1], [ref]$__DoneB_PrNumber) | Out-Null
      break
    }
  }
}

if ($__DoneB_PrNumber -gt 0) {
  try {
    $filesJson = (gh pr view $__DoneB_PrNumber --repo Osuu-ops/yorisoidou-system --json files 2>$null)
    if (-not $filesJson) { throw "gh pr view failed for PR #$__DoneB_PrNumber" }
    $obj = $filesJson | ConvertFrom-Json
    $files = @()
    if ($obj -and $obj.files) {
      $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and $_ .Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Trim() } | Sort-Object -Unique)
    }
    Write-Host "## Scope-IN candidates"
    foreach ($f in $files) { Write-Host ("- " + $f) }
    exit 0
  } catch {
    Write-Host "## Scope-IN candidates"
    Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done.".Exception.Message)
    exit 1
  }
}
### DONEB_PRNUMBER_SHIM_V2 ###


# === HARD_EARLY_RETURN: PRNUMBER_MODE ===
# PR-number mode: MUST NOT prompt. Force exit before any other logic.
if ($PSBoundParameters.ContainsKey('PrNumber') -and ([int]$PrNumber) -ne 0) {
  $repo = 'Osuu-ops/yorisoidou-system'
  $tool = Join-Path $PSScriptRoot 'mep_scopein_candidates_from_pr.ps1'
  if (-not (Test-Path $tool)) { throw "missing tool: $tool" }
  & $tool -PrNumber ([int]$PrNumber) -Repo $repo
  exit 0
}
# === END HARD_EARLY_RETURN: PRNUMBER_MODE ===


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
$scopePath = Join-Path $repoRoot $ScopeFile
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
# ALWAYS array + normalize slashes
$changedArr = @(
  $changed.ToArray() |
    Where-Object { $_ -and ($_ -notmatch '^\s*$') } |
    ForEach-Object { $_.Replace('\','/') } |
    Sort-Object -Unique
)
if (@($changedArr).Count -eq 0) { Warn "No changed files detected vs $baseRef...HEAD. Scope-IN candidate will be empty." }
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
# ---- SCOPE_FILE upsert (no blank lines) ----
$dir = Split-Path $scopePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
if (!(Test-Path $scopePath)) {
  Info "SCOPE_FILE not found. Creating scaffold."
  @(
    "# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）"
    $ScopeHeader
    "- (none)"
    "## 非対象（Scope-OUT｜明示）"
    "- platform/MEP/01_CORE/**"
    "- platform/MEP/00_GLOBAL/**"
  ) | Set-Content -Path $scopePath -Encoding UTF8
}
$lines = Get-Content -Path $scopePath -Encoding UTF8
if (-not $lines) { $lines = @() }
# locate header (strict equality after Trim)
$startIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i].Trim() -eq $ScopeHeader) { $startIdx = $i; break }
}
# find end (next heading or EOF)
$endIdx = $lines.Count
if ($startIdx -ge 0) {
  for ($j=$startIdx+1; $j -lt $lines.Count; $j++) {
    if ($lines[$j].StartsWith("## ") ) { $endIdx = $j; break }
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
# enforce bullet-only inside Scope-IN block + remove blanks
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
$enforce.ToArray() | Set-Content -Path $scopePath -Encoding UTF8
Info ("Updated SCOPE_FILE: " + $ScopeFile)
# ---- commit/push (scope update) ----
$branchName = (git branch --show-current).Trim()
if (-not $branchName) { Fail "Current branch name is empty." }
git add $scopePath | Out-Null
$ts2 = Get-Date -Format "yyyyMMdd_HHmmss"
$commitMsg = "chore(scope): update Scope-IN via unified entry ($ts2)"
try { git commit -m $commitMsg | Out-Null } catch { Warn "git commit skipped (maybe no changes)." }
try { git push -u origin $branchName | Out-Null } catch { Warn "git push failed (check auth/remote)." }
# ---- optional hooks ----
if ($RunGate) {
  $gate = Join-Path $repoRoot "tools/mep_entry.ps1"
  if (Test-Path $gate) { Info "Run Gate: tools/mep_entry.ps1 -Once"; & $gate -Once } else { Warn "tools/mep_entry.ps1 not found" }
}
if ($RunWriteback) {
  $wfCandidates = @(
    ".github/workflows/mep_writeback_bundle_dispatch.yml",
    ".github/workflows/mep_writeback_bundle_dispatch_v3.yml"
  ) | ForEach-Object { Join-Path $repoRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $wfCandidates) {
    Warn "Writeback workflow yaml not found (known candidates)."
  } else {
    $wfRel = $wfCandidates.Substring($repoRoot.Length).TrimStart('\','/')
    Info "Trigger writeback workflow_dispatch: $wfRel (pr_number=$WritebackPrNumber)"
    try { gh workflow run $wfRel -f pr_number=$WritebackPrNumber | Out-Null } catch { Warn "gh workflow run failed" }
  }
}
Info "Unified entry step1 done."
