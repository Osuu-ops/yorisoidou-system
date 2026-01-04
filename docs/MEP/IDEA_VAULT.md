# IDEA_VAULT・医い繧､繝・い驕ｿ髮｣謇・・v1.0

譛ｬ譖ｸ縺ｯ縲√メ繝｣繝・ヨ蠑輔▲雜翫＠繝ｻ荳ｦ襍ｰ繝ｻ豎壽沒縺ｮ荳ｭ縺ｧ繧ゅ後い繧､繝・い縺梧淵騾ｸ縺励↑縺・阪◆繧√・譛蟆城∩髮｣謇縺ｧ縺ゅｋ縲・
## 譁ｹ驥晢ｼ亥崋螳夲ｼ・- 繧｢繧､繝・い髮・・ID邂｡逅・・ 窶懷ｿ・医〒縺ｯ縺ｪ縺・昴・- 縺溘□縺励∵･ｭ蜍吝・・・USINESS・峨ｒ菴懊ｊ蟋九ａ繧九→萓句､悶・蛻・ｲ舌′蠅励∴縺ｦ謨｣騾ｸ繧ｳ繧ｹ繝医′蠅励∴繧九◆繧√！DEA_VAULT・・繝輔ぃ繧､繝ｫ驕ｿ髮｣謇・峨・譌ｩ繧√↓鄂ｮ縺上・- ID蛹悶・ 窶懈治逕ｨ蛟呵｣懊□縺鯛・縺ｫ髯仙ｮ壹☆繧具ｼ磯尅隲・い繧､繝・い繧貞・驛ｨID蛹悶＠縺ｪ縺・ｼ峨・
## 菴ｿ縺・婿・域怙蟆擾ｼ・- 霑ｽ險倥☆繧九□縺代ょ炎髯､繝ｻ蜈ｨ譁・ｽｮ謠帙・驕ｿ縺代ｋ・・IG莠区腐髦ｲ豁｢・峨・- 謗｡逕ｨ蛟呵｣懊↓縺ｪ縺｣縺溘ｉ縲∬ｩｲ蠖楢ｦ句・縺励↓ `IDEA_ID: IDEA:<short>` 繧剃ｻ倅ｸ弱＠縺ｦ謇ｱ縺・ｼ亥ｾ御ｻ倥￠縺ｧOK・峨・
---

## 繧｢繧､繝・い荳隕ｧ

### IDEA-000・医ユ繝ｳ繝励Ξ・・- STATUS: draft
- TAGS: 
- SOURCE:
- BODY:


## ACTIVE・育樟蠖ｹ・壼ｼ輔▲蠑ｵ繧雁・縺怜ｯｾ雎｡・・
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
  -     $idea = Read-Host "霑ｽ蜉縺励◆縺・い繧､繝・い繧・莉ｶ・医◎縺ｮ縺ｾ縺ｾ雋ｼ繧具ｼ・
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



## ARCHIVE・磯驕ｿ・壼ｼ輔▲蠑ｵ繧雁・縺玲ｸ医∩・・・育ｩｺ・・

## 驕狗畑・亥崋螳夲ｼ・- 繧｢繧､繝・い縺ｯ驛ｽ蠎ｦ縲後∪縺ｨ繧√坂・ capture 縺ｧ ACTIVE 縺ｫ蜷ｸ縺・ｸ翫￡繧九・- 邨ｱ蜷医〒 pick 縺励◆繧｢繧､繝・い縺ｯ ACTIVE 縺九ｉ蜑企勁縺吶ｋ・域ｺ懊ａ霎ｼ縺ｾ縺ｪ縺・ｼ峨・- ARCHIVE縺ｯ蜴溷援菴ｿ繧上↑縺・ｼ郁ｨｼ霍｡縺ｯ Git 縺ｮ繧ｳ繝溘ャ繝亥ｱ･豁ｴ縺ｫ谿九ｋ・峨・




