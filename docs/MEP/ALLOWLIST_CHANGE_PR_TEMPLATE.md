# Allowlist Change PR Template

## 目的
Allowlist にアカウントを追加/削除するための PR。変更は Owner または Ops Lead の承認を最低 2 名必要とする。

## 変更内容（必須）
- 変更種別: add | remove
- login: <github-login>
- roles: [ops-lead | ci-bot | ...]
- reason: <短い理由>

## チェックリスト（PR 作成者）
- [ ] docs/MEP/SIGNED_BY_ALLOWLIST.yml の該当エントリを編集しました
- [ ] 変更の理由を上に記載しました
- [ ] semantic-audit / semantic-audit-business を通すための補足説明を PR Body に追記しました

## 承認ルール
- 2 名以上の Owner / Ops Lead のレビュー & Approve を要求します
- マージ前に CI が `metadata-format-check` を通ること
