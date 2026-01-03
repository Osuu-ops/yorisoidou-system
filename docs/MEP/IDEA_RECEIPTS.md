# IDEA_RECEIPTS（実装レシート台帳） v1.0

目的：
- 「このIDEAは実装された（=採用済み）」を GitHub（main）上で機械判定できる形で固定する。
- IDEA_VAULT の削除は、この台帳に `RESULT: implemented` が入ってからのみ行う。

運用（固定）：
- 実装が完了したら、次の形式で1行追記する（編集はPR経由）。
- 例：
  - IDEA:abcd1234efgh  RESULT: implemented  REF: PR#999  DESC: 今回このアイデアが実装されました

フォーマット（機械判定）：
- 行に `IDEA:xxxxxxxxxxxx`（12桁） と `RESULT: implemented` が同時に含まれていれば「実装済み」と判定する。

---

## RECEIPTS（追記していく：1行=1件）

（空）
