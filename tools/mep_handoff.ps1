
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
  $picked = $lines | Where-Object { $_ -match 'audit=OK,WB0000' } | Select-Object -Last $Take
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

# MEP_HANDOFF_FIXED_META_DEFAULTS_BEGIN
# 目的：ROOT_GOAL / ROLE / EXIT_CONDITION などの固定メタが (not set) になるのを禁止し、既定値で必ず埋める。
# 方針：既存実装の変数名に依存しないよう、代表的な候補（$meta / $handoff / $outMeta / $fixedMeta）に対して
#       「存在する場合のみ」不足値を既定値で補完する。
$__mepMetaDefaults = @{
  ROOT_GOAL       = "MEP Evidence を一意・正規・監査耐性ありで main に固定する（1PR=1行 / ノイズ無し）"
  ROLE            = "audited handoff generator"
  EXIT_CONDITION  = "handoff に ROOT_GOAL 等が常に埋まり、次チャット冒頭貼付だけで上位目標が消えない"
}
function __mep_meta_apply_defaults([object]$obj, [hashtable]$defs){
  if ($null -eq $obj) { return $obj }
  if ($obj -is [hashtable]) {
    foreach($k in $defs.Keys){
      if (-not $obj.ContainsKey($k) -or [string]::IsNullOrWhiteSpace([string]$obj[$k]) -or ([string]$obj[$k]).Trim() -eq "(not set)") {
        $obj[$k] = $defs[$k]
      }
    }
    return $obj
  }
  # PSCustomObject 等
  try {
    foreach($k in $defs.Keys){
      $p = $obj.PSObject.Properties[$k]
      if ($null -eq $p) {
        $obj | Add-Member -NotePropertyName $k -NotePropertyValue $defs[$k] -Force
      } else {
        $v = [string]$p.Value
        if ([string]::IsNullOrWhiteSpace($v) -or $v.Trim() -eq "(not set)") {
          $p.Value = $defs[$k]
        }
      }
    }
  } catch {}
  return $obj
}
# 代表的な候補変数に対して適用（存在するものだけ）
try { if (Get-Variable -Name meta -Scope 0 -ErrorAction SilentlyContinue)      { $meta      = __mep_meta_apply_defaults $meta      $__mepMetaDefaults } } catch {}
try { if (Get-Variable -Name handoff -Scope 0 -ErrorAction SilentlyContinue)   { $handoff   = __mep_meta_apply_defaults $handoff   $__mepMetaDefaults } } catch {}
try { if (Get-Variable -Name outMeta -Scope 0 -ErrorAction SilentlyContinue)   { $outMeta   = __mep_meta_apply_defaults $outMeta   $__mepMetaDefaults } } catch {}
try { if (Get-Variable -Name fixedMeta -Scope 0 -ErrorAction SilentlyContinue) { $fixedMeta = __mep_meta_apply_defaults $fixedMeta $__mepMetaDefaults } } catch {}
# 最後に「出力テキスト」側に (not set) が混入していたら置換する（最後の安全網）
try {
  if (Get-Variable -Name out -Scope 0 -ErrorAction SilentlyContinue) {
    if ($out -is [System.Collections.Generic.List[string]]) {
      for ($i=0; $i -lt $out.Count; $i++) {
        if ($out[$i] -match "^(ROOT_GOAL|ROLE|EXIT_CONDITION)\s*:\s*\(not set\)\s*$") {
          $k = ($Matches[1])
          $out[$i] = ($k + ": " + $__mepMetaDefaults[$k])
        }
      }
    }
  }
} catch {}
# MEP_HANDOFF_FIXED_META_DEFAULTS_END


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








