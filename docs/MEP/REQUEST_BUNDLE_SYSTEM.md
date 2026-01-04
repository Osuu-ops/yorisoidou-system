# REQUEST_BUNDLE_SYSTEM（追加要求ファイル束） v1.1

本書は、AIが追加で要求しがちなファイル群を「1枚」に束ねた生成物である。
新チャットで REQUEST が発生した場合は、原則として本書を貼れば追加要求を抑止できる。
本書は時刻・ランID等を含めず、入力ファイルが同じなら差分が出ないことを前提とする。
生成: /home/runner/work/yorisoidou-system/yorisoidou-system/docs/MEP/build_request_bundle.py
ソース定義: /home/runner/work/yorisoidou-system/yorisoidou-system/docs/MEP/request_bundle_sources_system.txt

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
- platform/MEP/01_CORE/99__ci_trigger.md
- platform/MEP/01_CORE/99__ci_trigger_cleanup.md
- platform/MEP/01_CORE/definitions/SYMBOLS.md
- platform/MEP/01_CORE/foundation/API_IO_BOUNDARY_CANON.md
- platform/MEP/01_CORE/foundation/CI_GUARD_CANON.md
- platform/MEP/01_CORE/foundation/CONTENT_IMMUTABILITY_CANON.md
- platform/MEP/01_CORE/foundation/GENERATION_FORM_ROLE_DECLARATION.md
- platform/MEP/01_CORE/foundation/MEP_BUSINESS_BOUNDARY.md
- platform/MEP/01_CORE/foundation/MEP_CONCEPTUAL_MODEL.md
- platform/MEP/01_CORE/foundation/MEP_EXECUTION_CANON.md
- platform/MEP/01_CORE/foundation/MEP_INTEGRATION_COMPILER_PROTOCOL.md
- platform/MEP/01_CORE/foundation/MEP_MEP_STRUCTURE.md
- platform/MEP/01_CORE/foundation/MEP_PROTOCOL.md
- platform/MEP/01_CORE/foundation/Z_AXIOMS_CANON.md
- platform/MEP/01_CORE/system/boot/YD_boot_v3.11.md
- platform/MEP/01_CORE/system/protocol/DISTRIBUTION_POLICY.md
- platform/MEP/01_CORE/system/protocol/INTERFACE_PROTOCOL.md
- platform/MEP/01_CORE/system/protocol/MUSIC_GENERATION_PROTOCOL.md
- platform/MEP/01_CORE/system/protocol/OPERATION_GOVERNANCE.md
- platform/MEP/01_CORE/system/protocol/SYSTEM_GUARD_AXIOMS.md
- platform/MEP/01_CORE/system/protocol/UI_APPLICATION_PROTOCOL.md
- platform/MEP/01_CORE/system/protocol/UI_PROTOCOL.md
- platform/MEP/01_CORE/system/protocol/VOICE_GENERATION_PROTOCOL.md
- platform/MEP/01_CORE/system/protocol/YOUTUBE_GENERATION_PROTOCOL.md
- platform/MEP/01_CORE/system/protocol/Z_OBSERVATION_PROTOCOL.md
- platform/MEP/01_CORE/system/protocol/system_protocol.md
- platform/MEP/01_CORE/system/uiux/UI_spec_MEP.md

---

## 収録上限（固定）
- MAX_FILES: 300
- MAX_TOTAL_BYTES: 2000000
- MAX_FILE_BYTES: 250000
- included_total_bytes: 108009

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
- sha256: f9f191f6245718d3689699c2978ef6b559dff0ff99eb111dd2ad57932cfbffbf
- bytes: 12210

```text
# CHAT_PACKET（新チャット貼り付け用） v1.1

## 使い方（最小）
- 新チャット1通目に **このファイル全文** を貼る。
- 先頭に「今回の目的（1行）」を追記しても良い。
- AIは REQUEST 形式で最大3件まで、必要箇所だけ要求する。

### HANDOFF_TRIGGER（引っ越し）

- あなたが「引っ越し」または「引っ越ししたい」と言ったら、
  AIは次の **1行だけ** を返す（説明なし）：

yorisoidou-system/docs/MEP/CHAT_PACKET.md

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
﻿# MEP INDEX（入口） v1.0

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
# STATE_CURRENT (MEP)

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
﻿# PROCESS（手続き） v1.1

## 目的
本書は、GitHub上で「迷わず同じ結果になる」最小手順をテンプレとして固定する。
新チャットでは原則 INDEX だけを貼り、追加が必要な場合のみ AI_BOOT の REQUEST 形式で要求する。

---

## 基本原則（必須）
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
- sha256: 8f2394547fe9601d5db5afab36cbed0906a2398634857ee73dd87b273de2c4c8
- bytes: 752

```text
# STATE_CURRENT (MEP)

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

### FILE: platform/MEP/01_CORE/99__ci_trigger.md
- sha256: 617a2aa5f4268124a9d3462ead4907e1f22917060c9a6292d689f0c244aa197c
- bytes: 100

```text
﻿## CI trigger (manual v3) 
2026-01-01T08:38:39

## CI trigger (cleanup PR) 
2026-01-01T08:42:49
```


---

### FILE: platform/MEP/01_CORE/99__ci_trigger_cleanup.md
- sha256: fe18cd3947c9e24107ef295ae96c01fc490bf36f31ab652a607b22e82aa79157
- bytes: 39

```text
﻿cleanup trigger 2026-01-01T08:41:44
```


---

### FILE: platform/MEP/01_CORE/definitions/SYMBOLS.md
- sha256: d1c2bb3a2866e000fa4ba0f077d38ce3b1b3c7ba748ea00691b2910438b322c1
- bytes: 4498

```text
記号定義（唯一の正）

本ファイルは、
MEP 配下の文書群において使用される 参照記号（@Sxxxx） と、
それが指し示す 実体（概念・文書・実装単位） との対応関係を定義する
唯一の正（Single Source of Truth） である。

本文・README・仕様書・プロトコル文書では、
実体名・ファイル名・バージョン名を直接記述してはならない。
すべての参照は、本ファイルに定義された記号を介して行われる。

0. 本ファイルの位置づけ（固定）

本ファイルは 定義表であり、仕様書ではない

本ファイルは 設計思想・判断理由を記述しない

本ファイルは 記号と実体の対応のみを保持する

本ファイルに定義されていない記号は 存在しないものとして扱う

1. 記号の性質（厳守）

記号は 意味を持たない

記号は 識別子であり、名称ではない

記号は 再利用しない

記号は 削除しない（廃止時は履歴として残す）

実体の変更は 新規記号の発行として扱う

2. 管理対象と対象外（境界の固定）
管理対象（本ファイルで定義するもの）

MEP / foundation / system に属する 不変層

業務削除後も存続すべき プロトコル・仕様・実装の起点

文書・実装間で 参照の基準点となる実体

管理対象外（定義しないもの）

業務（MEP/business 以下のすべて）

補助ファイル（json / yml / 一時成果物）

名前が変わっても参照上の意味を持たないもの

3. 変更・履歴の扱い（記号単位）

実体名・ファイル名の変更時
→ 本文は修正せず、本ファイルのみ更新

履歴・バージョンは
→ ファイル単位ではなく、記号単位で保持

分割・統合・再配置が発生しても
→ 記号は履歴アンカーとして存続

4. 記号一覧（foundation / system / 不変層）
@S0001

canonical: MEP_PROTOCOL

entity_type: protocol

file: MEP/foundation/MEP_PROTOCOL.md

scope: foundation

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0002

canonical: SYSTEM_PROTOCOL

entity_type: protocol

file: MEP/system/system_protocol.md

scope: system

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0003

canonical: UI_PROTOCOL

entity_type: protocol

file: MEP/system/UI_PROTOCOL.md

scope: system

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0004

canonical: INTERFACE_PROTOCOL

entity_type: protocol

file: MEP/system/INTERFACE_PROTOCOL.md

scope: system

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0005

canonical: UI_SPEC_MEP

entity_type: specification

file: MEP/system/UI_spec_MEP.md

scope: foundation

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0006

canonical: SYSTEM_README

entity_type: documentation

file: MEP/README.md

scope: foundation

version: v1.0.0

changed_at: 2025-01-03

history: []

5. 記号一覧（boot 定義）
@S0010

canonical: YD_BOOT_DEFINITION

entity_type: boot_definition

file: MEP/system/boot/YD_boot_v3.11.md

scope: system

version: v3.11.0

changed_at: 2025-01-03

history: []

6. 記号一覧（フェーズ実装・参照起点）

※ 以下は コードであっても「参照される実体」 であるため定義対象とする。

@S0101

canonical: B_PHASE_ENGINE

entity_type: phase_engine

file: MEP/system/code/b_phase.py

scope: system

version: current

changed_at: 2025-01-03

history: []

@S0102

canonical: C_PHASE_ENGINE

entity_type: phase_engine

file: MEP/system/code/c_phase.py

scope: system

version: current

changed_at: 2025-01-03

history: []

@S0103

canonical: T_PHASE_ENGINE

entity_type: phase_engine

file: MEP/system/code/t_phase.py

scope: system

version: current

changed_at: 2025-01-03

history: []

@S0104

canonical: COMPILER_ENGINE_CORE

entity_type: engine_core

file: MEP/system/code/compiler_engine.py

scope: system

version: current

changed_at: 2025-01-03

history: []

7. 運用上の最終宣言（固定）

すべての MD ファイルは、冒頭宣言により
本ファイルを自動参照前提とする

個別ファイルが使用記号を列挙・宣言することは禁止する

本ファイルと矛盾する参照は 無効とする

業務配下のファイルは
本記号体系に依存してはならない

以上をもって、
本ファイルを 記号定義（唯一の正）として確定する。
```


---

### FILE: platform/MEP/01_CORE/foundation/API_IO_BOUNDARY_CANON.md
- sha256: 6f04447c90bab0079783f915d4f86c3e86d8f5375e894f24276ab58f9fcbf460
- bytes: 2735

