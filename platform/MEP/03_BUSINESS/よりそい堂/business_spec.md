<!--
PHASE-1 (ADD ONLY): This file is a new container. Do NOT change canonical meaning yet.
CANONICAL (current): platform/MEP/03_BUSINESS/よりそい堂/master_spec
ROLE: BUSINESS_SPEC (workflow / rules / decisions / exceptions)
-->

# BUSINESS_SPEC（業務スペック）

## 0. 目的
- 見積→受注→施工→請求→領収→部材→経費 の業務ルールを定義する
- 項目定義は BUSINESS_MASTER に置く

## 1. 業務フロー（章立て）
1) 見積（ESTIMATE）
2) 受注（ORDER）
3) 施工（WORK）
4) 請求（INVOICE）
5) 領収（RECEIPT）
6) 部材（PARTS）
7) 経費（EXPENSE）

## 2. 見積（ESTIMATE）— 最小仕様（仮）
- 目的：依頼内容から見積書を生成する
- 入力：BUSINESS_MASTER の estimate 項目
- 出力：docType=ESTIMATE / docName / docDesc / docPrice / docMemo
- 例外：必須項目不足は質問で補完する

（※詳細は次のPRで詰める。今回は骨格のみ）

## 3. 請求（INVOICE）

### 3.1 目的
- 確定した見積（ESTIMATE）を元に、請求書（docType=INVOICE）を生成する。

### 3.2 入力（最小）
- 元見積（確定済み）：
  - docName / docDesc / docPrice / docMemo
- 必要なら追加：
  - 支払期限（任意）
  - 振込先/支払方法（任意）

### 3.3 出力（生成物）
- docType = INVOICE
- docName（宛名）
- docDesc（請求内容）
- docPrice（金額：原則必須）
- docMemo（備考：任意、支払条件など）

### 3.4 ルール
- ESTIMATE が priceStatus=FINAL でない場合は原則 INVOICE を作らない（例外：手動で進める場合は docMemo に理由を明記）
- 金額は原則 docPrice を引き継ぐ（税/端数処理などは将来拡張）

### 3.5 不足情報（質問）
- docName/docDesc/docPrice が揃っていない場合は質問して補完する。
- 支払期限や支払方法は未設定でも作成可（docMemo に未確定と記載）。

## 4. 領収（RECEIPT）

### 4.1 目的
- 確定した請求（INVOICE）または入金情報を元に、領収書（docType=RECEIPT）を生成する。

### 4.2 入力（最小）
- 元請求（INVOICE）：
  - docName / docDesc / docPrice / docMemo
- 可能なら追加：
  - 受領日（任意）
  - 支払方法（任意：現金/振込など）

### 4.3 出力（生成物）
- docType = RECEIPT
- docName（宛名）
- docDesc（領収内容）
- docPrice（金額：原則必須）
- docMemo（備考：任意）

### 4.4 ルール
- 原則、INVOICE が invoiceStatus=PAID（入金済み）の場合に作成する
- 例外的に、現金受領などで手動作成する場合は docMemo に理由を明記する

### 4.5 不足情報（質問）
- docName/docDesc/docPrice が揃っていない場合は質問して補完する。
- 受領日や支払方法は未設定でも作成可（docMemo に未確定と記載）。

## 5. 受注（ORDER）

### 5.1 目的
- 見積（ESTIMATE）が確定した後、受注として案件を確定し、次工程（WORK/INVOICE）へ渡す。

### 5.2 入力（最小）
- 元見積（確定済み）：
  - docName / docDesc / docPrice / docMemo
- 可能なら追加：
  - 工事予定日（任意）
  - 担当者（任意）
  - ステータス（任意）

### 5.3 出力（生成物）
- ORDER（受注）レコード（将来：台帳/ID化）
- 最低限の保持項目：
  - customer/docName
  - scope/docDesc
  - amount/docPrice
  - notes/docMemo
  - status（例：CONFIRMED）

### 5.4 ルール
- 元見積が priceStatus=FINAL であることが原則
- 分割見積の場合、受注は「1案件に複数見積紐付け」または「見積ごとに受注」を選べる（将来拡張）
- 受注確定後、WORK と INVOICE を作成可能になる

<!-- WORK_SPEC_PHASE1 -->
## WORK（施工）— BUSINESS_SPEC（Phase-1）
### タスク投影（Todoist/ClickUp）— ライフサイクル表示と完了/復旧（固定）

#### 目的（固定）
- VOID/CANCEL/RESTORE/REOPEN を、現場（Todoist）・管理（ClickUp）のタスク表示に安全に反映し、見落としと誤操作を防ぐ。
- タスク名の既存契約（AA群／納品 分子/分母／末尾 `_ ` 自由文スロット保持）を破壊しない。

#### 表示（タイトル）規約（固定）
- タスク名は「先頭=AA群（または納品 分子/分母）」の規約を維持する（AAを先頭から外さない）。
- 末尾 `_ `（アンダースコア＋半角スペース）の自由文スロットは必ず保持する（更新でも消さない）。
- 表示タグは `_ ` の直前に付与する（AA群/納品表示を壊さない）:
  - VOID:  `[VOID]`
  - CANCEL: `[CANCEL]`
  - 例）`AA01 AA03 [CANCEL] _ `
  - 例）`納品 1/7 [VOID] _ `
- RESTORE（復旧）時は、`[VOID]` / `[CANCEL]` を除去する（元の表示へ戻す）。
- REOPEN（誤完了解除）は状態タグではなく「操作」であり、タイトルへ永続タグは付けない（コメントへ記録する）。

#### タスク状態（完了/復旧）規約（固定）
- VOID/CANCEL:
  - 結果が FREEZE（凍結＝Recovery Queue: BLOCKER/OPEN）になった場合：
    - タスクは自動完了しない（監督回収のためオープン維持）。
    - コメントに `[STATE] VOID/CANCEL + FREEZE` と理由（最小）を記録する。
  - FREEZE でない場合：
    - タスクは完了（Close）してよい（Todoist/ClickUp の完了操作）。
    - コメントに `[STATE] VOID/CANCEL` を記録する（監査用）。
- RESTORE:
  - 可能なら「完了済みタスクを復旧（Reopen/Uncomplete）」する。
  - 復旧できない実装の場合は「新規タスクを作成し、旧タスクへリンク（参照ID/URL）」する（増殖は許容、監査リンク必須）。
  - タイトルから `[VOID]` / `[CANCEL]` を除去する。
- REOPEN（誤完了解除）:
  - タスクは復旧（Reopen/Uncomplete）してよい（誤完了の訂正）。
  - コメントに `[OP] REOPEN` と対象（Order_ID/#n）を記録する。
  - VOID/CANCEL の状態を解除する操作ではない（混同禁止）。

#### コメント記録（固定）
- 状態/操作の記録はタスクコメントに最小で残す（監査用）:
  - `[STATE] VOID` / `[STATE] CANCEL` / `[STATE] RESTORE`
  - FREEZE の場合：`[STATE] VOID FREEZE` 等
  - 操作ログ：`[OP] REOPEN`
- [INFO] ブロックの上書き規約は維持する（`--- USER ---` 以下は触らない）。


### 目的
- 施工（WORK）を「受注（Order_ID）に紐づく現場作業の実行・完了報告」として定義し、
  完了同期（台帳確定・経費確定・在庫戻し）へ繋ぐ。

### 入力入口（不変）
- 現場の完了報告は「現場タスクの完了（完了コメント全文）」が唯一の正（master_spec 9章）。
- 施工の途中経過は、運用上のメモとして残してよいが、台帳確定のトリガーではない。

### 最小データ（業務要件）
- `workDoneAt`（完了日時）
- `workDoneComment`（完了コメント全文：未使用部材記載を含み得る）
- `photosBefore` / `photosAfter` / `photosParts` / `photosExtra`（任意：不足は管理警告）
- `videoInspection`（任意）
- `workSummary`（任意：要約の作り込みで業務判断を置換しない）

### 完了コメント規約（抽出）
- 未使用部材は、以下の書式で列挙できること（master_spec 9.3 準拠）：
  - 例）未使用：BP-YYYYMM-AAxx-PAyy, BM-YYYYMM-AAxx-MAyy
- 抽出結果は在庫戻し（STATUS=STOCK）へ利用される（LOCATION 整合が必須）

### 完了時に起きる業務（概要）
- Order の完了日時・状態更新・最終同期日時の更新。
- 部材（PARTS）の確定：
  - DELIVERED 部材の USED 化（使用確定）。
  - 未使用部材の STOCK 戻し（LOCATION 整合必須）。
- 経費（EXPENSE）の確定：
  - USED（使用確定）になった BP の PRICE を根拠に、確定経費として記録する。
- 不備（価格未入力 / 写真不足 / LOCATION 不整合 等）は管理警告対象。

### 禁止事項
- 人 / AI / UI が Order の STATUS / orderStatus を任意に確定・変更してはならない。
- 完了同期の代替として、別経路で台帳を確定させてはならない。

<!-- PARTS_SPEC_PHASE1 -->

<!-- PHASE1_PARTS_SPEC_BLOCK (derived; do not edit meaning) -->
### Phase-1: PARTS（部材）— 業務最小定義（派生）
参照（唯一の正）：
- master_spec: 3.4 Parts_Master / 3.4.1 Parts STATUS / 6 部材体系 / 7 UF06/UF07 / 9 完了同期。

最小目的：
- 部材（BP/BM）の発注→納品→使用→在庫の追跡を、Order_ID と PART_ID で破綻なく再現する。

業務状態（固定）：
- STOCK / ORDERED / DELIVERED / USED / STOCK_ORDERED。

最小トリガー（固定）：
- UF06（発注確定）: ORDERED または STOCK_ORDERED（Order_ID有無で判定）。
- UF06（納品確定）: DELIVERED（DELIVERED_AT 記録）。
- UF07（価格入力）: PRICE 確定（状態は原則維持）。
- 完了同期（現場完了起点）: DELIVERED の対象を USED へ（使用確定）。
- 未使用部材コメント抽出: STOCK 戻し（LOCATION 整合必須）。

不変条件（固定）：
- BP は納品時に PRICE を確定（未確定は警告対象）。
- BM は PRICE=0（経費対象外）。
- LOCATION は STATUS=STOCK の部材で必須。
<!-- END PHASE1_PARTS_SPEC_BLOCK -->
## PARTS（部材）— BUSINESS_SPEC（Phase-1）

### 目的
- 部材（PARTS）を「発注→納品→使用→在庫」の工程で追跡可能な業務として定義する。
- 受注（Order_ID）と部材（PART_ID/OD_ID/AA/PA/MA）を正しく接続し、完了同期で経費確定へ繋ぐ。

### 入力入口（不変）
- UF06（発注/納品）が工程の主入口（master_spec 7章）。
- UF07（価格入力）は BP の価格未確定を補完する入口（master_spec 7.3）。
- 価格/区分/状態の“確定”は業務ルールに従い、人/AI/UI が任意に決めない。

### 部材区分（BP/BM）
- BP（メーカー手配品）。
  - 納品時に PRICE を確定する（未確定は警告）。
- BM（既製品/支給品等）。
  - PRICE=0（経費対象外）。
- BP/BM の区分変更は危険修正（申請/FIX）に分類し、直接確定しない。

### 主要IDと接続（要点）
- PART_ID：部材の貫通ID（BP/BM体系）。
- AA：部材群の永続番号（タスク名へ反映）。
- PA/MA：枝番（BP=PA, BM=MA）。
- OD_ID：同一受注内の発注行補助ID。
- 接続の中心は Order_ID（受注）。
  - Order_ID の無い発注は STOCK_ORDERED として扱う（在庫発注）。

### STATUS（部材状態：固定）
- STOCK / ORDERED / DELIVERED / USED / STOCK_ORDERED。
- 変更は工程イベントにより行う（発注/納品/完了同期）。
- 人/AI/UI が任意に書き換えない。

### LOCATION（在庫ロケーション）
- STATUS=STOCK の部材は LOCATION を必須とする（欠落は管理警告）。
- 未使用部材の STOCK 戻しでも LOCATION 整合が必須。

### 発注（UF06: ORDER）業務（概要）
- 採用行のみを発注として確定する。
- 確定結果：。
  - PART_ID/OD_ID 発行。
  - STATUS=ORDERED（Order_ID 無しの場合は STOCK_ORDERED）。
  - BP は PRICE 未定、BM は PRICE=0。

### 納品（UF06: DELIVER）業務（概要）
- 確定結果：。
  - STATUS=DELIVERED。
  - DELIVERED_AT 記録。
  - BP は PRICE 入力必須（納品時確定）。
  - LOCATION 記録（在庫・管理に必要）。
  - AA群を抽出し、現場タスク名へ反映する。

### 価格入力（UF07）業務（概要）
- BP の PRICE 未入力を補完し、業務として価格を確定する。
- 部材STATUSは原則変更しない（価格確定のみ）。
- 価格未確定は管理警告の対象。

### 完了同期との関係（要点）
- 現場完了により、DELIVERED 部材が USED 化され、EX/Expense が確定される。
- 未使用部材は STOCK 戻し（LOCATION 整合必須）。

### 禁止事項
- ID の再利用/改変、AA 再発番。
- PRICE の推測代入。
- STATUS の任意変更。
- LOCATION 欠落の放置（警告として扱い、管理で回収）。

<!-- EXPENSE_SPEC_PHASE1 -->

<!-- PHASE1_EXPENSE_SPEC_BLOCK (derived; do not edit meaning) -->
### Phase-1: EXPENSE（経費）— 業務最小定義（派生）
参照（唯一の正）：
- master_spec: 3.6 Expense_Master / 3.6.1 Expense確定 / 9 完了同期 / 8.4.1 警告。

最小目的：
- USED（使用確定）になった BP の PRICE を根拠に、確定経費として一意に記録する。

確定トリガー（固定）：
- 完了同期（現場完了起点）でのみ確定（作成/追記）。

対象範囲（固定）：
- BP（メーカー手配品）: PRICE確定が前提（未確定は警告）。
- BM: PRICE=0（経費対象外／経費に入れない）。

不変条件（固定）：
- 推測代入は禁止（PRICEは確定値のみ）。
- 既存Expenseの削除は禁止（履歴保全）。
<!-- END PHASE1_EXPENSE_SPEC_BLOCK -->
## EXPENSE（経費）— BUSINESS_SPEC（Phase-1）

