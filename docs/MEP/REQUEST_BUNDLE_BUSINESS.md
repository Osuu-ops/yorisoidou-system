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
- included_total_bytes: 247073

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
- sha256: 113f1212ccc48525ac3c409bb34309ab8dcd9a4f6061375b16f06d67071caabf
- bytes: 12731

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
- 最短は docs/MEP/CHAT_PACKET.md を貼る（1枚で開始できる）。
- CHAT_PACKET が無い場合は、本書（START_HERE）を貼って開始する。

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
- Text Integrity Guard (PR): enabled
- Halfwidth Kana Guard: enabled
- UTF-8/LF stabilization: enabled (.gitattributes/.editorconfig)

## Current objective
- Build and refine Yorisoidou BUSINESS master_spec and UI spec under the above scope.

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
# PROCESS（手続き） v1.1

## 目的
本書は、GitHub上で「迷わず同じ結果になる」最小手順をテンプレとして固定する。
新チャットでは原則 INDEX だけを貼り、追加が必要な場合のみ AI_BOOT の REQUEST 形式で要求する。

---

## 基本原則（必須）

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
- sha256: 1e885f3a3b06293b0c6c832b9f27ab62cfe74920f2a0e210dd43840834662c98
- bytes: 755

```text
﻿# STATE_CURRENT (MEP)

## Doc status registry（重複防止）
- docs/MEP/DOC_REGISTRY.md を最初に確認する (ACTIVE/STABLE/GENERATED)
- STABLE/GENERATED は原則触らない（目的明示の専用PRのみ）

## CURRENT_SCOPE (canonical)
- platform/MEP/03_BUSINESS/よりそい堂/**

## Guards / Safety
- Text Integrity Guard (PR): enabled
- Halfwidth Kana Guard: enabled
- UTF-8/LF stabilization: enabled (.gitattributes/.editorconfig)

## Current objective
- Build and refine Yorisoidou BUSINESS master_spec and UI spec under the above scope.

## How to start a new conversation
Tell the assistant:
- "Read docs/MEP/START_HERE.md and proceed."
- (If memory=0 / new chat) paste CHAT_PACKET_MIN first (tools/mep_chat_packet_min.ps1 output).
```


---

### FILE: docs/MEP/STATE_SUMMARY.md
- sha256: 3187521f37da5680b73612b5d2acb52406d7292ed61740022da049fa05f0562c
- bytes: 2107

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
- sha256: 25383cbd2e8a54509e0ef93ecbde24fc6a71ced0630c2029d00774fb0a8551a9
- bytes: 11248

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

### 目的
- 施工（WORK）を「受注（Order_ID）に紐づく現場作業の実行・完了報告」として定義し、
  完了同期（台帳確定・経費確定・在庫戻し）へ繋ぐ。

### 入力入口（不変）
- 現場の完了報告は「現場タスクの完了（完了コメント全文）」が唯一の正（master_spec 9章）。
- 施工の途中経過は、運用上のメモとして残してよいが、台帳確定のトリガーではない。

### 最小データ（業務要件）
- workDoneAt（完了日時）
- workDoneComment（完了コメント全文：未使用部材記載を含み得る）
- photosBefore / photosAfter / photosParts / photosExtra（任意：不足は管理警告）
- videoInspection（任意）
- workSummary（任意：要約の作り込みで業務判断を置換しない）

### 完了コメント規約（抽出）
- 未使用部材は、以下の書式で列挙できること（master_spec 9.3 準拠）：
  例）未使用：BP-YYYYMM-AAxx-PAyy, BM-YYYYMM-AAxx-MAyy
- 抽出結果は在庫戻し（STATUS=STOCK）へ利用される（LOCATION 整合が必須）

### 完了時に起きる業務（概要）
- Order の完了日時・状態更新・最終同期日時の更新
- DELIVERED 部材の USED 化、EX/Expense の確定、未使用部材の STOCK 戻し
- 不備（価格未入力/写真不足/LOCATION不整合 等）は管理警告対象

### 禁止事項
- 人/AI/UI が Order の STATUS/orderStatus を任意に確定/変更してはならない
- 完了同期の代替として、別経路で台帳を確定させてはならない

<!-- PARTS_SPEC_PHASE1 -->

<!-- PHASE1_PARTS_SPEC_BLOCK (derived; do not edit meaning) -->
### Phase-1: PARTS（部材）— 業務最小定義（派生）
参照（唯一の正）：
- master_spec: 3.4 Parts_Master / 3.4.1 Parts STATUS / 6 部材体系 / 7 UF06/UF07 / 9 完了同期

最小目的：
- 部材（BP/BM）の発注→納品→使用→在庫の追跡を、Order_ID と PART_ID で破綻なく再現する。

業務状態（固定）：
- STOCK / ORDERED / DELIVERED / USED / STOCK_ORDERED

最小トリガー（固定）：
- UF06（発注確定）: ORDERED または STOCK_ORDERED（Order_ID有無で判定）
- UF06（納品確定）: DELIVERED（DELIVERED_AT 記録）
- UF07（価格入力）: PRICE 確定（状態は原則維持）
- 完了同期（現場完了起点）: DELIVERED の対象を USED へ（使用確定）
- 未使用部材コメント抽出: STOCK 戻し（LOCATION 整合必須）

不変条件（固定）：
- BP は納品時に PRICE を確定（未確定は警告対象）
- BM は PRICE=0（経費対象外）
- LOCATION は STATUS=STOCK の部材で必須
<!-- END PHASE1_PARTS_SPEC_BLOCK -->
## PARTS（部材）— BUSINESS_SPEC（Phase-1）

### 目的
- 部材（PARTS）を「発注→納品→使用→在庫」の工程で追跡可能な業務として定義する。
- 受注（Order_ID）と部材（PART_ID/OD_ID/AA/PA/MA）を正しく接続し、完了同期で経費確定へ繋ぐ。

