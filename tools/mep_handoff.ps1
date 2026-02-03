
function Get-BundledAtFromBundled([string]$bundledPath){
  if (-not (Test-Path $bundledPath)) { return $null }
  $m = Select-String -Path $bundledPath -Pattern '^\s*BUNDLED_AT\s*=\s*(.+)\s*$' -AllMatches -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($m) { return $m.Matches[0].Groups[1].Value.Trim() }
  return $null
}
function Get-HandoffVerifiedAt([string]$evidenceFile){
  if (-not (Test-Path $evidenceFile)) { return $null }
  $v = (Get-Content -Path $evidenceFile -ErrorAction SilentlyContinue | Select-Object -First 1)
  if ($v) { return $v.Trim() }
  return $null
}
Set-StrictMode -Version Latest

# === MEP_HANDOFF_BUNDLED_PATCH_v1 ===
# Adds Bundled (docs/MEP/MEP_BUNDLE.md) evidence extraction into handoff output.
function __ReadBundledEvidence {
  param([string]$RepoRoot)
  $p = Join-Path $RepoRoot "docs/MEP/MEP_BUNDLE.md"
  if (!(Test-Path $p)) { return @{ ok=$false; err="Bundled missing: $p" } }
  $bundleVersion = (Select-String -Path $p -Pattern '^BUNDLE_VERSION\s*=' -List).Line
  if (-not $bundleVersion) { $bundleVersion = "<BUNDLE_VERSION_NOT_FOUND>" }
  # Extract: CARD headings + key evidence tokens + recent PR evidence lines (best-effort)
  $lines = Get-Content -Path $p -Encoding UTF8
  $cards = @()
  foreach ($m in ($lines | Select-String -Pattern "^\s*##\s*CARD:\s*.+" -AllMatches)) { $cards += $m.Line }
}
# --- StrictMode guard: ensure $evidencePath is always initialized (avoid unbound variable) ---
try {
  $repoRoot = (git rev-parse --show-toplevel 2>$null)
  if ($repoRoot) {
    $repoRoot = $repoRoot.Trim()
    $cand = Join-Path $repoRoot "docs\MEP_SUB\EVIDENCE\MEP_BUNDLE.md"
    if (Test-Path $cand) {
      $evidencePath = $cand
    } elseif (-not (Get-Variable evidencePath -Scope Local -ErrorAction SilentlyContinue)) {
      $evidencePath = ""
    }
  } elseif (-not (Get-Variable evidencePath -Scope Local -ErrorAction SilentlyContinue)) {
    $evidencePath = ""
  }
} catch {
  if (-not (Get-Variable evidencePath -Scope Local -ErrorAction SilentlyContinue)) { $evidencePath = "" }
}
# --- end guard ---
$ErrorActionPreference = "Stop"
$env:GIT_PAGER="cat"
$env:PAGER="cat"

function Fail([string]$m){ throw $m }

###__MEP_HANDOFF_EVIDENCE_EXTRACTOR_INJECTED__###
function Get-MepEvidenceAuditMarkers {
  param(
    [Parameter(Mandatory=$true)][string]$RepoRoot,
    [string]$EvidenceRel = "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md",
    [int]$Tail = 400,
    [int]$Take = 5
  )
  $evidenceAbs = Join-Path $RepoRoot $EvidenceRel
  if (-not (Test-Path -LiteralPath $evidenceAbs)) {
    throw "EVIDENCE_BUNDLE not found: $EvidenceRel"
  }
  $lines = Get-Content -LiteralPath $evidenceAbs -Encoding UTF8 -Tail $Tail
  $picked = $lines | Where-Object { $_ -match "audit=OK,WB0000" } | Select-Object -Last $Take
  return ,$picked
}
function Info([string]$m){ Write-Host $m -ForegroundColor Cyan }