### 目的
- 経費（EXPENSE）を「確定した支出記録」として保持し、受注（Order_ID）へ接続する。
- 経費の“確定”は推測ではなく、確定入力（または完了同期で確定されたUSED部材）に限定する。

### 入力入口（不変）
- 完了同期により USED 部材の PRICE が経費として確定される（master_spec 9章 / Expense_Master）。
- 手動の経費追加は、確定情報（領収/金額/日付/対象）を入力できる入口（運用/将来UI）。
- 推測代入は禁止。

### 最小データ（業務要件）
- EXP_ID（経費ID：月内連番、再利用不可）。
- Order_ID（接続キー）。
- PART_ID（関連部材がある場合）。
- PRICE（確定金額）。
- USED_DATE（使用/支出日）。
- CreatedAt（記録日時）。

### 禁止事項
- PRICE 推測代入。
- EXP_ID 再発番/再利用。
- Order_ID 無しの経費混在（例外運用をする場合は別途定義して停止）。
## WARNINGS & BLOCKERS（Phase-1）

### 目的
- Phase-1 の運用で「完了同期を止めるべき不備（BLOCKER）」と、「同期は進めて管理で回収する不備（WARNING）」を固定する。
- 判定は人/AI/UI の恣意で変えず、本章の分類に従う。

### BLOCKER（完了同期を停止）
- LOCATION 不整合（在庫戻し対象の部材で LOCATION が欠落/不一致）。
- BP の PRICE 未確定（経費確定の根拠となる PRICE を確定できない）。

### WARNING（同期は進めるが管理回収）
- 写真不足（photosBefore / photosAfter / photosParts / photosExtra の不足）。
- 価格未入力（ただし「経費確定が必要な BP の PRICE 未確定」は BLOCKER）。
- 完了コメント抽出不備（未使用部材の抽出ができない/形式不備）。※在庫戻し対象がある場合は BLOCKER 扱いに昇格し得る。

### 参照（出典）
- WORK: 「不備（価格未入力 / 写真不足 / LOCATION 不整合 等）は管理警告対象」
- PARTS: PRICE/LOCATION の不変条件、未使用 STOCK 戻しの LOCATION 整合
- EXPENSE: PRICE は確定値のみ（推測代入禁止）
## EXCEPTIONS（Phase-1）

### 目的
- Phase-1 で「許可する例外」と「禁止する例外」を固定し、運用判断のブレを防ぐ。

### 許可（Phase-1 で扱う）
- Order_ID 無しの発注は「在庫発注」として許可する（STATUS=STOCK_ORDERED）。
  - 参照: PARTS（部材）章「Order_ID の無い発注は STOCK_ORDERED」。
  - 注: 後から Order に紐づけ直す運用を行う場合は、危険修正（申請/FIX）として扱い、別途手順を定義する。

### 禁止（Phase-1 では扱わない）
- Order_ID 無しの経費は禁止する（台帳混在させない）。
  - 必要な場合は Phase-2 で例外運用として別途定義してから解禁する。

### 補足（規約の再確認）
- BM は PRICE=0（経費対象外）であり、経費として記録しない。
## DoD（Phase-1）

### 目的
- Phase-1 が「運用として成立し、次フェーズへ進める」状態を、確認可能な条件で固定する。

### 完了条件（確認可能）
- WORK（施工）の完了同期を起点として、次が仕様どおりに確定されること：
  - Order（受注）：完了日時・状態・最終同期日時が更新される。
  - PARTS（部材）：DELIVERED → USED 化、および未使用部材の STOCK 戻し（LOCATION 整合必須）が行われる。
  - EXPENSE（経費）：USED（使用確定）になった BP の PRICE を根拠に確定経費が記録される。
- WARNINGS & BLOCKERS（Phase-1）の分類が適用されること：
  - BLOCKER は完了同期を停止する。
  - WARNING は同期は進め、管理で回収する。
- EXCEPTIONS（Phase-1）の例外規約が適用されること：
  - Order_ID 無しの発注（在庫発注）は STATUS=STOCK_ORDERED として扱える。
  - Order_ID 無しの経費は Phase-1 では禁止（混在させない）。
- 不変条件が破られないこと（破綻防止）：
  - PRICE の推測代入は禁止（確定値のみ）。
  - ID（EXP_ID 等）の再発番／再利用は禁止。
## UI/Form Capture Spec（Phase-2）

### 目的
- Phase-1 で固定した WORK / PARTS / EXPENSE / WARNINGS & BLOCKERS / EXCEPTIONS を、入力（フォーム/画面）として「何を・いつ・必須で」取得するかを固定する。
- 本章は入力仕様のみを扱い、業務ロジックの意味は Phase-1 各章に委譲する。

### 入力タイミング（固定）
- UF06（発注/納品）: PARTS の工程イベント入力。
- UF07（価格入力）: BP の PRICE 確定入力（原則 STATUS は変えない）。
- 現場完了（完了コメント）: WORK の完了同期起点（台帳確定・在庫戻し・経費確定）。

### 画面/フォーム別の最小入力項目

#### 1) 現場完了（WORK 完了報告）
- 必須:
  - `workDoneAt`（datetime）
  - `workDoneComment`（text; 未使用部材抽出対象）
- 任意（不足は WARNING）:
  - `photosBefore`（images[]）
  - `photosAfter`（images[]）
  - `photosParts`（images[]）
  - `photosExtra`（images[]）
  - `videoInspection`（video）
  - `workSummary`（text; 判断を置換しない）
- 入力後の検証（Phase-1 参照）:
  - 未使用部材の抽出に失敗 / 形式不備 → WARNING（在庫戻し対象がある場合は BLOCKER に昇格し得る）
  - LOCATION 不整合（在庫戻し対象） → BLOCKER
  - BP の PRICE 未確定（経費確定不可） → BLOCKER

#### 2) UF06（発注確定）
- 必須:
  - 対象行の採用（発注確定の意思）
- 自動/派生（入力しないが確認対象）:
  - PART_ID / OD_ID の発行
  - STATUS=ORDERED（Order_ID 無しの場合は STOCK_ORDERED）
  - BP は PRICE 未定、BM は PRICE=0
- 例外（Phase-1 EXCEPTIONS 参照）:
  - Order_ID 無し発注（在庫発注）: 許可（STOCK_ORDERED）

#### 3) UF06（納品確定）
- 必須:
  - 納品確定（DELIVER）
  - `DELIVERED_AT`（datetime）
  - （BPの場合）PRICE の確定入力（UF07 を使う運用でも可。ただし最終的に未確定は BLOCKER）
- 任意/運用:
  - LOCATION（在庫・管理に必要。STATUS=STOCK の場合は必須）
- 入力後の検証（Phase-1 参照）:
  - BP の PRICE 未確定 → BLOCKER（経費確定不可）
  - LOCATION 欠落（STOCK対象） → WARNING（在庫戻し対象では BLOCKER）

#### 4) UF07（価格入力）
- 対象:
  - BP の PRICE 未入力を補完する
- 必須:
  - `PRICE`（number; 推測代入禁止）
- 制約:
  - 原則 STATUS は変更しない（価格確定のみ）

#### 5) 経費の手動追加（将来UI/運用）
- Phase-1 方針:
  - Order_ID 無し経費は禁止（混在させない）
- 必須（許可する場合の最小セット）:
  - Order_ID / 金額（PRICE）/ 日付（USED_DATE）/ 対象（摘要）
## UI/Form Split & Validation（Phase-2）

### 目的
- UI/Form Capture Spec（Phase-2）で定義した入力を、実運用のフォーム/画面単位に分割して固定する。
- 送信時のバリデーション結果を WARNINGS & BLOCKERS（Phase-1）にマッピングし、処理の分岐（同期停止/管理回収）を固定する。

### 基本方針（固定）
- 送信は原則受け付ける（現場で入力を止めない）。
- ただし、BLOCKER に該当する場合は「完了同期を停止」し、管理回収（要対応）に回す。
- WARNING は同期は進め、管理回収（要確認）に回す。

### フォーム/画面の分割（固定）
1) 現場完了フォーム（WORK 完了報告）
2) UF06-ORDER（発注確定）
3) UF06-DELIVER（納品確定）
4) UF07-PRICE（価格入力）
5) EXPENSE-ADD（経費の手動追加：将来UI/運用）

### バリデーション（フォーム別）

#### 1) 現場完了フォーム（WORK 完了報告）
- 必須未入力 → BLOCKER
  - `workDoneAt` 未入力
  - `workDoneComment` 未入力
- BLOCKER（同期停止）
  - LOCATION 不整合（在庫戻し対象の部材で LOCATION が欠落/不一致）
  - BP の PRICE 未確定（経費確定が必要な BP の PRICE を確定できない）
- WARNING（同期継続＋管理回収）
  - 写真不足（photosBefore / photosAfter / photosParts / photosExtra の不足）
  - 完了コメント抽出不備（未使用部材抽出ができない/形式不備）
    - 注：在庫戻し対象がある場合は BLOCKER に昇格し得る

#### 2) UF06-ORDER（発注確定）
- BLOCKER（送信拒否ではなく、確定処理を停止）
  - 対象行の採用が無い（発注確定意思が不明）
- EXCEPTIONS（Phase-1 参照）
  - Order_ID 無し発注は許可（在庫発注: STATUS=STOCK_ORDERED）

#### 3) UF06-DELIVER（納品確定）
- 必須未入力 → BLOCKER
  - `DELIVERED_AT` 未入力
- BLOCKER
  - （BP）PRICE が最終的に未確定（経費確定不可）
- WARNING
  - LOCATION 欠落（STATUS=STOCK 対象で LOCATION が未入力）
    - 注：在庫戻し対象（未使用戻し）が発生する場合は BLOCKER に昇格し得る

#### 4) UF07-PRICE（価格入力）
- 必須未入力 → BLOCKER
  - `PRICE` 未入力
- BLOCKER
  - PRICE が推測代入（根拠無し）※運用上禁止
- 制約
  - STATUS は原則変更しない（価格確定のみ）

#### 5) EXPENSE-ADD（経費の手動追加：将来UI/運用）
- Phase-1 方針（固定）
  - Order_ID 無し経費は禁止（混在させない）→ BLOCKER
- 必須未入力 → BLOCKER
  - Order_ID / PRICE / USED_DATE / 対象（摘要）
## Form → Ledger Mapping（Phase-2）

### 目的
- フォーム入力を「どの台帳（Ledger）へ、どの最小フィールドとして記録するか」を固定し、実装を一本道にする。
- 詳細スキーマ（列構造/型/正規化）は master_spec を唯一の正として参照し、本章は “最低限の対応付け” に限定する。

### 台帳（Ledger）と最小フィールド（固定）
- Order（受注）:
  - Order_ID
  - workDoneAt / workDoneComment（完了同期の根拠）
  - orderStatus / STATUS（完了同期により更新）
  - lastSyncedAt（最終同期日時）
- Parts（部材）:
  - PART_ID / OD_ID / Order_ID（接続）
  - STATUS（ORDERED / DELIVERED / USED / STOCK / STOCK_ORDERED）
  - DELIVERED_AT
  - PRICE（BP のみ確定値）
  - LOCATION（STATUS=STOCK のとき必須）
- Expense（経費）:
  - EXP_ID
  - Order_ID
  - PART_ID（関連がある場合）
  - PRICE（確定値のみ）
  - USED_DATE
  - CreatedAt
- Warnings / Blockers（管理回収）:（= Recovery Queue）
  - Order_ID
  - category（BLOCKER / WARNING）
  - reason（例：PRICE未確定 / LOCATION不整合 / 写真不足 / 抽出不備 / 必須未入力）
  - detectedAt（検出日時）
  - detectedBy（検出契機：WORK完了 / UF06 / UF07 / 手動）
  - details（原文/補足：例 完了コメント、写真不足の内訳 等）
  - status（OPEN / RESOLVED）
  - resolvedAt（解消日時）
  - resolvedBy（解消者）
  - resolutionNote（解消メモ）
  - Order_ID 無し経費 → BLOCKER（Phase-1 方針）
## ID Issuance & UI Responsibility（Phase-2）

### 目的
- ID（採番）を「いつ・誰（どの処理）が・どの入力を根拠に」発行するかを固定し、実装・運用のブレを防ぐ。
- 再発番/再利用は禁止（Phase-1 不変条件）を前提とする。

### 対象ID（本章で固定する範囲）
- PART_ID（部材ID）
- OD_ID（同一受注内の発注行補助ID）
- AA / PA / MA（部材群/枝番：タスク名へ反映）
- EXP_ID（経費ID：月内連番）

### 発行タイミングと責務（固定）

#### PART_ID / OD_ID
- 発行タイミング: UF06-ORDER（発注確定）で「採用行確定」した瞬間に発行する。
- 発行責務: UF06-ORDER の確定処理（人/AI/UI の恣意ではなく処理が発行する）。
- 例外: Order_ID 無し発注（在庫発注）は許可し、STATUS=STOCK_ORDERED として発行する（Phase-1 EXCEPTIONS 参照）。

#### AA / PA / MA（タスク名・枝番体系）
- 発行タイミング:
  - AA: 部材群の永続番号として、PART_ID 発行時に確定する（タスク名へ反映）。
  - PA/MA: 枝番として、BP=PA / BM=MA を PART_ID 発行時に確定する。
- 発行責務: PART_ID 発行処理（UF06-ORDER）で確定し、後からの任意変更は行わない。
- 変更扱い: BP/BM 区分変更や枝番変更は危険修正（申請/FIX）として別途扱う（Phase-1: PARTS 参照）。

#### EXP_ID
- 発行タイミング:
  - 完了同期（現場完了起点）で EXPENSE を確定する瞬間に発行する。
  - 手動経費追加（将来UI/運用）で経費を確定する瞬間に発行する。
- 発行責務: EXPENSE の確定処理（台帳記録処理）が発行する。
- 禁止: 再発番/再利用は禁止（履歴保全）。

### UIの責務（固定）
- UI は ID を入力させない（表示・参照は許可）。
- UI は「確定の意思」を入力させる（採用行確定、納品確定、価格確定、完了報告）。
- ID 発行は確定処理が行い、UI は発行結果を表示する。
## Integration Contract（Phase-2｜Todoist×ClickUp×Ledger 統合契約）

