# Handoff 破損 / EVIDENCE 追随破損 からの最短復旧 Runbook（OP-2）
## 目的
handoff / EVIDENCE（子MEP）が破損しても、一次根拠（EVIDENCE_BUNDLE）を起点に最短で復旧し、main の運用に戻す。
## 前提（運用契約）
- main への直接 push は禁止（Ruleset）。必ず PR 経由で反映する。
- 一次根拠は「main の HEAD」「PR の mergeCommit/mergedAt」「Bundled/EVIDENCE_BUNDLE の内容」。
## 手順（最短）
1) 状態の固定（一次根拠を確保）
- main を同期し HEAD を取得する
- 破損の兆候（EVIDENCE_BUNDLE の欠落・競合・追随停止）を確認する
2) 復旧の正本を決める
- EVIDENCE 追随破損の場合は EVIDENCE_BUNDLE を正本として扱う（子が正）
- 親 Bundled 側に不足があれば「子→親 sync」系の経路で戻す
3) 修復は必ず PR で行う
- 修復ブランチを作り、必要ファイルを最小変更で直す
- required checks を通し、Ruleset 経由で merge する
4) 復旧確認
- main 同期 → pre_gate / auto_loop を実行し、停止理由が解消していることを確認する
- HANDOFF（監査用引継ぎ）に main HEAD / PR / mergeCommit / Bundled/EVIDENCE_BUNDLE の BUNDLE_VERSION を固定する
## 失敗時
- pre_gate / auto_loop が停止する場合は「どの監査が落ちたか」を一次出力で特定し、修復PRを追加する
- 破損が広範囲なら、最小安定（MINIMAL STABLE）へ退避してから段階的に復元する
