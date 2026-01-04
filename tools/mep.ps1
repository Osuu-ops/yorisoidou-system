<#
MEP Entry (single command)
- If launched under Windows PowerShell 5.1 (Desktop), re-exec in pwsh and return.
Commands:
  status           : repo/branch/dirty + open PRs (base main)
  required-checks  : required check contexts on main
  chatpacket-diff  : regenerate chat packet and show diff
  verify           : status + required-checks + chatpacket-diff
Usage:
  pwsh .\tools\mep.ps1 verify
#>

param(
  [Parameter(Position=0)]
  [ValidateSet("status","required-checks","chatpacket-diff","verify","help")]
  [string] $Cmd = "verify"
)

$ErrorActionPreference = "Stop"

if ($PSVersionTable.PSEdition -ne "Core") {
  $pwshExe = Join-Path $env:ProgramFiles "PowerShell\7\pwsh.exe"
  if (-not (Test-Path $pwshExe)) { throw "pwsh not found: $pwshExe" }
  & $pwshExe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath @args
  return
}

function Get-Repo {
  $r = (gh repo view --json nameWithOwner -q .nameWithOwner)
  if (-not $r) { throw "gh repo view failed." }
  return $r
}

function Ensure-RepoRoot {
  if (-not (Test-Path ".git")) { throw "Run at repo root (where .git exists)." }
}

function Cmd-Status {
  Ensure-RepoRoot
  $repo = Get-Repo
  Write-Host ("Repo: {0}" -f $repo)
  $branch = (git rev-parse --abbrev-ref HEAD).Trim()
  Write-Host ("Branch: {0}" -f $branch)

  $dirty = git status --porcelain
  if ($dirty) { Write-Host "Working tree: DIRTY"; $dirty | Out-Host } else { Write-Host "Working tree: clean" }

  Write-Host "`nOpen PRs (base main):"
  gh pr list --repo $repo --state open --base main --limit 20
}

function Cmd-RequiredChecks {
  Ensure-RepoRoot
  $repo = Get-Repo
  $raw = gh api "repos/$repo/branches/main/protection/required_status_checks" 2>$null
  if (-not $raw) { Write-Host "(Could not read required_status_checks)"; return }
  $rsc = $raw | ConvertFrom-Json
  $ctx = @()
  if ($rsc.contexts) { $ctx = @($rsc.contexts) }
  elseif ($rsc.checks) { $ctx = @($rsc.checks | ForEach-Object { $_.context }) }
  Write-Host "Required checks (main):"
  $ctx | Sort-Object -Unique | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

function Cmd-ChatPacketDiff {
  Ensure-RepoRoot
  if (-not (Test-Path "docs/MEP/build_chat_packet.py")) { throw "Missing: docs/MEP/build_chat_packet.py" }
  if (-not (Test-Path "docs/MEP/CHAT_PACKET.md")) { throw "Missing: docs/MEP/CHAT_PACKET.md" }
  python docs/MEP/build_chat_packet.py | Out-Null
  $d = git diff --name-only -- docs/MEP/CHAT_PACKET.md
  if ($d) { Write-Host "NG: CHAT_PACKET.md differs."; git --no-pager diff -- docs/MEP/CHAT_PACKET.md; return }
  Write-Host "OK: CHAT_PACKET.md matches generator output."
}

function Cmd-Help { Get-Help -Detailed $PSCommandPath }

switch ($Cmd) {
  "status"          { Cmd-Status; break }
  "required-checks" { Cmd-RequiredChecks; break }
  "chatpacket-diff" { Cmd-ChatPacketDiff; break }
  "verify"          { Cmd-Status; Write-Host ""; Cmd-RequiredChecks; Write-Host ""; Cmd-ChatPacketDiff; break }
  "help"            { Cmd-Help; break }
}
