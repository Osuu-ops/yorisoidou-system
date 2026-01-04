# PROCESS（手続き） v1.1

## 目的
本書は、GitHub上で「迷わず同じ結果になる」最小手順をテンプレとして固定する。
新チャットでは原則 INDEX だけを貼り、追加が必要な場合のみ AI_BOOT の REQUEST 形式で要求する。

---


## Post-merge（必須）
- MERGE後、docs/MEP/STATE_CURRENT.md に `YYYY-MM-DD: (PR #NNN) 要点` を 1〜3行だけ追記する（肥大化禁止）。
- 追記対象：運用ルール・ゲート・境界、または BUSINESS の契約/責務分界/同期/冪等/競合回収。
- 禁止：長文化、全文貼替、整形だけコミット、DOC_REGISTRYで GENERATED とされる生成物を手で直すこと。
## docs/MEP 生成物同期（必須）
- docs/MEP/** を変更したPRは、先に **Chat Packet Update (Dispatch)** を実行して docs/MEP/CHAT_PACKET.md を最新化する。
- Chat Packet Guard は Required check のため、**outdated のままではマージ不可**（＝このルールを守れば詰まらない）。
- 失敗時は「Chat Packet Update (Dispatch) → 生成PRをマージ → 元PRへ戻る」で復旧する。
- 変更は必ず PR で行う（main 直コミット禁止）
- Required checks（semantic-audit / semantic-audit-business）が OK のみマージ可能
- 変更スコープは1つだけ（混ぜない）
- 巨大ファイルの全文置換や整形だけのコミットを避ける

---

## 実行テンプレ（PowerShell / gh）— これをコピペで回す

### 0) main 同期
```powershell
git checkout main
git pull --ff-only
scope-guard enforcement test 20260103-002424

## PowerShell 実行環境（必須）
- MEP 操作は **pwsh（PowerShell 7）** を使用する（Windows PowerShell 5.1 は禁止）。
- 5.1 で起動してしまった場合は tools/mep_pwsh_guard.ps1 の方式で pwsh に転送して実行する。

## Autopilot（自動エラー回し／open PR 収束）

### 使い方（1回コピペ）
- open PR が 0 なら即終了。
- safe PR は自動で merge/close。
- manual PR が残った場合は一覧だけ出して停止（＝あなたの判断待ち）。

~~~powershell
.\tools\mep_autopilot.ps1 -MaxRounds 120 -SleepSeconds 5 -StagnationRounds 12
~~~

