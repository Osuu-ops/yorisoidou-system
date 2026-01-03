# OPS: Scope-IN Suggest 運用（Out-of-scope 自動提案PR）

## 目的
PRで Scope-OUT（CURRENT_SCOPE の許可外）が発生したときに、

- out-of-scope ファイルを自動検出し
- CURRENT_SCOPE.md の Scope-IN に **exact path** で追加する「提案PR」を自動作成し
- 元PRに、提案PR URL と out-of-scope 一覧を自動コメントする

ことで、Scope-IN 更新を「手順」ではなく「構造」で運用する。

## 期待される挙動（観測点）
- 元PRのコメントに `[SCOPE_SUGGEST] Out-of-scope detected` が付く
- 提案PRの headRefName は `auto/scope-suggest-pr<PR番号>-<timestamp>`
- 提案PRは `platform/MEP/90_CHANGES/CURRENT_SCOPE.md` の Scope-IN に追記するだけ（安全：exact path）

## 運用フロー（最短）
1. 元PRコメントの `[SCOPE_SUGGEST]` を確認し、提案PR URL を開く
2. 提案PRの差分（Scope-IN へ追加される exact path）を目視確認
3. 問題なければ提案PRをマージ（Scope-IN 反映）
4. 元PRの Checks が通ることを確認して、元PRをマージ

---

## コピペ用：open の提案PR一覧（jq不要）
※すべて自動取得。ID/番号の手入力は不要。

    & {
      $ErrorActionPreference = "Stop"
      $repo = (gh repo view --json nameWithOwner -q .nameWithOwner)
      $prs = (gh pr list --repo $repo --state open --json number,title,headRefName,url) | ConvertFrom-Json
      $sugs = $prs | Where-Object { $_.headRefName -like "auto/scope-suggest-pr*" } | Sort-Object number

      if (-not $sugs) {
        Write-Host "[OK] open の提案PRはありません (auto/scope-suggest-pr*)"
        return
      }

      Write-Host "[INFO] open の提案PR一覧:"
      $sugs | Select-Object number,title,headRefName,url | Format-Table -AutoSize
    }

## コピペ用：健全性チェック（read-only / jq不要）

    & {
      $ErrorActionPreference = "Stop"

      function Assert-Exit([string]$msg) {
        if ($LASTEXITCODE -ne 0) { throw "$msg (exit=$LASTEXITCODE)" }
      }

      $repo = (gh repo view --json nameWithOwner -q .nameWithOwner)
      Assert-Exit "gh repo view failed"

      git checkout main | Out-Null
      Assert-Exit "git checkout main failed"
      git pull --ff-only | Out-Null
      Assert-Exit "git pull failed"

      # 1) tracked DoD artifacts (_SCOPE_SUGGEST_*)
      $patterns = @(
        "platform/MEP/01_CORE/_SCOPE_SUGGEST_*",
        "platform/MEP/90_CHANGES/_SCOPE_SUGGEST_*"
      )
      $found = @()
      foreach ($pat in $patterns) {
        $hits = (git ls-files $pat 2>$null)
        if ($hits) { $found += $hits }
      }
      $found = $found | Sort-Object -Unique

      if ($found.Count -eq 0) {
        Write-Host "[OK] No tracked DoD artifacts (_SCOPE_SUGGEST_*)"
      } else {
        Write-Host "[WARN] Tracked DoD artifacts found:"
        $found | ForEach-Object { Write-Host "  - $_" }
      }

      # 2) open suggestion PRs
      $prs = (gh pr list --repo $repo --state open --json number,title,headRefName,url) | ConvertFrom-Json
      Assert-Exit "gh pr list failed"

      $openSuggest = $prs | Where-Object { $_.headRefName -like "auto/scope-suggest-pr*" } | Sort-Object number
      if (-not $openSuggest) {
        Write-Host "[OK] No open suggestion PRs (auto/scope-suggest-pr*)"
      } else {
        Write-Host "[WARN] Open suggestion PRs exist:"
        $openSuggest | ForEach-Object {
          Write-Host ("  - #{0} {1}" -f $_.number, $_.title)
          Write-Host ("    head: {0}" -f $_.headRefName)
          Write-Host ("    url : {0}" -f $_.url)
        }
      }

      Write-Host "DONE: Health check finished (read-only)."
    }

---

## 方針（重要）
- 提案PRの **作成は自動**
- 提案PRの **マージは人間判断**（Scope-IN の暴走拡張を防ぐ）

以上。
