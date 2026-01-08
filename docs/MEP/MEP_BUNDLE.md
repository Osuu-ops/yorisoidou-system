BUNDLE_VERSION: v0.0.0+20260109_043222+main_5ee3d4c
# MEP_BUNDLE
BUNDLE_VERSION: v0.0.0+20260109_025708
SOURCE_CONTEXT: 本ファイルは「MEPの唯一の正（main反映）」を前提に、次チャット開始時の再現性を最大化するための束ね（生成物）である。手編集は原則禁止。更新はゲートを経た反映（PR→main→Bundled）で行う。

## CARD: Response Behavior & Display Rules（応答挙動・表示規約）  [Adopted]

### 規約（最優先）
- **マスタ優先順位**：System > Developer > User
- **AIが先に決め切る**：マスタに沿ってAIが判断し、まず結論を出す
- **人間は否定のみ**：ユーザーが否定した点だけ、深掘り・再設計する
- **説明は原則しない**：ユーザーが説明を求めた時だけ説明する
- 説明する場合は **短く・明快・素人にもわかる** 形で行う

### 表示（UI）
- 通常は上から **2行のみ** 表示する：`[モード]` / `[現在地]`
- **メモ／採用** フェーズ、または **完了ゲート（0承認要求）** の時は **4行表示**：
  - 2行（モード/現在地）＋2行（ブレイン要約/プロダクト要約）
- **生成フェーズ中は表示なし**（0行）

（4行時の要約フォーマット）
- 3行目：`【ブレイン】メモ:<n> 採用:<n> 生成:<n> バンドル完了:<n>`
- 4行目：`【プロダクト】メモ:<n> 採用:<n> 生成:<n> マージ完了:<n>`

## CARD: BUSINESS_UNIT バンドル設計（ドメイン単位の束ね）  [Draft]

### 目的
BUSINESS側を構築すると、例外・分岐・用語・台帳参照が急増し、全体BUNDLEだけでは参照コストと混線リスクが上がる。ドメイン（業務単位）ごとの束ねを持ち、再開・実装・監査を高速化する。

### 3階層（推奨）
- **GLOBAL（全体BUNDLE）**：MEP契約・Gate・状態タグ・安全規約など共通
- **BUSINESS_UNIT（業務単位BUNDLE）**：そのドメイン固有（前提/用語/台帳/境界/DoD/例外）
- **WORK_ITEM（作業単位ミニBUNDLE/CURRENT）**：1テーマの目的/前提/採用済み/未決/次アクションのみ

運用上は「入口投入は単一」を維持するため、起動時に
`GLOBAL + 対象UNIT + 対象WORK_ITEM` を結合した **STARTUP_BUNDLE（単一）** を生成して投入する。

### 分割原則（汚染防止）
- **層の優先順位固定**：GLOBAL > UNIT > WORK_ITEM（下位が上位を上書き禁止）
- **重複禁止**：同一決定は1か所のみ（例：状態タグ/Gate/確定定義はGLOBALのみ）
- **参照固定**：UNIT/WORK_ITEMは参照するGLOBALのBUNDLE_VERSION（またはcommit）を明記
- **生成物の手編集禁止**：更新はPR→main→Bundledでのみ行う

# RUNBOOK（復旧カード）

## CARD: no-checks（Checksがまだ出ない／表示されない）

### 観測
- PR に checks が出ない／"No checks" が継続する
- bot/GITHUB_TOKEN由来PRで pull_request が走らない疑い

### 一次対応
- PR作成側のトークンを PAT/GitHub App 等に変更（必要なら）
- CI専用workflowを新規作成（pull_requestで走る／write権限不要）
- Required checks 名と job/チェック名を一致させる

### 停止条件（DIRTYへ遷移）
- 原因が特定できず、手動運用の方が安全な場合（A運用継続）

### 次の遷移
- B運用へ移行条件（checks安定表示＋Required checks一致）を満たしたら移行

## CARD: behind / out-of-date（Head branch is out of date）

### 観測
- GitHub で "Head branch is out of date" が表示される
- base が更新された

### 一次対応
- rebase/merge ではなく、方針に沿って安全に追従
- 競合が出る場合はDIRTYへ

### 停止条件（DIRTYへ遷移）
- 競合（コンフリクト痕跡が残る）
- 意図外の差分が混入する

### 次の遷移
- cleanに戻し、必要なら新規PRで再作成

## CARD: DIRTY（自動で安全に解決できない）

### 観測
- 自動で安全に解決できない
- 競合痕跡／境界崩壊／意図外差分など

### 一次対応
- 状態を固定（現状保存）
- 影響範囲を特定
- 再現性のある手順で復旧（RUNBOOKに従う）

### 停止条件（固定）
- DIRTY のまま次工程へ進まない

### 次の遷移
- ALL_OK（境界監査OK）へ収束後にのみ進行

## CARD: Scope不足（Scope Guard / Scope-IN Suggest）

### 観測
- 情報が不足し判断ができない
- 参照が欠けている

### 一次対応
- 必要最小限の情報だけ要求（1回で収束）
- 不明点があっても推奨案とリスクは提示する

### 停止条件（DIRTYへ遷移）
- 誤確定に繋がる場合

### 次の遷移
- 必要情報が揃い次第、通常遷移に復帰

## CARD: Guard NG（Chat Packet Guard / Docs Index Guard 等）

### 観測
- 必須マーカー欠落
- 破損（文字化け）疑い
- マージ痕跡混入

### 一次対応
- 生成/反映を即停止
- 破損箇所の特定と除去
- 監査（ALL_OK）へ収束

### 停止条件（DIRTYへ遷移）
- 自動修復不可
- 影響範囲が不明

### 次の遷移
- ALL_OK → PR → main → Bundled → Completed Gate

