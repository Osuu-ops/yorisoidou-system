<!-- OP-2: min-recovery-runbook (SSOT) -->
# 最小復帰手順（SSOT / runbook）
この文書は handoff/証跡が破損しても復帰できる「最小一本道」を固定する。
## 前提（固定）
- PR作成主体は **checks が確実に発火する主体/トークン** に固定する（bot/GITHUB_TOKEN 起因の未発火は禁止）。
- 最終合否は PR（Ruleset）を正とし、ローカルは Preflight と差分生成まで。
## 手順（一本道）
1. main を ff-only 同期（dirty禁止）
2. writeback系の変更を1PRで作成（対象は必要最小限）
3. Ruleset によりブロックされた場合：
   - checks 未発火なら「再発火（例：空コミット等）」で必ず checks を出す
4. Scope Guard 対応：
   - EVIDENCE writeback は **Scope-IN を exact file list に収束**（許容面積を最小化）
5. checks が揃ったら auto-merge へ
6. merge 後、main 同期し、Bundled/EVIDENCE の一次根拠（PR/mergeCommit/HEAD）を handoff に反映
## 成果物（最低限）
- PR URL
- mergeCommit
- main HEAD
- EVIDENCE_BUNDLE 内の証跡行
