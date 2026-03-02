[MEP] New Spec: Issue /mep run → Actions IssueOps → MEP ingest (Phase0)
目的
GitHub Issue を「草案保存庫兼タスクキュー」として扱い、Issue本文またはコメントに /mep run が書かれたら、GitHub Actions（実行エージェント）が自動起動して MEPの最小取り込みを実行し、結果をIssueへ返す仕組み（Phase0）を導入する。
本Issueは Phase0（起動と取り込み・返却のみ）。Codex実装完走や自動マージは次段。
完了定義（DoD）
以下が満たされれば完了。
1. /mep run を含む Issueコメント（またはIssue本文更新）をトリガに GitHub Actions が起動する
2. Actionsが起動元Issueの本文を取得し、draft_text として扱う
3. draft_canonical を算出し RUN_ID を確定できる
4. mep/inbox/draft_<RUN_ID>.md を生成できる（PR経由でmainへ反映）
5. mep/run_state.json を更新できる（必須：last_result/next_action/updated_at）
6. compiled3を更新できる（docs/MEP/STATUS.md, HANDOFF_AUDIT.md, HANDOFF_WORK.md）
7. 起動元Issueへコメントで結果を返す（RUN_ID / OUTCOME / REASON_CODE / NEXT_ACTION / PR_URL(あれば)）
トリガ仕様（入口固定）
- 優先：issue_comment(created)
- 保険：issues(edited)
起動条件：直近コメント、またはIssue本文に /mep run を含む場合のみ実行。
RUN_ID 生成（固定）
draft_canonical:
- CRLF/CR → LF
- 前後空白trim（先頭/末尾のみ）
- 連続空白は保持（単一化しない）
RUN_ID:
- RUN_<SHA256(draft_canonical)[:12]>
生成・更新対象（Phase0の成果物）
編集対象（SSOT）
- mep/inbox/draft_<RUN_ID>.md（新規）
- mep/run_state.json（更新。無ければ生成してから更新）
- （任意）mep/policy.yaml / mep/boot_spec.yaml（欠落時の最小生成は許容）
compiled（read-only）
- docs/MEP/STATUS.md
- docs/MEP/HANDOFF_AUDIT.md
- docs/MEP/HANDOFF_WORK.md
返却仕様（Issue返信）
Actionsは起動元Issueへコメント返信：
- RUN_ID=...
- OUTCOME=PASS|STOP_WAIT|STOP_HARD
- REASON_CODE=...
- NEXT_ACTION=...
- PR_URL=...（PR作成した場合）
- EVIDENCE=workflow_run_url（可能なら）
STOP方針（最小）
- STOP_HARD（意味矛盾のみ）：仕様矛盾・単一解不能・禁止事項違反
- STOP_WAIT（不可抗力のみ）：認証/ネットワーク/外部障害
実装制約（重要）
- main直push禁止。必ずPR経由。
- required checks が出ない場合は workflows を単独PRで修理してから再試行。
実装タスク（Codex/実装者向け）
1. .github/workflows/mep_issueops_run.yml を追加（Issueコメント起動）
2. tools/agent/issueops.py（または同等）を追加
   - Issue本文取得 / canonical化→RUN_ID / ファイル生成 / PR作成/更新 / Issueへコメント返信
3. 最小テスト：このIssueにコメントで /mep run を付けたら Actions が走り、返信が返る
起動テスト手順（実装後に実施）
実装がmainに入ったら、このIssueにコメントで：
/mep run