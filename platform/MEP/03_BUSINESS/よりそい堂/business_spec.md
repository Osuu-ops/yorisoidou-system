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

