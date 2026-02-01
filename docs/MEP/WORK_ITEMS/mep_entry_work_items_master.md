# WORK_ID 表（MASTER / 実装の唯一参照）
## 固定語彙（契約）
- PURPOSE: `P001 | P002 | P003 | P004`
- RESULT_STATUS: `DONE | STILL_OPEN | FAILED | SKIPPED`
- STOP_REASON: `EXEC_IMPOSSIBLE | ERROR | ALL_DONE | NO_PROGRESS | TIMEOUT | MANUAL_STOP`
- EXIT_CODE 契約:
  - `0 = ALL_DONE`（WORK_IDが全てDONE）
  - `2 = UNDETERMINED`（未確定停止：人手/外部条件待ち/根拠不足）
  - `1 = EXEC_IMPOSSIBLE`（環境不備/前提違反/実行不能）
## 排他（唯一入口）契約
- **mep_entry**：唯一の入口。未完判定・アクション実行・一次根拠検証・起動レポート確定までを内包する。
- **mep_auto**：`mep_entry -Once` を繰り返し呼ぶだけ。dispatch等の実体処理は一切持たない。
- **禁止**：mep_auto（および他ツール）は、dispatch / run監視 / PR処理 / Bundled検証 / handoff再生成 を直接実行してはならない。実行可能なのは **mep_entry -Once のみ**。
## NO_PROGRESS 判定（進捗の固定定義）
進捗イベント＝以下のいずれかが BEFORE→AFTER で変化した場合のみ：
- `HEAD`
- `PARENT_BUNDLE_VERSION`
- `EVIDENCE_LAST_LINE`
- `TARGET_PR_EVIDENCE_LINE_PRESENT`（Bundled/EVIDENCEの対象PR証跡行の有無）
上記が **N回連続で不変**の場合、STOP_REASON=NO_PROGRESS として停止する。
stdoutの文言変化・時刻更新は進捗に含めない。
---
## WORK_ID 定義（固定集合）
### WIP-001（P001）Repo 妥当性OK
- TITLE: Repo is valid git repository
- DEFINITION: `git rev-parse --show-toplevel` が成功する
- TARGET_ACTION: `precheck.repo`
- DONE_CONDITION: 上記が成功
- EVIDENCE_KEYS: `REPO_ROOT`
### WIP-002（P001）Working tree clean
- TITLE: Working tree clean
- DEFINITION: `git status --porcelain` が空である
- TARGET_ACTION: `precheck.clean`
- DONE_CONDITION: 上記が空
- EVIDENCE_KEYS: `GIT_STATUS_PORCELAIN_HASH`（空/非空の判定ができる形）
### WIP-003（P001）main 同期（ff-only pull）
- TITLE: main is synced by fast-forward only pull
- DEFINITION: `git checkout main` + `git pull --ff-only origin main` が成功する
- TARGET_ACTION: `sync.main_ff_only`
- DONE_CONDITION: 上記が成功
- EVIDENCE_KEYS: `HEAD`（BEFORE/AFTER）, `HEAD_BEFORE/AFTER`
### WIP-010（P002）AUTO stage DONE
- TITLE: AUTO(read-only suite) stage is DONE
- DEFINITION: AUTO 実行結果の stdout に `CURRENT_STAGE=DONE` が存在しない
- TARGET_ACTION: `run.auto_p002`
- DONE_CONDITION: stdout に `CURRENT_STAGE=DONE` が存在する
- EVIDENCE_KEYS: `AUTO_STAGE`（stdoutから抽出）, `STDOUT_LOG_PATH`
---
## P003: writeback 内包（探索禁止・固定workflow）
### WIP-020（P003）writeback dispatch 実行済み
- TITLE: writeback workflow dispatched
- DEFINITION: 本RUN_IDで `workflow_dispatch` 実行痕跡（run_id確定）が存在しない
- TARGET_ACTION: `dispatch.writeback_fixed`
- DONE_CONDITION: `DISPATCH_RUN_ID` が確定している
- EVIDENCE_KEYS: `DISPATCH_RUN_ID`
### WIP-021（P003）run completed/success
- TITLE: dispatched run completed with success
- DEFINITION: `DISPATCH_RUN_ID` の run が `status=completed` かつ `conclusion=success` でない
- TARGET_ACTION: `monitor.run_until_completed`
- DONE_CONDITION: `status=completed` AND `conclusion=success`
- EVIDENCE_KEYS: `RUN_STATUS`, `RUN_CONCLUSION`
### WIP-022（P003）PR 単一確定
- TITLE: PR identified uniquely for this run
- DEFINITION: 対象PRが 0件 または 複数 で単一確定できない
- TARGET_ACTION: `discover.pr_single`
- DONE_CONDITION: `TARGET_PR_NUMBER` が単一に確定
- EVIDENCE_KEYS: `TARGET_PR_NUMBER`, `PR_DISCOVERY_METHOD`
### WIP-023（P003）PR mergeable == MERGEABLE
- TITLE: PR mergeable is MERGEABLE
- DEFINITION: `mergeable != MERGEABLE`
- TARGET_ACTION: `gate.mergeable_check`
- DONE_CONDITION: `mergeable == MERGEABLE`
- EVIDENCE_KEYS: `PR_MERGEABLE`
### WIP-024（P003）main pull 済み
- TITLE: main synced after merge
- DEFINITION: PRマージ後に main sync が実行されていない
- TARGET_ACTION: `sync.main_ff_only`
- DONE_CONDITION: main sync が成功
- EVIDENCE_KEYS: `HEAD`（AFTER）, `HEAD_BEFORE/AFTER`
### WIP-025（P003）Bundled に対象PR証跡行あり（Parent）
- TITLE: Parent Bundled contains target PR evidence line
- DEFINITION: `docs/MEP/MEP_BUNDLE.md`（存在する場合）に対象PR証跡行が存在しない
- TARGET_ACTION: `verify.parent_bundled`
- DONE_CONDITION: 対象PR証跡行が存在する（またはファイルが NOT_FOUND の場合は SKIPPED）
- EVIDENCE_KEYS: `PARENT_BUNDLE_VERSION`, `TARGET_PR_PARENT_LINE_PRESENT`
### WIP-026（P003）EVIDENCE に対象PR証跡行あり（Child）
- TITLE: Evidence Bundled contains target PR evidence line
- DEFINITION: `docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md` に対象PR証跡行が存在しない
- TARGET_ACTION: `verify.evidence_bundled`
- DONE_CONDITION: 対象PR証跡行が存在する
- EVIDENCE_KEYS: `EVIDENCE_BUNDLE_VERSION`, `EVIDENCE_LAST_LINE`, `TARGET_PR_EVIDENCE_LINE_PRESENT`
---
## P004: HANDOFF
### WIP-030（P004）handoff 再生成済み（最新一次根拠反映）
- TITLE: handoff regenerated from latest primary evidence
- DEFINITION: handoff先頭ブロックで `EVIDENCE_BUNDLED_AT` が `NOT_FOUND`、または基準点が最新と一致しない
- TARGET_ACTION: `run.handoff_regenerate`
- DONE_CONDITION: `EVIDENCE_BUNDLED_AT != NOT_FOUND` かつ最新基準点と整合
- EVIDENCE_KEYS: `HANDOFF_EVIDENCE_BUNDLED_AT`, `PARENT_BUNDLE_VERSION`, `EVIDENCE_BUNDLE_VERSION`
---
## メモ（固定）
- P003 の workflow は探索しない：固定パス `.github/workflows/mep_writeback_bundle_evidence_dispatch.yml` のみを使用する
- P003 の入力 pr_number は固定：`0`
- run success だけでは成功扱いしない：WIP-021〜026 の全てが DONE になるまで P003 は未完