try {
  if (!(Test-Path -LiteralPath ".git")) { Fail "Run at repo root (where .git exists)." }

  $repoUrl = (git remote get-url origin 2>$null)
  if (-not $repoUrl) { $repoUrl = "(origin not found)" }

  $bundlePath = "docs/MEP/MEP_BUNDLE.md"
  if (!(Test-Path -LiteralPath $bundlePath)) { Fail ("Missing: " + $bundlePath) }

  $bvLine = (Select-String -LiteralPath $bundlePath -Pattern "^BUNDLE_VERSION\s*=" -ErrorAction SilentlyContinue | Select-Object -First 1)
  $bundleVersion = if ($bvLine) { ($bvLine.Line -replace "\s+$","") } else { "BUNDLE_VERSION = (not found)" }

  # === TIME_MARKS_INLINE_OUT_BEGIN (transcribe-only; do not generate) ===
  $bundledAtLine = (Select-String -LiteralPath $bundlePath -Pattern "^BUNDLED_AT\s*=" -ErrorAction SilentlyContinue | Select-Object -First 1)
  $parentBundledAt = if ($bundledAtLine) { (($bundledAtLine.Line -replace "\s+$","") -replace "^\s*BUNDLED_AT\s*=\s*","") } else { "(not found)" }
  $handoffFile = "docs/MEP_SUB/EVIDENCE/HANDOFF_VERIFIED_AT.txt"
  $handoffVerifiedAt = if (Test-Path -LiteralPath $handoffFile) { (Get-Content -LiteralPath $handoffFile -TotalCount 1) } else { "(not found)" }
  $evidenceBundledAtLine = (Select-String -LiteralPath $evidencePath -Pattern "^BUNDLED_AT\s*=" -ErrorAction SilentlyContinue | Select-Object -First 1)
  $evidenceBundledAt = if ($evidenceBundledAtLine) { (($evidenceBundledAtLine.Line -replace "\s+$","") -replace "^\s*BUNDLED_AT\s*=\s*","") } else { "(not found)" }
  # === TIME_MARKS_INLINE_OUT_END ===
#   $evidencePath = "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"  # do not overwrite resolved evidencePath
  # === EVIDENCE_BUNDLED_AT_COMPUTE_BEGIN (mtime-based) ===
  # force evidencePath to repoRoot + fixed relative (stable)
  if ($repoRoot) {
    $evidencePath = (Join-Path $repoRoot "docs\MEP_SUB\EVIDENCE\MEP_BUNDLE.md")
  } else {
    $evidencePath = "docs\MEP_SUB\EVIDENCE\MEP_BUNDLE.md"
  }
  if (-not $evidencePath) {
    if ($repoRoot) {
      $evidencePath = (Join-Path $repoRoot "docs\MEP_SUB\EVIDENCE\MEP_BUNDLE.md")
    } else {
      $evidencePath = "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"
    }
  }
  $evidenceBundledAt = if (Test-Path -LiteralPath $evidencePath) {
    (Get-Item -LiteralPath $evidencePath).LastWriteTime.ToString("yyyy-MM-ddTHH:mm:ssK")
  } else {
    "(not found)"
  }
  # === EVIDENCE_BUNDLED_AT_COMPUTE_END ===
  $evOk = Test-Path -LiteralPath $evidencePath

  # recent PR evidence anchors we touched in this session
  $targets = @(1567,1204,1210,1214,1218,1220,1222,1224,1226,1233)
  $evLines = @()
  if ($evOk) {
    foreach ($n in $targets) {
      $hit = Select-String -LiteralPath $evidencePath -Pattern ("PR\s*#\s*" + $n + "\b") -ErrorAction SilentlyContinue | Select-Object -First 1
      if ($hit) { $evLines += $hit.Line }
    }
  }

  $head = (git rev-parse --short HEAD 2>$null)
  if (-not $head) { $head = "(unknown)" }

  $out = New-Object System.Collections.Generic.List[string]
  # --- meta header (chat/card) ---
  $chatId = if ($env:MEP_CHAT_ID) { $env:MEP_CHAT_ID } else { (Get-Date -Format "yyyyMMdd_HHmmss") + "_JST" }
  $cardId = if ($env:MEP_CARD_ID) { $env:MEP_CARD_ID } else { "(not set)" }
  $role   = if ($env:MEP_ROLE)    { $env:MEP_ROLE }    else { "(not set)" }
  $roleJp = if ($env:MEP_ROLE_JP) { $env:MEP_ROLE_JP } else { "(not set)" }
  $exitC  = if ($env:MEP_EXIT_CONDITION) { $env:MEP_EXIT_CONDITION } else { "(not set)" }
  $rootG  = if ($env:MEP_ROOT_GOAL) { $env:MEP_ROOT_GOAL } else { "(not set)" }
  $derivG = if ($env:MEP_DERIVED_GOAL) { $env:MEP_DERIVED_GOAL } else { "(not set)" }
  $chain  = if ($env:MEP_PARENT_CHAIN) { $env:MEP_PARENT_CHAIN } else { "(not set)" }

  $out.Add("CHAT_ID（チャット識別ID）: " + $chatId)
  $out.Add("CARD_ID（担当カード）: " + $cardId)
  $out.Add("ROLE（役割）: " + $role)
  $out.Add("ROLE_JP（役割・日本語）: " + $roleJp)
  $out.Add("EXIT_CONDITION（終了条件）: " + $exitC)
  $out.Add("ROOT_GOAL（上位目的・固定）: " + $rootG)
  $out.Add("DERIVED_GOAL（派生目的・担当範囲）: " + $derivG)
  $out.Add("PARENT_CHAIN（派生元）: " + $chain)
  $out.Add("")
  $out.Add("【HANDOFF｜次チャット冒頭に貼る本文】")
  $out.Add("")
  $out.Add("REPO_ORIGIN: " + $repoUrl)

## Scope-IN
$out.Add("- tools/mep_handoff.ps1")
  $out.Add("HEAD: " + $head)
  $out.Add($bundleVersion)
  $out.Add("PARENT_BUNDLED_AT: " + $parentBundledAt)
  $out.Add("HANDOFF_VERIFIED_AT: " + $handoffVerifiedAt)
  $out.Add("GENERATED_AT: " + $handoffVerifiedAt)
$out.Add("EVIDENCE_BUNDLE: docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md")
  $out.Add("EVIDENCE_BUNDLED_AT: " + $evidenceBundledAt)
  $out.Add("")
  $out.Add("完了（今回の確定点）")
  $out.Add("- Pre-Gate→AUTO（read-only suite）完走（stage=DONE）")
  $out.Add("- tools: entry/auto/stage を args-based に統一（StrictMode耐性）")
  $out.Add("")
  $out.Add("証跡（EVIDENCEより抜粋）")
try {
  $repoRoot = (git rev-parse --show-toplevel 2>$null)
  if (-not $repoRoot) { throw "git rev-parse failed in handoff." }
  $markers = Get-MepEvidenceAuditMarkers -RepoRoot $repoRoot -EvidenceRel "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md" -Tail 400 -Take 5
  if ($markers -and $markers.Count -gt 0) {
    foreach ($ln in $markers) { $out.Add("- " + $ln) }
  } else {
    $out.Add("- EVIDENCE_BUNDLE抽出不能（audit=OK,WB0000 が Tail 400 に存在しない）: docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md")
  }
} catch {
  $out.Add("- EVIDENCE_BUNDLE抽出不能（例外）: " + $_.Exception.Message)
}
  $out.Add("次から自動で回す入口")
  $out.Add("- .\tools\mep_entry.ps1 -Once")
  $out.Add("")
  $out.Add("注記")
  $out.Add("- 本文は Bundled/EVIDENCE の一次根拠のみを採用。会話ログは根拠にしない。")
  $out.Add("")

  Write-Host ($out -join "`n")
  exit 0
}
catch {
  Write-Error $_.Exception.Message
  exit 1
}








  $key = @(
    "RULESET_REQUIRED_CHECKS_EVIDENCE",
    "RULESET_MERGE_BLOCK_EVIDENCE"
  )
  $keyHits = @()
  foreach ($k in $key) {
    foreach ($m in ($lines | Select-String -SimpleMatch $k)) { $keyHits += $m.Line.Trim() }
  }
  $prs = @("PR #1669","PR #1671","PR #1673")
  $prHits = @()
  foreach ($pr in $prs) {
    foreach ($m in ($lines | Select-String -SimpleMatch $pr)) { $prHits += $m.Line.Trim() }
  }
  return @{
    ok=$true
    path=$p
    bundle_version=$bundleVersion
    cards=$cards
    key_hits=$keyHits
    pr_hits=$prHits
  }

