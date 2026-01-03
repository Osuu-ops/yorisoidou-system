<!--
PHASE-1 (ADD ONLY): This file is a new container. Do NOT change canonical meaning yet.
CANONICAL (current): platform/MEP/03_BUSINESS/よりそい堂/master_spec
ROLE: BUSINESS_MASTER (data dictionary / IDs / fields / constraints)
-->

# BUSINESS_MASTER（業務マスタ）

## 0. 目的
- 業務で使う「項目・ID・辞書・制約」を一箇所に集約する（ルール本文は BUSINESS_SPEC へ）

## 1. ID体系（仮）
- CU_ID:
- ORDER_ID:
- DOC_ID:
- ITEM_ID:
- PART_ID:

## 2. フィールド辞書（最小テンプレ）
| domain | entity | field | type | required | constraints | description |
|---|---|---|---|---|---|---|
| customer | customer | name | string | yes |  | 顧客名 |
| customer | customer | phone | string | no |  | 電話 |
| address | address | line1 | string | no |  | 住所 |
| doc | estimate | docName | string | yes |  | 文書宛名 |
| doc | estimate | docDesc | string | yes |  | 概要 |
| doc | estimate | docPrice | number | no | >=0 | 金額 |
| doc | estimate | docMemo | string | no |  | メモ |

## 3. 列挙（仮）
- docType: ESTIMATE / INVOICE / RECEIPT

## 4. 見積（ESTIMATE）追加フィールド

本セクションは BUSINESS_SPEC の「見積（ESTIMATE）」を実務で回すための追加辞書である。

### 4.1 追加フィールド（辞書）
| domain | entity | field | type | required | constraints | description |
|---|---|---|---|---|---|---|
| contact | customer | phone | string | no |  | 連絡先（電話） |
| address | site | addressLine1 | string | no |  | 現場住所（1行） |
| schedule | site | preferredDate | string | no | YYYY-MM-DD or free text | 希望日時（任意） |
| estimate | estimate | priceStatus | enum | no | TBD/FINAL | 金額の確定状態 |
| estimate | estimate | splitPolicy | enum | no | AUTO/MANUAL | 分割判断の方針 |
| estimate | estimate | scopeCategory | enum | no | EQUIPMENT/INTERIOR/OTHER | 見積カテゴリ（分割判断に利用） |

### 4.2 列挙（enum）
- priceStatus: TBD（未確定） / FINAL（確定）
- splitPolicy: AUTO（規約に従い自動分割） / MANUAL（手動指定）
- scopeCategory:
  - EQUIPMENT（製品＋取付＝設備）
  - INTERIOR（壁紙/床など＝内装）
  - OTHER（その他）

### 4.3 分割判断で使う最小ルール（辞書側の補足）
- scopeCategory=EQUIPMENT と INTERIOR が混在する場合は原則分割（BUSINESS_SPEC側のルールと対応）

## 5. 請求（INVOICE）追加フィールド

本セクションは BUSINESS_SPEC の「請求（INVOICE）」を実務で回すための追加辞書である。

### 5.1 追加フィールド（辞書）
| domain | entity | field | type | required | constraints | description |
|---|---|---|---|---|---|---|
| invoice | invoice | dueDate | string | no | YYYY-MM-DD or free text | 支払期限 |
| invoice | invoice | paymentMethod | enum | no | BANK/ON_SITE/OTHER | 支払方法 |
| invoice | invoice | bankAccount | string | no |  | 振込先（自由記述） |
| invoice | invoice | invoiceStatus | enum | no | DRAFT/ISSUED/PAID | 請求状態 |

### 5.2 列挙（enum）
- paymentMethod:
  - BANK（振込）
  - ON_SITE（現地/集金）
  - OTHER（その他）
- invoiceStatus:
  - DRAFT（下書き）
  - ISSUED（発行）
  - PAID（入金済み）

### 5.3 最小ルール（辞書側の補足）
- dueDate / paymentMethod / bankAccount は未設定でも INVOICE を作成可（BUSINESS_SPEC側と対応）

## 6. 領収（RECEIPT）追加フィールド

本セクションは BUSINESS_SPEC の「領収（RECEIPT）」を実務で回すための追加辞書である。

### 6.1 追加フィールド（辞書）
| domain | entity | field | type | required | constraints | description |
|---|---|---|---|---|---|---|
| receipt | receipt | receivedDate | string | no | YYYY-MM-DD or free text | 受領日 |
| receipt | receipt | paymentMethod | enum | no | CASH/BANK/OTHER | 支払方法 |
| receipt | receipt | receiptStatus | enum | no | DRAFT/ISSUED | 領収状態 |

### 6.2 列挙（enum）
- paymentMethod:
  - CASH（現金）
  - BANK（振込）
  - OTHER（その他）
- receiptStatus:
  - DRAFT（下書き）
  - ISSUED（発行）

### 6.3 最小ルール（辞書側の補足）
- receivedDate / paymentMethod は未設定でも RECEIPT を作成可（BUSINESS_SPEC側と対応）

<!-- ORDER_FIELDS_PHASE1 -->
## ORDER（受注）— BUSINESS_MASTER（辞書）

本節は「受注（ORDER）」に関する辞書（enum/field）を定義する。
※ master_spec の原則どおり、Order の状態（STATUS/orderStatus）は **業務ロジックが確定**し、人/AI/UIが任意に決定してはならない。

### Fields（追加：Phase-1）
- orderStatus
  - type: string（表示用）
  - source: business-logic（自動確定）
  - rule: UIは表示のみ。手入力で確定/変更してはならない。
- scheduledDate
  - type: date（YYYY-MM-DD, Asia/Tokyo）
  - meaning: 施工予定日（確定/未確定を含む“予定”）
- scheduledTimeSlot
  - type: enum
  - values: AM / PM / EVENING / ANY / TBD
  - rule: TBD は「未確定」を意味する（UIで明示）
- scheduledTimeNote
  - type: string（任意）
  - meaning: 時間帯の補足（例：10時以降希望、管理会社連絡後確定 等）
- assignee
  - type: string（任意）
  - meaning: 担当者（表示名/コードいずれでも可。確定は運用/実装で制約）
- priority
  - type: enum
  - values: NORMAL / HIGH / URGENT
- intakeChannel
  - type: enum
  - values: UF01 / FIX / DOC / OTHER
- orderMemo
  - type: string（任意）
  - meaning: 受注に関する補足（HistoryNotes と役割が衝突しない範囲で使用）

### UI 表示ルール（最小）
- scheduledTimeSlot=TBD の場合、「時間未確定」を明示して表示する。
- orderStatus は UI で“決めない”。表示・検索・監督（管理タスク参照）にのみ使う。
