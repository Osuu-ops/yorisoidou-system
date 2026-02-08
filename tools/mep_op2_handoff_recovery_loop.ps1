Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
param(
  [string]$RepoRoot = (git rev-parse --show-toplevel).Trim(),
  [string]$OutDir = (Join-Path (git rev-parse --show-toplevel).Trim() ".mep_op2_out"),
  [switch]$VerboseLog
)
function New-Dir([string]$Path) { if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Path $Path | Out-Null } }
function Score-Tool([System.IO.FileInfo]$fi) {
  $n = $fi.Name.ToLowerInvariant()
  $score = 0
  if ($n -match "handoff") { $score += 10 }
  if ($n -match "mep") { $score += 3 }
  if ($n -match "generate|gen|create|make") { $score += 6 }
  if ($n -match "recover|restore|repair|recovery|fix") { $score += 6 }
  if ($n -match "min") { $score += 2 }
  if ($n -match "auto|loop") { $score += 1 }
  return $score
}
function Select-Tool([string]$toolsDir, [string]$kind) {
  $files = Get-ChildItem -LiteralPath $toolsDir -File -Filter "*.ps1" | Where-Object { $_.Name -match "handoff" }
  if (-not $files) { return $null }
  $ranked = $files | ForEach-Object {
    $s = Score-Tool $_
    if ($kind -eq "generate") {
      if ($_.Name -match "recover|restore|repair|recovery") { $s -= 50 }
      if ($_.Name -match "handoff") { $s += 5 }
    } elseif ($kind -eq "recover") {
      if ($_.Name -match "recover|restore|repair|recovery|fix") { $s += 20 } else { $s -= 25 }
    }
    [pscustomobject]@{ File = $_; Score = $s }
  } | Sort-Object Score -Descending
  return $ranked[0].File
}
function Invoke-Tool([string]$path, [string[]]$args) {
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = (Get-Process -Id $PID).Path
  $psi.Arguments = @("-NoProfile","-ExecutionPolicy","Bypass","-File",("`"$path`"")) + $args | ForEach-Object { $_ } -join " "
  $psi.WorkingDirectory = (Split-Path -Parent $path)
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.UseShellExecute = $false
  $p = New-Object System.Diagnostics.Process
  $p.StartInfo = $psi
  [void]$p.Start()
  $stdout = $p.StandardOutput.ReadToEnd()
  $stderr = $p.StandardError.ReadToEnd()
  $p.WaitForExit()
  return [pscustomobject]@{ ExitCode=$p.ExitCode; Stdout=$stdout; Stderr=$stderr }
}
function Assert-Contains([string]$text, [string]$needle, [string]$label) {
  if ($text -notmatch [regex]::Escape($needle)) { throw "EVIDENCE_MISSING($label): '$needle' not found" }
}
$repoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$toolsDir = Join-Path $repoRoot "tools"
if (-not (Test-Path -LiteralPath $toolsDir)) { throw "tools dir not found: $toolsDir" }
New-Dir $OutDir
$ts = (Get-Date).ToString("yyyyMMdd_HHmmss")
$handoffPath = Join-Path $OutDir ("handoff_$ts.txt")
$gen = Select-Tool $toolsDir "generate"
$rec = Select-Tool $toolsDir "recover"
if ($null -eq $gen) { throw "No handoff generator script found under tools/ (*handoff*.ps1)" }
if ($null -eq $rec) { throw "No handoff recovery script found under tools/ (*handoff*.ps1 with recover/restore/etc.)" }
Write-Host ("[OP2] generator: {0}" -f $gen.FullName)
Write-Host ("[OP2] recovery : {0}" -f $rec.FullName)
# 1) generate
$r1 = Invoke-Tool $gen.FullName @()
$raw1 = ($r1.Stdout + "`n" + $r1.Stderr)
[System.IO.File]::WriteAllText($handoffPath, $raw1, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("[OP2] generated: {0} (exit={1})" -f $handoffPath, $r1.ExitCode)
if ($r1.ExitCode -ne 0) { throw "GENERATOR_FAILED exit=$($r1.ExitCode)" }
# 2) corrupt
$corruptPath = Join-Path $OutDir ("handoff_$ts.corrupt.txt")
$lines = Get-Content -LiteralPath $handoffPath
if ($lines.Count -lt 5) { throw "handoff output too short to corrupt safely" }
# 先頭付近の重要行を破壊（固定文字列置換）
$lines2 = $lines | ForEach-Object {
  $_ -replace "REPO_ORIGIN","REPO_ORIGXN" -replace "HEAD（main）","HEAD(mainX)"
}
$lines2 | Set-Content -LiteralPath $corruptPath -Encoding UTF8
Write-Host ("[OP2] corrupted: {0}" -f $corruptPath)
# 3) recover（復旧ツールが「入力を受け取らない」実装でも動くように、まず無引数）
$r2 = Invoke-Tool $rec.FullName @()
$raw2 = ($r2.Stdout + "`n" + $r2.Stderr)
$recoveredPath = Join-Path $OutDir ("handoff_$ts.recovered.txt")
[System.IO.File]::WriteAllText($recoveredPath, $raw2, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("[OP2] recovered(out): {0} (exit={1})" -f $recoveredPath, $r2.ExitCode)
# 4) re-generate（復旧後に生成が成立すること）
$r3 = Invoke-Tool $gen.FullName @()
$raw3 = ($r3.Stdout + "`n" + $r3.Stderr)
$regeneratedPath = Join-Path $OutDir ("handoff_$ts.regenerated.txt")
[System.IO.File]::WriteAllText($regeneratedPath, $raw3, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("[OP2] regenerated: {0} (exit={1})" -f $regeneratedPath, $r3.ExitCode)
if ($r3.ExitCode -ne 0) { throw "REGEN_FAILED exit=$($r3.ExitCode)" }
# 5) evidence check（最低限の固定キーが含まれる）
Assert-Contains $raw3 "REPO_ORIGIN" "KEY_REPO_ORIGIN"
Assert-Contains $raw3 "PARENT_BUNDLED" "KEY_PARENT_BUNDLED"
Assert-Contains $raw3 "EVIDENCE_BUNDLE" "KEY_EVIDENCE_BUNDLE"
Write-Host "[OP2] evidence check: OK"
exit 0