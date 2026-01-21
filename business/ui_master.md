<!--
PHASE-1 (ADD ONLY): This file is a new container. Do NOT change canonical meaning yet.
CANONICAL (current): platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md
ROLE: UI_MASTER (screen/components/field mappings)
-->

# UI_MASTER（UIマスタ）

## 0. 目的
- UIで扱う画面・コンポーネント・入力フィールドを辞書化する
- 導線は UI_SPEC に置く

## 1. 画面一覧（仮）
- SCREEN_ESTIMATE_CREATE
- SCREEN_ESTIMATE_PREVIEW
- SCREEN_INVOICE_CREATE
- SCREEN_RECEIPT_CREATE

## 2. フィールドマッピング（最小テンプレ）
| screen | field | source | required | ui_type | notes |
|---|---|---|---|---|---|
| SCREEN_ESTIMATE_CREATE | docName | BUSINESS_MASTER.doc.estimate.docName | yes | text | 宛名 |
| SCREEN_ESTIMATE_CREATE | docDesc | BUSINESS_MASTER.doc.estimate.docDesc | yes | textarea | 概要 |
| SCREEN_ESTIMATE_CREATE | docPrice | BUSINESS_MASTER.doc.estimate.docPrice | no | number | 金額 |
| SCREEN_ESTIMATE_CREATE | docMemo | BUSINESS_MASTER.doc.estimate.docMemo | no | textarea | メモ |

## 4. 請求（INVOICE）UI 拡張

### 4.1 画面（INVOICE）
- SCREEN_INVOICE_CREATE（請求作成）
- SCREEN_INVOICE_PREVIEW（請求プレビュー）

### 4.2 フィールドマッピング（請求作成：追加）
| screen | field | source | required | ui_type | notes |
|---|---|---|---|---|---|
| SCREEN_INVOICE_CREATE | dueDate | BUSINESS_MASTER.invoice.invoice.dueDate | no | text | 支払期限 |
| SCREEN_INVOICE_CREATE | paymentMethod | BUSINESS_MASTER.invoice.invoice.paymentMethod | no | select | BANK/ON_SITE/OTHER |
| SCREEN_INVOICE_CREATE | bankAccount | BUSINESS_MASTER.invoice.invoice.bankAccount | no | textarea | 振込先（自由記述） |
| SCREEN_INVOICE_CREATE | invoiceStatus | BUSINESS_MASTER.invoice.invoice.invoiceStatus | no | select | DRAFT/ISSUED/PAID |

### 4.3 UI上の最小ルール
- invoiceStatus=DRAFT の場合は docPrice を未確定として扱ってもよい（ただし最終は BUSINESS_SPEC に従う）
- invoiceStatus=ISSUED の場合は、docName/docDesc/docPrice が揃っていることを推奨チェックしてよい

## 5. 領収（RECEIPT）UI 拡張

### 5.1 画面（RECEIPT）
- SCREEN_RECEIPT_CREATE（領収作成）
- SCREEN_RECEIPT_PREVIEW（領収プレビュー）

### 5.2 フィールドマッピング（領収作成：追加）
| screen | field | source | required | ui_type | notes |
|---|---|---|---|---|---|
| SCREEN_RECEIPT_CREATE | receivedDate | BUSINESS_MASTER.receipt.receipt.receivedDate | no | text | 受領日 |
| SCREEN_RECEIPT_CREATE | paymentMethod | BUSINESS_MASTER.receipt.receipt.paymentMethod | no | select | CASH/BANK/OTHER |
| SCREEN_RECEIPT_CREATE | receiptStatus | BUSINESS_MASTER.receipt.receipt.receiptStatus | no | select | DRAFT/ISSUED |

### 5.3 UI上の最小ルール
- receiptStatus=DRAFT の場合：下書きとしてプレビュー可能
- receiptStatus=ISSUED の場合：docName/docDesc/docPrice が揃っていることを推奨チェックしてよい

