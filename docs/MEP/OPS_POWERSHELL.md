# OPS_POWERSHELL（PowerShellコピペ運用ルール）

## 絶対ルール（最重要）
- GitHub Actions YAML 等「${{ }} / $」を含むテキストは、PowerShellでは必ず @' '@（シングルクォート Here-String）で書く
  - @" "@（ダブルクォート Here-String）は変数解釈で壊れるため禁止
- main は唯一の正。変更は必ず PR（ブランチ→push→PR→checks→merge）
- workflow追加/変更は Scope Guard のため CURRENT_SCOPE.md の Scope-IN に許可行が必須
- “no checks reported / checksが付かない” は空コミットで synchronize を強制して復旧する

## コミット前の必須（事故防止）
git branch --show-current
（main なら止めて switch）

## PR作成〜auto-merge（テンプレ）
git add <files>
git commit -m "<message>"
git push -u origin HEAD
gh pr create --title "<title>" --body "<body>" --base main
gh pr merge --auto --squash --delete-branch HEAD

## BEHIND（ブランチが古い）の復旧
gh pr update-branch <PR番号> --rebase
（失敗する場合）gh pr update-branch <PR番号>

## no checks reported の復旧
git commit --allow-empty -m "chore(self-heal): trigger checks"
git push
