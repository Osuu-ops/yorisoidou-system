# STATE_SUMMARY（現在地サマリ） v1.0

本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
生成: docs/MEP/build_state_summary.py

---

## 目的（STATE_CURRENTから要約）
本書は「いま何が成立しているか／次に何をするか」を1枚で固定する。
UI/APIは実行器であり、唯一の正は GitHub（main / PR / Checks / docs）に置く。

---

## 参照導線（固定）
- CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
- 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
- 次の指示: docs/MEP/PLAYBOOK.md
- 復旧: docs/MEP/RUNBOOK.md
- 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）

---

## STATE_CURRENT の主要見出し
- STATE_CURRENT（現在地） v1.2
- 目的
- 1) docs/MEP：CHAT_PACKET 自動追随 = 成立
- 2) 重要ルール（固定）
- 3) 次の改良 Top3（一本道）

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
- （未取得）RUNBOOK.md を確認

---

## INDEX の主要見出し
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

