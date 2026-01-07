<!--
UI spec is derived from master_spec (CURRENT_SCOPE: Yorisoidou BUSINESS).
NOTE: navigation/positioning only; does NOT change meaning.
RULE: 1 theme = 1 PR; canonical is main after merge.
-->

UI_spec_<業務>.md

業務 UI ― UI 適用仕様（エンドユーザー向け）

※ <業務> は後から具体名（例：水道修理／申込受付 等）に置換する前提のテンプレート確定版です。

1. 対象仕様の概要

本 UI_spec_<業務> は、
エンドユーザーが業務を依頼・入力・確認するための業務 UIに対して、
UI_PROTOCOL に定義された UI 統治・意味仕様を、
特定業務の文脈に適用した結果を記述するものである。

本書は以下を満たす。

本書は UI_PROTOCOL に従属する

本書は 業務 UI 専用の派生文書である

本書は MEP 操作 UI（UI_spec_MEP）とは責務を分離する

本書は UI の原則・状態定義を再定義せず、参照に留める

2. 業務 UI の役割

業務 UI の役割は以下に限定される。

ユーザーに 必要な入力を迷わせずに行わせる

入力途中・未完了状態を 不安なく継続可能にする

処理状態（送信中／確認中／完了）を 誤認させない

業務判断・仕様解釈を ユーザーに要求しない

業務 UI は、
仕様を作らず、業務を進めるための入口である。

3. 画面構成（業務 UI）
3.1 画面種別

入力画面（主画面）

業務に必要な情報を入力する画面

1画面または段階分割（ステップ）形式を許容する

確認画面

入力内容を送信前に確認する画面

編集に戻れる導線を持つ

完了画面

受付・送信が完了したことを示す画面

次にユーザーが取るべき行動を示す

4. 入力項目の意味配置
<<<<<<< HEAD
=======

## Request入力の整合チェック（UI制約｜意味変更なし）

本UIは、master_spec 3.7.2 の PayloadJSON 共通ルールに従い、入力の矛盾を作らない。

- targetType / targetId は必須（master_spec 3.7.2）
- UF07（価格申請）の場合：
  - targetType = PART_ID
  - partId は必須
  - **partId と targetId は同値**（矛盾は送信不可）
- UF08（追加報告）の場合：
  - targetType = Order_ID
  - orderId は必須
  - **orderId と targetId は同値**（矛盾は送信不可）
>>>>>>> origin/main
4.1 入力項目の原則

ユーザーが 意味を理解できない専門語を使わない

入力理由が暗黙に理解できる順で並べる

「必須／任意」は UI_PROTOCOL の原則に従って表示する

4.2 入力補助

例文・プレースホルダーは
正解例ではなく記述の方向性を示す

未入力によるエラーは
責めない文言で示す

5. 操作順序（業務 UI の標準フロー）

入力画面を表示

業務情報を入力

確認画面で内容を確認

送信処理を実行

完了画面を表示

※ 操作順序は強制ではないが、
本順序を基準とする。

6. 状態と表示の関係
6.1 処理中表示

送信・確認処理中は、
処理中であることを明示する

二重送信を誘発する操作は表示しない

6.2 完了表示

業務が「受理された」ことのみを示す

内部処理や判断結果を断定的に示さない

7. 業務 UI における表示文言
7.1 入力開始時

必要な情報を入力してください。
途中で保存・中断することもできます。

7.2 入力中

入力内容はまだ送信されていません。
必要に応じて修正してください。

7.3 処理中

送信処理を行っています。
完了するまでお待ちください。

7.4 入力不備時

入力内容に不足があります。
該当箇所をご確認ください。

7.5 完了時

送信が完了しました。
受付内容を確認のうえ、後ほどご連絡します。

8. MEP との責務境界

業務 UI は 業務入力の受付までを担当する

業務仕様化・判断・生成は MEP 側の責務とする

業務 UI は master_spec を直接編集しない

9. 本書の更新ルール

本書は 業務 UI の仕様変更時にのみ更新する

MEP 内部仕様の変更により更新されることはない

UI_PROTOCOL の変更を伴う修正は行わない

UI 実装は、本書との差分として管理される

以上で、UI_spec_<業務>.md（業務 UI 用テンプレート）の生成を完了します。
<<<<<<< HEAD
=======

## DOC_FLOWS（参照のみ）

