# GLOBAL_INDEX（唯一の入口）

## 目的（固定）
MEP は「正しい答えを出す装置ではない。間違ったまま前に進めなくする装置」である。

## 参照ルール（固定）
- AI / 人間は、変更時は必ず以下の順で参照する
  1) 00_GLOBAL/GLOBAL_INDEX.md
  2) 00_GLOBAL/IMMUTABLE.md
  3) 90_CHANGES/CURRENT_SCOPE.md
- CURRENT_SCOPE に含まれない参照・変更は無効

## 現在の実体フォルダ（現状パス）
- Core：platform/MEP/MEP_core/
- Business：platform/MEP/MEP_business/

## 変更のやり方（固定）
- まず 90_CHANGES/CURRENT_SCOPE.md に「今回の目的・対象・非対象」を書く
- 実ファイルの変更は CURRENT_SCOPE の対象に限定する
