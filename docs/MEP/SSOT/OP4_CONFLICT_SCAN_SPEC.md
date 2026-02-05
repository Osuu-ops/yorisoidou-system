# OP-4 CONFLICT_SCAN 仕様（一次根拠化・Machine-Only STOP）
## 目的（OP-0/1と整合）
- 実行入口（ENTRY）において、**旧WORK_ID系** と **新SSOT/WORK_ITEMS系** が「実行候補」として同時に並立した場合の誤誘導を防止する。
- 検知時は **Machine-Only STOP** とし、以後の自動実行（実行経路）を封印して安全側に倒す。
- 旧は削除しない（証跡/比較/ロールバック材料として保持）。“実行候補から除外”のみ行う。
## 用語
- 旧WORK_ID系: 旧来のWORK_ID表/実行経路（例: 旧WIP一覧・旧ディスパッチ元データなど）
- 新SSOT/WORK_ITEMS系: `docs/MEP/SSOT/WORK_ITEMS.json` を唯一参照する実行経路（ENTRYの正系）
- 実行候補: ENTRYが「次に行うアクションを決めるために参照するデータ源」として扱うもの
## 並立の定義（“実行候補として”）
同一プロセス（ENTRY実行1回）の中で、以下が同時に成立した状態を「並立」と定義する。
1. 新SSOT/WORK_ITEMS系が存在し、ENTRYが参照可能である（ファイル存在 + 解析成功）
2. 旧WORK_ID系も存在し、ENTRYが参照可能である（存在 + 解析成功）
3. ENTRYが“実行候補”として両者を同列に扱える状態にある（優先/排他が仕様固定されていない、または両方を読み込む実装）
※重要: 「ファイルが残っている」だけでは並立としない。“実行候補”に入ることが条件。
## CONFLICT_SCAN（責務）
- 入力: ENTRYが参照し得る実行候補のデータ源一覧（新SSOT、旧系）
- 出力:
  - `conflictDetected: true/false`
  - `conflictReason: <machine-readable reason>`
  - `conflictDetails: <human-readable summary>`
  - `exitCode: <Exit契約に従う>`
## Machine-Only STOP（Exit契約）
- `conflictDetected == true` の場合、ENTRYは**自動修復・自動選択を禁止**し、停止する。
- 停止時に必ず出すもの:
  - STOP_REASON（例: `CONFLICT_SCAN: both-candidates-present`）
  - どのデータ源が“実行候補”になっていたか（paths / probes 結果）
  - 次に必要な人間操作（0承認で封印を有効化/移行を確定 等）
## 封印（実行経路のみ）
- 封印対象: 旧WORK_ID系を「実行候補」から外す（読み込み/実行/ディスパッチの対象外）
- 旧の保持: 旧ファイル・旧表は残す（証跡/比較用途）
- 封印の発動トリガ（仕様）:
  - **新仕様入口がDoD達成後**にのみ封印を許可する
  - DoD未達の段階では封印しない（比較/検証の余地を残す）
## DoD（封印許可の前提）
最低限、以下の連鎖が成立していること（例: SSOT_SCAN → CONFLICT_SCAN → writeback成功条件 → handoff）
- SSOT_SCAN: WORK_ITEMSが読み取れている（validator相当のチェックOK）
- CONFLICT_SCAN: 並立検知が実装され、検知時STOPできる
- writeback成功条件: run/commit/bundle の一次根拠が取れる（WIP-021..026等）
- handoff: 監査用引継ぎの一次根拠欄が継続可能
## 位置づけ（SSOT項目）
- WIP-900: CONFLICT_SCAN を仕様として固定し、ENTRYの停止契約として実装する（この仕様書が一次根拠化の中核）
