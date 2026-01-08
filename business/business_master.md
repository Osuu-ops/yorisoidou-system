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

<!-- WORK_FIELDS_PHASE1 -->
## WORK（施工）— BUSINESS_MASTER（辞書）

本節は WORK（施工/完了報告）に関する辞書（field/enum）を定義する。
※ “完了確定” は現場タスク完了が起点（master_spec 9章）。UI/人が任意に完了確定してはならない。

### Fields（Phase-1）
- workDoneAt
  - type: datetime（ISO / Asia/Tokyo）
  - source: field-report（現場完了の結果）
  - required: true（完了確定時）
- workDoneComment
  - type: string（全文）
  - source: field-report（完了コメント）
  - required: true（完了確定時）
  - rule: 未使用部材の抽出対象になり得る（書式は master_spec 9.3）
- unusedPartsList
  - type: list<string>
  - source: derived（workDoneComment から抽出）
  - required: false（抽出失敗は管理警告で扱う）
- photosBefore
  - type: list<url|string>
  - required: false
- photosAfter
  - type: list<url|string>
  - required: false
- photosParts
  - type: list<url|string>
  - required: false
- photosExtra
  - type: list<url|string>
  - required: false
- videoInspection
  - type: url|string
  - required: false
- workSummary
  - type: string
  - required: false
  - rule: 要約の作り込みで業務判断を置換しない（素材の要点メモに留める）

### Derived / Effects（参照）
- 完了同期により、Parts/EX/Expense/在庫戻しが確定される（business_spec / master_spec に従う）
- 不備（写真不足/LOCATION不整合/価格未確定 等）は管理警告対象

<!-- PARTS_FIELDS_PHASE1 -->

<!-- PHASE1_PARTS_FIELDS_BLOCK (derived; do not edit meaning) -->
### Phase-1: Parts_Master（部材台帳）— 最小フィールド（派生）
参照（唯一の正）：master_spec 3.4 / 3.4.1 / 6 / 7 / 9

主キー：PART_ID

主要項目（業務的意味を持つ列）：
- PART_ID / AA番号 / PA/MA番号 / PART_TYPE（BP/BM）
- Order_ID / OD_ID
- 品番 / 数量 / メーカー
- PRICE / STATUS
- CREATED_AT / DELIVERED_AT / USED_DATE
- MEMO / LOCATION

必須（最小）：
- STATUS=STOCK の場合：LOCATION 必須
- PART_TYPE=BP の場合：納品時に PRICE 確定（未確定は警告）
- PART_TYPE=BM の場合：PRICE=0（固定）
<!-- END PHASE1_PARTS_FIELDS_BLOCK -->
## PARTS（部材）— BUSINESS_MASTER（辞書）

本節は PARTS（部材）に関する辞書（field/enum/補助辞書）を定義する。
※ PRICE/STATUS/区分（BP/BM）等の確定は業務ルールに従う。人/AI/UI が任意に決定してはならない。

### Enums（固定）
- partType
  - values: BP / BM
  - meaning:
    - BP=メーカー手配品（納品時に価格確定）
    - BM=既製品/支給品等（PRICE=0、経費対象外）
- partStatus
  - values: STOCK / ORDERED / DELIVERED / USED / STOCK_ORDERED
  - rule: 工程イベント（発注/納品/完了同期）でのみ遷移する

### Fields（台帳カラムの意味：Phase-1）
- PART_ID
  - type: string
  - meaning: 部材の貫通ID（BP/BM体系、再利用不可）
- Order_ID
  - type: string|null
  - meaning: 受注への接続（無い場合は在庫発注として扱う）
- OD_ID
  - type: string|null
  - meaning: 同一受注内の発注行補助ID
- partType
  - type: enum(partType)
  - required: true
- AA
  - type: string|null
  - meaning: 永続番号（AA00は禁止、タスク名反映）
- PA
  - type: string|null
  - meaning: BP枝番（PA00禁止）
- MA
  - type: string|null
  - meaning: BM枝番（MA00禁止）
- maker
  - type: string|null
- modelNumber
  - type: string|null
  - meaning: 品番
- quantity
  - type: number
  - default: 1
- PRICE
  - type: number|null
  - rule:
    - BP: 納品時に確定（未確定は警告）
    - BM: 0（経費対象外）
- partStatus
  - type: enum(partStatus)
  - required: true
- CREATED_AT
  - type: datetime
- DELIVERED_AT
  - type: datetime|null
- USED_DATE
  - type: date|null
- LOCATION
  - type: string|null
  - rule:
    - STATUS=STOCK の場合は必須
    - 未使用部材の STOCK 戻しでも整合必須（欠落は管理警告）
- MEMO
  - type: string|null

### Discontinued Dictionary（廃番→新番：補助辞書）
- discontinuedPartMap
  - entry:
    - discontinued: string（廃番品番/旧番）
    - replacement: string|null（新番/代替候補）
    - keywords: list<string>（曖昧検索補助）
    - photoUrl: url|null（写真/参考）
  - rule:
    - 代替案内は補助。最終採用判断は業務ロジックで確定する

### Guard（業務破壊防止）
- AA00/PA00/MA00 はテスト専用。業務データに混在させない
- PRICE 推測代入禁止（確定入力のみ）
- BP/BM 区分変更は危険修正（申請/FIX）として扱う

<!-- EXPENSE_FIELDS_PHASE1 -->

<!-- PHASE1_EXPENSE_FIELDS_BLOCK (derived; do not edit meaning) -->
### Phase-1: Expense_Master（経費台帳）— 最小フィールド（派生）
参照（唯一の正）：master_spec 3.6 / 3.6.1 / 9

主キー：EXP_ID

主要項目（業務的意味を持つ列）：
- EXP_ID / Order_ID / PART_ID / CU_ID / UP_ID
- PRICE / USED_DATE / CreatedAt

最小ルール（固定）：
- 完了同期で BP の PRICE を根拠に確定（推測代入禁止）
- BM は経費対象外（PRICE=0）
<!-- END PHASE1_EXPENSE_FIELDS_BLOCK -->
## EXPENSE（経費）— BUSINESS_MASTER（辞書）

### Fields（Phase-1）
- EXP_ID
  - type: string
  - format: EXP-YYYYMM-0001
  - rule: 再利用不可、月内連番
- Order_ID
  - type: string
  - required: true
- PART_ID
  - type: string|null
  - required: false
- PRICE
  - type: number
  - required: true
  - rule: 推測代入禁止（確定のみ）
- USED_DATE
  - type: date
  - required: true
- CreatedAt
  - type: datetime
  - required: true

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
