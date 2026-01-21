BUNDLE_VERSION = v0.0.0+20260120_160047+main_52873f8

本書は Draft（提案）であり、採用確定ではない（採用は PR→main→Bundled の証跡のみ）。

## 監査根拠
- Bundled本文: docs/MEP/MEP_BUNDLE.md
- 束ね識別: 先頭ヘッダの BUNDLE_VERSION

## 根拠対応付け（BUSINESS_UNIT バンドル設計 [Draft]）
（Bundled本文から自動抽出）
## CARD: BUSINESS_UNIT バンドル設計（ドメイン単位の束ね）  [Draft]

### 目的
BUSINESS側を構築すると、例外・分岐・用語・台帳参照が急増し、全体BUNDLEだけでは参照コストと混線リスクが上がる。ドメイン（業務単位）ごとの束ねを持ち、再開・実装・監査を高速化する。

### 3階層（推奨）
- **GLOBAL（全体BUNDLE）**：MEP契約・Gate・状態タグ・安全規約など共通
- **BUSINESS_UNIT（業務単位BUNDLE）**：そのドメイン固有（前提/用語/台帳/境界/DoD/例外）
- **WORK_ITEM（作業単位ミニBUNDLE/CURRENT）**：1テーマの目的/前提/採用済み/未決/次アクションのみ

運用上は「入口投入は単一」を維持するため、起動時に
`GLOBAL + 対象UNIT + 対象WORK_ITEM` を結合した **STARTUP_BUNDLE（単一）** を生成して投入する。

### 分割原則（汚染防止）
- **層の優先順位固定**：GLOBAL > UNIT > WORK_ITEM（下位が上位を上書き禁止）
- **重複禁止**：同一決定は1か所のみ（例：状態タグ/Gate/確定定義はGLOBALのみ）
- **参照固定**：UNIT/WORK_ITEMは参照するGLOBALのBUNDLE_VERSION（またはcommit）を明記
- **生成物の手編集禁止**：更新はPR→main→Bundledでのみ行う

# RUNBOOK（復旧カード）

## 未確定事項（隔離）
- BUSINESS_UNIT 単位での独立 Evidence/Audit 運用形態
- BUSINESS_UNIT の切断・再接続・避難の操作仕様
- BUSINESS_UNIT ごとの生成物（ファイル構成・テンプレ群）の固定
- 上記を自動化するワークフロー群の具体設計

※ 本ブロックは Bundled 本文根拠外。確定語彙を使用しない。
