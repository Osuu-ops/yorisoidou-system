# MEP_SSOT_MASTER（単一正本｜省略ゼロ｜コピペ1回）v1.12

（この1ファイルに、決定台帳（Q1〜Q169）と、運用入力器（IDEA_NOTE：Schema＋入力欄）を内包する）
（人間が触るのはこのファイル投入＝正本投入のみ。以後は機械が Bundled/health/handoff/spec/cards を生成・更新する）

---

## 0) SSOT運用ルール（このファイル内の優先・置換規則＝単一解化）

この正本では、**同一論点（テーマ）**に対して決定が複数並存し得る前提で、以下の規則により必ず単一解に収束させる。

* **RULE-0（優先順位｜単一解化）**：**同一論点に複数決定が並存する場合**、明示的な置換宣言（`Supersedes` / `Superseded by`）を持つ後発決定が勝つ。
* **RULE-1（置換の書き方｜機械可読）**：置換は必ず **`Supersedes: Qxx`** または **`Superseded by: Qyy`** を本文に明記する。
* **RULE-2（append-only整合）**：過去決定の本文は削除しない。矛盾は **置換宣言**で解消する。
* **RULE-3（正本の範囲｜省略ゼロの適用）**：

  * **PART A（決定台帳）**は **“省略ゼロ（完全本文）”**。ここに無い決定は採用済みではない。
  * **PART B（運用入力器）**は **Schema＋入力欄**であり、**空欄（未記入）は欠落ではない**（機械がAUTO補完し、不可欠時のみSTOP）。
* **RULE-4（派生物と抽出物｜正の一意化）**：派生物（READABLE_SPEC/HANDOFF/health/ROADMAP_CARDS/重要出力）は **すべて本ファイルから生成される生成物**であり、正本は本ファイルのみ。

  * `docs/MEP/DECISION_LEDGER.md`（EXTRACT_LEDGER）および `docs/MEP/INPUT_PACKET.md`（EXTRACT_INPUT）は、**本ファイルから自動生成される抽出物（派生物）**であり、正本は本ファイルのみ。
* **RULE-5（派生物の署名｜昇格条件）**：派生物は先頭に `STATUS` 署名（`DRAFT | AUDITED_OK | ADOPTED`）を必ず付与し、`ADOPTED` は台帳採用済み＋監査欠落ゼロ時のみ許可（Q74/Q75）。

---

# PART A: DECISION_LEDGER（決定台帳｜SSOT-B）完全本文 v1.12（Q1〜Q169）

（ここが決定の唯一の正。PART Bは入力器であり決定ではない）

---

## Q1〜Q84（採用済み：原文そのまま）

### 基本（草案SSOT/ID/構造）

* **Q1**：A（草案SSOT＝GitHub Issue）

  * **Superseded by: Q70**
* **Q2**：B（Issue番号とは別にCS_IDを付与）
* **Q3**：B（CS_ID形式＝`CS-YYYYMMDD-HHMMSS-<short>`）
* **Q4**：A（必須スキーマは「全部必須」）＋AI拡張OK

  * ※その後、必須キーは**14（→DoD-2要件で実質15扱い）**に拡張して固定
* **Q5**：A（混在禁止：business/systemを必ず隔離）
* **Q6**：B（business正本フォルダは不変ID側＝`03_BUSINESS/CS/<CS_ID>/`）
* **Q7**：B（ビジネス表示名はファイル正本＝Manifestを作る）
* **Q8**：B（Manifest必須＝`cs_id, business_name, owner, description`）
* **Q9**：A（systemも正本はCS_ID。system_key必須化はしない）
* **Q10**：A（二段階WAITを採用）※「可視化が必須」という条件付きで採用
* **Q11**：A（WAIT可視化はActionsログのみ）
* **Q12**：A（STOP時はIssueに1回コメントで通知）
* **Q13**：A（状態ラベル体系は推奨で採用、必要なら増やす）
* **Q14**：A（ボツ＝`mep-canceled`ラベル＋Issue Close。証跡は残す）
* **Q15**：A（Issue本文のMETA形式＝YAML）
* **Q16**：A（Issue本文セクション固定＝META/YAML + DRAFT + DECISIONS）

### 許可範囲・自動修正・台帳

* **Q17**：A（ALLOWED_PATHSは草案ごとに明示：最小権限）
* **Q18**：B（ALLOWED_PATHSはファイル/パターン単位で厳格）
* **Q19**：C’（自動修正許可＝`scope_in_append_only`＋`ledger_append_only`、`format_fix`はOFF）
* **Q20**：B（台帳対象＝WORK_ITEMS＋IDEA_VAULT）
* **Q21**：B（IDEA_VAULTは採用候補のみ自動追記）
* **Q22**：B（採用候補フラグ＝`idea-candidate`ラベル）
* **Q23**：A（WORK_ITEMS追記は1行フォーマット固定）
* **Q24**：A（health出力はmain常設：`mep_health.json`＋`mep_health.md`）

  * **Superseded by: Q73**（path fix：置き場所はQ73に固定。ファイル名としての常設は維持）
* **Q25**：A（health項目は推奨7カテゴリを必須＋AIが増やす）

### handoff内製化（Bundled内製・ID復元）

* **Q26**：並走（DoD-2本線と同時に進めるが一本化で遅れないよう分離）
* **Q27**：A（handoff card内製化はDoD-2必須にしない＝準必須→後で昇格）

### 実行開始（queued）と許可（固定②）

* **Q28**：A（実行開始トリガ＝`mep-queued`）
* **Q29**：B（固定②＝実行固定の許可証跡はラベル：`mep-approved-queue`）
* **Q30**：A（固定①＝スナップショットは許可不要＝draft更新は自由）

### Bundled側の追跡（INDEX/STATE/TOP_GOAL）

* **Q31**：A（Bundledに `CARD: BUNDLE_INDEX` を設置）
* **Q32**：B（`STATE_<CS_ID>` を追記で残し、INDEXが最新を指す）
* **Q33**：A（STOP_REASON_CODEは最小5コードで開始＋拡張可）※AI最善化
* **Q34**：A（STATEカード項目セットは推奨を必須＋AIが増やす）
* **Q35**：A（Bundledに `CARD: TOP_GOAL` を置き、INDEXから参照）

### 放置・忘却（時間判定をトリガにしない）

* **Q36**：A（放置検知をhealthに入れる）
* **Q37**：A（TOP_GOALに `active/parked/done` を導入し、意図された放置と忘却を区別）
* **Q38**：A（parked再確認トリガ＝`next_bundle`）
* **Q39**：A（reviewはやかましくしない：`review_due`で一覧表示のみ）
* **Q40（Retired）**：（Reserved / intentionally blank; kept for numbering integrity）
* **Q41（Retired）**：（Reserved / intentionally blank; kept for numbering integrity）

### 依存/分岐（main/branch、BLOCKED_BY）

* **Q42**：A（`BLOCKED_BY`を導入）
* **Q43**：A（`BLOCKED_BY`は配列形式で固定）
* **Q44**：A（`ROLE: main|branch` を必須）

### 忘却判定・表示（時間判定をトリガにしない）