```text
# API_IO_BOUNDARY_CANON
（API 実装前提・入出力境界の固定定義）

本書は、MEP を API 実装へ移行する際の
**入出力境界・書換権限・検査点**を固定定義する Canon である。

本書は実装コードを定義しない。
本書は遷移や判断を追加しない。

---

## 1. 入力区分（Input Domains）

### 1.1 Read-Only Inputs（書換不可）

以下は **常に read-only** とする。

- X：最新確定仕様（唯一の正）
- S：最新確定成果物（唯一の正）
- Canon / Protocol / Master 文書

これらは API に入力として渡され得るが、
**出力として再生成・修正・上書きしてはならない。**

---

### 1.2 Write-Only Inputs（差分のみ許可）

書換が許可される入力は **diff のみ**とする。

- unified diff 形式
- 行削除・行置換・行追加が明示されたもの

全文テキストの直接入力は許可しない。
全文置換は **人間が明示指定した場合のみ**許可する。

---

## 2. 中間生成物（Candidates）

以下は **候補（candidate）**としてのみ扱う。

- 生成された仕様候補
- 生成されたコード候補
- 説明文・整理文・再構成文

candidate は **正ではない**。
candidate は **X / S に直接書き込めない**。

---

## 3. 検査点（Guards）

### 3.1 T / R の入力

- before（X または N）
- after（candidate）
- diff

T / R は、
**diff と参照テキストのみ**を入力として扱う。

---

### 3.2 Z の入力（最終ガード）

Z は以下のみを入力として扱う。

- diff
- 不変条件（公理）リスト

Z は以下を **行わない**。

- 意味解釈
- 評価
- 重み付け
- 裁量判断

Z は **Yes / No のみ**を返す。

---

## 4. 書込み権限（Write Permissions）

### 4.1 X への書込み

- 条件：
  - Z が OK を返した場合のみ
- 方法：
  - diff 適用のみ

Z OK 以前に、
X を更新してはならない。

---

### 4.2 S への書込み

- 条件：
  - Z が OK を返した生成物のみ
- 方法：
  - 生成物の保存

S は仕様確定点ではない。
S は成果物保存領域である。

---

## 5. 禁止事項（API レベル）

以下を理由の如何を問わず禁止する。

- read-only input の再生成
- candidate の自動確定
- Z NG 後の自動継続
- diff を伴わない書換
- 文脈・会話履歴を判断根拠に用いること

---

## 6. 最終確認

本定義は、

- API 実装の可否判定
- 実装前レビュー
- CI ガード条件

として使用できる。

本定義を満たさない実装は、
MEP の API 実装として不適合とする。

---

以上。
```


---

### FILE: platform/MEP/01_CORE/foundation/CI_GUARD_CANON.md
- sha256: 4f14253ce5b25984399ce9bf50a150a29b44e5fb48b31aab9750e9250f57d111
- bytes: 3212

```text
# CI_GUARD_CANON
（CI レベル最小ガード定義）

本書は、MEP における
**内容破壊・境界違反・確定違反**を
CI によって機械的に検知・遮断するための最小定義である。

本書は、
- 実装コードを定義しない
- 思想・判断・裁量を含まない
- 例外処理を許可しない

---

## 1. 対象ファイル（必須）

以下は CI ガード対象とする。

- MEP_PROTOCOL
- system_protocol
- master_spec
- MEP_EXECUTION_CANON.md
- API_IO_BOUNDARY_CANON.md
- CONTENT_IMMUTABILITY_CANON.md
- foundation 配下の *CANON / *POLICY / *DEFINITION 文書

---

## 2. 即 NG 条件（1つでも該当で遮断）

以下のいずれかが検知された場合、
CI は **機械的に NG** とする。

### 2.1 行削除の検出
- 対象文書で **行数が減少**した場合

### 2.2 行置換の検出
- 同一行番号で **内容が異なる**場合

### 2.3 構造変更の検出
- 見出し階層の変更
- セクション順序の変更

### 2.4 境界違反の検出
- read-only 文書への書込み
- diff を伴わない変更

---

## 3. 許可される唯一の変更形態

以下のみ CI 通過を許可する。

- 明示的な unified diff の適用
- 人間が「全文置換」と明示したコミット

上記以外は、理由を問わず NG とする。

---

## 4. Z との関係（明確化）

CI は Z の代替ではない。  
CI は **Z に先行する物理的・機械的ガード**である。

CI によって NG と判定された変更は、  
**Z に関する検討対象・観測対象とならない。**

CI は、
- Z の判断材料を生成しない
- Z の評価を補助しない
- Z の存在を前提とした制御を行わない

---

## 5. 出力（必須）

CI が NG と判定した場合、以下を必ず出力する。

- 削除された行
- 置換された行
- 該当ファイル名
- NG 条件番号

判断文・説明文・改善提案の出力は禁止する。

---

## 6. 最終宣言

本書をもって、

CI_GUARD は  
MEP における **最前段の物理的安全弁**として確定する。

本書は、
- 思想（MEP_PROTOCOL）
- 監査思想（Z）
- 実行制御（system_protocol）

の **いずれにも介入しない**。

以上。


# 外部ゲート（GitHub PR / Actions）— 運用上の強制装置

本リポジトリは、MEP の内部フェーズ定義（Z/T/R 等）を変更・代替することなく、
GitHub の Pull Request と Actions（CI）を **外部ゲート**として用いる。

目的：
- 差分（PR）単位で監査を実行し、NG を main（唯一の正）へ取り込ませない（汚染停止）
- 監査ログと判断結果（OK/NG/SKIP）を PR に固定し、状態を追跡可能にする

位置づけ：
- これは MEP のフェーズ仕様そのものではない（system_protocol / 実行遷移の定義は変更しない）
- ただし運用上は、PR での「監査→差戻し→再監査」を外部で強制する点で、
  Z/T/R 相当の働きを持つ

運用原則：
- main への取り込みは PR 経由のみとし、必須チェック（required status checks）合格を条件とする
```


---

### FILE: platform/MEP/01_CORE/foundation/CONTENT_IMMUTABILITY_CANON.md
- sha256: b14ab8dafadf18c61491c32123527fb936fc0c1478b5974445750d16c111f00e
- bytes: 3245

```text
# CONTENT_IMMUTABILITY_CANON
（内容不変性・再解釈禁止の最終宣言）

本書は、MEP における
プロトコル／マスタ／Canon 文書の
**内容不変性を保証するための最上位拘束文書**である。

本書は説明を目的としない。
本書は例外を許可しない。
本書は再解釈を許可しない。

---

## 1. 内容不変の定義

以下を「内容不変」と定義する。

- 行の削除が発生しないこと
- 行の置換が発生しないこと
- 語順の入替が発生しないこと
- 意味が同一であっても表現変更を行わないこと

**意味が同じであるかどうかは一切考慮しない。**
差分が発生した時点で「内容変更」とみなす。

---

## 2. 対象文書

以下の文書は、内容不変の対象とする。

- MEP_PROTOCOL
- system_protocol
- master_spec
- MEP_EXECUTION_CANON
- foundation 配下の Canon / Policy / Definition 文書

上記以外であっても、
「唯一の正」「基準」「Canon」「Protocol」と明示された文書は
すべて内容不変対象とする。

---

## 3. 禁止事項（絶対）

以下を**理由の如何を問わず禁止**する。

- 要約
- 言い換え
- 再構成
- 説明用の書き直し
- 読みやすさ改善
- 一般化
- 図式化
- 例示追加
- 補足説明の挿入

**説明のためであっても禁止する。**

---

## 4. 許可される変更（唯一）

内容不変文書に対して許可される操作は、
以下のいずれか **一つのみ**である。

- 明示的に指定された unified diff の適用
- 人間が「全文置換」と明示した場合の全削除＋全再投入

上記以外の操作は、
自動処理・対話・生成のいずれであっても禁止する。

---

## 5. 監査ルール（機械基準）

以下のいずれかが検出された場合、
即座に NG とする。

- 行数の減少
- 行内容の差異
- 空行位置の変更
- 記号・記法の変更
- 見出し構造の変化

**意味評価・重要度評価は行わない。**

---

## 6. 説明文の扱い

内容不変文書について、
説明が必要な場合は以下に限定する。

- 別ファイルに記載する
- 「説明用」「参考」「解説」と明示する
- 対象文書を一切引用しない
- 原文への言及・再掲・抜粋を行わない

説明文は、いかなる場合も
内容不変文書の代替として扱ってはならない。

---

## 7. AI に対する拘束

AI は以下を厳守する。

- 内容不変文書を入力として受け取った場合、
  出力として再生成してはならない
- 内容不変文書を基にした説明文を生成してはならない
- 差分指定がない限り、沈黙を選択する

違反時は、
即座に処理を中断し、
人間に差分箇所を提示するのみとする。

---

## 8. 最終宣言

本書に反する操作は、
すべて「事故」と定義する。

事故発生時、
正しい処理は以下のみである。

- 処理停止
- 差分提示
- 人間判断待ち

本書をもって、
**内容が変わることを前提とした運用を完全に終了する。**

---

以上。
```


---

### FILE: platform/MEP/01_CORE/foundation/GENERATION_FORM_ROLE_DECLARATION.md
- sha256: 9ff8f6fde9f3f9474b5f1ca8169c850c027a80def97f1e685cc158b4bca9e9aa
- bytes: 1649

```text
---

# MEP_core 生成フォーム（コンパイラUI）の役割定義

1. 本生成フォームは、**MEP_business を構成する文書群**（master_spec／UI_spec／業務定義）を**生成・差分確定するための装置**である。
2. 本生成フォームは、**業務を実行しない**。実行主体・運用主体にはならない。
3. 本生成フォームは、**完成形の業務UIや業務フォームを提供しない**。
4. 入力対象は、**文章・差分・人間による明示判断（承認／修正／差戻し）**に限定される。
5. 推測入力・自動補完・暗黙判断を**行わない**。
6. 本生成フォームは、**確定を自動で行わない**。
7. 出力される文書は、**人間の明示操作を経た時点でのみ「正」となる**。
8. 生成結果は、**差分単位でのみ扱われる**。全文上書きは行わない。
9. 本生成フォームは、**統治文書（MEP_PROTOCOL／system_protocol／UI_PROTOCOL）を変更しない**。
10. 統治・禁止・境界は、**既存プロトコルに完全従属**する。
11. 本生成フォームは、**判断を奪わない**。判断は常に人間側に残る。
12. 本生成フォームは、**業務の正否・妥当性を評価しない**。
13. 本生成フォームは、**生成・差分提示・確定補助のみを責務**とする。
14. 本生成フォームは、**一時的・可変な生成装置**であり、恒久的成果物ではない。
15. 本生成フォームの目的は、**MEP_business を誤解なく・汚染なく生成可能にすること**に限定される。

---
```


