# CHAT_PACKET（新チャット貼り付け用） v1.1

## 使い方（最小）
- 新チャット1通目に **このファイル全文** を貼る。
- 先頭に「今回の目的（1行）」を追記しても良い。
- AIは REQUEST 形式で最大3件まで、必要箇所だけ要求する。

---

## START_HERE.md（入口）  (START_HERE.md)
```
﻿# START_HERE（MEP入口） v1.1

## 役割
本書は新チャット開始の唯一の入口である。
新チャット1通目は「目的（1行）」＋本書を貼って開始する。

---

## 最小手数の推奨（貼り付け）

## 起動時ルール（新チャット1通目）

- CHAT_PACKETのみ（指示なし）：作業開始しない。溜まっている引継ぎ（open PR / CONTINUE_TARGET 等）＋アイデア一覧（IDEA_INDEX / ACTIVE）を提示し、「どれを始めますか？」で選択させる。
- CHAT_PACKET＋指示あり：指示に当てはまるリストを提示し、工程表を作成する（以後、ユーザーの自由文による採用宣言があるまでコードは出さない）。

- 最短は docs/MEP/CHAT_PACKET.md を貼る（1枚で開始できる）。
- CHAT_PACKET が無い場合は、本書（START_HERE）を貼って開始する。

- PRをMERGEしたら、STATE_CURRENT.mdへ最小追記（1〜3行）を行い、「何が正式採用になったか」を固定する。
- 対象は「運用ルール／ゲート／境界」および「BUSINESSの契約（同期・冪等・回収など）」で、整形や生成物更新だけは原則スキップする。

---

## 参照順（固定）
1. docs/MEP/STATE_CURRENT.md（現在地）
2. docs/MEP/ARCHITECTURE.md（構造）
3. docs/MEP/PROCESS.md（手続き）
4. docs/MEP/GLOSSARY.md（用語）
5. docs/MEP/GOLDEN_PATH.md（完走例）

---

## AIの要求ルール（必須）
- 「全部貼れ」「大量ファイル貼れ」は禁止。
- 追加が必要な場合のみ、最大3件まで、必ず次の形式で要求する。

### REQUEST
- file: <ファイルパス>
- heading: <見出し名>
- reason: <必要理由（1行）>

---

## Links
- docs/MEP/CHAT_PACKET.md
- docs/MEP/MEP_MANIFEST.yml
- docs/MEP/INDEX.md
- docs/MEP/AI_BOOT.md
- docs/MEP/STATE_CURRENT.md
- docs/MEP/ARCHITECTURE.md
- docs/MEP/PROCESS.md
- docs/MEP/GLOSSARY.md
- docs/MEP/GOLDEN_PATH.md

- [OPS: Scope-IN Suggest 運用（Out-of-scope 自動提案PR）](docs/MEP/OPS_SCOPE_SUGGEST.md)
```

---

## MEP_MANIFEST.yml（機械可読）  (docs/MEP/MEP_MANIFEST.yml)
```
﻿version: 1.0
entrypoint:
  primary: START_HERE.md
  index: docs/MEP/INDEX.md
chat_packet:
  file: docs/MEP/CHAT_PACKET.md
rules:
  request_limit: 3
  forbid:
    - "Ask to paste everything"
    - "Ask to paste 10 files"
reference_order:
  - docs/MEP/STATE_CURRENT.md
  - docs/MEP/ARCHITECTURE.md
  - docs/MEP/PROCESS.md
  - docs/MEP/GLOSSARY.md
  - docs/MEP/GOLDEN_PATH.md
checks:
  required:
    - semantic-audit
    - semantic-audit-business
```

---

