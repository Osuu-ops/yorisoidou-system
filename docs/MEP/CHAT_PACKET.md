# Single-copy block — apply CHAT_PACKET from clipboard (or ./CHAT_PACKET.input) and run tools\mep_handoff.ps1
# Default: no push/PR. To enable push+PR set $DoPush = $true and re-run this block.
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Abort([string]$msg){ Write-Error $msg; exit 1 }

# Config: enable push+PR only if you explicitly set $DoPush = $true
$DoPush = $false

# 1) locate repo top
try { $RepoTop = (& git rev-parse --show-toplevel 2>$null).Trim() } catch { $RepoTop = $null }
if (-not $RepoTop) { Abort "Not inside a git repository. Run this from the repository root." }
Set-Location $RepoTop
Write-Host "[INFO] Repo top: $RepoTop"

# 2) ensure pwsh (best-effort): prefer pwsh; if not, continue but warn
try {
    $pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue)
    if ($pwsh) { Write-Host "[INFO] pwsh available." } else { Write-Warning "pwsh not found; continuing with current PowerShell. Recommended: run with PowerShell 7 (pwsh)." }
} catch { Write-Warning "pwsh detection failed: $_" }

# 3) current branch & working tree
$CurrentBranch = (& git branch --show-current 2>$null).Trim()
if (-not $CurrentBranch) { $CurrentBranch = "(detached/unknown)"; Write-Host "[INFO] Current branch appears detached or unknown." } else { Write-Host "[INFO] Current branch: $CurrentBranch" }

$porcelain = (& git status --porcelain)
if ($porcelain) {
    Write-Host "[INFO] Working tree has uncommitted changes. Creating WIP branch and committing locally..."
    $ts = (Get-Date).ToString("yyyyMMdd-HHmmss")
    $gitUser = (& git config user.name) -join "" 
    if (-not $gitUser) { $gitUser = $env:USERNAME }
    $wipBranch = "wip/auto-save-before-handoff-$ts"

    try {
        (& git switch -c $wipBranch) | ForEach-Object { Write-Host "  $_" }
        (& git add -A) | Out-Null
        $commitMsg = "WIP: auto-save before mep_handoff (from $CurrentBranch) by $gitUser at $ts"
        (& git commit -m $commitMsg) | ForEach-Object { Write-Host "  $_" }
        Write-Host "[INFO] Uncommitted changes saved to local branch: $wipBranch"
    } catch {
        Write-Warning "Failed creating WIP commit: $_"
        try { (& git switch $CurrentBranch) } catch {}
        Abort "Aborting due to WIP commit failure."
    }
} else {
    Write-Host "[INFO] Working tree clean; continuing on branch: $CurrentBranch"
}

# 4) obtain CHAT_PACKET text — prefer clipboard, fallback to ./CHAT_PACKET.input
$chatText = $null
try {
    $chatText = Get-Clipboard -Raw -ErrorAction Stop
    if ($null -eq $chatText -or $chatText.Trim().Length -lt 80) { $chatText = $null; Write-Host "[WARN] Clipboard empty or too short; will fallback to file ./CHAT_PACKET.input if present." }
} catch {
    Write-Host "[WARN] Get-Clipboard failed or not available; will fallback to file ./CHAT_PACKET.input if present."
    $chatText = $null
}

if (-not $chatText) {
    $inputFile = Join-Path $RepoTop "CHAT_PACKET.input"
    if (Test-Path $inputFile) {
        Write-Host "[INFO] Reading CHAT_PACKET from file: $inputFile"
        try { $chatText = Get-Content -Raw -Encoding UTF8 $inputFile } catch { Abort "Failed to read CHAT_PACKET.input: $_" }
    } else {
        Write-Host "[ERROR] No CHAT_PACKET found in clipboard and ./CHAT_PACKET.input not present."
        Write-Host "[ACTION] Please: (A) select the CHAT_PACKET text in this chat and press Ctrl+C, then re-run this block, OR (B) save the CHAT_PACKET to ./CHAT_PACKET.input and re-run."
        Abort "CHAT_PACKET not supplied."
    }
}

if ($chatText.Length -lt 80) { Abort "CHAT_PACKET appears too short (<80 chars). Aborting." }

