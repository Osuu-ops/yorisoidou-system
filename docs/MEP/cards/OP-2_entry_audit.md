# OP-2｜入口監査（SSOT_SCAN / CONFLICT_SCAN）｜一次根拠固定
## 入口固定（再発防止プロトコル｜包括契約）
本チャットでは、同じ過ちが繰り返されることを前提とする。
個別事象は列挙せず、「再発パターン（型）」として扱う。
### 再発パターン（型）
- TYPE-A：入口前提ズレ
- TYPE-B：実行環境ズレ
- TYPE-C：手順ズレ
- TYPE-D：上記に分類できない新型
### 対処方針（契約）
- TYPE-A：WB0001 として即 STOP
- TYPE-B：ENTRY_SELFTEST として再実行
- TYPE-C：FORMAT_STOP として即停止
### 本処理開始条件（必須）
- SSOT_SCAN 完了
- CONFLICT_SCAN 完了
※ 未達のまま本処理に入った場合は WB0001
