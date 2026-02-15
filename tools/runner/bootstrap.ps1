param(
    [Parameter(Mandatory=$true)]
    [string]$DraftPath,

    [string]$PortfolioId = "UNSELECTED",
    [string]$Phase = "GENESIS_BOOTSTRAP",
    [string]$NextItem = "CONTINUE"
)

# 1. ここがGitリポジトリか確認
if (-not (Test-Path ".git")) {
    Write-Error "Not inside repository root. cd into yorisoidou-system first."
    exit 1
}

# 2. main同期
git fetch --prune origin
git checkout -f main
git reset --hard origin/main

# 3. 草案存在確認
if (-not (Test-Path $DraftPath)) {
    Write-Error "Draft file not found: $DraftPath"
    exit 1
}

# 4. commit
git add $DraftPath
git commit -m "draft: bootstrap snapshot" | Out-Null
$sha = git rev-parse HEAD

Write-Host "PRIMARY_ANCHOR: COMMIT:$sha"

# 5. ledger-in
$ledgerIn = python tools/runner/runner.py ledger-in `
  --parent-chat-id GENESIS `
  --portfolio-id $PortfolioId `
  --mode DRAFT_MODE `
  --primary-anchor "COMMIT:$sha" `
  --current-phase $Phase `
  --next-item $NextItem | ConvertFrom-Json

$thisChatId = $ledgerIn.this_chat_id
Write-Host "THIS_CHAT_ID: $thisChatId"

# 6. ledger-out
python tools/runner/runner.py ledger-out `
  --this-chat-id $thisChatId `
  --portfolio-id $PortfolioId `
  --mode DRAFT_MODE `
  --primary-anchor "COMMIT:$sha" `
  --current-phase $Phase `
  --next-item $NextItem

