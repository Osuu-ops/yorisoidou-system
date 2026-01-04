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
- Warnings / Blockers（管理回収）:
  - Order_ID
  - category（BLOCKER / WARNING）
  - reason（例：PRICE未確定 / LOCATION不整合 / 写真不足 / 抽出不備）
  - detectedAt（検出日時）
  - resolvedAt（解消日時：運用）

### フォーム別の書き込み先（固定）

#### 1) 現場完了フォーム（WORK 完了報告）
- Order:
  - workDoneAt ← `workDoneAt`
  - workDoneComment ← `workDoneComment`
  - orderStatus / STATUS ← 完了同期で更新（Phase-1: WORK 参照）
  - lastSyncedAt ← 完了同期実行時刻
- Parts:
  - 未使用部材抽出（workDoneComment）→ 対象 PART_ID の STATUS を STOCK に戻す（LOCATION 整合必須）
  - DELIVERED → USED 化（完了同期で確定）
- Expense:
  - USED（使用確定）になった BP の PRICE を根拠に Expense を確定（Phase-1: EXPENSE 参照）
- Warnings/Blockers:
  - 写真不足 → WARNING
  - 抽出不備 → WARNING（在庫戻し対象がある場合は BLOCKER に昇格し得る）
  - LOCATION 不整合 → BLOCKER
  - BP の PRICE 未確定 → BLOCKER

#### 2) UF06-ORDER（発注確定）
- Parts:
  - 採用行確定 → PART_ID / OD_ID を発行し STATUS=ORDERED（Order_ID 無しなら STOCK_ORDERED）
  - BM は PRICE=0（経費対象外）
- Warnings/Blockers:
  - 発注確定意思が無い（採用行無し）→ BLOCKER（確定処理を停止）

#### 3) UF06-DELIVER（納品確定）
- Parts:
  - STATUS=DELIVERED
  - DELIVERED_AT を記録
  - BP の PRICE を確定（未確定は BLOCKER）
  - LOCATION（運用入力；STOCK対象で必須）
- Warnings/Blockers:
  - PRICE 未確定（BP）→ BLOCKER
  - LOCATION 欠落（STOCK対象）→ WARNING（在庫戻し対象では BLOCKER に昇格し得る）

#### 4) UF07-PRICE（価格入力）
- Parts:
  - BP の PRICE を確定（状態は原則維持）
- Warnings/Blockers:
  - PRICE 未入力 → BLOCKER
  - 推測代入 → BLOCKER

#### 5) EXPENSE-ADD（経費の手動追加：将来UI/運用）
- Expense:
  - Order_ID / PRICE / USED_DATE / 対象（摘要）を記録（許可する場合の最小セット）
- Warnings/Blockers:
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
## Recovery Queue（Phase-2）

### 目的
- WARNINGS & BLOCKERS（Phase-1）で検出された不備を、運用で確実に回収・解消するための「回収キュー」を固定する。
- 実装（GAS/UI/タスク）はこの仕様に従って “登録→通知→解消→記録” を行う。

### 登録対象（固定）
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

### どこへ記録するか（実装境界）
- 仕様上は「回収キュー（台帳）」として記録する。
- 実装では、次のいずれか（または併用）でよい：
  - 台帳（Sheets 等）に 1 行として追記
  - タスク（Todoist 等）を起票し、台帳には参照IDを残す
（採用する実装先は Phase-2 の実装PRで固定する）

### 解消の定義（固定）
- PRICE未確定: 対象 BP の PRICE を確定値として入力済みであること（推測代入禁止）。
- LOCATION不整合: 対象部材の LOCATION が整合し、STOCK 戻しが可能であること。
- 写真不足: 必要写真が追補されたこと（不足の内訳は details に記録）。
- 抽出不備: 完了コメントの形式が修正され、未使用部材の抽出が可能であること。

