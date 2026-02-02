
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
  $out.Add("HEAD: " + $head)
  $out.Add($bundleVersion)
  $out.Add("PARENT_BUNDLED_AT: " + $parentBundledAt)
  $out.Add("HANDOFF_VERIFIED_AT: " + $handoffVerifiedAt)
  $out.Add("GENERATED_AT: " + $handoffVerifiedAt)
  $out.Add("EVIDENCE_BUNDLE: " + $evidencePath)
  $out.Add("EVIDENCE_BUNDLED_AT: " + $evidenceBundledAt)
  $out.Add("")
  $out.Add("完了（今回の確定点）")
  $out.Add("- Pre-Gate→AUTO（read-only suite）完走（stage=DONE）")
  $out.Add("- tools: entry/auto/stage を args-based に統一（StrictMode耐性）")
  $out.Add("")
  $out.Add("証跡（EVIDENCEより抜粋）")
  if ($evOk -and $evLines.Count -gt 0) {
    foreach ($l in $evLines) { $out.Add("- " + $l) }
  } elseif ($evOk) {
    # --- fallback excerpt (tail scan) ---
try {
  if (Test-Path $evidencePath) {
    $tail = Get-Content -Path $evidencePath -Tail 300 -ErrorAction Stop
    $hits = $tail | Select-String -Pattern '^\s*\*?\s*-?\s*PR #\d+ \| .*audit=OK,WB0000' -ErrorAction SilentlyContinue | Select-Object -Last 5
    if ($hits -and $hits.Count -gt 0) {
      foreach ($h in $hits) { $out.Add("- " + $h.Line.Trim()) }
    } else {
      $out.Add("- （EVIDENCE_BUNDLEは存在するが、対象PR行を未検出）")
    }
  } else {
    $out.Add("- （EVIDENCE_BUNDLEが存在しない）")
  }
} catch {
  $out.Add("- （EVIDENCE_BUNDLE抽出で例外）: " + $_.Exception.Message)
}
# --- /fallback excerpt ---
  } else {
    $out.Add("- （EVIDENCE_BUNDLEが存在しない）")
  }
  $out.Add("")
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


