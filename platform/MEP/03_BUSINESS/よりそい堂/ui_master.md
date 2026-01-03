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

