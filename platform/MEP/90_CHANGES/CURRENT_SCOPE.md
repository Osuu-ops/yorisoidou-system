## 変更対象（Scope-IN）
- .github/scripts/**
- docs/MEP/SSOT/**
- platform/MEP/90_CHANGES/**
## CURRENT_SCOPE 運用（最小復帰手順／一次根拠採取点）








目的








- 事故時に CURRENT_SCOPE を「確実に復帰」し、一次根拠（PR/commit/追随行）を採取できる状態を最小で保証する








復帰の最小手順（ローカル）








1) main を同期（ff-only）








   - git fetch origin --prune








   - git checkout main








   - git pull --ff-only origin main








2) CURRENT_SCOPE の参照点を確認








   - platform/MEP/90_CHANGES/CURRENT_SCOPE.md を確認（運用方針・固定点）








   - docs/MEP/MEP_BUNDLE.md の「OP-3 PARENT_BUNDLED FOLLOW LEDGER」を確認（追随行）








3) 一次根拠採取点（監査で必須となる最小セット）








   - main HEAD（git rev-parse HEAD）








   - 対象PR URL / mergedAt / mergeCommit（gh pr view）








   - PARENT_BUNDLE_VERSION（docs/MEP/MEP_BUNDLE.md 先頭の BUNDLE_VERSION 行）








   - EVIDENCE_BUNDLE_VERSION（docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md 先頭の BUNDLE_VERSION 行）








4) 追随が崩れている場合（最小復旧）








   - docs/MEP 側の ledger に「追随行（PR/commit）」を追記し、PR→auto-merge→main で一次根拠化する








   - zip/log 等の混入は Scope Guard / 非干渉ガードの対象（docs-only で収束させる）








注意








- 一次根拠は “main と gh/git の一次出力” のみ。会話文脈・推測は入れない。








- .github/workflows/mep_writeback_bundle_on_push.yml








- tools/mep_diag_context.ps1








- tools/mep_diag_context.cmd


=======


- CURRENT_SCOPE.md


- docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md


- platform/MEP/90_CHANGES/CURRENT_SCOPE.md


- tools/mep_auto_loop.ps1


- tools/mep_entry.ps1


- tools/mep_fix_bundle_version_suffix_to_head.ps1


- tools/mep_handoff_min.ps1


- tools/mep_handoff.ps1


- tools/mep_reporter.ps1


- tools/mep_writeback_create_pr.ps1


>>>>>>> origin/main