<!-- ORDER_UI_MASTER_PHASE1 -->
## ORDER（受注）— UI_MASTER（Phase-1）

本節は ORDER（受注）に関する UI 辞書（表示/入力の最小定義）を追加する。
※ orderStatus/STATUS は **業務ロジックが確定**し、UIは表示のみ（手入力で確定/変更しない）。

### Screens（最小）
- SCREEN_ORDER_INTake（受注取り込み）
  - 目的：UF01（raw/通知全文）から受注素材を入力し、登録へ進める
- SCREEN_ORDER_SCHEDULE（予定/担当）
  - 目的：施工予定（scheduledDate/timeSlot）と担当（assignee）を扱う（未確定を許容）
- SCREEN_ORDER_VIEW（閲覧）
  - 目的：OV01 相当の受注閲覧で、状態・予定・メモを確認できる

### Fields（UI表示/入力）
- raw
  - label: 通知全文 / 1行メモ
  - ui: textarea
  - required: true
- name
  - label: お名前
  - ui: text
  - required: false（素材が無い場合を許容）
- phone
  - label: 電話番号
  - ui: tel
  - required: false
- addressFull
  - label: 住所（全文）
  - ui: text
  - required: false
- preferred1 / preferred2
  - label: 希望日
  - ui: datetime/text（運用に合わせる）
  - required: false

- orderStatus
  - label: 状態
  - ui: badge（read-only）
  - rule: UIは決めない（表示のみ）

- scheduledDate
  - label: 施工予定日
  - ui: date
  - required: false（未確定を許容）
- scheduledTimeSlot
  - label: 時間帯
  - ui: select
  - values: AM / PM / EVENING / ANY / TBD
  - default: TBD
- scheduledTimeNote
  - label: 時間補足
  - ui: text
  - required: false

- assignee
  - label: 担当者
  - ui: text/select（運用に合わせる）
  - required: false
- priority
  - label: 優先度
  - ui: select
  - values: NORMAL / HIGH / URGENT
  - default: NORMAL
- intakeChannel
  - label: 入口
  - ui: select
  - values: UF01 / FIX / DOC / OTHER
  - default: UF01
- orderMemo
  - label: 受注メモ
  - ui: textarea
  - required: false
  - rule: HistoryNotes と役割が衝突しない範囲で使用

### Display Rules（最小）
- scheduledTimeSlot=TBD の場合、「時間未確定」を明示して表示する。
- required/optional の表示は UI_PROTOCOL に従う。

<!-- WORK_UI_MASTER_PHASE1 -->
## WORK（施工）— UI_MASTER（Phase-1）

本節は WORK（施工/完了報告）に関する UI 辞書（画面/表示/入力の最小定義）を追加する。
※ “完了確定” は現場タスク完了が起点（master_spec 9章）。UI は完了を任意に確定しない（報告の受付・表示・確認のみ）。

### Screens（最小）
- SCREEN_WORK_REPORT（完了報告）
  - 目的：完了コメント（全文）と写真/動画を添付し、完了報告として送信する
- SCREEN_WORK_CONFIRM（報告確認）
  - 目的：送信前に内容を確認し、二重送信を防止する
- SCREEN_WORK_DONE（報告完了）
  - 目的：受付完了を明示し、次の行動を迷わせない
- SCREEN_WORK_VIEW（閲覧）
  - 目的：完了報告内容（コメント全文・添付）を閲覧できる

### Fields（UI表示/入力）
- workDoneComment
  - label: 完了コメント（全文）
  - ui: textarea
  - required: true
  - helper: 「未使用：BP-..., BM-...」の形式で未使用部材を記載できます（任意）
- photosBefore
  - label: 写真（施工前）
  - ui: uploader（複数）
  - required: false
- photosAfter
  - label: 写真（施工後）
  - ui: uploader（複数）
  - required: false
