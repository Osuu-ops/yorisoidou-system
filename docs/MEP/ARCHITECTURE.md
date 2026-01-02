# ARCHITECTURE（構造） v1.1

## 目的
MEP運用で迷い・暴走・汚染が起きる箇所を、構造（パス境界）として固定する。

---

## 唯一の正（Source of Truth）
- **唯一の正は main ブランチ**である。
- 変更は必ず **Pull Request** で行い、**Required checks** を通過してからマージする。

---

## 入口（参照開始点）
- 入口は **START_HERE.md → docs/MEP/INDEX.md** を唯一の導線とする。
- 新チャットでは原則 INDEX だけを貼り、追加が必要な場合は **AI_BOOT の REQUEST 形式**で要求する。

---

## 触って良い領域 / 触ってはいけない領域（運用境界）
### 触って良い（今回のINDEX方式のスコープ）
- docs/MEP/**
- START_HERE.md
- .github/workflows/docs_index_guard.yml（入口の整合ガード）

### 原則触らない（別PR・別スコープ）
- platform/MEP/**（MEP本体・業務仕様の実体）
- .github/workflows/* のうち、入口整合ガード以外（CI/運用の核）
- MEP のプロトコル/キャノン/マスター類（変更するなら必ず専用PRでスコープを切る）

---

## 変更の粒度（事故防止）
- 文書の整形（改行/空白/並べ替え）だけのコミットを作らない。
- 巨大ファイルの全文置換を避け、差分を最小化する。
- AIが要求する追加提示は最大3件まで（AI_BOOT準拠）。

---

## 運用上の合格条件（DoD）
- docs/MEP/INDEX.md から各文書へ到達できる（リンク/パスが正しい）
- 「唯一の正」「触って良い/悪い領域」「PR運用」が明文化されている
- 入口破損は Docs Index Guard で検出できる