### 目的
- Todoist（現場）と ClickUp（管理）を併用しつつ、台帳（Ledger）を唯一の正として破綻なく同期するための契約を固定する。
- 「双方向」「スイッチ」「更新（再同期）」「競合」「冪等」を曖昧にせず、汚染・バグの再発を防ぐ。
- 実装手段（GAS/関数名/Webhook方式等）は定義しない（運用契約のみ）。業務の意味は master_spec を唯一の正として参照する。

### 正の階層（Authority｜固定）
- Ledger（台帳：Sheets 等）：業務データの唯一の正（Order/Parts/Expense/Request/Recovery Queue 等）。
- Orchestrator（業務ロジック）：正式値（住所/ID/STATUS/PRICE/健康スコア/警告）を確定する唯一の決定者（実装手段は問わない）。
- Field UI（現場 UI）：完了報告の起点 UI。現場の入力は「素材」であり、確定は Orchestrator が行う。
- Management UI（管理 UI）：監督・警告受信・優先度管理。**入力禁止（確定値を作らない）**。
- AI補助：素材抽出・監査・警告候補のみ（判断禁止）。

### 双方向同期の定義（固定）
本契約における「双方向」とは、**相互に確定値を書き換え合うことではない**。
- Ledger → UI（投影）：Ledger の確定情報を、現場/管理 UI へ参照情報として反映する。
- UI → Ledger（素材入力）：UI で許可された入力（例：現場完了コメント）を、確定処理の素材として受け取る。
禁止：
- 管理 UI（ClickUp）からの入力を Ledger の確定値として取り込むこと。
- UI が STATUS / PRICE / ID 等を確定すること。

### 同期対象（最小セット｜固定）
1) Ledger → Field UI（現場）
- Order_ID
- 顧客名（表示用）
- addressCityTown（正式値）
- 媒体（表示用）
- AA群（必要時：タスク名反映）

2) Ledger → Management UI（管理）
- Order_ID / 顧客名 / addressCityTown
- STATUS（参照のみ）
- alertLabels（参照のみ）
- 健康スコア（参照のみ）
- 未処理（OPEN）有無（Request / Recovery Queue）
- BLOCKER/WARNING の要点（理由・対象ID）

3) UI → Ledger（素材として受けるもの）
- 現場完了：完了日時、完了コメント全文（未使用部材抽出素材）
- 追加報告：写真・説明等（確定は Orchestrator）
- 価格入力：確定値のみ（推測代入禁止）

### スイッチ（切替）の意味（固定）
切替は「併用を成立させる統治スイッチ」であり、入力経路や同期範囲を安全に制御する。
- IntegrationMode（統合モード）：
  - DUAL（標準）：現場 UI + 管理 UI に投影する。
  - FIELD_ONLY：現場 UI のみ投影する。
  - MGMT_ONLY：管理 UI のみ投影する（例外運用）。
  - LEDGER_ONLY：外部連携を停止し台帳のみで運用する。
- FieldSource（現場完了の唯一入口）：**TODOIST** を唯一の正として固定する（併用は競合が常態化するため原則禁止）。
- maintenanceMode：master_spec の定義に従い、true の間は更新系を停止し閲覧・検査・ログを優先する（連携も停止側へ寄せる）。

### 冪等（Idempotency）と更新（再同期）の契約（固定）
- 次のイベントは冪等でなければならない：
  - UF01 / UF06（発注・納品）/ UF07 / UF08 / 完了同期 / 更新（再同期）
- 同一イベントの重複到達（再送・二重起動）は、結果を増殖させない（二重行・二重通知禁止）。
- 更新（再同期）は「Ledger の確定状態を UI に再投影して整合を回復する」ことを主目的とする。
  - UI の値で Ledger を上書きする用途に使用しない。

### 競合・破綻の扱い（固定）
競合例：
- 同一 Order_ID に対して短時間に複数の完了イベントが到達する。
- 入力素材（完了コメント等）が一致しない。
- Ledger の確定状態と UI 投影が不整合になる。
処理：
- 自動で辻褄合わせをしない。
- **Recovery Queue（OPEN）へ登録**し、監督回収に寄せる。
- 勝手に RESOLVED にしない（解消は根拠を伴う）。

### 観測（ログ）最小要件（固定）
- 重要イベント（UF/完了/再同期/競合/回収）は logs/system（または同等の台帳ログ）に必ず記録する。
- 記録は監督の根拠であり、UI/人が確定値を作るために使用しない（判断権の原則）。

### 再同期（Reconcile / Resync）責務（固定）

- 定義（固定）:
  - 再同期とは「Ledger（台帳）の確定状態を UI に再投影して整合を回復する」ことである。
  - UI の値で Ledger を上書きする用途に使用しない（UI→Ledger は素材入力のみ）。
- トリガ（固定）:
  - 手動（管理の指示）
  - BLOCKER 解消後（回収完了）
  - 定期（任意：運用で採用する場合のみ。実装PRで固定）
- 入力（最小セット｜固定）:
  - Order_ID
  - target（Order / Parts / Expense / Recovery Queue）
  - reason（なぜ再同期するか）
  - requestedAt（要求時刻）
- 競合（固定）:
  - 再同期の結果、競合（Ledger と UI の不整合、重複イベント、素材不一致）が検出された場合は自動で辻褄合わせをしない。
  - Recovery Queue（OPEN）へ登録し、監督回収へ寄せる。
- 冪等（固定）:
  - resyncKey = Hash(Order_ID + target + reason + requestedId)
  - 同一 resyncKey の再実行は「結果を増殖させない」（重複通知・重複タスク禁止）。
- 出力（固定）:
  - projectedAt（投影時刻）
  - diffSummary（投影差分の要約）
  - ledgerHead（投影に使った Ledger の基準（例：hash/timestamp））

## Recovery Queue（Phase-2）

### 目的
- WARNINGS & BLOCKERS（Phase-1）で検出された不備を、運用で確実に回収・解消するための「回収キュー」を固定する。
- 実装（GAS/UI/タスク）はこの仕様に従って “登録→通知→解消→記録” を行う。

### 登録対象（固定）

- CANCELLED : 取消（誤検知/重複/不要化により回収対象から外す。記録は残す）
最小ルール（固定）:
- CANCELLED にする場合は resolvedAt/resolvedBy/resolutionNote を記録してよい（根拠の明文化）。
- category: BLOCKER / WARNING
- reason: 例）PRICE未確定 / LOCATION不整合 / 写真不足 / 抽出不備 / 必須未入力
- Order_ID（原則必須）
- PART_ID（関連がある場合）
- detectedAt（検出日時）
- detectedBy（検出契機：WORK完了 / UF06 / UF07 / 手動）
- details（原文/補足：例 完了コメント、写真不足の内訳 等）
- status（OPEN / RESOLVED）
- resolvedAt（解消日時）
- resolvedBy（解消者）
- resolutionNote（解消メモ）

### 発生時の動作（固定）
- BLOCKER:
  - 完了同期を停止（処理を中断し、回収キューへ登録する）。
  - 回収が完了するまで “再同期” しない（または再同期しても同じ BLOCKER で停止する）。
- WARNING:
  - 同期は継続し、回収キューへ登録する（運用で回収）。
  - 次回以降の同期で自動解消はしない（人の解消を原則とする）。
### どこへ記録するか（実装境界｜固定）

- 唯一の正（Authority）は Ledger（台帳）である。
- Recovery Queue は Ledger に「回収キュー台帳」として 1 行で記録する（例：Sheets の Recovery_Queue シート）。
- Todoist / ClickUp は “投影（通知・作業管理）” であり、Ledger の確定値を上書きしない（管理UI入力禁止の原則）。
- 相互参照（固定）:
  - Ledger 行に taskIdTodoist / taskIdClickUp / url 等の参照IDを保持する（作業はタスクで進めてもよいが、状態の唯一の正は Ledger）。
- 冪等（固定）:
  - 登録キー（例）rqKey = Hash(Order_ID + category + reason + detectedBy + detectedAt)
  - 同一 rqKey の再登録は「新規行を増やさず」更新で吸収する（重複通知・重複タスク禁止）。
- 解消（固定）:
  - status を RESOLVED に更新し、resolvedAt / resolvedBy / resolutionNote を記録する。
  - Todoist/ClickUp の完了は “投影の反映” として行ってよいが、Ledger を自動で RESOLVED にしてはならない（根拠付き更新のみ）。


- 実装では、次のいずれか（または併用）でよい：
  - 台帳（Sheets 等）に 1 行として追記
  - タスク（Todoist 等）を起票し、台帳には参照IDを残す
（採用する実装先は Phase-2 の実装PRで固定する）

### 解消の定義（固定）
- PRICE未確定: 対象 BP の PRICE を確定値として入力済みであること（推測代入禁止）。
- LOCATION不整合: 対象部材の LOCATION が整合し、STOCK 戻しが可能であること。
- 写真不足: 必要写真が追補されたこと（不足の内訳は details に記録）。
- 抽出不備: 完了コメントの形式が修正され、未使用部材の抽出が可能であること。
### Request linkage（固定）

#### 位置づけ（固定）
- Recovery Queue は「不備回収の運用キュー」であり、Request は「申請台帳（master_spec 3.7）」である。
- いずれも OPEN を“未処理”として扱うが、意味は異なるため混同しない（Recovery=回収、Request=申請）。
- UI/人が勝手に RESOLVED/CANCELLED を確定しない（解消は根拠と記録を伴う）。

#### 連携ルール（最小｜固定）
- BLOCKER/WARNING を検出したら、まず Recovery Queue に status=OPEN で登録する（冪等）。
- 次に該当する場合は、Request も併せて status=OPEN で登録してよい（推奨）：
  - BP の PRICE 未確定 → Request.Category=UF07（targetType=PART_ID / targetId=PART_ID / partId=PART_ID / price=確定値）
  - LOCATION 不整合 / 抽出不備 / 写真不足 / 監督判断が必要 → Request.Category=REVIEW（targetType=Order_ID / targetId=Order_ID）
- 既に対応する Request（OPEN）が存在する場合は、重複作成せず「参照リンク（参照ID/URL等）」のみを残す（冪等・増殖防止）。

#### 理由→推奨アクション（固定）
- PRICE未確定（BP）:
  - Recovery Queue: BLOCKER / OPEN
  - Request: UF07 を推奨（価格確定の申請）
- LOCATION不整合（在庫戻し対象）:
  - Recovery Queue: BLOCKER / OPEN
  - Request: REVIEW を推奨（監督判断/是正の回収）
- 写真不足:
  - Recovery Queue: WARNING / OPEN（Phase-1 の分類に従属）
  - Request: REVIEW（MISSING_INFO）を推奨（追補回収）
- 抽出不備（未使用部材/完了コメント書式）:
  - Recovery Queue: WARNING / OPEN（在庫戻し対象が実在し処理停止が必要な場合は BLOCKER に昇格し得る）
  - Request: REVIEW を推奨（追補・監督回収）

#### 解消（RESOLVED）の定義（固定）
- Recovery Queue を RESOLVED にしてよい条件は、master_spec の確定データが整合し、不備が解消していること。
  - PRICE未確定 → Parts_Master.PRICE が確定値で埋まり、対象の警告（ALERT_PRICE_MISSING 等）が消える。
  - LOCATION不整合 → 対象部材の LOCATION が整合し、STOCK 戻しが可能である。
  - 写真不足 → DONE/CLOSED の要件を満たし、写真不足フラグが解消している。
  - 抽出不備 → 未使用部材抽出が成功し、必要な在庫戻し/記録が完了している。
- Request を併設した場合：
  - RequestStatus=RESOLVED/CANCELLED になったとき、対応する Recovery Queue は RESOLVED にしてよい（ただし上記の台帳整合が満たされていること）。
  - RequestStatus=OPEN の間は、Recovery Queue を勝手に RESOLVED にしない。

### 冪等（Recovery Queue 登録）【固定】
- 登録は必ず冪等でなければならない（再送・二重起動で増殖しない）。
- 推奨 idempotencyKey（固定要素）：
  - Order_ID + reason + detectedBy + (PART_ID がある場合は PART_ID)
- 同一 idempotencyKey は 1 件に正規化し、二重登録は「同一案件の再観測」として扱う（details の追記は許容、行増殖は禁止）。

### IdempotencyKey（イベント別｜固定）

#### 目的（固定）
- 再送・二重起動・順序逆転が起きても、台帳（Ledger）が増殖せず、状態が破綻しないことを保証する。
- ここで定義する idempotencyKey は「同一イベント判定」の唯一の基準とする。

#### 共通フォーマット（固定）
- idempotencyKey は次の要素で構成する（区切りは実装でよい。要素の意味は固定）：
  - eventType（固定語）
  - primaryId（Order_ID または PART_ID 等。イベントの主対象）
  - eventAt（イベント確定時刻：入力/受信の確定時刻）
  - sourceId（任意：外部イベントID等。取得できる場合のみ）

- primaryId が確定できない場合は Runtime 破綻として扱い、Recovery Queue に OPEN 登録する（増殖防止）。

#### イベント別（固定）
1) UF01（受注登録）
- eventType: UF01_SUBMIT
- primaryId: Order_ID
- eventAt: UF01 登録の確定時刻
- sourceId: 任意（媒体側の通知ID等）

2) UF06-ORDER（発注確定）
- eventType: UF06_ORDER
- primaryId: PART_ID（発行後は PART_ID を主対象とする）
- eventAt: 発注確定時刻
- sourceId: 任意

3) UF06-DELIVER（納品確定）
- eventType: UF06_DELIVER
- primaryId: PART_ID
- eventAt: 納品確定時刻（DELIVERED_AT）
- sourceId: 任意

4) UF07-PRICE（価格確定）
- eventType: UF07_PRICE
- primaryId: PART_ID
- eventAt: 価格確定時刻
- sourceId: 任意

5) UF08（追加報告）
- eventType: UF08_SUBMIT
- primaryId: Order_ID
- eventAt: 追加報告確定時刻
- sourceId: 任意

6) WORK 完了（現場完了）
- eventType: WORK_DONE
- primaryId: Order_ID
- eventAt: workDoneAt（完了日時）
- sourceId: 任意（現場UI側イベントID等）

7) 更新（再同期）
- eventType: RESYNC
- primaryId: Order_ID（Order 単位の再同期）または NONE（全体再同期）
- eventAt: 再同期の開始時刻
- sourceId: 任意

