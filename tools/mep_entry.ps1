    # --- MEP_ENTRY_ENV_INLINE_BEGIN ---

    # --- MEP_ENTRY_ENV_INLINE_BEGIN ---
    try {
      $env:MEP_AUTO_LOOP_EXIT = [string]$exitCode
      if (-not $env:MEP_SRC) { $env:MEP_SRC = "DRAFT" }
      if (-not $env:MEP_PRE) { $env:MEP_PRE = "OK" }
      $env:MEP_PROGRESS_EXIT = [string]$exitCode
      if ($gateMax -ge 0) {
        if ($exitCode -eq 0) { $env:MEP_PROGRESS_LABEL = ("G{0}/{0} ALL_DONE" -f $gateMax) }
        else { $sr = if ($stopReason) { $stopReason } else { "STOP" }; $env:MEP_PROGRESS_LABEL = ("G{0}/{1} STOP {2}" -f $stopGate, $gateMax, $sr) }
        $all = New-Object System.Collections.Generic.List[string]
        $ok  = New-Object System.Collections.Generic.List[string]
        for ($gi=0; $gi -le $gateMax; $gi++) {
          $k = "G$($gi)"
          $all.Add($k) | Out-Null
          if ($gateMap -and $gateMap.ContainsKey($k) -and $gateMap[$k] -eq "OK") { $ok.Add($k) | Out-Null }
        }
        $env:MEP_GATES    = ($all -join ",")
        $env:MEP_GATES_OK = ($ok  -join ",")
      }
      $reporter = Join-Path $PSScriptRoot "mep_reporter.ps1"
      if (Test-Path -LiteralPath $reporter) { & $reporter -ExitCode $exitCode }
    } catch {}
    # --- MEP_ENTRY_ENV_INLINE_END ---
    # --- MEP_ENTRY_ENV_INLINE_BEGIN ---
    try {
      # Publish ENV (inline, no function dependency)
      $env:MEP_AUTO_LOOP_EXIT = [string]$exitCode
      if (-not $env:MEP_SRC) { $env:MEP_SRC = "DRAFT" }
      if (-not $env:MEP_PRE) { $env:MEP_PRE = "OK" }
      $env:MEP_PROGRESS_EXIT = [string]$exitCode
      # Prefer fixed label style; if gateMax exists use it
      if ($gateMax -ge 0) {
        if ($exitCode -eq 0) { $env:MEP_PROGRESS_LABEL = ("G{0}/{0} ALL_DONE" -f $gateMax) }
        else { $env:MEP_PROGRESS_LABEL = ("G{0}/{1} STOP {2}" -f $stopGate, $gateMax, ($stopReason ?? "STOP")) }
        # gates list
        $all = New-Object System.Collections.Generic.List[string]
        $ok  = New-Object System.Collections.Generic.List[string]
        for ($gi=0; $gi -le $gateMax; $gi++) {
          $k = "G$($gi)"
          $all.Add($k) | Out-Null
          if ($gateMap -and $gateMap.ContainsKey($k) -and $gateMap[$k] -eq "OK") { $ok.Add($k) | Out-Null }
        }
        $env:MEP_GATES    = ($all -join ",")
        $env:MEP_GATES_OK = ($ok  -join ",")
      }
      # Call reporter
      $reporter = Join-Path $PSScriptRoot "mep_reporter.ps1"
      if (Test-Path -LiteralPath $reporter) { & $reporter -ExitCode $exitCode }
    } catch {}
    # --- MEP_ENTRY_ENV_INLINE_END ---


