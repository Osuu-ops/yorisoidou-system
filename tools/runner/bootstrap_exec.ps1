param(
  [string]$PortfolioId = "UNSELECTED",
  [string]$Phase = "EXEC_BOOTSTRAP",
  [string]$NextItem = "CONTINUE",
  [string]$PrimaryAnchor = ""
)
# repo root前提（ここで実行）
if (-not (Test-Path ".git")) {
  Write-Error "Not inside repository root. cd into yorisoidou-system first."
  exit 1
}
# 実装系は「作業ツリー汚れ禁止」
$dirty = git status --porcelain
if ($dirty) {
  Write-Error "Working tree is dirty. Commit/stash first (EXEC bootstrap requires clean tree)."
  exit 1
}
# main同期（一次根拠は main HEAD を使う）
git fetch --prune origin
git switch main
git reset --hard origin/main
$sha = git rev-parse HEAD
if (-not $PrimaryAnchor) { $PrimaryAnchor = "COMMIT:$sha" }
Write-Host "PRIMARY_ANCHOR: $PrimaryAnchor"
# CHECKPOINT_IN
$ledgerIn = python tools/runner/runner.py ledger-in `
  --parent-chat-id GENESIS `
  --portfolio-id $PortfolioId `
  --mode EXEC_MODE `
  --primary-anchor $PrimaryAnchor `
  --current-phase $Phase `
  --next-item $NextItem | ConvertFrom-Json
$thisChatId = $ledgerIn.this_chat_id
Write-Host "THIS_CHAT_ID: $thisChatId"
# CHECKPOINT_OUT（runner が [MEP_BOOT] を出す）
python tools/runner/runner.py ledger-out `
  --this-chat-id $thisChatId `
  --portfolio-id $PortfolioId `
  --mode EXEC_MODE `
  --primary-anchor $PrimaryAnchor `
  --current-phase $Phase `
  --next-item $NextItem
