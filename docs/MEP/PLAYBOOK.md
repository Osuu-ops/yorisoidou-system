# PLAYBOOK（次の指示カード集）

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