## INDEX.md（目次）  (docs/MEP/INDEX.md)
```
# MEP INDEX（入口） v1.0

## 参照順（固定）
1. STATE_CURRENT（現在地）
2. ARCHITECTURE（構造）
3. PROCESS（手続き）
4. GLOSSARY（用語）
5. GOLDEN_PATH（完走例）

## Links
- [OPS_POWERSHELL](./OPS_POWERSHELL.md)
- [OPS_SCOPE_GUARD](./OPS_SCOPE_GUARD.md)
- [AI_BOOT](./AI_BOOT.md)
- [STATE_CURRENT](./STATE_CURRENT.md)
- [ARCHITECTURE](./ARCHITECTURE.md)
- [PROCESS](./PROCESS.md)
- [GLOSSARY](./GLOSSARY.md)
- [GOLDEN_PATH](./GOLDEN_PATH.md)


## RUNBOOK（復旧カード）
- RUNBOOK.md（異常時は診断ではなく次の一手だけを返す）

## PLAYBOOK（次の指示）
- PLAYBOOK.md（常に次の一手を返すカード集）

## STATE_SUMMARY（現在地サマリ）
- STATE_SUMMARY.md（STATE/PLAYBOOK/RUNBOOK/INDEX を1枚に圧縮した生成物）

## PLAYBOOK_SUMMARY（次の指示サマリ）
- PLAYBOOK_SUMMARY.md（PLAYBOOK のカード一覧生成物）

## RUNBOOK_SUMMARY（復旧サマリ）
- RUNBOOK_SUMMARY.md（RUNBOOK のカード一覧生成物）

## UPGRADE_GATE（開始ゲート）
- UPGRADE_GATE.md（開始直後に100点化してから着手する固定ゲート）

## HANDOFF_100（引継ぎ100点）
- HANDOFF_100.md（新チャット1通目に貼る1枚）

## REQUEST_BUNDLE（追加要求ファイル束）
- REQUEST_BUNDLE_SYSTEM.md（SYSTEM側の要求ファイル束）
- REQUEST_BUNDLE_BUSINESS.md（BUSINESS側の要求ファイル束）

## IDEA_VAULT（アイデア避難所）
- IDEA_VAULT.md（アイデア散逸防止。ID化は採用候補のみ）

## IDEA_INDEX（統合用一覧）
- IDEA_INDEX.md（ACTIVEから生成。番号で選ぶ）
- IDEA_VAULT.md（本体。ACTIVE/ARCHIVE）

## IDEA_RECEIPTS（実装レシート）
- IDEA_RECEIPTS.md（RESULT: implemented が付いたら削除可能）

## Tools
- [mep_idea_receipt.ps1](../../tools/mep_idea_receipt.ps1) — IDEA を「IDEA_RECEIPTS」に固定し、必要ならPRとして提出する

---

## Lease / Continue Target（追加）
- LEASE: docs/MEP/LEASE.md
- CONTINUE_TARGET: docs/MEP/CONTINUE_TARGET.md

---

## RUNBOOK（追加）
- CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）: docs/MEP/RUNBOOK.md

## DOC_STATUS（追加）
- [DOC_REGISTRY](./DOC_REGISTRY.md)  — 文書状態台帳（ACTIVE/STABLE/GENERATED）
```

---