# 5) write to docs/MEP/CHAT_PACKET.md (ensure directory)
$targetRel = "docs/MEP/CHAT_PACKET.md"
$targetPath = Join-Path $RepoTop $targetRel
$targetDir = Split-Path $targetPath -Parent
if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null; Write-Host "[INFO] Created directory: $targetDir" }

# backup existing file if present
if (Test-Path $targetPath) {
    $bakTs = (Get-Date).ToString("yyyyMMdd-HHmmss")
    $bakPath = "$targetPath.bak.$bakTs"
    Copy-Item -Path $targetPath -Destination $bakPath -Force
    Write-Host "[INFO] Existing CHAT_PACKET backed up to: $bakPath"
}

# write file (UTF8 no BOM)
try {
    Set-Content -Path $targetPath -Value $chatText -Encoding UTF8
    Write-Host "[INFO] Wrote CHAT_PACKET to: $targetRel"
} catch {
    Abort "Failed to write CHAT_PACKET: $_"
}

# 6) git add & commit if changed
try {
    (& git add -- $targetRel) | Out-Null
    $statusBefore = (& git status --porcelain)
    # attempt commit; if no change, commit will exit non-zero but we catch
    try {
        (& git commit -m "chore(mep): update CHAT_PACKET via handoff script") | ForEach-Object { Write-Host "  $_" }
        Write-Host "[INFO] Committed CHAT_PACKET update locally."
    } catch {
        Write-Host "[INFO] No commit necessary (file identical or no staged changes)."
    }
} catch {
    Write-Warning "Git add/commit step failed: $_"
    Abort "Failed to stage/commit CHAT_PACKET."
}

# 7) run tools\mep_handoff.ps1 (non-destructive)
$handoffScript = Join-Path $RepoTop "tools\mep_handoff.ps1"
if (-not (Test-Path $handoffScript)) { Abort "mep_handoff.ps1 not found at tools\\mep_handoff.ps1" }

Write-Host "`n[INFO] Running mep_handoff.ps1 (non-destructive) ...`n"
try {
    & $handoffScript
    Write-Host "`n[INFO] mep_handoff.ps1 completed successfully (or returned no error)."
} catch {
    Write-Warning "mep_handoff.ps1 failed or returned error: $_"
    Write-Host "`n[NOTE] The CHAT_PACKET change is committed locally. Inspect the branch and logs; you can push manually if desired."
    # continue — do not abort here
}

# 8) optional: push & create PR if $DoPush - true (explicit opt-in)
if ($DoPush) {
    Write-Host "`n[INFO] Push/PR mode enabled; attempting push + PR creation..."
    try {
        $repo = (& gh repo view --json nameWithOwner -q .nameWithOwner 2>$null).Trim()
        if (-not $repo) { throw "gh repo view failed or gh not authenticated. Run 'gh auth login'." }
        $currentHead = (& git rev-parse --abbrev-ref HEAD).Trim()
        if (-not $currentHead) { throw "Cannot determine current HEAD branch name." }

        Write-Host "  Pushing branch $currentHead -> origin/$currentHead"
        (& git push -u origin $currentHead) | ForEach-Object { Write-Host "  $_" }

        $prTitle = "Recovery: apply CHAT_PACKET update ($currentHead)"
        $prBody = "Applied CHAT_PACKET via handoff script. Please review docs/MEP/CHAT_PACKET.md and related artifacts."
        Write-Host "  Creating PR: $prTitle"
        (& gh pr create --repo $repo --base main --head $currentHead --title $prTitle --body $prBody) | ForEach-Object { Write-Host "  $_" }

        Write-Host "[INFO] Push and PR creation attempted."
    } catch {
        Write-Warning "Push/PR step failed: $_"
        Write-Host "[NOTE] You may push the branch manually: git push -u origin HEAD"
    }
} else {
    Write-Host "`n[INFO] Push/PR step skipped (set `$DoPush = $true` at top of block to enable)."
}

# 9) post-run guidance (idempotent)
Write-Host "`n=== NEXT STEPS ==="
Write-Host "1) Inspect recent commits: git log -n 5 --pretty=oneline"
Write-Host "2) If you wish to push current branch: git push -u origin HEAD"
Write-Host "3) To create PR manually: gh pr create --base main --head HEAD --title 'Recovery: CHAT_PACKET update' --body 'Applied CHAT_PACKET via handoff script.'"
Write-Host "`n=== INSPECTION COMPLETE ==="
exit 0