* **Q45**：A（忘却判定は時間ゼロ：時間を判定トリガに使わない）
* **Q46**：A（忘却トリガ＝状態矛盾のみ）
* **Q47**：A（時系列は表示する：`updated_at`等。ただし判定には使わない）
* **Q48**：A（FORGOTTEN_FLAGは状態矛盾があるときだけtrue）
* **Q49**：A（health一覧は古い順＝`updated_at`昇順）※表示のみ
* **Q50**：B（FORGOTTEN_FLAGが立ったらIssueに1回だけ確認コメント）

### 依存/分岐（BLOCK_REASON_CODE）

* **Q51**：A（`BLOCK_REASON_CODE`は最小5コードで開始＋拡張可）※AIが追加

### Bundled側の追跡（INDEX/STATE/TOP_GOAL）つづき

* **Q52**：A（STATEカード更新責任＝GitHub Actions）
* **Q53**：A（BUNDLE_INDEX更新責任＝GitHub Actions）
* **Q54**：A（TOP_GOAL更新責任＝人間＋AI壁打ち。人間が採用したもののみ反映）
* **Q55**：B（ACTIVE/BACKLOGはTOP_GOALに直書きせず、`CARD: ACTIVE_BACKLOG` を別カード化）
* **Q56**：A（ACTIVE/BACKLOG更新責任＝人間＋AI壁打ち）
* **Q57**：A（ACTIVE/BACKLOGカードの中身＝CS_IDのみ）
* ※（補足確定）「カードは軽く」「問いかけ/一覧は分かりやすく（CS_ID＋タイトル）」で統一

### health生成の正本と不整合処理

* **Q58**：A（healthは各runごとに更新）
* **Q59**：A（STOP発生時にも必ずhealth更新）
* **Q60**：A（healthの正本は突合：Issue＋Bundled＋Actions）
* **Q61**：A（不整合はhealth-alertとして一覧化＋該当Issueへ1回コメント）

### 実行開始（queued）と許可（固定②）つづき

* **Q62**：A（実行開始条件＝`mep-queued`＋`mep-approved-queue`＋Preflight PASS）

### 実行中ロック・停止要求・STOP記録

* **Q63**：A（`mep-running`中はIssue本文編集禁止、停止要求のみ）

* **Q64**：A（停止要求は次の安全ポイントで停止）

* **Q65**：A（停止時STATE必須項目4つ＋AIが増やす）

* **Q66**：A（STOP後の訂正＝同一Issue更新→再実行）

* **Q67**：A（再実行時は全再確認＝新規同等）

* **Q68**：A（YAMLに `REV` を持つ改訂番号を採用）

* **Q69（Adopted）**：SSOT-B（決定台帳）の配置を `docs/MEP/DECISION_LEDGER.md` に固定する。

* **Q70（Adopted）**：SSOT-A（入力正本：草案パケット拡張＝正本入力）を **Issueではなく repo内ファイル** `docs/MEP/INPUT_PACKET.md` に固定する。

  * **Supersedes: Q1**（SSOT-A正はINPUT_PACKET抽出物。Issueは突合対象に降格）

* **Q71（Adopted）**：Readable Spec（派生物）の配置を `docs/MEP/READABLE_SPEC.md` に固定する。

* **Q72（Adopted）**：Handoff（派生物）の配置を `docs/MEP/HANDOFF.md` に固定する。

* **Q73（Adopted）**：health（派生物）は `docs/MEP_STATUS/mep_health.json` と `docs/MEP_STATUS/mep_health.md` を正とする。

* **Q74（Adopted）**：派生物（READABLE_SPEC/HANDOFF/重要出力）は先頭に必ず `STATUS` 署名を付与（`DRAFT | AUDITED_OK | ADOPTED`）。

* **Q75（Adopted）**：`STATUS: ADOPTED` は「台帳採用済み＋監査欠落ゼロ＋署名付与」全成立時のみ許可。ADOPTED以外は正扱い禁止。

* **Q76（Adopted）**：Coverage Map未実装の間は Readable Spec を採用済み決定を落とさず全文展開。短いReadable Spec は欠落疑いとしてSTOP（採用不可）。

* **Q77（Adopted）**：Coverage Map実装後のみ missing=[] 証明がある短縮版をADOPTED可へ移行。移行は台帳採用が必須。

* **Q78（Adopted）**：MEPは `DECISION_LEDGER → INPUT_PACKET` を自動生成/正規化して入口を構成する。

* **Q79（Adopted）**：Preflight監査は必須で `missing[]/conflicts[]/provenance_violations[]` を必ず列挙。非空ならSTOP。

* **Q80（Adopted）**：STOP時は必ず `questions[]` を機械生成し INPUT_PACKETへ書戻す。

* **Q81（Adopted）**：自動補完は単一解のみ。複数解はタイブレーク規則不足としてSTOP維持。

* **Q82（Adopted）**：GO時のみ採用分を台帳へ追記（append-only）。

* **Q83（Adopted）**：GO後に READABLE_SPEC / HANDOFF / health を必ず再生成。

* **Q84（Adopted）**：複数正当解が残る論点は台帳にタイブレーク規則として採用追記し、次回以降単一解化する。

---

## Q85〜Q97（採用済み：Gate-0〜Gate-12）【省略ゼロ・Q番号ごと】

* **Q85（Adopted）**：Gate-0（Integrity）を必須とする。

  * 目的：SSOT入力／抽出物／参照先の整合（欠落・破損・形式違反）を検出する。
  * STOP条件：整合違反が1つでもある場合。
* **Q86（Adopted）**：Gate-1（Input）を必須とする。

  * 目的：INPUT_PACKET（抽出入力）の構造・最低限の入力要素を検証する。
  * STOP条件：必須入力の欠落がありAUTO補完で単一解に収束しない場合。
* **Q87（Adopted）**：Gate-2（Coverage）を必須とする。

  * 目的：主要論点の列挙（COVERAGE）と、欠落論点の検出を行う。
  * STOP条件：COVERAGEが空/極小、または欠落が重大で単一解補完不能の場合。
* **Q88（Adopted）**：Gate-3（Provenance）を必須とする。

  * 目的：正本（本ファイル）起点で生成されること、参照が正当であることを検証する。
  * STOP条件：provenance_violations が非空の場合。
* **Q89（Adopted）**：Gate-4（Completeness）を必須とする。

  * 目的：採用済み決定（PART A）の欠落ゼロ前提で、派生物生成に必要な要素が揃うか判定する。
  * STOP条件：missing[] が非空で単一解補完不能の場合。
* **Q90（Adopted）**：Gate-5（Consistency）を必須とする。

  * 目的：矛盾（conflicts[]）の検出と、単一解化（置換規則・タイブレーク）の適用を行う。
  * STOP条件：conflicts[] が非空で単一解化できない場合。
* **Q91（Adopted）**：Gate-6（Question）を必須とする。

  * 目的：STOP時に必要な questions[] を機械生成し、INPUT_PACKETへ書戻す。
  * STOP条件：questions[] の生成・書戻しに失敗した場合（Machine-Only STOP）。
