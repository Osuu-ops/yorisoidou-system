# IssueOps #2400 再発防止FIXATE（shirnugui）

## Controller lock（SSOT）
- 正規形（推定禁止）: `^mep:controller=CHAT_[A-Za-z0-9_]+$`
- 本チャットの固定値: `mep:controller=CHAT_CHAT_20260305T140500Z_9A1F`
- writeback生成時は `tools/mep_writeback_create_pr.ps1` が上記を満たさない場合に `STOP_HARD` で終了する。

## 単一スイッチ（freeze / resume / status）
- コマンド: `tools/mep_loop_switch.sh [freeze|resume|status] [owner/repo]`
- 対象ワークフロー（固定）:
  - `mep_entry_clean.yml`
  - `mep_writeback_bundle_dispatch_entry.yml`
  - `mep_writeback_bundle_on_push.yml`
  - `mep_autotrigger_next_cycle.yml`
  - `self_heal_auto_prs.yml`
- `status` は機械可読な `workflow<TAB>state` を出力する。

## Manual entry（dispatch 422再発防止）
- 正本workflow: `.github/workflows/mep_entry_clean_dispatch.yml`
- `entry_clean` は入口成功を維持し、下流dispatch失敗は `continue-on-error` + Step Summaryで可視化する。
- 既定値では自動writeback dispatchを行わない（`dispatch_writeback=false`）。

## 診断不能時の固定迂回（jobs=0 / log not found）
- コマンド: `tools/mep_checkruns_fallback.sh <sha> [owner/repo]`
- `check-runs` から `details_url` を辿って各チェック実体へ到達する。

## Restart / Recovery
1. **Freeze**: `tools/mep_loop_switch.sh freeze Osuu-ops/yorisoidou-system`
2. **State確認**: `tools/mep_loop_switch.sh status Osuu-ops/yorisoidou-system`
3. **Manual entry実行**: `gh workflow run mep_entry_clean_dispatch.yml -f iter=0 -f max_iter=50 -f dispatch_writeback=false -f dispatch_engine=false`
4. **必要時のみwriteback**:
   - `gh workflow run mep_writeback_bundle_dispatch_entry.yml -f pr_number=0 -f controller_label='mep:controller=CHAT_CHAT_20260305T140500Z_9A1F' -f expected_controller_label='mep:controller=CHAT_CHAT_20260305T140500Z_9A1F'`
5. **Resume**: `tools/mep_loop_switch.sh resume Osuu-ops/yorisoidou-system`
