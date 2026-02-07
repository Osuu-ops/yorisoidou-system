# INPUT_PACKET (EXTRACT_INPUT)

STATUS: DRAFT
source: MEP_SSOT_MASTER
ssot_master_path: docs/MEP/MEP_SSOT_MASTER.md
ssot_master_version: v1.12
generated_by: local-script
generated_at: 2026-02-07T19:54:34.6355967+09:00

# PART B: IDEA_NOTE（運用入力器｜Schema＋入力欄｜空欄OK）

（注意：PART Aが“決定正本（Q）”。PART Bは“運用入力器”。未記入は欠落ではない）
（薄い入力は問題にしない。AIがAUTO補完し、不可欠時のみSTOPする：Q106〜Q113）

## B-0) STATUS（入力欄：空欄OK）

STATUS: DRAFT | AUDITED_OK | ADOPTED
source: MEP_SSOT_MASTER
generated_by: (AI/Actions)
generated_at: (UTC/ISO)

## B-1) TOP_GOAL（入力欄：空欄OK）

* goal_id: TG-001
* goal_text: |
  （入力：上位目的を1〜5行。未記入なら機械はBundledの既存TOP_GOALから復元し、不可ならSTOP）
* non_interference: business/system混在禁止（Q5）
* success_definition: |
  （入力：終わりの条件を3行。未記入なら機械が暫定案をDRAFTとして生成し、不可欠ならSTOP）

## B-2) ROADMAP（入力欄：空欄OK）

* done_range: RM-0001..RM-0010
* now: RM-0011
* next_main_range: RM-0012..RM-0020
* exit_range: RM-0021..RM-0030

### 分岐（入力欄）

* branch_type: MAINLINE | SIDEQUEST | EXTERNAL
* attach_mode: INLINE | DETACH
* 昇格：SIDEQUEST/EXTERNAL → MAINLINE は昇格イベントとして記録し、採用Q（台帳追記）を必須とする（Q114整合）。

## B-3) CURRENT_POSITION（機械更新：入力欄／空欄OK）

* now_rm: RM-0011
* phase: PRECHECK | QUESTION | AUTO_REMEDIATE | IMPLEMENT | VERIFY | BUNDLE | HANDOFF
* gate: G0..Gn
* owner_chat: (新チャット開始時にBundled照合で自動固定)
* assigned: true|false
* branch_active: BR-0003 | null
* priority_next: RM-0012 | BR-0003 | null
* stop_class: HUMAN_RESOLVABLE | MACHINE_ONLY | null
* stop_reason_code: null
* stop_kind: WAIT | HARD | null
* resume_packet:

  * ssot_version: ""
  * head: ""
  * parent_bundle_version: ""
  * bundle_version: ""  # alias (deprecated)
  * last_stop: ""

## B-4) ROADMAP_CARDS（テンプレ：空欄OK）

#### CARD: RM-____

* rm_id: RM-____

* title: ""

* card_type: FEATURE | RECOVERY

* class: business | system

* role: main | branch

* branch:

  * branch_id: BR-____ | null
  * branch_type: MAINLINE | SIDEQUEST | EXTERNAL
  * attach_mode: INLINE | DETACH
  * detach_ref: ""   # DETACHなら必須（Q116）

* blocked_by: []

* allowed_paths: []  # 空ならAUTO補完or不可欠ならSTOP（Q109）

* output_root: ""

* artifacts_expected: []

* bundled_cards_expected: []

* handoff_expected: true

* decision_entry:

  * decision_mode: AUTO | HUMAN | null
  * choice_set: []
  * chosen: ""
  * rationale: ""
  * tradeoffs: ""
  * evidence_q: null
  * tiebreak_rule: null
  * confidence: null
  * why_auto: null

* execution:

  * phase_hint: ""
  * stop_reason_code: null
  * stop_class: HUMAN_RESOLVABLE | MACHINE_ONLY | null
  * error_signature: null
  * root_cause_observation: ""
  * proposed_fix: ""
  * touch_points: []
  * acceptance_tests: []
  * rollback_plan: "revert|fix-forward|n/a"
  * recovery_steps: ""

* proof:

  * pr_refs: []
  * commit_refs: []
  * bundled_refs: []
  * health_refs: []

* status: DRAFT | ACTIVE | PARKED | DONE | CANCELED | FORGOTTEN | UNASSIGNED

* parked_trigger: next_bundle

* updated_at: ""

## B-5) AUTO_LOOP_POLICY（要約：空欄OK）

* 薄い入力は問題にしない：AIがAUTO補完（Q106）。
* STOPは2系統のみ：境界不明・汚染リスク／不可逆・高コスト（Q109）。
* STOP時：SSOTから材料復元→選択肢提示（Q112）。Machine-Onlyは質問ではなくRECOVERY起票（Q113）。
* タイブレーク：暫定規則で単一化し台帳へ自動追記（Q114）。
* 参照破損・DETACH参照切れ・環境不足は Machine-Only STOP → RECOVERY起票（Q115〜Q117）。
* AUTO決定の累積はhealthに出す（Q118）。

## B-6) PR_OUTER_POLICY（外周PR正の固定欄：空欄OK）

* required_checks_expected: []
* pr_creator_allowlist: []
* disallow_bot_github_token_pr: true

---