* **Q92（Adopted）**：Gate-7（Auto-Answer）を必須とする。

  * 目的：AUTO補完可能な欠落を単一解で埋め、decision_mode=AUTOとしてマーキングする。
  * STOP条件：複数解が残る場合（タイブレーク規則不足としてSTOP維持）。
* **Q93（Adopted）**：Gate-8（Tie-break）を必須とする。

  * 目的：複数正当解が残る論点を単一解化し、必要なら規則を台帳へ追記する。
  * STOP条件：単一解化不能、または追記ができず復旧も不能な場合。
* **Q94（Adopted）**：Gate-9（Commit）を必須とする。

  * 目的：生成・更新結果をコミット可能な単位に確定し、差分が許可範囲内であることを確認する。
  * STOP条件：allowed_paths逸脱、または不可逆・高コストで安全確証がない場合。
* **Q95（Adopted）**：Gate-10（FullExpand）を必須とする。

  * 目的：Coverage Map未実装期間は Readable Spec を全文展開し欠落疑いを排除する。
  * STOP条件：短縮版になっている／欠落疑いが解消できない場合。
* **Q96（Adopted）**：Gate-11（Handoff）を必須とする。

  * 目的：Handoff生成（派生物）を実行し、STATUS署名を付与する。
  * STOP条件：生成失敗、または署名規約違反がある場合。
* **Q97（Adopted）**：Gate-12（Health）を必須とする。

  * 目的：health生成・更新を必ず行い、STOP時でも更新する。
  * STOP条件：health更新に失敗した場合（Machine-Only STOP）。

---

## Q98〜Q105（採用済み：Readability＝人の選択が読める必須）

* **Q98（Adopted）**：SSOT-Aは「機械監査」だけでなく「人の意図・選択が読み取れる」ことを必須要件とする。
* **Q99（Adopted）**：DECISIONS必須：decision / choice_set / rationale / tradeoffs / evidence（強断定時必須）。
* **Q100（Adopted）**：OBS必須：observation / why_important / open_question。
* **Q101（Adopted）**：COVERAGE必須：主要論点列挙。空/極小はSTOP。
* **Q102（Adopted）**：Readability Gate必須。欠ければSTOP。
* **Q103（Adopted）**：Readability STOP時は質問自動生成→INPUT_PACKETへ書戻す。
* **Q104（Adopted）**：Readability不足は独立STOP理由としてhealthに一覧化。
* **Q105（Adopted）**：Gate順序にReadabilityを組込み、最低順序を固定する。

---

## Q106〜Q113（採用済み：STOP最小化＝AUTO優先＋任意確認＋不可欠時のみSTOP）

* **Q106（Adopted）**：STOPは例外。原則はAUTOで前進。補完可能ならSTOPせず補完して継続。
* **Q107（Adopted）**：AUTO決定は必ずマーキング（decision_mode:AUTO、tiebreak_rule、confidence任意、why_auto任意）。
* **Q108（Adopted）**：任意確認・任意修正は SSOT再投入のみ（人間操作は正本投入だけ）。
* **Q109（Adopted）**：STOP境界は2系統のみ：

  1. 境界不明・汚染リスク（allowed_paths未確定、混在疑いが解消不能）
  2. 不可逆・高コスト（戻れない変更、権限/ルールセット欠如で事故時に戻れない）
* **Q110（Adopted）**：AUTOで進めてよい領域（STOPしない）：表現弱め、テンプレ補完、タイブレーク分岐、Machine-Only STOPは復旧カード起票、生成物はSTATUS=DRAFTで先行生成。
* **Q111（Adopted）**：先行生成OK（STATUS=DRAFT）。ADOPTED署名と台帳採用確定は監査欠落ゼロ後に限定。
* **Q112（Adopted）**：STOP時「ここはどうですか？」は禁止。SSOTから復元した選択肢・根拠・影響範囲を添えて提示。
* **Q113（Adopted）**：STOP継続が機械側原因（未実装/権限不足等）の場合、必ず復旧カード（RECOVERY）を自動起票しnext_priorityに積む。復旧カード生成/積載に失敗したらそれ自体を最優先RECOVERYとして扱う。

---

## Q114〜Q120（採用済み：残りの穴A〜Eを完全封鎖）

* **Q114（Adopted）**：複数解が出た場合、機械は必ず「暫定タイブレーク規則」を適用して単一化し、その規則をSSOT-Bへ自動追記する。追記できない場合は Machine-Only STOP とし、環境復旧RECOVERYを自動起票する（Q113準拠）。
* **Q115（Adopted）**：ROADMAP_POINTERS（最新参照）が解決不能、またはSTATEの最新が一意に決まらない場合は Machine-Only STOP とする。その際、必ず「参照修復RECOVERYカード」を自動起票し next_priority に積む（人間に質問しない）。
* **Q116（Adopted）**：attach_mode=DETACH の枝は detach_ref を必須とし、解決不能は Machine-Only STOP。必ず「参照復旧RECOVERYカード」を自動起票し next_priority に積む。
* **Q117（Adopted）**：実行環境不足による停止（権限不足、workflow不存在、書戻し不可、ルールセット不整備）は Machine-Only STOP とし、必ず「環境復旧RECOVERYカード」を自動起票して next_priority に積む。人間への質問は禁止。
* **Q118（Adopted）**：AUTO決定の累積は health に必ず出力する（auto_decision_count/auto_decision_latest/auto_decision_locations）。AUTO決定箇所はカードと入力正本に必ずマーキングされ、探索可能でなければならない。
* **Q119（Adopted）**：RECOVERYカード生成失敗、Bundled反映失敗、next_priority積載失敗は、それ自体を最優先RECOVERYとして自動起票し、復旧カードの復旧を行う（無限停止を回避）。
* **Q120（Adopted）**：新チャット開始時に Bundled照合で owner_chat を固定する際、既に別owner_chatが確定している対象に上書きが必要な場合は Machine-Only STOP とし、必ず「担当衝突解消RECOVERYカード」を起票して next_priority に積む。人間の記憶に依存せず、証跡（Bundled/handOff/health）から機械が解決方針を提示する。

## Q121〜Q128（Adopted）：SSOT_SCAN（草案スキャン監査）必須化

* **Q121（Adopted）**：SSOT（本ファイル投入後）は、いかなる生成/実装/更新より先に **SSOT_SCAN（静的監査）**を必ず実行する。

  * 位置づけ：Gate Full Set の最前段（Pre-Gate / Gate-(-1)）
* **Q122（Adopted）**：SSOT_SCANの検査対象（最低限）は以下：

  1. **Q整合**：Q番号の重複/欠落/順序不整合（例：Q24/Q25誤写、同一Qの二重本文など）
  2. **置換整合**：`Supersedes/Superseded by` の参照先が存在するか／循環参照がないか
  3. **宣言整合**：RULE-3（PART A省略ゼロ／PART B Schema空可）が本文と矛盾していないか
  4. **抽出物整合**：RULE-4 に基づき、EXTRACT_LEDGER/EXTRACT_INPUT の扱いが一意か
  5. **人の選択が読める**：Readability必須フィールド（choice_set等）のスキーマが存在するか（未記入は許容）
