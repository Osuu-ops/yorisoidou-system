

# --- MEP_ENTRY_ENV_EXPORT_BEGIN ---
try {
  # export progress contract to ENV in PARENT process (gates run in child processes; their env won't propagate)
  $ec = 0
  try { $ec = [int]$exitCode } catch { $ec = 0 }
  $env:MEP_AUTO_LOOP_EXIT = [string]$ec
  if (-not $env:MEP_SRC) { $env:MEP_SRC = "DRAFT" }
  if (-not $env:MEP_PRE) { $env:MEP_PRE = "OK" }
  $env:MEP_PROGRESS_EXIT = [string]$ec
  # gateMax/gateMap/stopGate/stopReason are owned by entry itself
  $gmax = -1
  try { $gmax = [int]$gateMax } catch { $gmax = -1 }
  if ($gmax -ge 0) {
    if ($ec -eq 0) { $env:MEP_PROGRESS_LABEL = ("G{0}/{0} ALL_DONE (exit=0)" -f $gmax) }
    else {
      $sr = if ($stopReason) { [string]$stopReason } else { "STOP" }
      $sg = -1
      try { $sg = [int]$stopGate } catch { $sg = -1 }
      if ($sg -ge 0) { $env:MEP_PROGRESS_LABEL = ("G{0}/{1} STOP {2} (exit={3})" -f $sg, $gmax, $sr, $ec) }
      else           { $env:MEP_PROGRESS_LABEL = ("G?/{0} STOP {1} (exit={2})" -f $gmax, $sr, $ec) }
    }
    if ($gateMap -is [hashtable]) {
      $all = New-Object System.Collections.Generic.List[string]
      $ok  = New-Object System.Collections.Generic.List[string]
      for ($i=0; $i -le $gmax; $i++) {
        $k = "G$($i)"
        $all.Add($k) | Out-Null
        if ($gateMap.ContainsKey($k) -and $gateMap[$k] -eq "OK") { $ok.Add($k) | Out-Null }
      }
      $env:MEP_GATES    = ($all -join ",")
      $env:MEP_GATES_OK = ($ok  -join ",")
    }
  }
  # reporter (must never break entry)
  $reporter = Join-Path $PSScriptRoot "mep_reporter.ps1"
  if (Test-Path -LiteralPath $reporter) { try { & $reporter -ExitCode $ec } catch {} }
} catch {}
# --- MEP_ENTRY_ENV_EXPORT_END ---


