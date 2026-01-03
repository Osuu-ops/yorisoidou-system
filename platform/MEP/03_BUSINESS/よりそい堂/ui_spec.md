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

## ESTIMATE_FLOW（見積の導線）

### 目的
- 見積作成（入力）→プレビュー→確定 の導線を固定する。
- 意味（必須/任意・ルール）は BUSINESS_SPEC/BUSINESS_MASTER に従う。

### 画面
- SCREEN_ESTIMATE_CREATE（見積作成）
- SCREEN_ESTIMATE_PREVIEW（見積プレビュー）

### 入力→プレビュー遷移（VALIDATION）
1) SCREEN_ESTIMATE_CREATE で「プレビューへ」
2) その時点で最低限チェック：
   - docName（必須）
   - docDesc（必須）
3) docPrice は priceStatus=TBD の場合は未設定でも可
   - priceStatus=FINAL の場合は docPrice を必須にしてよい
4) splitPolicy=MANUAL の場合は scopeCategory を必須にしてよい

### プレビュー画面（表示規約）
- priceStatus=TBD の場合：
  - 「価格未確定」を明記して表示（docPriceが空でもOK）
- 分割が必要な場合（設備＋内装混在など）は、プレビュー上で
  - 「見積A（設備）」「見積B（内装）」のように2件表示できる（BUSINESS_SPECの分割ルールに従う）

### 確定（CONFIRM）
- SCREEN_ESTIMATE_PREVIEW で「確定」
- 確定時の最小要件：
  - docName/docDesc が揃っている
  - priceStatus=FINAL の場合は docPrice が設定されている
- 確定後は「見積DOCが生成された」状態として次工程へ（将来：INVOICE連携）

## INVOICE_FLOW（請求の導線）

### 目的
- 請求作成（入力）→プレビュー→発行（ISSUED）→入金済み（PAID）までの導線を固定する。
- 意味（必須/任意・ルール）は BUSINESS_SPEC/BUSINESS_MASTER に従う。

### 画面
- SCREEN_INVOICE_CREATE（請求作成）
- SCREEN_INVOICE_PREVIEW（請求プレビュー）

### 入力→プレビュー遷移（VALIDATION）
1) SCREEN_INVOICE_CREATE で「プレビューへ」
2) 最低限チェック（推奨）：
   - docName（宛名）
   - docDesc（請求内容）
   - docPrice（原則必須：未確定運用をする場合は invoiceStatus=DRAFT を許容）
3) dueDate / paymentMethod / bankAccount は未設定でも可（docMemoで補足してよい）

### プレビュー画面（表示規約）
- invoiceStatus=DRAFT の場合：
  - 「下書き」を明記して表示
- invoiceStatus=ISSUED の場合：
  - 支払期限があれば表示
  - 支払方法/振込先があれば表示

### 発行（ISSUED）
- SCREEN_INVOICE_PREVIEW で「発行」
- 発行時の最小要件：
  - docName/docDesc/docPrice が揃っている（原則）
- 発行後は invoiceStatus=ISSUED

### 入金済み（PAID）
- 画面上の操作（将来）または運用手順により invoiceStatus=PAID に更新できる

## RECEIPT_FLOW（領収の導線）

### 目的
- 領収作成（入力）→プレビュー→発行（ISSUED）までの導線を固定する。
- 意味（必須/任意・ルール）は BUSINESS_SPEC/BUSINESS_MASTER に従う。

### 画面
- SCREEN_RECEIPT_CREATE（領収作成）
- SCREEN_RECEIPT_PREVIEW（領収プレビュー）

### 入力→プレビュー遷移（VALIDATION）
1) SCREEN_RECEIPT_CREATE で「プレビューへ」
2) 最低限チェック（推奨）：
   - docName（宛名）
   - docDesc（領収内容）
   - docPrice（金額）
3) receivedDate / paymentMethod は未設定でも可（docMemoで補足してよい）
4) receiptStatus=DRAFT の場合は「下書き」としてプレビュー可能

### プレビュー画面（表示規約）
- receiptStatus=DRAFT の場合：下書きを明記
- receiptStatus=ISSUED の場合：受領日/支払方法があれば表示

### 発行（ISSUED）
- SCREEN_RECEIPT_PREVIEW で「発行」
- 発行時の最小要件：
  - docName/docDesc/docPrice が揃っている（原則）
- 発行後は receiptStatus=ISSUED

<!-- ORDER_FLOW_PHASE1 -->

## ORDER_FLOW（受注の導線）

### 目的
- UF01（受注）入力 → 確認 → 受付完了 の導線を固定する。
- 意味（必須/任意・ルール）は master_spec に従う（特に raw 必須、orderStatus は UI で決めない）。

### 画面
- SCREEN_ORDER_CREATE（受注入力）
- SCREEN_ORDER_CONFIRM（受注確認）
- SCREEN_ORDER_DONE（受付完了）

