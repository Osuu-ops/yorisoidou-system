# REQUEST_BUNDLE_BUSINESS（追加要求ファイル束） v1.1

本書は、AIが追加で要求しがちなファイル群を「1枚」に束ねた生成物である。
新チャットで REQUEST が発生した場合は、原則として本書を貼れば追加要求を抑止できる。
本書は時刻・ランID等を含めず、入力ファイルが同じなら差分が出ないことを前提とする。
生成: /home/runner/work/yorisoidou-system/yorisoidou-system/docs/MEP/build_request_bundle.py
ソース定義: /home/runner/work/yorisoidou-system/yorisoidou-system/docs/MEP/request_bundle_sources_business.txt

---

## 収録ファイル一覧（存在するもの）
- docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
- docs/MEP/CHAT_PACKET.md
- docs/MEP/INDEX.md
- docs/MEP/PLAYBOOK.md
- docs/MEP/PLAYBOOK_SUMMARY.md
- docs/MEP/RUNBOOK.md
- docs/MEP/RUNBOOK_SUMMARY.md
- docs/MEP/STATE_CURRENT.md
- docs/MEP/STATE_SUMMARY.md
- docs/MEP/UPGRADE_GATE.md
- platform/MEP/03_BUSINESS/tictactoe/master_spec.md
- platform/MEP/03_BUSINESS/よりそい堂/00_CURRENT_SCOPE_NOTE.md
- platform/MEP/03_BUSINESS/よりそい堂/01_INDEX.md
- platform/MEP/03_BUSINESS/よりそい堂/03_TODO.md
- platform/MEP/03_BUSINESS/よりそい堂/04_DOC_EXAMPLE_STATUS.md
- platform/MEP/03_BUSINESS/よりそい堂/99__ci_trigger.md
- platform/MEP/03_BUSINESS/よりそい堂/99__ci_trigger_cleanup.md
- platform/MEP/03_BUSINESS/よりそい堂/BUSINESS_PACKET.md
- platform/MEP/03_BUSINESS/よりそい堂/INDEX.md
- platform/MEP/03_BUSINESS/よりそい堂/business_master.md
- platform/MEP/03_BUSINESS/よりそい堂/business_spec.md
- platform/MEP/03_BUSINESS/よりそい堂/code/README.md
- platform/MEP/03_BUSINESS/よりそい堂/master_spec.md
- platform/MEP/03_BUSINESS/よりそい堂/ui_master.md
- platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md
- platform/MEP/90_CHANGES/CHANGELOG.md
- platform/MEP/90_CHANGES/CURRENT_SCOPE.md

---

## 収録上限（固定）
- MAX_FILES: 300
- MAX_TOTAL_BYTES: 2000000
- MAX_FILE_BYTES: 250000
- included_total_bytes: 329874

## 欠落（指定されたが存在しない）
- ﻿# One path per line. Lines starting with # are comments.

---

## 本文（ファイル内容を連結）
注意：本書は貼り付け専用の束であり、ここに含まれる内容を編集対象にしない（編集は元ファイルで行う）。

---

### FILE: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
- sha256: 7cfe777c553e8743f16b34fec199fee9fc5cce4c2a640daf34d37a9294b1fa8e
- bytes: 1726

```text
﻿# AI出力契約（PowerShell運用・単一コピペ一本道）

本書は **MEP 運用における AI 出力の契約**である。以後、AI は本契約に違反する出力をしてはならない。

## 1. 実行環境（固定）
- 作業は **PowerShell** で実行する。
- PowerShell の Here-String は **@'' ''@（シングルクォート）** を使用する（@" "@ 禁止）。

## 2. 出力形式（原則：単一ブロック）
- AI の出力は、原則として **単一の PowerShell コードブロック**のみで提示する。
- ユーザーが行う操作は **上から順にコピペして実行するだけ**とする。
- 途中に別のコードブロック、分岐、選択肢、差し替え指示を挟まない（混入がバグの原因となるため）。

## 3. ID・番号・差し替え（手入力禁止）
- PR番号 / workflow id / run id / commit sha 等の **ID・番号の手入力や代入（差し替え）を禁止**する。
- 必要なIDは、AIが **gh コマンドで自動解決して変数化**し、提示するコマンド内で完結させる。
- `<...>` 形式のプレースホルダをユーザーに差し替えさせない。

## 4. 例外（分割を許可する条件）
- 以下の場合に限り、AIはコードブロック分割を許可される：
  - エラー回避や安全性のため、段階実行が必須である
  - GitHub の応答待ち（生成されるPR/Checksの確定）が必要である
- 分割する場合は、**STEP 1 / STEP 2** のように順番を明示し、ユーザーが迷わない一本道を維持する。

## 5. 優先順位
本契約は、チャット内の便宜的な説明や提案より優先される。
```


---

### FILE: docs/MEP/CHAT_PACKET.md
- sha256: 55f9cd72e7db48521e248dbd744d4a3092144496569925606912ff7959af9901
- bytes: 20715

```text
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
﻿# STATE_CURRENT (MEP)

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
- 2026-01-06: (GAS) WRITE endpoint is B16-1 (Recovery_Queue upsert + Request upsert_open_dedupe + resolve_request): https://script.google.com/macros/s/AKfycbzZtrlz9MIMPNn7RQoO-SIUrtJvtOBPLACFxuzCIYhcQbzkQ7xYN79AukEV9eIyB3KCfQ/exec
- 2026-01-06: (GAS) Spreadsheet ID (Ledger): 1VWqQXs9HAvZQ7K9fKXa4M0BHrvvsZW8qZBJHqoCCE3I (Sheets: Recovery_Queue / Request)
- 2026-01-06: (NEXT) B17: Recovery_Queue ↔ Request linkage (requestRef/recoveryRqKey) in write endpoint
- 2026-01-06: (GAS) WRITE endpoint is B16-1 (Recovery_Queue upsert + Request upsert_open_dedupe + resolve_request): https://script.google.com/macros/s/AKfycbzZtrlz9MIMPNn7RQoO-SIUrtJvtOBPLACFxuzCIYhcQbzkQ7xYN79AukEV9eIyB3KCfQ/exec
- 2026-01-05: (PR #509) tools/mep_integration_compiler/collect_changed_files.py: accept tab-less git diff -z output (rename/copy parsing robustness)
- Build and refine Yorisoidou BUSINESS master_spec and UI spec under the above scope.
- 2026-01-05: (PR #479) Decision-first（採用/不採用→採用後のみ実装）を正式採用
- 2026-01-05: (PR #483) Phase-2 Integration Contract（Todoist×ClickUp×Ledger）を business_spec に追加

## How to start a new conversation
Tell the assistant:
- "Read docs/MEP/START_HERE.md and proceed."
- (If memory=0 / new chat) paste CHAT_PACKET_MIN first (tools/mep_chat_packet_min.ps1 output).
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
```


---

### FILE: docs/MEP/INDEX.md
- sha256: 3ae34213ad7b0bacb33fbcbbf5ac287c3555438530932b302662a1f60924f814
- bytes: 2303

```text
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

### FILE: docs/MEP/PLAYBOOK.md
- sha256: 6e544294f3777c812f8a89b4996d91e3a8f843f42c1aa72440549dc93c129567
- bytes: 3466

```text
﻿# PLAYBOOK（次の指示カード集）

本書は「UI/API有無に関わらず、常に次の一手が出る」ためのカード集である。
診断ではなく「次の行動」を返す。手順は PowerShell 単一コピペ一本道を原則とする。
唯一の正：main / PR / Checks / docs（GitHub上の状態）
運用契約：docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md

---

## CARD-00: 新チャット開始（最短の開始入力）

入力（原則）：
- docs/MEP/CHAT_PACKET.md（全文）
- docs/MEP/STATE_CURRENT.md（全文）

以後：
- 追加情報が必要な場合のみ、AIは REQUEST 形式（最大3件）で要求する。

---

## CARD-01: docs/MEP を更新する（最小PRで進める）

目的：
- docs/MEP の変更は 1PR 単位で小さく通す。

次の一手：
- 対象ファイルを編集
- PR作成 → checks を待つ → auto-merge を設定
- NG が出たら RUNBOOK の該当カードへ遷移する（診断はしない）

---

## CARD-02: no-checks（表示待ち）に遭遇した

症状：
- gh pr checks が「no checks reported」または空

次の一手：
- 30〜90秒待機して再観測（RUNBOOK: CARD-01）
- 継続する場合は A運用（Gate Runner Manual）へ遷移

---

## CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）

次の一手：
- docs/MEP/build_chat_packet.py を実行して docs/MEP/CHAT_PACKET.md を更新
- 同一PRに含めて再push（または自動更新PRに任せる）
- RUNBOOK: CARD-02

---

## CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）

次の一手：
- Scope-IN Suggest の提案を確認
- 変更が本当に必要なら CURRENT_SCOPE を最小拡張して通す
- 不要なら変更をScope内に戻す
- RUNBOOK: CARD-03

---

## CARD-05: Head branch is out of date（behind/out-of-date）

次の一手：
- PRブランチを main に追従（merge / rebase どちらか）して再push
- auto-merge を再設定
- RUNBOOK: CARD-04

---

## CARD-06: DIRTY（自動停止すべき状態）

次の一手：
- 停止理由（分類）を確認
- 人間判断入力に変換（採用/破棄を明示）
- 最小差分PRで再実行
- RUNBOOK: CARD-05

## CARD: IDEA → Receipt → PR（mep_idea_receipt）

目的：
- 採用したIDEAを「実装レシート（IDEA_RECEIPTS）」として固定し、必要ならPRとして提出する。

実行（ID手入力なし）：
- powershell: .\tools\mep_idea_receipt.ps1

参照：
- docs/MEP/IDEA_VAULT.md（避難所）
- docs/MEP/IDEA_INDEX.md（候補一覧）
- docs/MEP/IDEA_RECEIPTS.md（実装レシート）

## CARD: IDEA → Receipt → PR（mep_idea_receipt）

目的：
- 採用したIDEAを「実装レシート（IDEA_RECEIPTS）」として固定し、必要ならPRとして提出する。

実行（非対話／例）：
- powershell: .\tools\mep_idea_receipt.ps1 -IdeaId abcd1234efgh -Ref "PR#999" -Desc "Implemented the idea"
- usage:     .\tools\mep_idea_receipt.ps1 -Help

参照：
- docs/MEP/IDEA_VAULT.md（避難所）
- docs/MEP/IDEA_INDEX.md（候補一覧）
- docs/MEP/IDEA_RECEIPTS.md（実装レシート）

---

## CARD-00 追記（Lease / Continue Target） v1.1

新チャット開始時の最初の作業は、必ず以下の順で固定する：
- LEASE 適用（CURRENT）
- UPGRADE_GATE 適用（矛盾検出 → 観測）
- CONTINUE_TARGET により “次の一手カード” を 1つに確定
- そのカードに従い 1PR を着手
```


---

### FILE: docs/MEP/PLAYBOOK_SUMMARY.md
- sha256: 4b3888d4438d090d5d37fc0388f28c2e19af475ce59dfb7c278414d4532f6086
- bytes: 632

```text
# PLAYBOOK_SUMMARY（次の指示サマリ） v1.0

本書は docs/MEP/PLAYBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
生成: docs/MEP/build_playbook_summary.py

---

## カード一覧
- CARD-00: 新チャット開始（最短の開始入力）
- CARD-01: docs/MEP を更新する（最小PRで進める）
- CARD-02: no-checks（表示待ち）に遭遇した
- CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
- CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
- CARD-05: Head branch is out of date（behind/out-of-date）
- CARD-06: DIRTY（自動停止すべき状態）
```


---

### FILE: docs/MEP/RUNBOOK.md
- sha256: f2cbc838b1d1c7b9eafa1655065c748d3e26a756692577b10cb42738a54becd8
- bytes: 7106

```text
# RUNBOOK（復旧カード）

本書は「異常時の復旧」をカードとして固定する。
本書は説明を行わない。評価を行わない。
目的は、観測 → 一次対応 → 停止条件 → 次の遷移 を迷いなく実行すること。

---

## CARD: no-checks（Checksがまだ出ない／表示されない）

### 観測
- PR の状態とChecks表示
  - `gh pr view <PR> --json number,state,url,headRefName,baseRefName,mergeable --jq '.'`
  - `gh pr checks <PR>`
- GitHub 側の遅延か、ワークフロー未発火かを切り分ける

### 一次対応
- しばらく待って再観測（短時間で出ることがある）
- `gh pr checks <PR>` が永続的に空なら、RUNBOOK: Guard / Scope / token 起因を疑う

### 停止条件（DIRTYへ遷移）
- 何度観測してもChecksが出ない／「No checks」のまま変化しない

### 次の遷移
- `CARD: Guard NG` または `CARD: Scope不足` を適用（観測結果により決定）
- それでも不明なら `CARD: DIRTY`

---

## CARD: behind / out-of-date（Head branch is out of date）

### 観測
- PR 画面で “Head branch is out of date” 表示
- `gh pr view <PR> --json mergeable,baseRefOid,headRefOid --jq '.'`

### 一次対応
- 原則：main を取り込んで更新（rebase/merge は運用規約に従う）
- 自動で安全に解決できない場合は DIRTY に落とす

### 停止条件（DIRTYへ遷移）
- 競合が発生する／解決に人間判断が必要

### 次の遷移
- 解消できたら PLAYBOOK の該当カードへ復帰
- 解消できないなら `CARD: DIRTY`

---

## CARD: DIRTY（自動で安全に解決できない）

### 観測
- `git status --porcelain` が空でない
- 差分が「意図した範囲」外へ漏れている
- どのカードにも機械的に当てはまらず、人間判断が必要

### 一次対応
- 自動実行を停止する（これ以上進めない）
- 停止理由を分類し、人間入力に変換する（最大3点）

### 停止条件（固定）
- 以後の自動PR作成は行わない

### 次の遷移
- PLAYBOOK へ戻す前に、人間が「採るべき方針」を確定させる

---

## CARD: Scope不足（Scope Guard / Scope-IN Suggest）

### 観測
- Scope Guard が NG
- 変更対象が Scope-IN に含まれていない

### 一次対応
- CURRENT_SCOPE に必要最小限の Scope-IN を追加する（1PR）
- 余計なパスを増やさない

### 停止条件（DIRTYへ遷移）
- どのパスを許可すべきか、人間判断が必要

### 次の遷移
- Scope PR が通ったら、元の目的PRへ復帰

---

## CARD: Guard NG（Chat Packet Guard / Docs Index Guard 等）

### 観測
- Guard のチェック名とログで NG 理由を確定
- 典型：生成物が outdated / 参照不整合 / 期待ファイル不足

### 一次対応
- main 最新から「生成物を再生成して整合」させる（差分最小）
- 必要なら `docs/MEP/build_*` を実行して追随させる

### 停止条件（DIRTYへ遷移）
- 追随しても原因が解消しない
- 参照の正が不明で人間判断が必要

### 次の遷移
- 解消できたら PLAYBOOK へ復帰
- 解消できないなら DIRTY

---

## CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

### 症状
- PowerShell/端末が落ちた
- rebase/merge/cherry-pick が途中で止まった
- 状況が不明だが、安全に観測へ戻りたい

### 目的
- ローカルの途中状態を安全に解除し、DIRTY を検出したら停止する
- Continue Target（open PR → failing checks → RUNBOOK）へ戻す

### 手順（PowerShell 単一コピペ）
~~~powershell
$ErrorActionPreference = "Stop"
$repo = (gh repo view --json nameWithOwner -q .nameWithOwner)

& git rebase --abort 2>$null | Out-Null
& git merge --abort 2>$null | Out-Null
& git cherry-pick --abort 2>$null | Out-Null

$porcelain = (& git status --porcelain)
if (-not [string]::IsNullOrWhiteSpace($porcelain)) {
  git status
  throw "DIRTY: 未コミット変更あり（人間判断へ）"
}

git checkout main | Out-Null
git pull --ff-only | Out-Null

gh pr list --repo $repo --state open
~~~

### 判定
- DIRTY が出たら停止して人間判断へ
- clean なら観測に復帰

## CARD-BOOT: One-Packet Bootstrap（新チャット/新アカウント向け）
- 実行：`.\tools\mep_chat_packet_min.ps1` を実行し、出力を貼る。
- AI：個別ファイル要求は禁止。必要なら再貼付のみ要求する。

<!-- CARD: BUSINESS_IMPL_GO_NOGO -->

## CARD: BUSINESS_IMPL_GO_NOGO（業務系へ進むGo/No-Go）

### 観測
- open PR が 0 か
  - `gh pr list --state open`
- Phase-1（PARTS/EXPENSE）の marker が origin/main に揃っているか（唯一の正で確認）
  - `git show origin/main:platform/MEP/03_BUSINESS/よりそい堂/business_spec.md`
  - `git show origin/main:platform/MEP/03_BUSINESS/よりそい堂/business_master.md`
  - `git show origin/main:platform/MEP/03_BUSINESS/よりそい堂/ui_master.md`
  - `git show origin/main:platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md`

### 一次対応（PowerShell 単一コピペ）
~~~powershell
$ErrorActionPreference="Stop"
$repo = (gh repo view --json nameWithOwner -q .nameWithOwner)

git checkout main | Out-Null
git pull --ff-only | Out-Null
if (git status --porcelain) { git status; throw "NO-GO: working tree not clean" }

$open = (gh pr list --repo $repo --state open --json number,title,headRefName | ConvertFrom-Json)
if ($open.Count -ne 0) { $open | Format-Table -AutoSize; throw "NO-GO: open PR exists" }

$need = @(
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/business_spec.md";  marker="<!-- PARTS_SPEC_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/business_master.md"; marker="<!-- PARTS_FIELDS_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/ui_master.md";       marker="<!-- PARTS_UI_MASTER_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md";         marker="<!-- PARTS_FLOW_PHASE1 -->" },

  @{ file="platform/MEP/03_BUSINESS/よりそい堂/business_spec.md";  marker="<!-- EXPENSE_SPEC_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/business_master.md"; marker="<!-- EXPENSE_FIELDS_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/ui_master.md";       marker="<!-- EXPENSE_UI_MASTER_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md";         marker="<!-- EXPENSE_FLOW_PHASE1 -->" }
)

$ng=@()
foreach($x in $need){
  $txt = (git show ("origin/main:{0}" -f $x.file) | Out-String)
  if ($txt -notmatch [regex]::Escape($x.marker)) { $ng += "$($x.file) :: $($x.marker)" }
}

if ($ng.Count -ne 0) { $ng | ForEach-Object { "MISSING: $_" }; throw "NO-GO: missing markers" }
"GO: Business implementation can proceed."
~~~

### 停止条件（NO-GO）
- open PR が 1本でもある
- marker が欠けている
- working tree が dirty

### 次の遷移（GO）
- 業務系（実装・運用側）へ進む（Phase-1 を前提として進める）
```


---

### FILE: docs/MEP/RUNBOOK_SUMMARY.md
- sha256: c78aacf6e55e619444c1e9a7a8890ae38172f8e87458764670b9104034d611ed
- bytes: 289

```text
# RUNBOOK_SUMMARY（復旧サマリ） v1.0

本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
生成: docs/MEP/build_runbook_summary.py

---

## カード一覧
- CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
```


---

### FILE: docs/MEP/STATE_CURRENT.md
- sha256: 12774da6924ea9aa229f01c6902341a613a8405fa671e195e68b5a25869c586f
- bytes: 2298

```text
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
- 2026-01-06: (GAS) B17-1 verified: Request.upsert_open_dedupe links Recovery_Queue.requestRef when recoveryRqKey (==rqKey) is provided; policy A = overwrite forbidden (CONFLICT).
- 2026-01-06: (GAS) B17-1 linkageStatus fixed: LINKED | NOT_FOUND_RECOVERY | CONFLICT | ERROR; dryRun=true => op=noop (no writes).
- 2026-01-06: (GAS) WRITE endpoint is B16-1 (Recovery_Queue upsert + Request upsert_open_dedupe + resolve_request): https://script.google.com/macros/s/AKfycbzZtrlz9MIMPNn7RQoO-SIUrtJvtOBPLACFxuzCIYhcQbzkQ7xYN79AukEV9eIyB3KCfQ/exec
- 2026-01-06: (GAS) Spreadsheet ID (Ledger): 1VWqQXs9HAvZQ7K9fKXa4M0BHrvvsZW8qZBJHqoCCE3I (Sheets: Recovery_Queue / Request)
- 2026-01-06: (NEXT) B17: Recovery_Queue ↔ Request linkage (requestRef/recoveryRqKey) in write endpoint
- 2026-01-06: (GAS) WRITE endpoint is B16-1 (Recovery_Queue upsert + Request upsert_open_dedupe + resolve_request): https://script.google.com/macros/s/AKfycbzZtrlz9MIMPNn7RQoO-SIUrtJvtOBPLACFxuzCIYhcQbzkQ7xYN79AukEV9eIyB3KCfQ/exec
- 2026-01-05: (PR #509) tools/mep_integration_compiler/collect_changed_files.py: accept tab-less git diff -z output (rename/copy parsing robustness)
- Build and refine Yorisoidou BUSINESS master_spec and UI spec under the above scope.
- 2026-01-05: (PR #479) Decision-first（採用/不採用→採用後のみ実装）を正式採用
- 2026-01-05: (PR #483) Phase-2 Integration Contract（Todoist×ClickUp×Ledger）を business_spec に追加

## How to start a new conversation
Tell the assistant:
- "Read docs/MEP/START_HERE.md and proceed."
- (If memory=0 / new chat) paste CHAT_PACKET_MIN first (tools/mep_chat_packet_min.ps1 output).
```


---

### FILE: docs/MEP/STATE_SUMMARY.md
- sha256: d0d810b59a8cedd1eb05edc7926e47c07f950f89ab50710f5de2acce1bf17c1a
- bytes: 2129

```text
# STATE_SUMMARY（現在地サマリ） v1.0

本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
生成: docs/MEP/build_state_summary.py

---

## 目的（STATE_CURRENTから要約）
- （未取得）STATE_CURRENT.md の「目的」節を確認

---

## 参照導線（固定）
- CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
- 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
- 次の指示: docs/MEP/PLAYBOOK.md
- 復旧: docs/MEP/RUNBOOK.md
- 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）

---

## STATE_CURRENT の主要見出し
- STATE_CURRENT (MEP)
- Doc status registry（重複防止）
- CURRENT_SCOPE (canonical)
- Guards / Safety
- Current objective
- How to start a new conversation

---

## PLAYBOOK カード一覧
- CARD-00: 新チャット開始（最短の開始入力）
- CARD-01: docs/MEP を更新する（最小PRで進める）
- CARD-02: no-checks（表示待ち）に遭遇した
- CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
- CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
- CARD-05: Head branch is out of date（behind/out-of-date）
- CARD-06: DIRTY（自動停止すべき状態）

---

## RUNBOOK カード一覧
- CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

---

## INDEX の主要見出し
- MEP INDEX（入口） v1.0
- 参照順（固定）
- Links
- RUNBOOK（復旧カード）
- PLAYBOOK（次の指示）
- STATE_SUMMARY（現在地サマリ）
- PLAYBOOK_SUMMARY（次の指示サマリ）
- RUNBOOK_SUMMARY（復旧サマリ）
- UPGRADE_GATE（開始ゲート）
- HANDOFF_100（引継ぎ100点）
- REQUEST_BUNDLE（追加要求ファイル束）
- IDEA_VAULT（アイデア避難所）
- IDEA_INDEX（統合用一覧）
- IDEA_RECEIPTS（実装レシート）
- Tools
- Lease / Continue Target（追加）
- RUNBOOK（追加）
- DOC_STATUS（追加）
```


---

### FILE: docs/MEP/UPGRADE_GATE.md
- sha256: ff963d0c2903b55ec28d893a88b0fbf5b77019bb6ce2e793a98c7285760f7365
- bytes: 2309

```text
﻿# UPGRADE_GATE（開始直後の100点化ゲート）

本書は、新チャット開始直後に「引継ぎを100点へアップグレードしてから着手する」ための固定ゲートである。
目的は、迷子・矛盾・誤参照を開始時点で排除し、以後の作業をカード駆動で一本道にすること。

---

## 0) 入力（最小）
- まず STATE_SUMMARY（docs/MEP/STATE_SUMMARY.md）を貼る
- 追加が必要な場合のみ、AIは REQUEST 形式（最大3件）で要求する
- 原則の追加入力順：CHAT_PACKET → STATE_CURRENT → PLAYBOOK/RUNBOOK

---

## 1) ゲート手順（AIが必ず実施）
1. 矛盾検出（引継ぎ/CHAT_PACKET/STATE_* の衝突を抽出）
2. 観測コマンド提示（読むだけ・ID手入力禁止・PowerShell単一コピペ）
3. 次の一手カード確定（PLAYBOOK/RUNBOOK の該当カードへリンク）
4. 作業開始（1PR単位で小さく）

---

## 2) 出力要件（契約）
- 出力は PowerShell単一コピペ一本道 を原則とする
- ID/番号の手入力・差し替えは禁止（ghで自動解決）
- 例外は安全性/エラー回避で分割が必須の場合のみ（STEP分割で一本道維持）
- 唯一の正：docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md

---

## 3) DoD（成立条件）
- 新チャット開始で、STATE_SUMMARY から開始できる
- 必要に応じて REQUEST（最大3件）で追加情報を取得できる
- 取得後、観測→次の一手→1PR、の一本道が成立する

---

## Lease / Continue Target（開始直後の固定手順） v1.1

開始直後、AIは必ず以下を実行する。

1) LEASE を適用する（CURRENT に含まれる：HANDOFF_ID / HANDOFF_OVERVIEW / CONTINUE_TARGET）
2) UPGRADE_GATE を適用する（矛盾検出 → 観測 → 次の一手カード確定）
3) CONTINUE_TARGET を決定する
   - AUTO: open PR / failing checks / RUNBOOK異常 → 1つに確定
   - FIXED: CURRENT 指定の CARD-ID を優先（ただし DIRTY は例外なく停止）
4) 出力は PowerShell 単一コピペ一本道（ID手入力禁止、ghで自動解決）
5) 1サイクルは「観測 → 1PR」まで（複数PR同時進行は禁止）

本手順に違反した場合は LEASE_BREAK として DIRTY 扱いで停止する。
```


---

### FILE: platform/MEP/03_BUSINESS/tictactoe/master_spec.md
- sha256: e7a82f7a6240f473815a656b55985d6146bdbb7da38901862f4e218f7d4009a3
- bytes: 605

```text
# TicTacToe Specification

## 概要
本仕様は、コンソールで動作する〇×ゲームを生成するための仕様である。

注記：本業務には console版（code/tictactoe.py）と、参考UI版（ui/index.html）が同梱される。


## 盤面
- 3x3 のマス
- 初期状態はすべて空白

## プレイヤー
- プレイヤー1：X
- プレイヤー2：O

## 勝利条件
- 横・縦・斜めのいずれかが揃った場合に勝利

## 入力
- 行と列を数値で指定する（各 1〜3）

## 出力
- 毎ターン盤面を表示
- 勝敗または引き分けを表示
```


---

### FILE: platform/MEP/03_BUSINESS/よりそい堂/00_CURRENT_SCOPE_NOTE.md
- sha256: 3c6b2d913dbd817f451daad29881d8cd1706ba0ea782d3def42b922187d6d751
- bytes: 588

```text
﻿# CURRENT_SCOPE NOTE（よりそい堂）

本ファイルは運用メモであり、業務仕様（master_spec / spec / ui_spec）の意味を変更しない。
CURRENT_SCOPE: platform/MEP/03_BUSINESS/よりそい堂/

運用ルール:
- 1テーマ=1ブランチ=1PR（混在禁止）
- main が唯一の正。確定は PR が必須Checks合格の上で main にマージされた時点のみ。
- 原則として 03_BUSINESS 配下のみを変更する。
- 未定義参照が出た場合は、まず参照修正を優先し、SYMBOLS追加は例外として人間判断で行う。
```


---

### FILE: platform/MEP/03_BUSINESS/よりそい堂/01_INDEX.md
- sha256: 7b62b617592855e1d52f8f0f199100acfdd9f5d53435a8db1ad4ec56abcedb0e
- bytes: 1203

```text
﻿# INDEX (CURRENT_SCOPE: Yorisoidou BUSINESS)

This file is navigation-only. It does NOT change the meaning of business specifications.

Entry points:
- master_spec: ./master_spec
- ui_spec: ./ui_spec.md
- scope note: ./00_CURRENT_SCOPE_NOTE.md

Rule:
- 1 theme = 1 branch = 1 PR
- Canonical is main after merge (not this PR conversation)

## 唯一の正（実体）
- platform/MEP/03_BUSINESS/よりそい堂/master_spec（拡張子なし）

## 入口
- platform/MEP/03_BUSINESS/よりそい堂/master_spec.md（案内専用）

## 分離（Phase-1）: 4ファイル構成

### 役割（固定）
- 唯一の正（実体・当面）：platform/MEP/03_BUSINESS/よりそい堂/master_spec（拡張子なし）
- BUSINESS_MASTER: platform/MEP/03_BUSINESS/よりそい堂/business_master.md
- BUSINESS_SPEC:   platform/MEP/03_BUSINESS/よりそい堂/business_spec.md
- UI_MASTER:       platform/MEP/03_BUSINESS/よりそい堂/ui_master.md
- UI_SPEC:         platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md

### フェーズ方針
- Phase-1: 追加のみ（参照切替なし／既存の意味を変えない）
- Phase-2: 参照切替（監査・生成・RUNBOOKの参照先を4本へ移行）
```


---

### FILE: platform/MEP/03_BUSINESS/よりそい堂/03_TODO.md
- sha256: 6613a293d452a2910a420626f9c51d4e62979a1b12877c4f8976cc7d74f94e31
- bytes: 242

```text
﻿# TODO candidates (extracted from ui_spec.md)

This file is generated as a navigation/worklist only. It does NOT change business meaning.

Source:
- platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md

Hits:
- (none found by keyword scan)
```


---

### FILE: platform/MEP/03_BUSINESS/よりそい堂/04_DOC_EXAMPLE_STATUS.md
- sha256: 2073ceb9e3d28e67d425a7f1eb891577684235111f3c8826b45669f63eafb7f3
- bytes: 79745

```text
﻿# DOC example status (CURRENT_SCOPE)

This file is report-only. It does NOT change business meaning.

Target:
- platform/MEP/03_BUSINESS/よりそい堂/master_spec

Status:
- Found 1 line(s) matching 'DOC example:'.

Hits:
- 1: <!-- CURRENT_SCOPE: platform/MEP/03_BUSINESS/yorisoidou/ NOTE: operational note only; does NOT change master_spec meaning. RULE: 1 theme = 1 PR; canonical is main after merge. -->  <!-- LAYER: L2 -->  <!-- FOUNDATION_REF: MEP/foundation/FOUNDATION_SPEC.md -->  <!-- NOTE: This specification must conform to FOUNDATION_SPEC -->    隨倥・master_spec繝ｻ莠･鬮ｪ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣郢晢ｽｻ陞ｳ謔溘・霑夊肩・ｽ諛茨ｽ･・ｭ陷榊姓・ｻ蠅難ｽｧ蛟･繝ｻ陷閧ｴ・ｧ蛹ｺ繝ｻ繝ｻ荳橸ｽｾ・ｩ陷医・豐ｿ繝ｻ繝ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 0. 隶弱ｊ・ｦ竏壹・郢ｧ・ｳ郢晢ｽｳ郢ｧ・ｻ郢晏干繝ｨ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  隴幢ｽｬ闔牙｢難ｽｧ菫ｶ蠍後・繝ｻaster_spec繝ｻ蟲ｨ繝ｻ邵ｲ竏夲ｽ育ｹｧ鄙ｫ笳守ｸｺ繝ｻ・ｰ繝ｻ隶鯉ｽｭ陷榊揃繝ｻ陷榊供蝟ｧ郢ｧ・ｷ郢ｧ・ｹ郢昴・ﾎ堤ｸｺ・ｫ邵ｺ鄙ｫ・郢ｧ繝ｻ 邵ｲ譴ｧ・･・ｭ陷榊雀繝ｻ陞ｳ・ｹ郢晢ｽｻ隶鯉ｽｭ陷榊生繝ｧ郢晢ｽｼ郢ｧ・ｿ郢晢ｽｻ隶鯉ｽｭ陷榊生繝ｵ郢晢ｽｭ郢晢ｽｼ郢晢ｽｻ隶鯉ｽｭ陷榊姓・ｸ鄙ｫ繝ｻ陋ｻ・ｶ驍上・ﾂ髦ｪ・定叉ﾂ髮具ｽｫ邵ｺ蜉ｱ窶ｻ陞ｳ螟ゑｽｾ・ｩ邵ｺ蜷ｶ・・隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ蛟･繝ｻ陷夲ｽｯ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣邵ｺ・ｧ邵ｺ繧・ｽ狗ｸｲ繝ｻ  隴幢ｽｬ闔牙｢難ｽｧ蛟･繝ｻ騾ｶ・ｮ騾ｧ繝ｻ・ｼ繝ｻ 郢晢ｽｻ霑ｴ・ｾ陜｣・ｴ隶鯉ｽｭ陷榊生繝ｻ髴托ｽｷ邵ｺ繝ｻ繝ｻ陷讎翫・陷牙ｸ吶・陋ｻ・､隴・ｽｭ郢晄ｺ倥○郢ｧ蛛ｵ縺樒ｹ晢ｽｭ邵ｺ・ｫ邵ｺ蜷ｶ・・郢晢ｽｻ驍ゑｽ｡騾・・・･・ｭ陷榊生・定ｿｴ・ｾ陜｣・ｴ邵ｺ荵晢ｽ芽崕繝ｻ・企ｫｮ・｢邵ｺ蜉ｱﾂ竏ｫ螻ｮ騾ｹ・｣陷ｿ・ｯ髢ｭ・ｽ邵ｺ・ｫ邵ｺ蜷ｶ・・郢晢ｽｻ隶鯉ｽｭ陷榊雀・ｱ・･雎・ｽｴ郢ｧ雋橸ｽｮ謔溘・髴托ｽｽ髴搾ｽ｡陷ｿ・ｯ髢ｭ・ｽ邵ｺ・ｪ陟厄ｽ｢邵ｺ・ｧ闖ｫ譎・亜邵ｺ蜷ｶ・・郢晢ｽｻ郢ｧ・ｷ郢ｧ・ｹ郢昴・ﾎ堤ｸｺ・ｫ關捺剌・ｭ蛟･笳狗ｸｺ螢ｹﾂ竏ｵ・･・ｭ陷榊生笳守ｸｺ・ｮ郢ｧ繧・・郢ｧ雋槭・霑ｴ・ｾ陷ｿ・ｯ髢ｭ・ｽ邵ｺ・ｫ邵ｺ蜷ｶ・・ 0.1 郢ｧ・ｷ郢ｧ・ｹ郢昴・ﾎ定惺繝ｻ 郢ｧ・ｷ郢ｧ・ｹ郢昴・ﾎ定惺謳ｾ・ｼ螢ｹ・育ｹｧ鄙ｫ笳守ｸｺ繝ｻ・ｰ繝ｻ隶鯉ｽｭ陷榊揃繝ｻ陷榊供蝟ｧ郢ｧ・ｷ郢ｧ・ｹ郢昴・ﾎ・ 0.2 陝・ｽｾ髮趣ｽ｡郢晁ｼ釆溽ｹ晢ｽｼ繝ｻ繝ｻnd-to-End繝ｻ繝ｻ 陷ｿ邇ｲ・ｳ・ｨ繝ｻ繝ｻF01繝ｻ螟青螟り｡咲ｹｧ・ｳ郢晄鱒繝ｻ繝ｻ繝ｻ髯ｦ蠕湖鍋ｹ晢ｽ｢繝ｻ繝ｻ 遶翫・鬯假ｽｧ陞ｳ・｢騾具ｽｻ鬪ｭ・ｲ繝ｻ繝ｻU_Master繝ｻ繝ｻ 遶翫・霑夲ｽｩ闔会ｽｶ騾具ｽｻ鬪ｭ・ｲ繝ｻ繝ｻP_Master繝ｻ繝ｻ 遶翫・陷ｿ邇ｲ・ｳ・ｨ騾具ｽｺ髯ｦ魃会ｽｼ繝ｻrder_ID繝ｻ繝ｻ 遶翫・霑ｴ・ｾ陜｣・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ騾墓ｻ薙・繝ｻ閧ｲ讓溯撻・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ繝ｻ繝ｻ 遶翫・驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ騾墓ｻ薙・繝ｻ閧ｲ・ｮ・｡騾・・繝ｻ鬩滓ｦ翫・郢晢ｽｻ騾ｶ・｣騾ｹ・｣繝ｻ繝ｻ 遶翫・鬩幢ｽｨ隴壼鴻蛹ｱ雎包ｽｨ郢晢ｽｻ陷讎願懸騾包ｽｨ郢晢ｽｻ驍乗ｦ雁・繝ｻ繝ｻF06繝ｻ隘ｲarts_Master繝ｻ繝ｻ 遶翫・AA騾｡・ｪ陷ｿ・ｷ隰夲ｽｽ陷・ｽｺ邵ｺ・ｨ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ陷ｷ讎頑ｸ夊ｭ擾｣ｰ 遶翫・驍乗ｦ雁・騾具ｽｻ鬪ｭ・ｲ 遶翫・BP關難ｽ｡隴ｬ・ｼ驕抵ｽｺ陞ｳ螟ｲ・ｼ繝ｻF06繝ｻ驟祈07繝ｻ繝ｻ 遶翫・闖ｴ諛茨ｽ･・ｭ陞ｳ貊灘多 遶翫・霑ｴ・ｾ陜｣・ｴ陞ｳ蠕｡・ｺ繝ｻ・ｼ莠･・ｮ蠕｡・ｺ繝ｻ・ｰ・ｱ陷ｻ螂・ｽｼ菫・・ USED陋ｹ蜴・ｽｼ蜀暦ｽｵ迹夲ｽｲ・ｻ髫ｪ莠包ｽｸ螂・ｽｼ荵玲ざ闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴夊・繝ｻSTOCK隰鯉ｽｻ邵ｺ繝ｻ 遶翫・驍ゑｽ｡騾・・・ｭ・ｦ陷ｻ鄙ｫ繝ｻ鬨ｾ・ｲ髯ｦ遒・螟り｡・遶翫・隴厄ｽｸ鬯俶ｩｸ・ｼ繝ｻOC繝ｻ莨夲ｽｼ荳茨ｽｿ・ｮ雎・ｽ｣繝ｻ繝ｻIX繝ｻ莨夲ｽｼ蜑ｰ・ｿ・ｽ陷会｣ｰ陜｣・ｱ陷ｻ螂・ｽｼ繝ｻF08繝ｻ繝ｻ 遶翫・鬮｢・ｲ髫包ｽｧ繝ｻ繝ｻV01繝ｻ繝ｻ 遶翫・陷茨ｽｨ隴√・・､諛・ｽｴ・｢繝ｻ繝ｻV02繝ｻ繝ｻ  0.3 陋ｻ・､隴・ｽｭ隶難ｽｩ邵ｺ・ｮ陷ｴ貅ｷ謠ｴ繝ｻ蝓滂ｽ･・ｭ陷榊生繝ｻ闕ｳ讎奇ｽ､逕ｻ謫・脂・ｶ繝ｻ繝ｻ 郢晢ｽｻ闖ｴ荵怜恍郢晢ｽｻID郢晢ｽｻ鬩･鮃ｹ・｡髦ｪ繝ｻ陋ｹ・ｺ陋ｻ繝ｻ繝ｻ霑･・ｶ隲ｷ荵昶・邵ｺ・ｩ邵ｺ・ｮ雎・ｽ｣陟台ｸ楪・､邵ｺ・ｯ邵ｲ竏ｵ・･・ｭ陷榊生ﾎ溽ｹｧ・ｸ郢昴・縺醍ｸｺ・ｫ郢ｧ蛹ｻ・企￡・ｺ陞ｳ螢ｹ・・ｹｧ蠕鯉ｽ・郢晢ｽｻ闔・ｺ郢晢ｽｻAI郢晢ｽｻ陞溷､慚夂ｹ昴・繝ｻ郢晢ｽｫ邵ｺ・ｯ邵ｲ竏ｵ・ｭ・｣陟台ｸ楪・､郢ｧ蝣､蟲ｩ隰暦ｽ･雎趣ｽｺ陞ｳ螢ｹ・邵ｺ・ｪ邵ｺ繝ｻ・ｼ閧ｲ・ｴ・ｰ隴壼・豁楢怎・ｺ郢晢ｽｻ騾ｶ・｣隴滂ｽｻ郢晢ｽｻ髯ｬ諛ｷ蜍ｧ邵ｺ・ｯ陷ｿ・ｯ繝ｻ繝ｻ  0.4 郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ邵ｺ・ｮ闕ｳ陋ｾ蝴ｴ陞ｻ・､郢晢ｽ｢郢昴・ﾎ昴・蝓滂ｽ･・ｭ陷榊雀・ｮ螟ゑｽｾ・ｩ繝ｻ繝ｻ 郢晢ｽｻ髫ｨ・ｬ闕ｳﾂ鬮ｫ荳ｻ・ｱ・､繝ｻ螟よｨ溯撻・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ繝ｻ莠･・ｮ蠕｡・ｺ繝ｻ・ｰ・ｱ陷ｻ鄙ｫ繝ｻ陷夲ｽｯ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣繝ｻ繝ｻ 郢晢ｽｻ髫ｨ・ｬ闔遒∝垓陞ｻ・､繝ｻ螟ゑｽｮ・｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ繝ｻ閧ｲ螻ｮ騾ｹ・｣郢晢ｽｻ鬩輔・・ｻ・ｶ隶諛・｡咲ｹ晢ｽｻ髫ｴ・ｦ陷ｻ髮∝･ｳ闖ｫ・｡繝ｻ繝ｻ 郢晢ｽｻ髫ｨ・ｬ闕ｳ陋ｾ蝴ｴ陞ｻ・､繝ｻ螟奇ｽ｣諛ｷ蜍ｧ髫暦ｽ｣隴ｫ謦ｰ・ｼ閧ｲ・ｴ・ｰ隴壼・豁楢怎・ｺ郢晢ｽｻ髫暦ｽ｣隴ｫ闊後・髫ｴ・ｦ陷ｻ鄙ｫ繝ｻ髢ｾ・ｪ霎滂ｽｶ隴√・・､諛・ｽｴ・｢髯ｬ諛ｷ蜍ｧ郢晢ｽｻ騾ｶ・｣隴滂ｽｻ髯ｬ諛ｷ蜍ｧ繝ｻ繝ｻ 郢晢ｽｻ隶鯉ｽｭ陷榊生ﾎ溽ｹｧ・ｸ郢昴・縺代・莠･蠎願涕・ｳ隴厄ｽｴ隴・ｽｰ繝ｻ蟲ｨ繝ｻ陝ｶ・ｸ邵ｺ・ｫ隴崢闕ｳ雍具ｽｽ髦ｪ繝ｻ驕抵ｽｺ陞ｳ螟環繝ｻ竊堤ｸｺ蜉ｱ窶ｻ隰・ｽｱ邵ｺ繝ｻ  0.5 驕ｶ・ｯ隴幢ｽｫ隴崢鬩包ｽｩ陋ｹ蜴・ｽｼ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｵ・ｱ繧托ｽｼ繝ｻ UF01邵ｲ蠑詮08繝ｻ豢ｲIX繝ｻ諢＾C繝ｻ陦・01繝ｻ陦・02 邵ｺ・ｯ邵ｲ・｣C繝ｻ荳翫○郢晄ｧｭ繝ｻ繝ｻ荳翫■郢晄じﾎ樒ｹ昴・繝ｨ邵ｺ・ｮ陷茨ｽｨ驕ｶ・ｯ隴幢ｽｫ邵ｺ・ｧ 隶鯉ｽｭ陷榊生竊楢ｬｾ・ｯ鬮ｫ諛岩・邵ｺ荵玲咎ｩ包ｽｩ邵ｺ・ｫ陷咲ｩゑｽｽ諛岩・郢ｧ荵晢ｼ・ｸｺ・ｨ邵ｲ繝ｻ 隶鯉ｽｭ陷榊揃・ｲ・ｰ髣包ｽｷ郢ｧ雋橸ｽ｢蜉ｱ・・ｸｺ蜆ｷI陷会ｽ｣陋ｹ謔ｶ繝ｻ驕問扱・ｭ・｢邵ｺ蜷ｶ・九・蝓溽・隰ｨ・ｰ陟・干繝ｻ髫募・・ｪ閧ｴﾂ・ｧ闖ｴ諠ｹ・ｸ荵昴・隰ｫ蝣ｺ・ｽ諛ｷ蟲・ｫｮ・｣郢晢ｽｻ鬩穂ｸｻ・ｺ・ｦ邵ｺ・ｪ陟輔・笆隴弱ｋ菫｣邵ｺ・ｪ邵ｺ・ｩ繝ｻ蟲ｨﾂ繝ｻ  # 隴崢驍ｨ繧・ｽｮ・｣髫ｪﾂ繝ｻ繝ｻaster_spec繝ｻ繝ｻ  ---  ## 隴幢ｽｬ隴厄ｽｸ邵ｺ・ｮ闖ｴ蜥ｲ・ｽ・ｮ邵ｺ・･邵ｺ謇假ｽｼ蝓滓咎お繧会ｽ｢・ｺ陞ｳ螟ｲ・ｼ繝ｻ  隴幢ｽｬ隴厄ｽｸ繝ｻ繝ｻaster_spec繝ｻ蟲ｨ繝ｻ邵ｲ繝ｻ  MEP 郢晏干ﾎ溽ｹｧ・ｸ郢ｧ・ｧ郢ｧ・ｯ郢晏現竊鍋ｸｺ鄙ｫ・郢ｧ繝ｻ**隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ蛟･繝ｻ陷夲ｽｯ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣繝ｻ繝ｻingle Source of Truth繝ｻ繝ｻ*邵ｺ・ｧ邵ｺ繧・ｽ狗ｸｲ繝ｻ  隴幢ｽｬ隴厄ｽｸ邵ｺ・ｯ邵ｲ繝ｻ  - MEP_PROTOCOL - INTERFACE_PROTOCOL - system_protocol - UI_PROTOCOL  邵ｺ・ｫ陞ｳ謔溘・邵ｺ・ｫ陟慕§・ｱ讒ｭ笘・ｹｧ荵敖繝ｻ  隴幢ｽｬ隴厄ｽｸ邵ｺ・ｯ邵ｲ繝ｻ  隶鯉ｽｭ陷榊生繝ｻ隲｢荳櫁｢也ｹ晢ｽｻ隶堤洸ﾂ・ｰ郢晢ｽｻ陋ｻ・､隴・ｽｭ陜難ｽｺ雋・じ繝ｻ邵ｺ・ｿ郢ｧ雋橸ｽｮ螟ゑｽｾ・ｩ邵ｺ蜉ｱﾂ繝ｻ  郢ｧ・ｷ郢ｧ・ｹ郢昴・ﾎ定崕・ｶ陟包ｽ｡郢晢ｽｻUI 髯ｦ・ｨ霑ｴ・ｾ郢晢ｽｻ陞ｳ貅ｯ・｣繝ｻ蟀ｿ雎戊ｼ費ｽ定楜螟ゑｽｾ・ｩ邵ｺ蜉ｱ竊醍ｸｺ繝ｻﾂ繝ｻ  ---  ## 雎・ｽ｣邵ｺ・ｮ陷夲ｽｯ闕ｳﾂ隲､・ｧ  隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ蛟･竊堤ｸｺ蜉ｱ窶ｻ邵ｺ・ｮ邵ｲ譴ｧ・ｭ・｣邵ｲ髦ｪ繝ｻ邵ｲ繝ｻ  **隴幢ｽｬ master_spec 邵ｺ・ｫ髫ｪ蛟ｩ・ｿ・ｰ邵ｺ霈費ｽ檎ｸｺ貅ｷ繝ｻ陞ｳ・ｹ邵ｺ・ｮ邵ｺ・ｿ**邵ｺ・ｨ邵ｺ蜷ｶ・狗ｸｲ繝ｻ  闔会ｽ･闕ｳ荵昴・邵ｲ繝ｻ  雎・ｽ｣邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ邵ｺ・ｮ陷会ｽｹ陷牙ｸ呻ｽ定ｬ問・笳・ｸｺ・ｪ邵ｺ繝ｻﾂ繝ｻ  - 隴鯉ｽｧ霑壹・master_spec - 雎｢・ｾ騾墓ｺ佩鍋ｹ晢ｽ｢郢晢ｽｻ髫ｱ・ｬ隴丞叙譫夂ｹ晢ｽｻ陷ｿ・｣鬯・ｽｭ髯ｬ諛・ｽｶ・ｳ - 陞ｳ貅ｯ・｣繝ｻ・ｸ鄙ｫ繝ｻ鬩幢ｽｽ陷ｷ蛹ｻ竊鍋ｹｧ蛹ｻ・矩囓・｣鬩･繝ｻ - UI 髯ｦ・ｨ驕会ｽｺ郢ｧ繝ｻ縺咏ｹｧ・ｹ郢昴・ﾎ定ｬ門雀陌夂ｸｺ荵晢ｽ臥ｸｺ・ｮ鬨ｾ繝ｻ・ｮ繝ｻ  ---  ## 陷蟠趣ｽｪ蟠趣ｽｨ・ｼ陷ｴ貅ｷ謠ｴ  隴幢ｽｬ隴厄ｽｸ邵ｺ・ｫ陷ｷ・ｫ邵ｺ・ｾ郢ｧ蠕鯉ｽ狗ｸｺ蜷ｶ竏狗ｸｺ・ｦ邵ｺ・ｮ髫補悪・ｴ・ｰ邵ｺ・ｯ邵ｲ繝ｻ  **OK繝ｻ荳茨ｽｿ・ｮ雎・ｽ｣繝ｻ荳樒ｎ鬮ｯ・､ 邵ｺ・ｮ隴丞ｮ茨ｽ､・ｺ騾ｧ繝ｻ繝ｻ髫ｱ蟠趣ｽｨ・ｼ**郢ｧ蝣､・ｵ蠕娯ｻ   雎・ｽ｣邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ驕抵ｽｺ陞ｳ螢ｹ・邵ｺ・ｦ邵ｺ繝ｻ・狗ｹｧ繧・・邵ｺ・ｨ邵ｺ蜷ｶ・狗ｸｲ繝ｻ  陷蟠趣ｽｪ蟠趣ｽｨ・ｼ邵ｺ霈費ｽ檎ｸｺ・ｦ邵ｺ繝ｻ竊醍ｸｺ繝ｻ・ｦ竏ｫ・ｴ・ｰ邵ｺ・ｯ邵ｲ繝ｻ  陝・ｼ懈Β邵ｺ蜉ｱ窶ｻ邵ｺ繝ｻ窶ｻ郢ｧ繝ｻ**霎滂ｽ｡陷会ｽｹ**邵ｺ・ｨ邵ｺ蜷ｶ・狗ｸｲ繝ｻ  ---  ## 髫ｪ・ｭ髫ｪ蛹ｻ竊定楜貅ｯ・｣繝ｻ繝ｻ陋ｻ繝ｻ螻ｬ  隴幢ｽｬ隴厄ｽｸ邵ｺ・ｯ邵ｲ繝ｻ  隶鯉ｽｭ陷榊揃・ｨ・ｭ髫ｪ蛹ｻ・定楜螟ゑｽｾ・ｩ邵ｺ蜷ｶ・玖ｭ√・蠍檎ｸｺ・ｧ邵ｺ繧・ｽ顔ｸｲ繝ｻ  陞ｳ貅ｯ・｣繝ｻ・ｻ蠅難ｽｧ蛟･縲堤ｸｺ・ｯ邵ｺ・ｪ邵ｺ繝ｻﾂ繝ｻ  隴幢ｽｬ隴厄ｽｸ邵ｺ・ｫ陞ｳ螟ゑｽｾ・ｩ邵ｺ霈費ｽ檎ｸｺ・ｦ邵ｺ繝ｻ竊醍ｸｺ繝ｻ・･・ｭ陷榊綜ﾑ崎惱・ｳ邵ｺ・ｯ邵ｲ繝ｻ  邵ｺ繝ｻﾂｰ邵ｺ・ｪ郢ｧ蜿･・ｮ貅ｯ・｣繝ｻ竊鍋ｸｺ鄙ｫ・樒ｸｺ・ｦ郢ｧ繧域ｲｻ騾包ｽｨ邵ｺ蜉ｱ窶ｻ邵ｺ・ｯ邵ｺ・ｪ郢ｧ蟲ｨ竊醍ｸｺ繝ｻﾂ繝ｻ  ---  ## 陞溽判蟲ｩ隰・玄・ｮ・ｵ邵ｺ・ｮ陷夲ｽｯ闕ｳﾂ隲､・ｧ  隴幢ｽｬ隴厄ｽｸ邵ｺ・ｸ邵ｺ・ｮ陞溽判蟲ｩ邵ｺ・ｯ邵ｲ繝ｻ  **diff 隴・ｽｹ陟台ｸ岩・郢ｧ蛹ｻ笆ｲ邵ｺ・ｦ邵ｺ・ｮ邵ｺ・ｿ**髫ｪ・ｱ陷ｿ・ｯ邵ｺ霈費ｽ檎ｹｧ荵敖繝ｻ  闔会ｽ･闕ｳ荵晢ｽ帝＊竏ｵ・ｭ・｢邵ｺ蜷ｶ・狗ｸｲ繝ｻ  - 陷茨ｽｨ隴√・繝ｻ隶貞玄繝ｻ - 鬩幢ｽｨ陋ｻ繝ｻ・ｷ・ｨ鬮ｮ繝ｻ - 霎滂ｽ｡髫ｪ蛟ｬ鮖ｸ陞溽判蟲ｩ  ---  ## 郢晏干ﾎ溽ｹ晏現縺慕ｹ晢ｽｫ髯ｦ譎会ｽｪ竏ｵ蜃ｾ邵ｺ・ｮ隰・ｽｱ邵ｺ繝ｻ  隴幢ｽｬ隴厄ｽｸ邵ｺ・ｨ陷ｷ繝ｻ繝ｻ郢晢ｽｭ郢晏現縺慕ｹ晢ｽｫ邵ｺ迹夲ｽ｡譎会ｽｪ竏夲ｼ邵ｺ貅ｷ・ｰ・ｴ陷ｷ蛹ｻﾂ繝ｻ  **郢晏干ﾎ溽ｹ晏現縺慕ｹ晢ｽｫ郢ｧ雋樞煤陷医・*邵ｺ蜷ｶ・狗ｸｲ繝ｻ  隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ蛟･繝ｻ邵ｲ繝ｻ  驍ｨ・ｱ雎撰ｽｻ隲､譎・ｦ郢晢ｽｻ陋ｻ・ｶ陟包ｽ｡陷ｴ貅ｷ謠ｴ邵ｺ・ｫ陟慕§・ｱ讒ｭ笘・ｹｧ荵敖繝ｻ  ---  ## 陟第・・ｶ蜷ｶ邃・ｸｺ・ｨ陷蜥ｲ讓溯ｫ､・ｧ  陟第・・ｶ蜷ｶ邃・ｭ弱ｅ竊鍋ｸｺ・ｯ邵ｲ繝ｻ  **陷茨ｽｨ隴√・縺慕ｹ晄鱒繝ｻ陷ｿ・ｯ髢ｭ・ｽ邵ｺ・ｪ master_spec**郢ｧ繝ｻ  陟｢繝ｻ・ｰ蝓溘・隴ｫ諛・ｻ・ｸｺ・ｨ邵ｺ蜷ｶ・狗ｸｲ繝ｻ  髫補悪・ｴ繝ｻ繝ｻ隰壽㏍・ｲ荵昴・陷蜥ｲ・ｷ・ｨ鬮ｮ繝ｻ竊鍋ｹｧ蛹ｻ・玖第・・ｶ蜷ｶ邃・ｸｺ・ｯ霎滂ｽ｡陷会ｽｹ邵ｺ・ｨ邵ｺ蜷ｶ・狗ｸｲ繝ｻ  ---  ## 隴崢驍ｨ繧・ｽｮ・｣髫ｪﾂ  隴幢ｽｬ陞ｳ・｣髫ｪﾂ郢ｧ蛛ｵ・らｸｺ・｣邵ｺ・ｦ邵ｲ繝ｻ  MEP 郢晏干ﾎ溽ｹｧ・ｸ郢ｧ・ｧ郢ｧ・ｯ郢晏現竊鍋ｸｺ鄙ｫ・郢ｧ繝ｻ  隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ蛟･繝ｻ雎・ｽ｣郢晢ｽｻ陞溽判蟲ｩ隴・ｽｹ雎戊ｼ斐・陷・ｽｪ陷育｣ｯ・ｰ繝ｻ・ｽ髦ｪ繝ｻ   **驕抵ｽｺ陞ｳ繝ｻ*邵ｺ・ｨ邵ｺ蜷ｶ・狗ｸｲ繝ｻ  邵ｺ阮呻ｽ瑚脂・･鬮ｯ髦ｪ繝ｻ隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ莨懶ｽ､逕ｻ蟲ｩ邵ｺ・ｯ邵ｲ繝ｻ  隴幢ｽｬ陞ｳ・｣髫ｪﾂ郢ｧ雋樒√隰闊娯・邵ｺ蜉ｱ笳・**陋ｻ・･郢晁ｼ斐♂郢晢ｽｼ郢ｧ・ｺ**邵ｺ・ｨ邵ｺ蜷ｶ・狗ｸｲ繝ｻ  ---    隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 1. 隶鯉ｽｭ陷榊揃・ｨ・ｭ陞ｳ螟ｲ・ｼ繝ｻusiness CONFIG繝ｻ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  1.1 陜難ｽｺ隴幢ｽｬ鬯・・蟯ｼ繝ｻ蝓滂ｽ･・ｭ陷榊揃・ｨ・ｭ陞ｳ螢ｹ竊堤ｸｺ蜉ｱ窶ｻ邵ｺ・ｮ隲｢荳櫁｢悶・繝ｻ 郢晢ｽｻ郢ｧ・ｷ郢ｧ・ｹ郢昴・ﾎ定惺繝ｻ 郢晢ｽｻ陝ｷ・ｴ陟趣ｽｦ繝ｻ荳茨ｽｼ螟奇ｽｨ蝓滓ｦ繝ｻ莠･・ｹ・ｴ陟趣ｽｦ陋ｻ繝ｻ蟠帷ｹ晢ｽｻ闖ｫ譎擾ｽｭ莨懊・陋ｻ繝ｻ蟠帷ｸｺ・ｫ鬮｢・｢郢ｧ荳奇ｽ玖ｮ鯉ｽｭ陷榊綜・ｦ繧・ｽｿ・ｵ繝ｻ繝ｻ 郢晢ｽｻ郢ｧ・ｿ郢ｧ・､郢晢｣ｰ郢ｧ・ｾ郢晢ｽｼ郢晢ｽｳ繝ｻ蝓滂ｽ･・ｭ陷榊綜蠕玖ｭ弱ｅ繝ｻ陜難ｽｺ雋・私・ｼ繝ｻ 郢晢ｽｻ驕橸ｽｼ陷呈ｦ奇ｽｯ・ｾ髮趣ｽ｡隴帶ｻ・ｿ｣繝ｻ莠･・ｹ・ｴ陟趣ｽｦ繝ｻ繝ｻ  1.2 郢晄じﾎ帷ｹ晢ｽｳ郢昜ｼ夲ｽｼ蝓滂ｽ･・ｭ陷榊雀閻ｰ闖ｴ謳ｾ・ｼ繝ｻ 郢晢ｽｻ郢晄じﾎ帷ｹ晢ｽｳ郢晏ｳｨ繝ｻ隶鯉ｽｭ陷榊雀閻ｰ闖ｴ髦ｪ縲定崕繝ｻ蟠幄愾・ｯ髢ｭ・ｽ 郢晢ｽｻ郢晄じﾎ帷ｹ晢ｽｳ郢晏ｳｨ・・ｸｺ・ｨ邵ｺ・ｫ鬯假ｽｧ陞ｳ・｢郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ郢晢ｽｻ鬩幢ｽｨ隴夊・窶ｲ霑｢・ｬ驕ｶ荵昶・郢ｧ蜈ｷ・ｼ繝ｻD隰暦ｽ･鬯・ｽｭ髴取ｧｭ繝ｻ陷ｿ・ｰ陝ｶ・ｳ陷ｿ繧峨・邵ｺ謔溘・鬮ｮ・｢邵ｺ霈費ｽ檎ｹｧ蜈ｷ・ｼ繝ｻ  1.3 郢晁ｼ斐°郢晢ｽｼ郢晢｣ｰ闕ｳﾂ髫包ｽｧ繝ｻ蝓滂ｽ･・ｭ陷榊雀繝ｻ陷ｿ・｣繝ｻ繝ｻ 郢晢ｽｻUF01繝ｻ莠･螂ｳ雎包ｽｨ繝ｻ繝ｻ 郢晢ｽｻUF06繝ｻ閧ｲ蛹ｱ雎包ｽｨ繝ｻ蜀暦ｽｴ讎雁・繝ｻ繝ｻ 郢晢ｽｻUF07繝ｻ莠包ｽｾ・｡隴ｬ・ｼ陷茨ｽ･陷牙ｹ｢・ｼ繝ｻ 郢晢ｽｻUF08繝ｻ驛・ｽｿ・ｽ陷会｣ｰ陜｣・ｱ陷ｻ螂・ｽｼ繝ｻ 郢晢ｽｻFIX繝ｻ莠包ｽｿ・ｮ雎・ｽ｣騾包ｽｳ髫ｲ蜈ｷ・ｼ繝ｻ 郢晢ｽｻDOC繝ｻ蝓溷ｶ碁ｬ俶ｧｭﾎ懃ｹｧ・ｯ郢ｧ・ｨ郢ｧ・ｹ郢晁肩・ｼ繝ｻ 郢晢ｽｻOV01繝ｻ逎ｯ螟｢髫包ｽｧ郢ｧ・ｫ郢晢ｽｫ郢昴・・ｼ繝ｻ 郢晢ｽｻOV02繝ｻ莠･繝ｻ隴√・・､諛・ｽｴ・｢繝ｻ繝ｻ  1.4 maintenanceMode繝ｻ蝓滂ｽ･・ｭ陷榊衷蝎ｪ郢晢ｽ｡郢晢ｽｳ郢昴・繝ｪ郢晢ｽｳ郢ｧ・ｹ繝ｻ繝ｻ maintenanceMode: true/false true 邵ｺ・ｮ陜｣・ｴ陷ｷ闌ｨ・ｼ繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ繝ｻ蜀怜験雎包ｽｨ繝ｻ蜀暦ｽｴ讎雁・繝ｻ荳茨ｽｾ・｡隴ｬ・ｼ陷茨ｽ･陷牙ｹ｢・ｼ蜑ｰ・ｿ・ｽ陷会｣ｰ陜｣・ｱ陷ｻ鄙ｫ竊醍ｸｺ・ｩ邵ｲ譴ｧ蟲ｩ隴・ｽｰ驍会ｽｻ隶鯉ｽｭ陷榊生ﾂ髦ｪ・定屁諛茨ｽｭ・｢邵ｺ蜷ｶ・・郢晢ｽｻ鬮｢・ｲ髫包ｽｧ繝ｻ繝ｻV01/OV02繝ｻ蟲ｨ笙郢ｧ蛹ｻ繝ｻ隰ｨ・ｴ陷ｷ蝓淞・ｧ隶諛域ｸ顔ｹｧ雋樞煤陷亥現笘・ｹｧ繝ｻ 郢晢ｽｻ鬩･蟠趣ｽｦ竏墅溽ｹｧ・ｰ髫ｪ蛟ｬ鮖ｸ邵ｺ・ｯ驍ｯ蜥擾ｽｶ螢ｹ笘・ｹｧ繝ｻ 隰ｫ蝣ｺ・ｽ諛・繝ｻ・ｼ蝓滂ｽ･・ｭ陷榊綜・ｨ・ｩ鬮ｯ謦ｰ・ｼ莨夲ｽｼ螢ｽ諤呵叉雍具ｽｽ蜥ｲ・ｮ・｡騾・・ﾂ繝ｻ繝ｻ邵ｺ・ｿ  1.5 隶難ｽｩ鬮ｯ闊湖溽ｹ晢ｽｼ郢晢ｽｫ繝ｻ蝓滂ｽ･・ｭ陷榊雀・ｽ・ｹ陷托ｽｲ繝ｻ繝ｻ guest / viewer / operator / staff / manager / admin / config-admin-primary / config-admin-secondary 郢晢ｽｻ陟厄ｽｹ陷托ｽｲ邵ｺ・ｯ邵ｲ譴ｧ・･・ｭ陷榊綜譯・抄諛翫・陷ｿ・ｯ陷ｷ・ｦ邵ｲ髦ｪ・定楜螟ゑｽｾ・ｩ邵ｺ蜷ｶ・・郢晢ｽｻ隶難ｽｩ鬮ｯ闊後・隰堋髯ｦ骰句飭髫ｱ・ｬ隴丞ｼｱ繝ｻ隴幢ｽｬ隴厄ｽｸ邵ｺ・ｫ陷ｷ・ｫ郢ｧ竏壺・邵ｺ繝ｻ・ｼ蝓滂ｽ･・ｭ陷榊姓・ｸ鄙ｫ繝ｻ陷ｿ・ｯ陷ｷ・ｦ邵ｺ・ｮ邵ｺ・ｿ繝ｻ繝ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 2. ID闖ｴ骰具ｽｳ・ｻ繝ｻ蝓滂ｽ･・ｭ陷榊雀・･驢搾ｽｴ繝ｻ・ｽ諛ｷ・ｮ謔溘・繝ｻ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  隴幢ｽｬ驕ｶ・ｰ邵ｺ・ｯ邵ｲ竏ｵ・･・ｭ陷榊姓・ｸ鄙ｫﾂ蠕｡・ｸﾂ隲｢蜑ｰ・ｭ莨懈肩郢晢ｽｻ髴托ｽｽ髴搾ｽ｡郢晢ｽｻ隰暦ｽ･驍ｯ螢ｹﾂ髦ｪ・定ｬ悟鴻・ｫ荵晢ｼ・ｸｺ蟶呻ｽ玖桙驢搾ｽｴ繝ｻ竊堤ｸｺ蜉ｱ窶ｻ陜暦ｽｺ陞ｳ螢ｹ・・ｹｧ蠕鯉ｽ狗ｸｲ繝ｻ ID 邵ｺ・ｯ隶鯉ｽｭ陷榊雀・ｱ・･雎・ｽｴ邵ｺ・ｮ隴滂ｽｱ邵ｺ・ｧ邵ｺ繧・ｽ顔ｸｲ竏昴・陋ｻ・ｩ騾包ｽｨ郢晢ｽｻ隰ｾ・ｹ陞溷ｳｨ繝ｻ陷蜥ｲ蛹ｱ騾｡・ｪ郢ｧ蝣､・ｦ竏ｵ・ｭ・｢邵ｺ蜷ｶ・狗ｸｲ繝ｻ  2.1 鬯假ｽｧ陞ｳ・｢ID繝ｻ繝ｻU_ID繝ｻ繝ｻ 隲｢荳櫁｢悶・螟撰ｽ｡・ｧ陞ｳ・｢郢ｧ蜻茨ｽｰ・ｸ驍ｯ螢ｹ竊馴垓莨懈肩邵ｺ蜷ｶ・・郢晁ｼ斐°郢晢ｽｼ郢晄ｧｭ繝｣郢晁肩・ｼ蜥ｾU-AA001 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ雎鯉ｽｸ驍ｯ蜚妊 郢晢ｽｻ陷讎願懸騾包ｽｨ闕ｳ讎雁ｺ・・荳樒ｎ鬮ｯ・､闕ｳ讎雁ｺ・・閧ｲ笏瑚怏・ｹ陋ｹ謔ｶ繝ｻ邵ｺ・ｿ繝ｻ繝ｻ 郢晢ｽｻ鬯假ｽｧ陞ｳ・｢邵ｺ・ｫ驍剰・笆ｼ邵ｺ蜀鈴ｻ・脂・ｶ邵ｺ・ｯ UP_ID 邵ｺ・ｧ髯ｦ・ｨ霑ｴ・ｾ邵ｺ蜷ｶ・・ 2.2 霑夲ｽｩ闔会ｽｶID繝ｻ繝ｻP_ID繝ｻ繝ｻ 隲｢荳櫁｢悶・螟撰ｽ｡・ｧ陞ｳ・｢邵ｺ・ｫ陟慕§・ｱ讒ｭ笘・ｹｧ迢鈴ｻ・脂・ｶ郢ｧ蜻茨ｽｰ・ｸ驍ｯ螢ｹ竊馴垓莨懈肩邵ｺ蜷ｶ・・郢晁ｼ斐°郢晢ｽｼ郢晄ｧｭ繝｣郢晁肩・ｼ蝠・-AA001-0001 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ雎鯉ｽｸ驍ｯ蜚妊 郢晢ｽｻ陟｢繝ｻ笘・CU_ID 邵ｺ・ｫ陟慕§・ｱ讒ｭ笘・ｹｧ繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ邵ｺ・ｯ UP_ID 邵ｺ・ｫ驍剰・笆ｼ邵ｺ謫ｾ・ｼ莠･驟碑叉ﾂ鬯假ｽｧ陞ｳ・｢邵ｺ・ｧ郢ｧ繧蛾ｻ・脂・ｶ邵ｺ遒・ｼ・ｸｺ蛹ｻ繝ｻ陋ｻ・･繝ｻ繝ｻ  2.3 陷ｿ邇ｲ・ｳ・ｨID繝ｻ繝ｻrder_ID繝ｻ繝ｻ 隲｢荳櫁｢悶・螢ｼ螂ｳ雎包ｽｨ郢ｧ螳夲ｽｭ莨懈肩邵ｺ蜷ｶ・玖ｮ鯉ｽｭ陷榊生繝ｻ闕ｳ・ｭ陟｢繝ｻ縺冗ｹ晢ｽｼ繝ｻ莠･繝ｻ隰暦ｽ･驍ｯ螟ゅ○繝ｻ繝ｻ 郢晁ｼ斐°郢晢ｽｼ郢晄ｧｭ繝｣郢晁肩・ｼ蜚ｹRDER-YYYYMMDD-00001-<UP_ID> 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ陷雁・ｽｽ髦ｪ縲帝具ｽｺ髯ｦ蠕鯉ｼ・ｹｧ蠕鯉ｽ九・逎ｯ謦ｼ雎鯉ｽｸ驍ｯ螟ｲ・ｼ繝ｻ 郢晢ｽｻ陷讎願懸騾包ｽｨ闕ｳ讎雁ｺ・郢晢ｽｻ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ繝ｻ蝓斜夊ｭ壽腸・ｼ蜀暦ｽｵ迹夲ｽｲ・ｻ繝ｻ荵怜ｶ碁ｬ俶ｩｸ・ｼ荳橸ｽｱ・･雎・ｽｴ繝ｻ荵暦ｽ､諛・ｽｴ・｢邵ｺ・ｮ闕ｳ・ｭ陟｢繝ｻ縺冗ｹ晢ｽｼ  2.4 鬩幢ｽｨ隴夊摯D繝ｻ繝ｻART_ID繝ｻ繝ｻ 隲｢荳櫁｢悶・螟石夊ｭ夊・・帝具ｽｺ雎包ｽｨ遶雁､・ｴ讎雁・遶雁宴・ｽ・ｿ騾包ｽｨ遶願ｲ樊Β陟趣ｽｫ邵ｺ・ｮ陷茨ｽｨ陝ｾ・･驕樔ｹ昴帝寞・ｫ鬨ｾ螟奇ｽｭ莨懈肩邵ｺ蜷ｶ・・郢晁ｼ斐°郢晢ｽｼ郢晄ｧｭ繝｣郢晁肩・ｼ繝ｻ 郢晢ｽｻBP繝ｻ蜥､P-YYYYMM-AAxx-PAyy 郢晢ｽｻBM繝ｻ蜥､M-YYYYMM-AAxx-MAyy 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻBP/BM 邵ｺ・ｧ闖ｴ骰具ｽｳ・ｻ邵ｺ謔溘・邵ｺ荵晢ｽ檎ｹｧ繝ｻ 郢晢ｽｻ陷讎願懸騾包ｽｨ闕ｳ讎雁ｺ・郢晢ｽｻ鬩幢ｽｨ隴壼鴻諞ｾ隲ｷ蜈ｷ・ｼ繝ｻTATUS繝ｻ蟲ｨ繝ｻ陷雁・ｽｽ繝ｻ  2.5 騾具ｽｺ雎包ｽｨ髯ｦ譬優繝ｻ繝ｻD_ID繝ｻ諛・ｽ｣諛ｷ蜍ｧ繝ｻ繝ｻ 隲｢荳櫁｢悶・螢ｼ驟碑叉ﾂ陷ｿ邇ｲ・ｳ・ｨ陷繝ｻ繝ｻ騾具ｽｺ雎包ｽｨ髯ｦ蠕鯉ｽ定叉ﾂ隲｢荳岩・髫ｴ莨懈肩邵ｺ蜷ｶ・矩勳諛ｷ蜍ｧID 郢晁ｼ斐°郢晢ｽｼ郢晄ｧｭ繝｣郢晁肩・ｼ蜚ｹD-<Order_ID>-001 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ1陷ｿ邇ｲ・ｳ・ｨ邵ｺ・ｫ髫阪・辟夊氛莨懈Β陷ｿ・ｯ髢ｭ・ｽ 郢晢ｽｻ隶鯉ｽｭ陷榊揃・ｿ・ｽ髴搾ｽ｡邵ｺ・ｮ髯ｬ諛ｷ蜍ｧ邵ｺ・ｧ邵ｺ繧・ｽ顔ｸｲ竏ｵ諤呵叉雍具ｽｽ髦ｪ繝ｻ隰暦ｽ･驍ｯ螢ｹ繝ｻ Order_ID 郢ｧ蝣､逡醍ｸｺ繝ｻ・・ 2.6 闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴夊摯D繝ｻ繝ｻX_ID繝ｻ繝ｻ 隲｢荳櫁｢悶・螢ｼ・ｮ貊・怙邵ｺ・ｫ闖ｴ・ｿ騾包ｽｨ邵ｺ霈費ｽ檎ｸｺ貊・夊ｭ壼頃・ｨ蛟ｬ鮖ｸ郢ｧ蜑・ｽｸﾂ隲｢荳岩・髫ｴ莨懈肩邵ｺ蜷ｶ・・郢晁ｼ斐°郢晢ｽｼ郢晄ｧｭ繝｣郢晁肩・ｼ蜩蝋-YYYYMM-0001 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻOrder_ID 郢ｧ雋樣ｫｪ闕ｳﾂ邵ｺ・ｮ隰暦ｽ･驍ｯ螢ｹ縺冗ｹ晢ｽｼ邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ隰・ｽｱ邵ｺ繝ｻ・ｼ繝ｻU/UP 郢ｧ蝣､蟲ｩ隰暦ｽ･隰問・笳・ｸｺ・ｪ邵ｺ繝ｻ・ｼ繝ｻ 郢晢ｽｻ陷讎願懸騾包ｽｨ闕ｳ讎雁ｺ・ 2.7 驍ｨ迹夲ｽｲ・ｻID繝ｻ繝ｻXP_ID繝ｻ繝ｻ 隲｢荳櫁｢悶・螟ゑｽ｢・ｺ陞ｳ螢ｹ・邵ｺ貅ｽ・ｵ迹夲ｽｲ・ｻ髫ｪ蛟ｬ鮖ｸ郢ｧ蜑・ｽｸﾂ隲｢荳岩・髫ｴ莨懈肩邵ｺ蜷ｶ・・郢晁ｼ斐°郢晢ｽｼ郢晄ｧｭ繝｣郢晁肩・ｼ蜩蝋P-YYYYMM-0001 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ陷ｷ譴ｧ諤ｦ陷繝ｻﾂ・｣騾｡・ｪ 郢晢ｽｻ陷讎願懸騾包ｽｨ闕ｳ讎雁ｺ・ 2.8 郢昴・縺帷ｹ昴・D繝ｻ繝ｻ騾｡・ｪ繝ｻ蟲ｨﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ蝓滂ｽ･・ｭ陷榊雀・ｮ迚吶・繝ｻ繝ｻ 闔会ｽ･闕ｳ荵昴・郢昴・縺帷ｹ昜ｺ･・ｰ繧臥舞邵ｺ・ｧ隴幢ｽｬ騾｡・ｪ陋ｻ・ｩ騾包ｽｨ闕ｳ讎雁ｺ・・繝ｻ AA00 / PA00 / MA00 / 0000 / EXP-YYYYMM-0000 / EX-YYYYMM-0000 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ郢昴・縺帷ｹ晏現繝ｧ郢晢ｽｼ郢ｧ・ｿ邵ｺ・ｯ隴幢ｽｬ騾｡・ｪ隶鯉ｽｭ陷榊生ﾂｰ郢ｧ陋ｾ蜍∬棔謔ｶ・・ｹｧ蠕鯉ｽ九・逎ｯ螟｢髫包ｽｧ郢晢ｽｻ隶諛・ｽｴ・｢郢晢ｽｻ鬮ｮ繝ｻ・ｨ蛹ｻ繝ｻ陝・ｽｾ髮趣ｽ｡陞溷私・ｼ繝ｻ 郢晢ｽｻ隴幢ｽｬ騾｡・ｪ郢昴・繝ｻ郢ｧ・ｿ邵ｺ・ｸ邵ｺ・ｮ雎ｬ竏ｫ逡鷹＊竏ｵ・ｭ・｢繝ｻ蝓滂ｽｷ・ｷ陜ｨ・ｨ邵ｺ・ｯ隶鯉ｽｭ陷榊衷・ｰ・ｴ驍ｯ・ｻ邵ｺ・ｨ邵ｺ・ｿ邵ｺ・ｪ邵ｺ蜻ｻ・ｼ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 3. 陷ｿ・ｰ陝ｶ・ｳ隶堤洸ﾂ・ｰ繝ｻ蝓滂ｽ･・ｭ陷榊生繝ｧ郢晢ｽｼ郢ｧ・ｿ郢晢ｽ｢郢昴・ﾎ昴・諛ｷ・ｮ謔溘・繝ｻ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  陷ｷ繝ｻ蠎願涕・ｳ邵ｺ・ｯ隶鯉ｽｭ陷榊姓・ｸ鄙ｫ繝ｻ隲｢荳櫁｢也ｹｧ蜻域亜邵ｺ・､陷夲ｽｯ闕ｳﾂ邵ｺ・ｮ闖ｫ譎会ｽｮ・｡陜｣・ｴ隰・邵ｺ・ｧ邵ｺ繧・ｽ顔ｸｲ竏晢ｽｱ・･雎・ｽｴ邵ｺ・ｯ陷台ｼ∝求邵ｺ蟶吮・髣｢繝ｻ・ｩ讎頑｢帷ｹｧ雋樊ｬ｡陷代・竊堤ｸｺ蜷ｶ・狗ｸｲ繝ｻ  3.1 CU_Master繝ｻ逎ｯ・｡・ｧ陞ｳ・｢陷ｿ・ｰ陝ｶ・ｳ繝ｻ繝ｻ 闕ｳ・ｻ郢ｧ・ｭ郢晢ｽｼ繝ｻ蜥ｾU_ID 闕ｳ・ｻ髫輔・・ｰ繝ｻ蟯ｼ繝ｻ蝓滂ｽ･・ｭ陷榊衷蝎ｪ隲｢荳櫁｢也ｹｧ蜻域亜邵ｺ・､陋ｻ證ｦ・ｼ莨夲ｽｼ繝ｻ CU_ID / 鬯假ｽｧ陞ｳ・｢陷ｷ繝ｻ/ 郢ｧ・ｫ郢昴・/ 陋ｹ・ｺ陋ｻ繝ｻ/ 鬮ｮ・ｻ髫ｧ・ｱ1 / 鬮ｮ・ｻ髫ｧ・ｱ2 / 郢晢ｽ｡郢晢ｽｼ郢晢ｽｫ / 鬩幢ｽｵ關難ｽｿ騾｡・ｪ陷ｿ・ｷ / 闖ｴ荵怜恍 / 隲｡繝ｻ・ｽ讌｢ﾂ繝ｻ骭・/ 雎包ｽｨ隲｢荳茨ｽｺ遏ｩ・ｰ繝ｻ/ 闖ｴ諛医・隴鯉ｽ･ / 隴厄ｽｴ隴・ｽｰ隴鯉ｽ･ / 隴帷甥譟・隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ隴鯉ｽ｢陝・・ｽｸﾂ髢ｾ・ｴ繝ｻ逎ｯ蟠暮圦・ｱ繝ｻ荵暦ｽｰ荳樣倹繝ｻ荳茨ｽｽ荵怜恍邵ｺ・ｪ邵ｺ・ｩ邵ｺ・ｮ隶鯉ｽｭ陷榊生縺冗ｹ晢ｽｼ繝ｻ蟲ｨ竊鍋ｹｧ蛹ｻ・願怙讎願懸騾包ｽｨ騾具ｽｻ鬪ｭ・ｲ郢ｧ螳夲ｽ｡蠕娯鴬邵ｺ阮吮・邵ｺ蠕娯旺郢ｧ繝ｻ 郢晢ｽｻ鬯假ｽｧ陞ｳ・｢隲繝ｻ・ｰ・ｱ邵ｺ・ｯ驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ邵ｺ・ｸ陷ｿ繧峨・騾包ｽｨ邵ｺ・ｫ陷ｿ閧ｴ荳千ｸｺ蜉ｱ窶ｻ郢ｧ蛹ｻ・槭・莠包ｽｻ・ｻ隲｢謫ｾ・ｼ繝ｻ  3.2 UP_Master繝ｻ閧ｲ鮟・脂・ｶ陷ｿ・ｰ陝ｶ・ｳ繝ｻ繝ｻ 闕ｳ・ｻ郢ｧ・ｭ郢晢ｽｼ繝ｻ蝠・_ID 陟｢繝ｻ・ｰ逎ｯ譛ｪ闖ｫ繧托ｽｼ蝠・_ID 邵ｺ・ｯ CU_ID 邵ｺ・ｫ陟慕§・ｱ繝ｻ 闕ｳ・ｻ髫輔・・ｰ繝ｻ蟯ｼ繝ｻ繝ｻ UP_ID / CU_ID / 霑夲ｽｩ闔会ｽｶ騾｡・ｪ陷ｿ・ｷ / 霑夲ｽｩ闔会ｽｶ陷ｷ繝ｻ/ 鬩幢ｽｵ關難ｽｿ騾｡・ｪ陷ｿ・ｷ / 闖ｴ荵怜恍 / 陝抵ｽｺ霑夲ｽｩ驕橸ｽｮ陋ｻ・･ / 鬩幢ｽｨ陞ｻ迢怜・陷ｿ・ｷ / 驍ゑｽ｡騾・・・ｼ螟ゑｽ､・ｾ / 雎包ｽｨ隲｢荳茨ｽｺ遏ｩ・ｰ繝ｻ/ 闖ｴ諛医・隴鯉ｽ･ / 隴厄ｽｴ隴・ｽｰ隴鯉ｽ･ / 隴帷甥譟・隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ陷ｷ蠕｡・ｸﾂ鬯假ｽｧ陞ｳ・｢繝ｻ蜿･驟碑叉ﾂ闖ｴ荵怜恍邵ｺ・ｮ陷讎願懸騾包ｽｨ騾具ｽｻ鬪ｭ・ｲ郢ｧ螳夲ｽ｡蠕娯鴬邵ｺ阮吮・邵ｺ蠕娯旺郢ｧ繝ｻ 郢晢ｽｻ霑夲ｽｩ闔会ｽｶ隲繝ｻ・ｰ・ｱ邵ｺ・ｯ驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ邵ｺ・ｸ陷ｿ繧峨・騾包ｽｨ邵ｺ・ｫ陷ｿ閧ｴ荳千ｸｺ蜉ｱ窶ｻ郢ｧ蛹ｻ・槭・莠包ｽｻ・ｻ隲｢謫ｾ・ｼ繝ｻ  3.3 Order_YYYY繝ｻ莠･螂ｳ雎包ｽｨ陷ｿ・ｰ陝ｶ・ｳ繝ｻ繝ｻ 闕ｳ・ｻ郢ｧ・ｭ郢晢ｽｼ繝ｻ蜚ｹrder_ID 闕ｳ・ｻ髫輔・・ｰ繝ｻ蟯ｼ繝ｻ繝ｻ Order_ID / UP_ID / CU_ID / 陝仙宴・ｽ阮吶＆郢晢ｽｼ郢昴・/ 鬯假ｽｧ陞ｳ・｢陷ｷ繝ｻ/ 鬮ｮ・ｻ髫ｧ・ｱ / 鬩幢ｽｵ關難ｽｿ騾｡・ｪ陷ｿ・ｷ / 闖ｴ荵怜恍 / addressFull / addressCityTown / 陝ｶ譴ｧ謔崎ｭ鯉ｽ･1 / 陝ｶ譴ｧ謔崎ｭ鯉ｽ･2 / 髫慕距・ｩ蝓ｼ竕｡鬯倥・/ 陋ｯ蜻ｵﾂ繝ｻ・ｼ繝ｻaw陷茨ｽｨ隴√・・ｼ繝ｻ/ summary / STATUS / CreatedAt / UpdatedAt / LastSyncedAt / HistoryNotes 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻHistoryNotes 邵ｺ・ｯ髢ｾ・ｪ騾包ｽｱ髫ｪ蛟ｩ・ｿ・ｰ邵ｺ・ｧ邵ｲ竏昴・鬩幢ｽｨ邵ｺ・ｮ Order_ID 邵ｺ・ｨ騾ｶ・ｸ闔雋樒崟霎｣・ｧ邵ｺ・ｧ邵ｺ髦ｪ・・郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ邵ｺ・ｮ霑･・ｶ隲ｷ蜈ｷ・ｼ繝ｻTATUS繝ｻ蟲ｨ繝ｻ隶鯉ｽｭ陷榊生繝ｵ郢晢ｽｭ郢晢ｽｼ邵ｺ・ｫ陟戊侭・樣明・ｪ陷肴坩繝ｻ驕假ｽｻ邵ｺ蜷ｶ・九・閧ｲ・ｫ・ｰ7郢晢ｽｻ9陷ｿ繧峨・繝ｻ繝ｻ  3.4 Parts_Master繝ｻ逎ｯﾎ夊ｭ壻ｻ吝ｺ願涕・ｳ繝ｻ繝ｻ 闕ｳ・ｻ郢ｧ・ｭ郢晢ｽｼ繝ｻ蝠ART_ID 闕ｳ・ｻ髫輔・・ｰ繝ｻ蟯ｼ繝ｻ繝ｻ PART_ID / AA騾｡・ｪ陷ｿ・ｷ / PA/MA騾｡・ｪ陷ｿ・ｷ / PART_TYPE繝ｻ繝ｻP/BM繝ｻ繝ｻ/ Order_ID / OD_ID / 陷ｩ竏ｫ蛻・/ 隰ｨ・ｰ鬩･繝ｻ/ 郢晢ｽ｡郢晢ｽｼ郢ｧ・ｫ郢晢ｽｼ / PRICE / STATUS / CREATED_AT / DELIVERED_AT / USED_DATE / MEMO / LOCATION 鬩幢ｽｨ隴壼ｿサATUS繝ｻ莠･蟠玖楜螟ｲ・ｼ莨夲ｽｼ繝ｻ STOCK / ORDERED / DELIVERED / USED / STOCK_ORDERED 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻLOCATION 邵ｺ・ｯ陜ｨ・ｨ陟趣ｽｫ繝ｻ繝ｻTOCK繝ｻ蟲ｨ縲定｢繝ｻ・ｰ繝ｻ 郢晢ｽｻBP 邵ｺ・ｯ驍乗ｦ雁・隴弱ｅ竊・PRICE 郢ｧ蝣､・｢・ｺ陞ｳ螢ｹ笘・ｹｧ繝ｻ 郢晢ｽｻBM 邵ｺ・ｯ PRICE=0繝ｻ閧ｲ・ｵ迹夲ｽｲ・ｻ陝・ｽｾ髮趣ｽ｡陞溷私・ｼ繝ｻ 郢晢ｽｻ鬩幢ｽｨ隴夊・繝ｻ陷ｿ邇ｲ・ｳ・ｨ陷繝ｻ・､謔ｶ縲定怙讎願懸騾包ｽｨ郢晢ｽｻ陜ｨ・ｨ陟趣ｽｫ邵ｺ・ｫ隰鯉ｽｻ郢ｧ髮・ｽｾ蜉ｱ・九・閧ｲ・ｫ・ｰ8郢晢ｽｻ9陷ｿ繧峨・繝ｻ繝ｻ  3.5 EX_Master繝ｻ莠包ｽｽ・ｿ騾包ｽｨ鬩幢ｽｨ隴壻ｻ吝ｺ願涕・ｳ繝ｻ繝ｻ 闕ｳ・ｻ郢ｧ・ｭ郢晢ｽｼ繝ｻ蜩蝋_ID 闕ｳ・ｻ髫輔・・ｰ繝ｻ蟯ｼ繝ｻ繝ｻ EX_ID / Order_ID / PART_ID / AA騾｡・ｪ陷ｿ・ｷ / PRICE / USED_DATE / MEMO 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ闖ｴ・ｿ騾包ｽｨ陞ｳ貅ｽ・ｸ・ｾ邵ｺ・ｮ驕抵ｽｺ陞ｳ螟奇ｽｨ蛟ｬ鮖ｸ 郢晢ｽｻOrder_ID 郢ｧ雋樣ｫｪ闕ｳﾂ邵ｺ・ｮ隰暦ｽ･驍ｯ螢ｹ縺冗ｹ晢ｽｼ邵ｺ・ｨ邵ｺ蜷ｶ・九・繝ｻU/UP 郢ｧ蝣､蟲ｩ隰暦ｽ･陷ｿ繧峨・邵ｺ蜉ｱ竊醍ｸｺ繝ｻ・ｼ繝ｻ  3.6 Expense_Master繝ｻ閧ｲ・ｵ迹夲ｽｲ・ｻ陷ｿ・ｰ陝ｶ・ｳ繝ｻ繝ｻ 闕ｳ・ｻ郢ｧ・ｭ郢晢ｽｼ繝ｻ蜩蝋P_ID 闕ｳ・ｻ髫輔・・ｰ繝ｻ蟯ｼ繝ｻ繝ｻ EXP_ID / Order_ID / PART_ID / CU_ID / UP_ID / PRICE / USED_DATE / CreatedAt 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻUSED 鬩幢ｽｨ隴夊・繝ｻ PRICE 郢ｧ蝣､・｢・ｺ陞ｳ螟ゑｽｵ迹夲ｽｲ・ｻ邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ髫ｪ蛟ｬ鮖ｸ邵ｺ蜷ｶ・玖悁・ｯ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣ 郢晢ｽｻ鬩･鮃ｹ・｡髦ｪ繝ｻ隰暦ｽｨ雋ゑｽｬ郢晢ｽｻ闔会ｽ｣陷茨ｽ･邵ｺ・ｯ驕問扱・ｭ・｢繝ｻ閧ｲ・｢・ｺ陞ｳ螢ｼ繝ｻ陷牙ｸ吶・邵ｺ・ｿ繝ｻ繝ｻ  3.7 Request繝ｻ閧ｲ遲城坿蜿･蠎願涕・ｳ繝ｻ蜩･IX/DOC/UF07/UF08繝ｻ繝ｻ 闕ｳ・ｻ髫輔・・ｰ繝ｻ蟯ｼ繝ｻ繝ｻ Timestamp / Category / TargetID / PayloadJSON / Requester / Memo 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ闖ｫ・ｮ雎・ｽ｣繝ｻ荵怜ｶ碁ｬ俶ｩｸ・ｼ蝓寂横鬯伜ｴ趣ｽ｣諛ｷ・ｮ魃会ｽｼ蜑ｰ・ｿ・ｽ陷会｣ｰ陜｣・ｱ陷ｻ鄙ｫ・帝包ｽｳ髫ｲ荵昶・邵ｺ蜉ｱ窶ｻ闖ｫ譎・亜邵ｺ蜷ｶ・矩ｂ・ｱ 郢晢ｽｻ陷繝ｻ・ｮ・ｹ邵ｺ・ｯ隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ邵ｺ・ｫ陟戊侭笆ｲ邵ｺ・ｦ髫暦ｽ｣鬩･蛹ｻ繝ｻ陷ｿ閧ｴ荳千ｸｺ霈費ｽ檎ｹｧ繝ｻ 郢晢ｽｻ陷奇ｽｱ鬮ｯ・ｺ闖ｫ・ｮ雎・ｽ｣邵ｺ・ｯ隴丞ｮ茨ｽ｢・ｺ邵ｺ・ｫ陋ｹ・ｺ陋ｻ・･邵ｺ蜉ｱﾂ竏ｫ蟲ｩ隰暦ｽ･鬩包ｽｩ騾包ｽｨ郢ｧ蝣､・ｦ竏ｵ・ｭ・｢邵ｺ蜷ｶ・九・閧ｲ・ｫ・ｰ10繝ｻ繝ｻ  3.8 logs/system郢晢ｽｻlogs/extra繝ｻ蝓滂ｽ･・ｭ陷榊生ﾎ溽ｹｧ・ｰ繝ｻ繝ｻ 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ鬩･蟠趣ｽｦ竏壹＞郢ｧ・ｯ郢ｧ・ｷ郢晢ｽｧ郢晢ｽｳ邵ｺ・ｯ髫ｪ蛟ｬ鮖ｸ邵ｺ蜉ｱﾂ竏晢ｽｱ・･雎・ｽｴ髴托ｽｽ髴搾ｽ｡邵ｺ・ｮ隴ｬ・ｹ隲｡・ｰ邵ｺ・ｨ邵ｺ蜷ｶ・・郢晢ｽｻ隶諛・ｽｴ・｢繝ｻ繝ｻV02繝ｻ蟲ｨ繝ｻ陝・ｽｾ髮趣ｽ｡邵ｺ・ｨ邵ｺ・ｪ郢ｧ蜈ｷ・ｼ閧ｲ・ｫ・ｰ11繝ｻ繝ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 4. 闖ｴ荵怜恍闖ｴ骰具ｽｳ・ｻ繝ｻ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  闖ｴ荵怜恍邵ｺ・ｯ闔会ｽ･闕ｳ繝ｻ隴幢ｽｬ邵ｺ・ｧ闖ｫ譎・亜邵ｺ蜷ｶ・九・繝ｻ 遶ｭ・ｰ addressFull繝ｻ莠･繝ｻ隴√・・ｽ荵怜恍繝ｻ繝ｻ 遶ｭ・｡ addressCityTown繝ｻ莠･・ｸ繧・私騾包ｽｺ繝ｻ迢嶺ｼｴ陷ｷ髦ｪ竏ｪ邵ｺ・ｧ繝ｻ繝ｻ  隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻaddressCityTown 邵ｺ・ｯ隶鯉ｽｭ陷榊姓・ｸ鄙ｫ繝ｻ雎・ｽ｣陟台ｸ楪・､邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ隰・ｽｱ邵ｺ繝ｻ 郢晢ｽｻ隰夲ｽｽ陷・ｽｺ陜難ｽｺ雋・私・ｼ螢ｼ・ｸ繧托ｽｼ荳樒私繝ｻ蜀嶺ｼｴ繝ｻ荵玲雛繝ｻ蝓斜鍋ｸｺ・ｾ邵ｺ・ｧ繝ｻ迢怜ｳｩ陟募ｾ後・騾包ｽｺ陷ｷ髦ｪﾂ竏ｽ・ｸ竏ｫ蟯ｼ闔会ｽ･闕ｳ荵昴・陷ｷ・ｫ郢ｧ竏壺・邵ｺ繝ｻ 郢晢ｽｻ鬮｢・ｲ髫包ｽｧ繝ｻ繝ｻV01繝ｻ蟲ｨ繝ｻ驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ邵ｺ・ｧ邵ｺ・ｮ陷ｿ繧峨・郢ｧ・ｭ郢晢ｽｼ邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ騾包ｽｨ邵ｺ繝ｻ・・ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 5. UF01繝ｻ莠･螂ｳ雎包ｽｨ繝ｻ逕ｻ・･・ｭ陷榊姓・ｻ蠅難ｽｧ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  騾ｶ・ｮ騾ｧ繝ｻ・ｼ螟青螟り｡崎怦・ｨ隴√・・ｼ蜀暦ｽｰ・｡隴剰侭ﾎ鍋ｹ晢ｽ｢邵ｺ荵晢ｽ芽愾邇ｲ・ｳ・ｨ郢ｧ蟶晏ｹ戊沂荵晢ｼ邵ｲ繝ｻ・｡・ｧ陞ｳ・｢郢晢ｽｻ霑夲ｽｩ闔会ｽｶ郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ郢ｧ蜻茨ｽｭ・｣邵ｺ蜉ｱ・･驍剰・笆ｼ邵ｺ莉｣・狗ｸｲ繝ｻ  5.1 陷茨ｽ･陷牙ｹ・｣ｰ繝ｻ蟯ｼ繝ｻ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ繝ｻ 郢晢ｽｻraw繝ｻ逎ｯﾂ螟り｡崎怦・ｨ隴√・or 1髯ｦ蠕湖鍋ｹ晢ｽ｢繝ｻ迚呻ｽｿ繝ｻ・ｰ繝ｻ 郢晢ｽｻname / phone / addressFull / preferred1 / preferred2 / price  5.2 陷ｿ邇ｲ・ｳ・ｨ驕抵ｽｺ陞ｳ螢ｽ蜃ｾ邵ｺ・ｮ隶鯉ｽｭ陷榊衷・ｵ蜈域｣｡ 郢晢ｽｻCU_Master繝ｻ螟撰ｽ｡・ｧ陞ｳ・｢邵ｺ・ｮ隴・ｽｰ髫募臆・ｿ・ｽ陷会｣ｰ邵ｺ・ｾ邵ｺ貅倥・隴鯉ｽ｢陝・ｼ懊・陋ｻ・ｩ騾包ｽｨ 郢晢ｽｻUP_Master繝ｻ螟るｻ・脂・ｶ邵ｺ・ｮ隴・ｽｰ髫募臆・ｿ・ｽ陷会｣ｰ邵ｺ・ｾ邵ｺ貅倥・隴鯉ｽ｢陝・ｼ懊・陋ｻ・ｩ騾包ｽｨ 郢晢ｽｻOrder_YYYY繝ｻ蜚ｹrder_ID 騾具ｽｺ髯ｦ蠕個竏晄ｸ戊ｭ幢ｽｬ隲繝ｻ・ｰ・ｱ邵ｲ縲隔mmary邵ｲ竏昴・隴帶ｬ傍ATUS邵ｲ竏晢ｽｱ・･雎・ｽｴ隴ｫ・ｰ邵ｺ・ｮ闖ｴ諛医・ 郢晢ｽｻ霑ｴ・ｾ陜｣・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ繝ｻ螢ｼ繝ｻ隴帶ｺ倥■郢ｧ・ｹ郢ｧ・ｯ騾墓ｻ薙・ 郢晢ｽｻ驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ繝ｻ螢ｼ逶ｾ霎｣・ｧ騾包ｽｨ邵ｺ・ｫ陋ｻ譎丞ｱ馴ｨｾ螟り｡阪・莠包ｽｻ・ｻ隲｢謫ｾ・ｼ繝ｻ  5.3 summary繝ｻ蝓滂ｽ･・ｭ陷榊生縺帷ｹｧ・ｿ郢晢ｽｳ郢晄圜・ｼ繝ｻ 郢晢ｽｻsummary 邵ｺ・ｯ陷ｿ邇ｲ・ｳ・ｨ陷繝ｻ・ｮ・ｹ邵ｺ・ｮ隶鯉ｽｭ陷榊生縺咲ｹ昴・縺也ｹ晢ｽｪ郢晢ｽｻ闖ｴ諛茨ｽ･・ｭ郢ｧ・ｹ郢ｧ・ｿ郢晢ｽｳ郢晏干・定ｰｿ荵昶・ 郢晢ｽｻ鬩穂ｸｻ閾・ｸｺ・ｪ髫補悪・ｴ繝ｻ繝ｻ騾ｵ竏ｫ謇慕ｸｺ・ｯ驕問扱・ｭ・｢繝ｻ蝓滂ｽ･・ｭ陷榊雀諢幄ｭ・ｽｭ邵ｺ・ｮ驗ゑｽｮ隰蟶ｷ・ｦ竏ｵ・ｭ・｢繝ｻ繝ｻ  5.4 霑ｴ・ｾ陜｣・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ陷ｷ謳ｾ・ｼ莠･繝ｻ隴帶ｺｽ蜃ｽ隰梧腸・ｼ繝ｻ 陟厄ｽ｢陟第得・ｼ蝌ｴAA驗抵ｽ､}{鬯假ｽｧ陞ｳ・｢陷ｷ謳ｾ・ｼ蝓溷匐驕假ｽｰ闔牙∞・ｼ蜴ｭ{addressCityTown}_{陝仙宴・ｽ蜈・郢晢ｽｻ陋ｻ譎丞ｱ鍋ｸｺ・ｯ AA驗抵ｽ､邵ｺ・ｪ邵ｺ繝ｻ 郢晢ｽｻ陟墓ｪ趣ｽｶ螢ｹ繝ｻ騾具ｽｺ雎包ｽｨ繝ｻ蜀暦ｽｴ讎雁・邵ｺ・ｧ AA驗抵ｽ､邵ｺ蠕｡・ｻ蛟・ｽｸ蠑ｱ・・ｹｧ蠕鯉ｽ九・閧ｲ・ｫ・ｰ7繝ｻ繝ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 6. 鬩幢ｽｨ隴夊揄・ｽ骰具ｽｳ・ｻ繝ｻ繝ｻP/BM/AA/PA/MA/LOCATION/陝偵・蛻・恷讓雁ｶ後・繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  6.1 PART_TYPE繝ｻ蝓滂ｽ･・ｭ陷榊雀・ｮ螟ゑｽｾ・ｩ繝ｻ繝ｻ 郢晢ｽｻBP繝ｻ蛹ｻﾎ鍋ｹ晢ｽｼ郢ｧ・ｫ郢晢ｽｼ隰・洸繝ｻ陷ｩ繝ｻ・ｼ莨夲ｽｼ螟ゑｽｴ讎雁・隴弱ｅ竊・PRICE 驕抵ｽｺ陞ｳ繝ｻ 郢晢ｽｻBM繝ｻ蝓滄㈹髯ｬ・ｽ陷ｩ繝ｻ・ｼ荵鈴ｫｪ驍ｨ・ｦ陷ｩ竏ｫ・ｭ莨夲ｽｼ莨夲ｽｼ蝠RICE=0繝ｻ閧ｲ・ｵ迹夲ｽｲ・ｻ陝・ｽｾ髮趣ｽ｡陞溷私・ｼ繝ｻ  6.2 雎鯉ｽｸ驍ｯ螟ょ・陷ｿ・ｷ繝ｻ繝ｻA繝ｻ繝ｻ AA01邵ｲ蠖〇99繝ｻ蛹ｻ繝ｦ郢ｧ・ｹ郢昴・A00邵ｺ・ｯ驕問扱・ｭ・｢繝ｻ繝ｻ 隲｢荳櫁｢悶・螟石夊ｭ壼鴻・ｾ・､郢ｧ蜻茨ｽ･・ｭ陷榊揃・ｿ・ｽ髴搾ｽ｡邵ｺ蜷ｶ・狗ｸｺ貅假ｽ∫ｸｺ・ｮ雎鯉ｽｸ驍ｯ螟ょ・陷ｿ・ｷ繝ｻ蛹ｻ縺｡郢ｧ・ｹ郢ｧ・ｯ陷ｷ髦ｪ竊鍋ｹｧ繧・ｸ夊ｭ擾｣ｰ繝ｻ繝ｻ  6.3 隴ｫ譎牙・繝ｻ繝ｻA/MA繝ｻ繝ｻ 郢晢ｽｻBP繝ｻ蝠A01邵ｲ蠑ア99繝ｻ繝ｻA00驕問扱・ｭ・｢繝ｻ繝ｻ 郢晢ｽｻBM繝ｻ蜩ｺA01邵ｲ蟒ｴA99繝ｻ繝ｻA00驕問扱・ｭ・｢繝ｻ繝ｻ  6.4 陜ｨ・ｨ陟趣ｽｫ郢晢ｽｭ郢ｧ・ｱ郢晢ｽｼ郢ｧ・ｷ郢晢ｽｧ郢晢ｽｳ繝ｻ繝ｻOCATION繝ｻ繝ｻ 郢晢ｽｻ陜ｨ・ｨ陟趣ｽｫ繝ｻ繝ｻTOCK繝ｻ蟲ｨ竊堤ｸｺ蜉ｱ窶ｻ闖ｫ譎・亜邵ｺ蜷ｶ・矩ｩ幢ｽｨ隴夊・繝ｻ LOCATION 郢ｧ雋橸ｽｿ繝ｻ・ｰ蛹ｻ竊堤ｸｺ蜷ｶ・・郢晢ｽｻLOCATION 隹ｺ・ｰ髣懶ｽｽ邵ｺ・ｯ隶鯉ｽｭ陷榊姓・ｸ讎奇ｽ咏ｸｺ・ｨ邵ｺ蜉ｱ窶ｻ隰・ｽｱ邵ｺ繝ｻﾂ竏ｫ・ｮ・｡騾・・繝ｻ邵ｺ・ｸ髫ｴ・ｦ陷ｻ髮・ｽｯ・ｾ髮趣ｽ｡邵ｺ・ｨ邵ｺ・ｪ郢ｧ繝ｻ  6.5 陝偵・蛻・遶翫・隴・ｽｰ騾｡・ｪ 陝・ｽｾ陟｢諛・ｽｾ讓雁ｶ後・蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ繝ｻ 鬩幢ｽｨ隴壼頃・ｾ讓雁ｶ檎ｸｺ・ｫ闔会ｽ･闕ｳ荵晢ｽ定ｬ問・笆ｽ繝ｻ繝ｻ discontinued / replacement / keywords / photoUrl 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ陝偵・蛻・ｸｺ・ｮ陜｣・ｴ陷ｷ蛹ｻ繝ｻ闔会ｽ｣隴厄ｽｿ陷ｩ竏ｵ・｡莠･繝ｻ郢ｧ蜻育ｽｲ驕会ｽｺ邵ｺ蜷ｶ・九・蝓滓咎お繧域ｲｻ騾包ｽｨ陋ｻ・､隴・ｽｭ邵ｺ・ｯ隶鯉ｽｭ陷榊生ﾎ溽ｹｧ・ｸ郢昴・縺醍ｸｺ・ｧ驕抵ｽｺ陞ｳ螟ｲ・ｼ繝ｻ 郢晢ｽｻkeywords 邵ｺ・ｯ陷茨ｽｨ隴√・・､諛・ｽｴ・｢邵ｺ・ｮ隴門戟荵りｮ諛・ｽｴ・｢髯ｬ諛ｷ蜍ｧ邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ陋ｻ・ｩ騾包ｽｨ邵ｺ蜷ｶ・・隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 7. UF06/UF07/UF08繝ｻ逎ｯﾎ夊ｭ壼・・･・ｭ陷榊遜・ｼ謌托ｽｻ蠅難ｽｧ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  7.1 UF06繝ｻ閧ｲ蛹ｱ雎包ｽｨ繝ｻ逕ｻ・･・ｭ陷阪・ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ螟石夊ｭ夊・繝ｻ騾具ｽｺ雎包ｽｨ郢ｧ蝣､・｢・ｺ陞ｳ螢ｹ・邵ｲ・｣arts_Master 邵ｺ・ｫ髫ｪ蛟ｬ鮖ｸ邵ｺ蜷ｶ・狗ｸｲ繝ｻ 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻBP/BM 陋ｹ・ｺ陋ｻ繝ｻ・帝￡・ｺ陞ｳ螢ｹ笘・ｹｧ繝ｻ 郢晢ｽｻ隰暦ｽ｡騾包ｽｨ邵ｺ霈費ｽ檎ｸｺ貅ｯ・｡蠕後・邵ｺ・ｿ騾具ｽｺ雎包ｽｨ隰・ｽｱ邵ｺ繝ｻ竊堤ｸｺ蜷ｶ・・郢晢ｽｻOrder_ID 邵ｺ蠕娯・邵ｺ繝ｻ蛹ｱ雎包ｽｨ邵ｺ・ｯ STOCK_ORDERED 邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ隰・ｽｱ邵ｺ繝ｻ  騾具ｽｺ雎包ｽｨ驕抵ｽｺ陞ｳ螢ｽ蜃ｾ邵ｺ・ｫ髫ｪ蛟ｬ鮖ｸ邵ｺ蜷ｶ・玖ｮ鯉ｽｭ陷榊衷・ｵ蜈域｣｡繝ｻ蝓滂ｽｦ繧奇ｽｦ繝ｻ・ｼ莨夲ｽｼ繝ｻ 郢晢ｽｻPART_ID 騾具ｽｺ髯ｦ魃会ｽｼ繝ｻP/BM邵ｺ・ｮ闖ｴ骰具ｽｳ・ｻ邵ｺ・ｫ陟戊侭竕ｧ繝ｻ繝ｻ 郢晢ｽｻOD_ID 騾具ｽｺ髯ｦ魃会ｽｼ驛・ｽ｣諛ｷ蜍ｧ繝ｻ繝ｻ 郢晢ｽｻSTATUS=ORDERED 郢晢ｽｻBP繝ｻ蝠RICE 隴幢ｽｪ陞ｳ繝ｻ 郢晢ｽｻBM繝ｻ蝠RICE=0 郢晢ｽｻ陟｢繝ｻ・ｦ竏壺・陟｢諛環ｧ邵ｺ・ｦ驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ邵ｺ・ｸ陜ｨ・ｨ陟趣ｽｫ郢ｧ・ｹ郢昴・繝ｻ郢ｧ・ｿ郢ｧ・ｹ鬨ｾ螟り｡阪・莠包ｽｻ・ｻ隲｢謫ｾ・ｼ繝ｻ  7.2 UF06繝ｻ閧ｲ・ｴ讎雁・繝ｻ逕ｻ・･・ｭ陷阪・ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ螟ゑｽｴ讎雁・郢ｧ蝣､・｢・ｺ陞ｳ螢ｹ・邵ｲ繝ｻﾎ夊ｭ壼鴻諞ｾ隲ｷ荵晢ｽ帝ｨｾ・ｲ髯ｦ蠕鯉ｼ・ｸｺ蟶呻ｽ狗ｸｲ繝ｻ 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻSTATUS=DELIVERED 郢晢ｽｻDELIVERED_AT 郢ｧ螳夲ｽｨ蛟ｬ鮖ｸ 郢晢ｽｻBP 邵ｺ・ｯ PRICE 陷茨ｽ･陷牙ｸ幢ｽｿ繝ｻ・ｰ闌ｨ・ｼ閧ｲ・ｴ讎雁・隴弱ｉ・｢・ｺ陞ｳ螟ｲ・ｼ繝ｻ 郢晢ｽｻLOCATION 郢ｧ螳夲ｽｨ蛟ｬ鮖ｸ繝ｻ莠･諠陟趣ｽｫ郢晢ｽｻ驍ゑｽ｡騾・・竊楢｢繝ｻ・ｦ繝ｻ・ｼ繝ｻ 郢晢ｽｻAA驗抵ｽ､郢ｧ蜻域ｭ楢怎・ｺ邵ｺ蜉ｱﾂ竏ｫ讓溯撻・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ陷ｷ髦ｪ竏郁愾閧ｴ荳千ｸｺ蜷ｶ・・郢晢ｽｻ陷茨ｽｨ陝・ｽｾ髮趣ｽ｡邵ｺ讙趣ｽｴ讎雁・雋ょ現繝ｻ陜｣・ｴ陷ｷ蛹ｻﾂ竏晏･ｳ雎包ｽｨSTATUS邵ｺ・ｮ髢ｾ・ｪ陷榊供諢幄楜螢ｹ窶ｲ髯ｦ蠕鯉ｽ冗ｹｧ蠕鯉ｽ九・閧ｲ・ｫ・ｰ8郢晢ｽｻ9繝ｻ繝ｻ  7.3 UF07繝ｻ莠包ｽｾ・｡隴ｬ・ｼ陷茨ｽ･陷牙ｹ｢・ｼ逕ｻ・･・ｭ陷阪・ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ蜥､P 邵ｺ・ｮ PRICE 隴幢ｽｪ陷茨ｽ･陷牙ｸ呻ｽ帝勳諛ｷ・ｮ蠕鯉ｼ邵ｲ竏ｵ・･・ｭ陷榊生竊堤ｸｺ蜉ｱ窶ｻ關難ｽ｡隴ｬ・ｼ郢ｧ蝣､・｢・ｺ陞ｳ螢ｹ笘・ｹｧ荵敖繝ｻ 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻPART_ID 邵ｺ・ｮ PRICE 郢ｧ蜻亥ｳｩ隴・ｽｰ 郢晢ｽｻ鬩幢ｽｨ隴壼ｿサATUS邵ｺ・ｯ陷ｴ貅ｷ謠ｴ陞溽判蟲ｩ邵ｺ蜉ｱ竊醍ｸｺ繝ｻ・ｼ莠包ｽｾ・｡隴ｬ・ｼ驕抵ｽｺ陞ｳ螢ｹ繝ｻ邵ｺ・ｿ繝ｻ繝ｻ 郢晢ｽｻ關難ｽ｡隴ｬ・ｼ隴幢ｽｪ驕抵ｽｺ陞ｳ螢ｹ繝ｻ驍ゑｽ｡騾・・繝ｻ髫ｴ・ｦ陷ｻ鄙ｫ繝ｻ陝・ｽｾ髮趣ｽ｡  7.4 UF08繝ｻ驛・ｽｿ・ｽ陷会｣ｰ陜｣・ｱ陷ｻ螂・ｽｼ逕ｻ・･・ｭ陷阪・ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ螟奇ｽｿ・ｽ陷会｣ｰ陷蜥乗ｄ繝ｻ蜑ｰ・ｿ・ｽ陷会｣ｰ髫ｱ・ｬ隴丞ｼｱ・定愾邇ｲ・ｳ・ｨ邵ｺ・ｫ驍剰・笆ｼ邵ｺ莉｣窶ｻ闖ｫ譎擾ｽｭ蛟･笘・ｹｧ荵敖繝ｻ 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ髴托ｽｽ陷会｣ｰ陜｣・ｱ陷ｻ鄙ｫ繝ｻ陷ｿ邇ｲ・ｳ・ｨ邵ｺ・ｮ隶鯉ｽｭ陷榊揃・ｨ蛟ｬ鮖ｸ邵ｺ・ｧ邵ｺ繧・ｽ顔ｸｲ竏晢ｽｱ・･雎・ｽｴ髴托ｽｽ髴搾ｽ｡邵ｺ・ｮ陝・ｽｾ髮趣ｽ｡ 郢晢ｽｻ鬮｢・ｲ髫包ｽｧ繝ｻ繝ｻV01繝ｻ蟲ｨ竊楢怺・ｳ隴弱ｇ貂夊ｭ擾｣ｰ邵ｺ霈費ｽ檎ｹｧ繝ｻ 郢晢ｽｻ髴托ｽｽ陷会｣ｰ陜｣・ｱ陷ｻ鄙ｫ繝ｻ騾包ｽｳ髫ｲ荵昶・邵ｺ蜉ｱ窶ｻRequest邵ｺ・ｫ隹ｿ荵晢ｼ邵ｺ・ｦ郢ｧ蛹ｻ・槭・逎ｯﾂｰ騾包ｽｨ隴・ｽｹ鬩･譎｢・ｼ繝ｻ  7.5 陷ｿ邇ｲ・ｳ・ｨSTATUS髢ｾ・ｪ陷榊供諢幄楜螟ｲ・ｼ蝓滂ｽ･・ｭ陷榊雀・ｮ螟ゑｽｾ・ｩ繝ｻ繝ｻ 陷ｿ邇ｲ・ｳ・ｨSTATUS邵ｺ・ｯ邵ｲ竏ｫ・ｴ讎雁・霑･・ｶ雎補・繝ｻ鬩幢ｽｨ隴夊・繝ｻ霑･・ｶ隲ｷ荵昴・陷蜥ｲ蛹ｱ雎包ｽｨ郢晁ｼ釆帷ｹｧ・ｰ驕ｲ蟲ｨ・帝包ｽｨ邵ｺ繝ｻ窶ｻ髢ｾ・ｪ陷榊供諢幄楜螢ｹ・・ｹｧ蠕鯉ｽ狗ｸｲ繝ｻ 郢晢ｽｻ闔・ｺ郢晢ｽｻAI邵ｺ蠕｡・ｻ・ｻ隲｢荳岩・陞溽判蟲ｩ邵ｺ蜉ｱ窶ｻ邵ｺ・ｯ邵ｺ・ｪ郢ｧ蟲ｨ竊醍ｸｺ繝ｻ 郢晢ｽｻ鬩包ｽｷ驕假ｽｻ隴夲ｽ｡闔会ｽｶ邵ｺ・ｯ邵ｲ譴ｧ・･・ｭ陷榊生繝ｵ郢晢ｽｭ郢晢ｽｼ邵ｺ・ｫ雎撰ｽｿ邵ｺ・｣邵ｺ貅ｽ・｢・ｺ陞ｳ螢ｹ縺・ｹ晏生ﾎｦ郢晏現ﾂ髦ｪ竊鍋ｹｧ蛹ｻ笆ｲ邵ｺ・ｦ邵ｺ・ｮ邵ｺ・ｿ隰悟鴻・ｫ荵昶・郢ｧ繝ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 8. 郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ驍ゑｽ｡騾・・・ｼ閧ｲ讓溯撻・ｴ繝ｻ蜀暦ｽｮ・｡騾・・・ｼ逕ｻ・･・ｭ陷榊姓・ｻ蠅難ｽｧ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  8.1 霑ｴ・ｾ陜｣・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ繝ｻ莠･鬮ｪ闕ｳﾂ邵ｺ・ｮ陞ｳ蠕｡・ｺ繝ｻ・ｰ・ｱ陷ｻ豸ｯI繝ｻ繝ｻ 郢晢ｽｻ霑ｴ・ｾ陜｣・ｴ邵ｺ・ｮ闖ｴ諛茨ｽ･・ｭ邵ｺ・ｯ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ陷雁・ｽｽ髦ｪ縲帝ｂ・｡騾・・・・ｹｧ蠕鯉ｽ・郢晢ｽｻ陞ｳ蠕｡・ｺ繝ｻ・ｰ・ｱ陷ｻ螂・ｽｼ莠･・ｮ蠕｡・ｺ繝ｻ縺慕ｹ晢ｽ｡郢晢ｽｳ郢晏現・定惺・ｫ郢ｧﾂ繝ｻ蟲ｨ窶ｲ邵ｲ譴ｧ・･・ｭ陷榊雀・ｮ蠕｡・ｺ繝ｻ繝ｻ隲｢荵猟譎・ｽ｡・ｨ驕会ｽｺ邵ｲ髦ｪ竊堤ｸｺ蜉ｱ窶ｻ隰・ｽｱ郢ｧ荳奇ｽ檎ｹｧ繝ｻ 郢晢ｽｻ霑ｴ・ｾ陜｣・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ邵ｺ・ｯ陷ｿ邇ｲ・ｳ・ｨ繝ｻ繝ｻrder_ID繝ｻ蟲ｨ竊楢叉ﾂ隲｢荳岩・驍剰・笆ｼ邵ｺ繝ｻ  8.2 郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ陷ｷ謳ｾ・ｼ閧ｲ讓溯撻・ｴ繝ｻ繝ｻ 陟厄ｽ｢陟第得・ｼ蝌ｴAA驗抵ｽ､}{鬯假ｽｧ陞ｳ・｢陷ｷ謳ｾ・ｼ蝓溷匐驕假ｽｰ闔牙∞・ｼ蜴ｭ{addressCityTown}_{陝仙宴・ｽ蜈・郢晢ｽｻaddressCityTown 邵ｺ・ｯ隶鯉ｽｭ陷榊姓・ｸ鄙ｫ繝ｻ雎・ｽ｣陟台ｸ楪・､郢ｧ蜑・ｽｽ・ｿ騾包ｽｨ 郢晢ｽｻAA驗抵ｽ､邵ｺ・ｯ鬩幢ｽｨ隴壻ｻ呻ｽｷ・･驕樔ｹ昴・鬨ｾ・ｲ髯ｦ蠕娯・郢ｧ蛹ｻ・願脂蛟・ｽｸ蠑ｱ繝ｻ隴厄ｽｴ隴・ｽｰ邵ｺ霈費ｽ檎ｹｧ繝ｻ  8.3 驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ繝ｻ閧ｲ螻ｮ騾ｹ・｣UI繝ｻ繝ｻ 陟厄ｽｹ陷托ｽｲ繝ｻ繝ｻ 郢晢ｽｻ鬩輔・・ｻ・ｶ隶諛・｡咲ｹ晢ｽｻ騾｡・ｰ陝ｶ・ｸ騾ｶ・｣髫墓じ繝ｻ髫ｴ・ｦ陷ｻ髮∝･ｳ闖ｫ・｡ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ陷雁・ｽｽ髦ｪ繝ｻ鬨ｾ・ｲ髯ｦ譴ｧ貊題ｬ・｡ 郢晢ｽｻ霑ｴ・ｾ陜｣・ｴ邵ｺ・ｨ邵ｺ・ｯ陋ｻ繝ｻ螻ｬ繝ｻ莠･繝ｻ陷牙ｸ吶・驕問扱・ｭ・｢邵ｲ竏ｫ螻ｮ騾ｹ・｣邵ｺ・ｮ邵ｺ・ｿ繝ｻ繝ｻ 驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ陷ｷ謳ｾ・ｼ莠包ｽｾ蜈ｷ・ｼ莨夲ｽｼ繝ｻ 邵ｲ莉呻ｽｪ蜑・ｽｽ阮卍鮃ｹ・｡・ｧ陞ｳ・｢陷ｷ繝ｻ/ addressCityTown / OrderID:xxx 陷ｷ譴ｧ謔・ｸｺ霈費ｽ檎ｹｧ蜿･逶ｾ霎｣・ｧ隲繝ｻ・ｰ・ｱ繝ｻ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ莨夲ｽｼ繝ｻ Order_ID / addressCityTown / 鬯假ｽｧ陞ｳ・｢陷ｷ繝ｻ/ STATUS / 陋幢ｽ･陟趣ｽｷ郢ｧ・ｹ郢ｧ・ｳ郢ｧ・｢ / 鬩募供譟ｱ隲｢貅ｽ・ｴ・ｰ隴壹・/ 鬩輔・・ｻ・ｶ郢晢ｽｻ闕ｳ蟠趣ｽｶ・ｳ郢晁ｼ釆帷ｹｧ・ｰ  8.4 驍ゑｽ｡騾・・・ｭ・ｦ陷ｻ螂・ｽｼ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ繝ｻ 闔会ｽ･闕ｳ荵昶ｲ騾具ｽｺ騾墓ｺ假ｼ邵ｺ貅ｷ・ｰ・ｴ陷ｷ蛹ｻﾂ竏ｫ・ｮ・｡騾・・繝ｻ邵ｺ・ｸ髫ｴ・ｦ陷ｻ髮・ｽｯ・ｾ髮趣ｽ｡邵ｺ・ｨ邵ｺ・ｪ郢ｧ蜈ｷ・ｼ繝ｻ 郢晢ｽｻPRICE隴幢ｽｪ陷茨ｽ･陷峨・ 郢晢ｽｻ隴幢ｽｪ驍乗ｦ雁・鬩幢ｽｨ隴壹・ 郢晢ｽｻ闖ｴ荵怜恍闕ｳ閧ｴ邏幄惺繝ｻ 郢晢ｽｻ陷蜥乗ｄ闕ｳ蟠趣ｽｶ・ｳ 郢晢ｽｻ鬩募供譟ｱ隲｢貅ｽ・ｴ・ｰ隴壽腸・ｼ莠包ｽｽ荵怜恍郢ｧ繝ｻ・臥ｸｺ雜｣・ｼ荵怜・驍会ｽｻ陋ｻ遉ｼ辟夊涕・ｸ繝ｻ荵玲椢驕ｶ・ｰ騾｡・ｰ陝ｶ・ｸ邵ｺ・ｪ邵ｺ・ｩ繝ｻ繝ｻ 郢晢ｽｻ髴托ｽｽ陷会｣ｰ陜｣・ｱ陷ｻ鄙ｫ・・嵩・｡隴ｬ・ｼ陷茨ｽ･陷牙ｸ吶・闕ｳ蟠趣ｽｶ・ｳ 郢晢ｽｻ隶鯉ｽｭ陷榊綜邏幄惺蝓淞・ｧ郢ｧ・ｨ郢晢ｽｩ郢晢ｽｼ繝ｻ蝓滂ｽ､諛域ｸ劾G繝ｻ繝ｻ  8.5 隴幢ｽｪ闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴壻ｻ吶・騾・・・ｼ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ繝ｻ 陞ｳ蠕｡・ｺ繝ｻ・ｰ・ｱ陷ｻ鄙ｫﾂｰ郢ｧ逕ｻ謔ｴ闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴夊摯D郢ｧ蜻域ｭ楢怎・ｺ邵ｺ蜉ｱﾂ竏晄Β陟趣ｽｫ繝ｻ繝ｻTOCK繝ｻ蟲ｨ竏郁ｬ鯉ｽｻ邵ｺ蜷ｶﾂ繝ｻ 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ陜ｨ・ｨ陟趣ｽｫ隰鯉ｽｻ邵ｺ蜉ｱ繝ｻ LOCATION 邵ｺ・ｮ隰ｨ・ｴ陷ｷ蛹ｻ窶ｲ陟｢繝ｻ・ｰ繝ｻ 郢晢ｽｻ闕ｳ閧ｴ邏幄惺蛹ｻ繝ｻ驍ゑｽ｡騾・・・ｭ・ｦ陷ｻ鄙ｫ繝ｻ陝・ｽｾ髮趣ｽ｡  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 9. 陞ｳ蠕｡・ｺ繝ｻ驟碑ｭ帶ｻゑｽｼ莠･・ｮ蠕｡・ｺ繝ｻ・ｰ・ｱ陷ｻ蟯ｩ繝ｻ陷ｿ・ｰ陝ｶ・ｳ驕抵ｽｺ陞ｳ螟ｲ・ｼ逕ｻ・･・ｭ陷榊姓・ｻ蠅難ｽｧ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  騾ｶ・ｮ騾ｧ繝ｻ・ｼ螟よｨ溯撻・ｴ陞ｳ蠕｡・ｺ繝ｻ・ｰ・ｱ陷ｻ鄙ｫ・定･搾ｽｷ霓､・ｹ邵ｺ・ｫ邵ｲ竏晏･ｳ雎包ｽｨ郢晢ｽｻ鬩幢ｽｨ隴夊・繝ｻ驍ｨ迹夲ｽｲ・ｻ郢晢ｽｻ陞ｻ・･雎・ｽｴ郢ｧ蝣､・｢・ｺ陞ｳ螢ｹ・・ｸｺ蟶呻ｽ狗ｸｲ繝ｻ  9.1 陞ｳ蠕｡・ｺ繝ｻ繝ｨ郢晢ｽｪ郢ｧ・ｬ郢晢ｽｼ繝ｻ蝓滂ｽ･・ｭ陷榊遜・ｼ繝ｻ 郢晢ｽｻ霑ｴ・ｾ陜｣・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ邵ｺ・ｮ陞ｳ蠕｡・ｺ繝ｻ窶ｲ陞ｳ蠕｡・ｺ繝ｻ驟碑ｭ帶ｺ倥・隘搾ｽｷ霓､・ｹ邵ｺ・ｨ邵ｺ・ｪ郢ｧ繝ｻ 郢晢ｽｻ陞ｳ蠕｡・ｺ繝ｻ蠕玖ｭ弱ｅ竊定楜蠕｡・ｺ繝ｻ縺慕ｹ晢ｽ｡郢晢ｽｳ郢昜ｺ･繝ｻ隴√・繝ｻ隶鯉ｽｭ陷榊雀・ｱ・･雎・ｽｴ邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ闖ｫ譎擾ｽｭ蛟･・・ｹｧ蠕鯉ｽ・ 9.2 陞ｳ蠕｡・ｺ繝ｻ蜃ｾ邵ｺ・ｫ驕抵ｽｺ陞ｳ螢ｹ・・ｹｧ蠕鯉ｽ玖ｮ鯉ｽｭ陷榊衷・ｵ蜈域｣｡繝ｻ莠･・ｿ繝ｻ・ｰ闌ｨ・ｼ繝ｻ 郢晢ｽｻOrder繝ｻ螢ｼ・ｮ蠕｡・ｺ繝ｻ蠕玖ｭ弱ｑ・ｼ蜀玲・隲ｷ蛹ｺ蟲ｩ隴・ｽｰ繝ｻ荵玲咎お繧・・隴帶ｻ灘ｾ玖ｭ弱ｅ繝ｻ隴厄ｽｴ隴・ｽｰ 郢晢ｽｻParts繝ｻ蜥ｼELIVERED 鬩幢ｽｨ隴夊・繝ｻ USED 陋ｹ蜴・ｽｼ莠包ｽｽ・ｿ騾包ｽｨ驕抵ｽｺ陞ｳ螟ｲ・ｼ繝ｻ 郢晢ｽｻEX繝ｻ螢ｻ・ｽ・ｿ騾包ｽｨ鬩幢ｽｨ隴壼頃・ｨ蛟ｬ鮖ｸ邵ｺ・ｮ驕抵ｽｺ陞ｳ螟ｲ・ｼ莠･・ｿ繝ｻ・ｦ繝ｻ・ｰ繝ｻ蟯ｼ邵ｺ・ｮ髫ｪ蛟ｬ鮖ｸ繝ｻ繝ｻ 郢晢ｽｻExpense繝ｻ螢ｻ・ｽ・ｿ騾包ｽｨ鬩幢ｽｨ隴夊・竊楢搏・ｺ邵ｺ・･邵ｺ蜀暦ｽｵ迹夲ｽｲ・ｻ邵ｺ・ｮ驕抵ｽｺ陞ｳ繝ｻ 郢晢ｽｻ隴幢ｽｪ闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴壽腸・ｼ蜚ｮTOCK隰鯉ｽｻ邵ｺ證ｦ・ｼ繝ｻOCATION隰ｨ・ｴ陷ｷ莠･・ｿ繝ｻ・ｰ闌ｨ・ｼ繝ｻ 郢晢ｽｻ郢晢ｽｭ郢ｧ・ｰ繝ｻ螟舌裟髫補・縺・ｹ晏生ﾎｦ郢晏現繝ｻ髫ｪ蛟ｬ鮖ｸ 郢晢ｽｻ驍ゑｽ｡騾・・・ｼ螟青・ｲ髯ｦ遒・螟り｡咲ｸｺ鄙ｫ・育ｸｺ・ｳ髫ｴ・ｦ陷ｻ螂・ｽｼ莠包ｽｻ・ｻ隲｢謫ｾ・ｼ繝ｻ  9.3 隴幢ｽｪ闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴夊・縺慕ｹ晢ｽ｡郢晢ｽｳ郢晏沺蠍瑚第得・ｼ蝓滂ｽ･・ｭ陷榊遜・ｼ繝ｻ 關灘・・ｼ螢ｽ謔ｴ闖ｴ・ｿ騾包ｽｨ繝ｻ蜥､P-YYYYMM-AAxx-PAyy, BM-YYYYMM-AAxx-MAyy 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ隴厄ｽｸ陟台ｸ環ｰ郢ｧ陋ｾﾎ夊ｭ夊摯D郢ｧ蜻域ｭ楢怎・ｺ邵ｺ・ｧ邵ｺ髦ｪ・狗ｸｺ阮吮・ 郢晢ｽｻ隰夲ｽｽ陷・ｽｺ邵ｺ霈費ｽ檎ｸｺ貊・夊ｭ夊・繝ｻ陜ｨ・ｨ陟趣ｽｫ陷・ｽｦ騾・・繝ｻ陝・ｽｾ髮趣ｽ｡邵ｺ・ｨ邵ｺ・ｪ郢ｧ繝ｻ  9.4 陋幢ｽ･陟趣ｽｷ郢ｧ・ｹ郢ｧ・ｳ郢ｧ・｢繝ｻ蝓滂ｽ･・ｭ陷榊綜谺隶灘遜・ｼ繝ｻ 0邵ｲ繝ｻ00霓､・ｹ 雋ょｸｷ縺幃囎竏ｫ・ｴ・ｰ關灘・・ｼ繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ隲繝ｻ・ｰ・ｱ邵ｺ・ｮ隹ｺ・ｰ髣懶ｽｽ 郢晢ｽｻBP邵ｺ・ｮ關難ｽ｡隴ｬ・ｼ隴幢ｽｪ陷茨ｽ･陷峨・ 郢晢ｽｻ陷蜥乗ｄ闕ｳ蟠趣ｽｶ・ｳ 郢晢ｽｻ隴幢ｽｪ闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴壻ｻ吶・騾・・・ｸ讎奇ｽ・郢晢ｽｻ鬩募供譟ｱ隲｢貅ｽ・ｴ・ｰ隴夊・繝ｻ陞溷､ょ験 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ郢晢ｽｻ鬩幢ｽｨ隴壼鴻諞ｾ隲ｷ荵昴・闕ｳ閧ｴ邏幄惺繝ｻ 鬩慕距逡代・繝ｻ 郢晢ｽｻ鬮｢・ｲ髫包ｽｧ繝ｻ繝ｻV01繝ｻ蟲ｨ竊馴勗・ｨ驕会ｽｺ 郢晢ｽｻ70霓､・ｹ隴幢ｽｪ雋・邵ｺ・ｯ闕ｳ讎奇ｽ咏ｸｺ繧・ｽ顔ｸｺ・ｨ邵ｺ蜉ｱ窶ｻ隰・ｽｱ邵ｺ繝ｻﾂ竏ｫ・ｮ・｡騾・・繝ｻ邵ｺ・ｮ騾ｶ・｣騾ｹ・｣陝・ｽｾ髮趣ｽ｡邵ｺ・ｨ邵ｺ蜷ｶ・・隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 10. FIX / DOC繝ｻ閧ｲ遲城坿蜈ｷ・ｼ逕ｻ・･・ｭ陷榊姓・ｻ蠅難ｽｧ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  10.1 FIX繝ｻ莠包ｽｿ・ｮ雎・ｽ｣騾包ｽｳ髫ｲ蜈ｷ・ｼ繝ｻ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ螢ｼ莠幃ｫｯ・ｺ邵ｺ・ｪ闖ｫ・ｮ雎・ｽ｣郢ｧ蝣､遲城坿荵昶・邵ｺ蜉ｱ窶ｻ隰・ｽｱ邵ｺ繝ｻﾂ竏ｵ・･・ｭ陷榊生・帝＄・ｴ陞｢鄙ｫ笳狗ｸｺ螢ｹ竊楢将・ｮ雎・ｽ｣郢ｧ蟶敖・ｲ郢ｧ竏夲ｽ狗ｸｲ繝ｻ 郢ｧ・ｫ郢昴・縺也ｹ晢ｽｪ關灘・・ｼ繝ｻ 郢晢ｽｻ騾具ｽｺ雎包ｽｨ郢ｧ・ｭ郢晢ｽ｣郢晢ｽｳ郢ｧ・ｻ郢晢ｽｫ繝ｻ驛・ｽｿ豕悟・陷ｿ・ｯ繝ｻ荳茨ｽｸ讎雁ｺ・・繝ｻ 郢晢ｽｻ驍乗ｦ雁・郢ｧ・ｭ郢晢ｽ｣郢晢ｽｳ郢ｧ・ｻ郢晢ｽｫ繝ｻ驛・ｽｿ豕悟・陷ｿ・ｯ繝ｻ荳茨ｽｸ讎雁ｺ・・繝ｻ 郢晢ｽｻ陋ｹ・ｺ陋ｻ繝ｻ・､逕ｻ蟲ｩ繝ｻ繝ｻP遶企洌M繝ｻ繝ｻ 郢晢ｽｻ陷茨ｽ･郢ｧ髮・・､闖ｫ・ｮ雎・ｽ｣ 郢晢ｽｻ隹ｺ・ｰ騾｡・ｪ隰・ｽｱ邵ｺ繝ｻ 郢晢ｽｻ陜ｨ・ｨ陟趣ｽｫ陋ｻ繝ｻ螻ｬ邵ｺ繝ｻ 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ驍ゑｽ｡騾・・・ｼ蜀怜ｱｮ騾ｹ・｣邵ｺ・ｮ陋ｻ・､隴・ｽｭ郢ｧ螳夲ｽｦ竏壺・郢ｧ蛟ｶ・ｿ・ｮ雎・ｽ｣邵ｺ・ｯ邵ｲ讙守ｭ城坿荵敖髦ｪ竊堤ｸｺ蜉ｱ窶ｻ隹ｿ荵昶・ 郢晢ｽｻ郢ｧ・ｳ郢晢ｽ｡郢晢ｽｳ郢晁ご・ｭ蟲ｨ繝ｻ髴・ｽｽ驍・・竊題怦・･陷牙ｸ吶定怺・ｱ鬮ｯ・ｺ闖ｫ・ｮ雎・ｽ｣郢ｧ蝣､蟲ｩ隰暦ｽ･驕抵ｽｺ陞ｳ螢ｹ・邵ｺ・ｦ邵ｺ・ｯ邵ｺ・ｪ郢ｧ蟲ｨ竊醍ｸｺ繝ｻ  10.2 郢ｧ・ｳ郢晢ｽ｡郢晢ｽｳ郢晏現竊鍋ｹｧ蛹ｻ・矩怕・ｽ陟包ｽｮ闖ｫ・ｮ雎・ｽ｣繝ｻ驛・ｽｨ・ｱ陷ｿ・ｯ驕ｽ繝ｻ蟲・・繝ｻ 髫ｪ・ｱ陷ｿ・ｯ繝ｻ繝ｻ 郢晢ｽｻ郢晢ｽ｡郢晢ｽｼ郢晢ｽｫ髴托ｽｽ陷会｣ｰ 郢晢ｽｻ雎包ｽｨ隲｢荳茨ｽｺ遏ｩ・ｰ繝ｻ・ｿ・ｽ陷会｣ｰ 郢晢ｽｻ隲｡繝ｻ・ｽ讌｢ﾂ繝ｻ骭宣恆・ｽ陷会｣ｰ 郢晢ｽｻ陋ｯ蜻ｵﾂ繝ｻ・ｿ・ｽ陷会｣ｰ 郢晢ｽｻ髴・ｽｽ陟包ｽｮ邵ｺ・ｪ髫慕距・ｩ蝣ｺ・ｿ・ｮ雎・ｽ｣ 郢晢ｽｻ闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴夊・繝ｻ髴托ｽｽ陷会｣ｰ髫ｪ蛟ｬ鮖ｸ繝ｻ莠･轤朱ｫｯ・､闕ｳ讎雁ｺ・・繝ｻ  驕問扱・ｭ・｢繝ｻ莠･莠幃ｫｯ・ｺ闖ｫ・ｮ雎・ｽ｣繝ｻ莨夲ｽｼ繝ｻ 郢晢ｽｻBP遶企洌M陞溽判蟲ｩ 郢晢ｽｻ關難ｽ｡隴ｬ・ｼ陞滂ｽｧ陝ｷ繝ｻ・ｿ・ｮ雎・ｽ｣ 郢晢ｽｻ隹ｺ・ｰ騾｡・ｪ隰・ｽｱ邵ｺ繝ｻ 郢晢ｽｻ陜ｨ・ｨ陟趣ｽｫ陋ｻ繝ｻ螻ｬ邵ｺ繝ｻ 郢晢ｽｻ陷ｩ竏ｫ蛻・棔逕ｻ蟲ｩ 郢晢ｽｻ鬯假ｽｧ陞ｳ・｢陷ｷ讎奇ｽ､逕ｻ蟲ｩ 郢晢ｽｻ鬯假ｽｧ陞ｳ・｢闖ｴ荵怜恍陞溽判蟲ｩ 郢晢ｽｻ霑夲ｽｩ闔会ｽｶ闖ｴ荵怜恍陞溽判蟲ｩ 郢晢ｽｻAA陷蜥ｲ蛹ｱ騾｡・ｪ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨID隶堤洸ﾂ・ｰ陞溽判蟲ｩ 郢晢ｽｻ隴厄ｽｸ鬯俶ｧｫ繝ｻ陞ｳ・ｹ陞溽判蟲ｩ  10.3 DOC繝ｻ蝓溷ｶ碁ｬ俶ｧｭﾎ懃ｹｧ・ｯ郢ｧ・ｨ郢ｧ・ｹ郢晁肩・ｼ繝ｻ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ螟奇ｽｦ迢暦ｽｩ閧ｴ蠍後・蜑ｰ・ｫ蛹ｺ・ｱ繧亥ｶ後・蝓趣｣ｰ莨懷ｺｶ隴厄ｽｸ驕ｲ蟲ｨ・定ｮ鯉ｽｭ陷榊揃・ｨ蛟ｬ鮖ｸ邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ騾墓ｻ薙・邵ｺ蜷ｶ・狗ｸｺ貅假ｽ∫ｸｺ・ｮ騾包ｽｳ髫ｲ荵敖繝ｻ 陷茨ｽ･陷牙ｹ・｣ｰ繝ｻ蟯ｼ繝ｻ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ莨夲ｽｼ繝ｻ orderId / docType / docName / docDesc / docPrice / docMemo 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ騾包ｽｳ髫ｲ荵昴・ Request 邵ｺ・ｫ髫ｪ蛟ｬ鮖ｸ邵ｺ霈費ｽ檎ｹｧ繝ｻ 郢晢ｽｻ騾墓ｻ薙・霑夲ｽｩ邵ｺ・ｯ陷ｿ邇ｲ・ｳ・ｨ邵ｺ・ｫ驍剰・笆ｼ邵ｺ荵暦ｽ･・ｭ陷榊揃・ｨ蛟ｬ鮖ｸ邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ闖ｫ譎擾ｽｭ蛟･・・ｹｧ蠕鯉ｽ・ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 11. 鬮｢・ｲ髫包ｽｧ郢晢ｽｻ隶諛・ｽｴ・｢繝ｻ繝ｻV01 / OV02繝ｻ逕ｻ・･・ｭ陷榊姓・ｻ蠅難ｽｧ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  11.1 OV01繝ｻ逎ｯ螟｢髫包ｽｧ郢ｧ・ｫ郢晢ｽｫ郢昴・・ｼ繝ｻ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ螢ｼ螂ｳ雎包ｽｨ陷雁・ｽｽ髦ｪ繝ｻ陷茨ｽｨ隶鯉ｽｭ陷榊綜繝･陜｣・ｱ郢ｧ蜑・ｽｸﾂ騾包ｽｻ鬮ｱ・｢邵ｺ・ｧ鬮｢・ｲ髫包ｽｧ邵ｺ蜷ｶ・狗ｸｲ繝ｻ 髯ｦ・ｨ驕会ｽｺ鬯・・蟯ｼ繝ｻ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ莨夲ｽｼ繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ陜難ｽｺ隴幢ｽｬ隲繝ｻ・ｰ・ｱ繝ｻ逎ｯ・｡・ｧ陞ｳ・｢陷ｷ謳ｾ・ｼ荳茨ｽｽ荵怜恍繝ｻ荳橸ｽｪ蜑・ｽｽ髮｣・ｼ繝ｻ 郢晢ｽｻ鬯假ｽｧ陞ｳ・｢隲繝ｻ・ｰ・ｱ繝ｻ繝ｻU_Master繝ｻ繝ｻ 郢晢ｽｻ霑夲ｽｩ闔会ｽｶ隲繝ｻ・ｰ・ｱ繝ｻ繝ｻP_Master繝ｻ繝ｻ 郢晢ｽｻsummary 郢晢ｽｻ霑ｴ・ｾ陜｣・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ隲繝ｻ・ｰ・ｱ 郢晢ｽｻSTATUS 郢晢ｽｻLOCATION 郢晢ｽｻ鬩幢ｽｨ隴夊揄・ｸﾂ髫包ｽｧ繝ｻ繝ｻA/PA/MA繝ｻ繝ｻ 郢晢ｽｻ陷蜥乗ｄ繝ｻ繝ｻefore/after/parts/extra繝ｻ繝ｻ 郢晢ｽｻ陷肴・蛻､繝ｻ繝ｻnspection繝ｻ繝ｻ 郢晢ｽｻEX繝ｻ諡ｾXP 郢晢ｽｻHistoryNotes 郢晢ｽｻ陋幢ｽ･陟趣ｽｷ郢ｧ・ｹ郢ｧ・ｳ郢ｧ・｢ 郢晢ｽｻ鬩募供譟ｱ隲｢貅ｽ・ｴ・ｰ隴壽腸・ｼ驛・ｽｭ・ｦ陷ｻ鄙ｫﾎ帷ｹ晏生ﾎ昴・繝ｻ  11.2 HistoryNotes繝ｻ莠･・ｱ・･雎・ｽｴ郢晢ｽ｡郢晢ｽ｢繝ｻ繝ｻ 郢晢ｽｻ髢ｾ・ｪ騾包ｽｱ髫ｪ蛟ｩ・ｿ・ｰ 郢晢ｽｻ陷繝ｻﾎ夊愾繧峨・繝ｻ繝ｻrder_ID繝ｻ蟲ｨ竊堤ｹ晢ｽｪ郢晢ｽｳ郢ｧ・ｯ邵ｺ蜉ｱﾂ竏ｬ・ｿ・ｽ髴搾ｽ｡陷ｿ・ｯ髢ｭ・ｽ邵ｺ・ｫ邵ｺ蜷ｶ・・郢晢ｽｻ隶諛・ｽｴ・｢陝・ｽｾ髮趣ｽ｡繝ｻ繝ｻV02繝ｻ繝ｻ  11.3 OV02繝ｻ莠･繝ｻ隴√・・､諛・ｽｴ・｢繝ｻ繝ｻ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ螢ｼ螂ｳ雎包ｽｨ郢晁ｼ斐°郢晢ｽｫ郢敖繝ｻ蛹ｻﾎ溽ｹｧ・ｰ繝ｻ荳槭・騾ｵ貊ゑｽｼ隘ｲDF驕ｲ莨夲ｽｼ蟲ｨ・定ｮ難ｽｪ隴・ｽｭ隶諛・ｽｴ・｢邵ｺ闍難ｽｪ・ｿ隴滂ｽｻ陷ｿ・ｯ髢ｭ・ｽ邵ｺ・ｫ邵ｺ蜷ｶ・狗ｸｲ繝ｻ 隶諛・ｽｴ・｢陝・ｽｾ髮趣ｽ｡繝ｻ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ莨夲ｽｼ繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ陷ｿ・ｰ陝ｶ・ｳ繝ｻ閧ｲ讓滄勗魃会ｽｼ荳翫＞郢晢ｽｼ郢ｧ・ｫ郢ｧ・､郢晏私・ｼ繝ｻ 郢晢ｽｻ隶鯉ｽｭ陷榊生ﾎ溽ｹｧ・ｰ繝ｻ繝ｻogs/system繝ｻ繝ｻ 郢晢ｽｻ髴托ｽｽ陷会｣ｰ陜｣・ｱ陷ｻ螂・ｽｼ繝ｻF08繝ｻ繝ｻ 郢晢ｽｻHistoryNotes 郢晢ｽｻ鬩幢ｽｨ隴壼・繝･陜｣・ｱ 郢晢ｽｻ陷蜥乗ｄ郢晢ｽｻPDF驕ｲ蟲ｨ繝ｻ郢昴・縺冗ｹｧ・ｹ郢昜ｺ･蝟ｧ驍擾｣ｰ隴壽腸・ｼ驛・ｽ｣諛ｷ蜍ｧ驍擾｣ｰ隴夊・竊堤ｸｺ蜉ｱ窶ｻ闖ｫ譎擾ｽｭ蛟･・・ｹｧ蠕娯螺郢ｧ繧・・繝ｻ繝ｻ  隶諛・ｽｴ・｢郢晏現ﾎ懃ｹｧ・ｬ郢晢ｽｼ繝ｻ蝓滂ｽ･・ｭ陷榊遜・ｼ莨夲ｽｼ繝ｻ 隶諛・ｽｴ・｢繝ｻ蜑ｰ・ｪ・ｿ隴滂ｽｻ繝ｻ荳橸ｽｱ・･雎・ｽｴ隶諛・ｽｴ・｢繝ｻ荵礼粟邵ｺ蜉ｱ窶ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 12. 鬩慕距逡醍ｹ晢ｽｫ郢晢ｽｼ郢晢ｽｫ繝ｻ蝓滂ｽ･・ｭ陷榊衷・ｵ・ｱ雎撰ｽｻ繝ｻ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  12.1 master_spec 邵ｺ・ｮ闕ｳ讎奇ｽ､繝ｻ 郢晢ｽｻ隴幢ｽｬ隴厄ｽｸ邵ｺ・ｯ隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ蛟･繝ｻ陷夲ｽｯ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣邵ｺ・ｧ邵ｺ繧・ｽ・郢晢ｽｻ鬩穂ｸｻ謔臥ｸｺ・ｮ郢晢ｽ｡郢晢ｽ｢繝ｻ蜑ｰ・ｨ蛟ｬ鮖ｸ繝ｻ荵苓ｳ雋ゑｽｬ邵ｺ・ｯ隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ蛟･竊堤ｸｺ蜉ｱ窶ｻ陷会ｽｹ陷牙ｸ呻ｽ定ｬ問・笳・ｸｺ・ｪ邵ｺ繝ｻ 郢晢ｽｻ陞溽判蟲ｩ邵ｺ・ｯ陝ｾ・ｮ陋ｻ繝ｻ蟀ｿ陟台ｸ岩・郢ｧ蛹ｻ笆ｲ邵ｺ・ｦ邵ｺ・ｮ邵ｺ・ｿ髯ｦ蠕鯉ｽ冗ｹｧ蠕鯉ｽ・ 12.2 陷茨ｽ･陷牙ｸ帙・陷ｿ・｣邵ｺ・ｮ闕ｳ讎奇ｽ､繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ繝ｻ蝓斜夊ｭ壽腸・ｼ荳茨ｽｾ・｡隴ｬ・ｼ繝ｻ蜑ｰ・ｿ・ｽ陷会｣ｰ陜｣・ｱ陷ｻ鄙ｫ繝ｻ UF 驍会ｽｻ郢晁ｼ斐°郢晢ｽｼ郢晢｣ｰ邵ｺ謔滄ｫｪ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣ 郢晢ｽｻ驍ゑｽ｡騾・・繝､郢晢ｽｼ郢晢ｽｫ邵ｺ荵晢ｽ臥ｸｺ・ｮ陷茨ｽ･陷牙ｸ吶・驕問扱・ｭ・｢繝ｻ閧ｲ螻ｮ騾ｹ・｣邵ｺ・ｮ邵ｺ・ｿ繝ｻ繝ｻ  12.3 陞ｻ・･雎・ｽｴ闖ｫ譎上・ 郢晢ｽｻ陞ｻ・･雎・ｽｴ邵ｺ・ｯ陷台ｼ∝求邵ｺ蟶吮・髣｢繝ｻ・ｩ謳ｾ・ｼ蛹ｻ縺・ｹ晢ｽｼ郢ｧ・ｫ郢ｧ・､郢晞摩諤ｧ郢ｧﾂ繝ｻ繝ｻ 郢晢ｽｻ隶諛・ｽｴ・｢陝・ｽｾ髮趣ｽ｡邵ｺ荵晢ｽ芽棔謔ｶ・・ｸｺ・ｪ邵ｺ繝ｻ・ｼ逎ｯ蜍∬棔謔ｶ笘・ｸｺ・ｹ邵ｺ髦ｪ繝ｻ郢昴・縺帷ｹ晏現繝ｧ郢晢ｽｼ郢ｧ・ｿ邵ｺ・ｮ邵ｺ・ｿ繝ｻ繝ｻ  12.4 陜ｨ・ｨ陟趣ｽｫ驕抵ｽｺ髫ｱ髦ｪ繝ｻ隴厄ｽｴ隴・ｽｰ繝ｻ蝓滂ｽ･・ｭ陷榊生繝ｨ郢晢ｽｪ郢ｧ・ｬ郢晢ｽｼ繝ｻ繝ｻ 陜ｨ・ｨ陟趣ｽｫ驕抵ｽｺ髫ｱ謳ｾ・ｼ繝ｻ 郢晢ｽｻ陜ｨ・ｨ陟趣ｽｫ鬩幢ｽｨ隴壽腸・ｼ繝ｻTATUS=STOCK繝ｻ蟲ｨ繝ｻ闕ｳﾂ髫包ｽｧ郢ｧ螳夲ｽｿ譁絶雷郢ｧ荵晢ｼ・ｸｺ・ｨ繝ｻ莠･蛻騾｡・ｪ繝ｻ荵礼・鬩･謫ｾ・ｼ蟆ｱA繝ｻ閾ｭOCATION繝ｻ繝ｻ 隴厄ｽｴ隴・ｽｰ繝ｻ莠･繝ｻ陷ｷ譴ｧ謔・・莨夲ｽｼ繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ郢晢ｽｻ郢ｧ・｢郢晢ｽｼ郢ｧ・ｫ郢ｧ・､郢晄じ繝ｻ鬩幢ｽｨ隴夊・繝ｻ驍ｨ迹夲ｽｲ・ｻ郢晢ｽｻ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ郢晢ｽｻ驍ゑｽ｡騾・・逶ｾ霎｣・ｧ郢ｧ蜻育ｴ幄惺蛹ｻ笘・ｹｧ繝ｻ 郢晢ｽｻ陷・ｪ驕ｲ莨夲ｽｼ莠包ｽｽ蜍滂ｽｺ・ｦ髯ｦ蠕娯夢邵ｺ・ｦ郢ｧ繧・ｽ｣鄙ｫ・檎ｸｺ・ｪ邵ｺ繝ｻ・ｼ蟲ｨ・定ｲ・邵ｺ貅倪・  12.5 驕問扱・ｭ・｢闔遏ｩ・ｰ繝ｻ・ｼ蝓滂ｽ･・ｭ陷榊衷・ｰ・ｴ陞｢莨∽ｺ溯ｱ・ｽ｢繝ｻ繝ｻ 郢晢ｽｻ隶鯉ｽｭ陷榊雀諢幄ｭ・ｽｭ邵ｺ・ｮ隶難ｽｪ陷ｿ謔ｶ・翫・莠包ｽｺ・ｺ繝ｻ蟆ｱI繝ｻ荳橸ｽ､螟慚壹・繝ｻ 郢晢ｽｻ鬮ｱ讓奇ｽｭ・｣髫募・・ｵ迹夲ｽｷ・ｯ邵ｺ荵晢ｽ臥ｸｺ・ｮ陷茨ｽ･陷峨・ 郢晢ｽｻID邵ｺ・ｮ陷讎願懸騾包ｽｨ郢晢ｽｻ隰ｾ・ｹ陞溘・ 郢晢ｽｻ陷奇ｽｱ鬮ｯ・ｺ闖ｫ・ｮ雎・ｽ｣邵ｺ・ｮ騾ｶ・ｴ隰暦ｽ･驕抵ｽｺ陞ｳ繝ｻ 郢晢ｽｻ陞ｻ・･雎・ｽｴ邵ｺ・ｮ陷台ｼ∝求 郢晢ｽｻUI陷会ｽ｣陋ｹ蜴・ｽｼ閧ｲ讓溯撻・ｴ髮具｣ｰ髣包ｽｷ陟・圜・ｼ繝ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 13. 騾包ｽｨ髫ｱ讖ｸ・ｼ繝ｻlossary繝ｻ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  郢晢ｽｻCU_ID繝ｻ螟撰ｽ｡・ｧ陞ｳ・｢郢ｧ螳夲ｽｭ莨懈肩邵ｺ蜷ｶ・玖ｱ鯉ｽｸ驍ｯ蜚妊 郢晢ｽｻUP_ID繝ｻ螟るｻ・脂・ｶ郢ｧ螳夲ｽｭ莨懈肩邵ｺ蜷ｶ・玖ｱ鯉ｽｸ驍ｯ蜚妊繝ｻ繝ｻU邵ｺ・ｫ陟慕§・ｱ讖ｸ・ｼ繝ｻ 郢晢ｽｻOrder_ID繝ｻ螢ｼ螂ｳ雎包ｽｨ郢ｧ螳夲ｽｭ莨懈肩邵ｺ蜷ｶ・玖叉・ｭ陟｢繝ｻ縺冗ｹ晢ｽｼ繝ｻ莠･繝ｻ隰暦ｽ･驍ｯ螟ゅ○繝ｻ繝ｻ 郢晢ｽｻPART_ID繝ｻ螟石夊ｭ夊・・帝寞・ｫ鬨ｾ螟奇ｽｭ莨懈肩邵ｺ蜷ｶ・紀D繝ｻ繝ｻP/BM闖ｴ骰具ｽｳ・ｻ繝ｻ繝ｻ 郢晢ｽｻSTATUS繝ｻ螢ｼ螂ｳ雎包ｽｨ郢晢ｽｻ鬩幢ｽｨ隴夊・繝ｻ霑･・ｶ隲ｷ蜈ｷ・ｼ莠･・ｷ・･驕樔ｹ晢ｽ帝勗・ｨ邵ｺ蜻ｻ・ｼ繝ｻ 郢晢ｽｻSUMMARY繝ｻ螢ｼ螂ｳ雎包ｽｨ陷繝ｻ・ｮ・ｹ郢ｧ蜻茨ｽｮ荵昶・隶鯉ｽｭ陷榊生縺帷ｹｧ・ｿ郢晢ｽｳ郢昴・ 郢晢ｽｻADDRESSCITYTOWN繝ｻ螢ｼ・ｸ繧・私騾包ｽｺ繝ｻ迢嶺ｼｴ陷ｷ髦ｪ竏ｪ邵ｺ・ｧ邵ｺ・ｮ隶鯉ｽｭ陷榊姓・ｸ鄙ｫ繝ｻ闖ｴ荵怜恍郢ｧ・ｭ郢晢ｽｼ 郢晢ｽｻOV01繝ｻ螢ｼ螂ｳ雎包ｽｨ郢ｧ・ｫ郢晢ｽｫ郢昴・螟｢髫包ｽｧ 郢晢ｽｻOV02繝ｻ螢ｼ繝ｻ隴√・・､諛・ｽｴ・｢繝ｻ驛・ｽｪ・ｿ隴滂ｽｻ繝ｻ繝ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 END OF master_spec繝ｻ莠･鬮ｪ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣郢晢ｽｻ陞ｳ謔溘・霑夊肩・ｽ諛茨ｽ･・ｭ陷榊姓・ｻ蠅難ｽｧ蛟･繝ｻ陷閧ｴ・ｧ蛹ｺ繝ｻ繝ｻ荳橸ｽｾ・ｩ陷医・豐ｿ繝ｻ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉   ## CHANGELOG - 2026-01-01: Added CURRENT_SCOPE entrypoints (00_CURRENT_SCOPE_NOTE.md, 01_INDEX.md, master_spec/ui_spec headers).  ### DOC example: Toilet remodel estimate (split into 2 documents)  - Scenario: Customer requests toilet remodel estimate.   - Includes: (1) shower/warm-seat toilet item, (2) wallpaper, (3) floor   - Requirement: create 2 documents (toilet item = 1 copy, wallpaper+floor = 1 copy)   - Addressee (docName): TOKI_KEIKO - How to submit (DOC):   - Create DOC request A (docType=ESTIMATE)     - docName: TOKI_KEIKO     - docDesc: Toilet item estimate (shower/warm-seat model)     - docPrice: (set later)     - docMemo: includes product + install + notes; ask questions if required fields missing   - Create DOC request B (docType=ESTIMATE)     - docName: TOKI_KEIKO     - docDesc: Wallpaper and floor estimate     - docPrice: (set later)     - docMemo: scope=wallpaper+floor; ask questions if required fields missing

Policy:
- Do NOT modify master_spec for examples when encoding/newline risk exists.
- Add/maintain examples as separate files, or keep report-only records.
```


---

### FILE: platform/MEP/03_BUSINESS/よりそい堂/99__ci_trigger.md
- sha256: 617a2aa5f4268124a9d3462ead4907e1f22917060c9a6292d689f0c244aa197c
- bytes: 100

```text
﻿## CI trigger (manual v3) 
2026-01-01T08:38:39

## CI trigger (cleanup PR) 
2026-01-01T08:42:49
```


---

### FILE: platform/MEP/03_BUSINESS/よりそい堂/99__ci_trigger_cleanup.md
- sha256: fe18cd3947c9e24107ef295ae96c01fc490bf36f31ab652a607b22e82aa79157
- bytes: 39

```text
﻿cleanup trigger 2026-01-01T08:41:44
```


---

### FILE: platform/MEP/03_BUSINESS/よりそい堂/BUSINESS_PACKET.md
- sha256: fcfaba51862fcc0782a363ef442095a23fb92fd4183578defff2b36edfd805db
- bytes: 84716

```text
# BUSINESS_PACKET（業務側・新チャット貼り付け用）
# これは自動生成ファイルです。手編集は禁止（差分事故の温床になるため）。
# 更新は workflow_dispatch（Business Packet Update (Dispatch)）で再生成→PR を作成してください。

## 使い方（最小）
- 新チャット1通目に **このファイル全文** を貼る（1枚貼り）。
- 追加提示が必要な場合、AIは REQUEST 形式で最大3件まで。

## AIの要求ルール（必須）
### REQUEST
- file: <ファイルパス>
- heading: <見出し名（h2/h3等）>
- reason: <必要理由（1行）>

---

## master_spec（業務仕様）

**path:** `master_spec`

<!-- BEGIN SOURCE:master_spec -->
```text
<!-- CURRENT_SCOPE: platform/MEP/03_BUSINESS/yorisoidou/ NOTE: operational note only; does NOT change master_spec meaning. RULE: 1 theme = 1 PR; canonical is main after merge. -->  <!-- LAYER: L2 -->  <!-- FOUNDATION_REF: MEP/foundation/FOUNDATION_SPEC.md -->  <!-- NOTE: This specification must conform to FOUNDATION_SPEC -->    隨倥・master_spec繝ｻ莠･鬮ｪ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣郢晢ｽｻ陞ｳ謔溘・霑夊肩・ｽ諛茨ｽ･・ｭ陷榊姓・ｻ蠅難ｽｧ蛟･繝ｻ陷閧ｴ・ｧ蛹ｺ繝ｻ繝ｻ荳橸ｽｾ・ｩ陷医・豐ｿ繝ｻ繝ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 0. 隶弱ｊ・ｦ竏壹・郢ｧ・ｳ郢晢ｽｳ郢ｧ・ｻ郢晏干繝ｨ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  隴幢ｽｬ闔牙｢難ｽｧ菫ｶ蠍後・繝ｻaster_spec繝ｻ蟲ｨ繝ｻ邵ｲ竏夲ｽ育ｹｧ鄙ｫ笳守ｸｺ繝ｻ・ｰ繝ｻ隶鯉ｽｭ陷榊揃繝ｻ陷榊供蝟ｧ郢ｧ・ｷ郢ｧ・ｹ郢昴・ﾎ堤ｸｺ・ｫ邵ｺ鄙ｫ・郢ｧ繝ｻ 邵ｲ譴ｧ・･・ｭ陷榊雀繝ｻ陞ｳ・ｹ郢晢ｽｻ隶鯉ｽｭ陷榊生繝ｧ郢晢ｽｼ郢ｧ・ｿ郢晢ｽｻ隶鯉ｽｭ陷榊生繝ｵ郢晢ｽｭ郢晢ｽｼ郢晢ｽｻ隶鯉ｽｭ陷榊姓・ｸ鄙ｫ繝ｻ陋ｻ・ｶ驍上・ﾂ髦ｪ・定叉ﾂ髮具ｽｫ邵ｺ蜉ｱ窶ｻ陞ｳ螟ゑｽｾ・ｩ邵ｺ蜷ｶ・・隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ蛟･繝ｻ陷夲ｽｯ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣邵ｺ・ｧ邵ｺ繧・ｽ狗ｸｲ繝ｻ  隴幢ｽｬ闔牙｢難ｽｧ蛟･繝ｻ騾ｶ・ｮ騾ｧ繝ｻ・ｼ繝ｻ 郢晢ｽｻ霑ｴ・ｾ陜｣・ｴ隶鯉ｽｭ陷榊生繝ｻ髴托ｽｷ邵ｺ繝ｻ繝ｻ陷讎翫・陷牙ｸ吶・陋ｻ・､隴・ｽｭ郢晄ｺ倥○郢ｧ蛛ｵ縺樒ｹ晢ｽｭ邵ｺ・ｫ邵ｺ蜷ｶ・・郢晢ｽｻ驍ゑｽ｡騾・・・･・ｭ陷榊生・定ｿｴ・ｾ陜｣・ｴ邵ｺ荵晢ｽ芽崕繝ｻ・企ｫｮ・｢邵ｺ蜉ｱﾂ竏ｫ螻ｮ騾ｹ・｣陷ｿ・ｯ髢ｭ・ｽ邵ｺ・ｫ邵ｺ蜷ｶ・・郢晢ｽｻ隶鯉ｽｭ陷榊雀・ｱ・･雎・ｽｴ郢ｧ雋橸ｽｮ謔溘・髴托ｽｽ髴搾ｽ｡陷ｿ・ｯ髢ｭ・ｽ邵ｺ・ｪ陟厄ｽ｢邵ｺ・ｧ闖ｫ譎・亜邵ｺ蜷ｶ・・郢晢ｽｻ郢ｧ・ｷ郢ｧ・ｹ郢昴・ﾎ堤ｸｺ・ｫ關捺剌・ｭ蛟･笳狗ｸｺ螢ｹﾂ竏ｵ・･・ｭ陷榊生笳守ｸｺ・ｮ郢ｧ繧・・郢ｧ雋槭・霑ｴ・ｾ陷ｿ・ｯ髢ｭ・ｽ邵ｺ・ｫ邵ｺ蜷ｶ・・ 0.1 郢ｧ・ｷ郢ｧ・ｹ郢昴・ﾎ定惺繝ｻ 郢ｧ・ｷ郢ｧ・ｹ郢昴・ﾎ定惺謳ｾ・ｼ螢ｹ・育ｹｧ鄙ｫ笳守ｸｺ繝ｻ・ｰ繝ｻ隶鯉ｽｭ陷榊揃繝ｻ陷榊供蝟ｧ郢ｧ・ｷ郢ｧ・ｹ郢昴・ﾎ・ 0.2 陝・ｽｾ髮趣ｽ｡郢晁ｼ釆溽ｹ晢ｽｼ繝ｻ繝ｻnd-to-End繝ｻ繝ｻ 陷ｿ邇ｲ・ｳ・ｨ繝ｻ繝ｻF01繝ｻ螟青螟り｡咲ｹｧ・ｳ郢晄鱒繝ｻ繝ｻ繝ｻ髯ｦ蠕湖鍋ｹ晢ｽ｢繝ｻ繝ｻ 遶翫・鬯假ｽｧ陞ｳ・｢騾具ｽｻ鬪ｭ・ｲ繝ｻ繝ｻU_Master繝ｻ繝ｻ 遶翫・霑夲ｽｩ闔会ｽｶ騾具ｽｻ鬪ｭ・ｲ繝ｻ繝ｻP_Master繝ｻ繝ｻ 遶翫・陷ｿ邇ｲ・ｳ・ｨ騾具ｽｺ髯ｦ魃会ｽｼ繝ｻrder_ID繝ｻ繝ｻ 遶翫・霑ｴ・ｾ陜｣・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ騾墓ｻ薙・繝ｻ閧ｲ讓溯撻・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ繝ｻ繝ｻ 遶翫・驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ騾墓ｻ薙・繝ｻ閧ｲ・ｮ・｡騾・・繝ｻ鬩滓ｦ翫・郢晢ｽｻ騾ｶ・｣騾ｹ・｣繝ｻ繝ｻ 遶翫・鬩幢ｽｨ隴壼鴻蛹ｱ雎包ｽｨ郢晢ｽｻ陷讎願懸騾包ｽｨ郢晢ｽｻ驍乗ｦ雁・繝ｻ繝ｻF06繝ｻ隘ｲarts_Master繝ｻ繝ｻ 遶翫・AA騾｡・ｪ陷ｿ・ｷ隰夲ｽｽ陷・ｽｺ邵ｺ・ｨ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ陷ｷ讎頑ｸ夊ｭ擾｣ｰ 遶翫・驍乗ｦ雁・騾具ｽｻ鬪ｭ・ｲ 遶翫・BP關難ｽ｡隴ｬ・ｼ驕抵ｽｺ陞ｳ螟ｲ・ｼ繝ｻF06繝ｻ驟祈07繝ｻ繝ｻ 遶翫・闖ｴ諛茨ｽ･・ｭ陞ｳ貊灘多 遶翫・霑ｴ・ｾ陜｣・ｴ陞ｳ蠕｡・ｺ繝ｻ・ｼ莠･・ｮ蠕｡・ｺ繝ｻ・ｰ・ｱ陷ｻ螂・ｽｼ菫・・ USED陋ｹ蜴・ｽｼ蜀暦ｽｵ迹夲ｽｲ・ｻ髫ｪ莠包ｽｸ螂・ｽｼ荵玲ざ闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴夊・繝ｻSTOCK隰鯉ｽｻ邵ｺ繝ｻ 遶翫・驍ゑｽ｡騾・・・ｭ・ｦ陷ｻ鄙ｫ繝ｻ鬨ｾ・ｲ髯ｦ遒・螟り｡・遶翫・隴厄ｽｸ鬯俶ｩｸ・ｼ繝ｻOC繝ｻ莨夲ｽｼ荳茨ｽｿ・ｮ雎・ｽ｣繝ｻ繝ｻIX繝ｻ莨夲ｽｼ蜑ｰ・ｿ・ｽ陷会｣ｰ陜｣・ｱ陷ｻ螂・ｽｼ繝ｻF08繝ｻ繝ｻ 遶翫・鬮｢・ｲ髫包ｽｧ繝ｻ繝ｻV01繝ｻ繝ｻ 遶翫・陷茨ｽｨ隴√・・､諛・ｽｴ・｢繝ｻ繝ｻV02繝ｻ繝ｻ  0.3 陋ｻ・､隴・ｽｭ隶難ｽｩ邵ｺ・ｮ陷ｴ貅ｷ謠ｴ繝ｻ蝓滂ｽ･・ｭ陷榊生繝ｻ闕ｳ讎奇ｽ､逕ｻ謫・脂・ｶ繝ｻ繝ｻ 郢晢ｽｻ闖ｴ荵怜恍郢晢ｽｻID郢晢ｽｻ鬩･鮃ｹ・｡髦ｪ繝ｻ陋ｹ・ｺ陋ｻ繝ｻ繝ｻ霑･・ｶ隲ｷ荵昶・邵ｺ・ｩ邵ｺ・ｮ雎・ｽ｣陟台ｸ楪・､邵ｺ・ｯ邵ｲ竏ｵ・･・ｭ陷榊生ﾎ溽ｹｧ・ｸ郢昴・縺醍ｸｺ・ｫ郢ｧ蛹ｻ・企￡・ｺ陞ｳ螢ｹ・・ｹｧ蠕鯉ｽ・郢晢ｽｻ闔・ｺ郢晢ｽｻAI郢晢ｽｻ陞溷､慚夂ｹ昴・繝ｻ郢晢ｽｫ邵ｺ・ｯ邵ｲ竏ｵ・ｭ・｣陟台ｸ楪・､郢ｧ蝣､蟲ｩ隰暦ｽ･雎趣ｽｺ陞ｳ螢ｹ・邵ｺ・ｪ邵ｺ繝ｻ・ｼ閧ｲ・ｴ・ｰ隴壼・豁楢怎・ｺ郢晢ｽｻ騾ｶ・｣隴滂ｽｻ郢晢ｽｻ髯ｬ諛ｷ蜍ｧ邵ｺ・ｯ陷ｿ・ｯ繝ｻ繝ｻ  0.4 郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ邵ｺ・ｮ闕ｳ陋ｾ蝴ｴ陞ｻ・､郢晢ｽ｢郢昴・ﾎ昴・蝓滂ｽ･・ｭ陷榊雀・ｮ螟ゑｽｾ・ｩ繝ｻ繝ｻ 郢晢ｽｻ髫ｨ・ｬ闕ｳﾂ鬮ｫ荳ｻ・ｱ・､繝ｻ螟よｨ溯撻・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ繝ｻ莠･・ｮ蠕｡・ｺ繝ｻ・ｰ・ｱ陷ｻ鄙ｫ繝ｻ陷夲ｽｯ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣繝ｻ繝ｻ 郢晢ｽｻ髫ｨ・ｬ闔遒∝垓陞ｻ・､繝ｻ螟ゑｽｮ・｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ繝ｻ閧ｲ螻ｮ騾ｹ・｣郢晢ｽｻ鬩輔・・ｻ・ｶ隶諛・｡咲ｹ晢ｽｻ髫ｴ・ｦ陷ｻ髮∝･ｳ闖ｫ・｡繝ｻ繝ｻ 郢晢ｽｻ髫ｨ・ｬ闕ｳ陋ｾ蝴ｴ陞ｻ・､繝ｻ螟奇ｽ｣諛ｷ蜍ｧ髫暦ｽ｣隴ｫ謦ｰ・ｼ閧ｲ・ｴ・ｰ隴壼・豁楢怎・ｺ郢晢ｽｻ髫暦ｽ｣隴ｫ闊後・髫ｴ・ｦ陷ｻ鄙ｫ繝ｻ髢ｾ・ｪ霎滂ｽｶ隴√・・､諛・ｽｴ・｢髯ｬ諛ｷ蜍ｧ郢晢ｽｻ騾ｶ・｣隴滂ｽｻ髯ｬ諛ｷ蜍ｧ繝ｻ繝ｻ 郢晢ｽｻ隶鯉ｽｭ陷榊生ﾎ溽ｹｧ・ｸ郢昴・縺代・莠･蠎願涕・ｳ隴厄ｽｴ隴・ｽｰ繝ｻ蟲ｨ繝ｻ陝ｶ・ｸ邵ｺ・ｫ隴崢闕ｳ雍具ｽｽ髦ｪ繝ｻ驕抵ｽｺ陞ｳ螟環繝ｻ竊堤ｸｺ蜉ｱ窶ｻ隰・ｽｱ邵ｺ繝ｻ  0.5 驕ｶ・ｯ隴幢ｽｫ隴崢鬩包ｽｩ陋ｹ蜴・ｽｼ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｵ・ｱ繧托ｽｼ繝ｻ UF01邵ｲ蠑詮08繝ｻ豢ｲIX繝ｻ諢＾C繝ｻ陦・01繝ｻ陦・02 邵ｺ・ｯ邵ｲ・｣C繝ｻ荳翫○郢晄ｧｭ繝ｻ繝ｻ荳翫■郢晄じﾎ樒ｹ昴・繝ｨ邵ｺ・ｮ陷茨ｽｨ驕ｶ・ｯ隴幢ｽｫ邵ｺ・ｧ 隶鯉ｽｭ陷榊生竊楢ｬｾ・ｯ鬮ｫ諛岩・邵ｺ荵玲咎ｩ包ｽｩ邵ｺ・ｫ陷咲ｩゑｽｽ諛岩・郢ｧ荵晢ｼ・ｸｺ・ｨ邵ｲ繝ｻ 隶鯉ｽｭ陷榊揃・ｲ・ｰ髣包ｽｷ郢ｧ雋橸ｽ｢蜉ｱ・・ｸｺ蜆ｷI陷会ｽ｣陋ｹ謔ｶ繝ｻ驕問扱・ｭ・｢邵ｺ蜷ｶ・九・蝓溽・隰ｨ・ｰ陟・干繝ｻ髫募・・ｪ閧ｴﾂ・ｧ闖ｴ諠ｹ・ｸ荵昴・隰ｫ蝣ｺ・ｽ諛ｷ蟲・ｫｮ・｣郢晢ｽｻ鬩穂ｸｻ・ｺ・ｦ邵ｺ・ｪ陟輔・笆隴弱ｋ菫｣邵ｺ・ｪ邵ｺ・ｩ繝ｻ蟲ｨﾂ繝ｻ  # 隴崢驍ｨ繧・ｽｮ・｣髫ｪﾂ繝ｻ繝ｻaster_spec繝ｻ繝ｻ  ---  ## 隴幢ｽｬ隴厄ｽｸ邵ｺ・ｮ闖ｴ蜥ｲ・ｽ・ｮ邵ｺ・･邵ｺ謇假ｽｼ蝓滓咎お繧会ｽ｢・ｺ陞ｳ螟ｲ・ｼ繝ｻ  隴幢ｽｬ隴厄ｽｸ繝ｻ繝ｻaster_spec繝ｻ蟲ｨ繝ｻ邵ｲ繝ｻ  MEP 郢晏干ﾎ溽ｹｧ・ｸ郢ｧ・ｧ郢ｧ・ｯ郢晏現竊鍋ｸｺ鄙ｫ・郢ｧ繝ｻ**隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ蛟･繝ｻ陷夲ｽｯ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣繝ｻ繝ｻingle Source of Truth繝ｻ繝ｻ*邵ｺ・ｧ邵ｺ繧・ｽ狗ｸｲ繝ｻ  隴幢ｽｬ隴厄ｽｸ邵ｺ・ｯ邵ｲ繝ｻ  - MEP_PROTOCOL - INTERFACE_PROTOCOL - system_protocol - UI_PROTOCOL  邵ｺ・ｫ陞ｳ謔溘・邵ｺ・ｫ陟慕§・ｱ讒ｭ笘・ｹｧ荵敖繝ｻ  隴幢ｽｬ隴厄ｽｸ邵ｺ・ｯ邵ｲ繝ｻ  隶鯉ｽｭ陷榊生繝ｻ隲｢荳櫁｢也ｹ晢ｽｻ隶堤洸ﾂ・ｰ郢晢ｽｻ陋ｻ・､隴・ｽｭ陜難ｽｺ雋・じ繝ｻ邵ｺ・ｿ郢ｧ雋橸ｽｮ螟ゑｽｾ・ｩ邵ｺ蜉ｱﾂ繝ｻ  郢ｧ・ｷ郢ｧ・ｹ郢昴・ﾎ定崕・ｶ陟包ｽ｡郢晢ｽｻUI 髯ｦ・ｨ霑ｴ・ｾ郢晢ｽｻ陞ｳ貅ｯ・｣繝ｻ蟀ｿ雎戊ｼ費ｽ定楜螟ゑｽｾ・ｩ邵ｺ蜉ｱ竊醍ｸｺ繝ｻﾂ繝ｻ  ---  ## 雎・ｽ｣邵ｺ・ｮ陷夲ｽｯ闕ｳﾂ隲､・ｧ  隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ蛟･竊堤ｸｺ蜉ｱ窶ｻ邵ｺ・ｮ邵ｲ譴ｧ・ｭ・｣邵ｲ髦ｪ繝ｻ邵ｲ繝ｻ  **隴幢ｽｬ master_spec 邵ｺ・ｫ髫ｪ蛟ｩ・ｿ・ｰ邵ｺ霈費ｽ檎ｸｺ貅ｷ繝ｻ陞ｳ・ｹ邵ｺ・ｮ邵ｺ・ｿ**邵ｺ・ｨ邵ｺ蜷ｶ・狗ｸｲ繝ｻ  闔会ｽ･闕ｳ荵昴・邵ｲ繝ｻ  雎・ｽ｣邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ邵ｺ・ｮ陷会ｽｹ陷牙ｸ呻ｽ定ｬ問・笳・ｸｺ・ｪ邵ｺ繝ｻﾂ繝ｻ  - 隴鯉ｽｧ霑壹・master_spec - 雎｢・ｾ騾墓ｺ佩鍋ｹ晢ｽ｢郢晢ｽｻ髫ｱ・ｬ隴丞叙譫夂ｹ晢ｽｻ陷ｿ・｣鬯・ｽｭ髯ｬ諛・ｽｶ・ｳ - 陞ｳ貅ｯ・｣繝ｻ・ｸ鄙ｫ繝ｻ鬩幢ｽｽ陷ｷ蛹ｻ竊鍋ｹｧ蛹ｻ・矩囓・｣鬩･繝ｻ - UI 髯ｦ・ｨ驕会ｽｺ郢ｧ繝ｻ縺咏ｹｧ・ｹ郢昴・ﾎ定ｬ門雀陌夂ｸｺ荵晢ｽ臥ｸｺ・ｮ鬨ｾ繝ｻ・ｮ繝ｻ  ---  ## 陷蟠趣ｽｪ蟠趣ｽｨ・ｼ陷ｴ貅ｷ謠ｴ  隴幢ｽｬ隴厄ｽｸ邵ｺ・ｫ陷ｷ・ｫ邵ｺ・ｾ郢ｧ蠕鯉ｽ狗ｸｺ蜷ｶ竏狗ｸｺ・ｦ邵ｺ・ｮ髫補悪・ｴ・ｰ邵ｺ・ｯ邵ｲ繝ｻ  **OK繝ｻ荳茨ｽｿ・ｮ雎・ｽ｣繝ｻ荳樒ｎ鬮ｯ・､ 邵ｺ・ｮ隴丞ｮ茨ｽ､・ｺ騾ｧ繝ｻ繝ｻ髫ｱ蟠趣ｽｨ・ｼ**郢ｧ蝣､・ｵ蠕娯ｻ   雎・ｽ｣邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ驕抵ｽｺ陞ｳ螢ｹ・邵ｺ・ｦ邵ｺ繝ｻ・狗ｹｧ繧・・邵ｺ・ｨ邵ｺ蜷ｶ・狗ｸｲ繝ｻ  陷蟠趣ｽｪ蟠趣ｽｨ・ｼ邵ｺ霈費ｽ檎ｸｺ・ｦ邵ｺ繝ｻ竊醍ｸｺ繝ｻ・ｦ竏ｫ・ｴ・ｰ邵ｺ・ｯ邵ｲ繝ｻ  陝・ｼ懈Β邵ｺ蜉ｱ窶ｻ邵ｺ繝ｻ窶ｻ郢ｧ繝ｻ**霎滂ｽ｡陷会ｽｹ**邵ｺ・ｨ邵ｺ蜷ｶ・狗ｸｲ繝ｻ  ---  ## 髫ｪ・ｭ髫ｪ蛹ｻ竊定楜貅ｯ・｣繝ｻ繝ｻ陋ｻ繝ｻ螻ｬ  隴幢ｽｬ隴厄ｽｸ邵ｺ・ｯ邵ｲ繝ｻ  隶鯉ｽｭ陷榊揃・ｨ・ｭ髫ｪ蛹ｻ・定楜螟ゑｽｾ・ｩ邵ｺ蜷ｶ・玖ｭ√・蠍檎ｸｺ・ｧ邵ｺ繧・ｽ顔ｸｲ繝ｻ  陞ｳ貅ｯ・｣繝ｻ・ｻ蠅難ｽｧ蛟･縲堤ｸｺ・ｯ邵ｺ・ｪ邵ｺ繝ｻﾂ繝ｻ  隴幢ｽｬ隴厄ｽｸ邵ｺ・ｫ陞ｳ螟ゑｽｾ・ｩ邵ｺ霈費ｽ檎ｸｺ・ｦ邵ｺ繝ｻ竊醍ｸｺ繝ｻ・･・ｭ陷榊綜ﾑ崎惱・ｳ邵ｺ・ｯ邵ｲ繝ｻ  邵ｺ繝ｻﾂｰ邵ｺ・ｪ郢ｧ蜿･・ｮ貅ｯ・｣繝ｻ竊鍋ｸｺ鄙ｫ・樒ｸｺ・ｦ郢ｧ繧域ｲｻ騾包ｽｨ邵ｺ蜉ｱ窶ｻ邵ｺ・ｯ邵ｺ・ｪ郢ｧ蟲ｨ竊醍ｸｺ繝ｻﾂ繝ｻ  ---  ## 陞溽判蟲ｩ隰・玄・ｮ・ｵ邵ｺ・ｮ陷夲ｽｯ闕ｳﾂ隲､・ｧ  隴幢ｽｬ隴厄ｽｸ邵ｺ・ｸ邵ｺ・ｮ陞溽判蟲ｩ邵ｺ・ｯ邵ｲ繝ｻ  **diff 隴・ｽｹ陟台ｸ岩・郢ｧ蛹ｻ笆ｲ邵ｺ・ｦ邵ｺ・ｮ邵ｺ・ｿ**髫ｪ・ｱ陷ｿ・ｯ邵ｺ霈費ｽ檎ｹｧ荵敖繝ｻ  闔会ｽ･闕ｳ荵晢ｽ帝＊竏ｵ・ｭ・｢邵ｺ蜷ｶ・狗ｸｲ繝ｻ  - 陷茨ｽｨ隴√・繝ｻ隶貞玄繝ｻ - 鬩幢ｽｨ陋ｻ繝ｻ・ｷ・ｨ鬮ｮ繝ｻ - 霎滂ｽ｡髫ｪ蛟ｬ鮖ｸ陞溽判蟲ｩ  ---  ## 郢晏干ﾎ溽ｹ晏現縺慕ｹ晢ｽｫ髯ｦ譎会ｽｪ竏ｵ蜃ｾ邵ｺ・ｮ隰・ｽｱ邵ｺ繝ｻ  隴幢ｽｬ隴厄ｽｸ邵ｺ・ｨ陷ｷ繝ｻ繝ｻ郢晢ｽｭ郢晏現縺慕ｹ晢ｽｫ邵ｺ迹夲ｽ｡譎会ｽｪ竏夲ｼ邵ｺ貅ｷ・ｰ・ｴ陷ｷ蛹ｻﾂ繝ｻ  **郢晏干ﾎ溽ｹ晏現縺慕ｹ晢ｽｫ郢ｧ雋樞煤陷医・*邵ｺ蜷ｶ・狗ｸｲ繝ｻ  隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ蛟･繝ｻ邵ｲ繝ｻ  驍ｨ・ｱ雎撰ｽｻ隲､譎・ｦ郢晢ｽｻ陋ｻ・ｶ陟包ｽ｡陷ｴ貅ｷ謠ｴ邵ｺ・ｫ陟慕§・ｱ讒ｭ笘・ｹｧ荵敖繝ｻ  ---  ## 陟第・・ｶ蜷ｶ邃・ｸｺ・ｨ陷蜥ｲ讓溯ｫ､・ｧ  陟第・・ｶ蜷ｶ邃・ｭ弱ｅ竊鍋ｸｺ・ｯ邵ｲ繝ｻ  **陷茨ｽｨ隴√・縺慕ｹ晄鱒繝ｻ陷ｿ・ｯ髢ｭ・ｽ邵ｺ・ｪ master_spec**郢ｧ繝ｻ  陟｢繝ｻ・ｰ蝓溘・隴ｫ諛・ｻ・ｸｺ・ｨ邵ｺ蜷ｶ・狗ｸｲ繝ｻ  髫補悪・ｴ繝ｻ繝ｻ隰壽㏍・ｲ荵昴・陷蜥ｲ・ｷ・ｨ鬮ｮ繝ｻ竊鍋ｹｧ蛹ｻ・玖第・・ｶ蜷ｶ邃・ｸｺ・ｯ霎滂ｽ｡陷会ｽｹ邵ｺ・ｨ邵ｺ蜷ｶ・狗ｸｲ繝ｻ  ---  ## 隴崢驍ｨ繧・ｽｮ・｣髫ｪﾂ  隴幢ｽｬ陞ｳ・｣髫ｪﾂ郢ｧ蛛ｵ・らｸｺ・｣邵ｺ・ｦ邵ｲ繝ｻ  MEP 郢晏干ﾎ溽ｹｧ・ｸ郢ｧ・ｧ郢ｧ・ｯ郢晏現竊鍋ｸｺ鄙ｫ・郢ｧ繝ｻ  隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ蛟･繝ｻ雎・ｽ｣郢晢ｽｻ陞溽判蟲ｩ隴・ｽｹ雎戊ｼ斐・陷・ｽｪ陷育｣ｯ・ｰ繝ｻ・ｽ髦ｪ繝ｻ   **驕抵ｽｺ陞ｳ繝ｻ*邵ｺ・ｨ邵ｺ蜷ｶ・狗ｸｲ繝ｻ  邵ｺ阮呻ｽ瑚脂・･鬮ｯ髦ｪ繝ｻ隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ莨懶ｽ､逕ｻ蟲ｩ邵ｺ・ｯ邵ｲ繝ｻ  隴幢ｽｬ陞ｳ・｣髫ｪﾂ郢ｧ雋樒√隰闊娯・邵ｺ蜉ｱ笳・**陋ｻ・･郢晁ｼ斐♂郢晢ｽｼ郢ｧ・ｺ**邵ｺ・ｨ邵ｺ蜷ｶ・狗ｸｲ繝ｻ  ---    隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 1. 隶鯉ｽｭ陷榊揃・ｨ・ｭ陞ｳ螟ｲ・ｼ繝ｻusiness CONFIG繝ｻ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  1.1 陜難ｽｺ隴幢ｽｬ鬯・・蟯ｼ繝ｻ蝓滂ｽ･・ｭ陷榊揃・ｨ・ｭ陞ｳ螢ｹ竊堤ｸｺ蜉ｱ窶ｻ邵ｺ・ｮ隲｢荳櫁｢悶・繝ｻ 郢晢ｽｻ郢ｧ・ｷ郢ｧ・ｹ郢昴・ﾎ定惺繝ｻ 郢晢ｽｻ陝ｷ・ｴ陟趣ｽｦ繝ｻ荳茨ｽｼ螟奇ｽｨ蝓滓ｦ繝ｻ莠･・ｹ・ｴ陟趣ｽｦ陋ｻ繝ｻ蟠帷ｹ晢ｽｻ闖ｫ譎擾ｽｭ莨懊・陋ｻ繝ｻ蟠帷ｸｺ・ｫ鬮｢・｢郢ｧ荳奇ｽ玖ｮ鯉ｽｭ陷榊綜・ｦ繧・ｽｿ・ｵ繝ｻ繝ｻ 郢晢ｽｻ郢ｧ・ｿ郢ｧ・､郢晢｣ｰ郢ｧ・ｾ郢晢ｽｼ郢晢ｽｳ繝ｻ蝓滂ｽ･・ｭ陷榊綜蠕玖ｭ弱ｅ繝ｻ陜難ｽｺ雋・私・ｼ繝ｻ 郢晢ｽｻ驕橸ｽｼ陷呈ｦ奇ｽｯ・ｾ髮趣ｽ｡隴帶ｻ・ｿ｣繝ｻ莠･・ｹ・ｴ陟趣ｽｦ繝ｻ繝ｻ  1.2 郢晄じﾎ帷ｹ晢ｽｳ郢昜ｼ夲ｽｼ蝓滂ｽ･・ｭ陷榊雀閻ｰ闖ｴ謳ｾ・ｼ繝ｻ 郢晢ｽｻ郢晄じﾎ帷ｹ晢ｽｳ郢晏ｳｨ繝ｻ隶鯉ｽｭ陷榊雀閻ｰ闖ｴ髦ｪ縲定崕繝ｻ蟠幄愾・ｯ髢ｭ・ｽ 郢晢ｽｻ郢晄じﾎ帷ｹ晢ｽｳ郢晏ｳｨ・・ｸｺ・ｨ邵ｺ・ｫ鬯假ｽｧ陞ｳ・｢郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ郢晢ｽｻ鬩幢ｽｨ隴夊・窶ｲ霑｢・ｬ驕ｶ荵昶・郢ｧ蜈ｷ・ｼ繝ｻD隰暦ｽ･鬯・ｽｭ髴取ｧｭ繝ｻ陷ｿ・ｰ陝ｶ・ｳ陷ｿ繧峨・邵ｺ謔溘・鬮ｮ・｢邵ｺ霈費ｽ檎ｹｧ蜈ｷ・ｼ繝ｻ  1.3 郢晁ｼ斐°郢晢ｽｼ郢晢｣ｰ闕ｳﾂ髫包ｽｧ繝ｻ蝓滂ｽ･・ｭ陷榊雀繝ｻ陷ｿ・｣繝ｻ繝ｻ 郢晢ｽｻUF01繝ｻ莠･螂ｳ雎包ｽｨ繝ｻ繝ｻ 郢晢ｽｻUF06繝ｻ閧ｲ蛹ｱ雎包ｽｨ繝ｻ蜀暦ｽｴ讎雁・繝ｻ繝ｻ 郢晢ｽｻUF07繝ｻ莠包ｽｾ・｡隴ｬ・ｼ陷茨ｽ･陷牙ｹ｢・ｼ繝ｻ 郢晢ｽｻUF08繝ｻ驛・ｽｿ・ｽ陷会｣ｰ陜｣・ｱ陷ｻ螂・ｽｼ繝ｻ 郢晢ｽｻFIX繝ｻ莠包ｽｿ・ｮ雎・ｽ｣騾包ｽｳ髫ｲ蜈ｷ・ｼ繝ｻ 郢晢ｽｻDOC繝ｻ蝓溷ｶ碁ｬ俶ｧｭﾎ懃ｹｧ・ｯ郢ｧ・ｨ郢ｧ・ｹ郢晁肩・ｼ繝ｻ 郢晢ｽｻOV01繝ｻ逎ｯ螟｢髫包ｽｧ郢ｧ・ｫ郢晢ｽｫ郢昴・・ｼ繝ｻ 郢晢ｽｻOV02繝ｻ莠･繝ｻ隴√・・､諛・ｽｴ・｢繝ｻ繝ｻ  1.4 maintenanceMode繝ｻ蝓滂ｽ･・ｭ陷榊衷蝎ｪ郢晢ｽ｡郢晢ｽｳ郢昴・繝ｪ郢晢ｽｳ郢ｧ・ｹ繝ｻ繝ｻ maintenanceMode: true/false true 邵ｺ・ｮ陜｣・ｴ陷ｷ闌ｨ・ｼ繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ繝ｻ蜀怜験雎包ｽｨ繝ｻ蜀暦ｽｴ讎雁・繝ｻ荳茨ｽｾ・｡隴ｬ・ｼ陷茨ｽ･陷牙ｹ｢・ｼ蜑ｰ・ｿ・ｽ陷会｣ｰ陜｣・ｱ陷ｻ鄙ｫ竊醍ｸｺ・ｩ邵ｲ譴ｧ蟲ｩ隴・ｽｰ驍会ｽｻ隶鯉ｽｭ陷榊生ﾂ髦ｪ・定屁諛茨ｽｭ・｢邵ｺ蜷ｶ・・郢晢ｽｻ鬮｢・ｲ髫包ｽｧ繝ｻ繝ｻV01/OV02繝ｻ蟲ｨ笙郢ｧ蛹ｻ繝ｻ隰ｨ・ｴ陷ｷ蝓淞・ｧ隶諛域ｸ顔ｹｧ雋樞煤陷亥現笘・ｹｧ繝ｻ 郢晢ｽｻ鬩･蟠趣ｽｦ竏墅溽ｹｧ・ｰ髫ｪ蛟ｬ鮖ｸ邵ｺ・ｯ驍ｯ蜥擾ｽｶ螢ｹ笘・ｹｧ繝ｻ 隰ｫ蝣ｺ・ｽ諛・繝ｻ・ｼ蝓滂ｽ･・ｭ陷榊綜・ｨ・ｩ鬮ｯ謦ｰ・ｼ莨夲ｽｼ螢ｽ諤呵叉雍具ｽｽ蜥ｲ・ｮ・｡騾・・ﾂ繝ｻ繝ｻ邵ｺ・ｿ  1.5 隶難ｽｩ鬮ｯ闊湖溽ｹ晢ｽｼ郢晢ｽｫ繝ｻ蝓滂ｽ･・ｭ陷榊雀・ｽ・ｹ陷托ｽｲ繝ｻ繝ｻ guest / viewer / operator / staff / manager / admin / config-admin-primary / config-admin-secondary 郢晢ｽｻ陟厄ｽｹ陷托ｽｲ邵ｺ・ｯ邵ｲ譴ｧ・･・ｭ陷榊綜譯・抄諛翫・陷ｿ・ｯ陷ｷ・ｦ邵ｲ髦ｪ・定楜螟ゑｽｾ・ｩ邵ｺ蜷ｶ・・郢晢ｽｻ隶難ｽｩ鬮ｯ闊後・隰堋髯ｦ骰句飭髫ｱ・ｬ隴丞ｼｱ繝ｻ隴幢ｽｬ隴厄ｽｸ邵ｺ・ｫ陷ｷ・ｫ郢ｧ竏壺・邵ｺ繝ｻ・ｼ蝓滂ｽ･・ｭ陷榊姓・ｸ鄙ｫ繝ｻ陷ｿ・ｯ陷ｷ・ｦ邵ｺ・ｮ邵ｺ・ｿ繝ｻ繝ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 2. ID闖ｴ骰具ｽｳ・ｻ繝ｻ蝓滂ｽ･・ｭ陷榊雀・･驢搾ｽｴ繝ｻ・ｽ諛ｷ・ｮ謔溘・繝ｻ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  隴幢ｽｬ驕ｶ・ｰ邵ｺ・ｯ邵ｲ竏ｵ・･・ｭ陷榊姓・ｸ鄙ｫﾂ蠕｡・ｸﾂ隲｢蜑ｰ・ｭ莨懈肩郢晢ｽｻ髴托ｽｽ髴搾ｽ｡郢晢ｽｻ隰暦ｽ･驍ｯ螢ｹﾂ髦ｪ・定ｬ悟鴻・ｫ荵晢ｼ・ｸｺ蟶呻ｽ玖桙驢搾ｽｴ繝ｻ竊堤ｸｺ蜉ｱ窶ｻ陜暦ｽｺ陞ｳ螢ｹ・・ｹｧ蠕鯉ｽ狗ｸｲ繝ｻ ID 邵ｺ・ｯ隶鯉ｽｭ陷榊雀・ｱ・･雎・ｽｴ邵ｺ・ｮ隴滂ｽｱ邵ｺ・ｧ邵ｺ繧・ｽ顔ｸｲ竏昴・陋ｻ・ｩ騾包ｽｨ郢晢ｽｻ隰ｾ・ｹ陞溷ｳｨ繝ｻ陷蜥ｲ蛹ｱ騾｡・ｪ郢ｧ蝣､・ｦ竏ｵ・ｭ・｢邵ｺ蜷ｶ・狗ｸｲ繝ｻ  2.1 鬯假ｽｧ陞ｳ・｢ID繝ｻ繝ｻU_ID繝ｻ繝ｻ 隲｢荳櫁｢悶・螟撰ｽ｡・ｧ陞ｳ・｢郢ｧ蜻茨ｽｰ・ｸ驍ｯ螢ｹ竊馴垓莨懈肩邵ｺ蜷ｶ・・郢晁ｼ斐°郢晢ｽｼ郢晄ｧｭ繝｣郢晁肩・ｼ蜥ｾU-AA001 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ雎鯉ｽｸ驍ｯ蜚妊 郢晢ｽｻ陷讎願懸騾包ｽｨ闕ｳ讎雁ｺ・・荳樒ｎ鬮ｯ・､闕ｳ讎雁ｺ・・閧ｲ笏瑚怏・ｹ陋ｹ謔ｶ繝ｻ邵ｺ・ｿ繝ｻ繝ｻ 郢晢ｽｻ鬯假ｽｧ陞ｳ・｢邵ｺ・ｫ驍剰・笆ｼ邵ｺ蜀鈴ｻ・脂・ｶ邵ｺ・ｯ UP_ID 邵ｺ・ｧ髯ｦ・ｨ霑ｴ・ｾ邵ｺ蜷ｶ・・ 2.2 霑夲ｽｩ闔会ｽｶID繝ｻ繝ｻP_ID繝ｻ繝ｻ 隲｢荳櫁｢悶・螟撰ｽ｡・ｧ陞ｳ・｢邵ｺ・ｫ陟慕§・ｱ讒ｭ笘・ｹｧ迢鈴ｻ・脂・ｶ郢ｧ蜻茨ｽｰ・ｸ驍ｯ螢ｹ竊馴垓莨懈肩邵ｺ蜷ｶ・・郢晁ｼ斐°郢晢ｽｼ郢晄ｧｭ繝｣郢晁肩・ｼ蝠・-AA001-0001 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ雎鯉ｽｸ驍ｯ蜚妊 郢晢ｽｻ陟｢繝ｻ笘・CU_ID 邵ｺ・ｫ陟慕§・ｱ讒ｭ笘・ｹｧ繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ邵ｺ・ｯ UP_ID 邵ｺ・ｫ驍剰・笆ｼ邵ｺ謫ｾ・ｼ莠･驟碑叉ﾂ鬯假ｽｧ陞ｳ・｢邵ｺ・ｧ郢ｧ繧蛾ｻ・脂・ｶ邵ｺ遒・ｼ・ｸｺ蛹ｻ繝ｻ陋ｻ・･繝ｻ繝ｻ  2.3 陷ｿ邇ｲ・ｳ・ｨID繝ｻ繝ｻrder_ID繝ｻ繝ｻ 隲｢荳櫁｢悶・螢ｼ螂ｳ雎包ｽｨ郢ｧ螳夲ｽｭ莨懈肩邵ｺ蜷ｶ・玖ｮ鯉ｽｭ陷榊生繝ｻ闕ｳ・ｭ陟｢繝ｻ縺冗ｹ晢ｽｼ繝ｻ莠･繝ｻ隰暦ｽ･驍ｯ螟ゅ○繝ｻ繝ｻ 郢晁ｼ斐°郢晢ｽｼ郢晄ｧｭ繝｣郢晁肩・ｼ蜚ｹRDER-YYYYMMDD-00001-<UP_ID> 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ陷雁・ｽｽ髦ｪ縲帝具ｽｺ髯ｦ蠕鯉ｼ・ｹｧ蠕鯉ｽ九・逎ｯ謦ｼ雎鯉ｽｸ驍ｯ螟ｲ・ｼ繝ｻ 郢晢ｽｻ陷讎願懸騾包ｽｨ闕ｳ讎雁ｺ・郢晢ｽｻ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ繝ｻ蝓斜夊ｭ壽腸・ｼ蜀暦ｽｵ迹夲ｽｲ・ｻ繝ｻ荵怜ｶ碁ｬ俶ｩｸ・ｼ荳橸ｽｱ・･雎・ｽｴ繝ｻ荵暦ｽ､諛・ｽｴ・｢邵ｺ・ｮ闕ｳ・ｭ陟｢繝ｻ縺冗ｹ晢ｽｼ  2.4 鬩幢ｽｨ隴夊摯D繝ｻ繝ｻART_ID繝ｻ繝ｻ 隲｢荳櫁｢悶・螟石夊ｭ夊・・帝具ｽｺ雎包ｽｨ遶雁､・ｴ讎雁・遶雁宴・ｽ・ｿ騾包ｽｨ遶願ｲ樊Β陟趣ｽｫ邵ｺ・ｮ陷茨ｽｨ陝ｾ・･驕樔ｹ昴帝寞・ｫ鬨ｾ螟奇ｽｭ莨懈肩邵ｺ蜷ｶ・・郢晁ｼ斐°郢晢ｽｼ郢晄ｧｭ繝｣郢晁肩・ｼ繝ｻ 郢晢ｽｻBP繝ｻ蜥､P-YYYYMM-AAxx-PAyy 郢晢ｽｻBM繝ｻ蜥､M-YYYYMM-AAxx-MAyy 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻBP/BM 邵ｺ・ｧ闖ｴ骰具ｽｳ・ｻ邵ｺ謔溘・邵ｺ荵晢ｽ檎ｹｧ繝ｻ 郢晢ｽｻ陷讎願懸騾包ｽｨ闕ｳ讎雁ｺ・郢晢ｽｻ鬩幢ｽｨ隴壼鴻諞ｾ隲ｷ蜈ｷ・ｼ繝ｻTATUS繝ｻ蟲ｨ繝ｻ陷雁・ｽｽ繝ｻ  2.5 騾具ｽｺ雎包ｽｨ髯ｦ譬優繝ｻ繝ｻD_ID繝ｻ諛・ｽ｣諛ｷ蜍ｧ繝ｻ繝ｻ 隲｢荳櫁｢悶・螢ｼ驟碑叉ﾂ陷ｿ邇ｲ・ｳ・ｨ陷繝ｻ繝ｻ騾具ｽｺ雎包ｽｨ髯ｦ蠕鯉ｽ定叉ﾂ隲｢荳岩・髫ｴ莨懈肩邵ｺ蜷ｶ・矩勳諛ｷ蜍ｧID 郢晁ｼ斐°郢晢ｽｼ郢晄ｧｭ繝｣郢晁肩・ｼ蜚ｹD-<Order_ID>-001 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ1陷ｿ邇ｲ・ｳ・ｨ邵ｺ・ｫ髫阪・辟夊氛莨懈Β陷ｿ・ｯ髢ｭ・ｽ 郢晢ｽｻ隶鯉ｽｭ陷榊揃・ｿ・ｽ髴搾ｽ｡邵ｺ・ｮ髯ｬ諛ｷ蜍ｧ邵ｺ・ｧ邵ｺ繧・ｽ顔ｸｲ竏ｵ諤呵叉雍具ｽｽ髦ｪ繝ｻ隰暦ｽ･驍ｯ螢ｹ繝ｻ Order_ID 郢ｧ蝣､逡醍ｸｺ繝ｻ・・ 2.6 闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴夊摯D繝ｻ繝ｻX_ID繝ｻ繝ｻ 隲｢荳櫁｢悶・螢ｼ・ｮ貊・怙邵ｺ・ｫ闖ｴ・ｿ騾包ｽｨ邵ｺ霈費ｽ檎ｸｺ貊・夊ｭ壼頃・ｨ蛟ｬ鮖ｸ郢ｧ蜑・ｽｸﾂ隲｢荳岩・髫ｴ莨懈肩邵ｺ蜷ｶ・・郢晁ｼ斐°郢晢ｽｼ郢晄ｧｭ繝｣郢晁肩・ｼ蜩蝋-YYYYMM-0001 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻOrder_ID 郢ｧ雋樣ｫｪ闕ｳﾂ邵ｺ・ｮ隰暦ｽ･驍ｯ螢ｹ縺冗ｹ晢ｽｼ邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ隰・ｽｱ邵ｺ繝ｻ・ｼ繝ｻU/UP 郢ｧ蝣､蟲ｩ隰暦ｽ･隰問・笳・ｸｺ・ｪ邵ｺ繝ｻ・ｼ繝ｻ 郢晢ｽｻ陷讎願懸騾包ｽｨ闕ｳ讎雁ｺ・ 2.7 驍ｨ迹夲ｽｲ・ｻID繝ｻ繝ｻXP_ID繝ｻ繝ｻ 隲｢荳櫁｢悶・螟ゑｽ｢・ｺ陞ｳ螢ｹ・邵ｺ貅ｽ・ｵ迹夲ｽｲ・ｻ髫ｪ蛟ｬ鮖ｸ郢ｧ蜑・ｽｸﾂ隲｢荳岩・髫ｴ莨懈肩邵ｺ蜷ｶ・・郢晁ｼ斐°郢晢ｽｼ郢晄ｧｭ繝｣郢晁肩・ｼ蜩蝋P-YYYYMM-0001 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ陷ｷ譴ｧ諤ｦ陷繝ｻﾂ・｣騾｡・ｪ 郢晢ｽｻ陷讎願懸騾包ｽｨ闕ｳ讎雁ｺ・ 2.8 郢昴・縺帷ｹ昴・D繝ｻ繝ｻ騾｡・ｪ繝ｻ蟲ｨﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ蝓滂ｽ･・ｭ陷榊雀・ｮ迚吶・繝ｻ繝ｻ 闔会ｽ･闕ｳ荵昴・郢昴・縺帷ｹ昜ｺ･・ｰ繧臥舞邵ｺ・ｧ隴幢ｽｬ騾｡・ｪ陋ｻ・ｩ騾包ｽｨ闕ｳ讎雁ｺ・・繝ｻ AA00 / PA00 / MA00 / 0000 / EXP-YYYYMM-0000 / EX-YYYYMM-0000 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ郢昴・縺帷ｹ晏現繝ｧ郢晢ｽｼ郢ｧ・ｿ邵ｺ・ｯ隴幢ｽｬ騾｡・ｪ隶鯉ｽｭ陷榊生ﾂｰ郢ｧ陋ｾ蜍∬棔謔ｶ・・ｹｧ蠕鯉ｽ九・逎ｯ螟｢髫包ｽｧ郢晢ｽｻ隶諛・ｽｴ・｢郢晢ｽｻ鬮ｮ繝ｻ・ｨ蛹ｻ繝ｻ陝・ｽｾ髮趣ｽ｡陞溷私・ｼ繝ｻ 郢晢ｽｻ隴幢ｽｬ騾｡・ｪ郢昴・繝ｻ郢ｧ・ｿ邵ｺ・ｸ邵ｺ・ｮ雎ｬ竏ｫ逡鷹＊竏ｵ・ｭ・｢繝ｻ蝓滂ｽｷ・ｷ陜ｨ・ｨ邵ｺ・ｯ隶鯉ｽｭ陷榊衷・ｰ・ｴ驍ｯ・ｻ邵ｺ・ｨ邵ｺ・ｿ邵ｺ・ｪ邵ｺ蜻ｻ・ｼ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 3. 陷ｿ・ｰ陝ｶ・ｳ隶堤洸ﾂ・ｰ繝ｻ蝓滂ｽ･・ｭ陷榊生繝ｧ郢晢ｽｼ郢ｧ・ｿ郢晢ｽ｢郢昴・ﾎ昴・諛ｷ・ｮ謔溘・繝ｻ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  陷ｷ繝ｻ蠎願涕・ｳ邵ｺ・ｯ隶鯉ｽｭ陷榊姓・ｸ鄙ｫ繝ｻ隲｢荳櫁｢也ｹｧ蜻域亜邵ｺ・､陷夲ｽｯ闕ｳﾂ邵ｺ・ｮ闖ｫ譎会ｽｮ・｡陜｣・ｴ隰・邵ｺ・ｧ邵ｺ繧・ｽ顔ｸｲ竏晢ｽｱ・･雎・ｽｴ邵ｺ・ｯ陷台ｼ∝求邵ｺ蟶吮・髣｢繝ｻ・ｩ讎頑｢帷ｹｧ雋樊ｬ｡陷代・竊堤ｸｺ蜷ｶ・狗ｸｲ繝ｻ  3.1 CU_Master繝ｻ逎ｯ・｡・ｧ陞ｳ・｢陷ｿ・ｰ陝ｶ・ｳ繝ｻ繝ｻ 闕ｳ・ｻ郢ｧ・ｭ郢晢ｽｼ繝ｻ蜥ｾU_ID 闕ｳ・ｻ髫輔・・ｰ繝ｻ蟯ｼ繝ｻ蝓滂ｽ･・ｭ陷榊衷蝎ｪ隲｢荳櫁｢也ｹｧ蜻域亜邵ｺ・､陋ｻ證ｦ・ｼ莨夲ｽｼ繝ｻ CU_ID / 鬯假ｽｧ陞ｳ・｢陷ｷ繝ｻ/ 郢ｧ・ｫ郢昴・/ 陋ｹ・ｺ陋ｻ繝ｻ/ 鬮ｮ・ｻ髫ｧ・ｱ1 / 鬮ｮ・ｻ髫ｧ・ｱ2 / 郢晢ｽ｡郢晢ｽｼ郢晢ｽｫ / 鬩幢ｽｵ關難ｽｿ騾｡・ｪ陷ｿ・ｷ / 闖ｴ荵怜恍 / 隲｡繝ｻ・ｽ讌｢ﾂ繝ｻ骭・/ 雎包ｽｨ隲｢荳茨ｽｺ遏ｩ・ｰ繝ｻ/ 闖ｴ諛医・隴鯉ｽ･ / 隴厄ｽｴ隴・ｽｰ隴鯉ｽ･ / 隴帷甥譟・隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ隴鯉ｽ｢陝・・ｽｸﾂ髢ｾ・ｴ繝ｻ逎ｯ蟠暮圦・ｱ繝ｻ荵暦ｽｰ荳樣倹繝ｻ荳茨ｽｽ荵怜恍邵ｺ・ｪ邵ｺ・ｩ邵ｺ・ｮ隶鯉ｽｭ陷榊生縺冗ｹ晢ｽｼ繝ｻ蟲ｨ竊鍋ｹｧ蛹ｻ・願怙讎願懸騾包ｽｨ騾具ｽｻ鬪ｭ・ｲ郢ｧ螳夲ｽ｡蠕娯鴬邵ｺ阮吮・邵ｺ蠕娯旺郢ｧ繝ｻ 郢晢ｽｻ鬯假ｽｧ陞ｳ・｢隲繝ｻ・ｰ・ｱ邵ｺ・ｯ驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ邵ｺ・ｸ陷ｿ繧峨・騾包ｽｨ邵ｺ・ｫ陷ｿ閧ｴ荳千ｸｺ蜉ｱ窶ｻ郢ｧ蛹ｻ・槭・莠包ｽｻ・ｻ隲｢謫ｾ・ｼ繝ｻ  3.2 UP_Master繝ｻ閧ｲ鮟・脂・ｶ陷ｿ・ｰ陝ｶ・ｳ繝ｻ繝ｻ 闕ｳ・ｻ郢ｧ・ｭ郢晢ｽｼ繝ｻ蝠・_ID 陟｢繝ｻ・ｰ逎ｯ譛ｪ闖ｫ繧托ｽｼ蝠・_ID 邵ｺ・ｯ CU_ID 邵ｺ・ｫ陟慕§・ｱ繝ｻ 闕ｳ・ｻ髫輔・・ｰ繝ｻ蟯ｼ繝ｻ繝ｻ UP_ID / CU_ID / 霑夲ｽｩ闔会ｽｶ騾｡・ｪ陷ｿ・ｷ / 霑夲ｽｩ闔会ｽｶ陷ｷ繝ｻ/ 鬩幢ｽｵ關難ｽｿ騾｡・ｪ陷ｿ・ｷ / 闖ｴ荵怜恍 / 陝抵ｽｺ霑夲ｽｩ驕橸ｽｮ陋ｻ・･ / 鬩幢ｽｨ陞ｻ迢怜・陷ｿ・ｷ / 驍ゑｽ｡騾・・・ｼ螟ゑｽ､・ｾ / 雎包ｽｨ隲｢荳茨ｽｺ遏ｩ・ｰ繝ｻ/ 闖ｴ諛医・隴鯉ｽ･ / 隴厄ｽｴ隴・ｽｰ隴鯉ｽ･ / 隴帷甥譟・隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ陷ｷ蠕｡・ｸﾂ鬯假ｽｧ陞ｳ・｢繝ｻ蜿･驟碑叉ﾂ闖ｴ荵怜恍邵ｺ・ｮ陷讎願懸騾包ｽｨ騾具ｽｻ鬪ｭ・ｲ郢ｧ螳夲ｽ｡蠕娯鴬邵ｺ阮吮・邵ｺ蠕娯旺郢ｧ繝ｻ 郢晢ｽｻ霑夲ｽｩ闔会ｽｶ隲繝ｻ・ｰ・ｱ邵ｺ・ｯ驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ邵ｺ・ｸ陷ｿ繧峨・騾包ｽｨ邵ｺ・ｫ陷ｿ閧ｴ荳千ｸｺ蜉ｱ窶ｻ郢ｧ蛹ｻ・槭・莠包ｽｻ・ｻ隲｢謫ｾ・ｼ繝ｻ  3.3 Order_YYYY繝ｻ莠･螂ｳ雎包ｽｨ陷ｿ・ｰ陝ｶ・ｳ繝ｻ繝ｻ 闕ｳ・ｻ郢ｧ・ｭ郢晢ｽｼ繝ｻ蜚ｹrder_ID 闕ｳ・ｻ髫輔・・ｰ繝ｻ蟯ｼ繝ｻ繝ｻ Order_ID / UP_ID / CU_ID / 陝仙宴・ｽ阮吶＆郢晢ｽｼ郢昴・/ 鬯假ｽｧ陞ｳ・｢陷ｷ繝ｻ/ 鬮ｮ・ｻ髫ｧ・ｱ / 鬩幢ｽｵ關難ｽｿ騾｡・ｪ陷ｿ・ｷ / 闖ｴ荵怜恍 / addressFull / addressCityTown / 陝ｶ譴ｧ謔崎ｭ鯉ｽ･1 / 陝ｶ譴ｧ謔崎ｭ鯉ｽ･2 / 髫慕距・ｩ蝓ｼ竕｡鬯倥・/ 陋ｯ蜻ｵﾂ繝ｻ・ｼ繝ｻaw陷茨ｽｨ隴√・・ｼ繝ｻ/ summary / STATUS / CreatedAt / UpdatedAt / LastSyncedAt / HistoryNotes 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻHistoryNotes 邵ｺ・ｯ髢ｾ・ｪ騾包ｽｱ髫ｪ蛟ｩ・ｿ・ｰ邵ｺ・ｧ邵ｲ竏昴・鬩幢ｽｨ邵ｺ・ｮ Order_ID 邵ｺ・ｨ騾ｶ・ｸ闔雋樒崟霎｣・ｧ邵ｺ・ｧ邵ｺ髦ｪ・・郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ邵ｺ・ｮ霑･・ｶ隲ｷ蜈ｷ・ｼ繝ｻTATUS繝ｻ蟲ｨ繝ｻ隶鯉ｽｭ陷榊生繝ｵ郢晢ｽｭ郢晢ｽｼ邵ｺ・ｫ陟戊侭・樣明・ｪ陷肴坩繝ｻ驕假ｽｻ邵ｺ蜷ｶ・九・閧ｲ・ｫ・ｰ7郢晢ｽｻ9陷ｿ繧峨・繝ｻ繝ｻ  3.4 Parts_Master繝ｻ逎ｯﾎ夊ｭ壻ｻ吝ｺ願涕・ｳ繝ｻ繝ｻ 闕ｳ・ｻ郢ｧ・ｭ郢晢ｽｼ繝ｻ蝠ART_ID 闕ｳ・ｻ髫輔・・ｰ繝ｻ蟯ｼ繝ｻ繝ｻ PART_ID / AA騾｡・ｪ陷ｿ・ｷ / PA/MA騾｡・ｪ陷ｿ・ｷ / PART_TYPE繝ｻ繝ｻP/BM繝ｻ繝ｻ/ Order_ID / OD_ID / 陷ｩ竏ｫ蛻・/ 隰ｨ・ｰ鬩･繝ｻ/ 郢晢ｽ｡郢晢ｽｼ郢ｧ・ｫ郢晢ｽｼ / PRICE / STATUS / CREATED_AT / DELIVERED_AT / USED_DATE / MEMO / LOCATION 鬩幢ｽｨ隴壼ｿサATUS繝ｻ莠･蟠玖楜螟ｲ・ｼ莨夲ｽｼ繝ｻ STOCK / ORDERED / DELIVERED / USED / STOCK_ORDERED 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻLOCATION 邵ｺ・ｯ陜ｨ・ｨ陟趣ｽｫ繝ｻ繝ｻTOCK繝ｻ蟲ｨ縲定｢繝ｻ・ｰ繝ｻ 郢晢ｽｻBP 邵ｺ・ｯ驍乗ｦ雁・隴弱ｅ竊・PRICE 郢ｧ蝣､・｢・ｺ陞ｳ螢ｹ笘・ｹｧ繝ｻ 郢晢ｽｻBM 邵ｺ・ｯ PRICE=0繝ｻ閧ｲ・ｵ迹夲ｽｲ・ｻ陝・ｽｾ髮趣ｽ｡陞溷私・ｼ繝ｻ 郢晢ｽｻ鬩幢ｽｨ隴夊・繝ｻ陷ｿ邇ｲ・ｳ・ｨ陷繝ｻ・､謔ｶ縲定怙讎願懸騾包ｽｨ郢晢ｽｻ陜ｨ・ｨ陟趣ｽｫ邵ｺ・ｫ隰鯉ｽｻ郢ｧ髮・ｽｾ蜉ｱ・九・閧ｲ・ｫ・ｰ8郢晢ｽｻ9陷ｿ繧峨・繝ｻ繝ｻ  3.5 EX_Master繝ｻ莠包ｽｽ・ｿ騾包ｽｨ鬩幢ｽｨ隴壻ｻ吝ｺ願涕・ｳ繝ｻ繝ｻ 闕ｳ・ｻ郢ｧ・ｭ郢晢ｽｼ繝ｻ蜩蝋_ID 闕ｳ・ｻ髫輔・・ｰ繝ｻ蟯ｼ繝ｻ繝ｻ EX_ID / Order_ID / PART_ID / AA騾｡・ｪ陷ｿ・ｷ / PRICE / USED_DATE / MEMO 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ闖ｴ・ｿ騾包ｽｨ陞ｳ貅ｽ・ｸ・ｾ邵ｺ・ｮ驕抵ｽｺ陞ｳ螟奇ｽｨ蛟ｬ鮖ｸ 郢晢ｽｻOrder_ID 郢ｧ雋樣ｫｪ闕ｳﾂ邵ｺ・ｮ隰暦ｽ･驍ｯ螢ｹ縺冗ｹ晢ｽｼ邵ｺ・ｨ邵ｺ蜷ｶ・九・繝ｻU/UP 郢ｧ蝣､蟲ｩ隰暦ｽ･陷ｿ繧峨・邵ｺ蜉ｱ竊醍ｸｺ繝ｻ・ｼ繝ｻ  3.6 Expense_Master繝ｻ閧ｲ・ｵ迹夲ｽｲ・ｻ陷ｿ・ｰ陝ｶ・ｳ繝ｻ繝ｻ 闕ｳ・ｻ郢ｧ・ｭ郢晢ｽｼ繝ｻ蜩蝋P_ID 闕ｳ・ｻ髫輔・・ｰ繝ｻ蟯ｼ繝ｻ繝ｻ EXP_ID / Order_ID / PART_ID / CU_ID / UP_ID / PRICE / USED_DATE / CreatedAt 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻUSED 鬩幢ｽｨ隴夊・繝ｻ PRICE 郢ｧ蝣､・｢・ｺ陞ｳ螟ゑｽｵ迹夲ｽｲ・ｻ邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ髫ｪ蛟ｬ鮖ｸ邵ｺ蜷ｶ・玖悁・ｯ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣ 郢晢ｽｻ鬩･鮃ｹ・｡髦ｪ繝ｻ隰暦ｽｨ雋ゑｽｬ郢晢ｽｻ闔会ｽ｣陷茨ｽ･邵ｺ・ｯ驕問扱・ｭ・｢繝ｻ閧ｲ・｢・ｺ陞ｳ螢ｼ繝ｻ陷牙ｸ吶・邵ｺ・ｿ繝ｻ繝ｻ  3.7 Request繝ｻ閧ｲ遲城坿蜿･蠎願涕・ｳ繝ｻ蜩･IX/DOC/UF07/UF08繝ｻ繝ｻ 闕ｳ・ｻ髫輔・・ｰ繝ｻ蟯ｼ繝ｻ繝ｻ Timestamp / Category / TargetID / PayloadJSON / Requester / Memo 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ闖ｫ・ｮ雎・ｽ｣繝ｻ荵怜ｶ碁ｬ俶ｩｸ・ｼ蝓寂横鬯伜ｴ趣ｽ｣諛ｷ・ｮ魃会ｽｼ蜑ｰ・ｿ・ｽ陷会｣ｰ陜｣・ｱ陷ｻ鄙ｫ・帝包ｽｳ髫ｲ荵昶・邵ｺ蜉ｱ窶ｻ闖ｫ譎・亜邵ｺ蜷ｶ・矩ｂ・ｱ 郢晢ｽｻ陷繝ｻ・ｮ・ｹ邵ｺ・ｯ隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ邵ｺ・ｫ陟戊侭笆ｲ邵ｺ・ｦ髫暦ｽ｣鬩･蛹ｻ繝ｻ陷ｿ閧ｴ荳千ｸｺ霈費ｽ檎ｹｧ繝ｻ 郢晢ｽｻ陷奇ｽｱ鬮ｯ・ｺ闖ｫ・ｮ雎・ｽ｣邵ｺ・ｯ隴丞ｮ茨ｽ｢・ｺ邵ｺ・ｫ陋ｹ・ｺ陋ｻ・･邵ｺ蜉ｱﾂ竏ｫ蟲ｩ隰暦ｽ･鬩包ｽｩ騾包ｽｨ郢ｧ蝣､・ｦ竏ｵ・ｭ・｢邵ｺ蜷ｶ・九・閧ｲ・ｫ・ｰ10繝ｻ繝ｻ  3.8 logs/system郢晢ｽｻlogs/extra繝ｻ蝓滂ｽ･・ｭ陷榊生ﾎ溽ｹｧ・ｰ繝ｻ繝ｻ 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ鬩･蟠趣ｽｦ竏壹＞郢ｧ・ｯ郢ｧ・ｷ郢晢ｽｧ郢晢ｽｳ邵ｺ・ｯ髫ｪ蛟ｬ鮖ｸ邵ｺ蜉ｱﾂ竏晢ｽｱ・･雎・ｽｴ髴托ｽｽ髴搾ｽ｡邵ｺ・ｮ隴ｬ・ｹ隲｡・ｰ邵ｺ・ｨ邵ｺ蜷ｶ・・郢晢ｽｻ隶諛・ｽｴ・｢繝ｻ繝ｻV02繝ｻ蟲ｨ繝ｻ陝・ｽｾ髮趣ｽ｡邵ｺ・ｨ邵ｺ・ｪ郢ｧ蜈ｷ・ｼ閧ｲ・ｫ・ｰ11繝ｻ繝ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 4. 闖ｴ荵怜恍闖ｴ骰具ｽｳ・ｻ繝ｻ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  闖ｴ荵怜恍邵ｺ・ｯ闔会ｽ･闕ｳ繝ｻ隴幢ｽｬ邵ｺ・ｧ闖ｫ譎・亜邵ｺ蜷ｶ・九・繝ｻ 遶ｭ・ｰ addressFull繝ｻ莠･繝ｻ隴√・・ｽ荵怜恍繝ｻ繝ｻ 遶ｭ・｡ addressCityTown繝ｻ莠･・ｸ繧・私騾包ｽｺ繝ｻ迢嶺ｼｴ陷ｷ髦ｪ竏ｪ邵ｺ・ｧ繝ｻ繝ｻ  隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻaddressCityTown 邵ｺ・ｯ隶鯉ｽｭ陷榊姓・ｸ鄙ｫ繝ｻ雎・ｽ｣陟台ｸ楪・､邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ隰・ｽｱ邵ｺ繝ｻ 郢晢ｽｻ隰夲ｽｽ陷・ｽｺ陜難ｽｺ雋・私・ｼ螢ｼ・ｸ繧托ｽｼ荳樒私繝ｻ蜀嶺ｼｴ繝ｻ荵玲雛繝ｻ蝓斜鍋ｸｺ・ｾ邵ｺ・ｧ繝ｻ迢怜ｳｩ陟募ｾ後・騾包ｽｺ陷ｷ髦ｪﾂ竏ｽ・ｸ竏ｫ蟯ｼ闔会ｽ･闕ｳ荵昴・陷ｷ・ｫ郢ｧ竏壺・邵ｺ繝ｻ 郢晢ｽｻ鬮｢・ｲ髫包ｽｧ繝ｻ繝ｻV01繝ｻ蟲ｨ繝ｻ驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ邵ｺ・ｧ邵ｺ・ｮ陷ｿ繧峨・郢ｧ・ｭ郢晢ｽｼ邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ騾包ｽｨ邵ｺ繝ｻ・・ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 5. UF01繝ｻ莠･螂ｳ雎包ｽｨ繝ｻ逕ｻ・･・ｭ陷榊姓・ｻ蠅難ｽｧ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  騾ｶ・ｮ騾ｧ繝ｻ・ｼ螟青螟り｡崎怦・ｨ隴√・・ｼ蜀暦ｽｰ・｡隴剰侭ﾎ鍋ｹ晢ｽ｢邵ｺ荵晢ｽ芽愾邇ｲ・ｳ・ｨ郢ｧ蟶晏ｹ戊沂荵晢ｼ邵ｲ繝ｻ・｡・ｧ陞ｳ・｢郢晢ｽｻ霑夲ｽｩ闔会ｽｶ郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ郢ｧ蜻茨ｽｭ・｣邵ｺ蜉ｱ・･驍剰・笆ｼ邵ｺ莉｣・狗ｸｲ繝ｻ  5.1 陷茨ｽ･陷牙ｹ・｣ｰ繝ｻ蟯ｼ繝ｻ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ繝ｻ 郢晢ｽｻraw繝ｻ逎ｯﾂ螟り｡崎怦・ｨ隴√・or 1髯ｦ蠕湖鍋ｹ晢ｽ｢繝ｻ迚呻ｽｿ繝ｻ・ｰ繝ｻ 郢晢ｽｻname / phone / addressFull / preferred1 / preferred2 / price  5.2 陷ｿ邇ｲ・ｳ・ｨ驕抵ｽｺ陞ｳ螢ｽ蜃ｾ邵ｺ・ｮ隶鯉ｽｭ陷榊衷・ｵ蜈域｣｡ 郢晢ｽｻCU_Master繝ｻ螟撰ｽ｡・ｧ陞ｳ・｢邵ｺ・ｮ隴・ｽｰ髫募臆・ｿ・ｽ陷会｣ｰ邵ｺ・ｾ邵ｺ貅倥・隴鯉ｽ｢陝・ｼ懊・陋ｻ・ｩ騾包ｽｨ 郢晢ｽｻUP_Master繝ｻ螟るｻ・脂・ｶ邵ｺ・ｮ隴・ｽｰ髫募臆・ｿ・ｽ陷会｣ｰ邵ｺ・ｾ邵ｺ貅倥・隴鯉ｽ｢陝・ｼ懊・陋ｻ・ｩ騾包ｽｨ 郢晢ｽｻOrder_YYYY繝ｻ蜚ｹrder_ID 騾具ｽｺ髯ｦ蠕個竏晄ｸ戊ｭ幢ｽｬ隲繝ｻ・ｰ・ｱ邵ｲ縲隔mmary邵ｲ竏昴・隴帶ｬ傍ATUS邵ｲ竏晢ｽｱ・･雎・ｽｴ隴ｫ・ｰ邵ｺ・ｮ闖ｴ諛医・ 郢晢ｽｻ霑ｴ・ｾ陜｣・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ繝ｻ螢ｼ繝ｻ隴帶ｺ倥■郢ｧ・ｹ郢ｧ・ｯ騾墓ｻ薙・ 郢晢ｽｻ驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ繝ｻ螢ｼ逶ｾ霎｣・ｧ騾包ｽｨ邵ｺ・ｫ陋ｻ譎丞ｱ馴ｨｾ螟り｡阪・莠包ｽｻ・ｻ隲｢謫ｾ・ｼ繝ｻ  5.3 summary繝ｻ蝓滂ｽ･・ｭ陷榊生縺帷ｹｧ・ｿ郢晢ｽｳ郢晄圜・ｼ繝ｻ 郢晢ｽｻsummary 邵ｺ・ｯ陷ｿ邇ｲ・ｳ・ｨ陷繝ｻ・ｮ・ｹ邵ｺ・ｮ隶鯉ｽｭ陷榊生縺咲ｹ昴・縺也ｹ晢ｽｪ郢晢ｽｻ闖ｴ諛茨ｽ･・ｭ郢ｧ・ｹ郢ｧ・ｿ郢晢ｽｳ郢晏干・定ｰｿ荵昶・ 郢晢ｽｻ鬩穂ｸｻ閾・ｸｺ・ｪ髫補悪・ｴ繝ｻ繝ｻ騾ｵ竏ｫ謇慕ｸｺ・ｯ驕問扱・ｭ・｢繝ｻ蝓滂ｽ･・ｭ陷榊雀諢幄ｭ・ｽｭ邵ｺ・ｮ驗ゑｽｮ隰蟶ｷ・ｦ竏ｵ・ｭ・｢繝ｻ繝ｻ  5.4 霑ｴ・ｾ陜｣・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ陷ｷ謳ｾ・ｼ莠･繝ｻ隴帶ｺｽ蜃ｽ隰梧腸・ｼ繝ｻ 陟厄ｽ｢陟第得・ｼ蝌ｴAA驗抵ｽ､}{鬯假ｽｧ陞ｳ・｢陷ｷ謳ｾ・ｼ蝓溷匐驕假ｽｰ闔牙∞・ｼ蜴ｭ{addressCityTown}_{陝仙宴・ｽ蜈・郢晢ｽｻ陋ｻ譎丞ｱ鍋ｸｺ・ｯ AA驗抵ｽ､邵ｺ・ｪ邵ｺ繝ｻ 郢晢ｽｻ陟墓ｪ趣ｽｶ螢ｹ繝ｻ騾具ｽｺ雎包ｽｨ繝ｻ蜀暦ｽｴ讎雁・邵ｺ・ｧ AA驗抵ｽ､邵ｺ蠕｡・ｻ蛟・ｽｸ蠑ｱ・・ｹｧ蠕鯉ｽ九・閧ｲ・ｫ・ｰ7繝ｻ繝ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 6. 鬩幢ｽｨ隴夊揄・ｽ骰具ｽｳ・ｻ繝ｻ繝ｻP/BM/AA/PA/MA/LOCATION/陝偵・蛻・恷讓雁ｶ後・繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  6.1 PART_TYPE繝ｻ蝓滂ｽ･・ｭ陷榊雀・ｮ螟ゑｽｾ・ｩ繝ｻ繝ｻ 郢晢ｽｻBP繝ｻ蛹ｻﾎ鍋ｹ晢ｽｼ郢ｧ・ｫ郢晢ｽｼ隰・洸繝ｻ陷ｩ繝ｻ・ｼ莨夲ｽｼ螟ゑｽｴ讎雁・隴弱ｅ竊・PRICE 驕抵ｽｺ陞ｳ繝ｻ 郢晢ｽｻBM繝ｻ蝓滄㈹髯ｬ・ｽ陷ｩ繝ｻ・ｼ荵鈴ｫｪ驍ｨ・ｦ陷ｩ竏ｫ・ｭ莨夲ｽｼ莨夲ｽｼ蝠RICE=0繝ｻ閧ｲ・ｵ迹夲ｽｲ・ｻ陝・ｽｾ髮趣ｽ｡陞溷私・ｼ繝ｻ  6.2 雎鯉ｽｸ驍ｯ螟ょ・陷ｿ・ｷ繝ｻ繝ｻA繝ｻ繝ｻ AA01邵ｲ蠖〇99繝ｻ蛹ｻ繝ｦ郢ｧ・ｹ郢昴・A00邵ｺ・ｯ驕問扱・ｭ・｢繝ｻ繝ｻ 隲｢荳櫁｢悶・螟石夊ｭ壼鴻・ｾ・､郢ｧ蜻茨ｽ･・ｭ陷榊揃・ｿ・ｽ髴搾ｽ｡邵ｺ蜷ｶ・狗ｸｺ貅假ｽ∫ｸｺ・ｮ雎鯉ｽｸ驍ｯ螟ょ・陷ｿ・ｷ繝ｻ蛹ｻ縺｡郢ｧ・ｹ郢ｧ・ｯ陷ｷ髦ｪ竊鍋ｹｧ繧・ｸ夊ｭ擾｣ｰ繝ｻ繝ｻ  6.3 隴ｫ譎牙・繝ｻ繝ｻA/MA繝ｻ繝ｻ 郢晢ｽｻBP繝ｻ蝠A01邵ｲ蠑ア99繝ｻ繝ｻA00驕問扱・ｭ・｢繝ｻ繝ｻ 郢晢ｽｻBM繝ｻ蜩ｺA01邵ｲ蟒ｴA99繝ｻ繝ｻA00驕問扱・ｭ・｢繝ｻ繝ｻ  6.4 陜ｨ・ｨ陟趣ｽｫ郢晢ｽｭ郢ｧ・ｱ郢晢ｽｼ郢ｧ・ｷ郢晢ｽｧ郢晢ｽｳ繝ｻ繝ｻOCATION繝ｻ繝ｻ 郢晢ｽｻ陜ｨ・ｨ陟趣ｽｫ繝ｻ繝ｻTOCK繝ｻ蟲ｨ竊堤ｸｺ蜉ｱ窶ｻ闖ｫ譎・亜邵ｺ蜷ｶ・矩ｩ幢ｽｨ隴夊・繝ｻ LOCATION 郢ｧ雋橸ｽｿ繝ｻ・ｰ蛹ｻ竊堤ｸｺ蜷ｶ・・郢晢ｽｻLOCATION 隹ｺ・ｰ髣懶ｽｽ邵ｺ・ｯ隶鯉ｽｭ陷榊姓・ｸ讎奇ｽ咏ｸｺ・ｨ邵ｺ蜉ｱ窶ｻ隰・ｽｱ邵ｺ繝ｻﾂ竏ｫ・ｮ・｡騾・・繝ｻ邵ｺ・ｸ髫ｴ・ｦ陷ｻ髮・ｽｯ・ｾ髮趣ｽ｡邵ｺ・ｨ邵ｺ・ｪ郢ｧ繝ｻ  6.5 陝偵・蛻・遶翫・隴・ｽｰ騾｡・ｪ 陝・ｽｾ陟｢諛・ｽｾ讓雁ｶ後・蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ繝ｻ 鬩幢ｽｨ隴壼頃・ｾ讓雁ｶ檎ｸｺ・ｫ闔会ｽ･闕ｳ荵晢ｽ定ｬ問・笆ｽ繝ｻ繝ｻ discontinued / replacement / keywords / photoUrl 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ陝偵・蛻・ｸｺ・ｮ陜｣・ｴ陷ｷ蛹ｻ繝ｻ闔会ｽ｣隴厄ｽｿ陷ｩ竏ｵ・｡莠･繝ｻ郢ｧ蜻育ｽｲ驕会ｽｺ邵ｺ蜷ｶ・九・蝓滓咎お繧域ｲｻ騾包ｽｨ陋ｻ・､隴・ｽｭ邵ｺ・ｯ隶鯉ｽｭ陷榊生ﾎ溽ｹｧ・ｸ郢昴・縺醍ｸｺ・ｧ驕抵ｽｺ陞ｳ螟ｲ・ｼ繝ｻ 郢晢ｽｻkeywords 邵ｺ・ｯ陷茨ｽｨ隴√・・､諛・ｽｴ・｢邵ｺ・ｮ隴門戟荵りｮ諛・ｽｴ・｢髯ｬ諛ｷ蜍ｧ邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ陋ｻ・ｩ騾包ｽｨ邵ｺ蜷ｶ・・隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 7. UF06/UF07/UF08繝ｻ逎ｯﾎ夊ｭ壼・・･・ｭ陷榊遜・ｼ謌托ｽｻ蠅難ｽｧ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  7.1 UF06繝ｻ閧ｲ蛹ｱ雎包ｽｨ繝ｻ逕ｻ・･・ｭ陷阪・ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ螟石夊ｭ夊・繝ｻ騾具ｽｺ雎包ｽｨ郢ｧ蝣､・｢・ｺ陞ｳ螢ｹ・邵ｲ・｣arts_Master 邵ｺ・ｫ髫ｪ蛟ｬ鮖ｸ邵ｺ蜷ｶ・狗ｸｲ繝ｻ 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻBP/BM 陋ｹ・ｺ陋ｻ繝ｻ・帝￡・ｺ陞ｳ螢ｹ笘・ｹｧ繝ｻ 郢晢ｽｻ隰暦ｽ｡騾包ｽｨ邵ｺ霈費ｽ檎ｸｺ貅ｯ・｡蠕後・邵ｺ・ｿ騾具ｽｺ雎包ｽｨ隰・ｽｱ邵ｺ繝ｻ竊堤ｸｺ蜷ｶ・・郢晢ｽｻOrder_ID 邵ｺ蠕娯・邵ｺ繝ｻ蛹ｱ雎包ｽｨ邵ｺ・ｯ STOCK_ORDERED 邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ隰・ｽｱ邵ｺ繝ｻ  騾具ｽｺ雎包ｽｨ驕抵ｽｺ陞ｳ螢ｽ蜃ｾ邵ｺ・ｫ髫ｪ蛟ｬ鮖ｸ邵ｺ蜷ｶ・玖ｮ鯉ｽｭ陷榊衷・ｵ蜈域｣｡繝ｻ蝓滂ｽｦ繧奇ｽｦ繝ｻ・ｼ莨夲ｽｼ繝ｻ 郢晢ｽｻPART_ID 騾具ｽｺ髯ｦ魃会ｽｼ繝ｻP/BM邵ｺ・ｮ闖ｴ骰具ｽｳ・ｻ邵ｺ・ｫ陟戊侭竕ｧ繝ｻ繝ｻ 郢晢ｽｻOD_ID 騾具ｽｺ髯ｦ魃会ｽｼ驛・ｽ｣諛ｷ蜍ｧ繝ｻ繝ｻ 郢晢ｽｻSTATUS=ORDERED 郢晢ｽｻBP繝ｻ蝠RICE 隴幢ｽｪ陞ｳ繝ｻ 郢晢ｽｻBM繝ｻ蝠RICE=0 郢晢ｽｻ陟｢繝ｻ・ｦ竏壺・陟｢諛環ｧ邵ｺ・ｦ驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ邵ｺ・ｸ陜ｨ・ｨ陟趣ｽｫ郢ｧ・ｹ郢昴・繝ｻ郢ｧ・ｿ郢ｧ・ｹ鬨ｾ螟り｡阪・莠包ｽｻ・ｻ隲｢謫ｾ・ｼ繝ｻ  7.2 UF06繝ｻ閧ｲ・ｴ讎雁・繝ｻ逕ｻ・･・ｭ陷阪・ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ螟ゑｽｴ讎雁・郢ｧ蝣､・｢・ｺ陞ｳ螢ｹ・邵ｲ繝ｻﾎ夊ｭ壼鴻諞ｾ隲ｷ荵晢ｽ帝ｨｾ・ｲ髯ｦ蠕鯉ｼ・ｸｺ蟶呻ｽ狗ｸｲ繝ｻ 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻSTATUS=DELIVERED 郢晢ｽｻDELIVERED_AT 郢ｧ螳夲ｽｨ蛟ｬ鮖ｸ 郢晢ｽｻBP 邵ｺ・ｯ PRICE 陷茨ｽ･陷牙ｸ幢ｽｿ繝ｻ・ｰ闌ｨ・ｼ閧ｲ・ｴ讎雁・隴弱ｉ・｢・ｺ陞ｳ螟ｲ・ｼ繝ｻ 郢晢ｽｻLOCATION 郢ｧ螳夲ｽｨ蛟ｬ鮖ｸ繝ｻ莠･諠陟趣ｽｫ郢晢ｽｻ驍ゑｽ｡騾・・竊楢｢繝ｻ・ｦ繝ｻ・ｼ繝ｻ 郢晢ｽｻAA驗抵ｽ､郢ｧ蜻域ｭ楢怎・ｺ邵ｺ蜉ｱﾂ竏ｫ讓溯撻・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ陷ｷ髦ｪ竏郁愾閧ｴ荳千ｸｺ蜷ｶ・・郢晢ｽｻ陷茨ｽｨ陝・ｽｾ髮趣ｽ｡邵ｺ讙趣ｽｴ讎雁・雋ょ現繝ｻ陜｣・ｴ陷ｷ蛹ｻﾂ竏晏･ｳ雎包ｽｨSTATUS邵ｺ・ｮ髢ｾ・ｪ陷榊供諢幄楜螢ｹ窶ｲ髯ｦ蠕鯉ｽ冗ｹｧ蠕鯉ｽ九・閧ｲ・ｫ・ｰ8郢晢ｽｻ9繝ｻ繝ｻ  7.3 UF07繝ｻ莠包ｽｾ・｡隴ｬ・ｼ陷茨ｽ･陷牙ｹ｢・ｼ逕ｻ・･・ｭ陷阪・ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ蜥､P 邵ｺ・ｮ PRICE 隴幢ｽｪ陷茨ｽ･陷牙ｸ呻ｽ帝勳諛ｷ・ｮ蠕鯉ｼ邵ｲ竏ｵ・･・ｭ陷榊生竊堤ｸｺ蜉ｱ窶ｻ關難ｽ｡隴ｬ・ｼ郢ｧ蝣､・｢・ｺ陞ｳ螢ｹ笘・ｹｧ荵敖繝ｻ 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻPART_ID 邵ｺ・ｮ PRICE 郢ｧ蜻亥ｳｩ隴・ｽｰ 郢晢ｽｻ鬩幢ｽｨ隴壼ｿサATUS邵ｺ・ｯ陷ｴ貅ｷ謠ｴ陞溽判蟲ｩ邵ｺ蜉ｱ竊醍ｸｺ繝ｻ・ｼ莠包ｽｾ・｡隴ｬ・ｼ驕抵ｽｺ陞ｳ螢ｹ繝ｻ邵ｺ・ｿ繝ｻ繝ｻ 郢晢ｽｻ關難ｽ｡隴ｬ・ｼ隴幢ｽｪ驕抵ｽｺ陞ｳ螢ｹ繝ｻ驍ゑｽ｡騾・・繝ｻ髫ｴ・ｦ陷ｻ鄙ｫ繝ｻ陝・ｽｾ髮趣ｽ｡  7.4 UF08繝ｻ驛・ｽｿ・ｽ陷会｣ｰ陜｣・ｱ陷ｻ螂・ｽｼ逕ｻ・･・ｭ陷阪・ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ螟奇ｽｿ・ｽ陷会｣ｰ陷蜥乗ｄ繝ｻ蜑ｰ・ｿ・ｽ陷会｣ｰ髫ｱ・ｬ隴丞ｼｱ・定愾邇ｲ・ｳ・ｨ邵ｺ・ｫ驍剰・笆ｼ邵ｺ莉｣窶ｻ闖ｫ譎擾ｽｭ蛟･笘・ｹｧ荵敖繝ｻ 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ髴托ｽｽ陷会｣ｰ陜｣・ｱ陷ｻ鄙ｫ繝ｻ陷ｿ邇ｲ・ｳ・ｨ邵ｺ・ｮ隶鯉ｽｭ陷榊揃・ｨ蛟ｬ鮖ｸ邵ｺ・ｧ邵ｺ繧・ｽ顔ｸｲ竏晢ｽｱ・･雎・ｽｴ髴托ｽｽ髴搾ｽ｡邵ｺ・ｮ陝・ｽｾ髮趣ｽ｡ 郢晢ｽｻ鬮｢・ｲ髫包ｽｧ繝ｻ繝ｻV01繝ｻ蟲ｨ竊楢怺・ｳ隴弱ｇ貂夊ｭ擾｣ｰ邵ｺ霈費ｽ檎ｹｧ繝ｻ 郢晢ｽｻ髴托ｽｽ陷会｣ｰ陜｣・ｱ陷ｻ鄙ｫ繝ｻ騾包ｽｳ髫ｲ荵昶・邵ｺ蜉ｱ窶ｻRequest邵ｺ・ｫ隹ｿ荵晢ｼ邵ｺ・ｦ郢ｧ蛹ｻ・槭・逎ｯﾂｰ騾包ｽｨ隴・ｽｹ鬩･譎｢・ｼ繝ｻ  7.5 陷ｿ邇ｲ・ｳ・ｨSTATUS髢ｾ・ｪ陷榊供諢幄楜螟ｲ・ｼ蝓滂ｽ･・ｭ陷榊雀・ｮ螟ゑｽｾ・ｩ繝ｻ繝ｻ 陷ｿ邇ｲ・ｳ・ｨSTATUS邵ｺ・ｯ邵ｲ竏ｫ・ｴ讎雁・霑･・ｶ雎補・繝ｻ鬩幢ｽｨ隴夊・繝ｻ霑･・ｶ隲ｷ荵昴・陷蜥ｲ蛹ｱ雎包ｽｨ郢晁ｼ釆帷ｹｧ・ｰ驕ｲ蟲ｨ・帝包ｽｨ邵ｺ繝ｻ窶ｻ髢ｾ・ｪ陷榊供諢幄楜螢ｹ・・ｹｧ蠕鯉ｽ狗ｸｲ繝ｻ 郢晢ｽｻ闔・ｺ郢晢ｽｻAI邵ｺ蠕｡・ｻ・ｻ隲｢荳岩・陞溽判蟲ｩ邵ｺ蜉ｱ窶ｻ邵ｺ・ｯ邵ｺ・ｪ郢ｧ蟲ｨ竊醍ｸｺ繝ｻ 郢晢ｽｻ鬩包ｽｷ驕假ｽｻ隴夲ｽ｡闔会ｽｶ邵ｺ・ｯ邵ｲ譴ｧ・･・ｭ陷榊生繝ｵ郢晢ｽｭ郢晢ｽｼ邵ｺ・ｫ雎撰ｽｿ邵ｺ・｣邵ｺ貅ｽ・｢・ｺ陞ｳ螢ｹ縺・ｹ晏生ﾎｦ郢晏現ﾂ髦ｪ竊鍋ｹｧ蛹ｻ笆ｲ邵ｺ・ｦ邵ｺ・ｮ邵ｺ・ｿ隰悟鴻・ｫ荵昶・郢ｧ繝ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 8. 郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ驍ゑｽ｡騾・・・ｼ閧ｲ讓溯撻・ｴ繝ｻ蜀暦ｽｮ・｡騾・・・ｼ逕ｻ・･・ｭ陷榊姓・ｻ蠅難ｽｧ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  8.1 霑ｴ・ｾ陜｣・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ繝ｻ莠･鬮ｪ闕ｳﾂ邵ｺ・ｮ陞ｳ蠕｡・ｺ繝ｻ・ｰ・ｱ陷ｻ豸ｯI繝ｻ繝ｻ 郢晢ｽｻ霑ｴ・ｾ陜｣・ｴ邵ｺ・ｮ闖ｴ諛茨ｽ･・ｭ邵ｺ・ｯ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ陷雁・ｽｽ髦ｪ縲帝ｂ・｡騾・・・・ｹｧ蠕鯉ｽ・郢晢ｽｻ陞ｳ蠕｡・ｺ繝ｻ・ｰ・ｱ陷ｻ螂・ｽｼ莠･・ｮ蠕｡・ｺ繝ｻ縺慕ｹ晢ｽ｡郢晢ｽｳ郢晏現・定惺・ｫ郢ｧﾂ繝ｻ蟲ｨ窶ｲ邵ｲ譴ｧ・･・ｭ陷榊雀・ｮ蠕｡・ｺ繝ｻ繝ｻ隲｢荵猟譎・ｽ｡・ｨ驕会ｽｺ邵ｲ髦ｪ竊堤ｸｺ蜉ｱ窶ｻ隰・ｽｱ郢ｧ荳奇ｽ檎ｹｧ繝ｻ 郢晢ｽｻ霑ｴ・ｾ陜｣・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ邵ｺ・ｯ陷ｿ邇ｲ・ｳ・ｨ繝ｻ繝ｻrder_ID繝ｻ蟲ｨ竊楢叉ﾂ隲｢荳岩・驍剰・笆ｼ邵ｺ繝ｻ  8.2 郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ陷ｷ謳ｾ・ｼ閧ｲ讓溯撻・ｴ繝ｻ繝ｻ 陟厄ｽ｢陟第得・ｼ蝌ｴAA驗抵ｽ､}{鬯假ｽｧ陞ｳ・｢陷ｷ謳ｾ・ｼ蝓溷匐驕假ｽｰ闔牙∞・ｼ蜴ｭ{addressCityTown}_{陝仙宴・ｽ蜈・郢晢ｽｻaddressCityTown 邵ｺ・ｯ隶鯉ｽｭ陷榊姓・ｸ鄙ｫ繝ｻ雎・ｽ｣陟台ｸ楪・､郢ｧ蜑・ｽｽ・ｿ騾包ｽｨ 郢晢ｽｻAA驗抵ｽ､邵ｺ・ｯ鬩幢ｽｨ隴壻ｻ呻ｽｷ・･驕樔ｹ昴・鬨ｾ・ｲ髯ｦ蠕娯・郢ｧ蛹ｻ・願脂蛟・ｽｸ蠑ｱ繝ｻ隴厄ｽｴ隴・ｽｰ邵ｺ霈費ｽ檎ｹｧ繝ｻ  8.3 驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ繝ｻ閧ｲ螻ｮ騾ｹ・｣UI繝ｻ繝ｻ 陟厄ｽｹ陷托ｽｲ繝ｻ繝ｻ 郢晢ｽｻ鬩輔・・ｻ・ｶ隶諛・｡咲ｹ晢ｽｻ騾｡・ｰ陝ｶ・ｸ騾ｶ・｣髫墓じ繝ｻ髫ｴ・ｦ陷ｻ髮∝･ｳ闖ｫ・｡ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ陷雁・ｽｽ髦ｪ繝ｻ鬨ｾ・ｲ髯ｦ譴ｧ貊題ｬ・｡ 郢晢ｽｻ霑ｴ・ｾ陜｣・ｴ邵ｺ・ｨ邵ｺ・ｯ陋ｻ繝ｻ螻ｬ繝ｻ莠･繝ｻ陷牙ｸ吶・驕問扱・ｭ・｢邵ｲ竏ｫ螻ｮ騾ｹ・｣邵ｺ・ｮ邵ｺ・ｿ繝ｻ繝ｻ 驍ゑｽ｡騾・・縺｡郢ｧ・ｹ郢ｧ・ｯ陷ｷ謳ｾ・ｼ莠包ｽｾ蜈ｷ・ｼ莨夲ｽｼ繝ｻ 邵ｲ莉呻ｽｪ蜑・ｽｽ阮卍鮃ｹ・｡・ｧ陞ｳ・｢陷ｷ繝ｻ/ addressCityTown / OrderID:xxx 陷ｷ譴ｧ謔・ｸｺ霈費ｽ檎ｹｧ蜿･逶ｾ霎｣・ｧ隲繝ｻ・ｰ・ｱ繝ｻ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ莨夲ｽｼ繝ｻ Order_ID / addressCityTown / 鬯假ｽｧ陞ｳ・｢陷ｷ繝ｻ/ STATUS / 陋幢ｽ･陟趣ｽｷ郢ｧ・ｹ郢ｧ・ｳ郢ｧ・｢ / 鬩募供譟ｱ隲｢貅ｽ・ｴ・ｰ隴壹・/ 鬩輔・・ｻ・ｶ郢晢ｽｻ闕ｳ蟠趣ｽｶ・ｳ郢晁ｼ釆帷ｹｧ・ｰ  8.4 驍ゑｽ｡騾・・・ｭ・ｦ陷ｻ螂・ｽｼ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ繝ｻ 闔会ｽ･闕ｳ荵昶ｲ騾具ｽｺ騾墓ｺ假ｼ邵ｺ貅ｷ・ｰ・ｴ陷ｷ蛹ｻﾂ竏ｫ・ｮ・｡騾・・繝ｻ邵ｺ・ｸ髫ｴ・ｦ陷ｻ髮・ｽｯ・ｾ髮趣ｽ｡邵ｺ・ｨ邵ｺ・ｪ郢ｧ蜈ｷ・ｼ繝ｻ 郢晢ｽｻPRICE隴幢ｽｪ陷茨ｽ･陷峨・ 郢晢ｽｻ隴幢ｽｪ驍乗ｦ雁・鬩幢ｽｨ隴壹・ 郢晢ｽｻ闖ｴ荵怜恍闕ｳ閧ｴ邏幄惺繝ｻ 郢晢ｽｻ陷蜥乗ｄ闕ｳ蟠趣ｽｶ・ｳ 郢晢ｽｻ鬩募供譟ｱ隲｢貅ｽ・ｴ・ｰ隴壽腸・ｼ莠包ｽｽ荵怜恍郢ｧ繝ｻ・臥ｸｺ雜｣・ｼ荵怜・驍会ｽｻ陋ｻ遉ｼ辟夊涕・ｸ繝ｻ荵玲椢驕ｶ・ｰ騾｡・ｰ陝ｶ・ｸ邵ｺ・ｪ邵ｺ・ｩ繝ｻ繝ｻ 郢晢ｽｻ髴托ｽｽ陷会｣ｰ陜｣・ｱ陷ｻ鄙ｫ・・嵩・｡隴ｬ・ｼ陷茨ｽ･陷牙ｸ吶・闕ｳ蟠趣ｽｶ・ｳ 郢晢ｽｻ隶鯉ｽｭ陷榊綜邏幄惺蝓淞・ｧ郢ｧ・ｨ郢晢ｽｩ郢晢ｽｼ繝ｻ蝓滂ｽ､諛域ｸ劾G繝ｻ繝ｻ  8.5 隴幢ｽｪ闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴壻ｻ吶・騾・・・ｼ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ繝ｻ 陞ｳ蠕｡・ｺ繝ｻ・ｰ・ｱ陷ｻ鄙ｫﾂｰ郢ｧ逕ｻ謔ｴ闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴夊摯D郢ｧ蜻域ｭ楢怎・ｺ邵ｺ蜉ｱﾂ竏晄Β陟趣ｽｫ繝ｻ繝ｻTOCK繝ｻ蟲ｨ竏郁ｬ鯉ｽｻ邵ｺ蜷ｶﾂ繝ｻ 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ陜ｨ・ｨ陟趣ｽｫ隰鯉ｽｻ邵ｺ蜉ｱ繝ｻ LOCATION 邵ｺ・ｮ隰ｨ・ｴ陷ｷ蛹ｻ窶ｲ陟｢繝ｻ・ｰ繝ｻ 郢晢ｽｻ闕ｳ閧ｴ邏幄惺蛹ｻ繝ｻ驍ゑｽ｡騾・・・ｭ・ｦ陷ｻ鄙ｫ繝ｻ陝・ｽｾ髮趣ｽ｡  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 9. 陞ｳ蠕｡・ｺ繝ｻ驟碑ｭ帶ｻゑｽｼ莠･・ｮ蠕｡・ｺ繝ｻ・ｰ・ｱ陷ｻ蟯ｩ繝ｻ陷ｿ・ｰ陝ｶ・ｳ驕抵ｽｺ陞ｳ螟ｲ・ｼ逕ｻ・･・ｭ陷榊姓・ｻ蠅難ｽｧ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  騾ｶ・ｮ騾ｧ繝ｻ・ｼ螟よｨ溯撻・ｴ陞ｳ蠕｡・ｺ繝ｻ・ｰ・ｱ陷ｻ鄙ｫ・定･搾ｽｷ霓､・ｹ邵ｺ・ｫ邵ｲ竏晏･ｳ雎包ｽｨ郢晢ｽｻ鬩幢ｽｨ隴夊・繝ｻ驍ｨ迹夲ｽｲ・ｻ郢晢ｽｻ陞ｻ・･雎・ｽｴ郢ｧ蝣､・｢・ｺ陞ｳ螢ｹ・・ｸｺ蟶呻ｽ狗ｸｲ繝ｻ  9.1 陞ｳ蠕｡・ｺ繝ｻ繝ｨ郢晢ｽｪ郢ｧ・ｬ郢晢ｽｼ繝ｻ蝓滂ｽ･・ｭ陷榊遜・ｼ繝ｻ 郢晢ｽｻ霑ｴ・ｾ陜｣・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ邵ｺ・ｮ陞ｳ蠕｡・ｺ繝ｻ窶ｲ陞ｳ蠕｡・ｺ繝ｻ驟碑ｭ帶ｺ倥・隘搾ｽｷ霓､・ｹ邵ｺ・ｨ邵ｺ・ｪ郢ｧ繝ｻ 郢晢ｽｻ陞ｳ蠕｡・ｺ繝ｻ蠕玖ｭ弱ｅ竊定楜蠕｡・ｺ繝ｻ縺慕ｹ晢ｽ｡郢晢ｽｳ郢昜ｺ･繝ｻ隴√・繝ｻ隶鯉ｽｭ陷榊雀・ｱ・･雎・ｽｴ邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ闖ｫ譎擾ｽｭ蛟･・・ｹｧ蠕鯉ｽ・ 9.2 陞ｳ蠕｡・ｺ繝ｻ蜃ｾ邵ｺ・ｫ驕抵ｽｺ陞ｳ螢ｹ・・ｹｧ蠕鯉ｽ玖ｮ鯉ｽｭ陷榊衷・ｵ蜈域｣｡繝ｻ莠･・ｿ繝ｻ・ｰ闌ｨ・ｼ繝ｻ 郢晢ｽｻOrder繝ｻ螢ｼ・ｮ蠕｡・ｺ繝ｻ蠕玖ｭ弱ｑ・ｼ蜀玲・隲ｷ蛹ｺ蟲ｩ隴・ｽｰ繝ｻ荵玲咎お繧・・隴帶ｻ灘ｾ玖ｭ弱ｅ繝ｻ隴厄ｽｴ隴・ｽｰ 郢晢ｽｻParts繝ｻ蜥ｼELIVERED 鬩幢ｽｨ隴夊・繝ｻ USED 陋ｹ蜴・ｽｼ莠包ｽｽ・ｿ騾包ｽｨ驕抵ｽｺ陞ｳ螟ｲ・ｼ繝ｻ 郢晢ｽｻEX繝ｻ螢ｻ・ｽ・ｿ騾包ｽｨ鬩幢ｽｨ隴壼頃・ｨ蛟ｬ鮖ｸ邵ｺ・ｮ驕抵ｽｺ陞ｳ螟ｲ・ｼ莠･・ｿ繝ｻ・ｦ繝ｻ・ｰ繝ｻ蟯ｼ邵ｺ・ｮ髫ｪ蛟ｬ鮖ｸ繝ｻ繝ｻ 郢晢ｽｻExpense繝ｻ螢ｻ・ｽ・ｿ騾包ｽｨ鬩幢ｽｨ隴夊・竊楢搏・ｺ邵ｺ・･邵ｺ蜀暦ｽｵ迹夲ｽｲ・ｻ邵ｺ・ｮ驕抵ｽｺ陞ｳ繝ｻ 郢晢ｽｻ隴幢ｽｪ闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴壽腸・ｼ蜚ｮTOCK隰鯉ｽｻ邵ｺ證ｦ・ｼ繝ｻOCATION隰ｨ・ｴ陷ｷ莠･・ｿ繝ｻ・ｰ闌ｨ・ｼ繝ｻ 郢晢ｽｻ郢晢ｽｭ郢ｧ・ｰ繝ｻ螟舌裟髫補・縺・ｹ晏生ﾎｦ郢晏現繝ｻ髫ｪ蛟ｬ鮖ｸ 郢晢ｽｻ驍ゑｽ｡騾・・・ｼ螟青・ｲ髯ｦ遒・螟り｡咲ｸｺ鄙ｫ・育ｸｺ・ｳ髫ｴ・ｦ陷ｻ螂・ｽｼ莠包ｽｻ・ｻ隲｢謫ｾ・ｼ繝ｻ  9.3 隴幢ｽｪ闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴夊・縺慕ｹ晢ｽ｡郢晢ｽｳ郢晏沺蠍瑚第得・ｼ蝓滂ｽ･・ｭ陷榊遜・ｼ繝ｻ 關灘・・ｼ螢ｽ謔ｴ闖ｴ・ｿ騾包ｽｨ繝ｻ蜥､P-YYYYMM-AAxx-PAyy, BM-YYYYMM-AAxx-MAyy 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ隴厄ｽｸ陟台ｸ環ｰ郢ｧ陋ｾﾎ夊ｭ夊摯D郢ｧ蜻域ｭ楢怎・ｺ邵ｺ・ｧ邵ｺ髦ｪ・狗ｸｺ阮吮・ 郢晢ｽｻ隰夲ｽｽ陷・ｽｺ邵ｺ霈費ｽ檎ｸｺ貊・夊ｭ夊・繝ｻ陜ｨ・ｨ陟趣ｽｫ陷・ｽｦ騾・・繝ｻ陝・ｽｾ髮趣ｽ｡邵ｺ・ｨ邵ｺ・ｪ郢ｧ繝ｻ  9.4 陋幢ｽ･陟趣ｽｷ郢ｧ・ｹ郢ｧ・ｳ郢ｧ・｢繝ｻ蝓滂ｽ･・ｭ陷榊綜谺隶灘遜・ｼ繝ｻ 0邵ｲ繝ｻ00霓､・ｹ 雋ょｸｷ縺幃囎竏ｫ・ｴ・ｰ關灘・・ｼ繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ隲繝ｻ・ｰ・ｱ邵ｺ・ｮ隹ｺ・ｰ髣懶ｽｽ 郢晢ｽｻBP邵ｺ・ｮ關難ｽ｡隴ｬ・ｼ隴幢ｽｪ陷茨ｽ･陷峨・ 郢晢ｽｻ陷蜥乗ｄ闕ｳ蟠趣ｽｶ・ｳ 郢晢ｽｻ隴幢ｽｪ闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴壻ｻ吶・騾・・・ｸ讎奇ｽ・郢晢ｽｻ鬩募供譟ｱ隲｢貅ｽ・ｴ・ｰ隴夊・繝ｻ陞溷､ょ験 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ郢晢ｽｻ鬩幢ｽｨ隴壼鴻諞ｾ隲ｷ荵昴・闕ｳ閧ｴ邏幄惺繝ｻ 鬩慕距逡代・繝ｻ 郢晢ｽｻ鬮｢・ｲ髫包ｽｧ繝ｻ繝ｻV01繝ｻ蟲ｨ竊馴勗・ｨ驕会ｽｺ 郢晢ｽｻ70霓､・ｹ隴幢ｽｪ雋・邵ｺ・ｯ闕ｳ讎奇ｽ咏ｸｺ繧・ｽ顔ｸｺ・ｨ邵ｺ蜉ｱ窶ｻ隰・ｽｱ邵ｺ繝ｻﾂ竏ｫ・ｮ・｡騾・・繝ｻ邵ｺ・ｮ騾ｶ・｣騾ｹ・｣陝・ｽｾ髮趣ｽ｡邵ｺ・ｨ邵ｺ蜷ｶ・・隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 10. FIX / DOC繝ｻ閧ｲ遲城坿蜈ｷ・ｼ逕ｻ・･・ｭ陷榊姓・ｻ蠅難ｽｧ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  10.1 FIX繝ｻ莠包ｽｿ・ｮ雎・ｽ｣騾包ｽｳ髫ｲ蜈ｷ・ｼ繝ｻ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ螢ｼ莠幃ｫｯ・ｺ邵ｺ・ｪ闖ｫ・ｮ雎・ｽ｣郢ｧ蝣､遲城坿荵昶・邵ｺ蜉ｱ窶ｻ隰・ｽｱ邵ｺ繝ｻﾂ竏ｵ・･・ｭ陷榊生・帝＄・ｴ陞｢鄙ｫ笳狗ｸｺ螢ｹ竊楢将・ｮ雎・ｽ｣郢ｧ蟶敖・ｲ郢ｧ竏夲ｽ狗ｸｲ繝ｻ 郢ｧ・ｫ郢昴・縺也ｹ晢ｽｪ關灘・・ｼ繝ｻ 郢晢ｽｻ騾具ｽｺ雎包ｽｨ郢ｧ・ｭ郢晢ｽ｣郢晢ｽｳ郢ｧ・ｻ郢晢ｽｫ繝ｻ驛・ｽｿ豕悟・陷ｿ・ｯ繝ｻ荳茨ｽｸ讎雁ｺ・・繝ｻ 郢晢ｽｻ驍乗ｦ雁・郢ｧ・ｭ郢晢ｽ｣郢晢ｽｳ郢ｧ・ｻ郢晢ｽｫ繝ｻ驛・ｽｿ豕悟・陷ｿ・ｯ繝ｻ荳茨ｽｸ讎雁ｺ・・繝ｻ 郢晢ｽｻ陋ｹ・ｺ陋ｻ繝ｻ・､逕ｻ蟲ｩ繝ｻ繝ｻP遶企洌M繝ｻ繝ｻ 郢晢ｽｻ陷茨ｽ･郢ｧ髮・・､闖ｫ・ｮ雎・ｽ｣ 郢晢ｽｻ隹ｺ・ｰ騾｡・ｪ隰・ｽｱ邵ｺ繝ｻ 郢晢ｽｻ陜ｨ・ｨ陟趣ｽｫ陋ｻ繝ｻ螻ｬ邵ｺ繝ｻ 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ驍ゑｽ｡騾・・・ｼ蜀怜ｱｮ騾ｹ・｣邵ｺ・ｮ陋ｻ・､隴・ｽｭ郢ｧ螳夲ｽｦ竏壺・郢ｧ蛟ｶ・ｿ・ｮ雎・ｽ｣邵ｺ・ｯ邵ｲ讙守ｭ城坿荵敖髦ｪ竊堤ｸｺ蜉ｱ窶ｻ隹ｿ荵昶・ 郢晢ｽｻ郢ｧ・ｳ郢晢ｽ｡郢晢ｽｳ郢晁ご・ｭ蟲ｨ繝ｻ髴・ｽｽ驍・・竊題怦・･陷牙ｸ吶定怺・ｱ鬮ｯ・ｺ闖ｫ・ｮ雎・ｽ｣郢ｧ蝣､蟲ｩ隰暦ｽ･驕抵ｽｺ陞ｳ螢ｹ・邵ｺ・ｦ邵ｺ・ｯ邵ｺ・ｪ郢ｧ蟲ｨ竊醍ｸｺ繝ｻ  10.2 郢ｧ・ｳ郢晢ｽ｡郢晢ｽｳ郢晏現竊鍋ｹｧ蛹ｻ・矩怕・ｽ陟包ｽｮ闖ｫ・ｮ雎・ｽ｣繝ｻ驛・ｽｨ・ｱ陷ｿ・ｯ驕ｽ繝ｻ蟲・・繝ｻ 髫ｪ・ｱ陷ｿ・ｯ繝ｻ繝ｻ 郢晢ｽｻ郢晢ｽ｡郢晢ｽｼ郢晢ｽｫ髴托ｽｽ陷会｣ｰ 郢晢ｽｻ雎包ｽｨ隲｢荳茨ｽｺ遏ｩ・ｰ繝ｻ・ｿ・ｽ陷会｣ｰ 郢晢ｽｻ隲｡繝ｻ・ｽ讌｢ﾂ繝ｻ骭宣恆・ｽ陷会｣ｰ 郢晢ｽｻ陋ｯ蜻ｵﾂ繝ｻ・ｿ・ｽ陷会｣ｰ 郢晢ｽｻ髴・ｽｽ陟包ｽｮ邵ｺ・ｪ髫慕距・ｩ蝣ｺ・ｿ・ｮ雎・ｽ｣ 郢晢ｽｻ闖ｴ・ｿ騾包ｽｨ鬩幢ｽｨ隴夊・繝ｻ髴托ｽｽ陷会｣ｰ髫ｪ蛟ｬ鮖ｸ繝ｻ莠･轤朱ｫｯ・､闕ｳ讎雁ｺ・・繝ｻ  驕問扱・ｭ・｢繝ｻ莠･莠幃ｫｯ・ｺ闖ｫ・ｮ雎・ｽ｣繝ｻ莨夲ｽｼ繝ｻ 郢晢ｽｻBP遶企洌M陞溽判蟲ｩ 郢晢ｽｻ關難ｽ｡隴ｬ・ｼ陞滂ｽｧ陝ｷ繝ｻ・ｿ・ｮ雎・ｽ｣ 郢晢ｽｻ隹ｺ・ｰ騾｡・ｪ隰・ｽｱ邵ｺ繝ｻ 郢晢ｽｻ陜ｨ・ｨ陟趣ｽｫ陋ｻ繝ｻ螻ｬ邵ｺ繝ｻ 郢晢ｽｻ陷ｩ竏ｫ蛻・棔逕ｻ蟲ｩ 郢晢ｽｻ鬯假ｽｧ陞ｳ・｢陷ｷ讎奇ｽ､逕ｻ蟲ｩ 郢晢ｽｻ鬯假ｽｧ陞ｳ・｢闖ｴ荵怜恍陞溽判蟲ｩ 郢晢ｽｻ霑夲ｽｩ闔会ｽｶ闖ｴ荵怜恍陞溽判蟲ｩ 郢晢ｽｻAA陷蜥ｲ蛹ｱ騾｡・ｪ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨID隶堤洸ﾂ・ｰ陞溽判蟲ｩ 郢晢ｽｻ隴厄ｽｸ鬯俶ｧｫ繝ｻ陞ｳ・ｹ陞溽判蟲ｩ  10.3 DOC繝ｻ蝓溷ｶ碁ｬ俶ｧｭﾎ懃ｹｧ・ｯ郢ｧ・ｨ郢ｧ・ｹ郢晁肩・ｼ繝ｻ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ螟奇ｽｦ迢暦ｽｩ閧ｴ蠍後・蜑ｰ・ｫ蛹ｺ・ｱ繧亥ｶ後・蝓趣｣ｰ莨懷ｺｶ隴厄ｽｸ驕ｲ蟲ｨ・定ｮ鯉ｽｭ陷榊揃・ｨ蛟ｬ鮖ｸ邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ騾墓ｻ薙・邵ｺ蜷ｶ・狗ｸｺ貅假ｽ∫ｸｺ・ｮ騾包ｽｳ髫ｲ荵敖繝ｻ 陷茨ｽ･陷牙ｹ・｣ｰ繝ｻ蟯ｼ繝ｻ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ莨夲ｽｼ繝ｻ orderId / docType / docName / docDesc / docPrice / docMemo 隶鯉ｽｭ陷榊生ﾎ晉ｹ晢ｽｼ郢晢ｽｫ繝ｻ繝ｻ 郢晢ｽｻ騾包ｽｳ髫ｲ荵昴・ Request 邵ｺ・ｫ髫ｪ蛟ｬ鮖ｸ邵ｺ霈費ｽ檎ｹｧ繝ｻ 郢晢ｽｻ騾墓ｻ薙・霑夲ｽｩ邵ｺ・ｯ陷ｿ邇ｲ・ｳ・ｨ邵ｺ・ｫ驍剰・笆ｼ邵ｺ荵暦ｽ･・ｭ陷榊揃・ｨ蛟ｬ鮖ｸ邵ｺ・ｨ邵ｺ蜉ｱ窶ｻ闖ｫ譎擾ｽｭ蛟･・・ｹｧ蠕鯉ｽ・ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 11. 鬮｢・ｲ髫包ｽｧ郢晢ｽｻ隶諛・ｽｴ・｢繝ｻ繝ｻV01 / OV02繝ｻ逕ｻ・･・ｭ陷榊姓・ｻ蠅難ｽｧ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  11.1 OV01繝ｻ逎ｯ螟｢髫包ｽｧ郢ｧ・ｫ郢晢ｽｫ郢昴・・ｼ繝ｻ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ螢ｼ螂ｳ雎包ｽｨ陷雁・ｽｽ髦ｪ繝ｻ陷茨ｽｨ隶鯉ｽｭ陷榊綜繝･陜｣・ｱ郢ｧ蜑・ｽｸﾂ騾包ｽｻ鬮ｱ・｢邵ｺ・ｧ鬮｢・ｲ髫包ｽｧ邵ｺ蜷ｶ・狗ｸｲ繝ｻ 髯ｦ・ｨ驕会ｽｺ鬯・・蟯ｼ繝ｻ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ莨夲ｽｼ繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ陜難ｽｺ隴幢ｽｬ隲繝ｻ・ｰ・ｱ繝ｻ逎ｯ・｡・ｧ陞ｳ・｢陷ｷ謳ｾ・ｼ荳茨ｽｽ荵怜恍繝ｻ荳橸ｽｪ蜑・ｽｽ髮｣・ｼ繝ｻ 郢晢ｽｻ鬯假ｽｧ陞ｳ・｢隲繝ｻ・ｰ・ｱ繝ｻ繝ｻU_Master繝ｻ繝ｻ 郢晢ｽｻ霑夲ｽｩ闔会ｽｶ隲繝ｻ・ｰ・ｱ繝ｻ繝ｻP_Master繝ｻ繝ｻ 郢晢ｽｻsummary 郢晢ｽｻ霑ｴ・ｾ陜｣・ｴ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ隲繝ｻ・ｰ・ｱ 郢晢ｽｻSTATUS 郢晢ｽｻLOCATION 郢晢ｽｻ鬩幢ｽｨ隴夊揄・ｸﾂ髫包ｽｧ繝ｻ繝ｻA/PA/MA繝ｻ繝ｻ 郢晢ｽｻ陷蜥乗ｄ繝ｻ繝ｻefore/after/parts/extra繝ｻ繝ｻ 郢晢ｽｻ陷肴・蛻､繝ｻ繝ｻnspection繝ｻ繝ｻ 郢晢ｽｻEX繝ｻ諡ｾXP 郢晢ｽｻHistoryNotes 郢晢ｽｻ陋幢ｽ･陟趣ｽｷ郢ｧ・ｹ郢ｧ・ｳ郢ｧ・｢ 郢晢ｽｻ鬩募供譟ｱ隲｢貅ｽ・ｴ・ｰ隴壽腸・ｼ驛・ｽｭ・ｦ陷ｻ鄙ｫﾎ帷ｹ晏生ﾎ昴・繝ｻ  11.2 HistoryNotes繝ｻ莠･・ｱ・･雎・ｽｴ郢晢ｽ｡郢晢ｽ｢繝ｻ繝ｻ 郢晢ｽｻ髢ｾ・ｪ騾包ｽｱ髫ｪ蛟ｩ・ｿ・ｰ 郢晢ｽｻ陷繝ｻﾎ夊愾繧峨・繝ｻ繝ｻrder_ID繝ｻ蟲ｨ竊堤ｹ晢ｽｪ郢晢ｽｳ郢ｧ・ｯ邵ｺ蜉ｱﾂ竏ｬ・ｿ・ｽ髴搾ｽ｡陷ｿ・ｯ髢ｭ・ｽ邵ｺ・ｫ邵ｺ蜷ｶ・・郢晢ｽｻ隶諛・ｽｴ・｢陝・ｽｾ髮趣ｽ｡繝ｻ繝ｻV02繝ｻ繝ｻ  11.3 OV02繝ｻ莠･繝ｻ隴√・・､諛・ｽｴ・｢繝ｻ繝ｻ 騾ｶ・ｮ騾ｧ繝ｻ・ｼ螢ｼ螂ｳ雎包ｽｨ郢晁ｼ斐°郢晢ｽｫ郢敖繝ｻ蛹ｻﾎ溽ｹｧ・ｰ繝ｻ荳槭・騾ｵ貊ゑｽｼ隘ｲDF驕ｲ莨夲ｽｼ蟲ｨ・定ｮ難ｽｪ隴・ｽｭ隶諛・ｽｴ・｢邵ｺ闍難ｽｪ・ｿ隴滂ｽｻ陷ｿ・ｯ髢ｭ・ｽ邵ｺ・ｫ邵ｺ蜷ｶ・狗ｸｲ繝ｻ 隶諛・ｽｴ・｢陝・ｽｾ髮趣ｽ｡繝ｻ蝓滂ｽ･・ｭ陷榊揃・ｦ竏ｽ・ｻ・ｶ繝ｻ莨夲ｽｼ繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ陷ｿ・ｰ陝ｶ・ｳ繝ｻ閧ｲ讓滄勗魃会ｽｼ荳翫＞郢晢ｽｼ郢ｧ・ｫ郢ｧ・､郢晏私・ｼ繝ｻ 郢晢ｽｻ隶鯉ｽｭ陷榊生ﾎ溽ｹｧ・ｰ繝ｻ繝ｻogs/system繝ｻ繝ｻ 郢晢ｽｻ髴托ｽｽ陷会｣ｰ陜｣・ｱ陷ｻ螂・ｽｼ繝ｻF08繝ｻ繝ｻ 郢晢ｽｻHistoryNotes 郢晢ｽｻ鬩幢ｽｨ隴壼・繝･陜｣・ｱ 郢晢ｽｻ陷蜥乗ｄ郢晢ｽｻPDF驕ｲ蟲ｨ繝ｻ郢昴・縺冗ｹｧ・ｹ郢昜ｺ･蝟ｧ驍擾｣ｰ隴壽腸・ｼ驛・ｽ｣諛ｷ蜍ｧ驍擾｣ｰ隴夊・竊堤ｸｺ蜉ｱ窶ｻ闖ｫ譎擾ｽｭ蛟･・・ｹｧ蠕娯螺郢ｧ繧・・繝ｻ繝ｻ  隶諛・ｽｴ・｢郢晏現ﾎ懃ｹｧ・ｬ郢晢ｽｼ繝ｻ蝓滂ｽ･・ｭ陷榊遜・ｼ莨夲ｽｼ繝ｻ 隶諛・ｽｴ・｢繝ｻ蜑ｰ・ｪ・ｿ隴滂ｽｻ繝ｻ荳橸ｽｱ・･雎・ｽｴ隶諛・ｽｴ・｢繝ｻ荵礼粟邵ｺ蜉ｱ窶ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 12. 鬩慕距逡醍ｹ晢ｽｫ郢晢ｽｼ郢晢ｽｫ繝ｻ蝓滂ｽ･・ｭ陷榊衷・ｵ・ｱ雎撰ｽｻ繝ｻ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  12.1 master_spec 邵ｺ・ｮ闕ｳ讎奇ｽ､繝ｻ 郢晢ｽｻ隴幢ｽｬ隴厄ｽｸ邵ｺ・ｯ隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ蛟･繝ｻ陷夲ｽｯ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣邵ｺ・ｧ邵ｺ繧・ｽ・郢晢ｽｻ鬩穂ｸｻ謔臥ｸｺ・ｮ郢晢ｽ｡郢晢ｽ｢繝ｻ蜑ｰ・ｨ蛟ｬ鮖ｸ繝ｻ荵苓ｳ雋ゑｽｬ邵ｺ・ｯ隶鯉ｽｭ陷榊姓・ｻ蠅難ｽｧ蛟･竊堤ｸｺ蜉ｱ窶ｻ陷会ｽｹ陷牙ｸ呻ｽ定ｬ問・笳・ｸｺ・ｪ邵ｺ繝ｻ 郢晢ｽｻ陞溽判蟲ｩ邵ｺ・ｯ陝ｾ・ｮ陋ｻ繝ｻ蟀ｿ陟台ｸ岩・郢ｧ蛹ｻ笆ｲ邵ｺ・ｦ邵ｺ・ｮ邵ｺ・ｿ髯ｦ蠕鯉ｽ冗ｹｧ蠕鯉ｽ・ 12.2 陷茨ｽ･陷牙ｸ帙・陷ｿ・｣邵ｺ・ｮ闕ｳ讎奇ｽ､繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ繝ｻ蝓斜夊ｭ壽腸・ｼ荳茨ｽｾ・｡隴ｬ・ｼ繝ｻ蜑ｰ・ｿ・ｽ陷会｣ｰ陜｣・ｱ陷ｻ鄙ｫ繝ｻ UF 驍会ｽｻ郢晁ｼ斐°郢晢ｽｼ郢晢｣ｰ邵ｺ謔滄ｫｪ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣ 郢晢ｽｻ驍ゑｽ｡騾・・繝､郢晢ｽｼ郢晢ｽｫ邵ｺ荵晢ｽ臥ｸｺ・ｮ陷茨ｽ･陷牙ｸ吶・驕問扱・ｭ・｢繝ｻ閧ｲ螻ｮ騾ｹ・｣邵ｺ・ｮ邵ｺ・ｿ繝ｻ繝ｻ  12.3 陞ｻ・･雎・ｽｴ闖ｫ譎上・ 郢晢ｽｻ陞ｻ・･雎・ｽｴ邵ｺ・ｯ陷台ｼ∝求邵ｺ蟶吮・髣｢繝ｻ・ｩ謳ｾ・ｼ蛹ｻ縺・ｹ晢ｽｼ郢ｧ・ｫ郢ｧ・､郢晞摩諤ｧ郢ｧﾂ繝ｻ繝ｻ 郢晢ｽｻ隶諛・ｽｴ・｢陝・ｽｾ髮趣ｽ｡邵ｺ荵晢ｽ芽棔謔ｶ・・ｸｺ・ｪ邵ｺ繝ｻ・ｼ逎ｯ蜍∬棔謔ｶ笘・ｸｺ・ｹ邵ｺ髦ｪ繝ｻ郢昴・縺帷ｹ晏現繝ｧ郢晢ｽｼ郢ｧ・ｿ邵ｺ・ｮ邵ｺ・ｿ繝ｻ繝ｻ  12.4 陜ｨ・ｨ陟趣ｽｫ驕抵ｽｺ髫ｱ髦ｪ繝ｻ隴厄ｽｴ隴・ｽｰ繝ｻ蝓滂ｽ･・ｭ陷榊生繝ｨ郢晢ｽｪ郢ｧ・ｬ郢晢ｽｼ繝ｻ繝ｻ 陜ｨ・ｨ陟趣ｽｫ驕抵ｽｺ髫ｱ謳ｾ・ｼ繝ｻ 郢晢ｽｻ陜ｨ・ｨ陟趣ｽｫ鬩幢ｽｨ隴壽腸・ｼ繝ｻTATUS=STOCK繝ｻ蟲ｨ繝ｻ闕ｳﾂ髫包ｽｧ郢ｧ螳夲ｽｿ譁絶雷郢ｧ荵晢ｼ・ｸｺ・ｨ繝ｻ莠･蛻騾｡・ｪ繝ｻ荵礼・鬩･謫ｾ・ｼ蟆ｱA繝ｻ閾ｭOCATION繝ｻ繝ｻ 隴厄ｽｴ隴・ｽｰ繝ｻ莠･繝ｻ陷ｷ譴ｧ謔・・莨夲ｽｼ繝ｻ 郢晢ｽｻ陷ｿ邇ｲ・ｳ・ｨ郢晢ｽｻ郢ｧ・｢郢晢ｽｼ郢ｧ・ｫ郢ｧ・､郢晄じ繝ｻ鬩幢ｽｨ隴夊・繝ｻ驍ｨ迹夲ｽｲ・ｻ郢晢ｽｻ郢ｧ・ｿ郢ｧ・ｹ郢ｧ・ｯ郢晢ｽｻ驍ゑｽ｡騾・・逶ｾ霎｣・ｧ郢ｧ蜻育ｴ幄惺蛹ｻ笘・ｹｧ繝ｻ 郢晢ｽｻ陷・ｪ驕ｲ莨夲ｽｼ莠包ｽｽ蜍滂ｽｺ・ｦ髯ｦ蠕娯夢邵ｺ・ｦ郢ｧ繧・ｽ｣鄙ｫ・檎ｸｺ・ｪ邵ｺ繝ｻ・ｼ蟲ｨ・定ｲ・邵ｺ貅倪・  12.5 驕問扱・ｭ・｢闔遏ｩ・ｰ繝ｻ・ｼ蝓滂ｽ･・ｭ陷榊衷・ｰ・ｴ陞｢莨∽ｺ溯ｱ・ｽ｢繝ｻ繝ｻ 郢晢ｽｻ隶鯉ｽｭ陷榊雀諢幄ｭ・ｽｭ邵ｺ・ｮ隶難ｽｪ陷ｿ謔ｶ・翫・莠包ｽｺ・ｺ繝ｻ蟆ｱI繝ｻ荳橸ｽ､螟慚壹・繝ｻ 郢晢ｽｻ鬮ｱ讓奇ｽｭ・｣髫募・・ｵ迹夲ｽｷ・ｯ邵ｺ荵晢ｽ臥ｸｺ・ｮ陷茨ｽ･陷峨・ 郢晢ｽｻID邵ｺ・ｮ陷讎願懸騾包ｽｨ郢晢ｽｻ隰ｾ・ｹ陞溘・ 郢晢ｽｻ陷奇ｽｱ鬮ｯ・ｺ闖ｫ・ｮ雎・ｽ｣邵ｺ・ｮ騾ｶ・ｴ隰暦ｽ･驕抵ｽｺ陞ｳ繝ｻ 郢晢ｽｻ陞ｻ・･雎・ｽｴ邵ｺ・ｮ陷台ｼ∝求 郢晢ｽｻUI陷会ｽ｣陋ｹ蜴・ｽｼ閧ｲ讓溯撻・ｴ髮具｣ｰ髣包ｽｷ陟・圜・ｼ繝ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 13. 騾包ｽｨ髫ｱ讖ｸ・ｼ繝ｻlossary繝ｻ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉  郢晢ｽｻCU_ID繝ｻ螟撰ｽ｡・ｧ陞ｳ・｢郢ｧ螳夲ｽｭ莨懈肩邵ｺ蜷ｶ・玖ｱ鯉ｽｸ驍ｯ蜚妊 郢晢ｽｻUP_ID繝ｻ螟るｻ・脂・ｶ郢ｧ螳夲ｽｭ莨懈肩邵ｺ蜷ｶ・玖ｱ鯉ｽｸ驍ｯ蜚妊繝ｻ繝ｻU邵ｺ・ｫ陟慕§・ｱ讖ｸ・ｼ繝ｻ 郢晢ｽｻOrder_ID繝ｻ螢ｼ螂ｳ雎包ｽｨ郢ｧ螳夲ｽｭ莨懈肩邵ｺ蜷ｶ・玖叉・ｭ陟｢繝ｻ縺冗ｹ晢ｽｼ繝ｻ莠･繝ｻ隰暦ｽ･驍ｯ螟ゅ○繝ｻ繝ｻ 郢晢ｽｻPART_ID繝ｻ螟石夊ｭ夊・・帝寞・ｫ鬨ｾ螟奇ｽｭ莨懈肩邵ｺ蜷ｶ・紀D繝ｻ繝ｻP/BM闖ｴ骰具ｽｳ・ｻ繝ｻ繝ｻ 郢晢ｽｻSTATUS繝ｻ螢ｼ螂ｳ雎包ｽｨ郢晢ｽｻ鬩幢ｽｨ隴夊・繝ｻ霑･・ｶ隲ｷ蜈ｷ・ｼ莠･・ｷ・･驕樔ｹ晢ｽ帝勗・ｨ邵ｺ蜻ｻ・ｼ繝ｻ 郢晢ｽｻSUMMARY繝ｻ螢ｼ螂ｳ雎包ｽｨ陷繝ｻ・ｮ・ｹ郢ｧ蜻茨ｽｮ荵昶・隶鯉ｽｭ陷榊生縺帷ｹｧ・ｿ郢晢ｽｳ郢昴・ 郢晢ｽｻADDRESSCITYTOWN繝ｻ螢ｼ・ｸ繧・私騾包ｽｺ繝ｻ迢嶺ｼｴ陷ｷ髦ｪ竏ｪ邵ｺ・ｧ邵ｺ・ｮ隶鯉ｽｭ陷榊姓・ｸ鄙ｫ繝ｻ闖ｴ荵怜恍郢ｧ・ｭ郢晢ｽｼ 郢晢ｽｻOV01繝ｻ螢ｼ螂ｳ雎包ｽｨ郢ｧ・ｫ郢晢ｽｫ郢昴・螟｢髫包ｽｧ 郢晢ｽｻOV02繝ｻ螢ｼ繝ｻ隴√・・､諛・ｽｴ・｢繝ｻ驛・ｽｪ・ｿ隴滂ｽｻ繝ｻ繝ｻ  隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉 END OF master_spec繝ｻ莠･鬮ｪ闕ｳﾂ邵ｺ・ｮ雎・ｽ｣郢晢ｽｻ陞ｳ謔溘・霑夊肩・ｽ諛茨ｽ･・ｭ陷榊姓・ｻ蠅難ｽｧ蛟･繝ｻ陷閧ｴ・ｧ蛹ｺ繝ｻ繝ｻ荳橸ｽｾ・ｩ陷医・豐ｿ繝ｻ繝ｻ 隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉隨渉   ## CHANGELOG - 2026-01-01: Added CURRENT_SCOPE entrypoints (00_CURRENT_SCOPE_NOTE.md, 01_INDEX.md, master_spec/ui_spec headers).  ### DOC example: Toilet remodel estimate (split into 2 documents)  - Scenario: Customer requests toilet remodel estimate.   - Includes: (1) shower/warm-seat toilet item, (2) wallpaper, (3) floor   - Requirement: create 2 documents (toilet item = 1 copy, wallpaper+floor = 1 copy)   - Addressee (docName): TOKI_KEIKO - How to submit (DOC):   - Create DOC request A (docType=ESTIMATE)     - docName: TOKI_KEIKO     - docDesc: Toilet item estimate (shower/warm-seat model)     - docPrice: (set later)     - docMemo: includes product + install + notes; ask questions if required fields missing   - Create DOC request B (docType=ESTIMATE)     - docName: TOKI_KEIKO     - docDesc: Wallpaper and floor estimate     - docPrice: (set later)     - docMemo: scope=wallpaper+floor; ask questions if required fields missing
```
<!-- END SOURCE:master_spec -->


---

## ui_spec（UI/運用の入口）

**path:** `ui_spec.md`

<!-- BEGIN SOURCE:ui_spec.md -->
```text
<!--
UI spec is derived from master_spec (CURRENT_SCOPE: Yorisoidou BUSINESS).
NOTE: navigation/positioning only; does NOT change meaning.
RULE: 1 theme = 1 PR; canonical is main after merge.
-->

UI_spec_<業務>.md

業務 UI ― UI 適用仕様（エンドユーザー向け）

※ <業務> は後から具体名（例：水道修理／申込受付 等）に置換する前提のテンプレート確定版です。

1. 対象仕様の概要

本 UI_spec_<業務> は、
エンドユーザーが業務を依頼・入力・確認するための業務 UIに対して、
UI_PROTOCOL に定義された UI 統治・意味仕様を、
特定業務の文脈に適用した結果を記述するものである。

本書は以下を満たす。

本書は UI_PROTOCOL に従属する

本書は 業務 UI 専用の派生文書である

本書は MEP 操作 UI（UI_spec_MEP）とは責務を分離する

本書は UI の原則・状態定義を再定義せず、参照に留める

2. 業務 UI の役割

業務 UI の役割は以下に限定される。

ユーザーに 必要な入力を迷わせずに行わせる

入力途中・未完了状態を 不安なく継続可能にする

処理状態（送信中／確認中／完了）を 誤認させない

業務判断・仕様解釈を ユーザーに要求しない

業務 UI は、
仕様を作らず、業務を進めるための入口である。

3. 画面構成（業務 UI）
3.1 画面種別

入力画面（主画面）

業務に必要な情報を入力する画面

1画面または段階分割（ステップ）形式を許容する

確認画面

入力内容を送信前に確認する画面

編集に戻れる導線を持つ

完了画面

受付・送信が完了したことを示す画面

次にユーザーが取るべき行動を示す

4. 入力項目の意味配置
4.1 入力項目の原則

ユーザーが 意味を理解できない専門語を使わない

入力理由が暗黙に理解できる順で並べる

「必須／任意」は UI_PROTOCOL の原則に従って表示する

4.2 入力補助

例文・プレースホルダーは
正解例ではなく記述の方向性を示す

未入力によるエラーは
責めない文言で示す

5. 操作順序（業務 UI の標準フロー）

入力画面を表示

業務情報を入力

確認画面で内容を確認

送信処理を実行

完了画面を表示

※ 操作順序は強制ではないが、
本順序を基準とする。

6. 状態と表示の関係
6.1 処理中表示

送信・確認処理中は、
処理中であることを明示する

二重送信を誘発する操作は表示しない

6.2 完了表示

業務が「受理された」ことのみを示す

内部処理や判断結果を断定的に示さない

7. 業務 UI における表示文言
7.1 入力開始時

必要な情報を入力してください。
途中で保存・中断することもできます。

7.2 入力中

入力内容はまだ送信されていません。
必要に応じて修正してください。

7.3 処理中

送信処理を行っています。
完了するまでお待ちください。

7.4 入力不備時

入力内容に不足があります。
該当箇所をご確認ください。

7.5 完了時

送信が完了しました。
受付内容を確認のうえ、後ほどご連絡します。

8. MEP との責務境界

業務 UI は 業務入力の受付までを担当する

業務仕様化・判断・生成は MEP 側の責務とする

業務 UI は master_spec を直接編集しない

9. 本書の更新ルール

本書は 業務 UI の仕様変更時にのみ更新する

MEP 内部仕様の変更により更新されることはない

UI_PROTOCOL の変更を伴う修正は行わない

UI 実装は、本書との差分として管理される

以上で、UI_spec_<業務>.md（業務 UI 用テンプレート）の生成を完了します。
```
<!-- END SOURCE:ui_spec.md -->


---

## code entry（コード入口）

**path:** `code/README.md`

<!-- BEGIN SOURCE:code/README.md -->
```text
# Yorisoidou Business Code Entry

This directory is the canonical entry point for business-side code/assets for よりそい堂.
- This file is intentionally minimal.
- Update business packet via workflow_dispatch: Business Packet Update (Dispatch)
```
<!-- END SOURCE:code/README.md -->

---

## PACKET_DIGEST
`sha256:0f4bcb0fc3ba0046219c893b9b3c1a28a47cf62e314e70b130b3c856112bb992`
```


---

### FILE: platform/MEP/03_BUSINESS/よりそい堂/INDEX.md
- sha256: a825fe00e1050b2adf7c5ac07d850886585f2f0fe4ec4e5e7c431f18e71a5456
- bytes: 1312

```text
# よりそい堂 BUSINESS INDEX（入口）

## 0. 唯一の正（固定）
- 仕様本文（唯一の正・実体）：platform/MEP/03_BUSINESS/よりそい堂/master_spec（拡張子なし）
- master_spec.md は案内専用（本文は置かない）
- ui_spec.md は導線/表示のみ（意味変更しない）
- business_spec.md は業務フロー/例外/運用の最小定義（Phase-1）

## 1. 読む順番（固定）
1) master_spec.md（案内）
2) master_spec（唯一の正）
3) business_spec.md（業務フロー/例外）
4) ui_spec.md（UI適用：導線/表示）


## Phase-2 Quick Links（業務統合の要点）

- business_spec.md（Phase-2）:
  - Integration Contract（統合契約）: ./business_spec.md#integration-contractphase-2todoistclickupledger-統合契約
  - Recovery Queue（回収キュー）: ./business_spec.md#recovery-queuephase-2
  - IdempotencyKey（イベント別）: ./business_spec.md#idempotencykeyイベント別固定
  - Runtime Audit Checklist（expected/unexpected）: ./business_spec.md#runtime-audit-checklistexpectedunexpected固定参照用

## 2. 編集ルール（固定）
- 変更は 1テーマ = 1PR
- 巨大な全文置換・整形だけのコミットは禁止（差分最小）
- 仕様本文を変える場合は必ず master_spec を編集
```


---

### FILE: platform/MEP/03_BUSINESS/よりそい堂/business_master.md
- sha256: 25c62dfad22f64bd6aec70f0d3be9c06c8b6d014829bdab987e1554d953f9097
- bytes: 11776

```text
<!--
PHASE-1 (ADD ONLY): This file is a new container. Do NOT change canonical meaning yet.
CANONICAL (current): platform/MEP/03_BUSINESS/よりそい堂/master_spec
ROLE: BUSINESS_MASTER (data dictionary / IDs / fields / constraints)
-->

# BUSINESS_MASTER（業務マスタ）

## 0. 目的
- 業務で使う「項目・ID・辞書・制約」を一箇所に集約する（ルール本文は BUSINESS_SPEC へ）

## 1. ID体系（仮）
- CU_ID:
- ORDER_ID:
- DOC_ID:
- ITEM_ID:
- PART_ID:

## 2. フィールド辞書（最小テンプレ）
| domain | entity | field | type | required | constraints | description |
|---|---|---|---|---|---|---|
| customer | customer | name | string | yes |  | 顧客名 |
| customer | customer | phone | string | no |  | 電話 |
| address | address | line1 | string | no |  | 住所 |
| doc | estimate | docName | string | yes |  | 文書宛名 |
| doc | estimate | docDesc | string | yes |  | 概要 |
| doc | estimate | docPrice | number | no | >=0 | 金額 |
| doc | estimate | docMemo | string | no |  | メモ |

## 3. 列挙（仮）
- docType: ESTIMATE / INVOICE / RECEIPT

## 4. 見積（ESTIMATE）追加フィールド

本セクションは BUSINESS_SPEC の「見積（ESTIMATE）」を実務で回すための追加辞書である。

### 4.1 追加フィールド（辞書）
| domain | entity | field | type | required | constraints | description |
|---|---|---|---|---|---|---|
| contact | customer | phone | string | no |  | 連絡先（電話） |
| address | site | addressLine1 | string | no |  | 現場住所（1行） |
| schedule | site | preferredDate | string | no | YYYY-MM-DD or free text | 希望日時（任意） |
| estimate | estimate | priceStatus | enum | no | TBD/FINAL | 金額の確定状態 |
| estimate | estimate | splitPolicy | enum | no | AUTO/MANUAL | 分割判断の方針 |
| estimate | estimate | scopeCategory | enum | no | EQUIPMENT/INTERIOR/OTHER | 見積カテゴリ（分割判断に利用） |

### 4.2 列挙（enum）
- priceStatus: TBD（未確定） / FINAL（確定）
- splitPolicy: AUTO（規約に従い自動分割） / MANUAL（手動指定）
- scopeCategory:
  - EQUIPMENT（製品＋取付＝設備）
  - INTERIOR（壁紙/床など＝内装）
  - OTHER（その他）

### 4.3 分割判断で使う最小ルール（辞書側の補足）
- scopeCategory=EQUIPMENT と INTERIOR が混在する場合は原則分割（BUSINESS_SPEC側のルールと対応）

## 5. 請求（INVOICE）追加フィールド

本セクションは BUSINESS_SPEC の「請求（INVOICE）」を実務で回すための追加辞書である。

### 5.1 追加フィールド（辞書）
| domain | entity | field | type | required | constraints | description |
|---|---|---|---|---|---|---|
| invoice | invoice | dueDate | string | no | YYYY-MM-DD or free text | 支払期限 |
| invoice | invoice | paymentMethod | enum | no | BANK/ON_SITE/OTHER | 支払方法 |
| invoice | invoice | bankAccount | string | no |  | 振込先（自由記述） |
| invoice | invoice | invoiceStatus | enum | no | DRAFT/ISSUED/PAID | 請求状態 |

### 5.2 列挙（enum）
- paymentMethod:
  - BANK（振込）
  - ON_SITE（現地/集金）
  - OTHER（その他）
- invoiceStatus:
  - DRAFT（下書き）
  - ISSUED（発行）
  - PAID（入金済み）

### 5.3 最小ルール（辞書側の補足）
- dueDate / paymentMethod / bankAccount は未設定でも INVOICE を作成可（BUSINESS_SPEC側と対応）

## 6. 領収（RECEIPT）追加フィールド

本セクションは BUSINESS_SPEC の「領収（RECEIPT）」を実務で回すための追加辞書である。

### 6.1 追加フィールド（辞書）
| domain | entity | field | type | required | constraints | description |
|---|---|---|---|---|---|---|
| receipt | receipt | receivedDate | string | no | YYYY-MM-DD or free text | 受領日 |
| receipt | receipt | paymentMethod | enum | no | CASH/BANK/OTHER | 支払方法 |
| receipt | receipt | receiptStatus | enum | no | DRAFT/ISSUED | 領収状態 |

### 6.2 列挙（enum）
- paymentMethod:
  - CASH（現金）
  - BANK（振込）
  - OTHER（その他）
- receiptStatus:
  - DRAFT（下書き）
  - ISSUED（発行）

### 6.3 最小ルール（辞書側の補足）
- receivedDate / paymentMethod は未設定でも RECEIPT を作成可（BUSINESS_SPEC側と対応）

<!-- ORDER_FIELDS_PHASE1 -->
## ORDER（受注）— BUSINESS_MASTER（辞書）

本節は「受注（ORDER）」に関する辞書（enum/field）を定義する。
※ master_spec の原則どおり、Order の状態（STATUS/orderStatus）は **業務ロジックが確定**し、人/AI/UIが任意に決定してはならない。

### Fields（追加：Phase-1）
- orderStatus
  - type: string（表示用）
  - source: business-logic（自動確定）
  - rule: UIは表示のみ。手入力で確定/変更してはならない。
- scheduledDate
  - type: date（YYYY-MM-DD, Asia/Tokyo）
  - meaning: 施工予定日（確定/未確定を含む“予定”）
- scheduledTimeSlot
  - type: enum
  - values: AM / PM / EVENING / ANY / TBD
  - rule: TBD は「未確定」を意味する（UIで明示）
- scheduledTimeNote
  - type: string（任意）
  - meaning: 時間帯の補足（例：10時以降希望、管理会社連絡後確定 等）
- assignee
  - type: string（任意）
  - meaning: 担当者（表示名/コードいずれでも可。確定は運用/実装で制約）
- priority
  - type: enum
  - values: NORMAL / HIGH / URGENT
- intakeChannel
  - type: enum
  - values: UF01 / FIX / DOC / OTHER
- orderMemo
  - type: string（任意）
  - meaning: 受注に関する補足（HistoryNotes と役割が衝突しない範囲で使用）

### UI 表示ルール（最小）
- scheduledTimeSlot=TBD の場合、「時間未確定」を明示して表示する。
- orderStatus は UI で“決めない”。表示・検索・監督（管理タスク参照）にのみ使う。

<!-- WORK_FIELDS_PHASE1 -->
## WORK（施工）— BUSINESS_MASTER（辞書）

本節は WORK（施工/完了報告）に関する辞書（field/enum）を定義する。
※ “完了確定” は現場タスク完了が起点（master_spec 9章）。UI/人が任意に完了確定してはならない。

### Fields（Phase-1）
- workDoneAt
  - type: datetime（ISO / Asia/Tokyo）
  - source: field-report（現場完了の結果）
  - required: true（完了確定時）
- workDoneComment
  - type: string（全文）
  - source: field-report（完了コメント）
  - required: true（完了確定時）
  - rule: 未使用部材の抽出対象になり得る（書式は master_spec 9.3）
- unusedPartsList
  - type: list<string>
  - source: derived（workDoneComment から抽出）
  - required: false（抽出失敗は管理警告で扱う）
- photosBefore
  - type: list<url|string>
  - required: false
- photosAfter
  - type: list<url|string>
  - required: false
- photosParts
  - type: list<url|string>
  - required: false
- photosExtra
  - type: list<url|string>
  - required: false
- videoInspection
  - type: url|string
  - required: false
- workSummary
  - type: string
  - required: false
  - rule: 要約の作り込みで業務判断を置換しない（素材の要点メモに留める）

### Derived / Effects（参照）
- 完了同期により、Parts/EX/Expense/在庫戻しが確定される（business_spec / master_spec に従う）
- 不備（写真不足/LOCATION不整合/価格未確定 等）は管理警告対象

<!-- PARTS_FIELDS_PHASE1 -->

<!-- PHASE1_PARTS_FIELDS_BLOCK (derived; do not edit meaning) -->
### Phase-1: Parts_Master（部材台帳）— 最小フィールド（派生）
参照（唯一の正）：master_spec 3.4 / 3.4.1 / 6 / 7 / 9

主キー：PART_ID

主要項目（業務的意味を持つ列）：
- PART_ID / AA番号 / PA/MA番号 / PART_TYPE（BP/BM）
- Order_ID / OD_ID
- 品番 / 数量 / メーカー
- PRICE / STATUS
- CREATED_AT / DELIVERED_AT / USED_DATE
- MEMO / LOCATION

必須（最小）：
- STATUS=STOCK の場合：LOCATION 必須
- PART_TYPE=BP の場合：納品時に PRICE 確定（未確定は警告）
- PART_TYPE=BM の場合：PRICE=0（固定）
<!-- END PHASE1_PARTS_FIELDS_BLOCK -->
## PARTS（部材）— BUSINESS_MASTER（辞書）

本節は PARTS（部材）に関する辞書（field/enum/補助辞書）を定義する。
※ PRICE/STATUS/区分（BP/BM）等の確定は業務ルールに従う。人/AI/UI が任意に決定してはならない。

### Enums（固定）
- partType
  - values: BP / BM
  - meaning:
    - BP=メーカー手配品（納品時に価格確定）
    - BM=既製品/支給品等（PRICE=0、経費対象外）
- partStatus
  - values: STOCK / ORDERED / DELIVERED / USED / STOCK_ORDERED
  - rule: 工程イベント（発注/納品/完了同期）でのみ遷移する

### Fields（台帳カラムの意味：Phase-1）
- PART_ID
  - type: string
  - meaning: 部材の貫通ID（BP/BM体系、再利用不可）
- Order_ID
  - type: string|null
  - meaning: 受注への接続（無い場合は在庫発注として扱う）
- OD_ID
  - type: string|null
  - meaning: 同一受注内の発注行補助ID
- partType
  - type: enum(partType)
  - required: true
- AA
  - type: string|null
  - meaning: 永続番号（AA00は禁止、タスク名反映）
- PA
  - type: string|null
  - meaning: BP枝番（PA00禁止）
- MA
  - type: string|null
  - meaning: BM枝番（MA00禁止）
- maker
  - type: string|null
- modelNumber
  - type: string|null
  - meaning: 品番
- quantity
  - type: number
  - default: 1
- PRICE
  - type: number|null
  - rule:
    - BP: 納品時に確定（未確定は警告）
    - BM: 0（経費対象外）
- partStatus
  - type: enum(partStatus)
  - required: true
- CREATED_AT
  - type: datetime
- DELIVERED_AT
  - type: datetime|null
- USED_DATE
  - type: date|null
- LOCATION
  - type: string|null
  - rule:
    - STATUS=STOCK の場合は必須
    - 未使用部材の STOCK 戻しでも整合必須（欠落は管理警告）
- MEMO
  - type: string|null

### Discontinued Dictionary（廃番→新番：補助辞書）
- discontinuedPartMap
  - entry:
    - discontinued: string（廃番品番/旧番）
    - replacement: string|null（新番/代替候補）
    - keywords: list<string>（曖昧検索補助）
    - photoUrl: url|null（写真/参考）
  - rule:
    - 代替案内は補助。最終採用判断は業務ロジックで確定する

### Guard（業務破壊防止）
- AA00/PA00/MA00 はテスト専用。業務データに混在させない
- PRICE 推測代入禁止（確定入力のみ）
- BP/BM 区分変更は危険修正（申請/FIX）として扱う

<!-- EXPENSE_FIELDS_PHASE1 -->

<!-- PHASE1_EXPENSE_FIELDS_BLOCK (derived; do not edit meaning) -->
### Phase-1: Expense_Master（経費台帳）— 最小フィールド（派生）
参照（唯一の正）：master_spec 3.6 / 3.6.1 / 9

主キー：EXP_ID

主要項目（業務的意味を持つ列）：
- EXP_ID / Order_ID / PART_ID / CU_ID / UP_ID
- PRICE / USED_DATE / CreatedAt

最小ルール（固定）：
- 完了同期で BP の PRICE を根拠に確定（推測代入禁止）
- BM は経費対象外（PRICE=0）
<!-- END PHASE1_EXPENSE_FIELDS_BLOCK -->
## EXPENSE（経費）— BUSINESS_MASTER（辞書）

### Fields（Phase-1）
- EXP_ID
  - type: string
  - format: EXP-YYYYMM-0001
  - rule: 再利用不可、月内連番
- Order_ID
  - type: string
  - required: true
- PART_ID
  - type: string|null
  - required: false
- PRICE
  - type: number
  - required: true
  - rule: 推測代入禁止（確定のみ）
- USED_DATE
  - type: date
  - required: true
- CreatedAt
  - type: datetime
  - required: true
```


---

### FILE: platform/MEP/03_BUSINESS/よりそい堂/business_spec.md
- sha256: 78840c47b77c5d3b1c4212cf156f134d109e77bfbd80ddd19a516fe26baa8501
- bytes: 78011

```text
<!--
PHASE-1 (ADD ONLY): This file is a new container. Do NOT change canonical meaning yet.
CANONICAL (current): platform/MEP/03_BUSINESS/よりそい堂/master_spec
ROLE: BUSINESS_SPEC (workflow / rules / decisions / exceptions)
-->

# BUSINESS_SPEC（業務スペック）

## 0. 目的
- 見積→受注→施工→請求→領収→部材→経費 の業務ルールを定義する
- 項目定義は BUSINESS_MASTER に置く

## 1. 業務フロー（章立て）
1) 見積（ESTIMATE）
2) 受注（ORDER）
3) 施工（WORK）
4) 請求（INVOICE）
5) 領収（RECEIPT）
6) 部材（PARTS）
7) 経費（EXPENSE）

## 2. 見積（ESTIMATE）— 最小仕様（仮）
- 目的：依頼内容から見積書を生成する
- 入力：BUSINESS_MASTER の estimate 項目
- 出力：docType=ESTIMATE / docName / docDesc / docPrice / docMemo
- 例外：必須項目不足は質問で補完する

（※詳細は次のPRで詰める。今回は骨格のみ）

## 3. 請求（INVOICE）

### 3.1 目的
- 確定した見積（ESTIMATE）を元に、請求書（docType=INVOICE）を生成する。

### 3.2 入力（最小）
- 元見積（確定済み）：
  - docName / docDesc / docPrice / docMemo
- 必要なら追加：
  - 支払期限（任意）
  - 振込先/支払方法（任意）

### 3.3 出力（生成物）
- docType = INVOICE
- docName（宛名）
- docDesc（請求内容）
- docPrice（金額：原則必須）
- docMemo（備考：任意、支払条件など）

### 3.4 ルール
- ESTIMATE が priceStatus=FINAL でない場合は原則 INVOICE を作らない（例外：手動で進める場合は docMemo に理由を明記）
- 金額は原則 docPrice を引き継ぐ（税/端数処理などは将来拡張）

### 3.5 不足情報（質問）
- docName/docDesc/docPrice が揃っていない場合は質問して補完する。
- 支払期限や支払方法は未設定でも作成可（docMemo に未確定と記載）。

## 4. 領収（RECEIPT）

### 4.1 目的
- 確定した請求（INVOICE）または入金情報を元に、領収書（docType=RECEIPT）を生成する。

### 4.2 入力（最小）
- 元請求（INVOICE）：
  - docName / docDesc / docPrice / docMemo
- 可能なら追加：
  - 受領日（任意）
  - 支払方法（任意：現金/振込など）

### 4.3 出力（生成物）
- docType = RECEIPT
- docName（宛名）
- docDesc（領収内容）
- docPrice（金額：原則必須）
- docMemo（備考：任意）

### 4.4 ルール
- 原則、INVOICE が invoiceStatus=PAID（入金済み）の場合に作成する
- 例外的に、現金受領などで手動作成する場合は docMemo に理由を明記する

### 4.5 不足情報（質問）
- docName/docDesc/docPrice が揃っていない場合は質問して補完する。
- 受領日や支払方法は未設定でも作成可（docMemo に未確定と記載）。

## 5. 受注（ORDER）

### 5.1 目的
- 見積（ESTIMATE）が確定した後、受注として案件を確定し、次工程（WORK/INVOICE）へ渡す。

### 5.2 入力（最小）
- 元見積（確定済み）：
  - docName / docDesc / docPrice / docMemo
- 可能なら追加：
  - 工事予定日（任意）
  - 担当者（任意）
  - ステータス（任意）

### 5.3 出力（生成物）
- ORDER（受注）レコード（将来：台帳/ID化）
- 最低限の保持項目：
  - customer/docName
  - scope/docDesc
  - amount/docPrice
  - notes/docMemo
  - status（例：CONFIRMED）

### 5.4 ルール
- 元見積が priceStatus=FINAL であることが原則
- 分割見積の場合、受注は「1案件に複数見積紐付け」または「見積ごとに受注」を選べる（将来拡張）
- 受注確定後、WORK と INVOICE を作成可能になる

<!-- WORK_SPEC_PHASE1 -->
## WORK（施工）— BUSINESS_SPEC（Phase-1）
### タスク投影（Todoist/ClickUp）— ライフサイクル表示と完了/復旧（固定）

#### 目的（固定）
- VOID/CANCEL/RESTORE/REOPEN を、現場（Todoist）・管理（ClickUp）のタスク表示に安全に反映し、見落としと誤操作を防ぐ。
- タスク名の既存契約（AA群／納品 分子/分母／末尾 `_ ` 自由文スロット保持）を破壊しない。

#### 表示（タイトル）規約（固定）
- タスク名は「先頭=AA群（または納品 分子/分母）」の規約を維持する（AAを先頭から外さない）。
- 末尾 `_ `（アンダースコア＋半角スペース）の自由文スロットは必ず保持する（更新でも消さない）。
- 表示タグは `_ ` の直前に付与する（AA群/納品表示を壊さない）:
  - VOID:  `[VOID]`
  - CANCEL: `[CANCEL]`
  - 例）`AA01 AA03 [CANCEL] _ `
  - 例）`納品 1/7 [VOID] _ `
- RESTORE（復旧）時は、`[VOID]` / `[CANCEL]` を除去する（元の表示へ戻す）。
- REOPEN（誤完了解除）は状態タグではなく「操作」であり、タイトルへ永続タグは付けない（コメントへ記録する）。

#### タスク状態（完了/復旧）規約（固定）
- VOID/CANCEL:
  - 結果が FREEZE（凍結＝Recovery Queue: BLOCKER/OPEN）になった場合：
    - タスクは自動完了しない（監督回収のためオープン維持）。
    - コメントに `[STATE] VOID/CANCEL + FREEZE` と理由（最小）を記録する。
  - FREEZE でない場合：
    - タスクは完了（Close）してよい（Todoist/ClickUp の完了操作）。
    - コメントに `[STATE] VOID/CANCEL` を記録する（監査用）。
- RESTORE:
  - 可能なら「完了済みタスクを復旧（Reopen/Uncomplete）」する。
  - 復旧できない実装の場合は「新規タスクを作成し、旧タスクへリンク（参照ID/URL）」する（増殖は許容、監査リンク必須）。
  - タイトルから `[VOID]` / `[CANCEL]` を除去する。
- REOPEN（誤完了解除）:
  - タスクは復旧（Reopen/Uncomplete）してよい（誤完了の訂正）。
  - コメントに `[OP] REOPEN` と対象（Order_ID/#n）を記録する。
  - VOID/CANCEL の状態を解除する操作ではない（混同禁止）。

#### コメント記録（固定）
- 状態/操作の記録はタスクコメントに最小で残す（監査用）:
  - `[STATE] VOID` / `[STATE] CANCEL` / `[STATE] RESTORE`
  - FREEZE の場合：`[STATE] VOID FREEZE` 等
  - 操作ログ：`[OP] REOPEN`
- [INFO] ブロックの上書き規約は維持する（`--- USER ---` 以下は触らない）。


### 目的
- 施工（WORK）を「受注（Order_ID）に紐づく現場作業の実行・完了報告」として定義し、
  完了同期（台帳確定・経費確定・在庫戻し）へ繋ぐ。

### 入力入口（不変）
- 現場の完了報告は「現場タスクの完了（完了コメント全文）」が唯一の正（master_spec 9章）。
- 施工の途中経過は、運用上のメモとして残してよいが、台帳確定のトリガーではない。

### 最小データ（業務要件）
- `workDoneAt`（完了日時）
- `workDoneComment`（完了コメント全文：未使用部材記載を含み得る）
- `photosBefore` / `photosAfter` / `photosParts` / `photosExtra`（任意：不足は管理警告）
- `videoInspection`（任意）
- `workSummary`（任意：要約の作り込みで業務判断を置換しない）

### 完了コメント規約（抽出）
- 未使用部材は、以下の書式で列挙できること（master_spec 9.3 準拠）：
  - 例）未使用：BP-YYYYMM-AAxx-PAyy, BM-YYYYMM-AAxx-MAyy
- 抽出結果は在庫戻し（STATUS=STOCK）へ利用される（LOCATION 整合が必須）

### 完了時に起きる業務（概要）
- Order の完了日時・状態更新・最終同期日時の更新。
- 部材（PARTS）の確定：
  - DELIVERED 部材の USED 化（使用確定）。
  - 未使用部材の STOCK 戻し（LOCATION 整合必須）。
- 経費（EXPENSE）の確定：
  - USED（使用確定）になった BP の PRICE を根拠に、確定経費として記録する。
- 不備（価格未入力 / 写真不足 / LOCATION 不整合 等）は管理警告対象。

### 禁止事項
- 人 / AI / UI が Order の STATUS / orderStatus を任意に確定・変更してはならない。
- 完了同期の代替として、別経路で台帳を確定させてはならない。

<!-- PARTS_SPEC_PHASE1 -->

<!-- PHASE1_PARTS_SPEC_BLOCK (derived; do not edit meaning) -->
### Phase-1: PARTS（部材）— 業務最小定義（派生）
参照（唯一の正）：
- master_spec: 3.4 Parts_Master / 3.4.1 Parts STATUS / 6 部材体系 / 7 UF06/UF07 / 9 完了同期。

最小目的：
- 部材（BP/BM）の発注→納品→使用→在庫の追跡を、Order_ID と PART_ID で破綻なく再現する。

業務状態（固定）：
- STOCK / ORDERED / DELIVERED / USED / STOCK_ORDERED。

最小トリガー（固定）：
- UF06（発注確定）: ORDERED または STOCK_ORDERED（Order_ID有無で判定）。
- UF06（納品確定）: DELIVERED（DELIVERED_AT 記録）。
- UF07（価格入力）: PRICE 確定（状態は原則維持）。
- 完了同期（現場完了起点）: DELIVERED の対象を USED へ（使用確定）。
- 未使用部材コメント抽出: STOCK 戻し（LOCATION 整合必須）。

不変条件（固定）：
- BP は納品時に PRICE を確定（未確定は警告対象）。
- BM は PRICE=0（経費対象外）。
- LOCATION は STATUS=STOCK の部材で必須。
<!-- END PHASE1_PARTS_SPEC_BLOCK -->
## PARTS（部材）— BUSINESS_SPEC（Phase-1）

### 目的
- 部材（PARTS）を「発注→納品→使用→在庫」の工程で追跡可能な業務として定義する。
- 受注（Order_ID）と部材（PART_ID/OD_ID/AA/PA/MA）を正しく接続し、完了同期で経費確定へ繋ぐ。

### 入力入口（不変）
- UF06（発注/納品）が工程の主入口（master_spec 7章）。
- UF07（価格入力）は BP の価格未確定を補完する入口（master_spec 7.3）。
- 価格/区分/状態の“確定”は業務ルールに従い、人/AI/UI が任意に決めない。

### 部材区分（BP/BM）
- BP（メーカー手配品）。
  - 納品時に PRICE を確定する（未確定は警告）。
- BM（既製品/支給品等）。
  - PRICE=0（経費対象外）。
- BP/BM の区分変更は危険修正（申請/FIX）に分類し、直接確定しない。

### 主要IDと接続（要点）
- PART_ID：部材の貫通ID（BP/BM体系）。
- AA：部材群の永続番号（タスク名へ反映）。
- PA/MA：枝番（BP=PA, BM=MA）。
- OD_ID：同一受注内の発注行補助ID。
- 接続の中心は Order_ID（受注）。
  - Order_ID の無い発注は STOCK_ORDERED として扱う（在庫発注）。

### STATUS（部材状態：固定）
- STOCK / ORDERED / DELIVERED / USED / STOCK_ORDERED。
- 変更は工程イベントにより行う（発注/納品/完了同期）。
- 人/AI/UI が任意に書き換えない。

### LOCATION（在庫ロケーション）
- STATUS=STOCK の部材は LOCATION を必須とする（欠落は管理警告）。
- 未使用部材の STOCK 戻しでも LOCATION 整合が必須。

### 発注（UF06: ORDER）業務（概要）
- 採用行のみを発注として確定する。
- 確定結果：。
  - PART_ID/OD_ID 発行。
  - STATUS=ORDERED（Order_ID 無しの場合は STOCK_ORDERED）。
  - BP は PRICE 未定、BM は PRICE=0。

### 納品（UF06: DELIVER）業務（概要）
- 確定結果：。
  - STATUS=DELIVERED。
  - DELIVERED_AT 記録。
  - BP は PRICE 入力必須（納品時確定）。
  - LOCATION 記録（在庫・管理に必要）。
  - AA群を抽出し、現場タスク名へ反映する。

### 価格入力（UF07）業務（概要）
- BP の PRICE 未入力を補完し、業務として価格を確定する。
- 部材STATUSは原則変更しない（価格確定のみ）。
- 価格未確定は管理警告の対象。

### 完了同期との関係（要点）
- 現場完了により、DELIVERED 部材が USED 化され、EX/Expense が確定される。
- 未使用部材は STOCK 戻し（LOCATION 整合必須）。

### 禁止事項
- ID の再利用/改変、AA 再発番。
- PRICE の推測代入。
- STATUS の任意変更。
- LOCATION 欠落の放置（警告として扱い、管理で回収）。

<!-- EXPENSE_SPEC_PHASE1 -->

<!-- PHASE1_EXPENSE_SPEC_BLOCK (derived; do not edit meaning) -->
### Phase-1: EXPENSE（経費）— 業務最小定義（派生）
参照（唯一の正）：
- master_spec: 3.6 Expense_Master / 3.6.1 Expense確定 / 9 完了同期 / 8.4.1 警告。

最小目的：
- USED（使用確定）になった BP の PRICE を根拠に、確定経費として一意に記録する。

確定トリガー（固定）：
- 完了同期（現場完了起点）でのみ確定（作成/追記）。

対象範囲（固定）：
- BP（メーカー手配品）: PRICE確定が前提（未確定は警告）。
- BM: PRICE=0（経費対象外／経費に入れない）。

不変条件（固定）：
- 推測代入は禁止（PRICEは確定値のみ）。
- 既存Expenseの削除は禁止（履歴保全）。
<!-- END PHASE1_EXPENSE_SPEC_BLOCK -->
## EXPENSE（経費）— BUSINESS_SPEC（Phase-1）

### 目的
- 経費（EXPENSE）を「確定した支出記録」として保持し、受注（Order_ID）へ接続する。
- 経費の“確定”は推測ではなく、確定入力（または完了同期で確定されたUSED部材）に限定する。

### 入力入口（不変）
- 完了同期により USED 部材の PRICE が経費として確定される（master_spec 9章 / Expense_Master）。
- 手動の経費追加は、確定情報（領収/金額/日付/対象）を入力できる入口（運用/将来UI）。
- 推測代入は禁止。

### 最小データ（業務要件）
- EXP_ID（経費ID：月内連番、再利用不可）。
- Order_ID（接続キー）。
- PART_ID（関連部材がある場合）。
- PRICE（確定金額）。
- USED_DATE（使用/支出日）。
- CreatedAt（記録日時）。

### 禁止事項
- PRICE 推測代入。
- EXP_ID 再発番/再利用。
- Order_ID 無しの経費混在（例外運用をする場合は別途定義して停止）。
## WARNINGS & BLOCKERS（Phase-1）

### 目的
- Phase-1 の運用で「完了同期を止めるべき不備（BLOCKER）」と、「同期は進めて管理で回収する不備（WARNING）」を固定する。
- 判定は人/AI/UI の恣意で変えず、本章の分類に従う。

### BLOCKER（完了同期を停止）
- LOCATION 不整合（在庫戻し対象の部材で LOCATION が欠落/不一致）。
- BP の PRICE 未確定（経費確定の根拠となる PRICE を確定できない）。

### WARNING（同期は進めるが管理回収）
- 写真不足（photosBefore / photosAfter / photosParts / photosExtra の不足）。
- 価格未入力（ただし「経費確定が必要な BP の PRICE 未確定」は BLOCKER）。
- 完了コメント抽出不備（未使用部材の抽出ができない/形式不備）。※在庫戻し対象がある場合は BLOCKER 扱いに昇格し得る。

### 参照（出典）
- WORK: 「不備（価格未入力 / 写真不足 / LOCATION 不整合 等）は管理警告対象」
- PARTS: PRICE/LOCATION の不変条件、未使用 STOCK 戻しの LOCATION 整合
- EXPENSE: PRICE は確定値のみ（推測代入禁止）
## EXCEPTIONS（Phase-1）

### 目的
- Phase-1 で「許可する例外」と「禁止する例外」を固定し、運用判断のブレを防ぐ。

### 許可（Phase-1 で扱う）
- Order_ID 無しの発注は「在庫発注」として許可する（STATUS=STOCK_ORDERED）。
  - 参照: PARTS（部材）章「Order_ID の無い発注は STOCK_ORDERED」。
  - 注: 後から Order に紐づけ直す運用を行う場合は、危険修正（申請/FIX）として扱い、別途手順を定義する。

### 禁止（Phase-1 では扱わない）
- Order_ID 無しの経費は禁止する（台帳混在させない）。
  - 必要な場合は Phase-2 で例外運用として別途定義してから解禁する。

### 補足（規約の再確認）
- BM は PRICE=0（経費対象外）であり、経費として記録しない。
## DoD（Phase-1）

### 目的
- Phase-1 が「運用として成立し、次フェーズへ進める」状態を、確認可能な条件で固定する。

### 完了条件（確認可能）
- WORK（施工）の完了同期を起点として、次が仕様どおりに確定されること：
  - Order（受注）：完了日時・状態・最終同期日時が更新される。
  - PARTS（部材）：DELIVERED → USED 化、および未使用部材の STOCK 戻し（LOCATION 整合必須）が行われる。
  - EXPENSE（経費）：USED（使用確定）になった BP の PRICE を根拠に確定経費が記録される。
- WARNINGS & BLOCKERS（Phase-1）の分類が適用されること：
  - BLOCKER は完了同期を停止する。
  - WARNING は同期は進め、管理で回収する。
- EXCEPTIONS（Phase-1）の例外規約が適用されること：
  - Order_ID 無しの発注（在庫発注）は STATUS=STOCK_ORDERED として扱える。
  - Order_ID 無しの経費は Phase-1 では禁止（混在させない）。
- 不変条件が破られないこと（破綻防止）：
  - PRICE の推測代入は禁止（確定値のみ）。
  - ID（EXP_ID 等）の再発番／再利用は禁止。
## UI/Form Capture Spec（Phase-2）

### 目的
- Phase-1 で固定した WORK / PARTS / EXPENSE / WARNINGS & BLOCKERS / EXCEPTIONS を、入力（フォーム/画面）として「何を・いつ・必須で」取得するかを固定する。
- 本章は入力仕様のみを扱い、業務ロジックの意味は Phase-1 各章に委譲する。

### 入力タイミング（固定）
- UF06（発注/納品）: PARTS の工程イベント入力。
- UF07（価格入力）: BP の PRICE 確定入力（原則 STATUS は変えない）。
- 現場完了（完了コメント）: WORK の完了同期起点（台帳確定・在庫戻し・経費確定）。

### 画面/フォーム別の最小入力項目

#### 1) 現場完了（WORK 完了報告）
- 必須:
  - `workDoneAt`（datetime）
  - `workDoneComment`（text; 未使用部材抽出対象）
- 任意（不足は WARNING）:
  - `photosBefore`（images[]）
  - `photosAfter`（images[]）
  - `photosParts`（images[]）
  - `photosExtra`（images[]）
  - `videoInspection`（video）
  - `workSummary`（text; 判断を置換しない）
- 入力後の検証（Phase-1 参照）:
  - 未使用部材の抽出に失敗 / 形式不備 → WARNING（在庫戻し対象がある場合は BLOCKER に昇格し得る）
  - LOCATION 不整合（在庫戻し対象） → BLOCKER
  - BP の PRICE 未確定（経費確定不可） → BLOCKER

#### 2) UF06（発注確定）
- 必須:
  - 対象行の採用（発注確定の意思）
- 自動/派生（入力しないが確認対象）:
  - PART_ID / OD_ID の発行
  - STATUS=ORDERED（Order_ID 無しの場合は STOCK_ORDERED）
  - BP は PRICE 未定、BM は PRICE=0
- 例外（Phase-1 EXCEPTIONS 参照）:
  - Order_ID 無し発注（在庫発注）: 許可（STOCK_ORDERED）

#### 3) UF06（納品確定）
- 必須:
  - 納品確定（DELIVER）
  - `DELIVERED_AT`（datetime）
  - （BPの場合）PRICE の確定入力（UF07 を使う運用でも可。ただし最終的に未確定は BLOCKER）
- 任意/運用:
  - LOCATION（在庫・管理に必要。STATUS=STOCK の場合は必須）
- 入力後の検証（Phase-1 参照）:
  - BP の PRICE 未確定 → BLOCKER（経費確定不可）
  - LOCATION 欠落（STOCK対象） → WARNING（在庫戻し対象では BLOCKER）

#### 4) UF07（価格入力）
- 対象:
  - BP の PRICE 未入力を補完する
- 必須:
  - `PRICE`（number; 推測代入禁止）
- 制約:
  - 原則 STATUS は変更しない（価格確定のみ）

#### 5) 経費の手動追加（将来UI/運用）
- Phase-1 方針:
  - Order_ID 無し経費は禁止（混在させない）
- 必須（許可する場合の最小セット）:
  - Order_ID / 金額（PRICE）/ 日付（USED_DATE）/ 対象（摘要）
## UI/Form Split & Validation（Phase-2）

### 目的
- UI/Form Capture Spec（Phase-2）で定義した入力を、実運用のフォーム/画面単位に分割して固定する。
- 送信時のバリデーション結果を WARNINGS & BLOCKERS（Phase-1）にマッピングし、処理の分岐（同期停止/管理回収）を固定する。

### 基本方針（固定）
- 送信は原則受け付ける（現場で入力を止めない）。
- ただし、BLOCKER に該当する場合は「完了同期を停止」し、管理回収（要対応）に回す。
- WARNING は同期は進め、管理回収（要確認）に回す。

### フォーム/画面の分割（固定）
1) 現場完了フォーム（WORK 完了報告）
2) UF06-ORDER（発注確定）
3) UF06-DELIVER（納品確定）
4) UF07-PRICE（価格入力）
5) EXPENSE-ADD（経費の手動追加：将来UI/運用）

### バリデーション（フォーム別）

#### 1) 現場完了フォーム（WORK 完了報告）
- 必須未入力 → BLOCKER
  - `workDoneAt` 未入力
  - `workDoneComment` 未入力
- BLOCKER（同期停止）
  - LOCATION 不整合（在庫戻し対象の部材で LOCATION が欠落/不一致）
  - BP の PRICE 未確定（経費確定が必要な BP の PRICE を確定できない）
- WARNING（同期継続＋管理回収）
  - 写真不足（photosBefore / photosAfter / photosParts / photosExtra の不足）
  - 完了コメント抽出不備（未使用部材抽出ができない/形式不備）
    - 注：在庫戻し対象がある場合は BLOCKER に昇格し得る

#### 2) UF06-ORDER（発注確定）
- BLOCKER（送信拒否ではなく、確定処理を停止）
  - 対象行の採用が無い（発注確定意思が不明）
- EXCEPTIONS（Phase-1 参照）
  - Order_ID 無し発注は許可（在庫発注: STATUS=STOCK_ORDERED）

#### 3) UF06-DELIVER（納品確定）
- 必須未入力 → BLOCKER
  - `DELIVERED_AT` 未入力
- BLOCKER
  - （BP）PRICE が最終的に未確定（経費確定不可）
- WARNING
  - LOCATION 欠落（STATUS=STOCK 対象で LOCATION が未入力）
    - 注：在庫戻し対象（未使用戻し）が発生する場合は BLOCKER に昇格し得る

#### 4) UF07-PRICE（価格入力）
- 必須未入力 → BLOCKER
  - `PRICE` 未入力
- BLOCKER
  - PRICE が推測代入（根拠無し）※運用上禁止
- 制約
  - STATUS は原則変更しない（価格確定のみ）

#### 5) EXPENSE-ADD（経費の手動追加：将来UI/運用）
- Phase-1 方針（固定）
  - Order_ID 無し経費は禁止（混在させない）→ BLOCKER
- 必須未入力 → BLOCKER
  - Order_ID / PRICE / USED_DATE / 対象（摘要）
## Form → Ledger Mapping（Phase-2）

### 目的
- フォーム入力を「どの台帳（Ledger）へ、どの最小フィールドとして記録するか」を固定し、実装を一本道にする。
- 詳細スキーマ（列構造/型/正規化）は master_spec を唯一の正として参照し、本章は “最低限の対応付け” に限定する。

### 台帳（Ledger）と最小フィールド（固定）
- Order（受注）:
  - Order_ID
  - workDoneAt / workDoneComment（完了同期の根拠）
  - orderStatus / STATUS（完了同期により更新）
  - lastSyncedAt（最終同期日時）
- Parts（部材）:
  - PART_ID / OD_ID / Order_ID（接続）
  - STATUS（ORDERED / DELIVERED / USED / STOCK / STOCK_ORDERED）
  - DELIVERED_AT
  - PRICE（BP のみ確定値）
  - LOCATION（STATUS=STOCK のとき必須）
- Expense（経費）:
  - EXP_ID
  - Order_ID
  - PART_ID（関連がある場合）
  - PRICE（確定値のみ）
  - USED_DATE
  - CreatedAt
- Warnings / Blockers（管理回収）:（= Recovery Queue）
  - Order_ID
  - category（BLOCKER / WARNING）
  - reason（例：PRICE未確定 / LOCATION不整合 / 写真不足 / 抽出不備 / 必須未入力）
  - detectedAt（検出日時）
  - detectedBy（検出契機：WORK完了 / UF06 / UF07 / 手動）
  - details（原文/補足：例 完了コメント、写真不足の内訳 等）
  - status（OPEN / RESOLVED）
  - resolvedAt（解消日時）
  - resolvedBy（解消者）
  - resolutionNote（解消メモ）
  - Order_ID 無し経費 → BLOCKER（Phase-1 方針）
## ID Issuance & UI Responsibility（Phase-2）

### 目的
- ID（採番）を「いつ・誰（どの処理）が・どの入力を根拠に」発行するかを固定し、実装・運用のブレを防ぐ。
- 再発番/再利用は禁止（Phase-1 不変条件）を前提とする。

### 対象ID（本章で固定する範囲）
- PART_ID（部材ID）
- OD_ID（同一受注内の発注行補助ID）
- AA / PA / MA（部材群/枝番：タスク名へ反映）
- EXP_ID（経費ID：月内連番）

### 発行タイミングと責務（固定）

#### PART_ID / OD_ID
- 発行タイミング: UF06-ORDER（発注確定）で「採用行確定」した瞬間に発行する。
- 発行責務: UF06-ORDER の確定処理（人/AI/UI の恣意ではなく処理が発行する）。
- 例外: Order_ID 無し発注（在庫発注）は許可し、STATUS=STOCK_ORDERED として発行する（Phase-1 EXCEPTIONS 参照）。

#### AA / PA / MA（タスク名・枝番体系）
- 発行タイミング:
  - AA: 部材群の永続番号として、PART_ID 発行時に確定する（タスク名へ反映）。
  - PA/MA: 枝番として、BP=PA / BM=MA を PART_ID 発行時に確定する。
- 発行責務: PART_ID 発行処理（UF06-ORDER）で確定し、後からの任意変更は行わない。
- 変更扱い: BP/BM 区分変更や枝番変更は危険修正（申請/FIX）として別途扱う（Phase-1: PARTS 参照）。

#### EXP_ID
- 発行タイミング:
  - 完了同期（現場完了起点）で EXPENSE を確定する瞬間に発行する。
  - 手動経費追加（将来UI/運用）で経費を確定する瞬間に発行する。
- 発行責務: EXPENSE の確定処理（台帳記録処理）が発行する。
- 禁止: 再発番/再利用は禁止（履歴保全）。

### UIの責務（固定）
- UI は ID を入力させない（表示・参照は許可）。
- UI は「確定の意思」を入力させる（採用行確定、納品確定、価格確定、完了報告）。
- ID 発行は確定処理が行い、UI は発行結果を表示する。
## Integration Contract（Phase-2｜Todoist×ClickUp×Ledger 統合契約）

### 目的
- Todoist（現場）と ClickUp（管理）を併用しつつ、台帳（Ledger）を唯一の正として破綻なく同期するための契約を固定する。
- 「双方向」「スイッチ」「更新（再同期）」「競合」「冪等」を曖昧にせず、汚染・バグの再発を防ぐ。
- 実装手段（GAS/関数名/Webhook方式等）は定義しない（運用契約のみ）。業務の意味は master_spec を唯一の正として参照する。

### 正の階層（Authority｜固定）
- Ledger（台帳：Sheets 等）：業務データの唯一の正（Order/Parts/Expense/Request/Recovery Queue 等）。
- Orchestrator（業務ロジック）：正式値（住所/ID/STATUS/PRICE/健康スコア/警告）を確定する唯一の決定者（実装手段は問わない）。
- Field UI（現場 UI）：完了報告の起点 UI。現場の入力は「素材」であり、確定は Orchestrator が行う。
- Management UI（管理 UI）：監督・警告受信・優先度管理。**入力禁止（確定値を作らない）**。
- AI補助：素材抽出・監査・警告候補のみ（判断禁止）。

### 双方向同期の定義（固定）
本契約における「双方向」とは、**相互に確定値を書き換え合うことではない**。
- Ledger → UI（投影）：Ledger の確定情報を、現場/管理 UI へ参照情報として反映する。
- UI → Ledger（素材入力）：UI で許可された入力（例：現場完了コメント）を、確定処理の素材として受け取る。
禁止：
- 管理 UI（ClickUp）からの入力を Ledger の確定値として取り込むこと。
- UI が STATUS / PRICE / ID 等を確定すること。

### 同期対象（最小セット｜固定）
1) Ledger → Field UI（現場）
- Order_ID
- 顧客名（表示用）
- addressCityTown（正式値）
- 媒体（表示用）
- AA群（必要時：タスク名反映）

2) Ledger → Management UI（管理）
- Order_ID / 顧客名 / addressCityTown
- STATUS（参照のみ）
- alertLabels（参照のみ）
- 健康スコア（参照のみ）
- 未処理（OPEN）有無（Request / Recovery Queue）
- BLOCKER/WARNING の要点（理由・対象ID）

3) UI → Ledger（素材として受けるもの）
- 現場完了：完了日時、完了コメント全文（未使用部材抽出素材）
- 追加報告：写真・説明等（確定は Orchestrator）
- 価格入力：確定値のみ（推測代入禁止）

### スイッチ（切替）の意味（固定）
切替は「併用を成立させる統治スイッチ」であり、入力経路や同期範囲を安全に制御する。
- IntegrationMode（統合モード）：
  - DUAL（標準）：現場 UI + 管理 UI に投影する。
  - FIELD_ONLY：現場 UI のみ投影する。
  - MGMT_ONLY：管理 UI のみ投影する（例外運用）。
  - LEDGER_ONLY：外部連携を停止し台帳のみで運用する。
- FieldSource（現場完了の唯一入口）：**TODOIST** を唯一の正として固定する（併用は競合が常態化するため原則禁止）。
- maintenanceMode：master_spec の定義に従い、true の間は更新系を停止し閲覧・検査・ログを優先する（連携も停止側へ寄せる）。

### 冪等（Idempotency）と更新（再同期）の契約（固定）
- 次のイベントは冪等でなければならない：
  - UF01 / UF06（発注・納品）/ UF07 / UF08 / 完了同期 / 更新（再同期）
- 同一イベントの重複到達（再送・二重起動）は、結果を増殖させない（二重行・二重通知禁止）。
- 更新（再同期）は「Ledger の確定状態を UI に再投影して整合を回復する」ことを主目的とする。
  - UI の値で Ledger を上書きする用途に使用しない。

### 競合・破綻の扱い（固定）
競合例：
- 同一 Order_ID に対して短時間に複数の完了イベントが到達する。
- 入力素材（完了コメント等）が一致しない。
- Ledger の確定状態と UI 投影が不整合になる。
処理：
- 自動で辻褄合わせをしない。
- **Recovery Queue（OPEN）へ登録**し、監督回収に寄せる。
- 勝手に RESOLVED にしない（解消は根拠を伴う）。

### 観測（ログ）最小要件（固定）
- 重要イベント（UF/完了/再同期/競合/回収）は logs/system（または同等の台帳ログ）に必ず記録する。
- 記録は監督の根拠であり、UI/人が確定値を作るために使用しない（判断権の原則）。

### 再同期（Reconcile / Resync）責務（固定）

- 定義（固定）:
  - 再同期とは「Ledger（台帳）の確定状態を UI に再投影して整合を回復する」ことである。
  - UI の値で Ledger を上書きする用途に使用しない（UI→Ledger は素材入力のみ）。
- トリガ（固定）:
  - 手動（管理の指示）
  - BLOCKER 解消後（回収完了）
  - 定期（任意：運用で採用する場合のみ。実装PRで固定）
- 入力（最小セット｜固定）:
  - Order_ID
  - target（Order / Parts / Expense / Recovery Queue）
  - reason（なぜ再同期するか）
  - requestedAt（要求時刻）
- 競合（固定）:
  - 再同期の結果、競合（Ledger と UI の不整合、重複イベント、素材不一致）が検出された場合は自動で辻褄合わせをしない。
  - Recovery Queue（OPEN）へ登録し、監督回収へ寄せる。
- 冪等（固定）:
  - resyncKey = Hash(Order_ID + target + reason + requestedId)
  - 同一 resyncKey の再実行は「結果を増殖させない」（重複通知・重複タスク禁止）。
- 出力（固定）:
  - projectedAt（投影時刻）
  - diffSummary（投影差分の要約）
  - ledgerHead（投影に使った Ledger の基準（例：hash/timestamp））

## Recovery Queue（Phase-2）

### 目的
- WARNINGS & BLOCKERS（Phase-1）で検出された不備を、運用で確実に回収・解消するための「回収キュー」を固定する。
- 実装（GAS/UI/タスク）はこの仕様に従って “登録→通知→解消→記録” を行う。

### 登録対象（固定）

- CANCELLED : 取消（誤検知/重複/不要化により回収対象から外す。記録は残す）
最小ルール（固定）:
- CANCELLED にする場合は resolvedAt/resolvedBy/resolutionNote を記録してよい（根拠の明文化）。
- category: BLOCKER / WARNING
- reason: 例）PRICE未確定 / LOCATION不整合 / 写真不足 / 抽出不備 / 必須未入力
- Order_ID（原則必須）
- PART_ID（関連がある場合）
- detectedAt（検出日時）
- detectedBy（検出契機：WORK完了 / UF06 / UF07 / 手動）
- details（原文/補足：例 完了コメント、写真不足の内訳 等）
- status（OPEN / RESOLVED）
- resolvedAt（解消日時）
- resolvedBy（解消者）
- resolutionNote（解消メモ）

### 発生時の動作（固定）
- BLOCKER:
  - 完了同期を停止（処理を中断し、回収キューへ登録する）。
  - 回収が完了するまで “再同期” しない（または再同期しても同じ BLOCKER で停止する）。
- WARNING:
  - 同期は継続し、回収キューへ登録する（運用で回収）。
  - 次回以降の同期で自動解消はしない（人の解消を原則とする）。
### どこへ記録するか（実装境界｜固定）

- 唯一の正（Authority）は Ledger（台帳）である。
- Recovery Queue は Ledger に「回収キュー台帳」として 1 行で記録する（例：Sheets の Recovery_Queue シート）。
- Todoist / ClickUp は “投影（通知・作業管理）” であり、Ledger の確定値を上書きしない（管理UI入力禁止の原則）。
- 相互参照（固定）:
  - Ledger 行に taskIdTodoist / taskIdClickUp / url 等の参照IDを保持する（作業はタスクで進めてもよいが、状態の唯一の正は Ledger）。
- 冪等（固定）:
  - 登録キー（例）rqKey = Hash(Order_ID + category + reason + detectedBy + detectedAt)
  - 同一 rqKey の再登録は「新規行を増やさず」更新で吸収する（重複通知・重複タスク禁止）。
- 解消（固定）:
  - status を RESOLVED に更新し、resolvedAt / resolvedBy / resolutionNote を記録する。
  - Todoist/ClickUp の完了は “投影の反映” として行ってよいが、Ledger を自動で RESOLVED にしてはならない（根拠付き更新のみ）。


- 実装では、次のいずれか（または併用）でよい：
  - 台帳（Sheets 等）に 1 行として追記
  - タスク（Todoist 等）を起票し、台帳には参照IDを残す
（採用する実装先は Phase-2 の実装PRで固定する）

### 解消の定義（固定）
- PRICE未確定: 対象 BP の PRICE を確定値として入力済みであること（推測代入禁止）。
- LOCATION不整合: 対象部材の LOCATION が整合し、STOCK 戻しが可能であること。
- 写真不足: 必要写真が追補されたこと（不足の内訳は details に記録）。
- 抽出不備: 完了コメントの形式が修正され、未使用部材の抽出が可能であること。
### Request linkage（固定）

#### 位置づけ（固定）
- Recovery Queue は「不備回収の運用キュー」であり、Request は「申請台帳（master_spec 3.7）」である。
- いずれも OPEN を“未処理”として扱うが、意味は異なるため混同しない（Recovery=回収、Request=申請）。
- UI/人が勝手に RESOLVED/CANCELLED を確定しない（解消は根拠と記録を伴う）。

#### 連携ルール（最小｜固定）
- BLOCKER/WARNING を検出したら、まず Recovery Queue に status=OPEN で登録する（冪等）。
- 次に該当する場合は、Request も併せて status=OPEN で登録してよい（推奨）：
  - BP の PRICE 未確定 → Request.Category=UF07（targetType=PART_ID / targetId=PART_ID / partId=PART_ID / price=確定値）
  - LOCATION 不整合 / 抽出不備 / 写真不足 / 監督判断が必要 → Request.Category=REVIEW（targetType=Order_ID / targetId=Order_ID）
- 既に対応する Request（OPEN）が存在する場合は、重複作成せず「参照リンク（参照ID/URL等）」のみを残す（冪等・増殖防止）。

#### 理由→推奨アクション（固定）
- PRICE未確定（BP）:
  - Recovery Queue: BLOCKER / OPEN
  - Request: UF07 を推奨（価格確定の申請）
- LOCATION不整合（在庫戻し対象）:
  - Recovery Queue: BLOCKER / OPEN
  - Request: REVIEW を推奨（監督判断/是正の回収）
- 写真不足:
  - Recovery Queue: WARNING / OPEN（Phase-1 の分類に従属）
  - Request: REVIEW（MISSING_INFO）を推奨（追補回収）
- 抽出不備（未使用部材/完了コメント書式）:
  - Recovery Queue: WARNING / OPEN（在庫戻し対象が実在し処理停止が必要な場合は BLOCKER に昇格し得る）
  - Request: REVIEW を推奨（追補・監督回収）

#### 解消（RESOLVED）の定義（固定）
- Recovery Queue を RESOLVED にしてよい条件は、master_spec の確定データが整合し、不備が解消していること。
  - PRICE未確定 → Parts_Master.PRICE が確定値で埋まり、対象の警告（ALERT_PRICE_MISSING 等）が消える。
  - LOCATION不整合 → 対象部材の LOCATION が整合し、STOCK 戻しが可能である。
  - 写真不足 → DONE/CLOSED の要件を満たし、写真不足フラグが解消している。
  - 抽出不備 → 未使用部材抽出が成功し、必要な在庫戻し/記録が完了している。
- Request を併設した場合：
  - RequestStatus=RESOLVED/CANCELLED になったとき、対応する Recovery Queue は RESOLVED にしてよい（ただし上記の台帳整合が満たされていること）。
  - RequestStatus=OPEN の間は、Recovery Queue を勝手に RESOLVED にしない。

### 冪等（Recovery Queue 登録）【固定】
- 登録は必ず冪等でなければならない（再送・二重起動で増殖しない）。
- 推奨 idempotencyKey（固定要素）：
  - Order_ID + reason + detectedBy + (PART_ID がある場合は PART_ID)
- 同一 idempotencyKey は 1 件に正規化し、二重登録は「同一案件の再観測」として扱う（details の追記は許容、行増殖は禁止）。

### IdempotencyKey（イベント別｜固定）

#### 目的（固定）
- 再送・二重起動・順序逆転が起きても、台帳（Ledger）が増殖せず、状態が破綻しないことを保証する。
- ここで定義する idempotencyKey は「同一イベント判定」の唯一の基準とする。

#### 共通フォーマット（固定）
- idempotencyKey は次の要素で構成する（区切りは実装でよい。要素の意味は固定）：
  - eventType（固定語）
  - primaryId（Order_ID または PART_ID 等。イベントの主対象）
  - eventAt（イベント確定時刻：入力/受信の確定時刻）
  - sourceId（任意：外部イベントID等。取得できる場合のみ）

- primaryId が確定できない場合は Runtime 破綻として扱い、Recovery Queue に OPEN 登録する（増殖防止）。

#### イベント別（固定）
1) UF01（受注登録）
- eventType: UF01_SUBMIT
- primaryId: Order_ID
- eventAt: UF01 登録の確定時刻
- sourceId: 任意（媒体側の通知ID等）

2) UF06-ORDER（発注確定）
- eventType: UF06_ORDER
- primaryId: PART_ID（発行後は PART_ID を主対象とする）
- eventAt: 発注確定時刻
- sourceId: 任意

3) UF06-DELIVER（納品確定）
- eventType: UF06_DELIVER
- primaryId: PART_ID
- eventAt: 納品確定時刻（DELIVERED_AT）
- sourceId: 任意

4) UF07-PRICE（価格確定）
- eventType: UF07_PRICE
- primaryId: PART_ID
- eventAt: 価格確定時刻
- sourceId: 任意

5) UF08（追加報告）
- eventType: UF08_SUBMIT
- primaryId: Order_ID
- eventAt: 追加報告確定時刻
- sourceId: 任意

6) WORK 完了（現場完了）
- eventType: WORK_DONE
- primaryId: Order_ID
- eventAt: workDoneAt（完了日時）
- sourceId: 任意（現場UI側イベントID等）

7) 更新（再同期）
- eventType: RESYNC
- primaryId: Order_ID（Order 単位の再同期）または NONE（全体再同期）
- eventAt: 再同期の開始時刻
- sourceId: 任意

#### 重複イベントの扱い（固定）
- 同一 idempotencyKey のイベントが再到達した場合：
  - Ledger を増殖させない（二重行追加・二重通知禁止）。
  - “同一イベントの再観測”として扱い、details/log の追記は許容する（ただし台帳の主要レコード増殖は禁止）。
- idempotencyKey が異なるが、同一 primaryId に対して短時間に競合が発生した場合：
  - 自動で辻褄合わせをしない。
  - Recovery Queue（OPEN）へ登録し、監督回収に寄せる（Integration Contract に従属）。

### Runtime Audit Checklist（expected/unexpected｜固定・参照用）

#### 目的（固定）
- 実行後に「必ず起きるべき副作用（expected effect）」と「起きてはならない副作用（unexpected effect）」を、イベント別に一覧化し、監査の探し回りをゼロにする。
- 本節は監査観点の固定であり、実装方法・ログ形式の詳細は別テーマで扱う。

#### 監査の原則（固定）
- expected effect が欠落している場合：Runtime NG（破綻）として扱い、Recovery Queue（OPEN）へ登録する。
- unexpected effect が発生した場合：Runtime NG（破綻）として扱い、Recovery Queue（OPEN）へ登録する。
- 自動で辻褄合わせをしない（Integration Contract に従属）。

#### イベント別 expected effect（最小｜固定）
1) UF01_SUBMIT（受注登録）
- Order_YYYY に 1 行以上の追加（Order_ID が発行済みである）
- CU_Master / UP_Master は「新規 or 再利用」のいずれかが成立している（参照整合が壊れていない）
- logs/system 相当へ記録が残る（参照用）

2) UF06_ORDER（発注確定）
- Parts_Master に新規行追加（PART_ID / OD_ID / STATUS=ORDERED or STOCK_ORDERED）
- BP の PRICE は未確定を許容（BM は PRICE=0 固定）
- Order_ID 無し発注は STOCK_ORDERED として扱われる（Phase-1 EXCEPTIONS）

3) UF06_DELIVER（納品確定）
- Parts_Master の対象 PART_ID が STATUS=DELIVERED へ遷移
- DELIVERED_AT が記録されている
- BP の PRICE は最終的に確定値で埋まる（未確定は BLOCKER として回収される）

4) UF07_PRICE（価格確定）
- Parts_Master の対象 PART_ID に PRICE が確定値で記録される
- STATUS は原則変更しない（価格確定のみ）

5) UF08_SUBMIT（追加報告）
- 追加報告の記録が残る（logs/extra または Request/相当台帳）
- OV01 参照で追跡可能な形（Order_ID 接続）が成立している

6) WORK_DONE（現場完了）
- Order の完了根拠（workDoneAt / workDoneComment）と最終同期が記録される
- DELIVERED 部材の USED 化が成立する（対象が USED へ遷移）
- BP（USED）の PRICE を根拠に Expense が確定記録される（EXP_ID 発行）
- 未使用部材が抽出され、在庫戻し（STOCK）と LOCATION 整合が成立する（不整合は BLOCKER 回収）

7) RESYNC（更新／再同期）
- Ledger の確定状態が UI（現場/管理）へ再投影される（参照整合が回復する）
- 冪等：同一 RESYNC の再実行で台帳が増殖しない

#### イベント別 unexpected effect（代表例｜固定）
共通（全イベント）：
- ID 再発番／再利用（Order_ID / PART_ID / EXP_ID 等の重複・改変）
- 二重行増殖（同一 idempotencyKey で主要台帳が増える）
- 異常日付（未来日／逆転）を確定値として保存
- 本番とテストの混在（テストIDの本番混入）

UF系（入力）：
- 入力禁止経路（管理UI等）からの確定値書込みが発生する

完了同期：
- PRICE 推測代入で Expense を確定してしまう
- LOCATION 欠落のまま STOCK 戻しが完了扱いになる

#### NG 時の出力（固定）
- NG は Recovery Queue（OPEN）へ登録する（reason / detectedBy / details / idempotencyKey）。
- 必要に応じて Request（REVIEW）を併設して監督回収に寄せる（Request linkage に従属）。

### RuntimeSelfTest（テスト走行｜固定）

#### 目的（固定）
- Runtime監査（expected/unexpected）が実運用で機能することを、**本番データに触れず**に検証する。
- 汚染（本番とテスト混在）を絶対に起こさない形で、UF/完了同期/回収の最短ループを通す。

#### 実行タイミング（固定）
- 次のいずれかに該当する変更を main へ入れる前に、必ず 1 回実行する：
  - UF01/UF06/UF07/UF08/FIX/DOC/完了同期/更新（再同期）に関わる変更
  - Idempotency / Recovery Queue / Request linkage / Runtime Audit Checklist に関わる変更
  - 外部連携（Todoist/ClickUp/AI補助）の経路に関わる変更
- 入口整備や文言のみ（意味変更なし）の変更では必須としない（任意）。

#### テストデータ規約（固定）
- テスト走行は **テストID（0番）**を用い、本番と混在させない。
- テストデータは集計/閲覧/検索の対象外とする（本番汚染防止）。
- 既存のテストID規約（master_spec）に従属する。

#### テストシナリオ（最小｜固定）
1) UF01_SUBMIT：テスト受注を 1 件登録（Order_ID 発行）
2) UF06_ORDER：テスト部材を発注として登録（PART_ID/OD_ID、STATUS=ORDERED）
3) UF06_DELIVER：納品確定（STATUS=DELIVERED、DELIVERED_AT 記録）
4) UF07_PRICE：BPのPRICE確定（推測代入禁止）
5) UF08_SUBMIT：追加報告を 1 件記録（Order_ID 接続）
6) FIX_SUBMIT：修正申請を 1 件記録（危険修正は確定しない）
7) DOC_SUBMIT：書類申請を 1 件記録
8) WORK_DONE：完了同期を実行し、USED/EXP/在庫戻し（必要なら未使用部材コメント）まで通す

#### 合格条件（固定）
- Runtime Audit Checklist の expected effect がイベント別に満たされる。
- unexpected effect が発生しない（特に：ID再発番、二重行増殖、本番混入）。
- NG の場合は自動で辻褄合わせをせず、Recovery Queue（OPEN）へ登録される（回収導線が成立する）。

### Rollback（連続NG時の安定復旧｜固定）

#### 目的（固定）
- 連続する Runtime NG（破綻）により運用が停滞した場合に、**最短で安定状態へ戻す**ための公式手順を固定する。
- 原因推測ではなく「観測→回収→復旧」を優先し、汚染の拡大を防ぐ。

#### 発動条件（固定）
- 同一テーマ（同一変更）に起因する Runtime NG が連続して発生し、回収（Recovery Queue）で解消できない状態が続く場合。

#### 取扱い（固定）
- 自動で辻褄合わせをしない。
- 最後に安定していた確定状態（Sで確定している状態）へ戻し、運用を再開する。
- rollback が発生した場合は、必ず logs/system 相当へ記録し、Recovery Queue（OPEN）へ「rollback発生」を登録する（監督回収）。

#### 注意（固定）
- rollback は「失敗の隠蔽」ではなく、汚染拡大を止めるための安全装置である。
- rollback 後は、原因の是正を別テーマ（別PR）で行い、再度 RuntimeSelfTest を通す。

### Self-Diff（矛盾検知｜警告のみ｜固定）

#### 目的（固定）
- AI/文書更新の過程で「直前の確定内容」と矛盾する可能性を検知した場合に、破綻前に止める。
- 仕様の勝手な書換えを防ぎ、差分（diff）方式を守る。

#### ルール（固定）
- 矛盾の可能性を検知した場合、AIは「警告」を出して停止してよい（勝手に修正しない）。
- 解決は必ず B（人間判断）→ diff → 反映（1テーマ=1PR）の順で行う。
- Self-Diff は判断ではなく、矛盾候補の提示に限定する。

### S→Apps Script 同期（全文貼替のみ｜固定）

#### 目的（固定）
- 実装反映における部分編集・手修正による破綻を防ぎ、監査と再現性を担保する。

#### ルール（固定）
- Apps Script 側への反映は「確定済み成果物（S）を全文貼替」する方式のみ許可する。
- 部分編集・差分編集・行単位の追加削除は原則禁止とする（事故防止）。
- 反映の前後で RuntimeSelfTest を通し、expected/unexpected の監査を成立させる。

### 更新（再同期）対象範囲（固定）

#### 目的（固定）
- 「更新（再同期）」の意味を一意にし、復旧と整合回復を最短化する。
- 冪等であり、何度実行しても台帳が増殖しないことを前提とする。

#### 最小対象（固定）
- Ledger（台帳）側の整合回復：
  - Order/Parts/EX/Expense/Request/Recovery Queue の参照整合
  - alertLabels / 健康スコアの再計算（冪等）
- UI投影の再構築（Ledger → UI）：
  - 現場UI（Todoist）への参照情報再投影（必要ならタスク名/要点）
  - 管理UI（ClickUp）への監督情報再投影（STATUS/警告/OPEN回収）
- 競合が検出された場合：
  - 自動で辻褄合わせをせず、Recovery Queue（OPEN）へ登録する。

#### 禁止（固定）
- UI側の値で Ledger の確定値を上書きする用途に「更新」を使わない。

### logs/system 保存仕様（Drive JSON + Sheet Index｜固定）

#### 目的（固定）
- 監査・追跡・原因調査のために、イベントログを長期に保持しつつ、確定申告/集計を阻害しない。

#### 保存方式（固定）
- 詳細ログ：Drive に JSON として保存する（イベント単位または日次単位等。実装で選ぶ）。
- 集計用インデックス：Sheet に最小列で保持する（確定申告・月次集計はここを参照できること）。

#### インデックス最小列（固定）
- date（YYYY-MM-DD）
- eventType
- Order_ID（該当する場合）
- PART_ID（該当する場合）
- severity（INFO/WARNING/BLOCKER）
- idempotencyKey
- driveFileId（またはURL参照）
- memo（任意：短文）

#### PII マスキング（必須｜固定）
- 電話・住所等のPIIは、logs/system（詳細ログ/インデックス）に保存する前にマスキングする（漏えい防止）。
- マスキングの有無で情報価値が落ちる場合は、Ledgerの正式列に保持し、ログには複製しない（判断権の原則）。

#### ローテーション（固定）
- 容量・ファイル数の増加に備え、日次/月次でアーカイブ・圧縮等のローテーションを行ってよい（実装テーマで確定）。

### 縮退運用（enabled=false｜固定）

#### 目的（固定）
- 外部連携が利用できない場合でも業務を停止させず、確定処理を破綻させない。

#### 基本原則（固定）
- 外部連携が無効の間は「入力禁止経路」から確定値を作らない。
- 代替導線は Ledger（台帳）側に寄せ、UI投影は停止してよい。

#### 代表ケース（固定）
- Todoist（現場UI）が無効：
  - 現場完了（WORK_DONE）の入力は Ledger 側の完了入力（フォーム/運用）へ縮退する。
  - idempotencyKey と Recovery Queue を維持し、二重確定を防ぐ。
- ClickUp（管理UI）が無効：
  - 警告・回収は Recovery Queue（OPEN）を唯一の回収箱として運用し、監督は Ledger/OV01 側で行う。
- AI補助が無効：
  - 素材抽出・違和感候補は停止し、業務ロジックの確定のみで進める。
- 住所API等が無効：
  - 既存の確定ルールに従い、曖昧さは REVIEW 回収へ寄せる。

### Webhook 再送・重複（リトライ/レート制限）契約（固定）

#### 目的（固定）
- 再送・重複・一時失敗が起きても、台帳が増殖せず、確定が二重化しないことを保証する。

#### 契約（固定）
- 受信イベントは必ず idempotencyKey で重複排除する（IdempotencyKey 節に従属）。
- 再送は許容するが、同一 idempotencyKey は “同一イベントの再観測” として扱い、主要台帳の増殖は禁止。
- rate limit / 一時障害時は、リトライを行ってよい（実装方式は別）。最終的に失敗した場合：
  - logs/system に記録し、Recovery Queue（OPEN）へ登録する（監督回収）。

#### 禁止（固定）
- リトライのたびに台帳へ新規行を追加する（増殖）。
- 管理UIからの入力で確定処理を代替する（入力禁止経路）。

## Comment Concierge & Task Presentation（Phase-2）

## Order Lifecycle Controls（Phase-2）— 欠番/削除/復旧/誤完了解除（トゥームストーン方式）

### 目的（固定）
- 「欠番（VOID）」「削除（CANCEL/DELETE）」「復旧（RESTORE）」「誤完了解除（REOPEN/UNDELIVER）」を、監査可能かつ事故耐性の高い方式で固定する。
- 物理削除（行削除／履歴消去）を禁止し、台帳（Ledger）に“事実”として残す（トゥームストーン）。
- 在庫（PARTS）・経費（EXPENSE）・回収（Recovery Queue / Request）へ、冪等かつ安全に接続する（自動辻褄合わせ禁止）。

### 用語と定義（固定）
- 欠番（VOID）:
  - Order_ID が発行されたが、業務として成立しなかった（誤作成／重複／即取消）。
  - 原則：請求／領収／完了同期の対象にしない。
- 削除（CANCEL/DELETE）:
  - 成立していたが取り下げた（キャンセル）。
  - 原則：以後の更新・同期を止める（ただし“存在した事実”は残す）。
- 復旧（RESTORE）:
  - VOID/CANCEL を取り消し、再び運用対象へ戻す。
  - 原則：復旧に伴う不整合は自動で補正せず、Recovery Queue（OPEN）へ回収する。
- 誤完了解除（REOPEN / UNDELIVER）:
  - DELIVERED / WORK_DONE 等の誤り訂正（欠番/削除とは別物）。
  - 原則：欠番/削除と混ぜない（会計・在庫・監査が破綻するため）。

### 大原則（固定）
- 物理削除は禁止（Order/Parts/Expense/Request/Recovery Queue の履歴を消さない）。
- 自動で辻褄合わせをしない（Integration Contract の「競合・破綻の扱い」に従属）。
- UI（現場/管理）・AI補助は確定値を作らない（Authority 原則に従属）。
- すべての操作は冪等であること（IdempotencyKey で重複排除）。
- 危険域（在庫・経費・請求に影響する領域）に触れる場合は「凍結→回収」を優先する。

### 在庫（PARTS）に対する「解放」と「凍結」（固定）
本節における解放/凍結は、「部材のSTATUSを恣意に変える」ことではない。
STATUSは Phase-1: PARTS の不変条件に従属し、任意変更はしない。

#### 解放（RELEASE｜安全域のみ）
- 対象：当該 Order に紐づく部材のうち、次を満たす“安全域”のみ。
  - まだ業務確定（納品/使用/経費確定）へ影響していないと判定できるもの。
- 効果：
  - 当該 Order の拘束（予約/紐付け）を解除し、在庫運用へ戻す。
  - 解除が「危険修正（FIX）」に該当する場合は自動で実行せず、凍結へ切り替える（後述）。

#### 凍結（FREEZE｜危険域は回収へ）
- 対象：当該 Order に次が1つでも存在する場合は凍結する。
  - DELIVERED / USED 等、完了同期・経費・会計に影響する部材が存在する。
  - 既に経費（Expense）が確定している。
  - 既に書類（INVOICE/RECEIPT 等）の作成・発行・入金等、会計イベントが進行している（将来拡張を含む）。
- 効果：
  - 自動で取消・転用・巻戻しをしない。
  - Recovery Queue（BLOCKER/OPEN）へ登録し、監督回収へ寄せる。
  - 必要に応じて Request（REVIEW）を併設してよい（Request linkage に従属）。

### Recovery Queue / Request linkage（固定）
- VOID/CANCEL/RESTORE/REOPEN の操作は、次のいずれかに該当する場合、必ず Recovery Queue に登録する（冪等）:
  - 凍結条件に該当（危険域が存在）。
  - 解除/復旧に必要な前提（例：在庫拘束解除、整合確認）が満たせない。
  - 競合（同一Orderに矛盾する操作が短時間に到達、素材不一致 等）を検出した。
- 監督判断が必要な場合は Request=REVIEW を併設してよい。
- いずれも自動で RESOLVED にしない（根拠と記録を伴う更新のみ）。

### IdempotencyKey（固定）
- 本節の操作イベントは必ず冪等であること。
- eventType（固定語）:
  - ORDER_VOID / ORDER_CANCEL / ORDER_RESTORE / ORDER_REOPEN
- primaryId: Order_ID（#n で指定された対象）
- eventAt: 確定時刻（受付確定時刻）
- sourceId: 任意（外部イベントID等。取得できる場合のみ）
- 同一 idempotencyKey の再到達は「同一イベントの再観測」として扱い、主要台帳の増殖は禁止（ログ追記は許容）。

### コメント操作（削除モード）— 最小仕様（固定）
本節は Comment Concierge の「確認→番号選択→実行」プロトコルに従属する。

#### トリガ（固定）
- `削除モード`（`#n 削除モード` により対象受注を指定可。未指定なら #0）
- モード中は対象 Order（#n）を固定し、他Orderへ移れない（誤爆防止）。
  - 他Orderへ移る場合は `キャンセル` で退出し、再度 `#m 削除モード` を開始する。

#### モード中の許可コマンド（固定・最小）
- `欠番`（= ORDER_VOID）
- `削除`（= ORDER_CANCEL）
- `復旧`（= ORDER_RESTORE）
- `誤完了解除`（= ORDER_REOPEN）
- `キャンセル`（何もせず退出）

#### 実行手順（固定）
1) 候補提示（番号付き・影響要約を含む）
2) ユーザーが番号選択（複数可）
3) 最終確認（要約）
4) ユーザーが `実行` で確定

#### 実行後の返答（固定・最小）
- 操作名（VOID/CANCEL/RESTORE/REOPEN）
- 対象（Order_ID/#n）
- 在庫扱い（解放できた数／凍結理由）
- Recovery Queue の発生有無（OPEN件数と理由）
- 次の導線（確認/回収の参照先：実装で定義）

### 監査（Runtime Audit Checklist への接続｜固定）
- ORDER_VOID / ORDER_CANCEL / ORDER_RESTORE / ORDER_REOPEN は、監査対象イベントとして expected/unexpected を持つ。
- unexpected effect（代表例）:
  - 物理削除が発生する（履歴消去）
  - 自動で辻褄合わせが発生する（危険域を勝手に巻戻す）
  - 同一 idempotencyKey で主要台帳が増殖する
- NG は Recovery Queue（OPEN）へ登録する（勝手に修正しない）。

### 注意（固定）
- VOID/CANCEL は「状態の確定」であり、会計・在庫・完了同期の“意味”を勝手に書き換えるものではない。
- 危険域が存在する場合は、停止して回収へ寄せることが正しい（自動で整合させない）。


### 目的
- コメント（コンシェルジュ）と HTML フォームの両方から、同じ受注（Order_ID）を安全に操作できる状態を固定する。
- コメントは「入口・回収・誘導」を担当し、HTML は「編集・確定」を担当する（ただし欠番等は運用方針に従う）。
- 事故防止のため、更新系は必ず “確認→番号選択→実行” の順で確定する。

---

### コメント（コンシェルジュ）操作ルール（固定）
#### 更新系の確定手順（固定）
- 更新系（発注/納品/金額入力/更新/解除/欠番 等）は、必ず次の順で進行する：
  1) 候補提示（番号付き）
  2) ユーザーが番号選択（複数可）
  3) 最終確認（要約）
  4) ユーザーが「実行」で確定
- 「実行」以外では確定処理を行わない。

#### 実行後の返答（固定）
- 実行後は最小サマリのみ返す：
  - 操作名 / 対象数 / 進捗（例：納品 1/3） / 残不備（BLOCKER/WARNING）＋次リンク
- 不明点はユーザーが質問し、必要な分だけ追加説明する（自発的な長文化は禁止）。

#### コマンド一覧（固定）
- コメント1行目が「コマンド」のとき、利用可能コマンドの最小一覧を返す（例文は最小）。
- `#n` 指定の例を 1 行だけ含める（迷子防止）。
  - 例：`#1 完了報告書` / `#1 請求書`

---

### コメントモード（モード固定）— 入力待ち・実行・キャンセル（Phase-2｜固定）

#### 目的（固定）
- 「トリガー→モード固定→入力待ち→確定（実行）／中止（キャンセル）」を、誤爆しない形で固定する。
- 長文（媒体コピペ／ぶつ切り入力）を安全に受け取り、確定処理は必ず人間の `実行` で行う。

#### 基本原則（固定）
- モード中は「対象（#n）」を固定し、他の対象へ自動で移動しない（誤爆防止）。
- タイムアウトは設けない（自動キャンセルしない）。退出は `実行` または `キャンセル` のみ。
- モード中に更新系の確定処理はしない（確定は `実行` のみ）。
- モード中の入力は「素材」であり、確定値の決定は Orchestrator が行う（Authority 原則に従属）。

#### モードの開始（固定）
- 入口は「トリガー」から開始する。
- `#n` 指定がある場合は対象=#n、無い場合は既定対象（例：#0）を用いる。
- 開始時は次を返す（最小）:
  - MODE名 / 対象（Order_ID/#n）
  - 入力待ちの案内（終了= `実行` / `キャンセル`）

#### モード中の許可入力（固定）
- 許可（入力）:
  - 自由文（ぶつ切り可）：素材として蓄積する。
- 許可（参照のみ）:
  - `コマンド`（最小一覧の再提示）
  - `#n 状態`（対象の状態/進捗の参照。更新はしない）
- 禁止（モード中）:
  - 発注/納品/金額入力/削除/復旧などの「更新系」確定（混在防止）。
  - 対象切替（#mへ移動）。必要なら `キャンセル` → 再トリガーで開始し直す。

#### 確定（固定）
- `実行` を受領した時だけ、蓄積した素材を用いて確定処理へ進む（confirm→select→実行の原則に従属）。
- 実行後は最小サマリのみ返す（登録済み/未入力/次リンク）。過剰な説明は禁止。

#### 中止（固定）
- `キャンセル` を受領した場合、蓄積した素材は破棄して退出する（台帳/外部へ反映しない）。
- キャンセルの事実はログ（logs/system 相当）に残してよい（実装に委譲）。

### トリガー一覧（Phase-2｜固定）

#### 目的（固定）
- コメント1行目（またはモード中の入力）を「トリガー」として解釈し、誤爆と混線を防ぐ。
- トリガーは分類（MODE / ONE-SHOT / REF）と衝突解決を持つ（自動で辻褄合わせしない）。

#### 分類（固定）
- MODE（モード化）:
  - 対象（#n）を固定し、入力を溜め、`実行` / `キャンセル` でのみ退出・確定する。
- ONE-SHOT（単発）:
  - 単発で受付・応答する（ただし更新系は confirm→select→実行 の原則に従属）。
- REF（参照）:
  - 参照のみ。確定値を書き換えない（Authority原則）。

#### トリガー一覧（固定・最小）
- REF:
  - `コマンド` : 利用可能コマンドの最小一覧を返す（例文は最小、#n例は1行のみ）。
  - `#n 状態` : 対象（#n）の状態/進捗/回収（OPEN）要点を返す（更新しない）。
- MODE:
  - `削除モード` : Order Lifecycle Controls の削除モードへ入る（対象固定、退出=実行/キャンセル）。
  - `完了報告書` : 完了報告書モードへ入る（対象固定、退出=実行/キャンセル）。
  - `追加受注` : 追加受注モードへ入る（対象固定、退出=実行/キャンセル）。
- MODE内コマンド（共通）:
  - `実行` : モードで蓄積した素材を確定処理へ渡す（確定はこれのみ）。
  - `キャンセル` : 蓄積素材を破棄して退出（外部/台帳へ反映しない）。
  - `コマンド` / `#n 状態` : 参照のみ（更新しない）。

#### 対象指定（#n）解決（固定）
- `#n <トリガー>` の形で対象を指定できる（例：`#1 完了報告書`）。
- `#n` が無い場合は既定対象（例：#0）を用いる（実装で #0 の解決は既存契約に従う）。
- `#n` 解決は台帳（Order_YYYY の TaskId 列等）を唯一の正として行う（推測しない）。

#### 衝突解決（固定）
- 1) 既に MODE 中の場合：
  - まず MODE内コマンド（`実行` / `キャンセル` / `コマンド` / `#n 状態`）を解釈する。
  - それ以外の入力は「素材」として蓄積する（更新系は確定しない）。
- 2) MODE 中でない場合：
  - 先頭行が REF（`コマンド` / `#n 状態`）に一致 → REF を実行。
  - 次に MODE トリガー（`削除モード` / `完了報告書` / `追加受注`）に一致 → MODE 開始。
  - それ以外は通常入力として扱い、必要なら適切な MODE へ誘導する（自動確定は禁止）。

#### 禁止（固定）
- トリガー曖昧時に「勝手に更新系を確定」しない。
- MODE 中に対象を自動で切替えない（誤爆防止）。
- 管理UI（ClickUp）入力を確定値として取り込まない（Authority原則）。

### 追加受注（同一タスク内で追加Order発行）（固定）
#### コマンド（固定）
- `追加受注 <自由文>`：同一タスク内で追加の Order_ID を発行する。

#### 追加受注の既定（固定）
- 既定は「同一顧客・同一物件」を引き継ぐ（CU/UP再利用）。
- 追加受注には “子番号” を付与し、コメント内で参照できるようにする。

#### 子番号参照（固定）
- `#0`：親（元の受注）
- `#1`：同一タスク内で作成した最初の追加受注
- `#2`：2つ目の追加受注 …（以後同様）
- 親タスク名は変更しない。

#### 生成直後の返答（固定）
- `追加受注 #1 を作成しました` を返し、`#1` 用の完了報告書テンプレを提示する。
- その後の指示（短文）を必ず付ける：
  - `次：#1 完了報告書 に本文を貼ってください（ぶつ切りOK）。登録状況を返します。`
  - `売上金額が入ったら請求書DRAFT（INVOICE）を自動作成し、直リンクを返します。`

#### 親子リンク（固定）
- コメントに `LINK: #0 → #1` の 1 行を残す（追跡用）。
- 台帳側も相互参照（HistoryNotes等）を残してよい（実装に委譲）。

---

### 完了報告書（コメント登録）（固定）
#### トリガー（固定）
- `完了報告書` をトリガーとする（`#n 完了報告書` により対象受注を指定可）。

#### ひな形提示（固定）
- `完了報告書` 受領時、既知情報を埋めたテンプレを提示する。
- ユーザーは媒体コピペ（自由文）または手書き（短い行羅列）で追記してよい。

#### ぶつ切り入力と登録状況（固定）
- ぶつ切りで送られても取り込む。
- 毎回、最小の登録状況を返す：
  - 今回登録した項目 / 未入力の項目（不足）
- 同一項目の上書きが発生した場合は「変更前→変更後」を短く提示する。

#### 金額（固定）
- 完了報告では「売上金額」のみを扱う（見積金額は扱わない）。
- 売上金額を受領したら、INVOICE の DRAFT（Request=DOC）を自動作成してよい（docDraftId直開きリンクを返す）。
- RECEIPT の DRAFT は自動作成しない（入金後に作る）。

---

### タスク表示（Todoist/ClickUp）契約（固定）
#### タスク名（title）
- 先頭は AA群（重複排除）を基本とする。
- AA個数が 5 以上の場合は、AA列挙を捨てて `納品 分子/分母` 表示へ切替する。
  - 分母：当該 Order_ID に紐づく「発注総数」（Parts_Masterで Order_ID を持つ PART_ID の総数）
  - 分子：当該 Order_ID に紐づく「納品数」（STATUS=DELIVERED の数）
- 末尾に自由文スロット `_ `（アンダースコア＋半角スペース）を必ず付与し、システム更新でも保持する。

#### タスク名の更新タイミング（固定）
- UF01 / UF06（発注・納品）/ 更新（再同期）/ WORK_DONE（完了報告）でイベント駆動更新する。

#### タスク説明（description）
- 次のフォーマットを採用する（メーカー不要）：

  品番：○○＋○○＋○○
  見積：
  memo：○○

  コメント
  <品番>  <AA>
  <品番>  <AA>
  ...

- 見積が未確定の場合は空欄（行は残してよい）。
- 品番リスト（コメント以下）は「品番＋AA」のみ（メーカー/状態/価格/PART_IDは表示しない）。

#### 重要情報の記録（コメント）— Todoist / ClickUp 共通（固定）
- 住所/電話/希望日/備考など “吸い上げた重要情報” はコメントに記録する（マスクしない）。
- Todoist/ClickUp の説明欄（または本文）に次のブロックを同一テンプレで持つ：
  [INFO]
  顧客名: ...
  電話: ...
  住所: ...
  希望日: ... / ...
  備考: ...

  --- USER ---
  （ここから下は自由メモ。システムは上書きしない）

- システム更新で上書きするのは [INFO] ブロックのみ。`--- USER ---` 以降は触らない。
- [INFO] 更新が失敗した場合は業務を止めず、Recovery Queue（WARNING/OPEN）へ登録して回収する。

#### ID解決（固定）
- 納品等の内部処理は PART_ID を用いるが、ユーザー提示は最小表示（品番＋AA）のみ。
- コンシェルジュは Order_YYYY の `TodoistTaskId` / `ClickUpTaskId` 列で Order_ID を解決して処理する。

### 欠番/削除モード（最終仕様）— FIX連携・解放/凍結境界・復旧（Phase-2｜固定）

#### 目的（固定）
- 欠番（VOID）/削除（CANCEL）を「実運用で事故らない」最終仕様として固定する。
- “安全に自動解放できる領域” と “凍結して監督回収すべき領域” を明確化し、勝手な辻褄合わせを禁止する。
- 危険修正（FIX）へ正しく接続し、復旧（RESTORE）・誤完了解除（REOPEN）を混同しない。

#### 判定の原則（固定）
- 判定は Orchestrator が行う（UI/人/AIが恣意に確定しない）。
- 不確実（情報不足・参照不整合・競合）な場合は必ず FREEZE とし、Recovery Queue（BLOCKER/OPEN）へ回収する。
- 物理削除は禁止（履歴保全）。VOID/CANCEL/RESTORE の事実を台帳に残す（トゥームストーン）。

#### 解放（RELEASE）可能条件（固定）
次の全てを満たす場合のみ、VOID/CANCEL に伴う「自動解放（安全域）」を許可する：
- 当該 Order に紐づく PARTS が、完了同期・会計へ影響する状態を含まない：
  - 禁止状態が 1つでもあれば FREEZE：ORDERED / DELIVERED / USED
- 当該 Order に確定経費（EXPENSE）が存在しない（存在すれば FREEZE）。
- 当該 Order に会計イベント（INVOICE/RECEIPT 等）の進行が存在しない（存在すれば FREEZE）。
- #n 解決（Order_ID）が台帳で確定でき、参照整合が取れている（取れない場合は FREEZE）。

補足（固定）：
- SAFE の可否に迷う場合は FREEZE（自動で辻褄合わせしない）。

#### FREEZE（凍結）条件（固定）
次のいずれかに該当したら、VOID/CANCEL の処理は FREEZE とし、自動で取消・転用・巻戻しを行わない：
- PARTS に ORDERED / DELIVERED / USED が存在する。
- EXPENSE（確定経費）が存在する。
- 会計（INVOICE/RECEIPT 等）の進行が存在する（将来拡張含む）。
- 参照不整合（Order_ID 解決不可、TaskId紐付け不明、同一Orderに競合イベント等）。
- 同一対象へ短時間に矛盾するライフサイクル操作が到達（VOID↔RESTORE など）した。

#### FREEZE 時の回収（Recovery Queue / Request / FIX 連携｜固定）
- FREEZE になった場合：
  - Recovery Queue に BLOCKER/OPEN を必ず登録する（冪等）。
  - details に最小で次を含める：
    - 操作（VOID/CANCEL/RESTORE/REOPEN）
    - FREEZE 理由（例：PARTS=DELIVEREDあり / EXPENSEあり / 会計進行あり / 参照不整合）
    - 対象（Order_ID/#n）
- FIX 連携（固定）：
  - FREEZE の解消に「ID/紐付け/状態の危険修正」が必要な場合は、Request に FIX（または同等カテゴリ）を併設する。
  - FIX は “申請” であり、自動確定しない（Authority原則）。
  - FIX が OPEN の間は、Recovery Queue を勝手に RESOLVED にしない（台帳整合が条件）。

#### 削除モード（コメント運用）での確定手順（固定）
- 削除モードは MODE として動作し、対象（#n）を固定する（モード固定規約に従属）。
- 進行（固定）：
  1) `#n 削除モード`
  2) 候補提示（影響要約を含む：SAFE/ FREEZE、在庫/経費/会計の検査結果）
  3) ユーザーが操作選択（欠番/削除/復旧/誤完了解除）
  4) 最終確認（要約）
  5) `実行` で確定
- 実行後の返答（固定・最小）：
  - 操作名（VOID/CANCEL/RESTORE/REOPEN）
  - 結果（SAFE=解放実施/ FREEZE=回収へ）
  - Recovery Queue（OPEN件数・理由）
  - 次導線（#n 状態 等）

#### 復旧（RESTORE）の手順（固定）
- RESTORE は VOID/CANCEL を取り消し、再び運用対象へ戻す。
- 原則（固定）：
  - タイトルの `[VOID]` / `[CANCEL]` を除去し、タスク状態は可能なら復旧（Reopen/Uncomplete）する（タスク投影規約に従属）。
  - RESTORE により不整合が検出された場合は FREEZE し、Recovery Queue（BLOCKER/OPEN）へ回収する（自動補正しない）。
  - RESTORE は “会計/在庫の巻戻し” を自動で行う操作ではない（必要なら FIX/REVIEW へ）。

#### 誤完了解除（REOPEN）との切り分け（固定）
- REOPEN は「誤って完了した状態を戻す」操作であり、VOID/CANCEL の解除ではない。
- REOPEN は VOID/CANCEL と混同しない（混同時は FREEZE して回収する）。

#### 監査（固定）
- VOID/CANCEL/RESTORE/REOPEN は idempotencyKey を持ち、同一キーの再到達で台帳を増殖させない。
- NG（想定外副作用）が出た場合は Recovery Queue（OPEN）へ登録し、勝手に修正しない。

## DoD（Phase-2）

### 目的
- Phase-1 を実装へ落とし込むための入力仕様（フォーム分割・バリデーション・台帳マッピング・ID責務・回収運用）を固定し、実装が一本道で進められる状態を完了とする。

### 完了条件（確認可能）
- UI/Form Capture Spec（Phase-2）が存在し、入力タイミングと最小入力項目が定義されている。
- UI/Form Split & Validation（Phase-2）が存在し、BLOCKER/WARNING へのマッピングが固定されている。
- Form → Ledger Mapping（Phase-2）が存在し、フォーム入力が Order/Parts/Expense/Warnings にどう記録されるかが固定されている。
- ID Issuance & UI Responsibility（Phase-2）が存在し、PART_ID/OD_ID/AA/PA/MA/EXP_ID の発行責務とタイミングが固定されている。
- Recovery Queue（Phase-2）が存在し、BLOCKER/WARNING の回収（登録→通知→解消→記録）が固定されている。
- Integration Contract（Phase-2）が存在し、統合の責務分界・同期範囲・切替・冪等・競合時の回収が固定されている。
```


---

### FILE: platform/MEP/03_BUSINESS/よりそい堂/code/README.md
- sha256: aaa3dad7ea832722566d5ab943505eea0986907285305246248057f916769f98
- bytes: 327

```text
# Yorisoidou Business Code Entry

This directory is the canonical entry point for business-side code/assets for よりそい堂.
- This file is intentionally minimal.
- Update business packet via workflow_dispatch: Business Packet Update (Dispatch)
<!-- CI_TOUCH: 2026-01-03T01:55:22 -->
<!-- CI_TOUCH: 2026-01-03T02:12:27 -->
```


---

### FILE: platform/MEP/03_BUSINESS/よりそい堂/master_spec.md
- sha256: 8ec9f8cbd32430512d349e57343948965f07429b29dcf2c2d4c2f50325ec6993
- bytes: 933

```text
<!--
ENTRY GUIDE ONLY (DO NOT PUT THE FULL SPEC HERE)
CANONICAL CONTENT: platform/MEP/03_BUSINESS/よりそい堂/master_spec
-->

# master_spec.md（入口・案内専用）

このファイルは **入口（案内）**です。本文（唯一の正）は次です：

- **唯一の正（実体）**：platform/MEP/03_BUSINESS/よりそい堂/master_spec（拡張子なし）

## 編集ルール（固定）
- 仕様の本文を編集する場合は **必ず master_spec を編集**する
- master_spec.md は案内・要点・手順のみ（本文は置かない）

## 関連（このディレクトリ内）

- INDEX（入口・読む順番）：platform/MEP/03_BUSINESS/よりそい堂/INDEX.md
- 業務スペック（フロー/例外/最小定義）：platform/MEP/03_BUSINESS/よりそい堂/business_spec.md
- UI適用仕様（導線/表示のみ・意味変更なし）：platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md
```


---

### FILE: platform/MEP/03_BUSINESS/よりそい堂/ui_master.md
- sha256: 8b689660ee5d20a6e0e830ce560a62e8b6eac0e14586a4ee9960db96dd71ea5f
- bytes: 12284

```text
<!--
PHASE-1 (ADD ONLY): This file is a new container. Do NOT change canonical meaning yet.
CANONICAL (current): platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md
ROLE: UI_MASTER (screen/components/field mappings)
-->

# UI_MASTER（UIマスタ）

## 0. 目的
- UIで扱う画面・コンポーネント・入力フィールドを辞書化する
- 導線は UI_SPEC に置く

## 1. 画面一覧（仮）
- SCREEN_ESTIMATE_CREATE
- SCREEN_ESTIMATE_PREVIEW
- SCREEN_INVOICE_CREATE
- SCREEN_RECEIPT_CREATE

## 2. フィールドマッピング（最小テンプレ）
| screen | field | source | required | ui_type | notes |
|---|---|---|---|---|---|
| SCREEN_ESTIMATE_CREATE | docName | BUSINESS_MASTER.doc.estimate.docName | yes | text | 宛名 |
| SCREEN_ESTIMATE_CREATE | docDesc | BUSINESS_MASTER.doc.estimate.docDesc | yes | textarea | 概要 |
| SCREEN_ESTIMATE_CREATE | docPrice | BUSINESS_MASTER.doc.estimate.docPrice | no | number | 金額 |
| SCREEN_ESTIMATE_CREATE | docMemo | BUSINESS_MASTER.doc.estimate.docMemo | no | textarea | メモ |

## 4. 請求（INVOICE）UI 拡張

### 4.1 画面（INVOICE）
- SCREEN_INVOICE_CREATE（請求作成）
- SCREEN_INVOICE_PREVIEW（請求プレビュー）

### 4.2 フィールドマッピング（請求作成：追加）
| screen | field | source | required | ui_type | notes |
|---|---|---|---|---|---|
| SCREEN_INVOICE_CREATE | dueDate | BUSINESS_MASTER.invoice.invoice.dueDate | no | text | 支払期限 |
| SCREEN_INVOICE_CREATE | paymentMethod | BUSINESS_MASTER.invoice.invoice.paymentMethod | no | select | BANK/ON_SITE/OTHER |
| SCREEN_INVOICE_CREATE | bankAccount | BUSINESS_MASTER.invoice.invoice.bankAccount | no | textarea | 振込先（自由記述） |
| SCREEN_INVOICE_CREATE | invoiceStatus | BUSINESS_MASTER.invoice.invoice.invoiceStatus | no | select | DRAFT/ISSUED/PAID |

### 4.3 UI上の最小ルール
- invoiceStatus=DRAFT の場合は docPrice を未確定として扱ってもよい（ただし最終は BUSINESS_SPEC に従う）
- invoiceStatus=ISSUED の場合は、docName/docDesc/docPrice が揃っていることを推奨チェックしてよい

## 5. 領収（RECEIPT）UI 拡張

### 5.1 画面（RECEIPT）
- SCREEN_RECEIPT_CREATE（領収作成）
- SCREEN_RECEIPT_PREVIEW（領収プレビュー）

### 5.2 フィールドマッピング（領収作成：追加）
| screen | field | source | required | ui_type | notes |
|---|---|---|---|---|---|
| SCREEN_RECEIPT_CREATE | receivedDate | BUSINESS_MASTER.receipt.receipt.receivedDate | no | text | 受領日 |
| SCREEN_RECEIPT_CREATE | paymentMethod | BUSINESS_MASTER.receipt.receipt.paymentMethod | no | select | CASH/BANK/OTHER |
| SCREEN_RECEIPT_CREATE | receiptStatus | BUSINESS_MASTER.receipt.receipt.receiptStatus | no | select | DRAFT/ISSUED |

### 5.3 UI上の最小ルール
- receiptStatus=DRAFT の場合：下書きとしてプレビュー可能
- receiptStatus=ISSUED の場合：docName/docDesc/docPrice が揃っていることを推奨チェックしてよい

<!-- ORDER_UI_MASTER_PHASE1 -->
## ORDER（受注）— UI_MASTER（Phase-1）

本節は ORDER（受注）に関する UI 辞書（表示/入力の最小定義）を追加する。
※ orderStatus/STATUS は **業務ロジックが確定**し、UIは表示のみ（手入力で確定/変更しない）。

### Screens（最小）
- SCREEN_ORDER_INTake（受注取り込み）
  - 目的：UF01（raw/通知全文）から受注素材を入力し、登録へ進める
- SCREEN_ORDER_SCHEDULE（予定/担当）
  - 目的：施工予定（scheduledDate/timeSlot）と担当（assignee）を扱う（未確定を許容）
- SCREEN_ORDER_VIEW（閲覧）
  - 目的：OV01 相当の受注閲覧で、状態・予定・メモを確認できる

### Fields（UI表示/入力）
- raw
  - label: 通知全文 / 1行メモ
  - ui: textarea
  - required: true
- name
  - label: お名前
  - ui: text
  - required: false（素材が無い場合を許容）
- phone
  - label: 電話番号
  - ui: tel
  - required: false
- addressFull
  - label: 住所（全文）
  - ui: text
  - required: false
- preferred1 / preferred2
  - label: 希望日
  - ui: datetime/text（運用に合わせる）
  - required: false

- orderStatus
  - label: 状態
  - ui: badge（read-only）
  - rule: UIは決めない（表示のみ）

- scheduledDate
  - label: 施工予定日
  - ui: date
  - required: false（未確定を許容）
- scheduledTimeSlot
  - label: 時間帯
  - ui: select
  - values: AM / PM / EVENING / ANY / TBD
  - default: TBD
- scheduledTimeNote
  - label: 時間補足
  - ui: text
  - required: false

- assignee
  - label: 担当者
  - ui: text/select（運用に合わせる）
  - required: false
- priority
  - label: 優先度
  - ui: select
  - values: NORMAL / HIGH / URGENT
  - default: NORMAL
- intakeChannel
  - label: 入口
  - ui: select
  - values: UF01 / FIX / DOC / OTHER
  - default: UF01
- orderMemo
  - label: 受注メモ
  - ui: textarea
  - required: false
  - rule: HistoryNotes と役割が衝突しない範囲で使用

### Display Rules（最小）
- scheduledTimeSlot=TBD の場合、「時間未確定」を明示して表示する。
- required/optional の表示は UI_PROTOCOL に従う。

<!-- WORK_UI_MASTER_PHASE1 -->
## WORK（施工）— UI_MASTER（Phase-1）

本節は WORK（施工/完了報告）に関する UI 辞書（画面/表示/入力の最小定義）を追加する。
※ “完了確定” は現場タスク完了が起点（master_spec 9章）。UI は完了を任意に確定しない（報告の受付・表示・確認のみ）。

### Screens（最小）
- SCREEN_WORK_REPORT（完了報告）
  - 目的：完了コメント（全文）と写真/動画を添付し、完了報告として送信する
- SCREEN_WORK_CONFIRM（報告確認）
  - 目的：送信前に内容を確認し、二重送信を防止する
- SCREEN_WORK_DONE（報告完了）
  - 目的：受付完了を明示し、次の行動を迷わせない
- SCREEN_WORK_VIEW（閲覧）
  - 目的：完了報告内容（コメント全文・添付）を閲覧できる

### Fields（UI表示/入力）
- workDoneComment
  - label: 完了コメント（全文）
  - ui: textarea
  - required: true
  - helper: 「未使用：BP-..., BM-...」の形式で未使用部材を記載できます（任意）
- photosBefore
  - label: 写真（施工前）
  - ui: uploader（複数）
  - required: false
- photosAfter
  - label: 写真（施工後）
  - ui: uploader（複数）
  - required: false
- photosParts
  - label: 写真（部材）
  - ui: uploader（複数）
  - required: false
- photosExtra
  - label: 写真（追加）
  - ui: uploader（複数）
  - required: false
- videoInspection
  - label: 動画（点検）
  - ui: uploader/url
  - required: false

### Display Rules（最小）
- 送信中はボタン無効化・処理中表示（UI_PROTOCOL 準拠、二重送信防止）。
- 未入力の添付は「未添付」として表示し、責めない文言にする。
- UI は未使用部材の抽出結果を断定表示しない（抽出/確定は業務ロジック側）。

### Error / Warning（最小）
- 必須不足：workDoneComment が空の場合のみエラー表示（他は任意）
- 添付不足（写真不足など）は “警告” として扱い、送信は止めない（管理警告で吸収）

<!-- PARTS_UI_MASTER_PHASE1 -->

<!-- PHASE1_PARTS_UI_MASTER_BLOCK (derived; do not edit meaning) -->
### Phase-1: PARTS UI（表示/導線）— 最小（派生）
参照（唯一の正）：
- master_spec: 7 UF06/UF07 / 3.4 / 3.4.1 / 9
- ui_spec: ALERT_LABELS / REQUEST_LIST_FLOW（表示のみ）

UI責務（固定）：
- 入力補助・表示・導線のみ（確定は業務ロジック／判断権の原則）
- Parts の一覧表示（PART_ID / PART_TYPE / AA/PA/MA / STATUS / PRICE / LOCATION）
- 未確定（PRICE未入力、未納品、LOCATION欠落等）は警告ラベル/導線で可視化（確定はしない）
<!-- END PHASE1_PARTS_UI_MASTER_BLOCK -->
## PARTS（部材）— UI_MASTER（Phase-1）

本節は PARTS（部材：発注/納品/価格入力）に関する UI 辞書（画面/表示/入力の最小定義）を追加する。
※ PRICE/STATUS/区分（BP/BM）の確定は業務ルールが行う。UI は「入力素材の受付」と「確認」を担い、任意に確定しない。

### Screens（最小）
- SCREEN_PARTS_ORDER_CREATE（UF06: 発注入力）
- SCREEN_PARTS_ORDER_CONFIRM（UF06: 発注確認）
- SCREEN_PARTS_ORDER_DONE（UF06: 発注完了）

- SCREEN_PARTS_DELIVER_CREATE（UF06: 納品入力）
- SCREEN_PARTS_DELIVER_CONFIRM（UF06: 納品確認）
- SCREEN_PARTS_DELIVER_DONE（UF06: 納品完了）

- SCREEN_PARTS_PRICE_CREATE（UF07: 価格入力）
- SCREEN_PARTS_PRICE_CONFIRM（UF07: 価格確認）
- SCREEN_PARTS_PRICE_DONE（UF07: 価格完了）

- SCREEN_PARTS_STOCK_LOCATION（在庫ロケーション入力/修正：任意）
  - 目的：STATUS=STOCK の LOCATION 欠落を回収する（欠落は警告対象）

### Fields（共通）
- Order_ID
  - label: 受注ID
  - ui: text
  - required: false（在庫発注を許容：無い場合は STOCK_ORDERED 扱い）
- partType
  - label: 区分
  - ui: select
  - values: BP / BM
  - required: true
- maker
  - label: メーカー
  - ui: text
  - required: false
- modelNumber
  - label: 品番
  - ui: text
  - required: false
- quantity
  - label: 数量
  - ui: number
  - default: 1
  - required: true
- MEMO
  - label: メモ
  - ui: textarea
  - required: false

### UF06: 発注（ORDER）追加Fields
- requestedAt
  - label: 発注日
  - ui: date/datetime
  - required: false

### UF06: 納品（DELIVER）追加Fields
- deliveredAt
  - label: 納品日
  - ui: date/datetime
  - required: true
- LOCATION
  - label: ロケーション（在庫場所）
  - ui: text
  - required: false（ただし STOCK を扱う場合は必須化してよい）
- PRICE
  - label: 価格
  - ui: number
  - required: false
  - rule:
    - BP は納品時に価格確定が必要（未入力は警告）
    - BM は 0（経費対象外）。UI は入力を受け付けてもよいが、業務ルールで 0 に正規化される

### UF07: 価格入力（PRICE）追加Fields
- PART_ID
  - label: 部材ID
  - ui: text
  - required: true
- PRICE
  - label: 価格
  - ui: number
  - required: true
  - rule: BP の未確定価格を補完する（STATUSは原則変更しない）

### Display Rules（最小）
- 必須/任意の表示は UI_PROTOCOL に従う
- 送信中は二重送信防止（ボタン無効化・処理中表示）
- 価格未入力/LOCATION欠落などは “警告” として扱い、送信自体は止めない（管理警告で回収）
- UI は STATUS を任意に編集しない（表示のみ、または非表示でも可）

<!-- EXPENSE_UI_MASTER_PHASE1 -->

<!-- PHASE1_EXPENSE_UI_MASTER_BLOCK (derived; do not edit meaning) -->
### Phase-1: EXPENSE UI（表示/導線）— 最小（派生）
参照（唯一の正）：
- master_spec: 3.6 / 3.6.1 / 9 / 8.4.1
- ui_spec: OV01 表示（参照のみ）

UI責務（固定）：
- 経費（Expense_Master）の表示（EXP_ID / Order_ID / PART_ID / PRICE / USED_DATE）
- 推測計算や確定操作はしない（確定は完了同期）
- PRICE未確定などは警告ラベルで可視化（確定はしない）
<!-- END PHASE1_EXPENSE_UI_MASTER_BLOCK -->
## EXPENSE（経費）— UI_MASTER（Phase-1）

### Screens（最小）
- SCREEN_EXPENSE_CREATE（経費入力）
- SCREEN_EXPENSE_CONFIRM（経費確認）
- SCREEN_EXPENSE_DONE（経費完了）
- SCREEN_EXPENSE_VIEW（閲覧）

### Fields（UI表示/入力）
- Order_ID
  - label: 受注ID
  - ui: text
  - required: true
- PART_ID
  - label: 部材ID（任意）
  - ui: text
  - required: false
- PRICE
  - label: 金額
  - ui: number
  - required: true
  - rule: 推測代入は禁止（確定のみ）
- USED_DATE
  - label: 使用日/支出日
  - ui: date
  - required: true
- MEMO
  - label: メモ
  - ui: textarea
  - required: false

### Display Rules（最小）
- 送信中は二重送信防止（UI_PROTOCOL 準拠）
- 未入力が許容されないのは PRICE/USED_DATE/Order_ID のみ
```


---

### FILE: platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md
- sha256: 51979abeecf2e6388108ab6b63cd296ba9fd5ca4a5575785e3a556ad044d715f
- bytes: 8612

```text
<!--
UI spec is derived from master_spec (CURRENT_SCOPE: Yorisoidou BUSINESS).
NOTE: navigation/positioning only; does NOT change meaning.
RULE: 1 theme = 1 PR; canonical is main after merge.
-->

UI_spec_<業務>.md

業務 UI ― UI 適用仕様（エンドユーザー向け）

※ <業務> は後から具体名（例：水道修理／申込受付 等）に置換する前提のテンプレート確定版です。

1. 対象仕様の概要

本 UI_spec_<業務> は、
エンドユーザーが業務を依頼・入力・確認するための業務 UIに対して、
UI_PROTOCOL に定義された UI 統治・意味仕様を、
特定業務の文脈に適用した結果を記述するものである。

本書は以下を満たす。

本書は UI_PROTOCOL に従属する

本書は 業務 UI 専用の派生文書である

本書は MEP 操作 UI（UI_spec_MEP）とは責務を分離する

本書は UI の原則・状態定義を再定義せず、参照に留める

2. 業務 UI の役割

業務 UI の役割は以下に限定される。

ユーザーに 必要な入力を迷わせずに行わせる

入力途中・未完了状態を 不安なく継続可能にする

処理状態（送信中／確認中／完了）を 誤認させない

業務判断・仕様解釈を ユーザーに要求しない

業務 UI は、
仕様を作らず、業務を進めるための入口である。

3. 画面構成（業務 UI）
3.1 画面種別

入力画面（主画面）

業務に必要な情報を入力する画面

1画面または段階分割（ステップ）形式を許容する

確認画面

入力内容を送信前に確認する画面

編集に戻れる導線を持つ

完了画面

受付・送信が完了したことを示す画面

次にユーザーが取るべき行動を示す

4. 入力項目の意味配置

## Request入力の整合チェック（UI制約｜意味変更なし）

本UIは、master_spec 3.7.2 の PayloadJSON 共通ルールに従い、入力の矛盾を作らない。

- targetType / targetId は必須（master_spec 3.7.2）
- UF07（価格申請）の場合：
  - targetType = PART_ID
  - partId は必須
  - **partId と targetId は同値**（矛盾は送信不可）
- UF08（追加報告）の場合：
  - targetType = Order_ID
  - orderId は必須
  - **orderId と targetId は同値**（矛盾は送信不可）
4.1 入力項目の原則

ユーザーが 意味を理解できない専門語を使わない

入力理由が暗黙に理解できる順で並べる

「必須／任意」は UI_PROTOCOL の原則に従って表示する

4.2 入力補助

例文・プレースホルダーは
正解例ではなく記述の方向性を示す

未入力によるエラーは
責めない文言で示す

5. 操作順序（業務 UI の標準フロー）

入力画面を表示

業務情報を入力

確認画面で内容を確認

送信処理を実行

完了画面を表示

※ 操作順序は強制ではないが、
本順序を基準とする。

6. 状態と表示の関係
6.1 処理中表示

送信・確認処理中は、
処理中であることを明示する

二重送信を誘発する操作は表示しない

6.2 完了表示

業務が「受理された」ことのみを示す

内部処理や判断結果を断定的に示さない

7. 業務 UI における表示文言
7.1 入力開始時

必要な情報を入力してください。
途中で保存・中断することもできます。

7.2 入力中

入力内容はまだ送信されていません。
必要に応じて修正してください。

7.3 処理中

送信処理を行っています。
完了するまでお待ちください。

7.4 入力不備時

入力内容に不足があります。
該当箇所をご確認ください。

7.5 完了時

送信が完了しました。
受付内容を確認のうえ、後ほどご連絡します。

8. MEP との責務境界

業務 UI は 業務入力の受付までを担当する

業務仕様化・判断・生成は MEP 側の責務とする

業務 UI は master_spec を直接編集しない

9. 本書の更新ルール

本書は 業務 UI の仕様変更時にのみ更新する

MEP 内部仕様の変更により更新されることはない

UI_PROTOCOL の変更を伴う修正は行わない

UI 実装は、本書との差分として管理される

以上で、UI_spec_<業務>.md（業務 UI 用テンプレート）の生成を完了します。

## DOC_FLOWS（参照のみ）

本 ui_spec は「表示／導線（ナビゲーション）」のみを扱い、
見積・請求・領収の **業務上の意味／必須条件／状態遷移** は定義しない。

DOC系の業務定義（唯一の正）は master_spec を参照する：
- platform/MEP/03_BUSINESS/よりそい堂/master_spec
  - 10.3 DOC（書類リクエスト）
  - 10.4 DOC系ステータスと導線（見積／請求／領収｜業務定義）

## ALERT_LABELS（表示／導線のみ）

本節は「管理警告ラベル」を UI 上でどこにどう表示するかの導線を定義する。
業務上の意味・判定・列挙は master_spec が唯一の正であり、本 ui_spec は再定義しない。

参照（唯一の正）：
- platform/MEP/03_BUSINESS/よりそい堂/master_spec
  - 8.4 管理警告（業務要件）
  - 8.4.1 管理警告ラベル（固定｜監督UIの表示根拠）
  - 11.1.1 写真不足フラグの根拠
  - 11.1.2 違和感素材フラグ（signals）

表示位置（推奨・固定）：
1) 管理タスク（監督UI）
- タスク名や本文の上部に「警告ラベル」を一覧表示する。
- 表示は短いラベル（例：PHOTO_INSUFFICIENT / ADDRESS_VARIANCE 等）を基本とし、必要なら日本語補足を併記する。
- 複数ラベルがある場合は並列表示し、優先順位は UI で強制しない（監督判断）。

2) OV01（閲覧カルテ）
- 健康スコア付近、または概要セクションに「警告ラベル」を一覧表示する。
- ラベルクリック（または展開）で、該当する根拠（写真不足／signals種別）への説明表示へ遷移してよい。

表示ルール（固定）：
- UI はラベルを“確定”しない。業務ロジックが確定したラベルを表示するのみ。
- 未確定（判定不能）の場合はラベルを出さない。曖昧さは REVIEW 申請導線へ誘導する。

導線（固定）：
- ALERT_REQUEST_PENDING_* がある場合は、申請一覧（Request）への導線を表示してよい。
- ALERT_PHOTO_INSUFFICIENT がある場合は、写真セクション（before/after）への導線を表示してよい。
- ADDRESS_VARIANCE / TIME_ANOMALY / TEXT_ANOMALY / PARTS_INCONSISTENCY がある場合は、
  “違和感素材” セクション（signals一覧）への導線を表示してよい。

## REQUEST_LIST_FLOW（表示／導線のみ）

本節は「未処理申請（RequestStatus=OPEN）」の一覧へ導く導線を定義する。
業務上の意味・判定・状態遷移は master_spec が唯一の正であり、本 ui_spec は再定義しない。

参照（唯一の正）：
- platform/MEP/03_BUSINESS/よりそい堂/master_spec
  - 3.7 Request（申請台帳）
  - 3.7.3 RequestStatus（OPEN/RESOLVED/CANCELLED）
  - 3.7.4 ResolutionMetadata（ResolvedAt等）
  - 8.4.1 管理警告ラベル（ALERT_REQUEST_PENDING_*）
  - 9.4 健康スコア（D: RequestStatus=OPEN）

表示・導線（固定）：
1) 管理タスク（監督UI）
- ALERT_REQUEST_PENDING_FIX / ALERT_REQUEST_PENDING_REVIEW が存在する場合、
  「未処理申請（OPEN）」一覧へのリンク（またはボタン）を表示してよい。
- 一覧は “RequestStatus=OPEN のみ” を表示対象とする（未処理の定義は master_spec に従属）。

2) OV01（閲覧カルテ）
- 健康スコア付近、または警告ラベル付近に「未処理申請（OPEN）」への導線を表示してよい。
- クリックで “未処理申請一覧（OPEN）” へ遷移し、該当 Order_ID でフィルタしてよい（表示のみ）。

UIの禁止事項（固定）：
- UI は RequestStatus を確定しない（OPEN/RESOLVED/CANCELLED の判断は業務ロジック）。
- UI は “勝手に解決扱い（RESOLVED/CANCELLED）” にしない。
- 未確定（判定不能）の場合は、一覧導線を出して “監督判断” に寄せる。

<!-- PHASE1_MARKERS (do not change meaning; for Go/No-Go checks only) -->
<!-- PARTS_FLOW_PHASE1 -->
<!-- EXPENSE_FLOW_PHASE1 -->
```


---

### FILE: platform/MEP/90_CHANGES/CHANGELOG.md
- sha256: 6bc9c570650d84195afea5b1f71c7356865bd833b4ddcf12fdedddace9e3e08d
- bytes: 12

```text
# CHANGELOG
```


---

### FILE: platform/MEP/90_CHANGES/CURRENT_SCOPE.md
- sha256: e49fac4916c90902c7ae6e4bdc1218b7750d32ac577875af481c13776ba596da
- bytes: 6396

```text
﻿# CURRENT_SCOPE（唯一の正：変更範囲の許可リスト）

## 変更対象（Scope-IN）
- .github/workflows/required_checks_drift_guard_manual.yml
- platform/MEP/03_BUSINESS/よりそい堂/**
- platform/MEP/90_CHANGES/CURRENT_SCOPE.md
- .github/workflows/scope_guard_pr.yml
- .github/workflows/business_packet_guard_pr.yml
- .github/workflows/self_heal_auto_prs.yml
- .github/workflows/chat_packet_update_schedule.yml
- .github/workflows/chat_packet_self_heal.yml
- docs/MEP/**
- .github/workflows/*.yml
- platform/MEP/01_CORE/_SCOPE_SUGGEST_FORCE_20260103-135009.txt
- platform/MEP/90_CHANGES/_SCOPE_SUGGEST_DOD_20260103-072904.txt
- tools/mep_handoff.ps1
- tools/mep_idea_capture.ps1
- tools/mep_idea_list.ps1
- tools/mep_idea_pick.ps1
- tools/mep_idea_finalize.ps1
- tools/mep_idea_receipt.ps1
- tools/mep_chat_packet_min.ps1
- tools/mep_pwsh_guard.ps1
- tools/mep_autopilot.ps1
- tools/mep_integration_compiler/collect_changed_files.py
- tools/mep_integration_compiler/runtime/__init__.py
- tools/mep_integration_compiler/runtime/__pycache__/__init__.cpython-314.pyc
- tools/mep_integration_compiler/runtime/__pycache__/cli.cpython-314.pyc
- tools/mep_integration_compiler/runtime/__pycache__/idempotency.cpython-314.pyc
- tools/mep_integration_compiler/runtime/__pycache__/recovery_queue.cpython-314.pyc
- tools/mep_integration_compiler/runtime/__pycache__/request_linkage.cpython-314.pyc
- tools/mep_integration_compiler/runtime/cli.py
- tools/mep_integration_compiler/runtime/idempotency.py
- tools/mep_integration_compiler/runtime/recovery_queue.py
- tools/mep_integration_compiler/runtime/request_linkage.py
- tools/mep_integration_compiler/runtime/README_B2_LEDGER.md
- tools/mep_integration_compiler/runtime/__pycache__/ledger_cli.cpython-314.pyc
- tools/mep_integration_compiler/runtime/__pycache__/ledger_recovery_queue.cpython-314.pyc
- tools/mep_integration_compiler/runtime/ledger_cli.py
- tools/mep_integration_compiler/runtime/ledger_recovery_queue.py
- tools/mep_integration_compiler/runtime/README_B3_REQUEST.md
- tools/mep_integration_compiler/runtime/__pycache__/ledger_request.cpython-314.pyc
- tools/mep_integration_compiler/runtime/__pycache__/ledger_request_cli.cpython-314.pyc
- tools/mep_integration_compiler/runtime/ledger_request.py
- tools/mep_integration_compiler/runtime/ledger_request_cli.py
- tools/mep_integration_compiler/runtime/tests/README_B4_E2E.md
- tools/mep_integration_compiler/runtime/tests/b4_csv_e2e.py
- tools/mep_integration_compiler/runtime/README_B5_LEDGER_ADAPTER.md
- tools/mep_integration_compiler/runtime/__pycache__/ledger_adapter.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/__init__.py
- tools/mep_integration_compiler/runtime/adapters/__pycache__/__init__.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/__pycache__/csv_adapter.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/csv_adapter.py
- tools/mep_integration_compiler/runtime/ledger_adapter.py
- tools/mep_integration_compiler/runtime/README_B6_SHEETS_ADAPTER.md
- tools/mep_integration_compiler/runtime/adapters/__pycache__/sheets_adapter_skeleton.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/sheets_adapter_skeleton.py
- tools/mep_integration_compiler/runtime/tests/README_B7_ADAPTER_E2E.md
- tools/mep_integration_compiler/runtime/tests/__pycache__/b7_adapter_e2e.cpython-314.pyc
- tools/mep_integration_compiler/runtime/tests/b7_adapter_e2e.py
- tools/mep_integration_compiler/runtime/README_B8_SHEETS_SCHEMA_CHECK.md
- tools/mep_integration_compiler/runtime/adapters/__pycache__/sheets_schema_check.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/__pycache__/sheets_schema_check_cli.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/sheets_schema_check.py
- tools/mep_integration_compiler/runtime/adapters/sheets_schema_check_cli.py
- tools/mep_integration_compiler/runtime/tests/__pycache__/b8_schema_check.cpython-314.pyc
- tools/mep_integration_compiler/runtime/tests/b8_schema_check.py
- tools/mep_integration_compiler/runtime/README_B9_SHEETS_READONLY_BOUNDARY.md
- tools/mep_integration_compiler/runtime/adapters/__pycache__/sheets_header_fetcher.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/sheets_header_fetcher.py
- tools/mep_integration_compiler/runtime/tests/__pycache__/b9_sheets_readonly_boundary.cpython-314.pyc
- tools/mep_integration_compiler/runtime/tests/b9_sheets_readonly_boundary.py
- tools/mep_integration_compiler/runtime/README_B10_HTTP_HEADER_PROVIDER.md
- tools/mep_integration_compiler/runtime/adapters/__pycache__/http_header_provider.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/__pycache__/http_header_provider_cli.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/http_header_provider.py
- tools/mep_integration_compiler/runtime/adapters/http_header_provider_cli.py
- tools/mep_integration_compiler/runtime/tests/__pycache__/b10_http_provider_parse.cpython-314.pyc
- tools/mep_integration_compiler/runtime/tests/b10_http_provider_parse.py
- tools/mep_integration_compiler/runtime/README_B12_HTTP_WRITE_CLIENT.md
- tools/mep_integration_compiler/runtime/adapters/__pycache__/http_write_client.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/__pycache__/http_write_client_cli.cpython-314.pyc
- tools/mep_integration_compiler/runtime/adapters/http_write_client.py
- tools/mep_integration_compiler/runtime/adapters/http_write_client_cli.py
- tools/mep_integration_compiler/runtime/tests/__pycache__/b12_http_write_import.cpython-314.pyc
- tools/mep_integration_compiler/runtime/tests/b12_http_write_import.py
## 非対象（Scope-OUT｜明示）
- platform/MEP/01_CORE/**
- platform/MEP/00_GLOBAL/**

## 判断が必要な点（YES/NO）
- なし（必要が生じた場合のみ追記して停止する）
# scope-guard registration test 20260103-000927

## Scope Guard 互換書式（固定）
- Scope Guard は本ファイルの「## 変更対象（Scope-IN）」見出し直下の「- 」箇条書きのみを機械抽出する。
- Scope-IN には glob を使用できる（例：platform/MEP/03_BUSINESS/**）。
- 見出し名の変更、箇条書き形式の変更（番号付き等）は禁止。
- 例外運用を行う場合も、必ず Scope-IN に明示し、PR差分で実施する。
<!-- CI_TOUCH: 2026-01-03T02:01:49 -->
```


