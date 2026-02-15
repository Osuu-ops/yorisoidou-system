param(

&nbsp;   \[Parameter(Mandatory=$true)]

&nbsp;   \[string]$DraftPath,



&nbsp;   \[string]$PortfolioId = "UNSELECTED",

&nbsp;   \[string]$Phase = "GENESIS\_BOOTSTRAP",

&nbsp;   \[string]$NextItem = "CONTINUE"

)



\# 1. ここがGitリポジトリか確認

if (-not (Test-Path ".git")) {

&nbsp;   Write-Error "Not inside repository root. cd into yorisoidou-system first."

&nbsp;   exit 1

}



\# 2. main同期

git fetch --prune origin

git checkout -f main

git reset --hard origin/main



\# 3. 草案存在確認

if (-not (Test-Path $DraftPath)) {

&nbsp;   Write-Error "Draft file not found: $DraftPath"

&nbsp;   exit 1

}



\# 4. commit

git add $DraftPath

git commit -m "draft: bootstrap snapshot" | Out-Null

$sha = git rev-parse HEAD



Write-Host "PRIMARY\_ANCHOR: COMMIT:$sha"



\# 5. ledger-in

$ledgerIn = python tools/runner/runner.py ledger-in `

&nbsp; --parent-chat-id GENESIS `

&nbsp; --portfolio-id $PortfolioId `

&nbsp; --mode DRAFT\_MODE `

&nbsp; --primary-anchor "COMMIT:$sha" `

&nbsp; --current-phase $Phase `

&nbsp; --next-item $NextItem | ConvertFrom-Json



$thisChatId = $ledgerIn.this\_chat\_id

Write-Host "THIS\_CHAT\_ID: $thisChatId"



\# 6. ledger-out

python tools/runner/runner.py ledger-out `

&nbsp; --this-chat-id $thisChatId `

&nbsp; --portfolio-id $PortfolioId `

&nbsp; --mode DRAFT\_MODE `

&nbsp; --primary-anchor "COMMIT:$sha" `

&nbsp; --current-phase $Phase `

&nbsp; --next-item $NextItem