- photosParts
  - label: 写真（部材）
  - ui: uploader（複数）
  - required: false
- photosExtra
  - label: 写真（追加）
  - ui: uploader（複数）
  - required: false
- videoInspection
  - label: 動画（点検）
  - ui: uploader/url
  - required: false

### Display Rules（最小）
- 送信中はボタン無効化・処理中表示（UI_PROTOCOL 準拠、二重送信防止）。
- 未入力の添付は「未添付」として表示し、責めない文言にする。
- UI は未使用部材の抽出結果を断定表示しない（抽出/確定は業務ロジック側）。

### Error / Warning（最小）
- 必須不足：workDoneComment が空の場合のみエラー表示（他は任意）
- 添付不足（写真不足など）は “警告” として扱い、送信は止めない（管理警告で吸収）

<!-- PARTS_UI_MASTER_PHASE1 -->

<!-- PHASE1_PARTS_UI_MASTER_BLOCK (derived; do not edit meaning) -->
### Phase-1: PARTS UI（表示/導線）— 最小（派生）
参照（唯一の正）：
- master_spec: 7 UF06/UF07 / 3.4 / 3.4.1 / 9
- ui_spec: ALERT_LABELS / REQUEST_LIST_FLOW（表示のみ）

UI責務（固定）：
- 入力補助・表示・導線のみ（確定は業務ロジック／判断権の原則）
- Parts の一覧表示（PART_ID / PART_TYPE / AA/PA/MA / STATUS / PRICE / LOCATION）
- 未確定（PRICE未入力、未納品、LOCATION欠落等）は警告ラベル/導線で可視化（確定はしない）
<!-- END PHASE1_PARTS_UI_MASTER_BLOCK -->
## PARTS（部材）— UI_MASTER（Phase-1）

本節は PARTS（部材：発注/納品/価格入力）に関する UI 辞書（画面/表示/入力の最小定義）を追加する。
※ PRICE/STATUS/区分（BP/BM）の確定は業務ルールが行う。UI は「入力素材の受付」と「確認」を担い、任意に確定しない。

### Screens（最小）
- SCREEN_PARTS_ORDER_CREATE（UF06: 発注入力）
- SCREEN_PARTS_ORDER_CONFIRM（UF06: 発注確認）
- SCREEN_PARTS_ORDER_DONE（UF06: 発注完了）

- SCREEN_PARTS_DELIVER_CREATE（UF06: 納品入力）
- SCREEN_PARTS_DELIVER_CONFIRM（UF06: 納品確認）
- SCREEN_PARTS_DELIVER_DONE（UF06: 納品完了）

- SCREEN_PARTS_PRICE_CREATE（UF07: 価格入力）
- SCREEN_PARTS_PRICE_CONFIRM（UF07: 価格確認）
- SCREEN_PARTS_PRICE_DONE（UF07: 価格完了）

- SCREEN_PARTS_STOCK_LOCATION（在庫ロケーション入力/修正：任意）
  - 目的：STATUS=STOCK の LOCATION 欠落を回収する（欠落は警告対象）

### Fields（共通）
- Order_ID
  - label: 受注ID
  - ui: text
  - required: false（在庫発注を許容：無い場合は STOCK_ORDERED 扱い）
- partType
  - label: 区分
  - ui: select
  - values: BP / BM
  - required: true
- maker
  - label: メーカー
  - ui: text
  - required: false
- modelNumber
  - label: 品番
  - ui: text
  - required: false
- quantity
  - label: 数量
  - ui: number
  - default: 1
  - required: true
- MEMO
  - label: メモ
  - ui: textarea
  - required: false

### UF06: 発注（ORDER）追加Fields
- requestedAt
  - label: 発注日
  - ui: date/datetime
  - required: false

### UF06: 納品（DELIVER）追加Fields
- deliveredAt
  - label: 納品日
  - ui: date/datetime
  - required: true
