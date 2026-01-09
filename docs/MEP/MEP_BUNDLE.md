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

<!-- BEGIN: HYBRID_ROADMAP_PHASE1_3 (MEP) -->
## CARD: HYBRID / ROADMAP（Phase 1〜3）  [Draft]

### ゴール（誤解防止）
- 「揺れをゼロにする」ではなく **揺れを成果物に通さない**（通過しない/採用されない）ことで、結果として揺れゼロに“見せる”。
- 「真実」は常に **PR → main → Bundled（BUNDLE_VERSION確認）** の証跡のみ。
- 検疫優先：**受入テスト実装（入口の機械化）が完成するまで、以後の自動化拡張はしない**。通らない成果物は **破棄（PRを作らない）**。

---

### Phase 1：MEP最上位化（証跡一本化）
#### 目的
- 採用・導入・引き継ぎの真実を Git 証跡に一本化し、幽霊（採用したつもり）を発生させない。

#### 完了条件（Definition of Done）
- 採用対象は「成果物（カード/差分）」のみ。会話ログは採用対象外。
- 採用＝PR作成、導入＝mainマージ、固定＝Bundled（BUNDLE_VERSION更新）で再現できる。
- 「入った/入ってない」を PowerShellで機械確認できる（mainの該当文言＋BUNDLE_VERSION）。

---

### Phase 2：ハイブリッド入口固定（思考UI × 決裁/実行系）
#### 目的
- UI（思考・候補生成）と、決裁/実行（採用・監査・固定）を分離し、UIの揺れを成果物に入れない。

#### 完了条件（Definition of Done）
- UI側は「候補生成（カード案）」まで。採用・完了宣言は禁止（会話は監査対象外）。
- 実行系は「唯一の成果物フォーマット」を1つに固定（未確定なら明記して止める）。
- 受入テスト（出力ガード）により、形式違反/禁止事項/境界崩壊は採用ルートに入らない（NGは破棄またはDIRTY停止）。

---

### Phase 3：安定化（揺れ結果ゼロ運用）
#### 目的
- 揺れは発生しても「採用されない」ことで、第三者でも壊れない運用を実現する。

#### 完了条件（Definition of Done）
- NG時の挙動が固定：再生成上限 or DIRTY停止、復旧カードで再開できる。
- 証跡の自動化：PR/commit/BUNDLE_VERSION/監査結果が常に残る（幽霊がほぼ消える）。
- 次チャット開始時に貼るべき最新束ね（BUNDLE_VERSION付き）が一意に分かる。

<!-- END: HYBRID_ROADMAP_PHASE1_3 (MEP) -->

<!-- BEGIN: HYBRID_UPGRADE_SPEC (MEP) -->
## CARD: HYBRID / UPGRADE SPEC（MEPハイブリッド化）  [Draft]

### 基本原則（固定）
- UI（GPT UI / 対話）＝ **思考・発散・候補生成**（確定しない）
- 実行系（Git/CI/API）＝ **採用・監査・固定**（証跡のみが真実）
- 揺れは「発生しても良い」が **成果物に通さない**。

### UI側の禁止（汚染防止）
- 採用・確定・完了の宣言を UI 会話で行わない。
- 会話ログを採用対象にしない。
- 監査100点のような“実態以上の保証”を出さない。

### 実行系（採用）側の固定
- 採用単位は「カード（成果物）」のみ（1枚ずつ）。
- 採用フロー：Draft → PR → Merged to main → Bundled（BUNDLE_VERSION更新）。
- 監査対象は main の成果物のみ（会話は対象外）。

<!-- END: HYBRID_UPGRADE_SPEC (MEP) -->

<!-- BEGIN: ACCEPTANCE_TESTS_SPEC (MEP) -->
## CARD: ACCEPTANCE_TESTS / SPEC（受入テスト仕様）  [Draft]

### 実装場所（固定）
- 受入テストは **採用ルートの入口**で実行する。
- 原則：**受入テストが通らない成果物は破棄（PRを作らない）**。

### 実行条件（固定）
- 「カード（成果物）」を採用ルートへ投入する前に必ず実行。
- NGの場合：再生成（上限あり）またはDIRTY停止。

### 機械判定（最小）
- 形式：必須マーカー（BEGIN/END）整合、必須フィールドの存在
- 禁止：コンフリクト痕跡、片側欠損、曖昧な範囲採用（例：「ここまで全部採用」）
- 境界：カード定義の重複/多重定義がない
- 判定は exit code（0=OK / 非0=NG）で返す

<!-- END: ACCEPTANCE_TESTS_SPEC (MEP) -->

<!-- BEGIN: EVIDENCE_WRITEBACK_SPEC (MEP) -->
## CARD: EVIDENCE / WRITEBACK SPEC（証跡貼り戻し仕様）  [Draft]

### 対象（必須）
- PR番号
- merge commit
- BUNDLE_VERSION
- 監査結果（OK/NG、検出コード）

### 貼り戻し先（今回の固定）
- **MEP_BUNDLE.md に一本化**（Runbook側へは貼らない）。

### 更新主体（固定）
- 手作業ではなく **スクリプト/CI** が自動で貼り戻す。
- 証跡が欠けるものは「入った扱い禁止」。

<!-- END: EVIDENCE_WRITEBACK_SPEC (MEP) -->

<!-- BEGIN: DIFF_POLICY_BOUNDARY_AUDIT (MEP) -->
## CARD: DIFF_POLICY / BOUNDARY AUDIT（差分運用・境界監査）  [Draft]

### 基本
- 大置換・全文書き換えは禁止。更新は **差分（最小パッチ）** を原則とする。

### 境界監査（最小）
- BEGIN/END は必ず対で存在し、片側欠損は DIRTY（停止）。
- 同一BEGINの重複定義は禁止（検出したらNG）。

<!-- END: DIFF_POLICY_BOUNDARY_AUDIT (MEP) -->

<!-- BEGIN: DIRTY_RECOVERY_SPEC (MEP) -->
## CARD: DIRTY / RECOVERY（停止・復旧仕様）  [Draft]

### DIRTY条件（最小）
- 受入テストNG（形式/禁止事項/境界崩壊）
- BEGIN/ENDの片側欠損
- 証跡が残せない（PR/commit/BUNDLE_VERSION不明）

### 取るべきログ（最小）
- 対象ファイル名
- 検出コード（NG理由）
- 直前の差分（最小）

### 復旧カード（フォーマット最小）
- 現状（何が起きたか）
- 影響範囲
- 次にやる手順（1ステップ）
- 再開条件（何が揃えば進めるか）

<!-- END: DIRTY_RECOVERY_SPEC (MEP) -->

<!-- BEGIN: SINGLE_ARTIFACT_FORMAT (MEP) -->
## CARD: SINGLE ARTIFACT FORMAT（唯一の成果物フォーマット）  [Draft]

### 未確定（明記）
- 採用ルートに投入する「唯一の成果物フォーマット」は未確定。
- 次ゲートで **1つに確定**するまで、採用ルートの自動化は段階停止（拡張を禁止）。

<!-- END: SINGLE_ARTIFACT_FORMAT (MEP) -->