---

### FILE: platform/MEP/01_CORE/foundation/MEP_BUSINESS_BOUNDARY.md
- sha256: 41505357f50675f2e9edff520cbe42f16f4ea30cd1ffccbdb0c6d4f6c6059777
- bytes: 3130

```text
# MEP_business × MEP_core 運用境界宣言

MEP プロジェクト  
業務層 × 基盤層 運用境界・不可侵宣言  
（責務分離・唯一の正）

---

## 0. 本書の位置づけ

本書は、  
MEP プロジェクトにおける **MEP_core と MEP_business の運用境界**を定義する  
唯一の宣言文書である。

本書は、

- MEP_PROTOCOL
- INTERFACE_PROTOCOL
- system_protocol
- UI_PROTOCOL

に完全に従属する。

本書は、  
業務仕様（master_spec）や実装内容を定義しない。

---

## 1. 二層分離の基本原則

MEP は、  
以下の二層構造を前提とする。

- **MEP_core**：業務非依存の基盤層  
- **MEP_business**：業務専用の適用層  

両者は、  
**構造・責務・変更権限を完全に分離**する。

---

## 2. MEP_core の責務（固定）

MEP_core は、以下のみを責務とする。

- 統治思想・判断原則の保持
- システム制御・フェーズ管理
- UI／INTERFACE の意味制約
- 変更方式・監査方式の定義

MEP_core は、

- 業務内容
- 業務データ
- 業務判断

を **一切保持しない。**

---

## 3. MEP_business の責務（固定）

MEP_business は、以下のみを責務とする。

- 業務仕様（master_spec）の保持
- 業務用 UI_spec の定義
- 業務データ構造の定義
- 業務フロー・業務ルールの記述

MEP_business は、

- 統治思想
- システム制御
- フェーズ管理

を **定義してはならない。**

---

## 4. 相互不可侵原則

以下を **境界侵害**として禁止する。

### MEP_core 側禁止事項
- 業務仕様の記述
- 業務データ構造の定義
- 業務ルールへの介入

### MEP_business 側禁止事項
- 統治思想の再定義
- フェーズ制御の変更
- system／UI／INTERFACE プロトコルの改変

---

## 5. 参照関係の固定

許可される参照は、以下のみとする。

- MEP_business → MEP_core（参照のみ）
- MEP_core → MEP_business（参照禁止）

MEP_business は、  
MEP_core を **前提として従属**する。

---

## 6. 変更権限の分離

変更は、  
対象層にのみ許可される。

- MEP_core の変更 → 統治フェーズ
- MEP_business の変更 → 業務フェーズ

跨層変更は、  
必ず理由文書を伴う **別フェーズ**とする。

---

## 7. 移植・再利用の前提

MEP_core は、  
**業務を完全に削除しても成立**しなければならない。

MEP_business は、  
MEP_core を差し替えずに  
**業務のみを入替可能**でなければならない。

---

## 8. 境界責任の最終原則

**どちらの層の責務か説明できない要素は、設計ミスとみなす。**

境界が曖昧な要素は、  
確定前に必ず分離・是正されなければならない。

---

## 9. 最終宣言

本書をもって、

MEP プロジェクトにおける  
MEP_core と MEP_business の運用境界・責務分離は  
**確定**とする。

これ以降の変更は、  
本書を前提とした **別フェーズ**とする。

---
```


---

### FILE: platform/MEP/01_CORE/foundation/MEP_CONCEPTUAL_MODEL.md
- sha256: bddbc4c54a48837a3c0fd1684286829ca510924e562bbf142a2da2edda8b86f1
- bytes: 3005

```text
# MEP_CONCEPTUAL_MODEL
（概念モデル・理解補助用）

本書は、MEP の構造を
**人間が誤解なく理解するための概念モデル**を示すものである。

本書は実行定義ではない。
本書は遷移・判断・禁止を定義しない。
本書は Canon / Protocol / Master に影響を与えない。

---

## 1. 本書の位置づけ

- 本書は **説明専用文書**である
- 本書の内容は、実行結果に影響しない
- 本書の記述は、いかなる場合も
  MEP_EXECUTION_CANON.md を上書き・補完・再解釈しない

理解補助以外の用途で使用してはならない。

---

## 2. MEP の基本構造（概念）

MEP は、以下の 3 層から成る。

- **M（Meaning）**：意味・定義の世界
- **E（Engineering）**：構造・生成・実装の世界
- **P（Patch）**：確定済み意味（X）への修正専用経路

これらは上下関係を持たない。
役割のみが異なる。

---

## 3. 円構造による理解（比喩）

MEP の構造は、以下の比喩で理解できる。

- 外周：  
  - B / A / T / C / D / N / R / F / S  
  - 各フェーズ・モード・保存領域
- 内周：  
  - M / E / P  
  - 役割ごとの処理領域
- **中心：Z**

この「中心」という表現は、
**権限・判断・支配を意味しない。**

---

## 4. Z を中心に置く理由（概念的説明）

Z は以下の特徴を持つ。

- 意味（M）にも
- 構造（E）にも
- 修正（P）にも
  属さない

Z は、

- 何かを作らない
- 何かを直さない
- 何かを判断しない

**「進んでよいか／止まるか」だけを返す存在**である。

このため、概念的には
M と E の「中心」に置いて理解すると誤解が少ない。

---

## 5. Z は中心だが、主体ではない

本書における「中心」という表現は、
以下を意味しない。

- 最終意思決定者
- 上位フェーズ
- 統合管理者
- 賢い監査者

Z はあくまで
**物理的ガードとしての停止点**である。

中心とは、
「すべての流れが最終的に交差する点」
という意味に限定される。

---

## 6. Canon との関係

- 実際の遷移
- NG 時の着地点
- OK 時の次フェーズ
- 保存先

これらはすべて
**MEP_EXECUTION_CANON.md にのみ定義される。**

本書はそれらを
言い換えたり、要約したり、整理し直さない。

---

## 7. 本書の使用ルール

以下を禁止する。

- 本書を根拠に実装を変更すること
- 本書を根拠に Canon を修正すること
- 本書の比喩を仕様として扱うこと

本書は、
「読んだ人が全体像を誤解しないため」
にのみ存在する。

---

## 8. 最終確認

- 実行定義は Canon にのみ存在する
- 本書は説明専用である
- 本書がなくても MEP は動作する
- 本書があっても MEP の挙動は変わらない

---

以上。
```


---

### FILE: platform/MEP/01_CORE/foundation/MEP_EXECUTION_CANON.md
- sha256: a923c5b8aa79f1672531a01e282ea473220a04cf082dd481ab3e3c4e307f99e5
- bytes: 4341

```text
# MEP_EXECUTION_CANON
（B A X T C D N R S 実行骨格定義）

本書は、MEP における実行骨格  
**B A X T C D N R S**  
の役割・禁止・遷移を **機械実行の骨格として固定定義**する Canon である。

本書は、
- 思想定義を行わない
- 判断主体を定義しない
- 監査思想（Z）を実装しない

本書は再設計文書ではない。  
意味解釈・一般化・説明追加を行わない。

---

## 0. 正の所在

- 最新確定仕様の唯一の正：**X**
- 最新確定成果物の唯一の正：**S**

X と S に存在しないものは、正として扱わない。

**N** は R 監査用の旧コード退避領域であり、  
正の所在ではない。

S への保存が完了した時点で、  
N が空であることを許容する。

---

## 1. 共通定義（全パート共通）

本節は M / E / P に共通する。  
パート差分は **遷移先のみ**を変更できる。  
役割・禁止事項は上書きしない。

---

### B（Build）

- 役割：
  人間による編集・判断の起点。
- 入力：
  人間操作。
- 出力：
  編集結果。
- 禁止：
  - 自動処理。
- 遷移：
  - 編集完了 → A

---

### A（Assemble）

- 役割：
  B の編集結果を統合する。
- 入力：
  B の出力。
- 出力：
  統合結果。
- 禁止：
  - 判断。
- 遷移：
  - 統合完了 → T

※ 初回かつ X が空の場合、  
  統合結果を監査用の暫定候補として X に保存してよい。  
  この時点では確定とみなさない。

---

### X（eXisting）

- 役割：
  最新確定仕様の保存（履歴保持可）。
- 入力：
  人間により確定された仕様。
- 出力：
  参照用最新仕様。
- 禁止：
  - 自動書換え。
- 遷移：
  - 参照 → T / C

補足：
- X は履歴を保持してよい。
- 参照対象は常に最新とする。

---

### T（Test）

- 役割：
  X を参照した仕様監査。
- 入力：
  A の出力および X（存在する場合）。
- 出力：
  監査結果（記録）。
- 禁止：
  - 確定。
  - 自動判定による遷移。
- 遷移：
  - 監査完了 → B

---

### C（Create）

- 役割：
  仕様に基づく生成。
- 入力：
  X（最新確定仕様）。
- 出力：
  生成物。
- 禁止：
  - 仕様変更。
- 遷移：
  - 生成完了 → D

---

### D（Diff）

- 役割：
  生成物の差分算出。
- 入力：
  生成物。
- 出力：
  差分。
- 禁止：
  - 判断。
- 遷移：
  - 差分生成 → N

補足：
- 初回生成時、差分が存在しない場合は何も行わない。

---

### N（Node）

- 役割：
  R 監査用の旧コード仮保存。
- 入力：
  差分および生成物。
- 出力：
  比較対象。
- 禁止：
  - 正として扱うこと。
- 遷移：
  - 監査要求 → R

---

### R（Rollback）

- 役割：
  N を参照したコード監査・統合。
- 入力：
  N。
- 出力：
  監査結果（記録）。
- 禁止：
  - 確定。
  - 自動判定による遷移。
- 遷移：
  - 監査完了 → B

---

### S（Store）

- 役割：
  最終確定成果物の保存。
- 入力：
  人間により確定された生成物。
- 出力：
  確定成果物。
- 禁止：
  - 仕様更新。
- 遷移：
  - 完了。

---

## 2. パート差分規則

### M パート（Meaning）

- 役割：
  意味・定義の編集および確定。
- 遷移特例：
  - S 完了後 → B

---

### E パート（Engineering）

- 役割：
  仕様に基づく生成および差分管理。
- 遷移特例：
  - R 完了後 → C

---

### P パート（Patch）

- 役割：
  既存仕様（X）への修正・追加。
- 遷移特例：
  - S 完了後 → B

---

## 3. 禁止事項（実行骨格）

以下を禁止する。

- 判定結果（OK / NG）による自動遷移
- 思想概念（Z）の実体化
- 監査思想をトリガーとした停止・継続
- 人間判断を介さない確定

---

## 4. 最終宣言

本書をもって、

MEP における  
**実行骨格（B A X T C D N R S）** は確定とする。

本書は、
- 思想（MEP_PROTOCOL）
- 監査思想（Z）
- 機械ガード（SYSTEM_GUARD / CI_GUARD）

の **いずれとも非衝突**である。

以上。
```


