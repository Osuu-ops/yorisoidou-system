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
# AI_BOOT（AI挙動固定） v1.0
（本文は docs/MEP/AI_BOOT.md を参照）
```

---

## STATE_CURRENT.md（現在地）  (docs/MEP/STATE_CURRENT.md)
```
# STATE_CURRENT (MEP)
（本文は docs/MEP/STATE_CURRENT.md を参照）
```

---

## ARCHITECTURE.md（構造・境界）  (docs/MEP/ARCHITECTURE.md)
```
# ARCHITECTURE（構造） v1.1
（本文は docs/MEP/ARCHITECTURE.md を参照）
```

---

## PROCESS.md（実行テンプレ）  (docs/MEP/PROCESS.md)
```
# PROCESS（手続き） v1.1

## docs/MEP 生成物同期（必須）
- docs/MEP/** を変更したPRは、先に **Chat Packet Update (Dispatch)** を実行して docs/MEP/CHAT_PACKET.md を最新化する。
- schedule/dispatch 専用のチェック名は Required checks に入れない（PRに出ず永久BLOCKEDになり得る）。
- 失敗時は「Chat Packet Update (Dispatch) → 生成PRをマージ → 元PRへ戻る」で復旧する。
```

---