### 入力入口（不変）
- UF06（発注/納品）が工程の主入口（master_spec 7章）
- UF07（価格入力）は BP の価格未確定を補完する入口（master_spec 7.3）
- 価格/区分/状態の“確定”は業務ルールに従い、人/AI/UI が任意に決めない

### 部材区分（BP/BM）
- BP（メーカー手配品）
  - 納品時に PRICE を確定する（未確定は警告）
- BM（既製品/支給品等）
  - PRICE=0（経費対象外）
- BP/BM の区分変更は危険修正（申請/FIX）に分類し、直接確定しない

### 主要IDと接続（要点）
- PART_ID：部材の貫通ID（BP/BM体系）
- AA：部材群の永続番号（タスク名へ反映）
- PA/MA：枝番（BP=PA, BM=MA）
- OD_ID：同一受注内の発注行補助ID
- 接続の中心は Order_ID（受注）
  - Order_ID の無い発注は STOCK_ORDERED として扱う（在庫発注）

### STATUS（部材状態：固定）
- STOCK / ORDERED / DELIVERED / USED / STOCK_ORDERED
- 変更は工程イベントにより行う（発注/納品/完了同期）
- 人/AI/UI が任意に書き換えない

### LOCATION（在庫ロケーション）
- STATUS=STOCK の部材は LOCATION を必須とする（欠落は管理警告）
- 未使用部材の STOCK 戻しでも LOCATION 整合が必須

### 発注（UF06: ORDER）業務（概要）
- 採用行のみを発注として確定する
- 確定結果：
  - PART_ID/OD_ID 発行
  - STATUS=ORDERED（Order_ID 無しの場合は STOCK_ORDERED）
  - BP は PRICE 未定、BM は PRICE=0

### 納品（UF06: DELIVER）業務（概要）
- 確定結果：
  - STATUS=DELIVERED
  - DELIVERED_AT 記録
  - BP は PRICE 入力必須（納品時確定）
  - LOCATION 記録（在庫・管理に必要）
  - AA群を抽出し、現場タスク名へ反映する

### 価格入力（UF07）業務（概要）
- BP の PRICE 未入力を補完し、業務として価格を確定する
- 部材STATUSは原則変更しない（価格確定のみ）
- 価格未確定は管理警告の対象

### 完了同期との関係（要点）
- 現場完了により、DELIVERED 部材が USED 化され、EX/Expense が確定される
- 未使用部材は STOCK 戻し（LOCATION 整合必須）

### 禁止事項
- ID の再利用/改変、AA 再発番
- PRICE の推測代入
- STATUS の任意変更
- LOCATION 欠落の放置（警告として扱い、管理で回収）

<!-- EXPENSE_SPEC_PHASE1 -->

<!-- PHASE1_EXPENSE_SPEC_BLOCK (derived; do not edit meaning) -->
### Phase-1: EXPENSE（経費）— 業務最小定義（派生）
参照（唯一の正）：
- master_spec: 3.6 Expense_Master / 3.6.1 Expense確定 / 9 完了同期 / 8.4.1 警告

最小目的：
- USED（使用確定）になった BP の PRICE を根拠に、確定経費として一意に記録する。

確定トリガー（固定）：
- 完了同期（現場完了起点）でのみ確定（作成/追記）

対象範囲（固定）：
- BP（メーカー手配品）: PRICE確定が前提（未確定は警告）
- BM: PRICE=0（経費対象外／経費に入れない）

不変条件（固定）：
- 推測代入は禁止（PRICEは確定値のみ）
- 既存Expenseの削除は禁止（履歴保全）
<!-- END PHASE1_EXPENSE_SPEC_BLOCK -->
## EXPENSE（経費）— BUSINESS_SPEC（Phase-1）

### 目的
- 経費（EXPENSE）を「確定した支出記録」として保持し、受注（Order_ID）へ接続する。
- 経費の“確定”は推測ではなく、確定入力（または完了同期で確定されたUSED部材）に限定する。

### 入力入口（不変）
- 完了同期により USED 部材の PRICE が経費として確定される（master_spec 9章 / Expense_Master）
- 手動の経費追加は、確定情報（領収/金額/日付/対象）を入力できる入口（運用/将来UI）
- 推測代入は禁止

### 最小データ（業務要件）
- EXP_ID（経費ID：月内連番、再利用不可）
- Order_ID（接続キー）
- PART_ID（関連部材がある場合）
- PRICE（確定金額）
- USED_DATE（使用/支出日）
- CreatedAt（記録日時）

### 禁止事項
- PRICE 推測代入
- EXP_ID 再発番/再利用
- Order_ID 無しの経費混在（例外運用をする場合は別途定義して停止）
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
- sha256: 5ee72b1ea6454c530373dd3bef5f994d73f2e6e53c7bfae3f242d7a78f3e360e
- bytes: 572

```text
﻿<!--
ENTRY GUIDE ONLY (DO NOT PUT THE FULL SPEC HERE)
CANONICAL CONTENT: platform/MEP/03_BUSINESS/よりそい堂/master_spec
-->

# master_spec.md（入口・案内専用）

このファイルは **入口（案内）**です。本文（唯一の正）は次です：

- **唯一の正（実体）**：platform/MEP/03_BUSINESS/よりそい堂/master_spec（拡張子なし）

## 編集ルール（固定）
- 仕様の本文を編集する場合は **必ず master_spec を編集**する
- master_spec.md は案内・要点・手順のみ（本文は置かない）
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
- sha256: 5e5ad98bb7355ab079b243bb2dc95d4de9e8a5aa4d3f43b9709ab3e4b2efb3e2
- bytes: 1580

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


