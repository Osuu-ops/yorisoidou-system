HANDOFF (dual-layer, machine-generated)

[AUDIT]
REPO_ORIGIN
https://github.com/Osuu-ops/yorisoidou-system
BASE_BRANCH
main
HEAD
5c9bee60
PARENT_BUNDLED
docs/MEP/MEP_BUNDLE.md
EVIDENCE_BUNDLE
docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md
PARENT_BUNDLE_VERSION
v0.0.0+20260206_191703+main_f733f7c
EVIDENCE_BUNDLE_VERSION
v0.0.0+20260204_035621+main+evidence-child
EVIDENCE_BUNDLE_LAST_COMMIT
5c9bee601c5654a19335536070c6750840fc7334 2026-02-07T10:48:39+09:00
Merge pull request #1913 from Osuu-ops/fix/handoff-dispatch-dedupe_20260207_104820

PR
number=1913 mergedAt= mergeCommit=


[WORK]
OP-0: separate system and business; keep non-interference; approval(0)->PR->main->Bundled/EVIDENCE loop
OP-1: ensure EVIDENCE follows main
OP-2: keep minimal recovery loop for handoff
OP-3: scope guard blocks unexpected files

PROOF_HIT parent= evidence=