- LOCATION
  - label: ロケーション（在庫場所）
  - ui: text
  - required: false（ただし STOCK を扱う場合は必須化してよい）
- PRICE
  - label: 価格
  - ui: number
  - required: false
  - rule:
    - BP は納品時に価格確定が必要（未入力は警告）
    - BM は 0（経費対象外）。UI は入力を受け付けてもよいが、業務ルールで 0 に正規化される

### UF07: 価格入力（PRICE）追加Fields
- PART_ID
  - label: 部材ID
  - ui: text
  - required: true
- PRICE
  - label: 価格
  - ui: number
  - required: true
  - rule: BP の未確定価格を補完する（STATUSは原則変更しない）

### Display Rules（最小）
- 必須/任意の表示は UI_PROTOCOL に従う
- 送信中は二重送信防止（ボタン無効化・処理中表示）
- 価格未入力/LOCATION欠落などは “警告” として扱い、送信自体は止めない（管理警告で回収）
- UI は STATUS を任意に編集しない（表示のみ、または非表示でも可）

<!-- EXPENSE_UI_MASTER_PHASE1 -->

<!-- PHASE1_EXPENSE_UI_MASTER_BLOCK (derived; do not edit meaning) -->
### Phase-1: EXPENSE UI（表示/導線）— 最小（派生）
参照（唯一の正）：
- master_spec: 3.6 / 3.6.1 / 9 / 8.4.1
- ui_spec: OV01 表示（参照のみ）

UI責務（固定）：
- 経費（Expense_Master）の表示（EXP_ID / Order_ID / PART_ID / PRICE / USED_DATE）
- 推測計算や確定操作はしない（確定は完了同期）
- PRICE未確定などは警告ラベルで可視化（確定はしない）
<!-- END PHASE1_EXPENSE_UI_MASTER_BLOCK -->
## EXPENSE（経費）— UI_MASTER（Phase-1）

### Screens（最小）
- SCREEN_EXPENSE_CREATE（経費入力）
- SCREEN_EXPENSE_CONFIRM（経費確認）
- SCREEN_EXPENSE_DONE（経費完了）
- SCREEN_EXPENSE_VIEW（閲覧）

### Fields（UI表示/入力）
- Order_ID
  - label: 受注ID
  - ui: text
  - required: true
- PART_ID
  - label: 部材ID（任意）
  - ui: text
  - required: false
- PRICE
  - label: 金額
  - ui: number
  - required: true
  - rule: 推測代入は禁止（確定のみ）
- USED_DATE
  - label: 使用日/支出日
  - ui: date
  - required: true
- MEMO
  - label: メモ
  - ui: textarea
  - required: false

### Display Rules（最小）
- 送信中は二重送信防止（UI_PROTOCOL 準拠）
- 未入力が許容されないのは PRICE/USED_DATE/Order_ID のみ
## TAX_REPORT UI（Phase-1 最小）

### Screens
- SCREEN_TAX_REPORT_CREATE
  - 確定申告：年度選択
- SCREEN_TAX_REPORT_CONFIRM
  - 確定申告：出力確認
- SCREEN_TAX_REPORT_DONE
  - 確定申告：出力受付完了

### Fields
| field | label | ui | required | rule |
|---|---|---|---|---|
| targetYear | 対象年度 | select / number | true | 年度選択のみ。集計内容は決定しない |
| outputFormat | 出力形式 | select | true | CSV / JSON の選択のみ |
| includeMonthlyBreakdown | 月次内訳を含める | checkbox | false | 任意。内容生成はMEP側 |
| runId | 集計実行ID | text / badge（read-only） | false | secondaryKey（集計実行日時）の参照表示のみ |

### Display Rules（TAX_REPORT 専用）
- UIは「年度選択／出力トリガ／参照表示」のみを扱う
- 金額・分類・税区分・Ledger/logs 内容を UI/AI が生成・確定しない
- 二重送信防止（送信中はトリガ無効化）
