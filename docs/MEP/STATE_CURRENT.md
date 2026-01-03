# STATE_CURRENT（現在地） v1.2

## 目的
本書は「いま何が成立しているか／次に何をするか」を1枚で固定する。
UI/APIは実行器であり、唯一の正は GitHub（main / PR / Checks / docs）に置く。

---

## 1) docs/MEP：CHAT_PACKET 自動追随 = 成立
- chat_packet_update_schedule により CHAT_PACKET を生成し、差分があれば auto PR を作成・auto-merge
- Chat Packet Guard が「生成物の古さ」をNGとして検出（正常）
- Self-Heal が no-checks / behind / DIRTY を検知し、復旧 or 停止（停止理由を残す）

---

## 2) Text Integrity Guard（TIG）= 成立（事故防止）
- CRLF / UTF-8不正 等のテキスト事故を検出する
- 規約（.gitattributes / .editorconfig）は main 反映済

---

## 3) MEPチェック運用（B/A）= 維持（別レーン）
- B運用：PRのChecksが観測でき、Green でマージする
- A運用：Bが機能不全（checksが付かない等）のときのみ保険として使用する

---

## 4) 重要ルール（固定）
- PowerShell は必ず @' '@ を使う（ダブルクォートHere-Stringは禁止）
- 人間によるID手入力・プレースホルダ差し替えを禁止（gh等で自動解決）
- 変更は必ずPR経由（main直コミット禁止）
- DIRTY（自動で安全に解決できない状態）は自動停止し、人間判断へ遷移

---

## 5) 次の改良 Top3（一本道）
1. RUNBOOK（復旧カード）を docs/MEP に追加（no-checks / behind / DIRTY / Scope不足 / Guard NG）
2. PLAYBOOK（次の指示カード）を docs/MEP に追加（成功/失敗の遷移固定）
3. STATE_SUMMARY 自動生成（生成物としてPR更新）→ API実行器へ直結

---