* **Q123（Adopted）**：SSOT_SCANの判定は `GO | STOP` の2値とする。

  * `GO`：矛盾ゼロ（機械が単一解に収束可能）
  * `STOP`：矛盾/破損があり、以後のGateに進めない
* **Q124（Adopted）**：SSOT_SCANがSTOPの場合、機械は必ず **自動修正案（PATCH）**を生成し、次を出力する：

  * `STOP_REPORT`（検知項目一覧）
  * `PATCH`（適用すべき差分）
  * `confidence`（自動修正の確度）
* **Q125（Adopted）**：SSOT_SCANの自動修正は **単一解のみ**許可（Q106〜Q113と整合）。
  例：誤写（Q24/Q25入れ替え）・参照先誤り・体裁の正規化など。
* **Q126（Adopted）**：SSOT_SCANがSTOPで、かつ自動修正が単一解に収束しない場合は **Machine-Only STOP**として扱い、必ず **RECOVERYカードを自動起票**し next_priority に積む（Q113/Q119と整合）。
* **Q127（Adopted）**：SSOT_SCANの結果（GO/STOP、修正適用の有無、検知件数）は必ず health に記録する（Q24/Q60/Q61と整合）。
  推奨キー：`ssot_scan_status`, `ssot_scan_findings_count`, `ssot_scan_autofix_applied`
* **Q128（Adopted）**：新チャット開始時（バンドル照合・owner_chat固定のタイミング）にも SSOT_SCAN を必ず実行する。

  * 目的：新チャット時の“正本の取り違え/崩れ”を入口で潰す。

---

## Q129〜Q136（Adopted）：CONFLICT_SCAN（生成前競合・衝突検知）必須化

* **Q129（Adopted）**：任意の **生成（system/business成果物生成、READABLE_SPEC生成、Bundled更新）**および **実装（PR/merge）**の前に、必ず CONFLICT_SCAN を実行する。

  * 位置づけ：SSOT_SCAN（Q121〜）の後、Preflightの前（Pre-Gate）
* **Q130（Adopted）**：CONFLICT_SCANは「現在採用されている内容（SSOT-B/EXTRACT_LEDGER/現main）」との 競合・衝突を事前検知する。対象は最低限：

  * パス衝突：allowed_paths外への変更／business領域へのsystem干渉（Q5/Q17/Q18）
  * 正本衝突：business正本配置（03_BUSINESS/CS/<CS_ID>/）とManifest必須（Q6〜Q8）との矛盾
  * 状態衝突：Bundled/STATE/INDEXが示す現在地と、生成が前提にする現在地の不一致（Q31〜Q35/Q52/Q53）
  * 決定衝突：採用済みQ（SSOT-B）に反する生成・実装（Provenance/Readabilityと整合）
* **Q131（Adopted）**：CONFLICT_SCANの出力は必須：

  * `conflicts[]`（type / target / current / proposed / risk）
  * `resolution_mode`（AUTO_FIX可能 or RECOVERY必要）
* **Q132（Adopted）**：競合が1つでも検知された場合の原則：

  * 単一解で安全に直せるもののみ AUTO_FIX を許可（Q106〜Q113に整合）
  * それ以外は Machine-Only STOP とし、必ず RECOVERYカードを自動起票して next_priority に積む（Q113/Q119に整合）
* **Q133（Adopted）**：AUTO_FIXで修正した場合、必ず 再CONFLICT_SCANを実行し、`conflicts=[]` を確認してから次ゲートへ進む。
* **Q134（Adopted）**：CONFLICT_SCANの結果（status/件数/auto_fix適用有無）は必ず health に記録する（Q24/Q60/Q61に整合）。
  推奨キー：`conflict_scan_status`, `conflict_scan_conflicts_count`, `conflict_scan_autofix_applied`
* **Q135（Adopted）**：CONFLICT_SCANで修正不能（複数解・危険境界・不可逆）と判断された場合、人間への質問は禁止。
  必ず RECOVERYカードとして「修正案・差分・rollback・acceptance_tests」を提示し、機械の復旧ループに載せる。
* **Q136（Adopted）**：Gate順序の最低要件を更新する：
  `SSOT_SCAN → CONFLICT_SCAN →（既存）Preflight → … → 生成/実装`

---

## Q137〜Q140（Adopted）：PARSER_SAFETY（旧）【保持のみ／参照用】

（注記：このブロックは append-only のため保持するが、**最新有効ではない**。**Superseded by: Q141**）

* **Q137（Adopted）**：決定台帳（PART A）の各Q本文は、必ず「Q行ヘッダ1行」から開始しなければならない（機械パースの唯一の正規形）。

  * 正規形（1行固定）：`- **Q<半角数字>（任意でAdopted等）**：<本文>`
  * 制約：`- `で開始／Q番号は半角数字のみ／全角コロン`：`のみ／1行1Q（複数Q禁止）
* **Q138（Adopted）**：PART A のQ番号範囲見出しは任意だが、見出しは本文として解釈しない。本文境界はQ137のQ行ヘッダのみで決定する。
* **Q139（Adopted）**：SSOT_SCANの検査対象にQ行Lint（Q137正規形違反の検知）とQ境界Lint（誤検出誘発の混入検知）を必須追加する。
* **Q140（Adopted）**：SSOT_SCANがQ行Lint違反を検知した場合、単一解で機械変換できる違反はAUTO_FIX許可、複数解が生じる違反はMachine-Only STOP＋RECOVERY起票、適用後は再SSOT_SCAN必須。

---

## Q141〜Q145（Adopted）：PARSER_SAFETY v2（正規形の適用先＝抽出物固定）【追記・最新有効】

* **Q141（Adopted）**：PARSER_SAFETY（Q137〜Q140）の正規形強制の適用先を更新する。

  * **Supersedes: Q137, Q138, Q139, Q140**
  * 正規形（厳格パース）を **MEP_SSOT_MASTER（本ファイル）に直接要求しない**。
  * 正規形の強制は、機械が実行に用いる **抽出物（EXTRACT_LEDGER / EXTRACT_INPUT）** に対してのみ必須とする。
* **Q142（Adopted）**：正規形強制の対象（抽出物）を固定する。

  * `docs/MEP/DECISION_LEDGER.md`（EXTRACT_LEDGER）
  * `docs/MEP/INPUT_PACKET.md`（EXTRACT_INPUT）
* **Q143（Adopted）**：抽出物におけるQ行ヘッダ正規形（唯一の正規形）を固定する。

  * 正規形（1行固定）：`- **Q<半角数字>（任意でAdopted等）**：<本文>`
  * 制約：行頭`- `／Q番号半角数字のみ／全角コロン`：`のみ／1行1Q
  * 本文（補足・箇条書き）は次行以降に続けてよい。
* **Q144（Adopted）**：SSOT_SCANは「抽出物生成時」に次を必須検査する（Q122へ追加扱い）。

  * 抽出物がQ143正規形に100%準拠（Q行Lint）
  * Q番号の重複／欠落／順序不整合（Q整合）
  * Supersedes/Superseded by参照先存在／循環参照（置換整合）
  * RULE-3/RULE-4に反する宣言矛盾（宣言整合）
  * 結果はhealthに必ず記録（`ssot_parse_canonical_ok`等の任意キー可）
