# OP-2｜最小復帰（handoff破損時の復帰系）運用標準
## 目的（OP-0 派生）
- handoff が破損しても、最小手順で **公式テンプレ（監査用二重構造）** を再生成できる状態を常時保持する
- 生成結果は「一次根拠（ログ/ファイル実体）」として保存し、追跡可能にする
## 対象（実体）
- 復旧スクリプト: 	ools/mep_recover_min.ps1
- 出力: 公式テンプレ + 運用ログ（例: Desktop\MEP_LOGS\RECOVERY_MIN\HANDOFF_RECOVERY_MIN_*.txt）
## トリガ（運用）
次のいずれかを満たす場合に実行する（手動トリガ可）:
1) handoff / bundled / evidence の整合が崩れた（監査で STOP / WB系エラー）
2) handoff生成経路が破損（必要ファイル欠落、生成不能）
3) 「次チャット冒頭に貼る本文」が欠落/破損し、復旧が必要
## 実行（最小）
PowerShell（repo ルート）で次を実行:
- .\tools\mep_recover_min.ps1
## 成果物（一次根拠）
- 公式テンプレ本文（監査用＋作業用の二重構造）を再生成
- 生成ログを Desktop\MEP_LOGS\RECOVERY_MIN\ に保存
## 監査観点（成功条件）
- 生成ログが保存され、参照可能である
- 公式テンプレに「REPO_ORIGIN / HEAD(main) / PARENT_BUNDLE_VERSION / EVIDENCE_BUNDLE_VERSION / EVIDENCE_BUNDLE_LAST_COMMIT」等が含まれる
- EVIDENCE_BUNDLE の該当行（hit 行）を示せる（該当する場合）
## 履歴（一次根拠へのリンク）
- 監査出力時刻（例）: 2026-02-04T05:24:32+09:00
- 参考: C:\Users\Syuichi\Desktop\MEP_LOGS\RECOVERY_MIN\HANDOFF_RECOVERY_MIN_20260204_052432.txt
（このカードは運用標準として固定。更新は 0承認→PR→main→Bundled/EVIDENCE の一次根拠ループに従う）
GeneratedAt: 2026-02-04T05:32:51+09:00
