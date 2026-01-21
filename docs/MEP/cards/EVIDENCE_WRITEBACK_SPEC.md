<!-- BEGIN: EVIDENCE_WRITEBACK_SPEC (MEP) -->
## CARD: EVIDENCE / WRITEBACK SPEC（証跡貼り戻し仕様）  [Adopted]

### 目的（固定）
- PR→main→Bundled の確定経路において、**証跡を Bundled 本文へ自動貼り戻し**する。
- 監査根拠を **Bundled（MEP_BUNDLE.md）単体**に集約する。

### 貼り戻し対象（必須）
- PR番号
- mergedAt
- mergeCommit
- BUNDLE_VERSION（確定値）
- 監査結果（audit=OK/NG, WBコード）
- PR URL

### 貼り戻し先（固定）
- `docs/MEP/MEP_BUNDLE.md`
- セクション：`### 証跡ログ（自動貼り戻し）`

### 実行主体（固定）
- スクリプト：`tools/mep_writeback_bundle.ps1`
- Workflow：`MEP Writeback Bundle (Evidence)`
- 実行契機：
  - PR merge 後の自動実行
  - workflow_dispatch（PR番号指定）

### 破損検出と扱い（固定）
- 以下を検出した場合は **DIRTY（入った扱い禁止）**：
  - `PR #@{` を含む行
  - `mergedAt=` が空
  - `mergeCommit=` が空
- 復旧は「壊れ行の除去」＋「正規行を1本に収束」。

### 制約
- 手編集禁止（更新は PR→main→Bundled のみ）。
- 同一 PR の証跡行は **必ず1本**に収束させる。
<!-- END: EVIDENCE_WRITEBACK_SPEC (MEP) -->
