# IMMUTABLE（不変・統治）

本書は、改定頻度が低く、統治の唯一の正となる不変領域を宣言する。

不変領域（例）：
- platform/MEP/01_CORE/**（MEP CORE：Canons / Protocol / Definitions）
- platform/MEP/01_CORE/definitions/SYMBOLS.md（参照定義の唯一の正）
- .github/workflows/mep_semantic_audit.yml（外部ゲート：監査）
- .mep/allowlists/*.sha256（バイナリ統治 allowlist）

運用：
- IMMUTABLE の変更は最小差分のみ
- 変更は必ずPR経由
- 必須チェック（semantic-audit / semantic-audit-business）合格を確定条件とする
