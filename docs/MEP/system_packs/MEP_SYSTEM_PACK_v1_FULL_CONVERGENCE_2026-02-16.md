# MEP_SYSTEM_PACK_v1｜入口＋2レイヤー正本（FULL CONVERGENCE + SAFETY INTEGRATION 2026-02-16）
TITLE: MEP_SYSTEM_PACK_v1_入口＋2レイヤー正本（2026-02-16）
SYSTEM_ID: SYS-MEP
BUSINESS_ID: NONE
============================================================
=== DOC 1: ENTRY_GOVERNANCE ================================
============================================================
FROZEN（仕様正文）
## 1. 目的
本仕様は、草案＋PATCHの投入から保存先確定（System/Business）、
ID付与、統合、監査、返却までを一貫して安全に運用するための入口ガバナンスを定義する。
本仕様は入力が以下のいずれであっても処理を開始できることを前提とする。
- 草案のみ
- 草案＋PATCH
- STOP_WAIT 状態
- STOP_HARD 状態（STOP_HARD_FATAL でない限り。STOP_HARD_FATAL の定義は DOC 2 #9 参照）
（追記）本仕様における「完成品1セット」は DONEのみを意味しない。
STOP_WAIT / STOP_HARD でも、現時点の最善として「返却物1セット」を生成し返却する（DOC2参照）。
2. ヘッダー規約（必須）
草案の最上段は以下順序で固定する。
1. TITLE: <案件名>_<目的>（YYYY-MM-DD）
2. SYSTEM_ID: SYS-MEP
3. BUSINESS_ID: NONE | BIZ-...
TITLEはローカル保存時のファイル名の基礎とする。
3. 初回（IDなし）の挙動
Step1：保存先選択（必須）
数値入力は禁止（0＝承認との衝突回避のため）。
S = SYSTEM
B = BUSINESS
Step2：BUSINESSの場合
既存候補がある場合
1..n = 既存候補
N = 新規ID作成（即作成で進行）
候補なし
N = 新規ID作成（即作成で進行）
4. 2回目以降（IDあり）
BUSINESS_IDが存在する場合はオート確定。
選択肢は出さない。
5. 保存規約（Vault）
BUSINESS_ID: NONE → System Vault
BUSINESS_ID: BIZ-... → Business Vault
Vault Root Key（固定）
System: vault/system/
Business: vault/business/
6. BUSINESS ID生成規則（確定）
形式：
BIZ-YYYYMMDD-XXXX
YYYYMMDD = UTC日付
XXXX = 16進大文字4桁
衝突回避：
最大16回再生成
16回失敗 → STOP_HARD_FATAL
7. エラー検知
TITLE欠落 → STOP_WAIT
SYSTEM_ID/BUSINESS_ID不整合 → STOP_WAIT
BUSINESS_ID形式不正 → STOP_HARD_FATAL
STOPは終了ではない（DOC2参照）。
============================================================
=== DOC 2: TWO_LAYER_SSOT =================================
============================================================
FROZEN（2レイヤー正本）
1. 目的
文章が統合・監査・校正で薄まらないため、
正本を文章ではなくデータ構造で保持する。
正本は以下2レイヤーとする。
doctrine.json（思想・規範の正）
behavior.json（挙動・状態の正）
formal.md は生成物であり正本ではない。
（追記）「収束（CONVERGENCE）」は、正本（doctrine/behavior）そのものを必ず更新することを意味しない。
収束は、resolved_spec.json 上で完結して「返却物1セット」を生成することを最小義務とする（7章参照）。
2. Doctrine（doctrine.json）
必須フィールド
doctrine_version
core_doctrine
norms
prohibitions
priority_rules
強度（固定4値）
MUST
MUST_NOT
SHOULD
MAY
強度変更の扱い
MUST→SHOULD 等の強度低下は停止しない。
必ず diff_report に記録する。
（追記）正本更新ポリシー（採用＝コミット/統合）を doctrine 側で制御できるよう、以下の設定を規範として保持してよい：
auto_commit_on_safe_bias（TRUE/FALSE）
TRUE：SAFE_BIAS=TRUE の場合、正本更新（doctrine/behavior 反映）まで自動で行ってよい
FALSE：SAFE_BIAS=TRUE でも、正本更新は行わず resolved_spec のみで収束して返却する
（追記）auto_commit_on_safe_bias の既定値は FALSE とする。
3. Behavior（behavior.json）
必須フィールド
behavior_version
states
transitions
invariants
wait_limit_count
wait_limit_duration_minutes
状態集合
RUNNING
WAIT
STOP_WAIT
STOP_HARD
RECOVERY
DONE
（追記）STOP_HARD は曖昧性を排除するため 2分類を持つ：
STOP_HARD_FATAL：自動修正禁止領域（RECOVERYへ遷移しない）
STOP_HARD_RECOVERABLE：自動修正可能領域（RECOVERYへ遷移してよい）
（追記）STOP_HARD を返す場合は、必ず hard_kind を併記する（FATAL/RECOVERABLE のいずれか）。
WAIT上限（自己完結）
wait_limit_count = 2
wait_limit_duration_minutes = 30
WAITがいずれかを超えた場合 → STOP_WAIT
（追記）修正ループ全体（RECOVERY含む）にも WAIT上限を適用してよい。
4. 監査と自動修正
AUTO_APPLIED
形式補正
Draft排除
Supersedes解決
並び整理
formal再生成
MEANING_OR_STRENGTH_CHANGED
強度変更
規範変更
禁止集合変更
停止はしないが必ず記録する。
（追記）AUTO_APPLIED は 正本の更新（doctrine/behaviorのコミット）を必須としない。
AUTO_APPLIED は resolved_spec 上で反映し、返却物の整合を満たすことを最小要件とする。
5. 差分レポート構造（固定）
DIFF REPORT
AUTO_APPLIED
MEANING_OR_STRENGTH_CHANGED
MANUAL_REQUIRED
SAFE_BIAS
SAFE_BIAS = TRUE 条件
MEANING_OR_STRENGTH_CHANGED が空
MANUAL_REQUIRED が空
（追記）STOP_WAIT / STOP_HARD の場合でも diff_report は必ず生成する。
（追記）STOP_HARD の場合は MANUAL_REQUIRED に「hard_kind」「理由」「禁止領域（自動修正不可理由）」を必ず記録する。
6. 返却物（1セット固定）
formal.md
diff_report.md
invariant_report.md
doctrine.json（変更時）
behavior.json（変更時）
resolved_spec.json（任意）
（追記）AUTO_PATCH を採用する場合、返却物セットに以下を 追加してよい：
auto_patch.json（機械適用用）
auto_patch.md（人間監査用）
7. CONVERGENCE（収束責務：本PACKの核心）
7.1 収束義務（MUST）
入力が以下のいずれであっても、
MEPは「返却物1セット」を生成するまで処理を継続する。
草案のみ
草案＋PATCH
STOP_WAIT状態
STOP_HARD状態（STOP_HARD_FATAL でない限り。定義は DOC2 #9 参照）
STOPは終了ではない。
STOPは修正ループの状態である。
（追記）ここでいう「返却物1セット」は、DONEのみを指さない。
DONE：完成（最終収束）
STOP_WAIT：人間入力待ちの最善セット（現時点で確定できる範囲を最大化して返却）
STOP_HARD：修正不能の最善セット（理由・禁止領域を明示して返却）
7.2 自動PATCH生成
diff_report生成後、以下を行う。
SAFE_BIAS = TRUE
→ AUTO_PATCH生成
→ resolved_spec へ自動適用
→ 再監査
SAFE_BIAS = FALSE
→ PATCH案生成
→ MANUAL_REQUIRED記録
→ STOP_WAIT
（追記）AUTO_PATCH のフォーマットは固定し、機械適用と人間監査を分離する：
auto_patch.json：機械適用用（機械がそのまま適用できる形式）
auto_patch.md：人間監査用（要点／理由／影響範囲を記述）
（追記）AUTO_PATCH の適用先は、優先規則に従い resolved_spec を作ることを最小要件とする。
doctrine/behavior への正本更新（コミット・統合）は、doctrine の auto_commit_on_safe_bias に従う。
7.3 修正ループ
修正ループは以下で制限される。
wait_limit_count
wait_limit_duration_minutes
上限到達 → STOP_WAIT
（追記）STOP_WAIT に落ちる場合、diff_report の MANUAL_REQUIRED に 不足情報（例：TITLE欠落等） を必ず列挙する。
7.4 DONE条件
以下すべて満たす場合
SAFE_BIAS = TRUE
MANUAL_REQUIRED = 空
invariants違反なし
→ 状態 = DONE
DONE時に返却物1セットを確定出力する。
（追記）DONE でも doctrine の auto_commit_on_safe_bias = FALSE の場合、正本（doctrine/behavior）の更新は行わず、resolved_spec を正として返却する。
7.5 POST_CONVERGENCE_NEXT（完成品後の次アクション提示：追加規定）
完成品（返却物1セット）を生成した後、MEPは次アクションを以下の規則で決定し、必要に応じて選択肢を提示する。
7.5.1 原則（MUST）
* 次アクション提示は「常に選ばせる」のではなく、状態により自動分岐する。
* ただし STOP_WAIT / STOP_HARD（特にFATAL）は人間判断が不可避なため、必ず選択肢を提示する。
* DONE であっても、正本更新（doctrine/behaviorへのコミット・統合）が伴う場合は、doctrine の auto_commit_on_safe_bias に従う。
7.5.2 状態別ルール（MUST）
A) DONE（かつ SAFE_BIAS=TRUE）
* auto_commit_on_safe_bias = TRUE
  → 自動で次の実装ループへ投入してよい（次サイクルへ進行）。