* **Q145（Adopted）**：SSOT_SCANは「抽出物の正規化」を常に許可された単一解AUTO_FIXとして実行してよい。

  * 許可：`:`→`：`／全角数字→半角数字／行頭`- `付与／太字付与／Adopted表記位置の正規化（抽出物のみ）
  * 禁止：1行に複数Q混在で分割が必要（複数解になり得る）→Machine-Only STOP＋RECOVERY起票
  * 正規化後は再SSOT_SCAN必須（GO確認後に次ゲート）

## Q146〜Q156（Adopted）：外周PR正・復元性・停止/進捗・固定参照の完璧化（v1）

* **Q146（Adopted）**：STOPは2軸で表現し、常にセットで出力する（混線防止）。

  * `stop_class`（誰が解くか）：`HUMAN_RESOLVABLE | MACHINE_ONLY`
  * `stop_kind`（性質）：`WAIT | HARD`
  * 出力契約：STOP時は必ず `STATE/REASON/NEXT` を1行で出す。片方欠落は「出力欠落」としてSTOP扱い（Machine-Only STOP可）。
  * Relates to: Q65, Q109, Q91, Q97

* **Q147（Adopted）**：進捗定義を2段階（STRONG/WEAK）に固定し、NO_PROGRESSはSTRONG不在でカウントする。

  * `PROGRESS_STRONG`：HEAD または PARENT_BUNDLE_VERSION が変化（BUNDLE_VERSIONは別名として扱う）
  * `PROGRESS_WEAK`：EVIDENCE最終行 または PR証跡状態が変化
  * NO_PROGRESSは `PROGRESS_STRONG` が無い周回を基準にカウントする（ただし stop_kind=WAIT の周回は NO_PROGRESS のカウント対象外）。
  * Relates to: Q33, Q58, Q59

* **Q148（Adopted）**：writeback固定参照（SSOT_WORKFLOW_ID固定）を唯一の正にする（探索禁止の入口）。

  * `SSOT_WORKFLOW_ID = 228815143`
  * 監査情報として `SSOT_WORKFLOW_PATH = .github/workflows/mep_writeback_bundle_dispatch_entry.yml` を併記する。
  * これ以外のworkflow参照は探索禁止違反として、`stop_kind=HARD` かつ `stop_class=HUMAN_RESOLVABLE` を出力する。
  * Relates to: Q85, Q88, Q79

* **Q149（Adopted）**：固定workflow参照の実在（active）をゲートで必須検査する。

  * Gate-0（Integrity）またはSSOT_SCANで、`SSOT_WORKFLOW_ID` がGitHub上で存在し `state=active` であることを検査する。
  * 不在／inactiveは `stop_kind=HARD` かつ `stop_class=MACHINE_ONLY` → 環境復旧RECOVERY起票。
  * Relates to: Q85, Q121, Q117

* **Q150（Adopted）**：writeback成功＝複合DoD（run successだけでは成功扱いしない）を固定する。

  * 成功条件は以下を「全て満たすまで未完」とする：

    * WIP-021 run completed/success
    * WIP-022 PR単一確定
    * WIP-023 mergeable==MERGEABLE
    * WIP-024 main pull
    * WIP-025 Bundled証跡行
    * WIP-026 EVIDENCE証跡行
  * 1つでも欠ければ未完（exit=2相当）。
  * Relates to: Q83, Q94, Q97

* **Q151（Adopted）**：外周PR方式を“物理的に”成立させるため、PR外周監査（No checks穴封鎖）を必須化する。

  * `CHECKS_PRESENT=true` であること（falseの場合は `stop_kind=HARD` かつ `stop_class=HUMAN_RESOLVABLE` を出力する）
  * `REQUIRED_CHECKS_MATCHED=true` であること（不一致の場合は `stop_kind=HARD` かつ `stop_class=HUMAN_RESOLVABLE` を出力する）
  * `TRIGGER_ACTOR_OK=true` であること（NGの場合は `stop_kind=HARD` かつ `stop_class=HUMAN_RESOLVABLE` を出力する）
  * Relates to: Q94, Q79, Q88, Q97

* **Q152（Adopted）**：`REQUIRED_CHECKS_SSOT` の正の置き場所と比較規則を固定する。

  * 正の置き場所：SSOT（本ファイル）→抽出物（EXTRACT_INPUT）に正規化して格納される `required_checks_expected[]` を正とする。
  * 比較規則：完全一致（名前は1文字も違えば不一致）。不一致の場合は `stop_kind=HARD` かつ `stop_class=HUMAN_RESOLVABLE` を出力する。
  * もし `required_checks_expected[]` が空の場合：

    * 単一ルールセットから一意に取得できる場合のみAUTO補完して書戻し可
    * 一意でない場合は `stop_kind=HARD` かつ `stop_class=MACHINE_ONLY` → 参照復旧RECOVERY起票
  * Relates to: Q79, Q85, Q90

* **Q153（Adopted）**：`TRIGGER_ACTOR_OK` の判定方法を固定する（実装割れ防止）。

  * 正の置き場所：SSOT（本ファイル）→抽出物（EXTRACT_INPUT）に `pr_creator_allowlist[]`（actor_login + actor_type）を正規化して格納する。
  * 判定：PR作成主体が allowlist と一致しない場合は `stop_kind=HARD` かつ `stop_class=HUMAN_RESOLVABLE`。
  * allowlist が空の場合：

    * 単一の「直近成功PR」の作成主体を一次根拠で一意に特定できる場合のみAUTO補完して書戻し可
    * 一意でない場合は `stop_kind=HARD` かつ `stop_class=MACHINE_ONLY` → 環境/主体復旧RECOVERY起票
  * Relates to: Q79, Q88, Q117


  * pr_creator_allowlist[]（一次根拠でAUTO補完・固定）:
    * actor_login: Osuu-ops
      actor_type: Organization
      evidence_pr: #1950
      evidence_merge_commit: 091ca0f2bea764d59cc99473d1d27c50dd01e138
      evidence_merged_at: 2026-02-08T13:41:29+09:00
      updated_at: 2026-02-08T23:18:28+09:00

  * TRIGGER_ACTOR_OK（固定）:
    * if PR.author.login == 'Osuu-ops' then OK
    * else NG（stop_kind=HARD / stop_class=MACHINE_ONLY）

* **Q154（Adopted）**：`SSOT_VERSION` の定義を固定する（再開パケットのブレ防止）。

  * `SSOT_VERSION` は `PARENT_BUNDLE_VERSION` を正とする。
  * PARENT_BUNDLE_VERSIONが取得不能な場合のみ、代替として `HEAD(main)` を使用し、代替使用をhealthに記録する。
  * Relates to: Q58, Q59

