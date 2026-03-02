MEP 導入パケット v0.1（入口固定・自走前提・Codex主体）
0. 目的（最重要）
•草案（人間+GPT）→ GitHub Issue → 実行エージェント → MEP監査 → Codex実装 → PR → required checks → merge を自動で完走させる。
•意味矛盾以外は止まらない（不可抗力はWAIT、その他は自動修正 or 分割で続行）。
⸻
1. 入口（唯一の起動方式）
1.1 草案の置き場
•草案は GitHub Issue本文に自由記述で保存してよい（テンプレ強制なし）。
1.2 起動トリガ（送信ボタン）
•Issueの最後の行、またはコメントに /mep run を書いた時点で 実行対象とする。
/mep run が無いIssueは「草案保存庫」であり、実行しない。
⸻
2. 実行主体（誰が取りに行くか）
•**実行エージェント（GitHub Actions想定）**が Issue を監視し、/mep run を検知したら開始する。
•GPT/Codexは「呼ばれたら返す」側。
呼ぶのは常に実行エージェント。
⸻
3. 監査と停止（意味矛盾以外は止めない）
3.1 STOPの分類
•STOP_HARD（意味矛盾のみ）：仕様矛盾・単一解不能・禁止事項違反（allowlist/ops違反等）
•STOP_WAIT（不可抗力のみ）：外部要因で継続不能（認証/ネットワーク/サービス障害）
3.2 続行原則
•意味矛盾以外の失敗は、自動修正または作戦変更（分割）で続行する。
•STOP_WAITは「放棄」ではなく 自動再開前提の保留。
⸻
4. 作戦変更（パッチ分割）— 採用済みルール
4.1 分割トリガ（停止ではなく戦術変更）
次のいずれかで 自動分割する：
•同一 reason_code が N回連続（推奨N=3）
•PATCH_TOO_LARGE
•INTEGRATION_CONFLICT
•NO_CHECKS
•RETRY_LIMIT_EXCEEDED（ただしSTOPしない）
4.2 分割の絶対順序
1..github/workflows/*（必ず最優先で単独パッチ/単独PR）
2.mep/*
3.docs/*
4.3 分割しないWAIT例外
以下は分割せず WAIT：
•AUTH_FAILURE
•GitHub API 到達不可（CONNECT/403/トンネル等）
•外部障害（5xx等）
⸻
5. 実装（Codex主体）と反映（PR主体）
•実装・変更作成・テスト・修正は Codex主体で行う。
•GitHub反映は 必ずPR経由（main直push禁止の前提に適合）。
•required checks が出ない場合は workflows分割PRで修理し、再試行する。
⸻
6. 成果物の返却先（固定）
•成果物（差分）：PR（URLを返す）
•確定（完成形）：main（mergeで確定）
•状態/再開点：MEP SSOT/compiled（run_state + STATUS/HANDOFF）
•人間への返答：起動したIssueへコメントで返す（PR URL / STOP理由 / next_action）
⸻
7. 実行エージェントの最小責務（これだけやれば回る）
1./mep run を検知して Issue本文を取得
2.MEPに取り込み（RUN_ID付与・SSOT更新）
3.監査（意味矛盾ならSTOP_HARD、不可抗力ならSTOP_WAIT）
4.PASSなら Codexを起動して実装→PR作成
5.checksを確認し、揃わなければ workflows分割PRで修理
6.merge可能なら merge（auto-merge可なら設定）
7.Issueへ結果返却（PR URL/状態/次アクション）
⸻
Codexに貼る「実行指示（最小）」
（Issueを見て作業する時の共通指示として使う）
•このIssue本文の草案を起点に、必要な変更を PR経由でmainに反映せよ。
•required checksが出ない/足りない場合は .github/workflows/* を単独PRで修理してから再試行せよ。
•意味矛盾以外は止めない。失敗は自動修正か、分割（workflows→mep→docs）で続行せよ。
•完了時はIssueに PR URL / 状態 / 次アクション を返せ。
⸻
これで「散らばり」は解消され、次回からは Issue に草案＋/mep run だけで開始できます。