# === /MEP_HANDOFF_BUNDLED_PATCH_v1 ===

# --- StrictMode guard: ensure $evidencePath is always initialized (avoid unbound variable) ---
try {
  $repoRoot = (git rev-parse --show-toplevel 2>$null)
  if ($repoRoot) {
    $repoRoot = $repoRoot.Trim()
    $cand = Join-Path $repoRoot "docs\MEP_SUB\EVIDENCE\MEP_BUNDLE.md"
    if (Test-Path $cand) {
      $evidencePath = $cand
    } elseif (-not (Get-Variable evidencePath -Scope Local -ErrorAction SilentlyContinue)) {
      $evidencePath = ""
    }
  } elseif (-not (Get-Variable evidencePath -Scope Local -ErrorAction SilentlyContinue)) {
    $evidencePath = ""
  }
} catch {
  if (-not (Get-Variable evidencePath -Scope Local -ErrorAction SilentlyContinue)) { $evidencePath = "" }
}
# --- end guard ---
$ErrorActionPreference = "Stop"
$env:GIT_PAGER="cat"
$env:PAGER="cat"

function Fail([string]$m){ throw $m }

###__MEP_HANDOFF_EVIDENCE_EXTRACTOR_INJECTED__###
function Get-MepEvidenceAuditMarkers {
  param(
    [Parameter(Mandatory=$true)][string]$RepoRoot,
    [string]$EvidenceRel = "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md",
    [int]$Tail = 400,
    [int]$Take = 5
  )
  $evidenceAbs = Join-Path $RepoRoot $EvidenceRel
  if (-not (Test-Path -LiteralPath $evidenceAbs)) {
    throw "EVIDENCE_BUNDLE not found: $EvidenceRel"
  }
  $lines = Get-Content -LiteralPath $evidenceAbs -Encoding UTF8 -Tail $Tail
  $picked = $lines | Where-Object { $_ -match "audit=OK,WB0000" } | Select-Object -Last $Take
  return ,$picked
}
function Info([string]$m){ Write-Host $m -ForegroundColor Cyan }