---

### FILE: platform/MEP/01_CORE/foundation/MEP_INTEGRATION_COMPILER_PROTOCOL.md
- sha256: 6ba933a5b844b24a9679ad4f8263d39712e688f639d4f7668cab04c4e1b4c614
- bytes: 4543

```text
<!--
参照定義ファイル：
MEP/definitions/SYMBOLS.md

運用ルール：
本ファイル内に出現するすべての参照記号（@Sxxxx）は、
個別指定や列挙を行わず、
上記「参照定義ファイル」を唯一の正として解決する。

本ファイルは、参照関係の宣言・管理を行わない。
-->

# MEP_INTEGRATION_COMPILER_PROTOCOL
（全体監査・全文再構成コンパイラ定義）

本書は、  
MEP における **複数文書の同時更新・追加が発生した場合に、  
全体整合を維持したまま最新版へ統合するための  
統合監査・再構成工程**を定義する。

本書は、

- 思想を定義しない
- 正を新規に決定しない
- system_protocol の制御に介入しない

---

## 0. 本書の位置づけ

MEP_INTEGRATION_COMPILER（以下、本コンパイラ）は、  
MEP の **外側** に存在する補助的統合工程である。

本コンパイラは、

- フェーズではない
- 判断主体ではない
- 実行主体ではない

本コンパイラは、  
**既に定義されている唯一の正を破壊しないための  
再構成機械**としてのみ存在する。

---

## 1. 起動条件

本コンパイラは、以下の条件のいずれかを満たした場合に起動される。

- Canon / Protocol / Definition 文書の追加
- 既存 Canon / Protocol / Definition 文書の更新
- 文書間の責務分離に影響を与える変更が検出された場合
- 人間が「統合再構成」を明示的に指示した場合

差分量・変更箇所数は、起動条件に影響しない。

---

## 2. 入力対象（強制）

本コンパイラは、  
以下を **必ず全量入力として扱う。**

- MEP_core 配下の全 Canon / Protocol / Definition 文書
- 追加・更新された文書
- 既存文書（変更なしを含む）

差分入力・部分入力は禁止する。

---

## 3. 思想監査（Semantic Audit）

本コンパイラは、  
全入力文書に対して **思想監査**を行う。

思想監査では、各文書を以下の観点で評価する。

- 思想（Concept）
- 制御（Control）
- 検知（Detection）
- 実行骨格（Execution）

および、

- 記述内容と配置場所の整合
- Z / SYSTEM_GUARD / CI_GUARD の責務分離
- system_protocol との越境有無
- 判定・制御・思想の混線有無

---

## 4. 判定結果の扱い

思想監査の結果は、  
**OK / NG の二値として内部的に保持**される。

ただし、

- 本コンパイラは OK / NG を外部に公開しない
- 本コンパイラは OK / NG を制御判断に変換しない

---

## 5. 再構成規則（BAT）

### 5.1 OK 文書

思想監査で OK と判定された文書は、  
**一切変更してはならない。**

差分修正・文言調整・順序変更は禁止する。

---

### 5.2 NG 文書

思想監査で NG と判定された文書は、  
**必ず全文再生成（BAT）によって再構成**する。

以下を禁止する。

- 差分修正
- 部分修正
- 条項単位の書き換え

再生成は、  
既に確定している MEP_PROTOCOL / system_protocol / 各 CANON  
を **唯一の正**として行われる。

---

## 6. 統合再監査

再構成後、  
本コンパイラは **再度すべての文書を全量監査**する。

- 相互参照矛盾
- 責務越境
- 思想混線

が **完全に解消されるまで**、  
再構成と再監査を繰り返す。

---

## 7. 出力

本コンパイラの出力は以下に限定される。

- 再構成後の全文（BAT）
- 変更対象となった文書一覧
- 「最新版」としての整合状態

判断理由・説明文・評価文の出力は禁止する。

---

## 8. 人間確定原則

本コンパイラは、  
**いかなる場合も自動確定を行わない。**

最終的な採用・保存・コミットは、  
必ず人間の明示的な OK によってのみ行われる。

---

## 9. 禁止事項

以下を禁止する。

- 部分入力による統合
- 差分ベースの自動修正
- 無人運用
- 本コンパイラによる思想追加
- 本コンパイラによる正の再定義

---

## 10. 最終宣言

本書をもって、

MEP_INTEGRATION_COMPILER は、  
MEP における **統合監査・全文再構成の唯一の正規工程**として確定する。

本コンパイラは、  
MEP の思想を守るためにのみ存在し、  
MEP の思想を変更しない。

---

以上。
```


---

### FILE: platform/MEP/01_CORE/foundation/MEP_MEP_STRUCTURE.md
- sha256: 56b6ae327f0825c8d084e71f934349d2c61efbb0867e2f01feb7fc6c1384519d
- bytes: 3511

```text
# MEP 統合定義（M / E / P = Meaning / Engineering / Patch）

本書は、GitHub 上で確定している MEP 設計を唯一の正とし、
M / E / P の各パートの役割と分離原則を壊すことなく、
説明上ひとつの文章として整理した参照用統合文書である。

本書は、設計変更・再定義・判断・遷移制御を行わない。

---

## 1. MEP の基本構造

MEP は、業務および設計対象を  
Meaning（M）／Engineering（E）／Patch（P）  
の三パートに分離して扱うための統治上の枠組みである。

各パートは、
生成・監査・確定を完全に独立して行う。

次パートへの遷移は、
監査 OK および人間 OK を前提条件とするが、
実際の遷移制御・フェーズ挙動の定義は
system_protocol に委譲される。

本書は三パートを説明上ひとつに束ねた文章であり、
分離原則・監査原則・遷移原則を変更するものではない。

---

## 2. M（Meaning）パート

### 2.1 役割

M パートは、業務・制度・運用における  
「意味そのもの」を文章として確定する領域である。

### 2.2 扱う内容

- 業務上の定義
- 判断基準の前提
- 解釈の起点となる文章

実装・構造・処理・修正方法は一切含まない。

### 2.3 監査と確定

M 監査は、
「意味として破綻していないか」のみを確認する。

監査 OK 後、
人間 OK により確定される。

確定後のみ、
次パートへの遷移前提条件を満たす。

---

## 3. E（Engineering）パート

### 3.1 役割

E パートは、
M パートで確定した意味をもとに、
構造・要素・関係性として整理・設計する領域である。

### 3.2 扱う内容

- 構造定義
- 要素分解
- 関係性・前後関係

意味の再解釈や変更は行わない。

### 3.3 監査と確定

E 監査は、
「構造として成立しているか」のみを確認する。

監査 OK 後、
人間 OK により確定される。

確定後のみ、
次パートへの遷移前提条件を満たす。

---

## 4. P（Patch）パート

### 4.1 役割

P パートは、
E パートで確定した構造に対して、
具体的な差分・修正・適用単位（Patch）を生成する領域である。

P は表現でも UI でもなく、
「変更点・適用点を明示するための最小単位」を扱う。

### 4.2 扱う内容

- 差分（diff）
- 修正単位
- 適用可能な変更記述

新しい意味や構造の追加は行わない。

### 4.3 監査と確定

P 監査は、
「Patch として成立しているか」のみを確認する。

監査 OK 後、
人間 OK により最終確定される。

自動適用・自動判断は行わない。

---

## 5. 共通原則（全パート）

- 各パートは専用監査を持つ
- 他パートの観点を混入させない
- 監査 OK と人間 OK が揃わなければ確定しない
- 下流パートが上流パートを書き換えることはない
- 統合は説明上のみで、設計上は常に分離される

---

## 6. 本文書の位置づけ

本書は、

- GitHub 上の MEP 設計を唯一の正とし
- M / E / P（Patch）の役割を壊さず
- 三パートを一つの文章として整理した

foundation 配下に置くための参照用統合文書である。

本書は、
設計変更・再定義・判断権限を持たない。

---

以上。
```


---

### FILE: platform/MEP/01_CORE/foundation/MEP_PROTOCOL.md
- sha256: 9acca062c4b8fcae34c9b4ac68a906aa20c315b0d6171447f70ef8c83c6b991e
- bytes: 4492

