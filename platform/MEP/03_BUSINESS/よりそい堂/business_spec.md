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
