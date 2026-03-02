## Update: CODEX_FIRST 運用固定 + 8-gate接続（2026-03-02 22:13:16 +09:00）
HEAD(main): 6e7c4abe84802ce0da39151f0daf80daad2ac46d
### 実施内容（証跡）
- CODEX_FIRST（編集=Codex / 観測+dispatch=PS）を Bundled に固定
- Codex側の push/PR 作成経路（origin/token/REST API）を復旧カードとして固定
- Standalone AutoLoop → 8-gate entry（Packet Filter）への接続を修正し、main上で再現確認
- ノイズ（artifact PR / テストissue）をクリーンアップ
### Merged PR（主要）
- #2744 / #2745 : CODEX_FIRST_OPERATION_CONTRACT 追加 + 整形修正
- #2747 / #2748 : CODEX_GITHUB_AUTH_RECOVERY（復旧RUNBOOK）追加 + 整形修正
- #2749 : CODEX_REPO_BOOTSTRAP（Codex作業開始時の標準初期化）追加
- #2750 : CODEX_TASK_PACKET_TEMPLATE（Codex一括指示テンプレ）追加
- #2752 : standalone autoloop → Gate0/8-gate dispatch 接続修正（Issue #2400 で main上再現）
- #2760 : self_heal auto-resume が dirty 時に PR作成/auto-merge へ寄せる実装（Scope内）
- #2767 : Issue #2119/#2120 の仕様を repo成果物へ移植し、Bundled参照（ISSUEOPS_SPEC_REFS）を追加
### 再現（一次出力リンク）
- Issue #2400 コメントに、main固定後の再現URL（standalone run / 8-gate entry run）を記録済み

# STATUS
RUN_ID: RUN_5b8c712dddea
RUN_STATUS: DONE
STOP_CLASS: 
REASON_CODE: 
NEXT_ACTION: ALL_DONE
TIMESTAMP_UTC: 2026-03-02T12:34:30Z
EVIDENCE:
- branch_name: mep/issueops-run-run_5b8c712dddea
- pr_url: https://github.com/Osuu-ops/yorisoidou-system/pull/2723
- commit_sha:
