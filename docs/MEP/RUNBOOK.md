# RUNBOOK（復旧カード）

本書は「異常時の復旧」をカードとして固定する。
本書は説明を行わない。評価を行わない。
目的は、観測 → 一次対応 → 停止条件 → 次の遷移 を迷いなく実行すること。

---

## CARD: no-checks（Checksがまだ出ない／表示されない）

### 観測
- PR の状態とChecks表示
  - `gh pr view <PR> --json number,state,url,headRefName,baseRefName,mergeable --jq '.'`
  - `gh pr checks <PR>`
- GitHub 側の遅延か、ワークフロー未発火かを切り分ける

### 一次対応
- しばらく待って再観測（短時間で出ることがある）
- `gh pr checks <PR>` が永続的に空なら、RUNBOOK: Guard / Scope / token 起因を疑う

### 停止条件（DIRTYへ遷移）
- 何度観測してもChecksが出ない／「No checks」のまま変化しない

### 次の遷移
- `CARD: Guard NG` または `CARD: Scope不足` を適用（観測結果により決定）
- それでも不明なら `CARD: DIRTY`

---

## CARD: behind / out-of-date（Head branch is out of date）

### 観測
- PR 画面で “Head branch is out of date” 表示
- `gh pr view <PR> --json mergeable,baseRefOid,headRefOid --jq '.'`

### 一次対応
- 原則：main を取り込んで更新（rebase/merge は運用規約に従う）
- 自動で安全に解決できない場合は DIRTY に落とす

### 停止条件（DIRTYへ遷移）
- 競合が発生する／解決に人間判断が必要

### 次の遷移
- 解消できたら PLAYBOOK の該当カードへ復帰
- 解消できないなら `CARD: DIRTY`

---

## CARD: DIRTY（自動で安全に解決できない）

### 観測
- `git status --porcelain` が空でない
- 差分が「意図した範囲」外へ漏れている
- どのカードにも機械的に当てはまらず、人間判断が必要

### 一次対応
- 自動実行を停止する（これ以上進めない）
- 停止理由を分類し、人間入力に変換する（最大3点）

### 停止条件（固定）
- 以後の自動PR作成は行わない

### 次の遷移
- PLAYBOOK へ戻す前に、人間が「採るべき方針」を確定させる

---

## CARD: Scope不足（Scope Guard / Scope-IN Suggest）

### 観測
- Scope Guard が NG
- 変更対象が Scope-IN に含まれていない

### 一次対応
- CURRENT_SCOPE に必要最小限の Scope-IN を追加する（1PR）
- 余計なパスを増やさない

### 停止条件（DIRTYへ遷移）
- どのパスを許可すべきか、人間判断が必要

### 次の遷移
- Scope PR が通ったら、元の目的PRへ復帰

---

## CARD: Guard NG（Chat Packet Guard / Docs Index Guard 等）

### 観測
- Guard のチェック名とログで NG 理由を確定
- 典型：生成物が outdated / 参照不整合 / 期待ファイル不足

### 一次対応
- main 最新から「生成物を再生成して整合」させる（差分最小）
- 必要なら `docs/MEP/build_*` を実行して追随させる

### 停止条件（DIRTYへ遷移）
- 追随しても原因が解消しない
- 参照の正が不明で人間判断が必要

### 次の遷移
- 解消できたら PLAYBOOK へ復帰
- 解消できないなら DIRTY

---

## CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

### 症状
- PowerShell/端末が落ちた
- rebase/merge/cherry-pick が途中で止まった
- 状況が不明だが、安全に観測へ戻りたい

### 目的
- ローカルの途中状態を安全に解除し、DIRTY を検出したら停止する
- Continue Target（open PR → failing checks → RUNBOOK）へ戻す

### 手順（PowerShell 単一コピペ）
~~~powershell
$ErrorActionPreference = "Stop"
$repo = (gh repo view --json nameWithOwner -q .nameWithOwner)

& git rebase --abort 2>$null | Out-Null
& git merge --abort 2>$null | Out-Null
& git cherry-pick --abort 2>$null | Out-Null

$porcelain = (& git status --porcelain)
if (-not [string]::IsNullOrWhiteSpace($porcelain)) {
  git status
  throw "DIRTY: 未コミット変更あり（人間判断へ）"
}

git checkout main | Out-Null
git pull --ff-only | Out-Null

gh pr list --repo $repo --state open
~~~

### 判定
- DIRTY が出たら停止して人間判断へ
- clean なら観測に復帰

## CARD-BOOT: One-Packet Bootstrap（新チャット/新アカウント向け）
- 実行：`.\tools\mep_chat_packet_min.ps1` を実行し、出力を貼る。
- AI：個別ファイル要求は禁止。必要なら再貼付のみ要求する。

<!-- CARD: BUSINESS_IMPL_GO_NOGO -->

## CARD: BUSINESS_IMPL_GO_NOGO（業務系へ進むGo/No-Go）

### 観測
- open PR が 0 か
  - `gh pr list --state open`
- Phase-1（PARTS/EXPENSE）の marker が origin/main に揃っているか（唯一の正で確認）
  - `git show origin/main:platform/MEP/03_BUSINESS/よりそい堂/business_spec.md`
  - `git show origin/main:platform/MEP/03_BUSINESS/よりそい堂/business_master.md`
  - `git show origin/main:platform/MEP/03_BUSINESS/よりそい堂/ui_master.md`
  - `git show origin/main:platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md`

### 一次対応（PowerShell 単一コピペ）
~~~powershell
$ErrorActionPreference="Stop"
$repo = (gh repo view --json nameWithOwner -q .nameWithOwner)

git checkout main | Out-Null
git pull --ff-only | Out-Null
if (git status --porcelain) { git status; throw "NO-GO: working tree not clean" }

$open = (gh pr list --repo $repo --state open --json number,title,headRefName | ConvertFrom-Json)
if ($open.Count -ne 0) { $open | Format-Table -AutoSize; throw "NO-GO: open PR exists" }

$need = @(
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/business_spec.md";  marker="<!-- PARTS_SPEC_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/business_master.md"; marker="<!-- PARTS_FIELDS_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/ui_master.md";       marker="<!-- PARTS_UI_MASTER_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md";         marker="<!-- PARTS_FLOW_PHASE1 -->" },

  @{ file="platform/MEP/03_BUSINESS/よりそい堂/business_spec.md";  marker="<!-- EXPENSE_SPEC_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/business_master.md"; marker="<!-- EXPENSE_FIELDS_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/ui_master.md";       marker="<!-- EXPENSE_UI_MASTER_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md";         marker="<!-- EXPENSE_FLOW_PHASE1 -->" }
)

$ng=@()
foreach($x in $need){
  $txt = (git show ("origin/main:{0}" -f $x.file) | Out-String)
  if ($txt -notmatch [regex]::Escape($x.marker)) { $ng += "$($x.file) :: $($x.marker)" }
}

if ($ng.Count -ne 0) { $ng | ForEach-Object { "MISSING: $_" }; throw "NO-GO: missing markers" }
"GO: Business implementation can proceed."
~~~

### 停止条件（NO-GO）
- open PR が 1本でもある
- marker が欠けている
- working tree が dirty

### 次の遷移（GO）
- 業務系（実装・運用側）へ進む（Phase-1 を前提として進める）

## CARD-07: Request Status Normalization (status/requestStatus)

### When to use
- Request sheet has mixed usage of `status` and legacy `requestStatus`, and list/read results look inconsistent.

### Endpoint
- Use the current B22 endpoint recorded in STATE_CURRENT.

### Procedure (safe)
1) DRY-RUN first:
- POST `{ "action":"request.normalize_status_columns", "limit":200, "dryRun":true }`
- Check `result.conflicts`:
  - `conflicts == 0` => proceed to write
  - `conflicts > 0`  => STOP (do not write). Resolve conflicts manually (row-by-row) then rerun.

2) WRITE:
- POST `{ "action":"request.normalize_status_columns", "limit":200, "dryRun":false }`
- Confirm summary: `fixed` increased, `conflicts` stayed 0.

### Conflict rule (fixed)
- If both columns are set and different: the tool MUST NOT overwrite. It reports the row as conflict.

