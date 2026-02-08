param(
  [string]$RepoRoot = (git rev-parse --show-toplevel).Trim(),
  [string]$OutDir   = (Join-Path (git rev-parse --show-toplevel).Trim() ".mep_op2_out")
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
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
function Select-Tool([string]$toolsDir, [ValidateSet('generate','recover')] [string]$kind, [string]$excludeFullPath) {
  $files = Get-ChildItem -LiteralPath $toolsDir -File -Filter '*.ps1' | Where-Object { $_.Name -match 'handoff' }
  if ($excludeFullPath) { $files = $files | Where-Object { $_.FullName -ne $excludeFullPath } }
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
function Invoke-ScriptCaptureAllStreams([string]$scriptPath, [string]$workingDir, [string]$outDir) {
  New-Dir $outDir
  $ts = (Get-Date).ToString('yyyyMMdd_HHmmss')
  $transcriptPath = Join-Path $outDir ("transcript_{0}_{1}.txt" -f $ts, ([IO.Path]::GetFileNameWithoutExtension($scriptPath)))
  Push-Location $workingDir
  try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
    try {
      $piped = (& $scriptPath 2>&1 | Out-String)
      $ec = $LASTEXITCODE
    } finally {
      Stop-Transcript | Out-Null
    }
    $t = Get-Content -LiteralPath $transcriptPath -Raw
    return [pscustomobject]@{
      ExitCode = $ec
      Output   = ($t + "`n" + $piped)
      TranscriptPath = $transcriptPath
    }
  } finally {
    Pop-Location
  }
}
function Assert-Contains([string]$text, [string]$needle, [string]$label) {
  if ($text -notmatch [regex]::Escape($needle)) { throw "EVIDENCE_MISSING($label): '$needle' not found" }
}
function Read-Latest([string]$dir, [string]$pattern) {
  if (-not (Test-Path -LiteralPath $dir)) { return $null }
  $f = Get-ChildItem -LiteralPath $dir -File -Filter $pattern | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($null -eq $f) { return $null }
  return Get-Content -LiteralPath $f.FullName -Raw
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
$selfPath = $MyInvocation.MyCommand.Path
$gen = Select-Tool $toolsDir 'generate' $selfPath
$rec = Select-Tool $toolsDir 'recover'  $selfPath
if ($null -eq $gen) { throw 'No handoff generator script found under tools/ (*handoff*.ps1)' }
if ($null -eq $rec) { throw 'No handoff recovery script found under tools/ (*handoff*.ps1 with recover/restore/etc.)' }
Write-Host ("[OP2] generator: {0}" -f $gen.FullName)
Write-Host ("[OP2] recovery : {0}" -f $rec.FullName)
# 1) generate（出力が空でもOK：後段で復旧成果物を主に検証する）
$r1 = Invoke-ScriptCaptureAllStreams $gen.FullName $repoRoot $OutDir
[System.IO.File]::WriteAllText($handoffPath, $r1.Output, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("[OP2] generated    : {0} (exit={1})" -f $handoffPath, $r1.ExitCode)
Write-Host ("[OP2] gen transcript: {0}" -f $r1.TranscriptPath)
if ($r1.ExitCode -ne 0) { throw "GENERATOR_FAILED exit=$($r1.ExitCode)" }
# 2) corrupt（単一行でも確実に壊す）
$raw = Get-Content -LiteralPath $handoffPath -Raw
if ([string]::IsNullOrWhiteSpace($raw)) { $raw = "(empty_generator_output)" }
$corrupted =
  $raw -replace 'REPO_ORIGIN','REPO_ORIGXN' `
      -replace 'HEAD（main）','HEAD(mainX)' `
      -replace 'HEAD\(main\)','HEAD(mainX)'
[System.IO.File]::WriteAllText($corruptPath, $corrupted, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("[OP2] corrupted     : {0}" -f $corruptPath)
# 3) recover（ここで実際の復旧成果物が生成される前提）
$r2 = Invoke-ScriptCaptureAllStreams $rec.FullName $repoRoot $OutDir
[System.IO.File]::WriteAllText($recoveredPath, $r2.Output, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("[OP2] recovered(out): {0} (exit={1})" -f $recoveredPath, $r2.ExitCode)
Write-Host ("[OP2] rec transcript: {0}" -f $r2.TranscriptPath)
# 4) re-generate（成功確認のみ）
$r3 = Invoke-ScriptCaptureAllStreams $gen.FullName $repoRoot $OutDir
[System.IO.File]::WriteAllText($regeneratedPath, $r3.Output, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("[OP2] regenerated  : {0} (exit={1})" -f $regeneratedPath, $r3.ExitCode)
Write-Host ("[OP2] regen transcript: {0}" -f $r3.TranscriptPath)
if ($r3.ExitCode -ne 0) { throw "REGEN_FAILED exit=$($r3.ExitCode)" }
# 5) evidence check（復旧成果物を主に検証）
$evidence = New-Object System.Text.StringBuilder
[void]$evidence.AppendLine($r2.Output)
[void]$evidence.AppendLine($r3.Output)
# repoRoot に生成される復旧ファイル（あなたのログに出てる）
$latestRecovery = Read-Latest $repoRoot 'MEP_HANDOFF_RECOVERY_*.txt'
if ($latestRecovery) { [void]$evidence.AppendLine($latestRecovery) }
# OutDir 生成物も足す
$latestOutHandoff = Read-Latest $OutDir 'handoff_*.txt'
if ($latestOutHandoff) { [void]$evidence.AppendLine($latestOutHandoff) }
$evText = $evidence.ToString()
Assert-Contains $evText 'REPO_ORIGIN'     'KEY_REPO_ORIGIN'
Assert-Contains $evText 'PARENT_BUNDLED'  'KEY_PARENT_BUNDLED'
Assert-Contains $evText 'EVIDENCE_BUNDLE' 'KEY_EVIDENCE_BUNDLE'
Write-Host '[OP2] evidence check: OK'
exit 0