#### 重複イベントの扱い（固定）
- 同一 idempotencyKey のイベントが再到達した場合：
  - Ledger を増殖させない（二重行追加・二重通知禁止）。
  - “同一イベントの再観測”として扱い、details/log の追記は許容する（ただし台帳の主要レコード増殖は禁止）。
- idempotencyKey が異なるが、同一 primaryId に対して短時間に競合が発生した場合：
  - 自動で辻褄合わせをしない。
  - Recovery Queue（OPEN）へ登録し、監督回収に寄せる（Integration Contract に従属）。

### Runtime Audit Checklist（expected/unexpected｜固定・参照用）

#### 目的（固定）
- 実行後に「必ず起きるべき副作用（expected effect）」と「起きてはならない副作用（unexpected effect）」を、イベント別に一覧化し、監査の探し回りをゼロにする。
- 本節は監査観点の固定であり、実装方法・ログ形式の詳細は別テーマで扱う。

#### 監査の原則（固定）
- expected effect が欠落している場合：Runtime NG（破綻）として扱い、Recovery Queue（OPEN）へ登録する。
- unexpected effect が発生した場合：Runtime NG（破綻）として扱い、Recovery Queue（OPEN）へ登録する。
- 自動で辻褄合わせをしない（Integration Contract に従属）。

#### イベント別 expected effect（最小｜固定）
1) UF01_SUBMIT（受注登録）
- Order_YYYY に 1 行以上の追加（Order_ID が発行済みである）
- CU_Master / UP_Master は「新規 or 再利用」のいずれかが成立している（参照整合が壊れていない）
- logs/system 相当へ記録が残る（参照用）

2) UF06_ORDER（発注確定）
- Parts_Master に新規行追加（PART_ID / OD_ID / STATUS=ORDERED or STOCK_ORDERED）
- BP の PRICE は未確定を許容（BM は PRICE=0 固定）
- Order_ID 無し発注は STOCK_ORDERED として扱われる（Phase-1 EXCEPTIONS）

3) UF06_DELIVER（納品確定）
- Parts_Master の対象 PART_ID が STATUS=DELIVERED へ遷移
- DELIVERED_AT が記録されている
- BP の PRICE は最終的に確定値で埋まる（未確定は BLOCKER として回収される）

4) UF07_PRICE（価格確定）
- Parts_Master の対象 PART_ID に PRICE が確定値で記録される
- STATUS は原則変更しない（価格確定のみ）

5) UF08_SUBMIT（追加報告）
- 追加報告の記録が残る（logs/extra または Request/相当台帳）
- OV01 参照で追跡可能な形（Order_ID 接続）が成立している

6) WORK_DONE（現場完了）
- Order の完了根拠（workDoneAt / workDoneComment）と最終同期が記録される
- DELIVERED 部材の USED 化が成立する（対象が USED へ遷移）
- BP（USED）の PRICE を根拠に Expense が確定記録される（EXP_ID 発行）
- 未使用部材が抽出され、在庫戻し（STOCK）と LOCATION 整合が成立する（不整合は BLOCKER 回収）

7) RESYNC（更新／再同期）
- Ledger の確定状態が UI（現場/管理）へ再投影される（参照整合が回復する）
- 冪等：同一 RESYNC の再実行で台帳が増殖しない

#### イベント別 unexpected effect（代表例｜固定）
共通（全イベント）：
- ID 再発番／再利用（Order_ID / PART_ID / EXP_ID 等の重複・改変）
- 二重行増殖（同一 idempotencyKey で主要台帳が増える）
- 異常日付（未来日／逆転）を確定値として保存
- 本番とテストの混在（テストIDの本番混入）

UF系（入力）：
- 入力禁止経路（管理UI等）からの確定値書込みが発生する

完了同期：
- PRICE 推測代入で Expense を確定してしまう
- LOCATION 欠落のまま STOCK 戻しが完了扱いになる

#### NG 時の出力（固定）
- NG は Recovery Queue（OPEN）へ登録する（reason / detectedBy / details / idempotencyKey）。
- 必要に応じて Request（REVIEW）を併設して監督回収に寄せる（Request linkage に従属）。

### RuntimeSelfTest（テスト走行｜固定）

#### 目的（固定）
- Runtime監査（expected/unexpected）が実運用で機能することを、**本番データに触れず**に検証する。
- 汚染（本番とテスト混在）を絶対に起こさない形で、UF/完了同期/回収の最短ループを通す。

#### 実行タイミング（固定）
- 次のいずれかに該当する変更を main へ入れる前に、必ず 1 回実行する：
  - UF01/UF06/UF07/UF08/FIX/DOC/完了同期/更新（再同期）に関わる変更
  - Idempotency / Recovery Queue / Request linkage / Runtime Audit Checklist に関わる変更
  - 外部連携（Todoist/ClickUp/AI補助）の経路に関わる変更
- 入口整備や文言のみ（意味変更なし）の変更では必須としない（任意）。

#### テストデータ規約（固定）
- テスト走行は **テストID（0番）**を用い、本番と混在させない。
- テストデータは集計/閲覧/検索の対象外とする（本番汚染防止）。
- 既存のテストID規約（master_spec）に従属する。

#### テストシナリオ（最小｜固定）
1) UF01_SUBMIT：テスト受注を 1 件登録（Order_ID 発行）
2) UF06_ORDER：テスト部材を発注として登録（PART_ID/OD_ID、STATUS=ORDERED）
3) UF06_DELIVER：納品確定（STATUS=DELIVERED、DELIVERED_AT 記録）
4) UF07_PRICE：BPのPRICE確定（推測代入禁止）
5) UF08_SUBMIT：追加報告を 1 件記録（Order_ID 接続）
6) FIX_SUBMIT：修正申請を 1 件記録（危険修正は確定しない）
7) DOC_SUBMIT：書類申請を 1 件記録
8) WORK_DONE：完了同期を実行し、USED/EXP/在庫戻し（必要なら未使用部材コメント）まで通す

#### 合格条件（固定）
- Runtime Audit Checklist の expected effect がイベント別に満たされる。
- unexpected effect が発生しない（特に：ID再発番、二重行増殖、本番混入）。
- NG の場合は自動で辻褄合わせをせず、Recovery Queue（OPEN）へ登録される（回収導線が成立する）。

### Rollback（連続NG時の安定復旧｜固定）

#### 目的（固定）
- 連続する Runtime NG（破綻）により運用が停滞した場合に、**最短で安定状態へ戻す**ための公式手順を固定する。
- 原因推測ではなく「観測→回収→復旧」を優先し、汚染の拡大を防ぐ。

#### 発動条件（固定）
- 同一テーマ（同一変更）に起因する Runtime NG が連続して発生し、回収（Recovery Queue）で解消できない状態が続く場合。

#### 取扱い（固定）
- 自動で辻褄合わせをしない。
- 最後に安定していた確定状態（Sで確定している状態）へ戻し、運用を再開する。
- rollback が発生した場合は、必ず logs/system 相当へ記録し、Recovery Queue（OPEN）へ「rollback発生」を登録する（監督回収）。

#### 注意（固定）
- rollback は「失敗の隠蔽」ではなく、汚染拡大を止めるための安全装置である。
- rollback 後は、原因の是正を別テーマ（別PR）で行い、再度 RuntimeSelfTest を通す。

### Self-Diff（矛盾検知｜警告のみ｜固定）

#### 目的（固定）
- AI/文書更新の過程で「直前の確定内容」と矛盾する可能性を検知した場合に、破綻前に止める。
- 仕様の勝手な書換えを防ぎ、差分（diff）方式を守る。

#### ルール（固定）
- 矛盾の可能性を検知した場合、AIは「警告」を出して停止してよい（勝手に修正しない）。
- 解決は必ず B（人間判断）→ diff → 反映（1テーマ=1PR）の順で行う。
- Self-Diff は判断ではなく、矛盾候補の提示に限定する。

### S→Apps Script 同期（全文貼替のみ｜固定）

#### 目的（固定）
- 実装反映における部分編集・手修正による破綻を防ぎ、監査と再現性を担保する。

#### ルール（固定）
- Apps Script 側への反映は「確定済み成果物（S）を全文貼替」する方式のみ許可する。
- 部分編集・差分編集・行単位の追加削除は原則禁止とする（事故防止）。
- 反映の前後で RuntimeSelfTest を通し、expected/unexpected の監査を成立させる。

### 更新（再同期）対象範囲（固定）

#### 目的（固定）
- 「更新（再同期）」の意味を一意にし、復旧と整合回復を最短化する。
- 冪等であり、何度実行しても台帳が増殖しないことを前提とする。

#### 最小対象（固定）
- Ledger（台帳）側の整合回復：
  - Order/Parts/EX/Expense/Request/Recovery Queue の参照整合
  - alertLabels / 健康スコアの再計算（冪等）
- UI投影の再構築（Ledger → UI）：
  - 現場UI（Todoist）への参照情報再投影（必要ならタスク名/要点）
  - 管理UI（ClickUp）への監督情報再投影（STATUS/警告/OPEN回収）
- 競合が検出された場合：
  - 自動で辻褄合わせをせず、Recovery Queue（OPEN）へ登録する。

#### 禁止（固定）
- UI側の値で Ledger の確定値を上書きする用途に「更新」を使わない。

### logs/system 保存仕様（Drive JSON + Sheet Index｜固定）

#### 目的（固定）
- 監査・追跡・原因調査のために、イベントログを長期に保持しつつ、確定申告/集計を阻害しない。

#### 保存方式（固定）
- 詳細ログ：Drive に JSON として保存する（イベント単位または日次単位等。実装で選ぶ）。
- 集計用インデックス：Sheet に最小列で保持する（確定申告・月次集計はここを参照できること）。

#### インデックス最小列（固定）
- date（YYYY-MM-DD）
- eventType
- Order_ID（該当する場合）
- PART_ID（該当する場合）
- severity（INFO/WARNING/BLOCKER）
- idempotencyKey
- driveFileId（またはURL参照）
- memo（任意：短文）

#### PII マスキング（必須｜固定）
- 電話・住所等のPIIは、logs/system（詳細ログ/インデックス）に保存する前にマスキングする（漏えい防止）。
- マスキングの有無で情報価値が落ちる場合は、Ledgerの正式列に保持し、ログには複製しない（判断権の原則）。

#### ローテーション（固定）
- 容量・ファイル数の増加に備え、日次/月次でアーカイブ・圧縮等のローテーションを行ってよい（実装テーマで確定）。

### 縮退運用（enabled=false｜固定）

#### 目的（固定）
- 外部連携が利用できない場合でも業務を停止させず、確定処理を破綻させない。

#### 基本原則（固定）
- 外部連携が無効の間は「入力禁止経路」から確定値を作らない。
- 代替導線は Ledger（台帳）側に寄せ、UI投影は停止してよい。

#### 代表ケース（固定）
- Todoist（現場UI）が無効：
  - 現場完了（WORK_DONE）の入力は Ledger 側の完了入力（フォーム/運用）へ縮退する。
  - idempotencyKey と Recovery Queue を維持し、二重確定を防ぐ。
- ClickUp（管理UI）が無効：
  - 警告・回収は Recovery Queue（OPEN）を唯一の回収箱として運用し、監督は Ledger/OV01 側で行う。
- AI補助が無効：
  - 素材抽出・違和感候補は停止し、業務ロジックの確定のみで進める。
- 住所API等が無効：
  - 既存の確定ルールに従い、曖昧さは REVIEW 回収へ寄せる。

### Webhook 再送・重複（リトライ/レート制限）契約（固定）

#### 目的（固定）
- 再送・重複・一時失敗が起きても、台帳が増殖せず、確定が二重化しないことを保証する。

#### 契約（固定）
- 受信イベントは必ず idempotencyKey で重複排除する（IdempotencyKey 節に従属）。
- 再送は許容するが、同一 idempotencyKey は “同一イベントの再観測” として扱い、主要台帳の増殖は禁止。
- rate limit / 一時障害時は、リトライを行ってよい（実装方式は別）。最終的に失敗した場合：
  - logs/system に記録し、Recovery Queue（OPEN）へ登録する（監督回収）。

#### 禁止（固定）
- リトライのたびに台帳へ新規行を追加する（増殖）。
- 管理UIからの入力で確定処理を代替する（入力禁止経路）。

## Comment Concierge & Task Presentation（Phase-2）

## Order Lifecycle Controls（Phase-2）— 欠番/削除/復旧/誤完了解除（トゥームストーン方式）

### 目的（固定）
- 「欠番（VOID）」「削除（CANCEL/DELETE）」「復旧（RESTORE）」「誤完了解除（REOPEN/UNDELIVER）」を、監査可能かつ事故耐性の高い方式で固定する。
- 物理削除（行削除／履歴消去）を禁止し、台帳（Ledger）に“事実”として残す（トゥームストーン）。
- 在庫（PARTS）・経費（EXPENSE）・回収（Recovery Queue / Request）へ、冪等かつ安全に接続する（自動辻褄合わせ禁止）。

### 用語と定義（固定）
- 欠番（VOID）:
  - Order_ID が発行されたが、業務として成立しなかった（誤作成／重複／即取消）。
  - 原則：請求／領収／完了同期の対象にしない。
- 削除（CANCEL/DELETE）:
  - 成立していたが取り下げた（キャンセル）。
  - 原則：以後の更新・同期を止める（ただし“存在した事実”は残す）。
- 復旧（RESTORE）:
  - VOID/CANCEL を取り消し、再び運用対象へ戻す。
  - 原則：復旧に伴う不整合は自動で補正せず、Recovery Queue（OPEN）へ回収する。
- 誤完了解除（REOPEN / UNDELIVER）:
  - DELIVERED / WORK_DONE 等の誤り訂正（欠番/削除とは別物）。
  - 原則：欠番/削除と混ぜない（会計・在庫・監査が破綻するため）。

### 大原則（固定）
- 物理削除は禁止（Order/Parts/Expense/Request/Recovery Queue の履歴を消さない）。
- 自動で辻褄合わせをしない（Integration Contract の「競合・破綻の扱い」に従属）。
- UI（現場/管理）・AI補助は確定値を作らない（Authority 原則に従属）。
- すべての操作は冪等であること（IdempotencyKey で重複排除）。
- 危険域（在庫・経費・請求に影響する領域）に触れる場合は「凍結→回収」を優先する。

