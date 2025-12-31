# CURRENT_SCOPE（今回の作業対象）

本書は「いま何を作業対象とするか」を宣言する。

CURRENT_SCOPE（例）：
- platform/MEP/03_BUSINESS/よりそい堂/**（業務マスタ/スペック）
- platform/MEP/03_BUSINESS/tictactoe/**（業務マスタ/スペック）
- 参照監査：03_BUSINESS内の参照（@Sxxxx等）→ 01_CORE/definitions/SYMBOLS.md に照合
- バイナリ統治：非テキストは sha256 allowlist で許可制

禁止：
- CURRENT_SCOPE外の範囲を勝手に参照・変更しない
- 全文置換、勝手な要約、無関係な整形

確定条件：
- PR差分
- 必須チェック合格
- mainへマージされた時点を唯一の確定とする