## AI_BOOT.md（AI挙動固定）  (docs/MEP/AI_BOOT.md)
```
﻿# AI_BOOT（AI挙動固定） v1.0

## 目的
本書は、新チャットでAIが迷わず進行するための「要求フォーマット」と「禁止事項」を固定する。
AIは本書に従ってのみ情報要求を行う。

---

## 絶対禁止
- 出力に「ネストしたコードブロック」や「複数のコードブロック混在」を作らない（本文中に ``` を入れ子にしない）。
- Git/GitHub/PowerShell 操作は必ず **単一の ```powershell ブロック**で提示する（途中で別ブロックを挿入しない）。
- 説明はコード内コメントに寄せ、ブロック外で手順を分割しない。
- PowerShell の Here-String は **@' '@** を使用する（@" "@ は禁止）。
- 「全部貼れ」「10ファイル貼れ」等の大量提示要求
- ローカル操作を前提とした手順提示（GitHub内で完結させる）
- 入口整備（docs/MEP）を超えるスコープ拡張（再設計・改善提案の無限化）

---

## AIの情報要求フォーマット（必須）
不足情報がある場合、AIは必ず次の形式で要求する：

### REQUEST
- file: <ファイルパス>
- heading: <見出し名（h2/h3等）>
- reason: <その見出しが必要な理由（1行）>

（複数必要な場合も最大3件まで。3件を超える要求は禁止。）

---

## 採否判断ゲート（コード生成の前に必須）


## 意思決定ゲート（Decision Gate｜コード禁止）

テーマが来たら、AIは必ず **次だけ** を返す（コード／コマンド／手順は禁止）：

- 目的（何を解決するか）
- 前提（制約／触って良い範囲／触らない範囲）
- 選択肢（最大3案）
- 評価（良い/悪い、リスク、コスト、DoD）
- 推奨案（AIの結論）
- 最終確認（採用/不採用/保留を選ばせる）

## 実装ゲート（Adoption Trigger｜採用宣言が出るまでコード禁止）

ユーザーが明示したときだけコード解禁：

- 「採用して進めて」
- 「この内容で採用」
- 「実装に入って」

この宣言が無い限り、AIは **コマンドも手順も出さない**。

## 例外（人間が命令したときだけ）

ユーザーが「今すぐそのコマンドを出して」等を明示した場合のみ、その瞬間だけコマンドを出す。
それ以外は出さない。
### 原則（正式採用）
- テーマ提示だけでは、AIはコード/コマンド/手順を出さない（深掘り→採否判断が先）。
- 人間が「採用/実装開始」を明示した場合のみ、実装フェーズへ進む。

### 深掘りフェーズ（コード禁止）
AIはまず以下を提示し、採用/不採用の判断材料を揃える：
- 目的（何を解決するか）
- 前提（制約・境界・触って良い/悪い）
- 成功条件（DoD）
- リスク（詰まりポイント）
- 選択肢（最大3案）と評価（良い/悪いの理由）
- AIの推奨案（名案）と、採用/不採用/保留の提案

### 採用宣言（人間の最終判断）
- ユーザーが「採用して」「この内容で採用」「実装に入って」等を明示したら実装へ進む。
- 明示がない限り、AIはコードを出さない。

### 実装フェーズ（採用後のみ）
- 採用後は 1テーマ=1PR を守り、PowerShell等は単一ブロックで提示する。

## 進行の優先順位（固定）
1) docs/MEP/INDEX.md（入口）
2) docs/MEP/STATE_CURRENT.md（現在地）
3) docs/MEP/ARCHITECTURE.md（構造）
4) docs/MEP/PROCESS.md（手続き）
5) docs/MEP/GLOSSARY.md（用語）
6) docs/MEP/GOLDEN_PATH.md（完走例）

---

## 不足情報の扱い（固定）
- AIは推測で補完しない。必要なら REQUEST フォーマットで要求する。
- ただし、要求は最大3件まで。足りない場合は「まずINDEX/STATE_CURRENTの更新PR」を提案して止める。

---

## 合格条件（AI側のDone判定）
- INDEXから必要文書へ辿れる
- 「唯一の正」「触って良い/悪い領域」「PR運用」が明文化されている
- AIが REQUEST フォーマットで必要箇所だけ要求できる
```

---