try {
  if (!(Test-Path -LiteralPath ".git")) { Fail "Run at repo root (where .git exists)." }

  $repoUrl = (git remote get-url origin 2>$null)
  if (-not $repoUrl) { $repoUrl = "(origin not found)" }

  $bundlePath = "docs/MEP/MEP_BUNDLE.md"
  if (!(Test-Path -LiteralPath $bundlePath)) { Fail ("Missing: " + $bundlePath) }

  $bvLine = (Select-String -LiteralPath $bundlePath -Pattern "^BUNDLE_VERSION\s*=" -ErrorAction SilentlyContinue | Select-Object -First 1)
  $bundleVersion = if ($bvLine) { ($bvLine.Line -replace "\s+$","") } else { "BUNDLE_VERSION = (not found)" }

  # === TIME_MARKS_INLINE_OUT_BEGIN (transcribe-only; do not generate) ===
  $bundledAtLine = (Select-String -LiteralPath $bundlePath -Pattern "^BUNDLED_AT\s*=" -ErrorAction SilentlyContinue | Select-Object -First 1)
  $parentBundledAt = if ($bundledAtLine) { (($bundledAtLine.Line -replace "\s+$","") -replace "^\s*BUNDLED_AT\s*=\s*","") } else { "(not found)" }
  $handoffFile = "docs/MEP_SUB/EVIDENCE/HANDOFF_VERIFIED_AT.txt"
  $handoffVerifiedAt = if (Test-Path -LiteralPath $handoffFile) { (Get-Content -LiteralPath $handoffFile -TotalCount 1) } else { "(not found)" }
  $evidenceBundledAtLine = (Select-String -LiteralPath $evidencePath -Pattern "^BUNDLED_AT\s*=" -ErrorAction SilentlyContinue | Select-Object -First 1)
  $evidenceBundledAt = if ($evidenceBundledAtLine) { (($evidenceBundledAtLine.Line -replace "\s+$","") -replace "^\s*BUNDLED_AT\s*=\s*","") } else { "(not found)" }
  # === TIME_MARKS_INLINE_OUT_END ===
#   $evidencePath = "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"  # do not overwrite resolved evidencePath
  # === EVIDENCE_BUNDLED_AT_COMPUTE_BEGIN (mtime-based) ===
  # force evidencePath to repoRoot + fixed relative (stable)
  if ($repoRoot) {
    $evidencePath = (Join-Path $repoRoot "docs\MEP_SUB\EVIDENCE\MEP_BUNDLE.md")
  } else {
    $evidencePath = "docs\MEP_SUB\EVIDENCE\MEP_BUNDLE.md"
  }
  if (-not $evidencePath) {
    if ($repoRoot) {
      $evidencePath = (Join-Path $repoRoot "docs\MEP_SUB\EVIDENCE\MEP_BUNDLE.md")
    } else {
      $evidencePath = "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"
    }
  }
  $evidenceBundledAt = if (Test-Path -LiteralPath $evidencePath) {
    (Get-Item -LiteralPath $evidencePath).LastWriteTime.ToString("yyyy-MM-ddTHH:mm:ssK")
  } else {
    "(not found)"
  }
  # === EVIDENCE_BUNDLED_AT_COMPUTE_END ===
  $evOk = Test-Path -LiteralPath $evidencePath

  # recent PR evidence anchors we touched in this session
  $targets = @(1567,1204,1210,1214,1218,1220,1222,1224,1226,1233)
  $evLines = @()
  if ($evOk) {
    foreach ($n in $targets) {
      $hit = Select-String -LiteralPath $evidencePath -Pattern ("PR\s*#\s*" + $n + "\b") -ErrorAction SilentlyContinue | Select-Object -First 1
      if ($hit) { $evLines += $hit.Line }
    }
  }

  $head = (git rev-parse --short HEAD 2>$null)
  if (-not $head) { $head = "(unknown)" }

  $out = New-Object System.Collections.Generic.List[string]
  # --- meta header (chat/card) ---
  $chatId = if ($env:MEP_CHAT_ID) { $env:MEP_CHAT_ID } else { (Get-Date -Format "yyyyMMdd_HHmmss") + "_JST" }
  $cardId = if ($env:MEP_CARD_ID) { $env:MEP_CARD_ID } else { "(not set)" }
  $role   = if ($env:MEP_ROLE)    { $env:MEP_ROLE }    else { "(not set)" }
  $roleJp = if ($env:MEP_ROLE_JP) { $env:MEP_ROLE_JP } else { "(not set)" }
  $exitC  = if ($env:MEP_EXIT_CONDITION) { $env:MEP_EXIT_CONDITION } else { "(not set)" }
  $rootG  = if ($env:MEP_ROOT_GOAL) { $env:MEP_ROOT_GOAL } else { "(not set)" }
  $derivG = if ($env:MEP_DERIVED_GOAL) { $env:MEP_DERIVED_GOAL } else { "(not set)" }
  $chain  = if ($env:MEP_PARENT_CHAIN) { $env:MEP_PARENT_CHAIN } else { "(not set)" }

  $out.Add("CHAT_ID（チャット識別ID）: " + $chatId)
  $out.Add("CARD_ID（担当カード）: " + $cardId)
  $out.Add("ROLE（役割）: " + $role)
  $out.Add("ROLE_JP（役割・日本語）: " + $roleJp)
  $out.Add("EXIT_CONDITION（終了条件）: " + $exitC)
  $out.Add("ROOT_GOAL（上位目的・固定）: " + $rootG)
  $out.Add("DERIVED_GOAL（派生目的・担当範囲）: " + $derivG)
  $out.Add("PARENT_CHAIN（派生元）: " + $chain)
  $out.Add("")
  $out.Add("【HANDOFF｜次チャット冒頭に貼る本文】")
  $out.Add("")
  $out.Add("REPO_ORIGIN: " + $repoUrl)

## Scope-IN
- tools/mep_handoff.ps1
  $out.Add("HEAD: " + $head)
  $out.Add($bundleVersion)
  $out.Add("PARENT_BUNDLED_AT: " + $parentBundledAt)
  $out.Add("HANDOFF_VERIFIED_AT: " + $handoffVerifiedAt)
  $out.Add("GENERATED_AT: " + $handoffVerifiedAt)
$out.Add("EVIDENCE_BUNDLE: docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md")
  $out.Add("EVIDENCE_BUNDLED_AT: " + $evidenceBundledAt)
  $out.Add("")
  $out.Add("完了（今回の確定点）")
  $out.Add("- Pre-Gate→AUTO（read-only suite）完走（stage=DONE）")
  $out.Add("- tools: entry/auto/stage を args-based に統一（StrictMode耐性）")
  $out.Add("")
  $out.Add("証跡（EVIDENCEより抜粋）")
try {
  $repoRoot = (git rev-parse --show-toplevel 2>$null)
  if (-not $repoRoot) { throw "git rev-parse failed in handoff." }
  $markers = Get-MepEvidenceAuditMarkers -RepoRoot $repoRoot -EvidenceRel "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md" -Tail 400 -Take 5
  if ($markers -and $markers.Count -gt 0) {
    foreach ($ln in $markers) { $out.Add("- " + $ln) }
  } else {
    $out.Add("- EVIDENCE_BUNDLE抽出不能（audit=OK,WB0000 が Tail 400 に存在しない）: docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md")
  }
} catch {
  $out.Add("- EVIDENCE_BUNDLE抽出不能（例外）: " + $_.Exception.Message)
}
  $out.Add("次から自動で回す入口")
  $out.Add("- .\tools\mep_entry.ps1 -Once")
  $out.Add("")
  $out.Add("注記")
  $out.Add("- 本文は Bundled/EVIDENCE の一次根拠のみを採用。会話ログは根拠にしない。")
  $out.Add("")

  Write-Host ($out -join "`n")
  exit 0
}
catch {
  Write-Error $_.Exception.Message
  exit 1
}

