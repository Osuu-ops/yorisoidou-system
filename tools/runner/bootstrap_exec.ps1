param(
  [string]$PortfolioId = "UNSELECTED",
  [string]$Phase = "EXEC_BOOTSTRAP",
  [string]$NextItem = "CONTINUE",
  [string]$PrimaryAnchor = ""
)
if (-not (Test-Path ".git")) { Write-Error "Not inside repo root"; exit 1 }
$dirty = git status --porcelain
if ($dirty) { Write-Error "Working tree is dirty (EXEC bootstrap requires clean)"; exit 1 }
git fetch --prune origin
git switch main
git reset --hard origin/main
$sha = (git rev-parse HEAD).Trim()
function _TryPr([string]$state, [string]$commitSha) {
  try {
    $q = "$commitSha repo:Osuu-ops/yorisoidou-system"
    $u = (gh pr list -R Osuu-ops/yorisoidou-system --search $q --state $state --limit 1 --json url --jq '.[0].url' 2>$null).Trim()
    if ($u) { return ("PR:" + $u) }
  } catch { }
  return ""
}
function Get-PrimaryAnchor([string]$given, [string]$commitSha) {
  if ($given) { return $given }
  # 1) OPEN PR
  $u = _TryPr "open" $commitSha
  if ($u) { return $u }
  # 2) MERGED PR
  $u = _TryPr "merged" $commitSha
  if ($u) { return $u }
  # 3) COMMIT
  return ("COMMIT:" + $commitSha)
}
$PrimaryAnchor = Get-PrimaryAnchor $PrimaryAnchor $sha
Write-Host "PRIMARY_ANCHOR: $PrimaryAnchor"
$ledgerIn = python tools/runner/runner.py ledger-in `
  --parent-chat-id GENESIS `
  --portfolio-id $PortfolioId `
  --mode EXEC_MODE `
  --primary-anchor $PrimaryAnchor `
  --current-phase $Phase `
  --next-item $NextItem | ConvertFrom-Json
$thisChatId = $ledgerIn.this_chat_id
Write-Host "THIS_CHAT_ID: $thisChatId"
python tools/runner/runner.py ledger-out `
  --this-chat-id $thisChatId `
  --portfolio-id $PortfolioId `
  --mode EXEC_MODE `
  --primary-anchor $PrimaryAnchor `
  --current-phase $Phase `
  --next-item $NextItem
