# IDEA_VAULT（アイデア避難所） v1.0

本書は、チャット引っ越し・並走・汚染の中でも「アイデアが散逸しない」ための最小避難所である。

## 方針（固定）
- アイデア集のID管理は “必須ではない”。
- ただし、業務側（BUSINESS）を作り始めると例外・分岐が増えて散逸コストが増えるため、IDEA_VAULT（1ファイル避難所）は早めに置く。
- ID化は “採用候補だけ” に限定する（雑談アイデアを全部ID化しない）。

## 使い方（最小）
- 追記するだけ。削除・全文置換は避ける（TIG事故防止）。
- 採用候補になったら、該当見出しに `IDEA_ID: IDEA:<short>` を付与して扱う（後付けでOK）。

---

## アイデア一覧

### IDEA-000（テンプレ）
- STATUS: draft
- TAGS: 
- SOURCE:
- BODY:


## ACTIVE（現役：引っ張り出し対象）

### IDEA_ID: IDEA:e61113b095cb
- TITLE: (captured)
- DESC: & {
- STATUS: candidate
- TAGS:
- SOURCE: chat -> clipboard capture
- BODY:
  - & {
  -   $ErrorActionPreference = "Stop"
  -   # ===== IDEA CAPTURE (PS5.1 SAFE / ONE-PASTE) =====
  -   if (-not (Test-Path ".git")) { throw "Run at repo root (where .git exists)." }
  -   $repo = (gh repo view --json nameWithOwner -q .nameWithOwner)
  -   # Keep repo clean (optional but safer)
  -   git checkout main | Out-Null
  -   git pull --ff-only | Out-Null
  -   if (git status --porcelain) { git status; throw "DIRTY: working tree not clean" }
  -   $capture = Join-Path (Get-Location) "tools\mep_idea_capture.ps1"
  -   $list    = Join-Path (Get-Location) "tools\mep_idea_list.ps1"
  -   if (-not (Test-Path $capture)) { throw ("Missing: {0}" -f $capture) }
  -   # Prefer clipboard; fallback to prompt
  -   $idea = $null
  -   try { $idea = Get-Clipboard -Raw } catch { $idea = $null }
  -   if ([string]::IsNullOrWhiteSpace($idea)) {
  -     $idea = Read-Host "追加したいアイデアを1件（そのまま貼る）"
  -   }
  -   if ($null -eq $idea) { $idea = "" }
  -   $idea = ($idea.ToString()).Trim()
  -   if ([string]::IsNullOrWhiteSpace($idea)) { throw "Idea is empty. Stop." }
  -   ""
  -   "===== IDEA (captured text) ====="
  -   $idea
  -   # Introspect parameters to call safely (no placeholders)
  -   $cmd  = Get-Command -Name $capture -ErrorAction Stop
  -   $keys = @($cmd.Parameters.Keys)
  -   $picked = $null
  -   foreach ($c in @("Text","Idea","Content","Message","Body","Input","Raw","Note")) {
  -     if ($keys -contains $c) { $picked = $c; break }
  -   }
  -   ""
  -   "===== RUN: mep_idea_capture ====="
  -   if ($picked) {
  -     $splat = @{}
  -     $splat[$picked] = $idea
  -     & $capture @splat
  -   } else {
  -     # positional first; if script expects env var, also set it
  -     $env:MEP_IDEA_TEXT = $idea
  -     try {
  -       & $capture $idea
  -     } catch {
  -       & $capture
  -     }
  -   }
  -   ""
  -   if (Test-Path $list) {
  -     "===== IDEA LIST (after capture) ====="
  -     & $list
  -   } else {
  -     ("INFO: not found: {0}" -f $list)
  -   }
  -   "DONE: idea captured."
  - }


### IDEA_ID: IDEA:1c4d4e1a7f30
- TITLE: (captured)
- DESC: .\tools\mep_idea_capture.ps1
- STATUS: candidate
- TAGS:
- SOURCE: chat -> clipboard capture
- BODY:
  - .\tools\mep_idea_capture.ps1



## ARCHIVE（退避：引っ張り出し済み）
（空）


## 運用（固定）
- アイデアは都度「まとめ」→ capture で ACTIVE に吸い上げる。
- 統合で pick したアイデアは ACTIVE から削除する（溜め込まない）。
- ARCHIVEは原則使わない（証跡は Git のコミット履歴に残る）。




