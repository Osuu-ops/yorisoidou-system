# OP-2｜入口監査（SSOT_SCAN / CONFLICT_SCAN）と復帰フロー（最小運用系）
## 目的
handoff破損・前提ズレ・環境ズレ・手順ズレを「型」として扱い、入口で止める／復帰する。
## 本処理開始条件（必須）
- SSOT_SCAN 完了
- CONFLICT_SCAN 完了
※ 未達のまま本処理に入った場合は WB0001（入口汚染）
## 再発パターン（型）と対処
### TYPE-A：入口前提ズレ
- 正本（SSOT / Bundled）未読
- 前提の勝手補完
- 一次根拠のない仕様追加・判断
=> WB0001（入口汚染）として即 STOP。一次根拠が明示されるまで採用しない。
### TYPE-B：実行環境ズレ
- PowerShell 関数（_git / _gh / _Run）欠落
- 引数透過不具合
- パス／権限／トークン／カレント不整合
=> ENTRY_SELFTEST（入口自己診断）として処理。失敗は汚染扱いしない。
修復後、直前に失敗したコマンドを同一内容で再実行する。
修復前ログはエビデンス対象外。再実行を正規初回実行として扱う。
### TYPE-C：手順ズレ
- PowerShell / Git 操作の段階分割
- プレースホルダ要求
- 対話入力要求
- 工程の省略・順序違反
=> FORMAT_STOP として即停止。以後形式を強制復帰：
- PowerShell：1ブロック完結
- プレースホルダ禁止
- 段階分割禁止
### TYPE-D：新型
=> 必ず記録し、後続で分類見直し。
## 入口で出す監査スナップショット（一次出力）
- REPO_ORIGIN / HEAD(main)
- PARENT_BUNDLED / PARENT_BUNDLE_VERSION / PARENT_BUNDLED_LAST_COMMIT
- EVIDENCE_BUNDLE / EVIDENCE_BUNDLE_VERSION / EVIDENCE_BUNDLE_LAST_COMMIT
- SSOT_PATH / SSOT_VERSION_HINT
- CONFLICT_SCAN_OK