本 ui_spec は「表示／導線（ナビゲーション）」のみを扱い、
見積・請求・領収の **業務上の意味／必須条件／状態遷移** は定義しない。

DOC系の業務定義（唯一の正）は master_spec を参照する：
- platform/MEP/03_BUSINESS/よりそい堂/master_spec
  - 10.3 DOC（書類リクエスト）
  - 10.4 DOC系ステータスと導線（見積／請求／領収｜業務定義）

## ALERT_LABELS（表示／導線のみ）

本節は「管理警告ラベル」を UI 上でどこにどう表示するかの導線を定義する。
業務上の意味・判定・列挙は master_spec が唯一の正であり、本 ui_spec は再定義しない。

参照（唯一の正）：
- platform/MEP/03_BUSINESS/よりそい堂/master_spec
  - 8.4 管理警告（業務要件）
  - 8.4.1 管理警告ラベル（固定｜監督UIの表示根拠）
  - 11.1.1 写真不足フラグの根拠
  - 11.1.2 違和感素材フラグ（signals）

表示位置（推奨・固定）：
1) 管理タスク（監督UI）
- タスク名や本文の上部に「警告ラベル」を一覧表示する。
- 表示は短いラベル（例：PHOTO_INSUFFICIENT / ADDRESS_VARIANCE 等）を基本とし、必要なら日本語補足を併記する。
- 複数ラベルがある場合は並列表示し、優先順位は UI で強制しない（監督判断）。

2) OV01（閲覧カルテ）
- 健康スコア付近、または概要セクションに「警告ラベル」を一覧表示する。
- ラベルクリック（または展開）で、該当する根拠（写真不足／signals種別）への説明表示へ遷移してよい。

表示ルール（固定）：
- UI はラベルを“確定”しない。業務ロジックが確定したラベルを表示するのみ。
- 未確定（判定不能）の場合はラベルを出さない。曖昧さは REVIEW 申請導線へ誘導する。

導線（固定）：
- ALERT_REQUEST_PENDING_* がある場合は、申請一覧（Request）への導線を表示してよい。
- ALERT_PHOTO_INSUFFICIENT がある場合は、写真セクション（before/after）への導線を表示してよい。
- ADDRESS_VARIANCE / TIME_ANOMALY / TEXT_ANOMALY / PARTS_INCONSISTENCY がある場合は、
  “違和感素材” セクション（signals一覧）への導線を表示してよい。

## REQUEST_LIST_FLOW（表示／導線のみ）

本節は「未処理申請（RequestStatus=OPEN）」の一覧へ導く導線を定義する。
業務上の意味・判定・状態遷移は master_spec が唯一の正であり、本 ui_spec は再定義しない。

参照（唯一の正）：
- platform/MEP/03_BUSINESS/よりそい堂/master_spec
  - 3.7 Request（申請台帳）
  - 3.7.3 RequestStatus（OPEN/RESOLVED/CANCELLED）
  - 3.7.4 ResolutionMetadata（ResolvedAt等）
  - 8.4.1 管理警告ラベル（ALERT_REQUEST_PENDING_*）
  - 9.4 健康スコア（D: RequestStatus=OPEN）

表示・導線（固定）：
1) 管理タスク（監督UI）
- ALERT_REQUEST_PENDING_FIX / ALERT_REQUEST_PENDING_REVIEW が存在する場合、
  「未処理申請（OPEN）」一覧へのリンク（またはボタン）を表示してよい。
- 一覧は “RequestStatus=OPEN のみ” を表示対象とする（未処理の定義は master_spec に従属）。

2) OV01（閲覧カルテ）
- 健康スコア付近、または警告ラベル付近に「未処理申請（OPEN）」への導線を表示してよい。
- クリックで “未処理申請一覧（OPEN）” へ遷移し、該当 Order_ID でフィルタしてよい（表示のみ）。

UIの禁止事項（固定）：
- UI は RequestStatus を確定しない（OPEN/RESOLVED/CANCELLED の判断は業務ロジック）。
- UI は “勝手に解決扱い（RESOLVED/CANCELLED）” にしない。
- 未確定（判定不能）の場合は、一覧導線を出して “監督判断” に寄せる。

<!-- PHASE1_MARKERS (do not change meaning; for Go/No-Go checks only) -->
<!-- PARTS_FLOW_PHASE1 -->
<!-- EXPENSE_FLOW_PHASE1 -->
>>>>>>> origin/main