### 在庫（PARTS）に対する「解放」と「凍結」（固定）
本節における解放/凍結は、「部材のSTATUSを恣意に変える」ことではない。
STATUSは Phase-1: PARTS の不変条件に従属し、任意変更はしない。

#### 解放（RELEASE｜安全域のみ）
- 対象：当該 Order に紐づく部材のうち、次を満たす“安全域”のみ。
  - まだ業務確定（納品/使用/経費確定）へ影響していないと判定できるもの。
- 効果：
  - 当該 Order の拘束（予約/紐付け）を解除し、在庫運用へ戻す。
  - 解除が「危険修正（FIX）」に該当する場合は自動で実行せず、凍結へ切り替える（後述）。

#### 凍結（FREEZE｜危険域は回収へ）
- 対象：当該 Order に次が1つでも存在する場合は凍結する。
  - DELIVERED / USED 等、完了同期・経費・会計に影響する部材が存在する。
  - 既に経費（Expense）が確定している。
  - 既に書類（INVOICE/RECEIPT 等）の作成・発行・入金等、会計イベントが進行している（将来拡張を含む）。
- 効果：
  - 自動で取消・転用・巻戻しをしない。
  - Recovery Queue（BLOCKER/OPEN）へ登録し、監督回収へ寄せる。
  - 必要に応じて Request（REVIEW）を併設してよい（Request linkage に従属）。

### Recovery Queue / Request linkage（固定）
- VOID/CANCEL/RESTORE/REOPEN の操作は、次のいずれかに該当する場合、必ず Recovery Queue に登録する（冪等）:
  - 凍結条件に該当（危険域が存在）。
  - 解除/復旧に必要な前提（例：在庫拘束解除、整合確認）が満たせない。
  - 競合（同一Orderに矛盾する操作が短時間に到達、素材不一致 等）を検出した。
- 監督判断が必要な場合は Request=REVIEW を併設してよい。
- いずれも自動で RESOLVED にしない（根拠と記録を伴う更新のみ）。

### IdempotencyKey（固定）
- 本節の操作イベントは必ず冪等であること。
- eventType（固定語）:
  - ORDER_VOID / ORDER_CANCEL / ORDER_RESTORE / ORDER_REOPEN
- primaryId: Order_ID（#n で指定された対象）
- eventAt: 確定時刻（受付確定時刻）
- sourceId: 任意（外部イベントID等。取得できる場合のみ）
- 同一 idempotencyKey の再到達は「同一イベントの再観測」として扱い、主要台帳の増殖は禁止（ログ追記は許容）。

### コメント操作（削除モード）— 最小仕様（固定）
本節は Comment Concierge の「確認→番号選択→実行」プロトコルに従属する。

#### トリガ（固定）
- `削除モード`（`#n 削除モード` により対象受注を指定可。未指定なら #0）
- モード中は対象 Order（#n）を固定し、他Orderへ移れない（誤爆防止）。
  - 他Orderへ移る場合は `キャンセル` で退出し、再度 `#m 削除モード` を開始する。

#### モード中の許可コマンド（固定・最小）
- `欠番`（= ORDER_VOID）
- `削除`（= ORDER_CANCEL）
- `復旧`（= ORDER_RESTORE）
- `誤完了解除`（= ORDER_REOPEN）
- `キャンセル`（何もせず退出）

#### 実行手順（固定）
1) 候補提示（番号付き・影響要約を含む）
2) ユーザーが番号選択（複数可）
3) 最終確認（要約）
4) ユーザーが `実行` で確定

#### 実行後の返答（固定・最小）
- 操作名（VOID/CANCEL/RESTORE/REOPEN）
- 対象（Order_ID/#n）
- 在庫扱い（解放できた数／凍結理由）
- Recovery Queue の発生有無（OPEN件数と理由）
- 次の導線（確認/回収の参照先：実装で定義）

### 監査（Runtime Audit Checklist への接続｜固定）
- ORDER_VOID / ORDER_CANCEL / ORDER_RESTORE / ORDER_REOPEN は、監査対象イベントとして expected/unexpected を持つ。
- unexpected effect（代表例）:
  - 物理削除が発生する（履歴消去）
  - 自動で辻褄合わせが発生する（危険域を勝手に巻戻す）
  - 同一 idempotencyKey で主要台帳が増殖する
- NG は Recovery Queue（OPEN）へ登録する（勝手に修正しない）。

### 注意（固定）
- VOID/CANCEL は「状態の確定」であり、会計・在庫・完了同期の“意味”を勝手に書き換えるものではない。
- 危険域が存在する場合は、停止して回収へ寄せることが正しい（自動で整合させない）。


### 目的
- コメント（コンシェルジュ）と HTML フォームの両方から、同じ受注（Order_ID）を安全に操作できる状態を固定する。
- コメントは「入口・回収・誘導」を担当し、HTML は「編集・確定」を担当する（ただし欠番等は運用方針に従う）。
- 事故防止のため、更新系は必ず “確認→番号選択→実行” の順で確定する。

---

### コメント（コンシェルジュ）操作ルール（固定）
#### 更新系の確定手順（固定）
- 更新系（発注/納品/金額入力/更新/解除/欠番 等）は、必ず次の順で進行する：
  1) 候補提示（番号付き）
  2) ユーザーが番号選択（複数可）
  3) 最終確認（要約）
  4) ユーザーが「実行」で確定
- 「実行」以外では確定処理を行わない。

#### 実行後の返答（固定）
- 実行後は最小サマリのみ返す：
  - 操作名 / 対象数 / 進捗（例：納品 1/3） / 残不備（BLOCKER/WARNING）＋次リンク
- 不明点はユーザーが質問し、必要な分だけ追加説明する（自発的な長文化は禁止）。

#### コマンド一覧（固定）
- コメント1行目が「コマンド」のとき、利用可能コマンドの最小一覧を返す（例文は最小）。
- `#n` 指定の例を 1 行だけ含める（迷子防止）。
  - 例：`#1 完了報告書` / `#1 請求書`

---

### コメントモード（モード固定）— 入力待ち・実行・キャンセル（Phase-2｜固定）

#### 目的（固定）
- 「トリガー→モード固定→入力待ち→確定（実行）／中止（キャンセル）」を、誤爆しない形で固定する。
- 長文（媒体コピペ／ぶつ切り入力）を安全に受け取り、確定処理は必ず人間の `実行` で行う。

#### 基本原則（固定）
- モード中は「対象（#n）」を固定し、他の対象へ自動で移動しない（誤爆防止）。
- タイムアウトは設けない（自動キャンセルしない）。退出は `実行` または `キャンセル` のみ。
- モード中に更新系の確定処理はしない（確定は `実行` のみ）。
- モード中の入力は「素材」であり、確定値の決定は Orchestrator が行う（Authority 原則に従属）。

#### モードの開始（固定）
- 入口は「トリガー」から開始する。
- `#n` 指定がある場合は対象=#n、無い場合は既定対象（例：#0）を用いる。
- 開始時は次を返す（最小）:
  - MODE名 / 対象（Order_ID/#n）
  - 入力待ちの案内（終了= `実行` / `キャンセル`）

#### モード中の許可入力（固定）
- 許可（入力）:
  - 自由文（ぶつ切り可）：素材として蓄積する。
- 許可（参照のみ）:
  - `コマンド`（最小一覧の再提示）
  - `#n 状態`（対象の状態/進捗の参照。更新はしない）
- 禁止（モード中）:
  - 発注/納品/金額入力/削除/復旧などの「更新系」確定（混在防止）。
  - 対象切替（#mへ移動）。必要なら `キャンセル` → 再トリガーで開始し直す。

#### 確定（固定）
- `実行` を受領した時だけ、蓄積した素材を用いて確定処理へ進む（confirm→select→実行の原則に従属）。
- 実行後は最小サマリのみ返す（登録済み/未入力/次リンク）。過剰な説明は禁止。

#### 中止（固定）
- `キャンセル` を受領した場合、蓄積した素材は破棄して退出する（台帳/外部へ反映しない）。
- キャンセルの事実はログ（logs/system 相当）に残してよい（実装に委譲）。

### トリガー一覧（Phase-2｜固定）

#### 目的（固定）
- コメント1行目（またはモード中の入力）を「トリガー」として解釈し、誤爆と混線を防ぐ。
- トリガーは分類（MODE / ONE-SHOT / REF）と衝突解決を持つ（自動で辻褄合わせしない）。

#### 分類（固定）
- MODE（モード化）:
  - 対象（#n）を固定し、入力を溜め、`実行` / `キャンセル` でのみ退出・確定する。
- ONE-SHOT（単発）:
  - 単発で受付・応答する（ただし更新系は confirm→select→実行 の原則に従属）。
- REF（参照）:
  - 参照のみ。確定値を書き換えない（Authority原則）。

#### トリガー一覧（固定・最小）
- REF:
  - `コマンド` : 利用可能コマンドの最小一覧を返す（例文は最小、#n例は1行のみ）。
  - `#n 状態` : 対象（#n）の状態/進捗/回収（OPEN）要点を返す（更新しない）。
- MODE:
  - `削除モード` : Order Lifecycle Controls の削除モードへ入る（対象固定、退出=実行/キャンセル）。
  - `完了報告書` : 完了報告書モードへ入る（対象固定、退出=実行/キャンセル）。
  - `追加受注` : 追加受注モードへ入る（対象固定、退出=実行/キャンセル）。
- MODE内コマンド（共通）:
  - `実行` : モードで蓄積した素材を確定処理へ渡す（確定はこれのみ）。
  - `キャンセル` : 蓄積素材を破棄して退出（外部/台帳へ反映しない）。
  - `コマンド` / `#n 状態` : 参照のみ（更新しない）。

#### 対象指定（#n）解決（固定）
- `#n <トリガー>` の形で対象を指定できる（例：`#1 完了報告書`）。
- `#n` が無い場合は既定対象（例：#0）を用いる（実装で #0 の解決は既存契約に従う）。
- `#n` 解決は台帳（Order_YYYY の TaskId 列等）を唯一の正として行う（推測しない）。

#### 衝突解決（固定）
- 1) 既に MODE 中の場合：
  - まず MODE内コマンド（`実行` / `キャンセル` / `コマンド` / `#n 状態`）を解釈する。
  - それ以外の入力は「素材」として蓄積する（更新系は確定しない）。
- 2) MODE 中でない場合：
  - 先頭行が REF（`コマンド` / `#n 状態`）に一致 → REF を実行。
  - 次に MODE トリガー（`削除モード` / `完了報告書` / `追加受注`）に一致 → MODE 開始。
  - それ以外は通常入力として扱い、必要なら適切な MODE へ誘導する（自動確定は禁止）。

#### 禁止（固定）
- トリガー曖昧時に「勝手に更新系を確定」しない。
- MODE 中に対象を自動で切替えない（誤爆防止）。
- 管理UI（ClickUp）入力を確定値として取り込まない（Authority原則）。

### 追加受注（同一タスク内で追加Order発行）（固定）
#### コマンド（固定）
- `追加受注 <自由文>`：同一タスク内で追加の Order_ID を発行する。

#### 追加受注の既定（固定）
- 既定は「同一顧客・同一物件」を引き継ぐ（CU/UP再利用）。
- 追加受注には “子番号” を付与し、コメント内で参照できるようにする。

#### 子番号参照（固定）
- `#0`：親（元の受注）
- `#1`：同一タスク内で作成した最初の追加受注
- `#2`：2つ目の追加受注 …（以後同様）
- 親タスク名は変更しない。

#### 生成直後の返答（固定）
- `追加受注 #1 を作成しました` を返し、`#1` 用の完了報告書テンプレを提示する。
- その後の指示（短文）を必ず付ける：
  - `次：#1 完了報告書 に本文を貼ってください（ぶつ切りOK）。登録状況を返します。`
  - `売上金額が入ったら請求書DRAFT（INVOICE）を自動作成し、直リンクを返します。`

#### 親子リンク（固定）
- コメントに `LINK: #0 → #1` の 1 行を残す（追跡用）。
- 台帳側も相互参照（HistoryNotes等）を残してよい（実装に委譲）。

---

### 完了報告書（コメント登録）（固定）
#### トリガー（固定）
- `完了報告書` をトリガーとする（`#n 完了報告書` により対象受注を指定可）。

#### ひな形提示（固定）
- `完了報告書` 受領時、既知情報を埋めたテンプレを提示する。
- ユーザーは媒体コピペ（自由文）または手書き（短い行羅列）で追記してよい。

#### ぶつ切り入力と登録状況（固定）
- ぶつ切りで送られても取り込む。
- 毎回、最小の登録状況を返す：
  - 今回登録した項目 / 未入力の項目（不足）
- 同一項目の上書きが発生した場合は「変更前→変更後」を短く提示する。

#### 金額（固定）
- 完了報告では「売上金額」のみを扱う（見積金額は扱わない）。
- 売上金額を受領したら、INVOICE の DRAFT（Request=DOC）を自動作成してよい（docDraftId直開きリンクを返す）。
- RECEIPT の DRAFT は自動作成しない（入金後に作る）。

---

### タスク表示（Todoist/ClickUp）契約（固定）
#### タスク名（title）
- 先頭は AA群（重複排除）を基本とする。
- AA個数が 5 以上の場合は、AA列挙を捨てて `納品 分子/分母` 表示へ切替する。
  - 分母：当該 Order_ID に紐づく「発注総数」（Parts_Masterで Order_ID を持つ PART_ID の総数）
  - 分子：当該 Order_ID に紐づく「納品数」（STATUS=DELIVERED の数）
- 末尾に自由文スロット `_ `（アンダースコア＋半角スペース）を必ず付与し、システム更新でも保持する。

#### タスク名の更新タイミング（固定）
- UF01 / UF06（発注・納品）/ 更新（再同期）/ WORK_DONE（完了報告）でイベント駆動更新する。

#### タスク説明（description）
- 次のフォーマットを採用する（メーカー不要）：

  品番：○○＋○○＋○○
  見積：
  memo：○○

  コメント
  <品番>  <AA>
  <品番>  <AA>
  ...

- 見積が未確定の場合は空欄（行は残してよい）。
- 品番リスト（コメント以下）は「品番＋AA」のみ（メーカー/状態/価格/PART_IDは表示しない）。

