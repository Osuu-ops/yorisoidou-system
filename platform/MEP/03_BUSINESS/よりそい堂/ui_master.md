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

