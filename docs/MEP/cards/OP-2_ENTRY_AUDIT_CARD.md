# OP-2 Entry Audit Card（入口監査カード）
## 目的
handoff が破損しても、入口で **一次根拠（git/gh）だけ**から復帰する。
## 禁止
- 推測値の記入（Version/Commit/PR/Path の推測禁止）
- 会話文脈を一次根拠として混入
## 必須チェック（順序固定）
1. REPO_ORIGIN が期待値と一致（git remote get-url origin）
2. main を origin/main に同期（git fetch/pull）
3. HEAD(main) を確定（git rev-parse HEAD）
4. PARENT_BUNDLED の VERSION/最終コミットを一次出力で確定
5. EVIDENCE_BUNDLE の VERSION/最終コミットを一次出力で確定
6. SSOT の所在を main から確定し、SSOT_SCAN を実行
7. CONFLICT_SCAN を実行（並立検知→STOP）
## 成果物（一次根拠として残す）
- runbook: OP-2_RECOVERY_RUNBOOK.md
- card   : OP-2_ENTRY_AUDIT_CARD.md
