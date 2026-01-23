[CmdletBinding()]
param(
  [Parameter()][string]$BundlePath = "docs/MEP/MEP_BUNDLE.md",
  [Parameter()][string]$OutPath    = "docs/MEP/HANDOFF_NEXT.generated.md",
  [Parameter()][int]$MaxEvidenceLines = 80
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $BundlePath)) { throw "BundlePath not found: $BundlePath" }

$lines = Get-Content -LiteralPath $BundlePath -Encoding UTF8
$bvLine = ($lines | Where-Object { $_ -match '^\s*BUNDLE_VERSION\s*=' } | Select-Object -First 1)
if (-not $bvLine) { throw "BUNDLE_VERSION line not found in $BundlePath" }

$evidence = $lines | Where-Object { $_ -match '^\s*-\s+PR\s+#\d+\s+\|' }
if ($evidence.Count -gt $MaxEvidenceLines) { $evidence = $evidence[-$MaxEvidenceLines..-1] }

$ok = @()
$ng = @()
foreach ($l in $evidence) {
  if ($l -match 'audit=OK,WB0000') { $ok += $l }
  elseif ($l -match 'audit=NG,WB') { $ng += $l }
}

function Extract-NGSignals([string[]]$ngLines) {
  $signals = New-Object System.Collections.Generic.HashSet[string]
  foreach ($l in $ngLines) {
    foreach ($m in ([regex]::Matches($l, '([A-Za-z0-9_-]+):FAILURE'))) { [void]$signals.Add($m.Groups[1].Value) }
    foreach ($m in ([regex]::Matches($l, '\bgate:FAILURE\b'))) { [void]$signals.Add("gate") }
    foreach ($m in ([regex]::Matches($l, '\baudit=NG,([A-Z0-9]+)\b'))) { [void]$signals.Add($m.Groups[1].Value) }
  }
  return $signals | Sort-Object
}

$signals = Extract-NGSignals -ngLines $ng
$undone = @()
foreach ($s in $signals) {
  switch ($s) {
    "semantic-audit-business" { $undone += "- NG回収：semantic-audit-business を SUCCESS に戻す（監査OK収束）" }
    "gate"                   { $undone += "- NG回収：gate:FAILURE の原因を解消し audit=OK に収束" }
    default                  { $undone += "- NG回収：$s の FAILURE/NG を解消し audit=OK に収束" }
  }
}

$body = @()
$body += "## 引継ぎ文兼 指令書（Bundled基準・本文のみ）"
$body += ""
$body += "基準点："
$body += ""
$body += "* $bvLine"
$body += ""
$body += "進捗台帳（機械生成）："
$body += ""
$body += "* OK（audit=OK,WB0000）"
if ($ok.Count -eq 0) { $body += "  * （該当なし）" } else { $ok | ForEach-Object { $body += "  * $_" } }
$body += ""
$body += "* NG（audit=NG）"
if ($ng.Count -eq 0) { $body += "  * （該当なし）" } else { $ng | ForEach-Object { $body += "  * $_" } }
$body += ""
$body += "制約："
$body += ""
$body += "* 「確定」「完了」等の断定は、audit=OK の正規証跡行＋BUNDLE_VERSION でのみ行う。"
$body += "* 会話ログは監査対象外。Bundled（本文＋証跡）が唯一の根拠。"
$body += ""
$body += "次の目的（NG/未確定の回収）："
$body += ""
if ($undone.Count -eq 0) { $body += "* （NG/未確定の回収項目は検出されなかった）" } else { $body += $undone }
$body += ""

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutPath) | Out-Null
$body -join "`n" | Set-Content -LiteralPath $OutPath -Encoding UTF8

Write-Output "OK: generated $OutPath from $BundlePath"