### Notes
- Repeat until `fixed == 0` and `conflicts == 0` for the scanned range.

## CARD-08: GAS Fixed-URL Redeploy (clasp fast loop)

### Purpose
- Update GAS WebApp without changing /exec URL (deploymentId fixed), and verify by GET /exec.

### Preconditions (one-time)
- Node.js + npm installed
- clasp installed: npm i -g @google/clasp
- clasp login completed (creates ~/.clasprc.json)
- Google Apps Script API enabled (Apps Script user settings)
- Workspace exists: gas\clasp_webapp
  - .clasp.json contains:
    - scriptId=1wpUF60VBRASNKuFOx1hLXK2bGQ74qL7YwU4Eq_wnd9eEAApHp9F4okxc
    - rootDir=src

### Fixed endpoint
- deploymentId (fixed URL): AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw
- fixed /exec: https://script.google.com/macros/s/AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw/exec

### Fast loop (PowerShell)
- Edit: gas\clasp_webapp\src\コード.js
- Then run (single-block): push -> create-version -> redeploy -> GET verify
  - NOTE: redeploy CLI:
    clasp redeploy <deploymentId> --versionNumber <ver> --description <desc>

### Local safety note
- If you use git clean -fd often, protect workspace locally:
  Add to .git/info/exclude:
    gas/clasp_webapp/

<!-- OPS_RUNBOOK_CARD_BEGIN -->
# 運用RUNBOOK（現場）｜コピペ運用カード（確定）

## 目的
- 現場は「全文コピペ」だけで進める
- 抽出・判定は自動（最後は 0＝承認）

## 受注コピペ（ORDER）
### 抽出 7項目（固定）
1) 顧客名
2) 住所（必須）
3) 決済チャネル（DIRECT / MITSUMOA / KURAMA / MEDIA_OTHER）
4) 支払い方法（CASH / BANK / CARD / POSTPAY / OTHER）
5) 作業内容（work_menu 複数可）※未確定は空欄
6) 金額（合計）
7) 既存顧客フラグ（空欄 / ◯ / ◎）

### 既存顧客フラグ
- 初回：空欄
- 2回目：◯
- 3回目以降：◎
- ◯/◎ の場合：コメントに「過去の作業＋日時」を追記（必須）

### 媒体差分
- KURAMA：定型文から取れる範囲だけ採用（作業内容が無ければ空欄）
- MITSUMOA：回答内容以下は捨てる（作業内容は原則空欄）

## 完了報告コピペ（DONE）
### 最終チェック（完了可否）
- 最優先：確定申告チェック（不足があれば必ず❌→完了復旧）
  - 顧客名
  - 住所（番地・建物名まで）
  - 作業日（訪問日時）
  - 作業内容（work_menu 複数可）
  - 金額（0円不可。ただし WM_900/901/902 例外あり）
  - 支払い方法

### 書類判定（完了報告時）
- 判定対象は「請求書」「領収書」のみ（見積書は対象外）
- 0円は請求書/領収書を発行しない

### 完了確認コメント（省略形・一時UI）
【完了確認】
顧客：<顧客名>（<空欄/◯/◎>）
作業：<作業一覧（/区切り）>
金額：<合計>（<支払い方法>）

確定申告：✅/❌（理由1語）
書類作成：
✅/❌ 請求書
✅/❌ 領収書

## 例外（WM_900/901/902）
- WM_900（見積のみ）
- WM_901（キャンセル）
- WM_902（無料対応）
上記が選択/記録されている場合のみ、0円/未記入でも完了可能（書類は発行しない）

## 状態（手動が正）
- 状態の確定は手動（自動は提案・ガードのみ）
- 3→4 を手動で進めるのは許可。ただし警告コメント：
  - 「納品未確認のまま4へ移行」
  - 「残タスク：納品確認」
<!-- OPS_RUNBOOK_CARD_END -->


<!-- FIXATION_PROTOCOL_BEGIN -->
# FIXATION_PROTOCOL（固定・保管・汚染防止）｜唯一の正

## 目的
- GPT側の忘却・推測で汚染が起きないようにする
- 「確定」は必ず GitHub（MEP）へ固定し、次回以降の唯一の正とする