#### 重要情報の記録（コメント）— Todoist / ClickUp 共通（固定）
- 住所/電話/希望日/備考など “吸い上げた重要情報” はコメントに記録する（マスクしない）。
- Todoist/ClickUp の説明欄（または本文）に次のブロックを同一テンプレで持つ：
  [INFO]
  顧客名: ...
  電話: ...
  住所: ...
  希望日: ... / ...
  備考: ...

  --- USER ---
  （ここから下は自由メモ。システムは上書きしない）

- システム更新で上書きするのは [INFO] ブロックのみ。`--- USER ---` 以降は触らない。
- [INFO] 更新が失敗した場合は業務を止めず、Recovery Queue（WARNING/OPEN）へ登録して回収する。

#### ID解決（固定）
- 納品等の内部処理は PART_ID を用いるが、ユーザー提示は最小表示（品番＋AA）のみ。
- コンシェルジュは Order_YYYY の `TodoistTaskId` / `ClickUpTaskId` 列で Order_ID を解決して処理する。

### 欠番/削除モード（最終仕様）— FIX連携・解放/凍結境界・復旧（Phase-2｜固定）

#### 目的（固定）
- 欠番（VOID）/削除（CANCEL）を「実運用で事故らない」最終仕様として固定する。
- “安全に自動解放できる領域” と “凍結して監督回収すべき領域” を明確化し、勝手な辻褄合わせを禁止する。
- 危険修正（FIX）へ正しく接続し、復旧（RESTORE）・誤完了解除（REOPEN）を混同しない。

#### 判定の原則（固定）
- 判定は Orchestrator が行う（UI/人/AIが恣意に確定しない）。
- 不確実（情報不足・参照不整合・競合）な場合は必ず FREEZE とし、Recovery Queue（BLOCKER/OPEN）へ回収する。
- 物理削除は禁止（履歴保全）。VOID/CANCEL/RESTORE の事実を台帳に残す（トゥームストーン）。

#### 解放（RELEASE）可能条件（固定）
次の全てを満たす場合のみ、VOID/CANCEL に伴う「自動解放（安全域）」を許可する：
- 当該 Order に紐づく PARTS が、完了同期・会計へ影響する状態を含まない：
  - 禁止状態が 1つでもあれば FREEZE：ORDERED / DELIVERED / USED
- 当該 Order に確定経費（EXPENSE）が存在しない（存在すれば FREEZE）。
- 当該 Order に会計イベント（INVOICE/RECEIPT 等）の進行が存在しない（存在すれば FREEZE）。
- #n 解決（Order_ID）が台帳で確定でき、参照整合が取れている（取れない場合は FREEZE）。

補足（固定）：
- SAFE の可否に迷う場合は FREEZE（自動で辻褄合わせしない）。

#### FREEZE（凍結）条件（固定）
次のいずれかに該当したら、VOID/CANCEL の処理は FREEZE とし、自動で取消・転用・巻戻しを行わない：
- PARTS に ORDERED / DELIVERED / USED が存在する。
- EXPENSE（確定経費）が存在する。
- 会計（INVOICE/RECEIPT 等）の進行が存在する（将来拡張含む）。
- 参照不整合（Order_ID 解決不可、TaskId紐付け不明、同一Orderに競合イベント等）。
- 同一対象へ短時間に矛盾するライフサイクル操作が到達（VOID↔RESTORE など）した。

#### FREEZE 時の回収（Recovery Queue / Request / FIX 連携｜固定）
- FREEZE になった場合：
  - Recovery Queue に BLOCKER/OPEN を必ず登録する（冪等）。
  - details に最小で次を含める：
    - 操作（VOID/CANCEL/RESTORE/REOPEN）
    - FREEZE 理由（例：PARTS=DELIVEREDあり / EXPENSEあり / 会計進行あり / 参照不整合）
    - 対象（Order_ID/#n）
- FIX 連携（固定）：
  - FREEZE の解消に「ID/紐付け/状態の危険修正」が必要な場合は、Request に FIX（または同等カテゴリ）を併設する。
  - FIX は “申請” であり、自動確定しない（Authority原則）。
  - FIX が OPEN の間は、Recovery Queue を勝手に RESOLVED にしない（台帳整合が条件）。

#### 削除モード（コメント運用）での確定手順（固定）
- 削除モードは MODE として動作し、対象（#n）を固定する（モード固定規約に従属）。
- 進行（固定）：
  1) `#n 削除モード`
  2) 候補提示（影響要約を含む：SAFE/ FREEZE、在庫/経費/会計の検査結果）
  3) ユーザーが操作選択（欠番/削除/復旧/誤完了解除）
  4) 最終確認（要約）
  5) `実行` で確定
- 実行後の返答（固定・最小）：
  - 操作名（VOID/CANCEL/RESTORE/REOPEN）
  - 結果（SAFE=解放実施/ FREEZE=回収へ）
  - Recovery Queue（OPEN件数・理由）
  - 次導線（#n 状態 等）

#### 復旧（RESTORE）の手順（固定）
- RESTORE は VOID/CANCEL を取り消し、再び運用対象へ戻す。
- 原則（固定）：
  - タイトルの `[VOID]` / `[CANCEL]` を除去し、タスク状態は可能なら復旧（Reopen/Uncomplete）する（タスク投影規約に従属）。
  - RESTORE により不整合が検出された場合は FREEZE し、Recovery Queue（BLOCKER/OPEN）へ回収する（自動補正しない）。
  - RESTORE は “会計/在庫の巻戻し” を自動で行う操作ではない（必要なら FIX/REVIEW へ）。

#### 誤完了解除（REOPEN）との切り分け（固定）
- REOPEN は「誤って完了した状態を戻す」操作であり、VOID/CANCEL の解除ではない。
- REOPEN は VOID/CANCEL と混同しない（混同時は FREEZE して回収する）。

#### 監査（固定）
- VOID/CANCEL/RESTORE/REOPEN は idempotencyKey を持ち、同一キーの再到達で台帳を増殖させない。
- NG（想定外副作用）が出た場合は Recovery Queue（OPEN）へ登録し、勝手に修正しない。

## DoD（Phase-2）

### 目的
- Phase-1 を実装へ落とし込むための入力仕様（フォーム分割・バリデーション・台帳マッピング・ID責務・回収運用）を固定し、実装が一本道で進められる状態を完了とする。

### 完了条件（確認可能）
- UI/Form Capture Spec（Phase-2）が存在し、入力タイミングと最小入力項目が定義されている。
- UI/Form Split & Validation（Phase-2）が存在し、BLOCKER/WARNING へのマッピングが固定されている。
- Form → Ledger Mapping（Phase-2）が存在し、フォーム入力が Order/Parts/Expense/Warnings にどう記録されるかが固定されている。
- ID Issuance & UI Responsibility（Phase-2）が存在し、PART_ID/OD_ID/AA/PA/MA/EXP_ID の発行責務とタイミングが固定されている。
- Recovery Queue（Phase-2）が存在し、BLOCKER/WARNING の回収（登録→通知→解消→記録）が固定されている。
- Integration Contract（Phase-2）が存在し、統合の責務分界・同期範囲・切替・冪等・競合時の回収が固定されている。

<!-- TODOIST_UI_CONTRACT_BEGIN -->
# TODOIST_UI_CONTRACT（Todoist運用UI/入力の固定）

## セクション名
- セクション名は運用で固定し、以後変更しない（現場の迷い防止）。

## タスク名（タイトル）フォーマット
- 現場運用のタスク名（タイトル）は以下を基本形とする：
  - `<AA>_<顧客名>_<市区町村>_<媒体>_(自由文)`
- 例：
  - `422_丸林様_西宮市_くらま_()`

## 自由文
- 自由文は「現場メモ用スロット」であり、解析・自動判定の根拠にしない（汚染防止）。
<!-- TODOIST_UI_CONTRACT_END -->

<!-- PARTS_AA_NUMBERING_CONTRACT_BEGIN -->
# PARTS_AA_NUMBERING_CONTRACT（AA群/枝番の採番・欠番）

## 確定タイミングと表示タイミング
- 発注時：AA（および枝番）は内部で確定する。
- 納品時：タスク名へ反映する（表示タイミングは運用で遅らせる）。

## 欠番（予約値）
- `??00` は予約値（欠番）とし、運用で表示される有効IDは `??01` からとする。
  - 例：`AA00` / `AB00` / `BA00` … は使わない。
- 目的：00が「未確定・空・仮」に見えて現場判断を誤る事故を防止する。
<!-- PARTS_AA_NUMBERING_CONTRACT_END -->

<!-- PARTS_TO_WORK_INFERENCE_POLICY_BEGIN -->
# PARTS_TO_WORK_INFERENCE_POLICY（部品→作業コード 推定の方針）

## 原則
- 手動が正。自動は提案のみ（採用/修正は人が行う）。

## 品番がある場合
- 品番がある場合は検索してカテゴリ判定し、作業コードを提案する。
- 提案は誤りうるため、必ず人が最終確定する。

## 品番がない場合（自由文部品名）
- 原則「部品交換」（WM_080）として提案し、明らかに大型/工事系の場合のみ工事系へ提案を寄せる。
- 手動修正の結果は辞書化して精度を上げる（追記のみ、削除しない）。
<!-- PARTS_TO_WORK_INFERENCE_POLICY_END -->

<!-- AGGREGATION_SERIAL_POLICY_BEGIN -->
# AGGREGATION_SERIAL_POLICY（月次/年次 集計・連番の扱い）

## 集計の考え方
- 集計は「イベント別」に数える（例：受注/発注/完了は別カウントとして扱う）。
- 欠番やズレがあるのは正常（業務件数と完全一致させない）。

## 目的
- 現場/コンシェルジュが「月次・年次の件数」を即答できる状態を作る（ダッシュボード等）。
<!-- AGGREGATION_SERIAL_POLICY_END -->

<!-- APP_BOUNDARY_DESIGN_NOTE_BEGIN -->
# APP_BOUNDARY_DESIGN_NOTE（将来アプリ化に備えた境界：設計のみ）

## 方針
- 現状は Todoist 前提で運用する。
- 将来の自作アプリ化で差し替え可能にするため、ドメイン（業務状態/ID/ガード）と運用基盤（Todoist等）を分離して記述する。
<!-- APP_BOUNDARY_DESIGN_NOTE_END -->

<!-- FIXATE_ADOPTED_20260109_UI_ORDER_DELIVER_DICT_BEGIN -->
# FIXATE（採用済み追記）: 発注UI/納品UI/辞書化（旧品番・用途タグ・廃盤記号）/タスク名表示

本ブロックは「既存仕様を置換しない」追記であり、本文と矛盾する場合は本文を唯一の正として優先する。

## 1) タスク名（表示・非干渉）
- 先頭表示：AAを最大5個表示。6個以上は「現在納品数/総発注数（x/y）」表示へ切替。
- 自由文スロット：末尾の自由文スロットは完全非干渉（自動追記・補完しない。欠番やキャンセル理由も書かない。保持のみ）。
- 欠番・キャンセル：タスク名へ反映しない。記録は台帳側のみ。

## 2) セクション（顧客カード：唯一の正）
1. 受注カード
2. 見積もり → 連絡待ち
3. 発注済み → 納品待ち
4. 納品待ち → 日時調整待ち
5. 日時確定 → 作業待ち
6. 入金待ち
- 分母（総発注数）が全納品になったら「③→④」へ移動。

## 3) 発注フォーム（UI：一覧入力）
- 画面は「左：顧客」「右：部品」を1行として縦に複数行。まとめて一括登録できる。
- 表罫線（セル罫線）は出さず、左右の境界線を基本にする。
- 顧客が確定した行は横線で区切る。
- 行の自動追加（フリーセル感）：
  - 初期3行固定。
  - 入力が進み残り空行が3行になったら5行を自動追加（以後繰り返し）。

### 3-1) 顧客検索（左）
- 対象セクション：①〜⑤（セクションで絞り込み可）。初期値は①・②・③。
- 全フィールド対象の部分一致検索。
- 検索語にスペースがある場合はAND検索（全語を含む顧客のみ）。
- 検索結果表示：顧客名＋市区町村＋顧客ID（最後）。

### 3-2) 部品入力（右：部品1個単位）
- 部品1個ごとに「新規発注／在庫」を選べる。初期値は新規発注（99%想定）。
- 色分けは文字色のみ（背景色は使わない）。

#### 新規発注
- 品番の部分一致検索が可能。
- 表示要素：切り替え（新規/在庫）＋メーカー＋部品（品番）。
- メーカーは自動入力（品番選択結果に紐づく場合）。
- メーカーで絞ってから検索する運用も可能だが必須化しない（人の癖で任意）。

#### 在庫
- 現在の保有在庫から選択する。
- 在庫候補は「AA＋品番」で表示する。

## 4) 納品フォーム（UI）
- 現在発注している物の一覧を表示する。
- 品番は発注日時順（古いものが上）に並べる。
- 品番一致したものをチェックし、一括納品できる。
- 品番の羅列はタスク説明に書く（区切りは「+」、改行なし）。

## 5) 在庫と納品（x/yの整合）
- 在庫品でも顧客に紐づけた瞬間に納品状態（DELIVERED）として扱う。
- x/y のカウントは「Order_IDを持つ部品」を対象にする。
- 在庫→顧客割当時は Order_ID 付与と同時に STATUS=DELIVERED とし、xとyに同時加算されてよい。

## 6) 辞書化（品番・タグ・旧品番/新品番）
- 一度発注した情報は辞書化し、次回以降引き出しやすくしていく。
- 旧品番の状態は3値：現行／旧（置換済み）／不明。
- 旧品番は削除しない。置換が確定した場合は旧→新（後継）リンクを持つ。
- 用途タグ（例：台所＋混合水栓）を持ち、検索対象にする（メーカー同格の扱い）。
- タグ等の自動化：AIは提案のみ。確定は「チェックで採用したときのみ」。確定後は次回以降固定（AI提案で上書きしない）。

## 7) 廃盤表示（記号：設計）
- 廃盤から1年以内：◇、それ以前：◆。
- 記号付与は確定（採用）された辞書レコードにのみ行う（候補段階では確定扱いしない）。
- 廃盤の全品番チェックは実装時にAPIで実施し、頻度は年2回（6月・12月）を採用（このブロックは設計のみ）。
<!-- FIXATE_ADOPTED_20260109_UI_ORDER_DELIVER_DICT_END -->

