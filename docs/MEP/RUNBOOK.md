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

## 運用ルール（採用済み）
受領しました。ここからは、あなたが冒頭に固定した運用ルールに従います（Decision Gate厳守／採用宣言まで実行可能コード提示禁止、FAST_LOOP_* 以外でコマンド提示禁止）。

### 確定：現在地（事実）
- チャット種別：Aチャット（MEP/GAS運用の続き）
- GAS：B22（固定URLの /exec を clasp redeploy で高速ループ可能）
  - deploymentId：AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw
  - /exec：https://script.google.com/macros/s/AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw/exec
- GitHub：open PR = 0

### トリガー仕様（最優先）
- `FAST_LOOP_GAS`（単独行で送信） → 返答は**単一の PowerShell 1 ブロックのみ**（内容：push→create-version→redeploy→GET検証）。  
- `FAST_LOOP_GH`（単独行で送信） → 返答は**単一の PowerShell 1 ブロックのみ**（内容：openPR=0 収束の自動化）。  
- それ以外の要求・提案は **Decision Gate** による採用宣言があるまで **実行可能なコード／コマンドを提示しない**。

### STATE_CURRENT 記録ルール（必須）
- 例外運用を行ったら必ず1行で記録（ISO日時／実行者／トリガー／要約／scriptId／deploymentId／version／理由／結果）。例：  
  `- 2026-01-06T10:59:41+09:00 (A:yorisoidoupdf) FAST_LOOP_GAS: redeploy→verify; scriptId=1wpU...; deploymentId=AKfy...; ver=16; reason="hotfix/ops"; result="OK:version match"`

### 検証基準（redeploy 後 GET）
- 合格判定：`res.ok === true` AND `res.version === expected`（expected は src\コード.js の CFG.VERSION）  
- 失敗時：自動ロールバック（直近安定 ver）→通知（Slack/Email/Runbook 担当）→STATE_CURRENT に失敗ログ記録。

### セーフティとガバナンス
- autopilot による自動マージは **required checks を迂回しないこと**。自動化が失敗した場合の通知先と担当を RUNBOOK に明記すること。  
- 例外運用を起こせる者は限定（Ops Lead, Owner 等）し、その権限を RUNBOOK に記載。

---- 
(追記日時: 2026-01-06T23:16:38+09:00 / actor: Osuu-ops)


## 運用ルール（採用済み）
受領しました。ここからは、あなたが冒頭に固定した運用ルールに従います（Decision Gate厳守／採用宣言まで実行可能コード提示禁止、FAST_LOOP_* 以外でコマンド提示禁止）。

### 確定：現在地（事実）
- チャット種別：Aチャット（MEP/GAS運用の続き）
- GAS：B22（固定URLの /exec を clasp redeploy で高速ループ可能）
  - deploymentId：' + $deploymentId + '
  - /exec：' + $execUrl + '
- GitHub：open PR = 0

### トリガー仕様（最優先）
- `FAST_LOOP_GAS`（単独行で送信） → 返答は**単一の PowerShell 1 ブロックのみ**（内容：push→create-version→redeploy→GET検証）。
- `FAST_LOOP_GH`（単独行で送信） → 返答は**単一の PowerShell 1 ブロックのみ**（内容：openPR=0 収束の自動化）。
- それ以外の要求・提案は **Decision Gate** による採用宣言があるまで **実行可能なコード／コマンドを提示しない**。

### STATE_CURRENT 記録ルール（必須）
- 例外運用を行ったら必ず1行で記録（ISO日時／実行者／トリガー／要約／scriptId／deploymentId／version／理由／結果）。例：
  `- 2026-01-06T10:59:41+09:00 (A:actor) FAST_LOOP_GAS: redeploy→verify; scriptId=...; deploymentId=...; ver=16; reason="hotfix/ops"; result="OK:version match"`

### 検証基準（redeploy 後 GET）
- 合格判定：`res.ok === true` AND `res.version === expected`（expected は src\コード.js の CFG.VERSION）
- 失敗時：自動ロールバック（直近安定 ver）→通知（Slack/Email/Runbook 担当）→STATE_CURRENT に失敗ログ記録。

### セーフティとガバナンス
- autopilot による自動マージは required checks を迂回しないこと。自動化が失敗した場合の通知先と担当を RUNBOOK に明記すること。
- 例外運用を起こせる者は限定（Ops Lead, Owner 等）し、その権限を RUNBOOK に記載。

----
(追記日時: ' + $now + ' / actor: ' + $actor + ')

