# START_HERE（MEP入口） v1.1

## 役割
本書は新チャット開始の唯一の入口である。
新チャット1通目は「目的（1行）」＋本書を貼って開始する。

---

## 最小手数の推奨（貼り付け）

## 起動時ルール（新チャット1通目）

- CHAT_PACKETのみ（指示なし）：作業開始しない。溜まっている引継ぎ（open PR / CONTINUE_TARGET 等）＋アイデア一覧（IDEA_INDEX / ACTIVE）を提示し、「どれを始めますか？」で選択させる。
- CHAT_PACKET＋指示あり：指示に当てはまるリストを提示し、工程表を作成する（以後、ユーザーの自由文による採用宣言があるまでコードは出さない）。

- 最短は docs/MEP/CHAT_PACKET.md を貼る（1枚で開始できる）。
- CHAT_PACKET が無い場合は、本書（START_HERE）を貼って開始する。

- PRをMERGEしたら、STATE_CURRENT.mdへ最小追記（1〜3行）を行い、「何が正式採用になったか」を固定する。
- 対象は「運用ルール／ゲート／境界」および「BUSINESSの契約（同期・冪等・回収など）」で、整形や生成物更新だけは原則スキップする。

---

## 参照順（固定）
1. docs/MEP/STATE_CURRENT.md（現在地）
2. docs/MEP/ARCHITECTURE.md（構造）
3. docs/MEP/PROCESS.md（手続き）
4. docs/MEP/GLOSSARY.md（用語）
5. docs/MEP/GOLDEN_PATH.md（完走例）

---

## AIの要求ルール（必須）
- 「全部貼れ」「大量ファイル貼れ」は禁止。
- 追加が必要な場合のみ、最大3件まで、必ず次の形式で要求する。

### REQUEST
- file: <ファイルパス>
- heading: <見出し名>
- reason: <必要理由（1行）>

---

## Links
- docs/MEP/CHAT_PACKET.md
- docs/MEP/MEP_MANIFEST.yml
- docs/MEP/INDEX.md
- docs/MEP/AI_BOOT.md
- docs/MEP/STATE_CURRENT.md
- docs/MEP/ARCHITECTURE.md
- docs/MEP/PROCESS.md
- docs/MEP/GLOSSARY.md
- docs/MEP/GOLDEN_PATH.md

- [OPS: Scope-IN Suggest 運用（Out-of-scope 自動提案PR）](docs/MEP/OPS_SCOPE_SUGGEST.md)