* **Q155（Adopted）**：`pr_number=0` の意味（解決規則）をSSOTで固定する。

  * 要件：`pr_number=0` は「AUTO-RESOLVEモード」を意味し、workflow/実装は“対象PRの一意解決規則”を持たなければならない。
  * 解決不能（複数解/不明）の場合は探索禁止として `stop_kind=HARD` かつ `stop_class=HUMAN_RESOLVABLE` を出力する。
  * Relates to: Q81, Q84, Q90

* **Q156（Adopted）**：RUNごとの再開パケットと人間用要約（現在地＋前後＋残り工程）を必須出力として固定する。

  * 再開パケット（必須）：`SSOT_VERSION / HEAD / PARENT_BUNDLE_VERSION / LAST_STOP=STATE/REASON/NEXT`（BUNDLE_VERSIONは別名として扱う）
  * 人間用要約（必須）：`NOW / CONTEXT（前後） / REMAINING`
  * 生成タイミング：バンドル固定時、または人間が質問した時（質問＝吸い上げ）。
  * Relates to: Q72, Q97, Q58, Q59

* **Q157（Adopted）**：WORK_ID（WIP）辞書をSSOT内に固定し、実装の唯一参照とする。

  * WORK_ID辞書は **「ID→目的→判定条件→一次根拠キー→アクション→完了条件」** を持つ。
  * 実装参照の唯一の正は WORK_ID辞書であり、本文説明（会話・ログ本文）を根拠にしない。
  * WORK_ID辞書は append-only。削除・改名は禁止。
  * 最低固定集合（必須、削除・改名禁止）：

    * P001: WIP-001 / WIP-002 / WIP-003
    * P002: WIP-010
    * P003: WIP-020 / WIP-021 / WIP-022 / WIP-023 / WIP-024 / WIP-025 / WIP-026
    * P004: WIP-030

* **Q158（Adopted）**：WIP-021〜WIP-026（writeback複合DoD）の辞書本文を一次根拠で閉じる（省略ゼロ）。

  * WIP-021（P003）run completed/success

    * 目的：workflow run が完了し成功であることを一次根拠で証明する
    * 判定条件：`gh run view <RUN_ID> --json status,conclusion` が `status=completed` かつ `conclusion=success`
    * 一次根拠キー：`RUN.status` / `RUN.conclusion`
    * アクション：固定workflow（Q148/Q149）を起動し、RUN_IDを取得し監視する
    * 完了条件：判定条件が満たされた時点で DONE（根拠キーを保存）

  * WIP-022（P003）PR 単一確定

    * **Superseded by: Q162（WIP-022本文）**
    * 目的：対象PRが一意に確定していることを一次根拠で証明する（探索禁止）
    * 判定条件：`gh api repos/{owner}/{repo}/actions/runs/<RUN_ID>/pull_requests --jq 'length'` が `1`
    * 一次根拠キー：`RUN_PR_LIST.length` / `PR.number`
    * PR番号抽出：`gh api repos/{owner}/{repo}/actions/runs/<RUN_ID>/pull_requests --jq '.[0].number'`
    * アクション：RUN_IDを一次根拠として取得し、候補集合を取得して length==1 を確認し、PR.number を確定する（length!=1 は stop_kind=HARD）
    * 完了条件：判定条件が満たされ、かつ PR.number が確定した時点で DONE（根拠キーを保存）

  * WIP-023（P003）mergeable == MERGEABLE

    * 目的：PRが mergeable であることを一次根拠で証明する
    * 判定条件：`gh pr view <PR_NUMBER> --json mergeable` が `mergeable=MERGEABLE`
    * 一次根拠キー：`PR.mergeable`
    * アクション：PRを再取得し mergeable を検証する（取得不能は stop_kind/stop_class の契約に従う）
    * 完了条件：判定条件が満たされた時点で DONE（根拠キーを保存）

  * WIP-024（P003）main pull済み

    * 目的：ローカル main が origin/main と同期済みであることを一次根拠で証明する
    * 判定条件：`git pull --ff-only origin main` が成功し、かつ `git rev-parse HEAD` が `git rev-parse origin/main` と一致
    * 一次根拠キー：`HEAD_SHA` / `ORIGIN_MAIN_SHA`
    * アクション：ff-only pull を実行し一致を検証する
    * 完了条件：判定条件が満たされた時点で DONE（根拠キーを保存）

  * WIP-025（P003）Bundledに対象PR証跡行あり

    * **Superseded by: Q163（WIP-025本文）**
    * 証跡行正規形：`^<MERGE_COMMIT_SHA>\s+Merge pull request #<PR_NUMBER>\b`
    * PROOF_LINE_KEY：`"<MERGE_COMMIT_SHA>#<PR_NUMBER>"`
    * 判定条件：親Bundled `docs/MEP/MEP_BUNDLE.md` に正規形一致行が **1行以上** 存在
    * 一次根拠キー：`PARENT_BUNDLE_VERSION` / `BUNDLED_PROOF_LINE_REGEX` / `BUNDLED_PROOF_LINE_KEY`
    * アクション：main同期（WIP-024）後に該当行の存在を検証する（無ければ未完）
    * 完了条件：判定条件が満たされた時点で DONE（根拠キーを保存）

  * WIP-026（P003）EVIDENCEに対象PR証跡行あり

    * **Superseded by: Q163（WIP-026本文）**
    * 証跡行正規形：`^<MERGE_COMMIT_SHA>\s+Merge pull request #<PR_NUMBER>\b`
    * PROOF_LINE_KEY：`"<MERGE_COMMIT_SHA>#<PR_NUMBER>"`
    * 判定条件：EVIDENCE Bundled `docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md` に正規形一致行が **1行以上** 存在
    * 一次根拠キー：`EVIDENCE_BUNDLE_VERSION` / `EVIDENCE_PROOF_LINE_REGEX` / `EVIDENCE_PROOF_LINE_KEY`
    * アクション：main同期（WIP-024）後に該当行の存在を検証する（無ければ未完）
    * 完了条件：判定条件が満たされた時点で DONE（根拠キーを保存）

  * 成功契約（固定）

    * WIP-021〜WIP-026 は **全てDONE** になるまで未完扱い（run successのみでは成功扱い禁止）
    * どれか1つでも欠けた場合は未確定（exit=2相当）

* **Q159（Adopted）**：mep_entry を未完駆動オーケストレーターとして固定し、固定規則（停止優先度／進捗／exit契約）を省略ゼロで断言する。

  * 入口必須工程（分岐不可）

    * RUN_ID / GENERATED_AT / REPO_ROOT を確定
    * repo妥当 / clean / main ff-only pull
    * BEFORE snapshot
    * 失敗時：停止し、停止理由をレポートに確定保存

  * 未完駆動ディスパッチ（固定）

    * AUTO未完 → mep_auto
    * DISPATCH未完 → workflow_dispatch（固定参照：Q148/Q149）
    * RUN未完 → run監視（WIP-021の判定へ）
    * Bundled未更新 → main sync→再検証（WIP-024/025/026へ）
    * HANDOFF未更新 → mep_handoff（WIP-030へ）

  * 停止優先度（固定）

    * 実行不能（汚染／pull失敗） ＞ ERROR ＞ ALL_DONE ＞ NO_PROGRESS ＞ TIMEOUT

  * 進捗判定（固定）

    * PROGRESS_STRONG：HEAD または PARENT_BUNDLE_VERSION が変化
    * PROGRESS_WEAK：EVIDENCE最終行 または PR証跡状態 が変化
    * NO_PROGRESSカウントは PROGRESS_STRONG 不在を基準とする

  * exit契約（固定）

    * ALL_DONE：exit=0
    * 未確定（複合DoD未達・不足）：exit=2
    * ERROR/契約違反：exit=1
    * 停止は Q146 の2軸契約（stop_class/stop_kind）で表現し、レポート先頭1行で宣言する

