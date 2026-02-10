# OP-1/OP-2｜自動ゲート実装（required checks 強制）
## OP-0（最上位・不変）
システムとビジネスを分離して管理する  
親システム側の変更がビジネス領域に混入・汚染しない構造を維持する  
承認（0）→PR→main→Bundled/EVIDENCE の一次根拠ループを自動で回せる状態を作る
## 判断順序（固定）
OP-0 → OP-1 / OP-2 / OP-3 の順で適用する
## OP-2（入口監査） required checks
- ENTRY_GATE / gate
  - SSOT_SCAN: SSOT の存在を必須化
  - CONFLICT_SCAN: 旧/新の実行候補並立を検知したら WB0001 STOP
## OP-1（EVIDENCE追随） required checks
- EVIDENCE_FOLLOW_GUARD / gate
  - EVIDENCE_BUNDLE の存在と最低限の内容健全性を必須化
