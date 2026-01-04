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
- workDoneAt（完了日時）
- workDoneComment（完了コメント全文：未使用部材記載を含み得る）
- photosBefore / photosAfter / photosParts / photosExtra（任意：不足は管理警告）
- videoInspection（任意）
- workSummary（任意：要約の作り込みで業務判断を置換しない）

### 完了コメント規約（抽出）
- 未使用部材は、以下の書式で列挙できること（master_spec 9.3 準拠）：
  例）未使用：BP-YYYYMM-AAxx-PAyy, BM-YYYYMM-AAxx-MAyy
- 抽出結果は在庫戻し（STATUS=STOCK）へ利用される（LOCATION 整合が必須）

### 完了時に起きる業務（概要）
- Order の完了日時・状態更新・最終同期日時の更新
- DELIVERED 部材の USED 化、EX/Expense の確定、未使用部材の STOCK 戻し
- 不備（価格未入力/写真不足/LOCATION不整合 等）は管理警告対象

### 禁止事項
- 人/AI/UI が Order の STATUS/orderStatus を任意に確定/変更してはならない
- 完了同期の代替として、別経路で台帳を確定させてはならない

<!-- PARTS_SPEC_PHASE1 -->

<!-- PHASE1_PARTS_SPEC_BLOCK (derived; do not edit meaning) -->
### Phase-1: PARTS（部材）— 業務最小定義（派生）
参照（唯一の正）：
- master_spec: 3.4 Parts_Master / 3.4.1 Parts STATUS / 6 部材体系 / 7 UF06/UF07 / 9 完了同期

最小目的：
- 部材（BP/BM）の発注→納品→使用→在庫の追跡を、Order_ID と PART_ID で破綻なく再現する。

業務状態（固定）：
- STOCK / ORDERED / DELIVERED / USED / STOCK_ORDERED

最小トリガー（固定）：
- UF06（発注確定）: ORDERED または STOCK_ORDERED（Order_ID有無で判定）
- UF06（納品確定）: DELIVERED（DELIVERED_AT 記録）
- UF07（価格入力）: PRICE 確定（状態は原則維持）
- 完了同期（現場完了起点）: DELIVERED の対象を USED へ（使用確定）
- 未使用部材コメント抽出: STOCK 戻し（LOCATION 整合必須）

不変条件（固定）：
- BP は納品時に PRICE を確定（未確定は警告対象）
- BM は PRICE=0（経費対象外）
- LOCATION は STATUS=STOCK の部材で必須
<!-- END PHASE1_PARTS_SPEC_BLOCK -->
## PARTS（部材）— BUSINESS_SPEC（Phase-1）

### 目的
- 部材（PARTS）を「発注→納品→使用→在庫」の工程で追跡可能な業務として定義する。
- 受注（Order_ID）と部材（PART_ID/OD_ID/AA/PA/MA）を正しく接続し、完了同期で経費確定へ繋ぐ。

### 入力入口（不変）
- UF06（発注/納品）が工程の主入口（master_spec 7章）
- UF07（価格入力）は BP の価格未確定を補完する入口（master_spec 7.3）
- 価格/区分/状態の“確定”は業務ルールに従い、人/AI/UI が任意に決めない

### 部材区分（BP/BM）
- BP（メーカー手配品）
  - 納品時に PRICE を確定する（未確定は警告）
- BM（既製品/支給品等）
  - PRICE=0（経費対象外）
- BP/BM の区分変更は危険修正（申請/FIX）に分類し、直接確定しない

### 主要IDと接続（要点）
- PART_ID：部材の貫通ID（BP/BM体系）
- AA：部材群の永続番号（タスク名へ反映）
- PA/MA：枝番（BP=PA, BM=MA）
- OD_ID：同一受注内の発注行補助ID
- 接続の中心は Order_ID（受注）
  - Order_ID の無い発注は STOCK_ORDERED として扱う（在庫発注）

### STATUS（部材状態：固定）
- STOCK / ORDERED / DELIVERED / USED / STOCK_ORDERED
- 変更は工程イベントにより行う（発注/納品/完了同期）
- 人/AI/UI が任意に書き換えない

### LOCATION（在庫ロケーション）
- STATUS=STOCK の部材は LOCATION を必須とする（欠落は管理警告）
- 未使用部材の STOCK 戻しでも LOCATION 整合が必須

### 発注（UF06: ORDER）業務（概要）
- 採用行のみを発注として確定する
- 確定結果：
  - PART_ID/OD_ID 発行
  - STATUS=ORDERED（Order_ID 無しの場合は STOCK_ORDERED）
  - BP は PRICE 未定、BM は PRICE=0

### 納品（UF06: DELIVER）業務（概要）
- 確定結果：
  - STATUS=DELIVERED
  - DELIVERED_AT 記録
  - BP は PRICE 入力必須（納品時確定）
  - LOCATION 記録（在庫・管理に必要）
  - AA群を抽出し、現場タスク名へ反映する

### 価格入力（UF07）業務（概要）
- BP の PRICE 未入力を補完し、業務として価格を確定する
- 部材STATUSは原則変更しない（価格確定のみ）
- 価格未確定は管理警告の対象

### 完了同期との関係（要点）
- 現場完了により、DELIVERED 部材が USED 化され、EX/Expense が確定される
- 未使用部材は STOCK 戻し（LOCATION 整合必須）

### 禁止事項
- ID の再利用/改変、AA 再発番
- PRICE の推測代入
- STATUS の任意変更
- LOCATION 欠落の放置（警告として扱い、管理で回収）

<!-- EXPENSE_SPEC_PHASE1 -->

<!-- PHASE1_EXPENSE_SPEC_BLOCK (derived; do not edit meaning) -->
### Phase-1: EXPENSE（経費）— 業務最小定義（派生）
参照（唯一の正）：
- master_spec: 3.6 Expense_Master / 3.6.1 Expense確定 / 9 完了同期 / 8.4.1 警告

最小目的：
- USED（使用確定）になった BP の PRICE を根拠に、確定経費として一意に記録する。

確定トリガー（固定）：
- 完了同期（現場完了起点）でのみ確定（作成/追記）

対象範囲（固定）：
- BP（メーカー手配品）: PRICE確定が前提（未確定は警告）
- BM: PRICE=0（経費対象外／経費に入れない）

不変条件（固定）：
- 推測代入は禁止（PRICEは確定値のみ）
- 既存Expenseの削除は禁止（履歴保全）
<!-- END PHASE1_EXPENSE_SPEC_BLOCK -->
## EXPENSE（経費）— BUSINESS_SPEC（Phase-1）

### 目的
- 経費（EXPENSE）を「確定した支出記録」として保持し、受注（Order_ID）へ接続する。
- 経費の“確定”は推測ではなく、確定入力（または完了同期で確定されたUSED部材）に限定する。

### 入力入口（不変）
- 完了同期により USED 部材の PRICE が経費として確定される（master_spec 9章 / Expense_Master）
- 手動の経費追加は、確定情報（領収/金額/日付/対象）を入力できる入口（運用/将来UI）
- 推測代入は禁止

### 最小データ（業務要件）
- EXP_ID（経費ID：月内連番、再利用不可）
- Order_ID（接続キー）
- PART_ID（関連部材がある場合）
- PRICE（確定金額）
- USED_DATE（使用/支出日）
- CreatedAt（記録日時）

### 禁止事項
- PRICE 推測代入
- EXP_ID 再発番/再利用
- Order_ID 無しの経費混在（例外運用をする場合は別途定義して停止）
