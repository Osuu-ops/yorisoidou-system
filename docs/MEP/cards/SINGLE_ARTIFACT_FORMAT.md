<!-- BEGIN: SINGLE_ARTIFACT_FORMAT (MEP) -->
## CARD: SINGLE ARTIFACT FORMAT（唯一の成果物フォーマット）  [Draft]

### 確定案（作業用ドラフトで整理した案）：Markdown Card Block

#### 定義（唯一の成果物フォーマット）
採用ルートに投入する成果物は、以下の **Markdown Card Block** に統一する。

#### 形式（必須）
1) ヘッダ（必須）
- `## CARD: <CARD_NAME>  [Draft|Adopted]`

2) 境界（必須）
- `<!-- BEGIN: <CARD_ID> -->`
- `<!-- END: <CARD_ID> -->`

#### 境界ルール（必須）
- BEGIN/END は必ず対で存在する（片側欠損は DIRTY）
- 同一 BEGIN（同一 `<CARD_ID>`）の重複定義は禁止（検出したら NG）

#### 受入テスト（入口）での機械判定（最小）
- 形式：BEGIN/END 整合、必須フィールドの存在
- 禁止：コンフリクト痕跡、片側欠損、曖昧な範囲採用（例：「ここまで全部採用」）
- 境界：カード定義の重複/多重定義がない

#### 制約（Bundled記載の再掲）
- 本カードが **未確定（[Draft]）の間**、採用ルート自動化は段階停止（拡張禁止）
<!-- END: SINGLE_ARTIFACT_FORMAT (MEP) -->
