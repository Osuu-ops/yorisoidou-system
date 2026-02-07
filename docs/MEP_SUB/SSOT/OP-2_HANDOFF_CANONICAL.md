【OP-2｜handoff入口 正本一本化（SSOT / 監査カード）】
基準
- REPO_ORIGIN: https://github.com/Osuu-ops/yorisoidou-system.git
- baseBranch: main
- HEAD(main): c512b306993866f138d2facdaa83fe1ab39f6e50
正本（CANONICAL）
- canonical_workflow_path: .github/workflows/mep_pregate_handoff_dispatch_v1.yml
- canonical_workflow_name: .github/workflows/mep_pregate_handoff_dispatch_v1.yml
入口一覧（CANONICAL/ALIAS）
- [CANONICAL] .github/workflows/mep_pregate_handoff_dispatch_v1.yml  (name=.github/workflows/mep_pregate_handoff_dispatch_v1.yml; state=active; workflow_dispatch=YES; score=70)
- [ALIAS] .github/workflows/mep_pregate_handoff_dispatch_v2.yml  (name=.github/workflows/mep_pregate_handoff_dispatch_v2.yml; state=active; workflow_dispatch=YES; score=70)
- [ALIAS] .github/workflows/mep_pregate_handoff_dispatch_v4.yml  (name=.github/workflows/mep_pregate_handoff_dispatch_v4.yml; state=active; workflow_dispatch=YES; score=70)
- [ALIAS] .github/workflows/mep_pregate_handoff_dispatch_v6.yml  (name=.github/workflows/mep_pregate_handoff_dispatch_v6.yml; state=active; workflow_dispatch=YES; score=70)
- [ALIAS] .github/workflows/mep_handoff_dispatch_manual.yml  (name=.github/workflows/mep_handoff_dispatch_manual.yml; state=active; workflow_dispatch=YES; score=70)
- [ALIAS] .github/workflows/mep_handoff_dispatch_manual_v2.yml  (name=.github/workflows/mep_handoff_dispatch_manual_v2.yml; state=active; workflow_dispatch=YES; score=70)
- [ALIAS] .github/workflows/mep_handoff_dispatch_manual_v3.yml  (name=.github/workflows/mep_handoff_dispatch_manual_v3.yml; state=active; workflow_dispatch=YES; score=70)
- [ALIAS] .github/workflows/mep_handoff_dispatch_manual_v4.yml  (name=.github/workflows/mep_handoff_dispatch_manual_v4.yml; state=active; workflow_dispatch=YES; score=70)
- [ALIAS] .github/workflows/mep_handoff_dispatch_manual_v4b.yml  (name=.github/workflows/mep_handoff_dispatch_manual_v4b.yml; state=active; workflow_dispatch=YES; score=70)
- [ALIAS] .github/workflows/mep_handoff_dispatch_manual_v4c.yml  (name=.github/workflows/mep_handoff_dispatch_manual_v4c.yml; state=active; workflow_dispatch=YES; score=70)
- [ALIAS] .github/workflows/mep_handoff_dispatch_manual_v5.yml  (name=.github/workflows/mep_handoff_dispatch_manual_v5.yml; state=active; workflow_dispatch=YES; score=70)
- [ALIAS] .github/workflows/mep_handoff_dispatch.yml  (name=mep-handoff-dispatch; state=active; workflow_dispatch=YES; score=70)
- [ALIAS] .github/workflows/mep_handoff_push_v8.yml  (name=.github/workflows/mep_handoff_push_v8.yml; state=active; workflow_dispatch=YES; score=55)
- [ALIAS] .github/workflows/mep_pregate_handoff_dispatch_v3.yml  (name=.github/workflows/mep_pregate_handoff_dispatch_v3.yml; state=active; workflow_dispatch=NO; score=20)
- [ALIAS] .github/workflows/mep_pregate_handoff_dispatch_v5.yml  (name=.github/workflows/mep_pregate_handoff_dispatch_v5.yml; state=active; workflow_dispatch=NO; score=20)
- [ALIAS] .github/workflows/mep_handoff_repo_dispatch_v7.yml  (name=.github/workflows/mep_handoff_repo_dispatch_v7.yml; state=active; workflow_dispatch=NO; score=20)
運用契約（OP-2）
- handoff入口は「正本（CANONICAL）」に収束させる。
- pregate/manual/dispatch 等の入口が存在しても、それは正本を呼ぶ“薄い入口（ALIAS）”に限定する。
- version付き入口（*_vN 等）は原則 ALIAS（互換維持）とし、新規運用の参照先にしない。
- 正本以外が直接生成・直接復旧ループを持つ設計は採用しない（入口乱立による破損を防ぐ）。
成立の一次根拠（merge証跡）
- PR #1916
  mergedAt: 02/07/2026 09:07:47
  mergeCommit: 4ddb249bf8292413cc2b2552490cc6cc51431546
  https://github.com/Osuu-ops/yorisoidou-system/pull/1916

- PR #1921
  mergedAt: 02/07/2026 09:21:59
  mergeCommit: 208b100e8198cd0d2aad18db2cdd788816d1147a
  https://github.com/Osuu-ops/yorisoidou-system/pull/1921