* **Q160（Adopted）**：置き場をSSOTで固定する（条件分岐禁止）。

  * CURRENT_POSITION は `stop_class` と `stop_kind` の2軸を持ち、常にセットで更新される（片方欠落は禁止）
  * CURRENT_POSITION は `resume_packet` を持ち、RUNごとに必ず更新される
  * PR_OUTER_POLICY は B-6 に固定する（B-5衝突回避）

## Q161〜Q163（Adopted）：STOP語彙統一／WIP-022一次根拠固定／Bundled/EVIDENCE証跡行正規形固定（省略ゼロ）

* **Q161（Adopted）**：STOP表現は Q146 の2軸契約に統一し、STOP_WAIT / STOP_HARD 等の新語を導入しない（stop_kind / stop_class の2軸のみを使用する）。

  * STOPは必ず次の2軸で表現する：

    * `stop_class: HUMAN_RESOLVABLE | MACHINE_ONLY`
    * `stop_kind: WAIT | HARD`
  * 先頭1行の出力契約は次で固定する（STOP_* の派生語を使わない）：

    * `STATE=<RUNNING|STOP|ALL_DONE> REASON=<...> NEXT=<...>`
  * `STOP_WAIT` / `STOP_HARD` 等の語彙がどこかに混入した場合は無効とし、本Qの定義に正規化される。
  * **Supersedes: Q159（STOP表現・exit契約のSTOP語彙部分）**
  * Relates to: Q146, Q156

* **Q162（Adopted）**：WIP-022（PR単一確定）の一次根拠コマンドを固定し、「候補列挙→一意判定」を一次出力で閉じる。

  * **Superseded by: Q164**
  * WIP-022（P003）PR 単一確定（一次根拠固定・省略ゼロ）

    * 目的：対象PRが一意に確定していることを一次根拠で証明する（探索禁止）
    * 判定条件：`gh api repos/{owner}/{repo}/actions/runs/<RUN_ID>/pull_requests --jq 'length'` が `1`
    * 一次根拠キー：`RUN_PR_LIST.length` / `PR.number`
    * PR番号抽出：`gh api repos/{owner}/{repo}/actions/runs/<RUN_ID>/pull_requests --jq '.[0].number'`
    * アクション：RUN_IDを一次根拠として取得し、候補集合を取得して length==1 を確認し、PR.number を確定する（length!=1 は stop_kind=HARD かつ stop_class=HUMAN_RESOLVABLE）
    * 完了条件：判定条件が満たされ、かつ PR.number が確定した時点で DONE（根拠キーを保存）
  * **Supersedes: Q158（WIP-022本文）**
  * Relates to: Q155, Q150

* **Q163（Adopted）**：WIP-025/026（Bundled/EVIDENCE証跡行）の正規形とキー生成規則を固定し、存在判定を割れなくする。

  * WIP-025（P003）Bundledに対象PR証跡行あり（正規形固定・省略ゼロ）

    * 証跡行正規形：`^<MERGE_COMMIT_SHA>\s+Merge pull request #<PR_NUMBER>\b`
    * PROOF_LINE_KEY：`"<MERGE_COMMIT_SHA>#<PR_NUMBER>"`
    * 判定条件：親Bundled `docs/MEP/MEP_BUNDLE.md` に正規形一致行が **1行以上** 存在
    * 一次根拠キー：`PARENT_BUNDLE_VERSION` / `BUNDLED_PROOF_LINE_REGEX` / `BUNDLED_PROOF_LINE_KEY`
    * アクション：main同期（WIP-024）後に該当行の存在を検証する（無ければ未完）
    * 完了条件：判定条件が満たされた時点で DONE（根拠キーを保存）

  * WIP-026（P003）EVIDENCEに対象PR証跡行あり（正規形固定・省略ゼロ）

    * 証跡行正規形：`^<MERGE_COMMIT_SHA>\s+Merge pull request #<PR_NUMBER>\b`
    * PROOF_LINE_KEY：`"<MERGE_COMMIT_SHA>#<PR_NUMBER>"`
    * 判定条件：EVIDENCE Bundled `docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md` に正規形一致行が **1行以上** 存在
    * 一次根拠キー：`EVIDENCE_BUNDLE_VERSION` / `EVIDENCE_PROOF_LINE_REGEX` / `EVIDENCE_PROOF_LINE_KEY`
    * アクション：main同期（WIP-024）後に該当行の存在を検証する（無ければ未完）
    * 完了条件：判定条件が満たされた時点で DONE（根拠キーを保存）

  * **Supersedes: Q158（WIP-025/WIP-026本文）**

  * Relates to: Q150

## Q164〜Q168（Adopted）：WIP-022停止契約の2軸固定／STOP時exit固定／MERGE_COMMIT_SHA取得元固定（省略ゼロ）

* **Q164（Adopted）**：WIP-022（PR単一確定）の「length!=1」時の停止契約は、Q146の2軸（stop_class/stop_kind）で省略なく固定する。

  * 目的：WIP-022の不確定（候補集合が1でない）時に stop_class が割れないようにする。
  * 適用対象：Q162（およびQ158内のWIP-022）における `length!=1` の扱い。
  * 固定：

    * `length==1` の場合：従来どおり PR.number を確定してDONE
    * `length!=1` の場合：**必ず STOP とし、次を固定する**

      * `stop_kind = HARD`
      * `stop_class = HUMAN_RESOLVABLE`
      * 出力先頭1行は Q146 の形式で `STATE/REASON/NEXT` を出す（片軸欠落は禁止）
    * 理由（REASON）は `PR_NOT_UNIQUE` を正とし、NEXTは「一意化（tiebreak/入力修正）」を示す。
  * **Supersedes: Q162**
  * Relates to: Q146, Q155, Q162, Q150

* **Q165（Adopted）**：STOP時の exit を固定する（STOP_KINDに依存せず割れを禁止）。

  * 目的：STATE=STOP（WAIT/HARD）の exit が実装で割れないようにする。
  * 固定：

    * `STATE=ALL_DONE` → `exit=0`
    * `STATE=STOP`（stop_kind が WAIT/HARD いずれでも）→ **`exit=2`**
    * `STATE=ERROR`（契約違反・例外・パース不能等）→ `exit=1`
  * 先頭1行は Q146 形式（`STATE/REASON/NEXT`）で必ず出す。
  * **Supersedes: Q159（exit契約のSTOP未定義部分）**
  * Relates to: Q146, Q159, Q161