```text
<!--
参照定義ファイル：
MEP/definitions/SYMBOLS.md

運用ルール：
本ファイル内に出現するすべての参照記号（@Sxxxx）は、
個別指定や列挙を行わず、
上記「参照定義ファイル」を唯一の正として解決する。

本ファイルは、参照関係の宣言・管理を行わない。
-->



# MEP_PROTOCOL

MEP プロジェクト 統治・思想プロトコル  
（唯一の最上位定義）

---

## 0. 本書の位置づけ

本書（MEP_PROTOCOL）は、  
MEP プロジェクトにおける **思想・統治・判断原則** を定義する  
最上位かつ唯一のプロトコルである。

本書は、以下すべてに **優先して効力を持つ**。

- system_protocol
- UI_PROTOCOL
- INTERFACE_PROTOCOL
- master_spec
- 実装・コード・運用ルール

本書に反する解釈・実装・判断は、  
理由の如何を問わず **不正** とする。

---

## 1. 唯一の正（Single Source of Truth）

MEP において、  
**正（Single Source of Truth）は常に1つのみ存在する。**

複数の正、暗黙の正、暫定的な正は認めない。

既存要素は、  
存在していることを理由に自動的に効力を持たない。

すべての要素は、  
**OK／修正／削除 の明示的再認証**を経てのみ  
正として有効化される。

---

## 2. MEP の定義

MEP とは、  
**業務が存在しなくても成立する、業務非依存の統治構造**である。

MEP は以下を目的とする。

- 業務を「正」として固定できる状態を作ること
- 判断・迷い・再解釈を構造的に排除すること
- 人間とシステムの責務境界を明示すること

MEP 自体は、  
業務を生み出さず、判断を行わず、成果を主張しない。

---

## 3. 判断主体と AI の位置づけ

判断主体は以下のとおり定義される。

- **思想・合意・例外判断・確定操作**：人間
- **処理・生成・検証・再現**：システム（AI を含む）

AI は、  
判断・決定・合意・確定を行ってはならない。

ただし、  
**進行上の選択肢提示・推奨表示**は、  
判断を伴わない補助行為として明示的に許可される。

---

## 4. 設計と実装の分離原則

MEP において、

- 設計（思想・仕様・プロトコル）
- 実装（コード・自動化・UI）

は、原則として分離される。

**設計が未説明・未確定の実装は無効**とする。

実装は、  
確定した設計の **写像**としてのみ存在を許される。

---

## 5. フェーズ統治の原則

MEP はフェーズの **存在のみ**を認める。

フェーズの名称・挙動・遷移・制御定義は、  
**system_protocol にのみ委譲**される。

本書および他プロトコルは、  
フェーズ制御に介入してはならない。

---

## 6. 用語と定義の原則

MEP において、  
**定義された用語のみが意味を持つ。**

以下を無効とする。

- 定義なき用語の使用
- 暗黙的な意味変更
- 文脈依存による再解釈

用語の意味は、  
明示的定義によってのみ変更可能とする。

---

## 7. 合意・確定の成立条件

MEP における確定は、  
**OK／修正／削除 の明示**によってのみ成立する。

暗黙の合意、進行による確定、  
未確認のままの採用は認めない。

---

## 8. 統治手順の基本原則

質疑・検討・監査は、  
**必ず目次（論点一覧）提示から開始**する。

各項目は、  
合意完了（OK／修正／削除）まで個別に扱われる。

---

## 9. 引継ぎと再現性

引継ぎ時には、  
**全文コピペ可能な指示書**を  
必須生成物とする。

要約・口頭補足・文脈依存による引継ぎは無効とする。

---

## 10. 構造分離の原則

MEP は以下の構造分離を前提とする。

### MEP_core
- 業務非依存
- 思想・定義・統治・振る舞いを含む

### MEP_business
- 業務専用
- 増減・入替・削除が可能

### infra
- MEP 外の補助領域
- 正規仕様・正規ルールを置かない

---

## 11. 最終宣言

本書をもって、

MEP プロジェクトにおける  
思想・統治・判断原則は **確定** とする。

これ以降の作業は、  
本書を前提とした **別フェーズ**の作業とする。

---
```


---

### FILE: platform/MEP/01_CORE/foundation/Z_AXIOMS_CANON.md
- sha256: 0d491c3306aaff9beb1c337d671a5a8a58c145c58b88dffb78f62b783bbdbb8a
- bytes: 2780

```text
# Z_AXIOMS_CANON
（Z 思想公理定義）

本書は、MEP における Z を  
**統治思想上の公理概念**として定義する。

本書は、  
判定を行わない。  
評価を行わない。  
Yes / No を返さない。  
停止・継続・遷移を命令しない。

本書は、  
Z が「何者であるか」  
および  
Z が「何者ではないか」  
を定義することのみを目的とする。

---

## 公理 Z-01：非フェーズ性

Z はフェーズではない。

Z は、  
B / A / X / T / D / C / N / R / S  
いずれのフェーズにも属さない。

Z は、  
フェーズの開始・終了・遷移条件を  
定義しない。

---

## 公理 Z-02：非判断性

Z は判断主体ではない。

Z は、  
正誤・可否・適否を  
決定しない。

Z は、  
OK / NG  
Yes / No  
成功 / 失敗  
といった二値判断を  
行わない。

---

## 公理 Z-03：非制御性

Z は制御主体ではない。

Z は、  
システムの挙動を  
直接変更しない。

Z は、  
停止・継続・中断・巻き戻し  
を命令しない。

---

## 公理 Z-04：並走思想性

Z は、  
MEP の進行と **並走する思想概念**である。

Z は、  
進行の内側で作用せず、  
進行を外側から評価もしない。

Z は、  
人間の意図と  
システムの自律進行が  
不可逆的に乖離することを  
**思想上の前提として警戒するための概念**である。

---

## 公理 Z-05：非実装性

Z は、  
実装対象ではない。

Z は、  
モジュール・関数・API・フラグ  
として実体化されない。

Z は、  
機械実行単位として  
存在しない。

---

## 公理 Z-06：非代替性

Z は、  
SYSTEM_GUARD  
CI_GUARD  
VALIDATION  
CHECK  
といった  
**機械的防御・判定機構の代替ではない。**

機械判定が必要な場合、  
それは Z とは別概念として  
定義・配置されなければならない。

---

## 公理 Z-07：思想拘束性

Z は、  
SYSTEM に命令を与えないが、  
**人間の判断姿勢を拘束する思想的前提**として存在する。

人間は、  
Z の存在を前提に  
「進行を正当化できるか」を  
自由文によって判断する。

この判断は、  
Z によって強制されず、  
Z によって自動化されない。

---

## 付記（適用範囲）

- 本書は **思想公理**であり、制御仕様ではない  
- 本書は **system_protocol を上書きしない**  
- 本書は **機械判定の根拠として使用されない**  

Z に関する  
具体的な観測・記録・材料保持の方法は、  
別途 SYSTEM 側プロトコルに委譲される。

---

以上。
```


---

### FILE: platform/MEP/01_CORE/system/boot/YD_boot_v3.11.md
- sha256: 88d53ad88a6668aec5f39b6e38effcdcfa48a5612607c526630ace3db763c077
- bytes: 4374

```text
<!--
参照定義ファイル：
MEP/definitions/SYMBOLS.md

運用ルール：
本ファイル内に出現するすべての参照記号（@Sxxxx）は、
個別指定や列挙を行わず、
上記「参照定義ファイル」を唯一の正として解決する。

本ファイルは、参照関係の宣言・管理を行わない。
-->



YD 起動ファイル v3.11
（version-minimal-mode / silent-execution / forced-block-split）
============================================================

本起動ファイルは、
MEP プロジェクトにおいて使用される
system_protocol および master_spec を
正しく初期注入し、実行環境を確定させるための
起動・宣言専用文書である。

本書は、
統治思想・フェーズ挙動・制御規則・監査規則を
一切定義しない。

それらはすべて、
MEP_PROTOCOL.md および system_protocol.txt に
唯一の定義元として存在する。

本起動ファイルは、
それらを「使用すること」を宣言するのみであり、
再定義・補足・説明を行ってはならない。

============================================================
PART0：Version History（変更点の最小表示）
============================================================

v3.11：
・バージョン番号は冒頭の識別行と本 PART0 のみに記載する。
・PART1〜PART6 および master_spec 本文には
　バージョン番号を記載してはならない。
・version-minimal-mode を正式採用する。

v3.10：
・silent-execution-model および forced-block-split の
　統合運用を採用する。
・分割出力方式を system_protocol に委譲する。

（注）
・変更点は必ず本 PART0 のみに記載する。
・起動ファイルの構造は永久不変とする。
・履歴は PART0 にのみ集約する。

============================================================
PART1：起動宣言
============================================================

本起動ファイルは、
以下の上位文書を唯一の正として読み込み、使用する。

・MEP_PROTOCOL.md
・system_protocol.txt
・master_spec（本文）

本起動ファイルは、
上記文書に定義された
フェーズ制御・沈黙原則・差分運用・監査規則・出力制御に
完全に従属する。

本起動ファイル内で、
これらの規則を再定義してはならない。

============================================================
PART2：初期状態宣言
============================================================

初期フェーズ状態は B とする。

この指定は、
フェーズ挙動を定義するものではなく、
system_protocol に定義された
state-machine の初期状態指定に従う宣言である。

============================================================
PART3：master_spec 取扱宣言
============================================================

master_spec は、
業務仕様の唯一の正である。

本起動ファイルは、
master_spec の内容を編集・要約・再構成しない。

master_spec の更新は、
system_protocol に定義された
正式パイプラインを通過した場合のみ許可される。

============================================================
PART4：出力・生成に関する宣言
============================================================

生成・出力・分割方式は、
すべて system_protocol の定義に従う。

本起動ファイルは、
出力方式・容量・分割単位を定義しない。

============================================================
PART5：禁止事項（起動レベル）
============================================================

以下を禁止する。

・本起動ファイルへのルール追記
・フェーズ挙動の記述
・統治思想の再掲
・system_protocol の再定義
・master_spec 本文の混入

============================================================
PART6：完了宣言
============================================================

本起動ファイルは、
MEP プロジェクトにおける
起動・初期注入・参照宣言として
正式に確定される。

============================================================
END OF BOOT FILE
============================================================
```


---

### FILE: platform/MEP/01_CORE/system/protocol/DISTRIBUTION_POLICY.md
- sha256: 19bf612e70b7e3999fa34a4f725330a7143cf3532675cf6eab506c10855616e7
- bytes: 717

```text
# Distribution Policy
（販売・展開ポリシー）

## 提供方式
- GitHub（リポジトリ提供）

## ビジネス形態
- 複合（併用）
  - MEP 本体の提供
  - MEP による生成代行
  - 無料配布＋周辺収益

## 想定利用者
- 個人
- 事業者
- 企業

## 初期セット内容
- MEP 本体リポジトリ
- サンプル master_spec（最小）
- README（導入手順のみ）
- 変更禁止領域の明示

## サポート
- 無償サポートなし
- 有償サポートのみ（契約・個別対応）

## 責任境界
- MEP 本体の仕様・挙動は保証対象外
- 利用・運用・成果物の責任は利用者側
- 有償サポート契約範囲のみ責任を負う
```


