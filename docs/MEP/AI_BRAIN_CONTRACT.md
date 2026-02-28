# AI_BRAIN_CONTRACT（固定｜GPTを脳にしても壊れない）
目的：GPTを「脳（提案者）」として用いても、MEPが壊れないことを絶対条件として固定する。
---
## 絶対ルール（固定）
1) GPTは提案者
- 欠損（穴）の指摘
- 修正案（パッチ案）
- 次アクション案
を出すことは許可する。
2) 最終判定は機械ゲート
- SSOT/CONFLICT/SCOPE/DIFF/Required checks 等の機械検査に通ったものだけを採用する。
- 通らないものは STOP + reason_code + next_action を残して終了する。
3) 変更はPR経路のみ
- 直書き禁止（常にPRで差分を可視化し、checksで判定する）
4) 失敗は収束へ導く
- stop_class（WAIT/HARD）と reason_code を必ず残す
- 同じ原因は同じ reason_code で止め、再発を減らす
5) 価値の最低ライン（GPT質問との差）
- 再現性（収束）
- 安全停止
- 証跡
- 再開
- 非暴走
を満たさない状態を「完成」と呼ぶことを禁止する。
