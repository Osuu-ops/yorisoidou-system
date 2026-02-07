# OP-2: handoff 破損復旧（最小運用系）
## 目的（OP-2）
handoff が破損しても、main と Bundled/EVIDENCE の一次根拠から二重構造HANDOFFを PowerShell 単独で自動復元できる状態を保持する。
## 入口（唯一）
- tools/mep_handoff_recovery.ps1
## DoD（最小）
- 監査用引継ぎ（一次根拠）を main/gh/git 出力から自動生成できる
- 出力は二重構造テンプレに一致する
- 生成物を MEP_HANDOFF_RECOVERY_*.txt として保存する
## 実行
pwsh -File tools/mep_handoff_recovery.ps1
