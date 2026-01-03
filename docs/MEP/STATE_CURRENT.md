# STATE_CURRENT（現在地） v1.2

## 目的
本書は「いま何が成立しているか／次に何をするか」を1枚で固定する。
UI/APIは実行器であり、唯一の正は GitHub（main / PR / Checks / docs）に置く。

---

## 1) docs/MEP：CHAT_PACKET 自動追随 = 成立
- chat_packet_update_schedule / dispatch により CHAT_PACKET を生成し、差分があれば auto PR を作成・auto-merge
- Chat Packet Guard が生成物の古さをNGとして検出（正常）
- Self-Heal が no-checks / behind / DIRTY を検知し、復旧 or 停止（停止理由を残す）

---

## 2) 重要ルール（固定）
- PowerShell は必ず @' '@（ダブルクォートHere-Stringは禁止）
- 人間によるID手入力・プレースホルダ差し替え禁止（gh等で自動解決）
- 変更は必ずPR経由（main直コミット禁止）

---

## 3) 次の改良 Top3（一本道）
1. RUNBOOK（復旧カード）を docs/MEP に追加
2. PLAYBOOK（次の指示カード）を docs/MEP に追加
3. STATE_SUMMARY を生成物として自動更新

---
