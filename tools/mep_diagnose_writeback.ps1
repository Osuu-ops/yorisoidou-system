[CmdletBinding()]
param(
  [int]$PrNumber = 0,
  [string]$Repo = "Osuu-ops/yorisoidou-system",
  [string]$WorkflowFile = "mep_writeback_bundle_dispatch.yml",
  [string]$Ref = "main",
  [int]$TimeoutSec = 900,
  [int]$PollSec = 5,
  [switch]$Dispatch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Require-Cmd([string]$name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) { throw "Required command not found: $name" }
}
function Ensure-GhAuth {
  $s = (gh auth status 2>&1 | Out-String)
  if ($LASTEXITCODE -ne 0) { throw "gh auth status failed" }
  if ($s -notmatch "Logged in") { throw "gh is not authenticated" }
}

Require-Cmd "gh"; Require-Cmd "git"; Ensure-GhAuth

# 既定：dispatchしない（PR量産を防ぐ）
if ($Dispatch) {
  Write-Host "=== DISPATCH (explicit) ==="
  Write-Host "repo=$Repo workflow=$WorkflowFile ref=$Ref pr_number=$PrNumber"
  & gh workflow run $WorkflowFile -R $Repo --ref $Ref -f pr_number=$PrNumber | Out-Host

  $runId = (& gh run list -R $Repo --workflow $WorkflowFile -L 1 --json databaseId --jq '.[0].databaseId' 2>&1 | Out-String).Trim()
  if (-not $runId) { throw "Failed to get latest run databaseId" }
  Write-Host "latest_run_databaseId=$runId"

  $deadline = (Get-Date).AddSeconds($TimeoutSec)
  while ($true) {
    $statusJson = (& gh run view $runId -R $Repo --json status,conclusion,startedAt,updatedAt,headSha,url --jq '{status:.status,conclusion:.conclusion,startedAt:.startedAt,updatedAt:.updatedAt,headSha:.headSha,url:.url}' 2>&1 | Out-String)
    $obj = $null; try { $obj = $statusJson | ConvertFrom-Json } catch { }
    if ($obj -and $obj.status -notin @("in_progress","queued")) {
      Write-Host "=== RUN RESULT ==="
      $statusJson.Trim() | Write-Host
      break
    }
    if ((Get-Date) -gt $deadline) { throw "Timeout waiting run completion. runId=$runId" }
    Start-Sleep -Seconds $PollSec
  }

  Write-Host "=== RUN LOG (tail 200) ==="
  $log = (& gh run view $runId -R $Repo --log 2>&1 | Out-String)
  ($log -split "`r?`n" | Select-Object -Last 200) -join "`n" | Write-Host
} else {
  Write-Host "=== DIAGNOSE ONLY (no dispatch) ==="
  Write-Host "Dispatch is disabled. Reading latest Bundled only."
  git fetch origin $Ref | Out-Host
}

# 共通：Bundled差分/PR行抽出（dispatch有無に関わらず実施）
Write-Host "=== BUNDLED DIFF (origin/$Ref) ==="
$bundledPath = "docs/MEP/MEP_BUNDLE.md"
git diff --name-only HEAD..origin/$Ref -- $bundledPath | Out-Host
git diff HEAD..origin/$Ref -- $bundledPath | Out-Host

Write-Host "=== BUNDLED PR LINE (origin/$Ref) ==="
$blob = (git show ("origin/{0}:{1}" -f $Ref, $bundledPath) 2>$null)
if (-not $blob) { throw "Failed to read $bundledPath from origin/$Ref" }
$lines = $blob -split "`r?`n"
if ($PrNumber -eq 0) {
  ($lines | Where-Object { $_ -like "*PR #*" } | Select-Object -Last 5) | ForEach-Object { $_ } | Write-Host
} else {
  ($lines | Where-Object { $_ -like ("*PR #{0} |*" -f $PrNumber) }) | ForEach-Object { $_ } | Write-Host
}

Write-Host "=== DONE ==="