### 入力→確認遷移（VALIDATION）
1) SCREEN_ORDER_CREATE で「確認へ」
2) 最低限チェック（必須）
   - raw（通知全文 / 1行メモ）
3) それ以外（name/phone/addressFull/preferred1/preferred2/price/備考等）は
   - 未入力を許容する（素材が無い受注を業務として拒否しない）

### 確認画面（表示規約）
- 未入力項目は「未入力」として表示し、責めない文言にする。
- addressCityTown 等の業務確定値が未確定な段階では、UI は推測で断定表示しない。
- orderStatus/STATUS は UI で決めない（表示のみ、または非表示でも可）。

### 受付完了（SUBMIT）
- SCREEN_ORDER_CONFIRM で「送信」
- 送信後は SCREEN_ORDER_DONE を表示し、以下を明示する：
  - 「受付しました」
  - 「内容を確認のうえ、後ほどご連絡します」
- 二重送信防止：送信中はボタン無効化・処理中表示を行う（UI_PROTOCOL に従う）。

<!-- WORK_FLOW_PHASE1 -->

## WORK_FLOW（施工完了報告の導線）

### 目的
- 現場の完了報告（コメント全文＋添付）を、迷いなく「送信→確認→完了」できる導線として固定する。
- “完了確定” は UI で決めない。完了報告は受付であり、確定・同期は業務ロジック（master_spec 9章）に従う。

### 画面
- SCREEN_WORK_REPORT（完了報告）
- SCREEN_WORK_CONFIRM（報告確認）
- SCREEN_WORK_DONE（報告完了）

### 入力→確認遷移（VALIDATION）
1) SCREEN_WORK_REPORT で「確認へ」
2) 最低限チェック（必須）
   - workDoneComment（完了コメント全文）
3) 添付（写真/動画）は任意
   - 不足は管理警告で扱うため、送信は止めない

### 確認画面（表示規約）
- workDoneComment は全文表示（省略しない）
- 添付は「添付あり/未添付」を明確に表示（責めない文言）
- 未使用部材の抽出結果など、業務ロジック側で確定される情報を UI は断定表示しない

### 送信（SUBMIT）
- SCREEN_WORK_CONFIRM で「送信」
- 送信中は二重送信防止（ボタン無効化・処理中表示。UI_PROTOCOL 準拠）
- 送信後は SCREEN_WORK_DONE を表示し、以下を明示する：
  - 「報告を受け付けました」
  - 「内容を確認のうえ、必要に応じてご連絡します」

### エラー/警告（最小）
- 必須不足（workDoneComment 空）のみエラー
- 添付不足は警告（任意）に留め、送信は止めない

<!-- PARTS_FLOW_PHASE1 -->

## PARTS_FLOW（部材：UF06/UF07 の導線）

### 目的
- UF06（発注/納品）と UF07（価格入力）を「入力→確認→完了」の導線として固定する。
- PRICE/STATUS/区分の確定は UI で行わない。業務ルールに従い、警告は管理側で回収する。

### UF06_ORDER_FLOW（発注）
- SCREEN_PARTS_ORDER_CREATE → SCREEN_PARTS_ORDER_CONFIRM → SCREEN_PARTS_ORDER_DONE
- 最低限チェック（推奨）：
  - partType（必須）
  - quantity（必須）
- Order_ID は未入力を許容（在庫発注＝STOCK_ORDERED）
- 送信中は二重送信防止（UI_PROTOCOL 準拠）

### UF06_DELIVER_FLOW（納品）
- SCREEN_PARTS_DELIVER_CREATE → SCREEN_PARTS_DELIVER_CONFIRM → SCREEN_PARTS_DELIVER_DONE
- 最低限チェック（必須）：
  - deliveredAt
- BP の PRICE 未入力は “警告” として扱い、送信は止めない（管理警告で回収）
- LOCATION は STOCK を扱う場合は必須化してよい（欠落は警告）

### UF07_PRICE_FLOW（価格入力）
- SCREEN_PARTS_PRICE_CREATE → SCREEN_PARTS_PRICE_CONFIRM → SCREEN_PARTS_PRICE_DONE
- 最低限チェック（必須）：
  - PART_ID
  - PRICE
- STATUS は変更しない（価格確定のみ）

<!-- EXPENSE_FLOW_PHASE1 -->

## EXPENSE_FLOW（経費の導線）

### 目的
- 経費入力 → 確認 → 完了 の導線を固定する。
- 金額は確定のみ（推測代入禁止）。

### 画面
- SCREEN_EXPENSE_CREATE
- SCREEN_EXPENSE_CONFIRM
- SCREEN_EXPENSE_DONE

### 入力→確認（VALIDATION）
- 必須：
  - Order_ID
  - PRICE
  - USED_DATE

### 完了（SUBMIT）
- 送信中は二重送信防止（UI_PROTOCOL 準拠）
- 完了画面で「記録しました」を明示
