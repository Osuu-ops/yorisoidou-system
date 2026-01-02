# GOLDEN_PATH（完走例） v1.1

## 目的
抽象説明ではなく「実際にこのリポジトリで通った完走例」を固定し、
次AI/新チャットが同じ手順で迷わず再現できるようにする。

---

## 完走例A：INDEX方式導入（入口整備）— 実績

### 目的
「マスタ1枚コピペ」運用から脱却し、GitHub上に読む順番（入口）を固定する。

### 実施内容（PR単位）
1) 入口セット作成（START_HERE + docs/MEP + AI_BOOT + Guard）
- PR: #119
- 追加/作成:
  - START_HERE.md
  - docs/MEP/INDEX.md
  - docs/MEP/AI_BOOT.md
  - docs/MEP/STATE_CURRENT.md（雛形）
  - docs/MEP/ARCHITECTURE.md（雛形）
  - docs/MEP/PROCESS.md（雛形）
  - docs/MEP/GLOSSARY.md（雛形）
  - docs/MEP/GOLDEN_PATH.md（雛形）
  - .github/workflows/docs_index_guard.yml
- チェック:
  - semantic-audit / semantic-audit-business（Required）
  - Text Integrity Guard (PR)
  - Docs Index Guard
- 結果: merged

2) ARCHITECTURE 境界の明文化（汚染防止）
- PR: #121
- 変更:
  - docs/MEP/ARCHITECTURE.md を v1.1 に更新（触って良い/悪い領域、粒度、DoD）
- 結果: merged

3) STATE_CURRENT の実務固定（B/A/TIG/Auto PR Gate の使い分け）
- PR: #122
- 変更:
  - docs/MEP/STATE_CURRENT.md を v1.1 に更新（運用状態と使用条件を明文化）
- 結果: merged

---

## 完走手順テンプレ（毎回これで回す）
1) main を最新化
2) 作業ブランチ作成（スコープは1つだけ）
3) 変更（差分は最小）
4) PR作成
5) Required checks が全て OK を確認
6) squash merge（ブランチ削除）
7) main を再同期

---

## 注意（事故防止）
- 「全部貼れ」「大量ファイル貼れ」は禁止。必要なら AI_BOOT の REQUEST 形式で最大3件まで。
- 文書の整形だけのコミットを作らない。巨大ファイルの全文置換を避ける。
- 入口整備のPRは docs/MEP/** と START_HERE.md と docs_index_guard のみに限定する。