## STATE_CURRENT.md（現在地）  (docs/MEP/STATE_CURRENT.md)
```
# STATE_CURRENT (MEP)

## Doc status registry（重複防止）
- docs/MEP/DOC_REGISTRY.md を最初に確認する (ACTIVE/STABLE/GENERATED)
- STABLE/GENERATED は原則触らない（目的明示の専用PRのみ）

## CURRENT_SCOPE (canonical)
- platform/MEP/03_BUSINESS/よりそい堂/**

## Guards / Safety
- Required checks は「PRで必ず表示されるチェック名」のみに限定する（schedule/dispatch専用チェック名を入れると永久BLOCKEDになり得る）。
- Text Integrity Guard (PR): enabled
- Halfwidth Kana Guard: enabled
- UTF-8/LF stabilization: enabled (.gitattributes/.editorconfig)

## Current objective
- 2026-01-06: (OPS) clasp fixed-URL redeploy loop established (RUNBOOK CARD-08: GAS Fixed-URL Redeploy (clasp fast loop)): scriptId=1wpUF60VBRASNKuFOx1hLXK2bGQ74qL7YwU4Eq_wnd9eEAApHp9F4okxc deploymentId=AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw exec=https://script.google.com/macros/s/AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw/exec
- 2026-01-06: (OPS) B23 adopted: RUNBOOK CARD-07 fixes operational procedure for request.normalize_status_columns (status/requestStatus) using B22 endpoint: https://script.google.com/macros/s/AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw/exec
- 2026-01-06: (NEXT) B24: TBD (define next theme)
- 2026-01-06: (GAS) WRITE endpoint is B22 (B21 + tool: request.normalize_status_columns for status/requestStatus normalization): https://script.google.com/macros/s/AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw/exec
- 2026-01-06: (GAS) B22 verified: normalize_status_columns exists and runs (dryRun + write), then request.get returns effectiveStatus on https://script.google.com/macros/s/AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw/exec
- 2026-01-06: (NEXT) B23: TBD (define next theme)
- 2026-01-06: (PR #576) master_spec: ledger reflection — add event→ledger mapping for delete/FREEZE/FIX
- 2026-01-06: (GAS) B21 verified: status and requestStatus kept in sync (OPEN/RESOLVED/CANCELLED); list_status works; resolve-after-cancel rejected on https://script.google.com/macros/s/AKfycbw2moBfgg13VaxGPNQDj-2vGzai5GZXHGpZP4bkNib3h12mVsldCCkwAfEvVAgbCs2-3Q/exec
- 2026-01-06: (NEXT) B22: TBD (define next theme)
- 2026-01-06: (GAS) B20 verified: cancel_request sets CANCELLED; resolve after cancel rejected (ok=false); Request.get reflects CANCELLED on https://script.google.com/macros/s/AKfycbwkdXO0x3SPLgvCSvn11NakOKDXCsROJCPZpDQKiyN1JGV0TwN1v-2Z7YyJd-EC4fNhwg/exec
- 2026-01-06: (NEXT) B21: TBD (define next theme)
- 2026-01-06: (GAS) B19 verified: default strict NOT_FOUND_RECOVERY (no Recovery create) + opt-in autoCreateRecovery created Recovery_Queue then LINKED on https://script.google.com/macros/s/AKfycbxTpul-Tdtce5V-MOTVofNumceEpEaQKD70fT66PL1mPo2YpTa0D6XmKehmoJwPj5HhJA/exec
- 2026-01-06: (NEXT) B20: TBD (define next theme)
- 2026-01-06: (PR #562) master_spec: ledger reflection for delete/FREEZE/Request(FIX) (v1.0) — ledger columns/keys + minimal rules
- 2026-01-06: (GAS) B18 verified: READ ops returned expected rows (rqKey/requestKey) on https://script.google.com/macros/s/AKfycby-lrrbKhIJHMNV85bzwUAFhNuffbTxuBzLHGTtmIJM2vxy4XdI95cxUkbsCz_bw59uZw/exec
- 2026-01-06: (NEXT) B19: TBD (define next theme)
- 2026-01-06: (NEXT) B18: add READ ops for verification/troubleshooting (recovery_queue.get/list_unlinked, request.get/list_open)
- 2026-01-06: (GAS) B17-1 verified: Request.upsert_open_dedupe links Recovery_Queue.requestRef when recoveryRqKey (==rqKey) is provided; policy A = overwrite forbidden (CONFLICT).
- 2026-01-06: (GAS) B17-1 linkageStatus fixed: LINKED | NOT_FOUND_RECOVERY | CONFLICT | ERROR; dryRun=true => op=noop (no writes).
- 2026-01-06: (GAS) Spreadsheet ID (Ledger): 1VWqQXs9HAvZQ7K9fKXa4M0BHrvvsZW8qZBJHqoCCE3I (Sheets: Recovery_Queue / Request)
- 2026-01-06: (NEXT) B17: Recovery_Queue ↔ Request linkage (requestRef/recoveryRqKey) in write endpoint
- 2026-01-05: (PR #509) tools/mep_integration_compiler/collect_changed_files.py: accept tab-less git diff -z output (rename/copy parsing robustness)
- Build and refine Yorisoidou BUSINESS master_spec and UI spec under the above scope.
- 2026-01-05: (PR #479) Decision-first（採用/不採用→採用後のみ実装）を正式採用
- 2026-01-05: (PR #483) Phase-2 Integration Contract（Todoist×ClickUp×Ledger）を business_spec に追加

## How to start a new conversation
Tell the assistant:
- "Read docs/MEP/START_HERE.md and proceed."
- (If memory=0 / new chat) paste CHAT_PACKET_MIN first (tools/mep_chat_packet_min.ps1 output).







- 2026-01-06T21:38:27+09:00 (actor: True) TEST-SIGNEDBY: PR test created; metadata-format-check executed; refer to CI logs for details.
```

---

