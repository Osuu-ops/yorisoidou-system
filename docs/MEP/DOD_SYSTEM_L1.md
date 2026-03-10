# DoD｜SYSTEM L1（固定｜完成判定の正）
この文書は **SYSTEM（親MEP）の完成判定（DoD）** を固定する。
以後、「完成／未完成」は本DoDにのみ従う（推測・会話・要約は禁止）。
---
## 0) 正のSSOT（固定）
正のSSOTは以下の3ファイルのみとする（それ以外は参考＝非正）：
- mep/boot_spec.yaml
- mep/policy.yaml
- mep/run_state.json
---
## 1) 完成レベル定義（固定）
### L1：SYSTEM完成（この文書の対象）
**0→8 が無人で1サイクル完走し、次サイクルへ再開できる**こと。
### L2：MEP全体完成（別文書で定義）
L1 + 子MEP（ビジネス隔離・結合/退避・互換運用）が確立していること。
---
## 2) L1 完成条件（必須：全て満たす）
### L1-1 再現性（収束）
- 同じ入力に対して、再実行しても発散しない（無限ループ禁止）
- 自動再起動連打（bot等）で勝手に増殖しない
### L1-2 安全停止（原因不明停止禁止）
- 停止時は必ず stop_class（WAIT/HARD）と reason_code を出す
- 次に何をするか（next_action）が機械可読で残る
### L1-3 証跡（監査可能）
最低限、SSOT（mep/run_state.json）に以下が残る：
- pr_url
- workflow_run_url
- （可能なら）commit_sha
- loop engine v2 を通る場合、phase 結果と phase pointer は `mep/run_state.json` に canonical に反映される
### L1-4 PR経路で収束
- 変更は PR → Required checks → merge の経路で本番反映される
- checks不発/不安定は STOP_HARD（自動継続禁止）
### L1-5 再開（次サイクルへ接続）
- 次サイクルの入口に渡す canonical restart contract が残る
- canonical restart contract は `RESTART_PACKET.txt` に保存され、必要に応じて `mep/run_state.json.restart_bridge` に mirror される
- `run_state.next_action` は runner 制御用であり、restart handoff 契約の代替定義にはしない
- `.mep/loop_phase_pointers.json` は補助 artifact であり、loop phase の唯一の正本にはしない
---
## 3) Gate 0〜8（機能で固定）
番号は便宜であり、責務（機能）で固定する。
- Gate0：ENTRY（入力契約チェック／開始）
- Gate1：SSOT_SCAN（整合検査）
- Gate2：CONFLICT_SCAN（衝突停止）
- Gate3：APPLY/GENERATE（生成・適用）
- Gate4：PR_CREATE（PR作成）
- Gate5：PR_CHECKS（Required checks）
- Gate6：MERGE_FINISH（merge確定）
- Gate7：EVIDENCE（台帳/証跡）
- Gate8：RESTART（次サイクル接続）
※ Gate1/2/（派生生成）/（Self-heal）は未統合の場合「未」と明示し、完成扱いは禁止。