<!-- FIXATE_UF06_QUEUE_CONTRACT_BEGIN -->
# FIXATE（実装契約・追記）: UF06_QUEUE（受付キュー）仕様

本ブロックは「追記のみ」。既存本文と矛盾する場合は本文を優先する。  
目的：UF06（発注/納品）入力を「安全に受け付け、確定処理（Orchestrator）へ渡す」ための唯一の正。

## 1) キュー台帳（Sheet）— UF06_QUEUE
- Sheet 名：`UF06_QUEUE`
- 1行＝1イベント（UF06_ORDER / UF06_DELIVER）
- 直接 Parts_Master 等へ確定書込しない（キュー投入のみ）

### Columns（固定）
- receivedAt: string（ISO datetime）
- kind: string（`UF06_ORDER` / `UF06_DELIVER`）
- idempotencyKey: string（冪等キー）
- status: string（`OPEN` / `ACCEPTED` / `REJECTED` / `PROCESSED`）
- customerId: string|null
- customerName: string|null
- cityTown: string|null
- payloadJson: string（正規化済みpayloadのJSON）

## 2) status 遷移（固定）
- OPEN: 受付済み（未処理）
- ACCEPTED: Orchestrator が処理対象としてロック（処理中）
- PROCESSED: 台帳確定まで完了（確定書込と監査ログが成立）
- REJECTED: 入力不備などで処理不可（理由を logs/system または別回収へ）

※ OPEN のまま放置は許可（運用回収対象）。勝手に PROCESSED にしない。

## 3) 冪等（固定）
- idempotencyKey は「同一イベント判定」の唯一基準。
- 推奨（Phase-1 実装基準）：
  - `eventType + ":" + sha1(payloadJson)`
- 同一 idempotencyKey の再到達は「同一イベントの再観測」として扱い、
  - 新規行の増殖は禁止（重複登録禁止）
  - details/log 追記は許容（別ログ/列で扱う）

## 4) Orchestrator の責務（固定）
- UF06_QUEUE の OPEN を読み取り、種別ごとに確定処理へ接続する。
- 処理単位は「1行（1イベント）」。
- 自動辻褄合わせ禁止：不明・競合・前提不足は OPEN 維持＋回収へ寄せる。

### UF06_ORDER（発注）処理の最小期待（Phase-1）
- 正規化payloadを根拠に、発注確定（PART_ID/OD_ID/AA 等）は Orchestrator が行う。
- 受付キュー投入の時点では台帳は確定しない。

### UF06_DELIVER（納品）処理の最小期待（Phase-1）
- 納品確定により、対象部材の状態遷移（DELIVERED）と DELIVERED_AT が成立する。
- 在庫→顧客割当は即 DELIVERED を許可（x/y の同時加算を許可）。

## 5) 失敗時の扱い（固定）
- 失敗は「OPEN 維持」を基本とする（再試行できる状態を保つ）。
- REJECTED は「入力不備が確定」した場合のみ（理由の記録必須）。
- 重大不整合は Recovery Queue（BLOCKER/OPEN）へ回収（自動で解決しない）。


<<<<<<< HEAD
## CARD: MOTHERSHIP_SYNC_CONTRACT（Todoist×ClickUp×Ledger 母艦同期契約）  [Draft]
<!-- BEGIN: MOTHERSHIP_SYNC_CONTRACT_YORISOIDOU (MEP) -->
### 目的（固定）
- Ledger（台帳）を唯一の正として、Todoist（現場）と ClickUp（管理）へ安全に投影し、以後の完了報告・コメント・AI補助・書類・部材運用の母艦とする。
=======

## CARD: MOTHERSHIP_SYNC_CONTRACT（Todoist×ClickUp×Ledger 母艦同期契約）  [Draft]

## CARD: WORK_DONE_MOTHERSHIP_CONTRACT（完了報告素材受付→Ledger→投影）  [Draft]
<!-- BEGIN: WORK_DONE_MOTHERSHIP_CONTRACT_YORISOIDOU (MEP) -->
### 目的（固定）
- WORK_DONE を素材として受領しLedgerへ根拠記録、UIへ参照投影（確定はしない）
### 入力入口（固定）
- FieldSource：Todoist を唯一入口
- workDoneAt / workDoneComment（必須）、添付は任意
### 冪等（固定）
- eventType=WORK_DONE, primaryId=Order_ID, eventAt=workDoneAt
### 回収（固定）
- 必須不足は BLOCKER → Recovery Queue（OPEN）
- BLOCKER/WARNING分類は Phase-1 に従属
<!-- END: WORK_DONE_MOTHERSHIP_CONTRACT_YORISOIDOU (MEP) -->

## CARD: PARTS_MOTHERSHIP_CONTRACT（UF06/UF07 → Ledger → 母艦投影）  [Draft]
<!-- BEGIN: PARTS_MOTHERSHIP_CONTRACT_YORISOIDOU (MEP) -->
### 目的（固定）
- UF06/UF07 をLedger正規化しUIへ参照投影（確定はOrchestrator）
### 入力入口（固定）
- UF06_ORDER / UF06_DELIVER / UF07_PRICE
### Ledger記録（固定）
- PART_ID/OD_ID/Order_ID/STATUS/DELIVERED_AT/PRICE/BM=0/LOCATION(STOCK必須)
### 冪等（固定）
- UF06_ORDER, UF06_DELIVER, UF07_PRICE は idempotencyKey で増殖禁止
<!-- END: PARTS_MOTHERSHIP_CONTRACT_YORISOIDOU (MEP) -->

## CARD: RECEIPT_MOTHERSHIP_CONTRACT（領収書 → Ledger → 母艦投影）  [Draft]
<!-- BEGIN: RECEIPT_MOTHERSHIP_CONTRACT_YORISOIDOU (MEP) -->
### 目的（固定）
- RECEIPT をLedgerで管理しUIへ参照投影（確定はしない）
### 生成トリガ（固定）
- 原則：INVOICEがPAID後、例外はdocMemoに理由
### Ledger記録（固定）
- docType=RECEIPT / docName / docDesc / docPrice / docMemo / receiptStatus / receivedDate / paymentMethod
### 冪等（固定）
- RECEIPT_CREATE / RECEIPT_ISSUE は増殖禁止
=======

### 投影（Ledger→Todoist）契約（固定）
- タスク名：
  - 先頭は AA群（重複排除）を基本とする
  - AAが6個以上は「納品 x/y」へ切替
  - 末尾 `_ `（アンダースコア＋半角スペース）の自由文スロットは必ず保持（非干渉）
- タスク説明：
  - 品番羅列は `+` 区切り、改行なし
  - [INFO] ブロックのみ上書きし、`--- USER ---` 以降は非干渉
- コメント：
  - 状態/操作ログは最小（例：[STATE] VOID/CANCEL/RESTORE、[OP] REOPEN）

### 投影（Ledger→ClickUp）契約（固定）
- 管理向け参照のみ：
  - Order_ID / STATUS / alertLabels / OPEN（Request/Recovery Queue）の要点
- 入力禁止：
  - ClickUp入力でLedger確定値を上書きしない

### 冪等（Idempotency｜固定）
- 全イベントは idempotencyKey を持つ（同一キー再到達で増殖禁止）
- 同一イベント再観測は「同一扱い」で吸収（主要台帳・タスクの重複作成禁止）

### 競合・不備（固定）
- 自動で辻褄合わせをしない
- 競合・参照不整合・素材不一致は Recovery Queue（OPEN）へ登録し監督回収へ寄せる

### 再同期（RESYNC｜固定）
- 定義：Ledgerの確定状態を UI へ再投影して整合回復すること
- 禁止：UI側の値でLedger確定値を上書きする用途に使わない

### 最小Done（監査観点｜固定）
- Ledger→Todoist/ClickUp 投影が再現可能（同一Ledger状態で同一表示へ収束）
- `_ ` 自由文スロット保持／[INFO]上書き非干渉が守られる
- 冪等：同一イベント再送で台帳・タスクが増殖しない
- NG/競合は Recovery Queue（OPEN）へ落ち、勝手にRESOLVEDにしない
- RESYNCで整合回復できる

<!-- END: MOTHERSHIP_SYNC_CONTRACT_YORISOIDOU (MEP) -->


## CARD: WORK_DONE_MOTHERSHIP_CONTRACT（完了報告素材受付→Ledger→投影）  [Draft]
<!-- BEGIN: WORK_DONE_MOTHERSHIP_CONTRACT_YORISOIDOU (MEP) -->

### 目的（固定）
- 現場完了（WORK_DONE）を「素材」として受け取り、Ledgerへ根拠記録し、Todoist/ClickUpへ参照投影する。
- 確定（STATUS/PRICE/ID/台帳確定処理）は Orchestrator の責務に委譲し、UIは確定しない。

### 入力入口（固定）
- FieldSource（完了報告の唯一入口）：Todoist（現場）を唯一の正とする（併用で確定しない）。
- 受ける素材（最小）：
  - workDoneAt（完了日時）
  - workDoneComment（完了コメント全文）
  - photosBefore / photosAfter / photosParts / photosExtra / videoInspection（任意）
  - workSummary（任意：判断を置換しない）

### Ledger記録（固定）
- Ledgerは唯一の正として、以下を保存する（確定値の上書きは禁止）：
  - Order_ID（対象）
  - workDoneAt / workDoneComment（根拠）
  - 添付（任意）と受信メタ（receivedAt/sourceId 等）

### 冪等（固定）
- eventType=WORK_DONE
- primaryId=Order_ID
- eventAt=workDoneAt
- sourceId（取得できる場合のみ）
- 同一 idempotencyKey の再到達は「同一イベント再観測」として扱い、台帳/タスクの増殖は禁止（ログ追記は許容）。

### バリデーション → 回収（固定）
- 必須不足（workDoneAt / workDoneComment 欠落）は BLOCKER 扱いで完了同期を停止し、Recovery Queue（OPEN）へ登録する。
- 以降の分類は WARNINGS & BLOCKERS（Phase-1）に従属する：
  - BLOCKER：LOCATION不整合、BPのPRICE未確定（経費確定不可）
  - WARNING：写真不足、抽出不備（在庫戻し対象がある場合はBLOCKERへ昇格し得る）
- 自動辻褄合わせは禁止。競合・素材不一致・参照不整合も Recovery Queue（OPEN）へ寄せる。

### 投影更新（固定）
- Ledger→Todoist：
  - タスク表示契約（AA群/納品x/y/`_ `自由文保持、[INFO]上書き非干渉）を維持したまま、
    「完了報告受領（素材）」の参照情報を反映してよい（確定状態は断定しない）。
- Ledger→ClickUp：
  - 管理向け参照（Order_ID / STATUS参照 / OPEN回収要点）を更新してよい（入力禁止）。

### ログ（固定）
- 重要イベント（WORK_DONE受領/再観測/競合/回収登録）は logs/system 相当へ記録する。
- PIIはログ保存前にマスキングする（Ledger正式列へ複製しない）。

### 最小Done（監査観点｜固定）
- WORK_DONE素材をLedgerに記録できる（必須2点）。
- 同一イベント再送で増殖しない（冪等）。
- BLOCKER/WARNING が Recovery Queue（OPEN）へ登録され、勝手にRESOLVEDにしない。
- Todoist/ClickUp 投影が「参照更新」として反映される（確定を作らない）。

<!-- END: WORK_DONE_MOTHERSHIP_CONTRACT_YORISOIDOU (MEP) -->


## CARD: PARTS_MOTHERSHIP_CONTRACT（UF06/UF07 → Ledger → 母艦投影）  [Draft]
<!-- BEGIN: PARTS_MOTHERSHIP_CONTRACT_YORISOIDOU (MEP) -->

### 目的（固定）
- 部品（PARTS）の発注／納品／価格イベント（UF06/UF07）を Ledger に正規化し、
  Todoist（現場）と ClickUp（管理）へ **参照投影のみ** を行う。
- PRICE/STATUS/ID 等の確定は Orchestrator の責務とし、UI は確定しない。

### 入力入口（固定）
- UF06_ORDER（発注確定）：発注採用の意思のみを受ける。
- UF06_DELIVER（納品確定）：納品確定と DELIVERED_AT を受ける。
- UF07_PRICE（価格確定）：BP の PRICE 確定値のみを受ける（推測代入禁止）。

### Ledger記録（固定）
- Parts_Master（唯一の正）に以下を確定記録する：
  - PART_ID / OD_ID / Order_ID
  - partType（BP/BM）
  - STATUS（ORDERED / DELIVERED / USED / STOCK / STOCK_ORDERED）
  - DELIVERED_AT（納品時）
  - PRICE（BPのみ確定、BM=0）
  - LOCATION（STATUS=STOCK の場合は必須）
- ID 再発番／再利用は禁止。

### 冪等（固定）
- UF06_ORDER:
  - eventType=UF06_ORDER
  - primaryId=PART_ID
  - eventAt=確定時刻
- UF06_DELIVER:
  - eventType=UF06_DELIVER
  - primaryId=PART_ID
  - eventAt=DELIVERED_AT
- UF07_PRICE:
  - eventType=UF07_PRICE
  - primaryId=PART_ID
  - eventAt=価格確定時刻
- 同一 idempotencyKey の再到達は増殖禁止（再観測扱い）。

### バリデーション → 回収（固定）
- BLOCKER（完了同期停止）：
  - BP の PRICE 未確定（経費確定不可）
  - LOCATION 不整合（在庫戻し対象）
- WARNING（同期継続・管理回収）：
  - 写真不足
  - 抽出不備
- 自動辻褄合わせは禁止。競合は Recovery Queue（OPEN）へ。

### 投影（Ledger→Todoist）契約（固定）
- タスク名：
  - 先頭 AA群、6個以上は「納品 x/y」表示へ切替
  - 末尾 `_ ` 自由文スロット保持
- タスク説明：
  - 品番は `+` 区切り、改行なし
  - [INFO] ブロックのみ上書き、`--- USER ---` 以降非干渉
- 状態表示：
  - 発注／納品の進捗を参照表示（確定値を断定しない）

### 投影（Ledger→ClickUp）契約（固定）
- 管理向け参照のみ：
  - Order_ID / PART_ID / STATUS / OPEN回収要点
- 入力禁止（確定値を書き換えない）。

### 最小Done（監査観点｜固定）
- UF06/UF07 イベントが Ledger に確定記録される。
- 冪等：再送で台帳・タスクが増殖しない。
- BLOCKER/WARNING が Recovery Queue（OPEN）へ登録される。
- Todoist/ClickUp へ参照投影される（確定禁止）。

