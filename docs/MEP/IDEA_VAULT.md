# IDEA_VAULT・医ぁE���E�繝�EぁE��ｿ髮�E�謁E�・・v1.0

譛ｬ譖ｸ縺�E�縲√メ繝｣繝�Eヨ蠑輔▲雜翫�E�繝ｻ荳�E�襍ｰ繝ｻ豎壽沒縺�E�荳�E�縺�E�繧めE�後い繧�E�繝�EぁE��梧淵騾�E�縺励↑縺・阪◁E��√�E譛蟁E��∩髮�E�謁E�縺�E�縺めE��縲・
## 譁E��驥晢�E�亥崋螳夲�E�・- 繧�E�繧�E�繝�EぁE��・・ID邂｡送E�E・ 窶懷�E�・�E�医〒縺�E�縺�E�縺・昴・- 縺溘□縺励∵�E��E�蜍吝・・・USINESS・峨�E�菴懊ｊ蟋九ａ繧九�E萓句�E�悶・蛻・�E�舌′蠁E��∴縺�E�謨�E�騾�E�繧�E�繧�E�繝医′蠁E��∴繧九◆繧√�E�DEA_VAULT・・繝輔ぃ繧�E�繝ｫ驕ｿ髮�E�謁E�・峨・譌ｩ繧√�E鄂ｮ縺上・- ID蛹悶・ 窶懈治逕ｨ蛟呵�E�懊□縺鯛・縺�E�髯仙ｮ壹☁E��具�E�磯封E��・ぁE���E�繝�EぁE��貞�E驛ｨID蛹悶�E�縺�E�縺・�E�峨・
## 菴�E�縺・婿・域怙蟆擾�E�・- 霑ｽ險倥☁E��九□縺代めE��髯�E�繝ｻ蜈ｨ譁�E�E��E�謠帙�E驕ｿ縺代�E��E・IG莠区腐髦�E�豁E��・峨・- 謗｡逕ｨ蛟呵�E�懊�E縺�E�縺�E�縺溘ｉ縲∬�E��E�蠖楢�E�句・縺励ↁE`IDEA_ID: IDEA:<short>` 繧剁E��倁E��弱�E�縺�E�謁E��縺・�E�亥�E�御�E�倥�E�縺�E�OK・峨・
---

## 繧�E�繧�E�繝�EぁE��隕ｧ

### IDEA-000・医ユ繝ｳ繝励Ξ�E・- STATUS: draft
- TAGS: 
- SOURCE:
- BODY:


## ACTIVE・育樟蠖ｹ・壼�E�輔▲蠑ｵ繧雁�E縺怜ｯ�E�雎｡・・
### IDEA_ID: IDEA:e61113b095cb
- TITLE: IDEA capture tooling (implemented)
- DESC: One-paste capture wrapper idea; implemented as scripts + merged PR
- STATUS: implemented
- TAGS:
- SOURCE: chat -> clipboard capture
- RESULT: implemented (PR #407)
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
  -     $idea = Read-Host "霑ｽ蜉縺励◁E��・ぁE���E�繝�EぁE��・莉ｶ・医◎縺�E�縺�E�縺�E�雋ｼ繧具�E�・
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


## ARCHIVE・磯驕ｿ・壼�E�輔▲蠑ｵ繧雁�E縺玲�E�医∩・・・育�E��E�・・

## 驕狗畑�E亥崋螳夲�E�・- 繧�E�繧�E�繝�EぁE���E�驛ｽ蠎ｦ縲後∪縺�E�繧√坂�E capture 縺�E� ACTIVE 縺�E�蜷�E�縺・�E�翫�E�繧九・- 邨�E�蜷医、Epick 縺励◁E���E�繧�E�繝�EぁE���E� ACTIVE 縺九ｉ蜑企勁縺吶�E��E域ｺ懊ａE���E�縺�E�縺�E�縺・�E�峨・- ARCHIVE縺�E�蜴溷援菴�E�繧上�E縺・�E�郁E���E�霍｡縺�E� Git 縺�E�繧�E�繝溘ャ繝亥�E��E�豁E��縺�E�谿九ｋ�E峨・