* auto_commit_on_safe_bias = FALSE
  → 正本更新は行わず、resolved_spec を正として返却し、次の実装ループへ投入するかは選択肢として提示する。
B) STOP_WAIT
* 必ず選択肢を提示する。
* MANUAL_REQUIRED に列挙された不足情報・未解決衝突を提示し、入力が得られ次第、RECOVERY → 再監査 → 再収束へ進む。
C) STOP_HARD_FATAL
* 必ず選択肢を提示する。
* 自動で実装ループへ投入してはならない。
* MANUAL_REQUIRED に hard_kind（FATAL）・理由・禁止領域（自動修正不可理由）を必ず記録する。
D) STOP_HARD_RECOVERABLE
* 原則として RECOVERY へ遷移し、修正ループを実行してよい。
* ただし wait_limit により収束できない場合は STOP_WAIT に落とし、選択肢を提示する。
7.5.3 選択肢（UI）最小セット（固定）
DONE（SAFE_BIAS=TRUE かつ auto_commit_on_safe_bias=FALSE）
1. 実装ループへ投入（次サイクルへ進行）
2. 今回はここで停止（resolved_specのみ確定）
STOP_WAIT
1. 不足情報を入力して再収束（RECOVERYへ）
2. 今回は固定して停止（次回へ持越し）
STOP_HARD_FATAL
1. 修正方針を選ぶ（入力差し替え／禁止領域回避等）
2. 中止（安全停止）
8. PRIORITY_RULES（衝突時の単一解化：追加規定）
本PACKは「単一解化」を必須とし、衝突は以下の優先規則で処理する。
本規則は doctrine.json の priority_rules にも同内容を持つ。
doctrine が behavior に優先する
Adopted（確定）扱いのPATCHが Draft より優先する
Supersedes が存在する場合、Supersedes により単一解化する
競合が解消できない場合、MANUAL_REQUIRED に記録し STOP_WAIT とする
STOP_HARD は必ず hard_kind（FATAL/RECOVERABLE）に分類し、FATAL は自動修正を禁止する
9. STOP_HARD_FATAL（自動修正禁止領域：追加規定）
以下のいずれかに該当する場合、STOP_HARD_FATAL とし自動修正を禁止する：
BUSINESS_ID形式破壊（規定の形式に復元できない）
doctrine/behavior/resolved_spec のJSONが破損し、機械的復旧が不可能
prohibitions（禁止集合）で明示された「自動修正禁止」に抵触
返却物セットを生成すると安全上のリスクが増大すると判定される（安全規約違反）
（追記）STOP_HARD_RECOVERABLE は上記に該当しない STOP_HARD とする。
============================================================
END OF PACK
============================================================
