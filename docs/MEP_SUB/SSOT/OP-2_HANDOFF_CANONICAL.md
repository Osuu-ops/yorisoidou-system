【OP-2｜handoff入口 正本一本化（SSOT / 監査カード）】
基準
- REPO_ORIGIN: https://github.com/Osuu-ops/yorisoidou-system.git
- baseBranch: main
- HEAD(main): 4f59bfbd8d78d87d9028185bf9c733ecc664120e
正本切替（旧→新：両方入ったら新へ）
- NEW（新正本候補）: .github/workflows/mep_handoff_dispatch.yml
- LEGACY（旧正本候補）: .github/workflows/mep_pregate_handoff_dispatch_v6.yml
- canonical_mode: NEW
- canonical_workflow_path: .github/workflows/mep_handoff_dispatch.yml
- canonical_workflow_name: mep-handoff-dispatch
切替ルール（固定）
- NEW が存在し、かつ workflow_dispatch=YES の場合：NEW を CANONICAL とする（新仕様へ切替）
- それ以外の場合：LEGACY を CANONICAL とする（旧仕様で継続）
- ALIAS は「旧互換入口（残置は許可）」であり、運用上の参照先（新規導線）にはしない
- pregate/manual/dispatch 等の入口が存在しても、それは CANONICAL を呼ぶ“薄い入口（ALIAS）”に限定する
- CANONICAL 以外が直接生成・直接復旧ループを持つ設計は採用しない（入口乱立による破損を防ぐ）
入口一覧（CANONICAL/ALIAS）
- [ALIAS] .github/workflows/mep_pregate_handoff_dispatch_v1.yml  (name=.github/workflows/mep_pregate_handoff_dispatch_v1.yml; state=active; workflow_dispatch=YES)
- [ALIAS] .github/workflows/mep_pregate_handoff_dispatch_v2.yml  (name=.github/workflows/mep_pregate_handoff_dispatch_v2.yml; state=active; workflow_dispatch=YES)
- [ALIAS] .github/workflows/mep_pregate_handoff_dispatch_v3.yml  (name=.github/workflows/mep_pregate_handoff_dispatch_v3.yml; state=active; workflow_dispatch=NO)
- [ALIAS] .github/workflows/mep_pregate_handoff_dispatch_v4.yml  (name=.github/workflows/mep_pregate_handoff_dispatch_v4.yml; state=active; workflow_dispatch=YES)
- [ALIAS] .github/workflows/mep_pregate_handoff_dispatch_v5.yml  (name=.github/workflows/mep_pregate_handoff_dispatch_v5.yml; state=active; workflow_dispatch=NO)
- [ALIAS] .github/workflows/mep_pregate_handoff_dispatch_v6.yml  (name=.github/workflows/mep_pregate_handoff_dispatch_v6.yml; state=active; workflow_dispatch=YES)
- [ALIAS] .github/workflows/mep_handoff_repo_dispatch_v7.yml  (name=.github/workflows/mep_handoff_repo_dispatch_v7.yml; state=active; workflow_dispatch=NO)
- [ALIAS] .github/workflows/mep_handoff_push_v8.yml  (name=.github/workflows/mep_handoff_push_v8.yml; state=active; workflow_dispatch=YES)
- [ALIAS] .github/workflows/mep_handoff_dispatch_manual.yml  (name=.github/workflows/mep_handoff_dispatch_manual.yml; state=active; workflow_dispatch=YES)
- [ALIAS] .github/workflows/mep_handoff_dispatch_manual_v2.yml  (name=.github/workflows/mep_handoff_dispatch_manual_v2.yml; state=active; workflow_dispatch=YES)
- [ALIAS] .github/workflows/mep_handoff_dispatch_manual_v3.yml  (name=.github/workflows/mep_handoff_dispatch_manual_v3.yml; state=active; workflow_dispatch=YES)
- [ALIAS] .github/workflows/mep_handoff_dispatch_manual_v4.yml  (name=.github/workflows/mep_handoff_dispatch_manual_v4.yml; state=active; workflow_dispatch=YES)
- [ALIAS] .github/workflows/mep_handoff_dispatch_manual_v4b.yml  (name=.github/workflows/mep_handoff_dispatch_manual_v4b.yml; state=active; workflow_dispatch=YES)
- [ALIAS] .github/workflows/mep_handoff_dispatch_manual_v4c.yml  (name=.github/workflows/mep_handoff_dispatch_manual_v4c.yml; state=active; workflow_dispatch=YES)
- [ALIAS] .github/workflows/mep_handoff_dispatch_manual_v5.yml  (name=.github/workflows/mep_handoff_dispatch_manual_v5.yml; state=active; workflow_dispatch=YES)
- [CANONICAL] .github/workflows/mep_handoff_dispatch.yml  (name=mep-handoff-dispatch; state=active; workflow_dispatch=YES)
成立の一次根拠（merge証跡）
- PR #1916
  mergedAt: 02/07/2026 09:07:47
  mergeCommit: 4ddb249bf8292413cc2b2552490cc6cc51431546
  https://github.com/Osuu-ops/yorisoidou-system/pull/1916

- PR #1921
  mergedAt: 02/07/2026 09:21:59
  mergeCommit: 208b100e8198cd0d2aad18db2cdd788816d1147a
  https://github.com/Osuu-ops/yorisoidou-system/pull/1921