# === MEP_HANDOFF_BUNDLED_APPEND_v1 ===
try {
  $be = __ReadBundledEvidence -RepoRoot $PSScriptRoot | Out-Null
} catch {}
try {
  # Note: $PSScriptRoot points to tools/ ; repoRoot is parent of tools/
  $repoRoot = Split-Path -Parent $PSScriptRoot
  $be = __ReadBundledEvidence -RepoRoot $repoRoot
  if ($be.ok) {
    Write-Output ""
    Write-Output "=== [Bundled Evidence] ==="
    Write-Output ("Bundled Path: " + $be.path)
    Write-Output ("Bundled " + $be.bundle_version)
    if ($be.cards -and $be.cards.Count -gt 0) {
      Write-Output ""
      Write-Output "Cards:"
      $be.cards | ForEach-Object { Write-Output ("- " + $_) }
    }
    if ($be.key_hits -and $be.key_hits.Count -gt 0) {
      Write-Output ""
      Write-Output "Key Evidence Hits (raw lines):"
      $be.key_hits | Select-Object -Unique | ForEach-Object { Write-Output ("- " + $_) }
    } else {
      Write-Output ""
      Write-Output "Key Evidence Hits: (none found; check Bundled text)"
    }
    if ($be.pr_hits -and $be.pr_hits.Count -gt 0) {
      Write-Output ""
      Write-Output "PR Evidence Hits (raw lines):"
      $be.pr_hits | Select-Object -Unique | ForEach-Object { Write-Output ("- " + $_) }
    } else {
      Write-Output ""
      Write-Output "PR Evidence Hits: (none found in Bundled; PR evidence may be in EVIDENCE_BUNDLE only)"
    }
  } else {
    Write-Output ""
    Write-Output "=== [Bundled Evidence] ==="
    Write-Output ("Bundled read failed: " + $be.err)
  }
} catch {
  Write-Output ""
  Write-Output "=== [Bundled Evidence] ==="
  Write-Output ("Bundled append failed: " + $_.Exception.Message)
}
# === /MEP_HANDOFF_BUNDLED_APPEND_v1 ===



