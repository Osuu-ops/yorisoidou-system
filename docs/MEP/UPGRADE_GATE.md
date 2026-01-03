# UPGRADE_GATE（開始直後の100点化ゲート）

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
