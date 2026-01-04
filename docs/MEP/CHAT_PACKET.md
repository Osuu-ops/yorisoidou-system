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
