# RUNBOOK（復旧カード集）

本書は「異常が起きたとき、診断ではなく次の一手だけを返す」ための復旧カード集である。
手順は PowerShell 単一コピペ一本道を原則とし、IDは gh で自動解決する（手入力禁止）。
唯一の正：main / PR / Checks / docs（GitHub上の状態）

---

## CARD-01: no-checks（Checksがまだ出ない／表示されない）

症状：
- gh pr checks が「no checks reported」または空
- ただし直後に表示されることがある（生成待ち）

次の一手（待機→再観測）：
- 一定時間（例：30〜90秒）待機して再度 gh pr checks を実行
- それでも出ない場合は A運用（Gate Runner Manual）へ遷移

停止条件（人間判断）：
- 一定時間待機してもChecksが出ない状態が継続

---

## CARD-02: Chat Packet Guard NG（CHAT_PACKET outdated）

症状：
- Chat Packet Guard が NG（例：CHAT_PACKET.md is outdated）

次の一手：
- docs/MEP/build_chat_packet.py を実行して CHAT_PACKET.md を更新
- 更新差分を同一PRに含めて再push（または自動更新PRに任せる）

---

## CARD-03: Scope不足（Scope Guard / Scope-IN Suggest）

症状：
- Scope Guard が NG
- Scope-IN Suggest が提案を出す

次の一手：
- 変更対象が本当に必要かを確認
- 必要なら CURRENT_SCOPE の Scope-IN を最小追加してPRで通す
- 不要なら変更をScope内に戻す

---

## CARD-04: Head branch is out of date（behind/out-of-date）

症状：
- gh pr merge が "Head branch is out of date" を返す

次の一手：
- PRブランチを main に追従（merge/rebaseのいずれか）して再push
- その後 auto-merge を再設定

---

## CARD-05: DIRTY（自動で安全に解決できない）

定義：
- merge conflict / push不可 / 自動修復失敗 など、汚染リスクが上がるため自動停止すべき状態

次の一手：
- 停止理由（分類）を確認
- 人間判断入力に変換（何を採用/破棄するかを明示）
- その判断を反映した最小差分PRで再実行
