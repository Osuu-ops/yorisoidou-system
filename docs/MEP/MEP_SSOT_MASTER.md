# PowerShellは @' '@（シングルクォートHere-String）前提 / 1ブロック完結 / プレースホルダ無し
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"

function Sec([string]$t){ Write-Host ""; Write-Host ("="*96); Write-Host $t; Write-Host ("="*96) }
function Cmd([string]$label,[scriptblock]$sb){ Write-Host ""; Write-Host ("--- {0}" -f $label); & $sb }

Sec "0) repo / main 同期 / clean 強制"
$repoRoot = (& git rev-parse --show-toplevel 2>$null)
if(-not $repoRoot){ throw "Gitリポジトリで実行してください（git rev-parse失敗）。" }
Set-Location -LiteralPath $repoRoot

Cmd "fetch + sync main" { git fetch --prune --tags origin; git checkout -q main; git pull --ff-only origin main }

$porc = (git status --porcelain)
if($porc){
  Sec "0.1) dirty 検出 → stash（untracked含む）"
  Cmd "stash" { git stash push -u -m ("AUTO_STASH_SSOT_{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss")) }
  Cmd "status after stash" { git status --porcelain }
}

Sec "1) 正本（クリップボード）を docs/MEP/MEP_SSOT_MASTER.md に配置"
$ssot = Get-Clipboard -Raw
if([string]::IsNullOrWhiteSpace($ssot)){ throw "クリップボードが空です。貼った正本をそのままコピーしてから再実行してください。" }

# 最低限の識別（省略ゼロ前提の正本ヘッダを確認）
if($ssot -notmatch '(?m)^\s*#\s*MEP_SSOT_MASTER'){
  throw "正本ヘッダ '# MEP_SSOT_MASTER' が見つかりません。別テキストを掴んでいる可能性があります。"
}
if($ssot -notmatch '(?m)^\s*#\s*PART A:\s*DECISION_LEDGER'){
  throw "PART A（決定台帳）が見つかりません。正本の全体をコピーした状態で再実行してください。"
}

$dstDir = Join-Path $repoRoot "docs\MEP"
$dstPath = Join-Path $dstDir "MEP_SSOT_MASTER.md"
New-Item -ItemType Directory -Force -Path $dstDir | Out-Null

# UTF8(BOMなし)で書き込み
[System.IO.File]::WriteAllText($dstPath, $ssot, [System.Text.UTF8Encoding]::new($false))

Cmd "verify written file head" {
  "DST=$dstPath"
  (Get-Content -LiteralPath $dstPath -Encoding UTF8 | Select-Object -First 25) -join "`n"
}

Sec "2) commit / push / PR"
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$branch = "feat/ssot-master-v1_12_$ts"

Cmd "create branch" { git checkout -q -b $branch }
Cmd "git add" { git add -- $dstPath }
Cmd "git diff --cached" { git diff --cached --stat; git diff --cached }

$commitMsg = "docs(ssot): add MEP_SSOT_MASTER v1.12 (single source of truth)"
Cmd "commit" { git commit -m $commitMsg }
Cmd "push" { git push -u origin $branch }

$body = @"
Add single canonical SSOT master file (MEP_SSOT_MASTER v1.12).

- Source of truth: docs/MEP/MEP_SSOT_MASTER.md
- Contains: Decision Ledger (Q1..Q169) + Operation Input Device (IDEA_NOTE schema)
- Append-only / supersedes rules / derived artifacts policy are defined in-file.
"@

Sec "3) PR create（URLを必ず表示）"
Cmd "gh pr create" {
  gh pr create --base main --head $branch --title "docs: add MEP_SSOT_MASTER v1.12" --body $body 2>&1
}

Sec "4) 次（自動ループへ接続する前提を整える）"
Write-Host "次は main に merge 後、mep_entry / Gate群がこの正本から EXTRACT_LEDGER/EXTRACT_INPUT を生成できるように接続します。"
Write-Host "（あなたのログ上の G2 停止は 'Approval required (MEP_APPROVE=0)' なので、続行は env 供給で前進できます。）"
