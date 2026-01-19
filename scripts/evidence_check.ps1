param(
  [string]$Path = "docs/MEP/MEP_BUNDLE.md",
  [string]$LogPath = $null
)

$ErrorActionPreference = "Stop"
$rc = 0

if ([string]::IsNullOrWhiteSpace($LogPath)) {
  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $LogPath = Join-Path (Get-Location) ("evidence_check.{0}.log" -f $stamp)
}

function SafeLog([string]$m) {
  try {
    $ts = (Get-Date).ToString("s")
    Add-Content -LiteralPath $LogPath -Value ("[{0}] {1}" -f $ts, $m) -Encoding UTF8
  } catch { }
}

try {
  SafeLog "== start =="
  SafeLog ("PSVersion: {0}" -f $PSVersionTable.PSVersion)
  SafeLog ("Path: {0}" -f $Path)
  SafeLog ("LogPath: {0}" -f $LogPath)

  if (-not (Test-Path -LiteralPath $Path)) {
    $msg = "VIOLATION: file not found: {0}" -f $Path
    SafeLog $msg
    Write-Output "Evidence Log FAIL"
    Write-Output $msg
    $rc = 2
  }
  else {
    $lines = Get-Content -LiteralPath $Path -ErrorAction Stop

    # 対象範囲：### 証跡ログ（自動貼り戻し） の直下にある "- PR #" 行だけ
    $in = $false
    $targets = New-Object System.Collections.Generic.List[object]

    for ($i = 0; $i -lt $lines.Count; $i++) {
      $line = $lines[$i]

      if (-not $in) {
        if ($line -match '^\s*###\s+証跡ログ（自動貼り戻し）\s*$') {
          $in = $true
        }
        continue
      }

      # 終了条件：証跡ログの並びが終わったら抜ける（次の非PR行に到達）
      if ($line -match '^\s*-\s*PR\s+#') {
        $targets.Add([pscustomobject]@{ LineNo = ($i + 1); Text = $line })
        continue
      }

      if ($line.Trim().Length -eq 0) { continue } # 空行は許容
      break
    }

    if ($targets.Count -eq 0) {
      $msg = "VIOLATION: evidence log lines not found under heading: ### 証跡ログ（自動貼り戻し）"
      Write-Output "Evidence Log FAIL"
      Write-Output $msg
      SafeLog $msg
      $rc = 3
    }
    else {
      $fail = $false

      foreach ($t in $targets) {
        $lineNo = $t.LineNo
        $line   = $t.Text

        # 1) PR #@{ must not exist（証跡ログ行のみ）
        if ($line -match 'PR #@\{') {
          $msg = "VIOLATION: found 'PR #@{{' at L{0}: {1}" -f $lineNo, $line
          Write-Output $msg
          SafeLog $msg
          $fail = $true
        }

        # 2) mergedAt= must be non-empty
        if ($line -like '*mergedAt=*' -and $line -notmatch 'mergedAt=\S+') {
          $msg = "VIOLATION: empty mergedAt at L{0}: {1}" -f $lineNo, $line
          Write-Output $msg
          SafeLog $msg
          $fail = $true
        }

        # 3) mergeCommit= must be non-empty
        if ($line -like '*mergeCommit=*' -and $line -notmatch 'mergeCommit=\S+') {
          $msg = "VIOLATION: empty mergeCommit at L{0}: {1}" -f $lineNo, $line
          Write-Output $msg
          SafeLog $msg
          $fail = $true
        }
      }

      if (-not $fail) {
        Write-Output "Evidence Log PASS"
        SafeLog "Evidence Log PASS"
        $rc = 0
      } else {
        Write-Output "Evidence Log FAIL"
        SafeLog "Evidence Log FAIL"
        $rc = 1
      }
    }
  }
}
catch {
  $msg = "VIOLATION: exception: {0}" -f $_.Exception.Message
  SafeLog $msg
  SafeLog $_.ScriptStackTrace
  Write-Output "Evidence Log FAIL"
  Write-Output $msg
  $rc = 99
}

SafeLog "== end =="
Write-Output ("LOGFILE: {0}" -f $LogPath)
exit $rc