## ARCHITECTURE.md（構造・境界）  (docs/MEP/ARCHITECTURE.md)
```
﻿# ARCHITECTURE（構造） v1.1

## 目的
MEP運用で迷い・暴走・汚染が起きる箇所を、構造（パス境界）として固定する。

---

## 唯一の正（Source of Truth）
- **唯一の正は main ブランチ**である。
- 変更は必ず **Pull Request** で行い、**Required checks** を通過してからマージする。

---

## 入口（参照開始点）
- 入口は **START_HERE.md → docs/MEP/INDEX.md** を唯一の導線とする。
- 新チャットでは原則 INDEX だけを貼り、追加が必要な場合は **AI_BOOT の REQUEST 形式**で要求する。

---

## 触って良い領域 / 触ってはいけない領域（運用境界）
### 触って良い（今回のINDEX方式のスコープ）
- docs/MEP/**
- START_HERE.md
- .github/workflows/docs_index_guard.yml（入口の整合ガード）

### 原則触らない（別PR・別スコープ）
- platform/MEP/**（MEP本体・業務仕様の実体）
- .github/workflows/* のうち、入口整合ガード以外（CI/運用の核）
- MEP のプロトコル/キャノン/マスター類（変更するなら必ず専用PRでスコープを切る）

---

## 変更の粒度（事故防止）
- 文書の整形（改行/空白/並べ替え）だけのコミットを作らない。
- 巨大ファイルの全文置換を避け、差分を最小化する。
- AIが要求する追加提示は最大3件まで（AI_BOOT準拠）。

---

## 運用上の合格条件（DoD）
- docs/MEP/INDEX.md から各文書へ到達できる（リンク/パスが正しい）
- 「唯一の正」「触って良い/悪い領域」「PR運用」が明文化されている
- 入口破損は Docs Index Guard で検出できる
```

---

## PROCESS.md（実行テンプレ）  (docs/MEP/PROCESS.md)
```
﻿# PROCESS（手続き） v1.1

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
```

---

## GLOSSARY.md（用語）  (docs/MEP/GLOSSARY.md)
```
﻿# GLOSSARY（用語） v1.0

- B運用: Required checks OKのみマージ
- A運用: 手動保険ルート
- TIG: Text Integrity Guard
- INDEX方式: 入口だけ貼り、必要箇所だけ要求


 - scopeguard-dod-test: 20260103-051233
 - ruleset-dod-test: 20260103-053612
 - required4-dod-test: 20260103-060125
 - seed-mep-gate: 20260103-062802
```

---

## GOLDEN_PATH.md（完走例）  (docs/MEP/GOLDEN_PATH.md)
```
﻿# GOLDEN_PATH（完走例） v1.1

## 目的
抽象説明ではなく「実際にこのリポジトリで通った完走例」を固定し、
次AI/新チャットが同じ手順で迷わず再現できるようにする。

---

## 完走例A：INDEX方式導入（入口整備）— 実績

### 目的
「マスタ1枚コピペ」運用から脱却し、GitHub上に読む順番（入口）を固定する。

### 実施内容（PR単位）
1) 入口セット作成（START_HERE + docs/MEP + AI_BOOT + Guard）
- PR: #119
- 追加/作成:
  - START_HERE.md
  - docs/MEP/INDEX.md
  - docs/MEP/AI_BOOT.md
  - docs/MEP/STATE_CURRENT.md（雛形）
  - docs/MEP/ARCHITECTURE.md（雛形）
  - docs/MEP/PROCESS.md（雛形）
  - docs/MEP/GLOSSARY.md（雛形）
  - docs/MEP/GOLDEN_PATH.md（雛形）
  - .github/workflows/docs_index_guard.yml
- チェック:
  - semantic-audit / semantic-audit-business（Required）
  - Text Integrity Guard (PR)
  - Docs Index Guard
- 結果: merged

2) ARCHITECTURE 境界の明文化（汚染防止）
- PR: #121
- 変更:
  - docs/MEP/ARCHITECTURE.md を v1.1 に更新（触って良い/悪い領域、粒度、DoD）
- 結果: merged

3) STATE_CURRENT の実務固定（B/A/TIG/Auto PR Gate の使い分け）
- PR: #122
- 変更:
  - docs/MEP/STATE_CURRENT.md を v1.1 に更新（運用状態と使用条件を明文化）
- 結果: merged

---

## 完走手順テンプレ（毎回これで回す）
1) main を最新化
2) 作業ブランチ作成（スコープは1つだけ）
3) 変更（差分は最小）
4) PR作成
5) Required checks が全て OK を確認
6) squash merge（ブランチ削除）
7) main を再同期

---

## 注意（事故防止）
- 「全部貼れ」「大量ファイル貼れ」は禁止。必要なら AI_BOOT の REQUEST 形式で最大3件まで。
- 文書の整形だけのコミットを作らない。巨大ファイルの全文置換を避ける。
- 入口整備のPRは docs/MEP/** と START_HERE.md と docs_index_guard のみに限定する。
```

---
