# OP-1｜EVIDENCE追随 自動化（push main → writeback dispatch）
## 目的（OP-0を変えない）
- 承認（0）→PR→main→Bundled/EVIDENCE の一次根拠ループを自動で回せる状態を作る
## OP-1（追随）完成条件のうち、このファイルで扱う範囲
- main へ push（= merge）されたら、自動で writeback を発火する
- 正本トリガは .github/workflows/mep_writeback_bundle_dispatch_entry.yml（workflow_dispatch）
- 発火は push main を契機に actions.createWorkflowDispatch で行う
- 失敗は workflow 側で FAILED として可視化される（監査可能に止まる）
## 実装
- .github/workflows/mep_op1_evidence_follow_on_push_main.yml