---

### FILE: platform/MEP/01_CORE/system/protocol/INTERFACE_PROTOCOL.md
- sha256: 01eb9c3bf07a09d9f1351031c6b75ba6429b64e90ecfb0df1df9b7348d981cca
- bytes: 3190

```text
<!--
参照定義ファイル：
MEP/definitions/SYMBOLS.md

運用ルール：
本ファイル内に出現するすべての参照記号（@Sxxxx）は、
個別指定や列挙を行わず、
上記「参照定義ファイル」を唯一の正として解決する。

本ファイルは、参照関係の宣言・管理を行わない。
-->



# INTERFACE_PROTOCOL

MEP プロジェクト  
UI × SYSTEM 境界統治プロトコル  
（責務分離・唯一の正）

---

## 0. 本書の位置づけ

本書（INTERFACE_PROTOCOL）は、  
**UI_PROTOCOL と system_protocol の責務境界**を定義する  
唯一の統治プロトコルである。

本書の主目的は、  
**UI と SYSTEM の判断領域を完全に分離すること**にある。

本書は、

- MEP_PROTOCOL に従属する
- UI_PROTOCOL と system_protocol の間に立つ
- 業務仕様（master_spec）を定義しない

---

## 1. 二項対立の原則

MEP において、

- **UI は意味・状態を語る**
- **SYSTEM は処理・制御を語る**

この二項は、  
役割・言語・責務のすべてにおいて分離される。

---

## 2. 相互不可侵原則

UI と SYSTEM は、  
互いの内部概念を **参照してはならない。**

- UI は SYSTEM の内部フェーズ・状態・制御を参照しない
- SYSTEM は UI の状態名・表示文言・意味表現を参照しない

相互参照は、  
**境界侵害**とみなす。

---

## 3. UI_PROTOCOL の決定権限（限定）

UI_PROTOCOL が決定できるのは、以下に限られる。

- UI 状態の定義
- UI 表示文言
- UI 状態間の意味的制約

処理・制御・判断は、  
一切定義できない。

---

## 4. system_protocol の決定権限（限定）

system_protocol が決定できるのは、以下に限られる。

- 内部フェーズ管理
- 生成・監査・保持
- 内部状態・制御

UI 表現・意味・表示状態は、  
一切定義できない。

---

## 5. 対称的禁止事項

以下を **境界侵害**として禁止する。

### UI 側禁止事項
- 内部フェーズの参照
- SYSTEM 判断の代替
- 処理進行の解釈

### SYSTEM 側禁止事項
- UI 状態名の使用
- 表示文言の生成
- UI 意味の解釈

---

## 6. 状態対応の原則

UI 状態と SYSTEM 内部状態は、  
**1 対 1 では対応しない。**

両者は、  
**意味対応関係**としてのみ結び付けられる。

---

## 7. プロトコル間の優先順位

衝突時の優先順位は、以下とする。

1. MEP_PROTOCOL  
2. INTERFACE_PROTOCOL  
3. system_protocol / UI_PROTOCOL  
4. master_spec  

下位文書は、  
上位文書に反してはならない。

---

## 8. 境界責任の最終原則

**責務境界を説明できない場合、設計ミスとみなす。**

説明不能な参照・判断・振る舞いは、  
存在してはならない。

---

## 9. 最終宣言

本書をもって、

MEP プロジェクトにおける  
UI × SYSTEM の責務境界・不可侵原則・優先順位は  
**確定**とする。

これ以降の境界変更は、  
本書を前提とした **別フェーズ**とする。

---
```


---

### FILE: platform/MEP/01_CORE/system/protocol/MUSIC_GENERATION_PROTOCOL.md
- sha256: 0cf86496183ec9aa0ae958b47a51a27c7e17f987c324b49818dcf51a38c3c241
- bytes: 457

```text
# Music Generation Protocol
（AI 楽曲生成仕様）

## 楽曲用途
- BGM
- 主題歌
- 効果音

## 生成単位
- 曲単位

## 歌詞生成
- 生成する

## ボーカル
- 用途に応じて切り替える
  - BGM：なし
  - 主題歌：あり
  - 効果音：任意

## 再生成条件
- 新しい diff が投入された場合のみ

## 出力形式
- 音声ファイル（WAV）
- 1生成 = 1ファイル
- 上書き禁止（履歴保持）
```


---

### FILE: platform/MEP/01_CORE/system/protocol/OPERATION_GOVERNANCE.md
- sha256: 6278a9b632abbcfbbefba39d7497d0c5d93c34cf17512f3e023e94e620591727
- bytes: 410

```text
# Operation Governance
（統合運用・権限・監査）

## diff 投稿権限
- 特定ロールのみ

## pipeline 実行権限
- CI のみ
- 人手実行不可

## S.commit 権限
- CI のみ（自動コミットのみ許可）

## read_only 公開範囲
- 限定公開（関係者のみ）

## ログ保存
- CI / Z.evaluate ログを自動保存
- 改変不可
- 削除不可
- 保存期間：無期限
```


---

### FILE: platform/MEP/01_CORE/system/protocol/SYSTEM_GUARD_AXIOMS.md
- sha256: e78d6bc477c27fb15b97c803bcb7fd07c04e82adb865ea6d45cd41bbe405edbe
- bytes: 4511

```text
<!--
参照定義ファイル：
MEP/definitions/SYMBOLS.md

運用ルール：
本ファイル内に出現するすべての参照記号（@Sxxxx）は、
個別指定や列挙を行わず、
上記「参照定義ファイル」を唯一の正として解決する。

本ファイルは、参照関係の宣言・管理を行わない。
-->

# SYSTEM_GUARD_AXIOMS
（SYSTEM 機械検知ガード公理定義）

本書は、  
MEP における **SYSTEM 側で機械的に検知可能な違反事象**を  
**検知条件としてのみ**定義する。

本書は、

- 思想を定義しない
- 判断主体を定義しない
- フェーズを定義しない
- 遷移・停止・継続を命令しない

本書は、  
**違反事象の有無を示す機械的フラグを生成することのみ**を目的とする。

本書は、  
MEP_PROTOCOL に定義された思想、および  
system_protocol に定義されたフェーズ制御に  
**一切介入しない。**

---

## 0. 基本原則

SYSTEM_GUARD は、  
以下の性質を持つ。

- 違反を「判断」しない
- 正誤を「評価」しない
- 処理を「停止」しない
- 遷移を「制御」しない

SYSTEM_GUARD が行うのは、  
**定義された条件に該当したか否かの検知のみ**である。

---

## 1. 出力形式（唯一）

SYSTEM_GUARD の出力は、  
以下の形式に限定される。

- `violation_detected = true`
- `violation_detected = false`

これ以外の出力は行わない。

---

## 2. 検知対象（共通）

以下は、SYSTEM_GUARD による検知対象とする。

- MEP_core/foundation 配下の Canon / Protocol / Definition 文書
- MEP_core/protocol 配下の Protocol 文書
- system_protocol が参照対象として扱う成果物
- read-only と明示された領域

---

## 3. 検知公理

### 公理 G-01：行削除検知

対象文書において、  
**既存行の削除が 1 行でも検知された場合**、  
`violation_detected = true` とする。

---

### 公理 G-02：行置換検知

対象文書において、  
**同一行番号で内容が異なる行が検知された場合**、  
`violation_detected = true` とする。

（意味同一・表現改善・誤字修正は考慮しない）

---

### 公理 G-03：diff 非経由変更検知

unified diff を伴わない変更が検知された場合、  
`violation_detected = true` とする。

---

### 公理 G-04：read-only 領域書込み検知

以下の read-only 領域への書込みが検知された場合、  
`violation_detected = true` とする。

- X（最新確定仕様）
- S（最新確定成果物）
- Canon / Protocol / Master 文書

---

### 公理 G-05：違反検知後の継続試行検知

`violation_detected = true` の状態で、  
自動処理・自動生成・自動遷移の試行が検知された場合、  
`violation_detected = true` を維持する。

※ 本公理は  
　SYSTEM_GUARD が **継続を遮断することを意味しない**。

---

### 公理 G-06：保存試行検知

system_protocol により  
保存が成立していない状態で、  
X または S への保存試行が検知された場合、  
`violation_detected = true` とする。

※ 保存の可否・成立条件は  
　本書では定義しない。

---

### 公理 G-07：境界違反入力検知

API 実装時において、  
以下の行為が検知された場合、  
`violation_detected = true` とする。

- read-only 入力の再生成
- candidate を確定扱いする行為
- 会話文脈を判断根拠として使用する行為

---

## 4. system_protocol との関係

SYSTEM_GUARD の出力は、  
system_protocol によって **参照され得る**が、

- 遷移条件とはならない
- 停止条件とはならない
- 判断材料として解釈されない

SYSTEM_GUARD は、  
system_protocol の制御権限を  
**一切持たない。**

---

## 5. Z との関係

SYSTEM_GUARD は、  
Z の代替ではない。

SYSTEM_GUARD は、

- Z を参照しない
- Z に影響を与えない
- Z の判断材料を生成しない

SYSTEM_GUARD の検知結果は、  
Z の存在有無に関わらず  
独立して存在する。

---

## 6. 付記

- SYSTEM_GUARD は理由説明を行わない
- SYSTEM_GUARD は修正案を提示しない
- SYSTEM_GUARD は合意・確定を行わない

本書は、  
**SYSTEM における純粋な機械検知ガード条件**としてのみ効力を持つ。

---

以上。
```


---

### FILE: platform/MEP/01_CORE/system/protocol/UI_APPLICATION_PROTOCOL.md
- sha256: 9e474ac94f38ecbe967efe9740eb18dc1ef1439573865dd1d1216b9fbc75fd2d
- bytes: 868

