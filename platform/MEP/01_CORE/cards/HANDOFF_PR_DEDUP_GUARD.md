## CARD: HANDOFF_PR_DEDUP_GUARD（handoff PR 多重OPENの抑止）  [Draft]
<!-- BEGIN: HANDOFF_PR_DEDUP_GUARD -->

### 目的（Why）
- 「handoff(PR) が多重にOPENになりやすい」事象を、会話メモではなく **成果物（カード）**として定義し、再現可能な手順と停止条件を固定する。
- 真実は常に **PR → main → Bundled（BUNDLE_VERSION）** のみ。会話ログでの「直った」は採用対象外。

### 観測（What）
- 同系統の handoff / writeback PR が並行してOPENし、どれを採用すべきかが不明瞭になる。
- 結果として、証跡（Bundled）への固定が遅延し、監査上の混線・汚染リスクが上がる。

### 原因仮説（Not Truth / Hypothesis）
- 自動PR生成のトリガーが近接し、同種PRが短時間で複数作られる。
- 「既存OPENがあるなら止める／集約する」というガードが不足している。

### 対策方針（Policy）
- handoff / writeback 系の運用は **同カテゴリでOPENは原則1本**。
- 既にOPENが存在する場合は、次を固定する：
  - 追加のPR生成を止める（= DIRTY停止）
  - 既存OPENへ集約する（= 新規を作らない）

### 観測点（Minimum Audit Signals）
- OPEN PRの一覧（headブランチ prefix で同カテゴリを抽出）
- 対象カテゴリで OPEN が 2本以上 → **DIRTY**
- 収束条件：対象カテゴリで OPEN が 0〜1本に戻る

### 停止条件（DIRTY）
- 同カテゴリの PR が 2本以上 OPEN
- どれが採用対象か（基準点／差分）が一意に定まらない

### 復旧（Recovery）
1) OPEN PR を列挙し、カテゴリ別に「採用対象1本」を選定
2) 採用対象以外は close（または draft / convert to issue 等、運用に沿う）
3) 採用対象を main にマージ → Bundled で証跡固定（BUNDLE_VERSION更新）

### 受入条件（DoD）
- 運用として「同カテゴリOPENは原則1本」が明文化されている
- 2本以上OPEN時の停止（DIRTY）と復旧手順が書かれている
- 本カードが PR→main→Bundled で固定され、次チャットで再現参照できる

<!-- END: HANDOFF_PR_DEDUP_GUARD -->
