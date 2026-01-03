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

