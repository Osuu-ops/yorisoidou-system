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
---

## CHAT_PACKET 整合（重要）：docs/MEP変更後の追随ルール

### 背景（何が起きるか）
docs/MEP 内の入力ファイル（例：GLOSSARY.md / ARCHITECTURE.md 等）を変更すると、
生成物である `docs/MEP/CHAT_PACKET.md` が「古い状態」になり得る。

この状態では、PR の Checks にて `Chat Packet Guard` が NG になることがある。

### 運用ルール（固定）
docs/MEP の入力ファイルを変更した場合、変更PRとは別に、
`CHAT_PACKET` を追随させる「生成PR」を必ず通す。

- 入力PR：docs/MEP/*.md 等を人間が編集するPR
- 生成PR：Chat Packet Update（Schedule/Dispatch）により `docs/MEP/CHAT_PACKET.md` のみを更新するPR（例：`auto/chat-packet-update-*`）

### 最短手順（PowerShell / gh）
1) 入力PRをマージ（Required checks OK → squash merge）
2) 直後に Chat Packet Update を1回起動して生成PRを作らせる（差分が無い日は何もしない）

```powershell
# Chat Packet Update (Schedule) を手動で1回起動（差分があれば auto PR が作られる）
gh workflow run .github/workflows/chat_packet_update_schedule.yml --ref main

# 直近run確認
gh run list --workflow "chat_packet_update_schedule.yml" --limit 1

# auto/chat-packet-update PR の有無（open は瞬殺されるので state all 推奨）
gh pr list --state all --base main --search "head:auto/chat-packet-update-" --limit 5

## AI出力契約（単一コピペ一本道）

- 本運用では、AIの出力は **PowerShell単一コピペ一本道**を原則とする。
- ID/番号の手入力・差し替えは禁止（ghで自動解決してコマンド内で完結）。
- 詳細は以下を唯一の正とする：
  - docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md

## Autopilot（自動エラー回し／自動掃除）
- open PR を自動で回し、safe-auto（auto/*, docs更新系, 整形PRなど）を merge/close して open PR=0 に収束させる
- docs/MEP の guard fail は、PRブランチ上で CHAT_PACKET を再生成して self-heal を試す
- 人間が考える必要がある PR（上記に該当しないもの）は触らず一覧表示して止まる

~~~powershell
.\tools\mep_autopilot.ps1
~~~
