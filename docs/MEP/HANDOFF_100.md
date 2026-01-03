# HANDOFF_100（引継ぎ100点・新チャット1通目に貼る1枚） v1.0

本書は、MEP運用の「唯一の正（docs/MEP）」から生成された引継ぎ文である。
新チャット開始は原則として本書 1枚だけを貼る。

## ルール（最優先）
- 開始直後に UPGRADE_GATE を必ず適用（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）
- 追加情報が必要な場合のみ REQUEST 形式（最大3件）で要求
- AI出力は PowerShell単一コピペ一本道（ID手入力禁止、ghで自動解決）

---

## Start（貼る順序）
- この HANDOFF_100 を貼る（= これ1枚）
- それでも足りない場合のみ、次を貼る：REQUEST_BUNDLE_SYSTEM または REQUEST_BUNDLE_BUSINESS

---

## 現在地（STATE_SUMMARY）
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
- （未取得）STATE_CURRENT.md を確認

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
- STATE_SUMMARY（現在地サマリ）
- PLAYBOOK_SUMMARY（次の指示サマリ）
- RUNBOOK_SUMMARY（復旧サマリ）
- UPGRADE_GATE（開始ゲート）
- HANDOFF_100（引継ぎ100点）
- REQUEST_BUNDLE（追加要求ファイル束）

---

## 次の一手（PLAYBOOK_SUMMARY）
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

---

## 異常時（RUNBOOK_SUMMARY）
# RUNBOOK_SUMMARY（復旧サマリ） v1.0

本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
生成: docs/MEP/build_runbook_summary.py

---

## カード一覧
- CARD-01: no-checks（Checksがまだ出ない／表示されない）
- CARD-02: Chat Packet Guard NG（CHAT_PACKET outdated）
- CARD-03: Scope不足（Scope Guard / Scope-IN Suggest）
- CARD-04: Head branch is out of date（behind/out-of-date）
- CARD-05: DIRTY（自動で安全に解決できない）

---

## 参照（唯一の正）
- docs/MEP/UPGRADE_GATE.md
- docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
- docs/MEP/STATE_CURRENT.md / PLAYBOOK.md / RUNBOOK.md / INDEX.md

