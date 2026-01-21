BUNDLE_VERSION = v0.0.0+20260122_052814+local+child

## CARD: q / CHILD_MEP / COMPLETION  [Draft]

### 目的
- q ビジネスを **子MEP単位**で管理する。

### 管理対象
- platform/MEP/03_BUSINESS/q 配下の成果物

### 成功条件
- PR → main → Bundled の経路で再現可能

## CARD: q / OPS  [Draft]

### 対象
- platform/MEP/03_BUSINESS/q/ 配下
  - business_spec.md
  - TARGETS.yml
  - MEP_SUB/MEP_BUNDLE.md

### 運用原則
- 真実の確定は PR → main → Bundled（BUNDLE_VERSION）のみ
- 会話・ローカル編集は採用対象外

### 更新ルール
- 更新は差分最小（追記優先）
- 不明は不明として残し、推測で埋めない
- 1段落＝1追加で進める

### 監査観測点（最小）
- main 上の該当ファイル差分がPRで説明できる
- 親Bundled（docs/MEP/MEP_BUNDLE.md）に PR 証跡が残る

### 停止条件
- 意図外差分、競合、証跡欠損は DIRTY として停止
