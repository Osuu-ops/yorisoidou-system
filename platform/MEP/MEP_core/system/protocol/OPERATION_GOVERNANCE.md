# Operation Governance
（統合運用・権限・監査）

## diff 投稿権限
- 特定ロールのみ

## pipeline 実行権限
- CI のみ
- 人手実行不可

## S.commit 権限
- CI のみ（自動コミットのみ許可）

## read_only 公開範囲
- 限定公開（関係者のみ）

## ログ保存
- CI / Z.evaluate ログを自動保存
- 改変不可
- 削除不可
- 保存期間：無期限
