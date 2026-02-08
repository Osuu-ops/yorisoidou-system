Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
param(
  [string]$RepoRoot = (git rev-parse --show-toplevel).Trim(),
  [string]$OutDir   = (Join-Path (git rev-parse --show-toplevel).Trim() ".mep_op2_out")
)
function New-Dir([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Path $Path | Out-Null }
}
function Score-Tool([System.IO.FileInfo]$fi) {
  $n = $fi.Name.ToLowerInvariant()
  $score = 0
  if ($n -match 'handoff') { $score += 10 }
  if ($n -match 'mep') { $score += 3 }
  if ($n -match 'generate|gen|create|make') { $score += 6 }
  if ($n -match 'recover|restore|repair|recovery|fix') { $score += 6 }
  if ($n -match 'min') { $score += 2 }
  if ($n -match 'auto|loop') { $score += 1 }
  return $score
}
function Select-Tool([string]$toolsDir, [ValidateSet('generate','recover')] [string]$kind) {
  $files = Get-ChildItem -LiteralPath $toolsDir -File -Filter '*.ps1' | Where-Object { $_.Name -match 'handoff' }
  if (-not $files) { return $null }
  $ranked = $files | ForEach-Object {
    $s = Score-Tool $_
    if ($kind -eq 'generate') {
      if ($_.Name -match 'recover|restore|repair|recovery') { $s -= 50 }
      $s += 5
    } else {
      if ($_.Name -match 'recover|restore|repair|recovery|fix') { $s += 20 } else { $s -= 25 }
    }
    [pscustomobject]@{ File = $_; Score = $s }
  } | Sort-Object Score -Descending
  return $ranked[0].File
}
function Invoke-ScriptCapture([string]$scriptPath, [string]$workingDir) {
  Push-Location $workingDir
  try {
    $out = & $scriptPath 2>&1 | Out-String
    $ec = $LASTEXITCODE
    return [pscustomobject]@{ ExitCode = $ec; Output = $out }
  } finally {
    Pop-Location
  }
}
function Assert-Contains([string]$text, [string]$needle, [string]$label) {
  if ($text -notmatch [regex]::Escape($needle)) { throw "EVIDENCE_MISSING($label): '$needle' not found" }
}
$repoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$toolsDir = Join-Path $repoRoot 'tools'
if (-not (Test-Path -LiteralPath $toolsDir)) { throw "tools dir not found: $toolsDir" }
New-Dir $OutDir
$ts = (Get-Date).ToString('yyyyMMdd_HHmmss')
$handoffPath      = Join-Path $OutDir ("handoff_{0}.txt" -f $ts)
$corruptPath      = Join-Path $OutDir ("handoff_{0}.corrupt.txt" -f $ts)
$recoveredPath    = Join-Path $OutDir ("handoff_{0}.recovered.txt" -f $ts)
$regeneratedPath  = Join-Path $OutDir ("handoff_{0}.regenerated.txt" -f $ts)
$gen = Select-Tool $toolsDir 'generate'
$rec = Select-Tool $toolsDir 'recover'
if ($null -eq $gen) { throw 'No handoff generator script found under tools/ (*handoff*.ps1)' }
if ($null -eq $rec) { throw 'No handoff recovery script found under tools/ (*handoff*.ps1 with recover/restore/etc.)' }
Write-Host ("[OP2] generator: {0}" -f $gen.FullName)
Write-Host ("[OP2] recovery : {0}" -f $rec.FullName)
# 1) generate
$r1 = Invoke-ScriptCapture $gen.FullName $repoRoot
[System.IO.File]::WriteAllText($handoffPath, $r1.Output, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("[OP2] generated    : {0} (exit={1})" -f $handoffPath, $r1.ExitCode)
if ($r1.ExitCode -ne 0) { throw "GENERATOR_FAILED exit=$($r1.ExitCode)" }
# 2) corrupt（重要キーワードを意図的に破壊）
$lines = Get-Content -LiteralPath $handoffPath
if ($lines.Count -lt 5) { throw 'handoff output too short to corrupt safely' }
$lines2 = $lines | ForEach-Object {
  $_ -replace 'REPO_ORIGIN','REPO_ORIGXN' -replace 'HEAD（main）','HEAD(mainX)' -replace 'HEAD\(main\)','HEAD(mainX)'
}
$lines2 | Set-Content -LiteralPath $corruptPath -Encoding UTF8
Write-Host ("[OP2] corrupted     : {0}" -f $corruptPath)
# 3) recover（現行の復旧ツール仕様に依存するので、とりあえず “実行してログを取る”）
$r2 = Invoke-ScriptCapture $rec.FullName $repoRoot
[System.IO.File]::WriteAllText($recoveredPath, $r2.Output, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("[OP2] recovered(out): {0} (exit={1})" -f $recoveredPath, $r2.ExitCode)
# 4) re-generate（復旧後に生成が成立すること）
$r3 = Invoke-ScriptCapture $gen.FullName $repoRoot
[System.IO.File]::WriteAllText($regeneratedPath, $r3.Output, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("[OP2] regenerated  : {0} (exit={1})" -f $regeneratedPath, $r3.ExitCode)
if ($r3.ExitCode -ne 0) { throw "REGEN_FAILED exit=$($r3.ExitCode)" }
# 5) evidence check（最低限の固定キー）
Assert-Contains $r3.Output 'REPO_ORIGIN'    'KEY_REPO_ORIGIN'
Assert-Contains $r3.Output 'PARENT_BUNDLED' 'KEY_PARENT_BUNDLED'
Assert-Contains $r3.Output 'EVIDENCE_BUNDLE' 'KEY_EVIDENCE_BUNDLE'
Write-Host '[OP2] evidence check: OK'
exit 0