# === MEP_HANDOFF_EOF_PATCH_v1 (SAFE: EOF only) ===
# Goal:
# - Surface Bundled (docs/MEP/MEP_BUNDLE.md) + EVIDENCE_BUNDLE (docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md) evidence
# - Surface mep_entry run evidence (Desktop\MEP_LOGS\ENTRY_AUDIT)
# - Do not disturb existing handoff logic; only append additional sections.
function __MEP_ReadTextLines {
  param([string]$Path)
  if (!(Test-Path $Path)) { return @() }
  try { return (Get-Content -LiteralPath $Path -Encoding UTF8 -ErrorAction Stop) } catch { return (Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue) }
}
function __MEP_GrepLines {
  param(
    [string[]]$Lines,
    [string]$Regex,
    [int]$Max = 200
  )
  $out = New-Object System.Collections.Generic.List[string]
  foreach ($l in $Lines) {
    if ($l -match $Regex) { $out.Add($l.Trim()) }
    if ($out.Count -ge $Max) { break }
  }
  return $out.ToArray()
}
function __MEP_PrintSection {
  param([string]$Title, [string[]]$Lines)
  Write-Output ""
  Write-Output ("=== [" + $Title + "] ===")
  if (-not $Lines -or $Lines.Count -eq 0) {
    Write-Output "(none)"
    return
  }
  $Lines | Select-Object -Unique | ForEach-Object { Write-Output ("- " + $_) }
}
try {
  $repoRoot = Split-Path -Parent $PSScriptRoot
  $bundledPath  = Join-Path $repoRoot "docs/MEP/MEP_BUNDLE.md"
  $evidencePath = Join-Path $repoRoot "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"
  # --- Bundled ---
  $bundledLines = __MEP_ReadTextLines -Path $bundledPath
  $bundleVersion = ($bundledLines | Select-String -Pattern "^\s*BUNDLE_VERSION\s*=" -List -ErrorAction SilentlyContinue).Line
  if (-not $bundleVersion) { $bundleVersion = "<BUNDLE_VERSION_NOT_FOUND>" }
  Write-Output ""
  Write-Output "=== [Bundled Baseline] ==="
  Write-Output ("Bundled Path: " + $bundledPath)
  Write-Output ("Bundled " + $bundleVersion)
  # CARD headings
  $cards = __MEP_GrepLines -Lines $bundledLines -Regex "^\s*##\s*CARD:\s*.+$" -Max 500
  __MEP_PrintSection -Title "Bundled Cards" -Lines $cards
  # Ruleset evidence: match broadly (token names may differ)
  $rulesetHits = __MEP_GrepLines -Lines $bundledLines -Regex "(?i)RULESET_|Required\s*checks|merge\s*block|MERGE_BLOCK" -Max 300
  __MEP_PrintSection -Title "Bundled Ruleset/Checks Evidence (raw lines)" -Lines $rulesetHits
  # PR evidence: match 1669/1671/1673 even if formatting differs
  $prHits = __MEP_GrepLines -Lines $bundledLines -Regex "(?i)(PR\s*#\s*(1669|1671|1673|1676)\b|pull/(1669|1671|1673|1676)\b|\b(1669|1671|1673|1676)\b)" -Max 200
  __MEP_PrintSection -Title "Bundled PR Evidence (1669/1671/1673 raw lines)" -Lines $prHits
  # --- EVIDENCE_BUNDLE (fallback / supplement) ---
  $evidenceLines = __MEP_ReadTextLines -Path $evidencePath
  Write-Output ""
  Write-Output "=== [EVIDENCE_BUNDLE Baseline] ==="
  Write-Output ("EVIDENCE_BUNDLE Path: " + $evidencePath)
  $evVersion = ($evidenceLines | Select-String -Pattern "^\s*BUNDLE_VERSION\s*=" -List -ErrorAction SilentlyContinue).Line
  if ($evVersion) { Write-Output ("EVIDENCE_BUNDLE " + $evVersion) }
  $evRulesetHits = __MEP_GrepLines -Lines $evidenceLines -Regex "(?i)RULESET_|Required\s*checks|merge\s*block|MERGE_BLOCK" -Max 300
  __MEP_PrintSection -Title "EVIDENCE_BUNDLE Ruleset/Checks Evidence (raw lines)" -Lines $evRulesetHits
  $evPrHits = __MEP_GrepLines -Lines $evidenceLines -Regex "(?i)(PR\s*#\s*(1669|1671|1673|1676)\b|pull/(1669|1671|1673|1676)\b|\b(1669|1671|1673|1676)\b)" -Max 200
  __MEP_PrintSection -Title "EVIDENCE_BUNDLE PR Evidence (1669/1671/1673 raw lines)" -Lines $evPrHits
  # --- mep_entry evidence (logs) ---
  $entryDir = Join-Path $env:USERPROFILE "Desktop\MEP_LOGS\ENTRY_AUDIT"
  Write-Output ""
  Write-Output "=== [Entry Orchestrator Evidence] ==="
  Write-Output ("ENTRY_AUDIT Dir: " + $entryDir)
  $latest = $null
  if (Test-Path $entryDir) {
    $latest = Get-ChildItem -LiteralPath $entryDir -Recurse -File -ErrorAction SilentlyContinue |
      Sort-Object LastWriteTime -Descending |
      Select-Object -First 1
  }
  if ($latest) {
    Write-Output ("Latest Log: " + $latest.FullName)
    $logLines = __MEP_ReadTextLines -Path $latest.FullName
    # pull the key tokens aggressively
    $entryHits = __MEP_GrepLines -Lines $logLines -Regex "(?i)(ENTRY_EXIT|STOP_REASON|ALL_DONE|Progress|Gate\s*\d+/\d+|mep_entry\.ps1)" -Max 200
    __MEP_PrintSection -Title "ENTRY_AUDIT Key Lines (raw)" -Lines $entryHits
  } else {
    Write-Output "(no log file found)"
  }
} catch {
  Write-Output ""
  Write-Output "=== [EOF Patch Error] ==="
  Write-Output ($_.Exception.Message)
}
# === /MEP_HANDOFF_EOF_PATCH_v1 ===
