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
function Get-PrimaryAnchor([string]$given, [string]$commitSha) {
  if ($given) { return $given }
  # 1) PR検索（commit sha を GitHub search で拾う。squashでも拾える）
  try {
    $q = "$commitSha repo:Osuu-ops/yorisoidou-system"
    $prUrl = (gh pr list -R Osuu-ops/yorisoidou-system --search $q --state merged --limit 1 --json url --jq '.[0].url' 2>$null).Trim()
    if ($prUrl) { return ("PR:" + $prUrl) }
  } catch { }
  # 2) フォールバック
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
