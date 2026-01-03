# STATE_SUMMARY（現在地サマリ） v1.0

本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
生成: docs/MEP/build_state_summary.py

---

## 目的（STATE_CURRENTから要約）
本書は「いま、このリポジトリで何が成立していて、何を唯一の正として進めるか」を 1枚で固定する。
新チャット開始時は原則として CHAT_PACKET と本書（STATE_CURRENT）を貼り、追加情報が必要な場合のみ AI は REQUEST 形式（最大3件）で要求する。

---

## 参照導線（固定）
- CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
- 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
- 次の指示: docs/MEP/PLAYBOOK.md
- 復旧: docs/MEP/RUNBOOK.md
- 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）

---

## STATE_CURRENT の主要見出し
- 目的（不変）
- 0) 運用契約（最優先）
- 1) PR運用（B運用）= 成立（必須）
- 2) 保険ルート（A運用）= 存続（障害時のみ）
- 3) Auto PR Gate（自動PR作成）= 稼働（作業の自動化用）
- 4) Text Integrity Guard（TIG）= 成立（事故防止）
- 5) docs/MEP：CHAT_PACKET運用（前提）= 成立
- 6) Guard群（観測可能な安全装置）= 成立
- 7) Manual-as-Code（次の強化対象）= 進行中
- 8) この作業（INDEX方式）のスコープ
- 9) 観測コマンド（読むだけ／ID手入力不要）

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
- CARD-01: no-checks（Checksがまだ出ない／表示されない）
- CARD-02: Chat Packet Guard NG（CHAT_PACKET outdated）
- CARD-03: Scope不足（Scope Guard / Scope-IN Suggest）
- CARD-04: Head branch is out of date（behind/out-of-date）
- CARD-05: DIRTY（自動で安全に解決できない）

---

## INDEX の主要見出し
- 参照順（固定）
- Links
- RUNBOOK（復旧カード）
- PLAYBOOK（次の指示）

