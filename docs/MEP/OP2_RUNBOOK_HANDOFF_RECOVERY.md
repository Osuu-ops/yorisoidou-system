# OP-2 Runbook: handoff 破損時の最小復旧導線（一次根拠化）
目的:
- handoff が破損/欠落しても、main と Bundled/EVIDENCE の一次根拠を PowerShell で吸い上げ直し、復旧できる最小運用系を保持する。
前提:
- repo: https://github.com/Osuu-ops/yorisoidou-system.git
- 基準ブランチ: main
- Bundled: docs/MEP/MEP_BUNDLE.md
- EVIDENCE child: docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md
最小復旧手順（機械的）:
1) main を同期して固定点（HEAD full SHA）を取る
   - git fetch --prune origin
   - git checkout main
   - git pull --ff-only origin main
   - git rev-parse HEAD
2) 親/子バンドルの固定点を取る
   - git log -1 --format="%H %cI %s" -- docs/MEP/MEP_BUNDLE.md
   - git log -1 --format="%H %cI %s" -- docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md
   - ファイル内の BUNDLE_VERSION を抽出（v0.0.0+YYYYMMDD_HHMMSS+...）
3) 追随確認（EVIDENCEがmainに追随しているか）
   - 対象PR番号/mergeCommit(40桁)が、親/子バンドル本文に存在することを確認
   - 親: PR(実装変更)の証跡行 / 子: writeback(追随)の証跡行
4) 必須チェック逸脱の検知（逸脱=STOP_HARDに繋げる材料）
   - Ruleset required checks の名称整合を維持（例: scope-fence / business-non-interference-guard）
   - 逸脱が起きた場合は「どのPRで」「どのチェック名が」「どの状態だったか」を一次出力で記録して復旧/是正へ
5) 復旧後の手渡し（次チャット冒頭に貼る二重構造handoff）
   - 監査用: REPO_ORIGIN / main HEAD(full) / Bundled/EVIDENCE path / BUNDLE_VERSION / 最終コミット / 確定PR(mergedAt/mergeCommit/url)
   - 作業用: OP-0〜派生 / 完了・未完 / 次工程
備考:
- このRunbook自体は「OP-2: 最小運用系を常に保持」の一部（証跡としてmainに保持する）。
