# INTERFACE_CONTRACT (MEP Dispatch) v1.0

目的：
- 入口（PowerShell/UI）を差し替えても同じ挙動になるよう、外部入力の契約を固定する。
- BAT（B/A/T等）は内部（GitHub Actions）に畳み込み、入口は intent/payload を渡すだけにする。

Inputs（固定）：
- theme: 1テーマ=1PR の識別子（例: health_score）
- intent: OBSERVE / UPDATE_SPEC / REGENERATE
- payload: 自由文（追記したい仕様や指示）。大型ファイル貼付は禁止。

Outputs（固定）：
- PR URL（UPDATE_SPEC/REGENERATEの場合）
- Checks 結果（成功/失敗の要点）
- main は merge 後に唯一の正として更新される

Rules（固定）：
- 1 theme = 1 PR
- Scope は platform/MEP/90_CHANGES/CURRENT_SCOPE.md に従う
- Guard NG の場合は「生成物再生成」優先で整合させる