<!-- END: PARTS_MOTHERSHIP_CONTRACT_YORISOIDOU (MEP) -->


## CARD: RECEIPT_MOTHERSHIP_CONTRACT（領収書 → Ledger → 母艦投影）  [Draft]
<!-- BEGIN: RECEIPT_MOTHERSHIP_CONTRACT_YORISOIDOU (MEP) -->

### 目的（固定）
- 領収書（RECEIPT）を Ledger（唯一の正）で管理し、
  Todoist / ClickUp へは **状態の参照投影のみ** を行う。
- UI / AI は領収書を確定しない。

### 生成トリガ（固定）
- 原則：
  - INVOICE が invoiceStatus=PAID（入金済み）になった後に生成する。
- 例外：
  - 現金受領等で手動生成する場合は理由を docMemo に記録する。

### Ledger記録（固定）
- Ledger に以下を確定記録する：
  - docType = RECEIPT
  - docName（宛名）
  - docDesc（領収内容）
  - docPrice（金額）
  - docMemo（備考／例外理由）
  - receiptStatus（DRAFT / ISSUED）
  - receivedDate（任意）
  - paymentMethod（任意：CASH / BANK / OTHER）
- PRICE 推測代入は禁止（確定値のみ）。

### 冪等（固定）
- eventType = RECEIPT_CREATE / RECEIPT_ISSUE
- primaryId = DOC_ID（領収書ID）
- eventAt = 確定時刻
- 同一 idempotencyKey の再到達は増殖禁止。

### バリデーション → 回収（固定）
- 必須不足（docName / docDesc / docPrice 欠落）は BLOCKER。
- 入金根拠不明・金額不整合は BLOCKER。
- 自動辻褄合わせは禁止。問題は Recovery Queue（OPEN）へ。

### 投影（Ledger→Todoist）契約（固定）
- タスク説明またはコメントに：
  - 「領収書：DRAFT / ISSUED」
  - 金額（参照）
- タスク名・自由文スロット（`_ `）は変更しない。

### 投影（Ledger→ClickUp）契約（固定）
- 管理向け参照のみ：
  - RECEIPT 状態（DRAFT / ISSUED）
  - 金額
- 入力禁止（Ledger確定値を上書きしない）。

### 最小Done（監査観点｜固定）
- RECEIPT が Ledger に確定記録される。
- 冪等：再送で重複生成されない。
- BLOCKER は Recovery Queue（OPEN）へ。
- Todoist / ClickUp に参照投影される。

>>>>>>> origin/main
<!-- END: RECEIPT_MOTHERSHIP_CONTRACT_YORISOIDOU (MEP) -->

<!-- FIXATE_UF06_QUEUE_CONTRACT_END -->

<!-- BEGIN: YORISOIDOU_ORDER_INTAKE_V1 --> 
## CARD: ORDER_INTAKE_V1（受注入口: HTML+コメント / raw解析 / タスク名 / セクション1）  [Draft]

### Scope（固定）
- 本カードは「受注（ORDER）まで」のみ。WORK/PARTS/INVOICE/RECEIPT/EXPENSE は対象外。

### 入口（固定）
- 入口は 2 系統を許可する：
  - HTMLフォーム
  - コメント入口（Todoist/ClickUp 等のタスクコメント）

### コメント入口（固定）
- トリガー：新規受注
- 運用：
  - 1行目：新規受注
  - 2行目以降：媒体通知本文を raw として自由貼付（ぶつ切り可）
  - モード中は素材蓄積のみ
  - 確定は 実行 のみ（実行 以前に受注カード生成を行わない）

### raw（受注素材）
- raw は「媒体通知の原文全文」を保持する。
- raw は解析素材であり、確定値ではない。

### AI解析（素材抽出）
- AIは raw から以下を抽出候補として生成する（確定はしない）：
  - 顧客名
  - 住所
  - 媒体
  - 依頼内容（任意）
  - 電話番号等（取得できる場合）

### 市区町村（cityTown）書き出しルール（固定）
- 住所文字列の先頭から、以下の最小単位を抽出する（番地・号・建物名は含めない）：
  - 市区：◯◯市◯◯区（例：大阪市中央区、神戸市中央区）
  - 郡部：◯◯郡◯◯町/村（例：川辺郡猪名川町）
  - 市内町名含む：◯◯市◯◯町名（例：西宮市小曽根町、西宮市甲子園口、西宮市甲子園口北町）

### タスク名生成（最低限）
- 最低限：顧客名 + 市区町村 + 媒体
- 形式（既存契約に揃える）：<顧客名>_<市区町村>_<媒体>_
- 自由文スロットは保持し、解析/自動確定の根拠にしない。

### 説明欄（description / comment）
- テンプレートは空でも可。
- raw から取得可能な情報は可能な限り補完する。
- [INFO] ブロックのみシステム管理対象とし、--- USER --- 以降は非干渉。

### セクション投入（受注の到達点）
- AI解析→振り分けタスクへ反映し、セクション1へ投入する。
- orderStatus 等の確定状態は UI/AI では決定しない。

<!-- END: YORISOIDOU_ORDER_INTAKE_V1 -->

<!-- BEGIN: YORISOIDOU_UF06_V1 -->
## CARD: UF06_V1（発注/納品：入力→確定→台帳反映） [Draft]

### Scope（固定）
- 本カードは UF06（発注/納品）に限定する。
- ORDER / WORK_DONE / INVOICE / RECEIPT / EXPENSE は対象外。

### 入口（固定）
- UF06 は 2 イベント：
  - UF06_ORDER（発注）
  - UF06_DELIVER（納品）
- UI/コメント/フォームは素材入力のみ。確定は Orchestrator。

### UF06_QUEUE（固定）
- 直接 Parts_Master を更新しない。
- 1行=1イベント。
- Columns：
  - receivedAt
  - kind（UF06_ORDER / UF06_DELIVER）
  - idempotencyKey
  - status（OPEN / ACCEPTED / PROCESSED / REJECTED）
  - payloadJson

### 冪等（固定）
- 同一 idempotencyKey は再観測として吸収。
- 行の増殖は禁止。

### UF06_ORDER（発注）
- 採用行のみ確定。
- PART_ID / OD_ID / AA / PA/MA 発行。
- STATUS=ORDERED
- Order_ID 無しは STOCK_ORDERED
- BP：PRICE 未確定可
- BM：PRICE=0 固定

### UF06_DELIVER（納品）
- STATUS=DELIVERED
- DELIVERED_AT 記録
- BP：PRICE 未確定は BLOCKER
- LOCATION 整合必須（在庫戻し対象）

### UI責務（固定）
- 入力補助／確定意思受付／表示のみ。
- STATUS / PRICE / ID を確定しない。

### 表示契約
- AA 最大5個、超過は 納品 x/y。
- 末尾 _  自由文スロット非干渉。

### BLOCKER / WARNING
- BLOCKER：
  - BP PRICE 未確定
  - LOCATION 不整合
- WARNING：
  - 写真不足
  - 補足情報不足

### Done
- 冪等処理成立
- ID再発番なし
- 推測代入なし

<!-- END: YORISOIDOU_UF06_V1 -->

<!-- BEGIN: YORISOIDOU_WORK_DONE_V1 -->
## CARD: WORK_DONE_V1（完了報告：素材受付→Ledger根拠→回収→参照投影） [Draft]

### Scope（固定）
- 本カードは WORK_DONE（完了報告）に限定する。
- UF06 / INVOICE / RECEIPT / EXPENSE の確定仕様は対象外（参照のみ）。

### 入口（固定）
- 現場完了（WORK_DONE）の唯一入口は Todoist（現場）とする。
- 受ける素材（最小）：
  - workDoneAt（必須）
  - workDoneComment（必須：全文）
  - 添付（任意）：photosBefore / photosAfter / photosParts / photosExtra / videoInspection
  - workSummary（任意：判断を置換しない）

### Ledger 記録（固定）
- Ledger（台帳）が唯一の正（Authority）。
- WORK_DONE 受領時に以下を Order へ根拠として記録する：
  - Order_ID
  - workDoneAt / workDoneComment（根拠）
  - receivedAt / sourceId（取得できる場合）
- UI/AI は STATUS/PRICE/ID 等の確定値を作らない。

### 冪等（固定）
- eventType = WORK_DONE
- primaryId = Order_ID
- eventAt = workDoneAt
- 同一 idempotencyKey の再到達は「再観測」として吸収し、台帳/タスクを増殖させない。

### 回収（BLOCKER / WARNING：固定）
- 必須不足：
  - workDoneAt 欠落 → BLOCKER
  - workDoneComment 欠落 → BLOCKER
- Phase-1 分類に従属（本カードで再定義しない）：
  - BLOCKER：LOCATION 不整合（在庫戻し対象）、BP の PRICE 未確定（経費確定不可）
  - WARNING：写真不足、抽出不備（在庫戻し対象がある場合は BLOCKER へ昇格し得る）
- 自動辻褄合わせは禁止。競合・参照不整合・素材不一致は Recovery Queue（OPEN）へ登録する。

### 投影（参照のみ：固定）
- Ledger → Todoist：
  - 参照情報として「完了報告受領」を反映してよい（確定を断定しない）。
  - タスク名（AA群/納品x/y）・末尾 _  自由文スロットは非干渉で保持する。
  - [INFO] ブロックのみ上書きし、--- USER --- 以降は非干渉。
- Ledger → ClickUp：
  - 管理向け参照（Order_ID / STATUS参照 / OPEN回収要点）を更新してよい。
  - 入力禁止（Ledger確定値を上書きしない）。

### Done（WORK_DONE バンドル v1）
- 必須2点（workDoneAt/workDoneComment）を根拠として Ledger に記録できる。
- 冪等：同一イベント再送で増殖しない。
- BLOCKER/WARNING が Recovery Queue（OPEN）へ落ち、勝手に RESOLVED にしない。
- 投影は参照のみで、確定値を作らない。

<!-- END: YORISOIDOU_WORK_DONE_V1 -->

<!-- BEGIN: YORISOIDOU_INVOICE_V1 -->
## CARD: INVOICE_V1（請求：台帳根拠→請求生成→参照投影） [Draft]

### Scope（固定）
- 本カードは INVOICE（請求）に限定する。
- RECEIPT / EXPENSE / TAX申告は対象外。

### 入口（固定）
- INVOICE の唯一入口は Ledger とする。
- 参照可能根拠：
  - Order_ID
  - WORK_DONE（確定済み根拠）
- UI/AI からの直接起票は禁止。

### Ledger 根拠（固定）
- Ledger が唯一の正（Authority）。
- 以下を必ず保持：
  - Invoice_ID
  - Order_ID
  - issuedAt
  - amount（確定値のみ）
  - tax
  - source（Order_ID / WORK_DONE_ID）

### 冪等（固定）
- primaryKey = Order_ID
- secondaryKey = issuedAt
- 同一キーでの再実行は再観測として吸収。
- 二重請求は禁止。

### 生成（固定）
- 請求データは Ledger 根拠のみから生成。
- PRICE / tax の推測・補完は禁止。
- 未確定金額が含まれる場合は BLOCKER。

### UI責務（固定）
- 表示／プレビュー／発行意思受付のみ。
- 金額・税・番号を確定しない。

### 投影（参照のみ）
- Ledger → 管理UI：
  - Invoice_ID / status / issuedAt を参照表示。
- Ledger → 顧客向け出力：
  - 請求書データ（PDF等）は後続工程で扱う。

### BLOCKER / WARNING
- BLOCKER：
  - amount 未確定
  - WORK_DONE 根拠欠落
- WARNING：
  - 補足情報不足（自動補完禁止）

### Done（INVOICE v1）
- Ledger 根拠のみで請求生成可能。
- 冪等が成立し、二重請求が起きない。
- UI/AI が確定値を生成しない。

<!-- END: YORISOIDOU_INVOICE_V1 -->

<!-- BEGIN: YORISOIDOU_RECEIPT_V1 -->
## CARD: RECEIPT_V1（領収：台帳根拠→領収生成→参照投影） [Draft]

### Scope（固定）
- 本カードは RECEIPT（領収）に限定する。
- INVOICE（請求）の仕様変更・EXPENSE・確定申告は対象外。

### 入口（固定）
- RECEIPT の唯一入口は Ledger とする。
- 参照可能根拠：
  - Invoice_ID（推奨）
  - Order_ID
  - 入金根拠（invoiceStatus=PAID 等、または現金受領の理由）
- UI/AI からの直接確定は禁止。

### 生成トリガ（固定）
- 原則：INVOICE が入金済み（例：invoiceStatus=PAID）の根拠がある場合に生成する。
- 例外：現金受領等で手動生成する場合は理由を memo/docMemo に根拠として記録する。

### Ledger 根拠（固定）
- Ledger が唯一の正（Authority）。
- 以下を必ず保持：
  - Receipt_ID
  - Invoice_ID（任意だが推奨）
  - Order_ID
  - receivedAt（受領日/入金日）
  - amount（確定値のみ）
  - paymentMethod（CASH/BANK/OTHER）
  - status（DRAFT/ISSUED）
  - memo（例外理由/補足）
- 金額の推測・補完は禁止。

### 冪等（固定）
- primaryKey = Receipt_ID
- 同一 Receipt_ID の再実行は再観測として吸収。
- 二重発行は禁止。

### 生成（固定）
- 領収データは Ledger 根拠のみから生成する。
- amount 未確定は BLOCKER。

### UI責務（固定）
- 表示／プレビュー／発行意思受付のみ。
- 金額・支払方法・受領日・ID を UI/AI が確定しない。

### 投影（参照のみ）
- Ledger → 管理UI：
  - Receipt_ID / status / receivedAt / amount を参照表示。
- Ledger → 顧客向け出力：
  - 領収書データ（PDF等）は後続工程で扱う。

### BLOCKER / WARNING
- BLOCKER：
  - amount 未確定
  - 入金根拠欠落（原則トリガ不成立）
- WARNING：
  - 補足情報不足（自動補完禁止）

### Done（RECEIPT v1）
- Ledger 根拠のみで領収生成可能。
- 冪等が成立し、二重領収が起きない。
- UI/AI が確定値を生成しない。

<!-- END: YORISOIDOU_RECEIPT_V1 -->