* **Q166（Adopted）**：WIP-025/026 の `<MERGE_COMMIT_SHA>` は一次根拠で取得し、PROOF_LINE_KEY生成を割れなくする。

  * 目的：WIP-025/026 の正規形（`^<MERGE_COMMIT_SHA>\s+Merge pull request #<PR_NUMBER>\b`）に必要な `<MERGE_COMMIT_SHA>` の取得元を固定する。
  * 前提：WIP-022により `PR.number` が確定している（未確定ならWIP-025/026は評価不能＝未完）。
  * 固定（一次根拠）：

    * `MERGE_COMMIT_SHA` は `gh pr view <PR_NUMBER> --json mergeCommit --jq '.mergeCommit.oid'` で取得した値を正とする。
    * 一次根拠キー：`PR.mergeCommit.oid` を正とする。
  * 正規形・キー生成（固定）：

    * `BUNDLED_PROOF_LINE_REGEX` / `EVIDENCE_PROOF_LINE_REGEX` は、上記 `MERGE_COMMIT_SHA` と `PR_NUMBER` を値として展開して構成する。
    * `PROOF_LINE_KEY` は `"<MERGE_COMMIT_SHA>#<PR_NUMBER>"` を正とする。
  * **Supersedes: Q163（WIP-025/026における MERGE_COMMIT_SHA 取得元未定義部分）**
  * Relates to: Q150, Q158, Q163

## Q167〜Q168（Adopted）：ニュアンス正本（Readable Spec）とGate割当表の固定（v1）

* **Q167（Adopted）**：ニュアンスの正本（人間が迷わない説明・例外・境界定義）は Readable Spec に固定し、監査スコープに含める。

  * 目的：決定台帳（PART A）が「決定のみ」である前提を崩さず、実装者・監査者がニュアンス不足で迷走しないようにする。
  * 正本（優先順位）：

    * 決定の正：PART A（本ファイルのQ）
    * ニュアンス正：Readable Spec（派生物）`docs/MEP/READABLE_SPEC.md`
    * 矛盾時：PART A が常に勝つ（Readable Spec は矛盾を作ってはならない。矛盾が出た場合は Readable Spec 側が修正対象）
  * 監査スコープ固定：

    * 監査は「PART A（決定）＋ Readable Spec（ニュアンス）」を必須入力として扱う。
    * Readable Spec が欠落／短すぎる／Gate割当表が欠落の場合は「監査材料不足」として STOP してよい（stop_kind/stop_class/exit は既存契約に従う）。
  * Relates to: Q71, Q74, Q75, Q76, Q85〜Q97, Q105, Q121

* **Q168（Adopted）**：Gate割当表（どの決定をどこで検査するか）を固定し、実装の順序・責務のズレを禁止する。

  * 目的：監査観点と実装順序を固定し、「前回OKなのに今回NG」等の迷走を防ぐ。
  * Gate割当表（固定）：

    * SSOT_SCAN（Q121〜Q128）：

      * Q整合／Supersedes参照整合／宣言整合（Q122）
      * PART A/PART B の境界と署名規約（Q74/Q75）
    * CONFLICT_SCAN（Q129〜Q136）：

      * business/system混在、allowed_paths逸脱等（Q5/Q17/Q18/Q130）
    * Gate-0（Integrity）（Q85）：

      * 固定workflow参照の実在・active確認（Q149）
      * 参照先ファイルの欠落・破損（Q85）
    * Gate-1（Input）（Q86）：

      * required_checks_expected[] / pr_creator_allowlist[] の構造検査（Q152/Q153）
      * stop_class/stop_kind/resume_packet の置き場存在（Q146/Q156）
    * Gate-3（Provenance）（Q88）：

      * 固定workflow参照の唯一性（Q148）
    * Gate-5（Consistency）（Q90）：

      * Supersedes/Superseded by による単一解化（RULE-0/RULE-1）
    * Gate-9（Commit）（Q94）：

      * 外周PR監査（CHECKS_PRESENT / REQUIRED_CHECKS_MATCHED / TRIGGER_ACTOR_OK）（Q151）
    * Gate-12（Health）（Q97）：

      * STOP時含めhealth更新（Q58/Q59/Q97）
    * ENTRY（未完駆動）（Q159/Q150/Q157〜Q158/Q162〜Q166）：

      * WIP-021〜026の複合DoD達成確認（Q150）
      * WIP-022一意確定（Q164）
      * WIP-025/026証跡行確認とMERGE_COMMIT_SHA取得（Q163/Q166）
      * STOP時exit契約（Q165）
  * この割当表に反する順序変更・責務移動は「設計逸脱」としてSTOPしてよい。
  * Relates to: Q85〜Q97, Q121〜Q136, Q146〜Q156, Q159〜Q166

---

## Q169（Adopted）：SSOT_SCANのQ順序は厳格（昇順でなければSTOP）【単一解固定】

* **Q169（Adopted）**：SSOT_SCAN（Q121〜Q128）における **Q整合（Q番号の順序）**の扱いを単一解として固定する。

  * 目的：Q番号の出現順の扱いが「STOPかAUTO_FIXか」で割れないようにする（実装割れ防止）。
  * 固定（単一解）：

    * **PART A（決定台帳）内のQ番号の出現順が昇順でない場合は、SSOT_SCANは必ず STOP とする。**
    * ここでいう「昇順でない」とは、例として `Q31〜Q35 → Q52〜Q57 → Q36〜…` のような **番号の巻き戻り／飛び込み**を含む。
  * STOP条件（明文化）：

    * `Q_order_violation=true`（任意の内部キー）を検知した場合、`SSOT_SCAN=STOP`。
  * 期待される最小修正：

    * **SSOT（本ファイル）側でQ番号の出現順を昇順に並べ替える**（AUTO_FIXで整列して継続は許可しない）。
  * Relates to: Q121, Q122, Q123, Q125, Q145

---

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
* required_checks_expected:
  - business-non-interference-guard
  - scope-fence
* pr_creator_allowlist: []
* disallow_bot_github_token_pr: true
---

# PART C: 機械生成物（パス固定｜人間は触らない）

* EXTRACT_LEDGER（抽出台帳）: `docs/MEP/DECISION_LEDGER.md`（本ファイルPART Aから抽出生成）
* EXTRACT_INPUT（抽出入力）: `docs/MEP/INPUT_PACKET.md`（本ファイルPART B等から正規化生成）
* Readable Spec: `docs/MEP/READABLE_SPEC.md`
* Handoff: `docs/MEP/HANDOFF.md`
* health: `docs/MEP_STATUS/mep_health.json` / `docs/MEP_STATUS/mep_health.md`
* roadmap cards: `docs/MEP/ROADMAP_CARDS/<RM_ID>.md`

---

## 末尾宣言（監査基準の明確化）

* 採用済み決定の正本は **PART A（Q1〜Q169）**のみ。
* PART Bは **運用入力器（Schema）**であり、空欄は欠落ではない（AUTO補完・不可欠時のみSTOP）。
* SSOT-A/SSOT-Bの外部ファイルは **抽出物（派生物）**であり、正本は本ファイルのみ。
* **このファイルに無い決定は採用済みではない。**

