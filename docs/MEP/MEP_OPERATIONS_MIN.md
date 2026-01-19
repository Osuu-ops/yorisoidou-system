# MEP 運用ガイド（最小）

## 基本原則
- 真実は PR → main → Bundled（BUNDLE_VERSION）でのみ確定する。
- 採用対象は成果物（カード）であり、会話は含まれない。
- 採用前に受入テストを実行し、判定は exit code に従う。

## 基本の流れ
1. 変更内容をカード（Markdown）として作成する。
2. 受入テストを実行する（exit code: 0=OK / 非0=NG）。
3. OK の場合のみ PR を作成し main にマージする。
4. Bundled に反映され BUNDLE_VERSION が更新された時点で確定する。
