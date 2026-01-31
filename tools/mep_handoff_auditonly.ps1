#requires -Version 7.0
<#
  Purpose:
    Generate "AUDIT-ONLY HANDOFF TEXT" from Parent Bundled (single source of truth),
    WITHOUT mutating the caller working tree or branch.

  Source of truth:
    - origin/main:docs/MEP/MEP_BUNDLE.md (fetched at runtime)

  Output:
    1) Prints copy/paste block to stdout
    2) Saves to: %USERPROFILE%\Desktop\MEP_LOGS\HANDOFF_OUT\HANDOFF_AUDITONLY_yyyyMMdd_HHmmss.txt

  Policy:
    - Bundled (primary evidence) only
    - No work memo / no chat log mixing
    - Conflict marker guard (<<<<<<< ======= >>>>>>>)

  Implementation note:
    Uses `git show origin/main:<path>` so it never checks out anything.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $ProgressPreference="SilentlyContinue"

function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail([string]$m){ throw $m }

try {
  $root = git rev-parse --show-toplevel 2>$null
  if (-not $root) { Fail "Not a git repository." }
  Set-Location $root

  $origin = (git config --get remote.origin.url)
  if (-not $origin) { Fail "remote.origin.url is empty." }

  git fetch --prune origin | Out-Null

  $bundledRel = "docs/MEP/MEP_BUNDLE.md"
  $spec = "origin/main:{0}" -f $bundledRel

  # --- read Bundled content from origin/main without checkout ---
  $content = (git show $spec 2>$null)
  if (-not $content) { Fail "git show failed: $spec" }
  $lines = $content -split "`r?`n"

  # --- conflict marker guard ---
  $markerCount = 0
  foreach ($ln in $lines) {
    if ($ln -match '^(<<<<<<<|=======|>>>>>>>)') { $markerCount++ }
  }
  Info ("CONFLICT_MARKERS(Bundled@origin/main) = {0}" -f $markerCount)
  if ($markerCount -gt 0) {
    $p = Join-Path (Join-Path $env:USERPROFILE "Desktop\MEP_LOGS\RECOVERY") ("bundled_conflict_markers_now_{0}.txt" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
    New-Item -ItemType Directory -Force -Path (Split-Path $p) | Out-Null
    $n = 0
    $out = New-Object System.Collections.Generic.List[string]
    for ($i=0; $i -lt $lines.Count; $i++) {
      if ($lines[$i] -match '^(<<<<<<<|=======|>>>>>>>)') {
        $n++
        if ($n -le 200) { $out.Add(("{0,6}: {1}" -f ($i+1), $lines[$i])) }
      }
    }
    $out | Set-Content -LiteralPath $p -Encoding UTF8
    Fail "STOP: Bundled contains merge markers. Report saved: $p"
  }

  # --- BUNDLE_VERSION ---
  $bv = $null
  foreach ($ln in $lines) {
    if ($ln -match '^\s*BUNDLE_VERSION\s*=') {
      $bv = ($ln -replace '^\s*BUNDLE_VERSION\s*=\s*','').Trim()
      break
    }
  }
  if (-not $bv) { Fail "BUNDLE_VERSION line not found in Bundled@origin/main." }
  Info "BUNDLE_VERSION = $bv"

  # --- HEAD(origin/main) ---
  $head = (git rev-parse --short origin/main).Trim()
  if (-not $head) { Fail "git rev-parse origin/main failed." }
  Info "HEAD(origin/main) = $head"

  # --- detect latest writeback-transport PR from merge commits on origin/main (best-effort) ---
  $transportPr = $null
  $mergeSubjects = @(git log origin/main --merges -n 200 --pretty=format:'%s' 2>$null)
  foreach ($s in $mergeSubjects) {
    if ($s -match 'Merge pull request #(?<n>\d+)\s+from\s+(?<br>.+)$') {
      $n  = [int]$Matches.n
      $br = $Matches.br
      if ($br -match '(^auto[/\\]writeback)|(^auto[/\\]sync)|writeback|sync-evidence|sync_evidence') { $transportPr = $n; break }
    }
  }

  # --- fallback: scan Bundled lines for "writeback/sync" evidence and take last PR number ---
  if (-not $transportPr) {
    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
      $ln = $lines[$i]
      if ($ln -match 'PR\s*#\s*(?<n>\d+)\b' -and ($ln -match 'writeback' -or $ln -match 'auto/writeback' -or $ln -match 'auto\/writeback' -or $ln -match 'sync evidence' -or $ln -match 'sync-evidence' -or $ln -match 'sync_evidence')) {
        $transportPr = [int]$Matches.n
        break
      }
    }
  }

  $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"

  $text = @"
【HANDOFF｜次チャット冒頭に貼る本文（監査用・一次根拠のみ）】

REPO_ORIGIN: $origin
PARENT_BUNDLED: $bundledRel

基準点（親Bundled）
- BUNDLE_VERSION = $bv
- HEAD(origin/main) = $head
- generatedAt = $now

注意（監査）
- 親Bundledにマージコンフリクト印(<<<<<<< 等)は存在しない（guard=OK）。
- 本本文は Bundled（一次根拠）のみ。作業メモ・会話ログは混ぜない。
"@.TrimEnd()

  if ($transportPr) {
    $text += "`r`n`r`n証跡（Bundled/運搬PR）`r`n- transport PR = #$transportPr`r`n- note: 元PR番号は出所、Bundled証跡行は運搬PR番号で記録される場合がある。"
  } else {
    $text += "`r`n`r`n証跡（Bundled/運搬PR）`r`n- transport PR = (auto-detect failed: please look at Bundled evidence lines)"
  }

  $outDir = Join-Path $env:USERPROFILE "Desktop\MEP_LOGS\HANDOFF_OUT"
  New-Item -ItemType Directory -Force -Path $outDir | Out-Null
  $outPath = Join-Path $outDir ("HANDOFF_AUDITONLY_{0}.txt" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
  $text | Set-Content -LiteralPath $outPath -Encoding UTF8
  Info "SAVED = $outPath"

  ""
  "===== COPY/PASTE BELOW (AUDIT-ONLY HANDOFF TEXT) ====="
  ""
  $text
  ""
  "===== COPY/PASTE END ====="
  ""

} catch {
  Warn $_.Exception.Message
  throw
}
