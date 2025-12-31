# GLOBAL\_INDEX（唯一の入口）

## 目的（固定）

MEP は「正しい答えを出す装置ではない。間違ったまま前に進めなくする装置」である。

## 参照ルール（固定）

* AI / 人間は、変更時は必ず以下の順で参照する

  1. 00\_GLOBAL/GLOBAL\_INDEX.md
  2. 00\_GLOBAL/IMMUTABLE.md
  3. 90\_CHANGES/CURRENT\_SCOPE.md

* CURRENT\_SCOPE に含まれない参照・変更は無効

## 現在の実体フォルダ（現状パス）

* Core：platform/MEP/01\_CORE/
* Business：platform/MEP/03\_BUSINESS/

## 変更のやり方（固定）

* まず 90\_CHANGES/CURRENT\_SCOPE.md に「今回の目的・対象・非対象」を書く
* 実ファイルの変更は CURRENT\_SCOPE の対象に限定する
