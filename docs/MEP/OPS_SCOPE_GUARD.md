# OPS_SCOPE_GUARD（CURRENT_SCOPE運用ルール）

## 対象ファイル（SCOPE_FILE）
platform/MEP/90_CHANGES/CURRENT_SCOPE.md

## 必須セクション（固定）
## 変更対象（Scope-IN）

この見出し直下の「- 」行のみが許可リストとして解釈される。

## 典型エラー
Scope Guard NG: out-of-scope changes detected
→ CURRENT_SCOPE.md の Scope-IN に「変更したパス」を - 行で追加して push
