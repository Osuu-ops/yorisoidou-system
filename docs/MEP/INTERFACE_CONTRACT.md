# INTERFACE_CONTRACT (MEP Dispatch) v1.0

目的：
- 入口（PowerShell/UI）を差し替えても同じ挙動になるよう、外部入力の契約を固定する。
- BAT（B/A/T等）は内部（GitHub Actions）に畳み込み、入口は intent/payload を渡すだけにする。

Inputs（固定）：
- theme: 1テーマ=1PR の識別子（例: health_score）
- intent: OBSERVE / UPDATE_SPEC / REGENERATE
- payload: 自由文（追記したい仕様や指示）。大型ファイル貼付は禁止。

### 執行（禁止事項：大型ファイル貼付）
- 執行主体：入口（PowerShell/UI）実行者（ユーザー）
- 成立条件：payload に「大型ファイル貼付」を伴う入力が含まれる
- 判定方法：入口ガード／CIガードで検知し、NG として停止（本文生成・PR作成に進まない）
- 違反時の扱い：当該入力は不受理（入力を縮小して再投入する）

Outputs（固定）：
- PR URL（UPDATE_SPEC/REGENERATEの場合）
- Checks 結果（成功/失敗の要点）
- main は merge 後に唯一の正として更新される

Rules（固定）：
- 1 theme = 1 PR
- Scope は platform/MEP/90_CHANGES/CURRENT_SCOPE.md に従う
- Guard NG の場合は「生成物再生成」優先で整合させる