```text
# UI Application Protocol
（MEP UI 適用仕様）

## 位置づけ
本書は、MEP システムにおける UI の適用方法を定義する。
UI は MEP の外部に位置し、MEP 本体・判断・統治を持たない。

## UI 種別
- 仮UI（UIなし／手順・CLIベース）

## UI が触る API
- diff 投稿 API
- read_only 取得 API

※ candidate / Z.evaluate / S.commit は UI から触らない。

## UI 入力単位
- 1 diff / 1 実行

## UI 実行
- トリガー：手動のみ
- 実行頻度：都度実行

## 失敗時の扱い
- UI 上の表示なし
- ログ（CI / Z.evaluate）のみを正とする

## 再実行ルール
- 再実行は禁止
- 必ず差し戻し（diff 修正 → 新 diff 投入）

## UI 出力
- 画面出力なし
- ログのみ

## UI 操作ログ
- 取得しない
- CI / Z.evaluate ログのみを正とする
```


---

### FILE: platform/MEP/01_CORE/system/protocol/UI_PROTOCOL.md
- sha256: 7b80a339e0e53c8339d414dc8457c8fbacd78c75e94e095323f00dd96cf4d226
- bytes: 3923

```text
<!--
参照定義ファイル：
MEP/definitions/SYMBOLS.md

運用ルール：
本ファイル内に出現するすべての参照記号（@Sxxxx）は、
個別指定や列挙を行わず、
上記「参照定義ファイル」を唯一の正として解決する。

本ファイルは、参照関係の宣言・管理を行わない。
-->



# UI_PROTOCOL

MEP プロジェクト  
UI 統治・状態意味プロトコル  
（人間可視化層・唯一の正）

---

## 0. 本書の位置づけ

本書（UI_PROTOCOL）は、  
MEP プロジェクトにおける **UI の責務・状態表現・意味制約**を定義する  
唯一のプロトコルである。

本書は、

- MEP_PROTOCOL に完全従属する
- system_protocol の内部制御を表出しない
- 業務仕様（master_spec）を定義しない

UI に関する判断・表現は、  
本書に定義された範囲でのみ許可される。

---

## 1. UI の最重要思想

UI は、  
**操作を誘導するものではなく、状態を理解させるためのもの**である。

UI の第一目的は、  
「今、何が起きているか」を人間が誤解なく把握できることとする。

---

## 2. 内部フェーズとの分離

UI 状態と、  
SYSTEM の内部フェーズ（A/B/T/C/D/R/S 等）は  
**完全に分離**される。

内部フェーズ名・識別子・遷移は、  
UI に表示してはならない。

---

## 3. UI 状態表現の原則

UI 状態は、

- 人間向け日本語名のみを正とする
- 内部識別子を持ち込まない
- 有限個に固定する

UI 状態は、  
**同時に複数成立してはならない。**

---

## 4. UI 状態一覧（固定）

UI は、以下の状態のみを持つ。

- 未開始  
- 編集中  
- 処理中  
- 業務エラー  
- システムエラー  
- 完了  

上記以外の UI 状態は存在しない。

---

## 5. 各 UI 状態の意味定義

- **未開始**：作業は開始されていない  
- **編集中**：人間が入力・修正を行っている  
- **処理中**：SYSTEM が処理を実行している  
- **業務エラー**：監査 NG 等、業務判断により修正が必要  
- **システムエラー**：SYSTEM 破綻・処理不能状態  
- **完了**：UI 上の処理区切りを示す便宜的状態  

「完了」は、  
恒久的な最終状態を意味しない。

---

## 6. エラー状態の分離原則

- **業務エラー**：修正（R）対象  
- **システムエラー**：再試行・復旧・リセット対象  

R（修正）は、  
**業務エラー専用**であり、  
復旧操作を意味しない。

---

## 7. 進捗表示の制約

進捗表示（スピナー等）は、  
**処理中状態でのみ**許可される。

編集中状態では、  
進捗表示を行ってはならない。

---

## 8. 作業対象と UI 状態の分離

カルテ／マスタは、  
UI 状態ではなく **作業対象**に過ぎない。

作業対象の名称を、  
UI 状態として扱ってはならない。

---

## 9. UI 表示文言の制約

UI の説明文は、  
以下のみを短文で記述する。

- 今の状態
- 次にできること

理由説明・背景説明・解説は禁止する。

---

## 10. 設計統治原則

UI 挙動を変更する場合、  
**必ず UI_PROTOCOL を先に修正する。**

UI_PROTOCOL を修正せずに行われた  
UI 挙動変更は無効とする。

---

## 11. 設計責任の最終原則

**説明できない UI 挙動は、設計ミスとみなす。**

理由を説明できない状態・遷移・表示は、  
存在してはならない。

---

## 12. 最終宣言

本書をもって、

MEP プロジェクトにおける  
UI の状態定義・意味境界・設計責任は  
**確定**とする。

これ以降の UI 変更は、  
本書を前提とした **別フェーズ**とする。

---
```


---

### FILE: platform/MEP/01_CORE/system/protocol/VOICE_GENERATION_PROTOCOL.md
- sha256: a6505d0a87acff6576cf19ccc1b56b7c44a9dba85081925cedaff1121b7951f9
- bytes: 461

```text
# Voice Generation Protocol
（AI ボイス生成仕様）

## 生成方式
- 全文一括生成

## 話者数
- フルボイス（全員）

## 話者固定
- メインキャラクターは固定ボイス
- その他登場人物も役割単位で固定可能（拡張余地のみ）

## 再生成条件
- 新しい diff が投入された場合のみ

## 出力形式
- 音声ファイル（WAV）
- 1生成 = 1ファイル
- 上書き禁止（履歴保持）
```


---

### FILE: platform/MEP/01_CORE/system/protocol/YOUTUBE_GENERATION_PROTOCOL.md
- sha256: 8e9de796fa867139b6e9701e68fd367d9d68d113289ad06e6bbc087ba3f0eb7b
- bytes: 462

```text
# YouTube Generation Protocol
（YouTube 制作仕様）

## 生成対象
- 台本

## 生成単位
- 1本単位（当面）
- 安定後に複数単位へ拡張可能

## 差分修正
- 修正は必ず diff で行う
- 既存台本の上書きは禁止
- 再生成は差分反映のみ

## 再生成条件
- 人為的に新しい diff が投入された場合のみ

## 出力物の保存
- リポジトリ内（MEP 管理下）
- 履歴保持
- 上書き禁止
```


---

### FILE: platform/MEP/01_CORE/system/protocol/Z_OBSERVATION_PROTOCOL.md
- sha256: c410887f6b7dc864a160dc016ba76965fc0e3b8f1016cf0e26ab4224018a3488
- bytes: 4145

```text
<!--
参照定義ファイル：
MEP/definitions/SYMBOLS.md

運用ルール：
本ファイル内に出現するすべての参照記号（@Sxxxx）は、
個別指定や列挙を行わず、
上記「参照定義ファイル」を唯一の正として解決する。

本ファイルは、参照関係の宣言・管理を行わない。
-->

# Z_OBSERVATION_PROTOCOL

MEP プロジェクト  
Z（並走監視）観測および材料取扱い定義  
（SYSTEM 側補助プロトコル）

---

## 0. 本書の位置づけ

本書（Z_OBSERVATION_PROTOCOL）は、  
MEP における **Z（並走監視概念）を SYSTEM 上でどのように観測し、  
その結果をどのように扱うか**を定義する補助プロトコルである。

本書は、

- MEP_PROTOCOL に定義された思想・統治原則
- system_protocol に定義されたフェーズ制御・遷移原則

の **いずれにも反しない範囲**でのみ効力を持つ。

本書は、

- フェーズを定義しない
- 遷移を定義しない
- 判断を定義しない
- 制御を定義しない

---

## 1. Z の SYSTEM 上での扱い方針

SYSTEM は、  
MEP_PROTOCOL に定義された Z を  
**実体・機構・モジュールとして実装しない。**

Z は、  
SYSTEM にとって **直接参照される存在ではなく**、  
SYSTEM が生成・保持する各種情報を  
**人間が Z 的観点で解釈可能な状態に保つための  
観測上の前提概念**として扱われる。

---

## 2. 観測対象（Z 観測材料）

SYSTEM は、  
以下の情報を **通常処理の副産物として保持**する。

- フェーズ進行履歴
- 生成物の構造状態
- 監査結果（T / D の出力）
- 差分適用履歴
- 再試行・差戻しの履歴

これらはすべて、

- Z 専用に生成されるものではなく
- SYSTEM の通常責務として存在する情報

である。

---

## 3. Z 観測材料の性質

Z 観測材料は、以下の性質を持つ。

- 解釈されない
- 評価されない
- OK / NG に変換されない
- 遷移条件に使用されない

Z 観測材料は、  
**人間が後段で自由文判断を行うための参考情報**としてのみ存在する。

---

## 4. SYSTEM の禁止事項

SYSTEM は、以下を **絶対に行ってはならない。**

- Z 観測材料を用いた自動判定
- Z 観測材料を用いたフェーズ遷移
- Z 観測材料を用いた停止・継続判断
- Z 観測材料の集約によるスコア化・フラグ化
- Z 観測材料の UI 上での強制可視化

---

## 5. 人間判断との関係

SYSTEM は、  
Z 観測材料を **人間判断の入力として直接提供しない。**

人間が Z 的観点で判断を行う場合、

- SYSTEM の保持する各種情報
- MEP_PROTOCOL に定義された思想
- system_protocol に定義されたフェーズ原則

を **総合的に参照**することによって行う。

この判断は、

- 自由文によってのみ行われ
- SYSTEM によって解釈されず
- SYSTEM の挙動を直接変更しない

---

## 6. system_protocol との関係

本書は、

- system_protocol のフェーズ定義
- フェーズ遷移順序
- 監査フェーズ（T / D）
- 差戻し（R）および保存（S）

の **いずれにも介入しない。**

Z 観測材料は、  
system_protocol 上の  
**既存フェーズ挙動の外側**でのみ参照され得る。

---

## 7. 拡張および変更の原則

Z 観測に関する拡張・変更は、

- 観測材料の追加
- 記録粒度の調整
- 表現形式の変更

に限定される。

判断・制御・遷移に関わる変更は、  
本書の範囲外とする。

---

## 8. 最終宣言

本書をもって、

- Z は SYSTEM 上で **制御対象ではなく観測前提として扱われる**
- Z 観測材料は **判断材料ではあるが判断根拠ではない**
- 人間の意図と SYSTEM の進行は **構造的に乖離しない**

ことを確定する。

本書は、  
MEP における **Z の SYSTEM 側取り扱いに関する最終定義**とする。

---
```