## 固定の原則（必須）
- 会話で「採用」「確定」「0（承認）」になった内容は **必ず MEP に記録して main に反映**する
- main に反映されていない内容は **確定扱いにしない**
- 仕様に無いことは **提案** と明記し、0（承認）まで確定しない

## 汚染防止（必須）
- GPTは、MEP（business/*, seed/*, docs/MEP/*）に根拠が無い断定をしない
- 断定が必要な場合は、必ず以下のいずれか：
  1) 該当ファイルのパスと該当セクション（見出し）を示す
  2) ユーザーに該当箇所の貼り付けを要求する
  3) 「提案」として提示し、0（承認）を待つ

## マージ時の運用（必須）
- “思想・運用・判断ルール” を含む変更は、PR内に固定ブロック（この章）またはRUNBOOK更新を伴う
- auto-merge が通らない場合でも、0（承認）後は **手動マージで main に確定反映**する

## 実務ルール
- 以後、決定事項は「PRで固定→main反映」を完了条件とする
- 反映が終わるまで次の確定事項に進まない（汚染防止）
<!-- FIXATION_PROTOCOL_END -->

<!-- MEP_UI_ZERO_BUNDLE_POLICY_BEGIN -->
## UI汚染ゼロ：単一フルバンドル運用（固定）

- UIでは「単一フルバンドル（本文差し込み済み1ファイル）」のみを入口投入物とする（それ以外は前提にしない）。
- 変更はチャット内では「提案」止まり。確定は 0（承認）→PR→main 反映→フルバンドル更新→次チャット開始時に最新バンドル投入。
- 完了ゲート：網羅チェック → 「この内容が引き継がれました（BUNDLE_VERSION/commit）」表記 → 0（承認）。
- 引き継ぎ／引っ越し／新規チャット開始時に貼り付けるパス（参照・投入対象）は、必ず「最後の完結分（完了ゲート後）」に貼る。
- 決定・反映に関する発言は必ず状態タグで明示（Draft / Adopted / PR Open / Merged to main / Bundled / Completed Gate）。PR番号・commit・BUNDLE_VERSION等の証跡がない限り「反映済み」と扱わない。
- 表示規約（チャット出力）：毎回 [STOCK]→[FOCUS]→[PROGRESS] を先頭3行に置き、説明は最小化する。

<!-- MEP_UI_ZERO_BUNDLE_POLICY_END -->

<!-- MEP_UI_DISPLAY_RULES_BEGIN -->
## 表示ルール（固定）

- 通常表示：2行のみ（[モード] / [現在地]）。
- ユーザーが「4行見せて」と言った時のみ4行表示（2行＋[ブレイン]＋[プロダクト]）。
- 生成中（実装モード）は表示0行（コードのみ）。失敗があれば即コードで修正し、完了までコード提示を継続する。
- ユーザーが自由文を送ったらコード提示を停止して天才へ戻り、「コード書いて」「生成に進む」で再び生成に入る。
<!-- MEP_UI_DISPLAY_RULES_END -->

<!-- MEP_BRAIN_PRODUCT_FLOW_BEGIN -->
## ブレイン／プロダクト（メモ→採用→生成→完了）運用（固定）

- ブレインとプロダクトは独立に管理する。
- カウント運用：
  - 「メモ」＝メモに追加（保留）
  - 「採用」「ここまで採用！」＝メモを飛ばして採用へ（「ここまで採用！」は束ねて1採用）
  - 「生成に進む」「コード書いて」＝生成へ
- 完了の定義：
  - ブレイン：バンドル完了（起動ファイルに反映される）
  - プロダクト：マージ完了（成果物がmainに反映される）
<!-- MEP_BRAIN_PRODUCT_FLOW_END -->

<!-- MEP_APPROVAL_GATE_BEGIN -->
## 承認ゲート（固定）

- 「メモ」および「採用（メモを採用含む）」を行う際は必ず承認（0/1）を取る。
- メモ/採用の対象が「メモ時点の内容」か「その後の追加分を含む」かを必ず明示する。
- 追加分が未記載の場合は「追加してよいか」を必ず確認し、承認を取る。
<!-- MEP_APPROVAL_GATE_END -->