## 運用ルール（採用済み）
受領しました。ここからは、あなたが冒頭に固定した運用ルールに従います（Decision Gate厳守／採用宣言まで実行可能コード提示禁止、FAST_LOOP_* 以外でコマンド提示禁止）。

### 確定：現在地（事実）
- チャット種別：Aチャット（MEP/GAS運用の続き）
- GAS：B22（固定URLの /exec を clasp redeploy で高速ループ可能）
  - deploymentId：AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw
  - /exec：https://script.google.com/macros/s/AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw/exec
- GitHub：open PR = 0

### トリガー仕様（最優先）
- `FAST_LOOP_GAS`（単独行で送信） → 返答は**単一の PowerShell 1 ブロックのみ**（内容：push→create-version→redeploy→GET検証）。  
- `FAST_LOOP_GH`（単独行で送信） → 返答は**単一の PowerShell 1 ブロックのみ**（内容：openPR=0 収束の自動化）。  
- それ以外の要求・提案は **Decision Gate** による採用宣言があるまで **実行可能なコード／コマンドを提示しない**。

### STATE_CURRENT 記録ルール（必須）
- 例外運用を行ったら必ず1行で記録（ISO日時／実行者／トリガー／要約／scriptId／deploymentId／version／理由／結果）。例：  
  `- 2026-01-06T10:59:41+09:00 (A:yorisoidoupdf) FAST_LOOP_GAS: redeploy→verify; scriptId=1wpU...; deploymentId=AKfy...; ver=16; reason="hotfix/ops"; result="OK:version match"`

### 検証基準（redeploy 後 GET）
- 合格判定：`res.ok === true` AND `res.version === expected`（expected は src\コード.js の CFG.VERSION）  
- 失敗時：自動ロールバック（直近安定 ver）→通知（Slack/Email/Runbook 担当）→STATE_CURRENT に失敗ログ記録。

### セーフティとガバナンス
- autopilot による自動マージは **required checks を迂回しないこと**。自動化が失敗した場合の通知先と担当を RUNBOOK に明記すること。  
- 例外運用を起こせる者は限定（Ops Lead, Owner 等）し、その権限を RUNBOOK に記載。

---- 
(追記日時: 2026-01-06T23:16:38+09:00 / actor: Osuu-ops)


## 運用ルール（採用済み）
受領しました。ここからは、あなたが冒頭に固定した運用ルールに従います（Decision Gate厳守／採用宣言まで実行可能コード提示禁止、FAST_LOOP_* 以外でコマンド提示禁止）。

### 確定：現在地（事実）
- チャット種別：Aチャット（MEP/GAS運用の続き）
- GAS：B22（固定URLの /exec を clasp redeploy で高速ループ可能）
  - deploymentId：' + $deploymentId + '
  - /exec：' + $execUrl + '
- GitHub：open PR = 0

### トリガー仕様（最優先）
- `FAST_LOOP_GAS`（単独行で送信） → 返答は**単一の PowerShell 1 ブロックのみ**（内容：push→create-version→redeploy→GET検証）。
- `FAST_LOOP_GH`（単独行で送信） → 返答は**単一の PowerShell 1 ブロックのみ**（内容：openPR=0 収束の自動化）。
- それ以外の要求・提案は **Decision Gate** による採用宣言があるまで **実行可能なコード／コマンドを提示しない**。

### STATE_CURRENT 記録ルール（必須）
- 例外運用を行ったら必ず1行で記録（ISO日時／実行者／トリガー／要約／scriptId／deploymentId／version／理由／結果）。例：
  `- 2026-01-06T10:59:41+09:00 (A:actor) FAST_LOOP_GAS: redeploy→verify; scriptId=...; deploymentId=...; ver=16; reason="hotfix/ops"; result="OK:version match"`

### 検証基準（redeploy 後 GET）
- 合格判定：`res.ok === true` AND `res.version === expected`（expected は src\コード.js の CFG.VERSION）
- 失敗時：自動ロールバック（直近安定 ver）→通知（Slack/Email/Runbook 担当）→STATE_CURRENT に失敗ログ記録。

### セーフティとガバナンス
- autopilot による自動マージは required checks を迂回しないこと。自動化が失敗した場合の通知先と担当を RUNBOOK に明記すること。
- 例外運用を起こせる者は限定（Ops Lead, Owner 等）し、その権限を RUNBOOK に記載。

----
(追記日時: ' + $now + ' / actor: ' + $actor + ')