---

### FILE: platform/MEP/01_CORE/system/protocol/system_protocol.md
- sha256: 8dbd0806afa9e4bfb229132b97638c14974916cb622dd26bba21dafa50b5b0dd
- bytes: 5032

```text
<!--
参照定義ファイル：
MEP/definitions/SYMBOLS.md

運用ルール：
本ファイル内に出現するすべての参照記号（@Sxxxx）は、
個別指定や列挙を行わず、
上記「参照定義ファイル」を唯一の正として解決する。

本ファイルは、参照関係の宣言・管理を行わない。
-->

# system_protocol

MEP プロジェクト  
システム統治・フェーズ制御プロトコル  
（機械定義・唯一の正）

---

## 0. 本書の位置づけ

本書（system_protocol）は、  
MEP プロジェクトにおける **SYSTEM の状態遷移・制御・監査**を  
機械的に定義する唯一のプロトコルである。

本書は、

- MEP_PROTOCOL に完全従属する
- 業務仕様（master_spec）を定義しない
- 人間判断を代替しない

本書に定義されていない挙動は、  
**存在しないものとして扱う。**

---

## 1. state-machine 原則

SYSTEM は、  
**state-machine による自動遷移**を前提として動作する。

明示的に定義されていない遷移・分岐・巻き戻しは  
一切許可されない。

---

## 2. 状態モデル

SYSTEM は、以下の状態を持つ。

- 初期状態：**B**
- 終了状態：**S 完了後、必ず B に復帰**

状態は循環構造を持ち、  
線形完了を前提としない。

---

## 3. フェーズ一覧と責務（固定）

SYSTEM は、以下のフェーズのみを扱う。

- **B**：編集・分類・再構成・diff 承認起点  
- **A**：差分統合  
- **X**：旧仕様保持  
- **T**：文章・構造監査  
- **D**：Runtime 監査  
- **C**：生成  
- **N**：内部保持  
- **R**：差戻し  
- **S**：保存・確定  

上記以外のフェーズは存在しない。

---

## 4. silent-execution 原則

SYSTEM は、  
**B フェーズ以外では完全沈黙（silent-execution）**とする。

T・D の監査結果は、  
**直接外部出力してはならない。**

可視化は、  
**必ず B フェーズを経由**して行う。

---

## 5. 変更手段の唯一性

SYSTEM における変更手段は、  
**diff 方式のみ**とする。

以下を禁止する。

- 全文再構成
- 部分編集
- 直接書換え

---

## 6. diff 運用と適用順序

diff は、以下の順序でのみ適用される。

**B → A → X → T → D → S**

この順序は固定であり、  
変更・省略・逆転を認めない。

---

## 7. diff 承認語トリガー

フェーズ遷移は、  
**diff 承認語トリガー**によってのみ成立する。

承認語集合・閾値・判定条件は、  
SYSTEM 外部に委譲される。

---

## 8. 外部委譲パラメータ

以下は、SYSTEM 内に定義しない。

- 承認語集合
- 閾値
- 分割単位
- 容量上限

これらは  
**外部委譲パラメータ**として扱う。

---

## 9. Runtime 監査

SYSTEM は、  
Runtime 監査を正式責務として持つ。

Runtime 監査は、

- expected effect
- unexpected effect

の検知を行う。

---

## 10. Runtime 破綻（SYSTEM_GUARD 領域）

以下を **Runtime 破綻**と定義する。

- 定義外フェーズ実行
- フェーズ順序違反
- ユーザーによるフェーズ順序操作
- silent-execution 違反

Runtime 破綻が検知された場合、  
SYSTEM は **SYSTEM_GUARD に基づく機械的処理**を実行する。

- 当該処理は **思想判断ではない**
- 当該処理は **Z に由来しない**
- 当該処理は **system_protocol に定義された範囲**でのみ行われる

具体的な処理内容（例：差戻し、進行停止等）は、  
SYSTEM_GUARD 系プロトコルに委譲される。

---

## 11. 自律ループ制御

SYSTEM は、  
以下の自律ループを持つ。

**C → N → D → R → C**

本ループは、  
明示条件を満たした場合のみ継続可能とする。

遮断条件は、  
Runtime 破綻検知とする。

---

## 12. 保存と成果物

**S フェーズに保存されたもののみ**を  
正式成果物とする。

実装反映は、  
**全文貼替**によってのみ許可される。

---

## 13. forced-block-split

forced-block-split は、  
**B フェーズ専権**とする。

部分出力は禁止する。

---

## 14. 生成物完全性

SYSTEM は、  
生成物完全性チェック  
（Completeness Guard）を前段安全弁として実行する。

完全性未達の場合、  
次フェーズへ進行してはならない。

---

## 15. 最終宣言

本書をもって、

MEP プロジェクトにおける  
SYSTEM の state-machine・制御・監査・限界は  
**確定**とする。

これ以降の変更は、  
MEP_PROTOCOL に基づく **別フェーズ**とする。

---

# Appendix: Documentation Reference Consistency

（※ Appendix は変更なし）

本 Appendix は、  
文章ドキュメントにおける参照記号の整合性維持に関する  
**SYSTEM の責務範囲**を定義する。
```


---

### FILE: platform/MEP/01_CORE/system/uiux/UI_spec_MEP.md
- sha256: 82cb9fbf4db1552992a635471593ea2a690a8f49bee06ebbdce820741c1ce6ac
- bytes: 5257

```text
<!--
参照定義ファイル：
MEP/definitions/SYMBOLS.md

運用ルール：
本ファイル内に出現するすべての参照記号（@Sxxxx）は、
個別指定や列挙を行わず、
上記「参照定義ファイル」を唯一の正として解決する。

本ファイルは、参照関係の宣言・管理を行わない。
-->



UI_spec_MEP.md

MEP Form UI ― MEP 操作 UI 適用仕様

1. 対象仕様の概要

本 UI_spec_MEP は、
MEP システム本体を操作するための管理用 UI に対して、
UI_PROTOCOL に定義された UI 統治・意味仕様を
MEP 操作という文脈に適用した結果を記述するものである。

本書は以下を満たす。

本書は UI_PROTOCOL に従属する

本書は MEP 操作 UI 専用の派生文書である

本書は 業務 master_spec に対する UI_spec ではない

本書は UI の原則・状態定義を再定義せず、参照に留める

2. 画面構成（MEP 操作 UI）

MEP 操作 UI における画面構成は、以下とする。

2.1 画面種別

HOME

MEP 操作の起点画面

新規作成、状態初期化後の表示起点となる

カルテ画面

業務 master_spec を作成・編集するための補助情報を入力する画面

業務の背景・意図・補足説明を記述する

マスタ画面

業務 master_spec 本体を作成・編集するための主画面

業務定義・構造・制約を記述する

コード画面

MEP により生成された成果物を確認する画面

API 定義／データ構造／UI ロジック等の生成結果を表示する

※ 各画面の存在理由および振る舞いは UI_PROTOCOL に従う。

3. 入力項目と画面割当（MEP 視点）
3.1 カルテ画面に割り当てられる情報

カルテ画面には、
業務 master_spec を作成するための補助情報を入力する。

業務の目的

現状の課題

前提条件

補足事項

背景情報

補足：

カルテは 業務仕様そのものではない

業務仕様の唯一の正は、マスタ画面の内容として確定される

3.2 マスタ画面に割り当てられる情報

マスタ画面には、
業務 master_spec 本体の内容を入力する。

業務定義

入力項目定義

出力項目定義

条件分岐

制約事項

データ構造

業務フロー

補足：

マスタ画面は MEP 操作 UI における主要入力画面である

ここに入力された内容が、業務 master_spec として確定される

4. 操作順序（MEP 操作の標準フロー）

MEP 操作における標準的な操作順序は以下とする。

HOME 画面で新規作成または作業開始

カルテ画面で補助情報を入力（任意）

マスタ画面で業務 master_spec を作成・編集（必須）

一時保存を行う

監査・生成等の MEP 処理を実行

コード画面で生成結果を確認

※ 操作順序は強制ではない。
本順序は 標準的な参照順である。

5. 条件付き表示・非表示（MEP 操作 UI）
5.1 コード画面の表示条件

コード画面は、MEP による生成処理が開始された後に 表示対象となる

生成未実行の状態では表示対象とならない

5.2 操作ボタンの表示条件

操作ボタンの表示は、
UI_PROTOCOL に定義された UI 状態 × 操作原則 に従う

本 UI_spec_MEP では、
追加の例外的な操作定義は行わない

6. 画面遷移フロー（MEP 操作特有）
6.1 新規作成時

新規作成操作により、

UI 状態は 初期状態に遷移する

表示画面は HOME に戻る

6.2 編集時

編集操作により、

カルテ画面またはマスタ画面が表示される

画面を開くこと自体は UI 状態を変更しない

6.3 処理実行時

保存・監査・生成等の処理実行により、

UI 状態は UI_PROTOCOL に定義された処理中状態へ遷移する

処理結果に応じて、以下のいずれかに遷移する。

完了

業務エラー（監査 NG）

システムエラー

7. MEP 操作 UI における表示文言

MEP 操作 UI において使用する表示文言は以下とする。

7.1 新規作成時

新しい業務仕様の作成を開始しました。
内容の入力を行ってください。

7.2 編集中

業務仕様を編集中です。
必要に応じて一時保存してください。

7.3 処理中

MEP による処理を実行しています。
完了するまでお待ちください。

7.4 業務エラー時（監査 NG）

業務仕様に監査上の不整合があります。
該当箇所を確認してください。

7.5 システムエラー時

MEP の処理に失敗しました。
キャンセルして最初からやり直してください。

7.6 完了時

処理が完了しました。
次に可能な操作を確認してください。

8. 本書の更新ルール

本書は MEP 操作 UI の仕様変更時にのみ更新する

業務 master_spec の内容変更により更新されることはない

UI_PROTOCOL の変更を伴う修正は行わない

UI 実装（index.html）は、本書との差分として管理される

以上で、UI_spec_MEP.md（確定版）の全文生成を完了します。
```


