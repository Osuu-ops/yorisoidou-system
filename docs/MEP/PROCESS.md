# PROCESS（手続き） v1.1

## 目的
本書は、GitHub上で「迷わず同じ結果になる」最小手順をテンプレとして固定する。
新チャットでは原則 INDEX だけを貼り、追加が必要な場合のみ AI_BOOT の REQUEST 形式で要求する。

---


## Post-merge（必須）

## 外部変更の正規化（GitHub経由しない作業を main に固定）

目的：
- GAS / スプレッドシート / 外部運用など「GitHub外で進んだ作業」を、引っ越し・再現性・唯一の正のために main へ正規化して固定する。

原則（固定）：
- 外部で進めた作業は、そのままでは GitHub に残らないため、結果（現在地）だけを docs/MEP に追記して PR→MERGE する。
- 追記は「確定した値のみ」。推測・埋め・未確定URLの混入は禁止（汚染防止）。
- 追記先は原則 docs/MEP/STATE_CURRENT.md の「## Current objective」に 1〜3 行（肥大化禁止）。

手順（最小・毎回同じ）：
1) docs/MEP/STATE_CURRENT.md に以下を最小追記（例）：
   - 外部システムの到達点（例：GAS Write Endpoint が B16-1 まで）
   - 台帳の識別子（例：Spreadsheet ID、対象シート名）
   - 次テーマ（NEXT）を 1 行
2) docs/MEP/build_chat_packet.py を実行し docs/MEP/CHAT_PACKET.md を再生成（Guard対策）。
3) 変更は docs/MEP のみに限定した PR を作成し、Required checks を通して MERGE。
4) MERGE 後は mep_autopilot.ps1 で open PR=0 を収束させる。

Done 判定：
- main に「外部の現在地」が固定され、CHAT_PACKET から参照できる（＝引っ越し後も同じ手順で続行できる）。
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

## Autorecovery（よくある詰まりの自動解消）
この節は「危険でないのに毎回詰まる」パターンを、手順として固定して再発をゼロにする。

- PR作成前に必ず push する（Head ref not a branch / sha blank 防止）:
  - `git push -u origin HEAD`
- `gh` の `--json` 引数は PowerShell で分割されやすいので、常に全体をクォートする:
  - 例: `gh pr view 123 --json "state,mergeStateStatus,url"`
- PowerShell では `-q`（jq式）周りのクォート事故が起きやすい。原則として:
  - `--json ...` の出力を `ConvertFrom-Json` で処理する（`-q` 依存を避ける）。
- 誤って main に戻ってしまった場合でも、人間判断なしで復旧できるようにする:
  - 「作業ブランチ候補を自動検出 → checkout → push → PR作成/再利用 → auto-merge → main同期」を 1ブロックで実行する。


