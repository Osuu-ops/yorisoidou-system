# Runner (Phase1 minimal)
この runner は Spec v2.1 の Phase1 最小（BOOT/STATUS/APPLY + SSOT/compiled更新）を実装する。
## 前提
- Python 3.10+ 推奨（3.11+推奨）
- 依存: pyyaml
## セットアップ
- python -m pip install -r tools/runner/requirements.txt
## 実行
- python tools/runner/runner.py boot
- python tools/runner/runner.py status
- python tools/runner/runner.py apply --draft-file <path-to-draft.md>
## 更新されるファイル
SSOT:
- mep/boot_spec.yaml
- mep/policy.yaml
- mep/run_state.json
- mep/inbox/draft_<RUN_ID>.md（apply時）
compiled（射影）:
- docs/MEP/STATUS.md
- docs/MEP/HANDOFF_AUDIT.md
- docs/MEP/HANDOFF_WORK.md