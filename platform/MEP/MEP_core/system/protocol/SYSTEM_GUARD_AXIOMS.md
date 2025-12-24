<!--
参照定義ファイル：
MEP/definitions/SYMBOLS.md

運用ルール：
本ファイル内に出現するすべての参照記号（@Sxxxx）は、
個別指定や列挙を行わず、
上記「参照定義ファイル」を唯一の正として解決する。

本ファイルは、参照関係の宣言・管理を行わない。
-->

# SYSTEM_GUARD_AXIOMS
（SYSTEM 機械検知ガード公理定義）

本書は、  
MEP における **SYSTEM 側で機械的に検知可能な違反事象**を  
**検知条件としてのみ**定義する。

本書は、

- 思想を定義しない
- 判断主体を定義しない
- フェーズを定義しない
- 遷移・停止・継続を命令しない

本書は、  
**違反事象の有無を示す機械的フラグを生成することのみ**を目的とする。

本書は、  
MEP_PROTOCOL に定義された思想、および  
system_protocol に定義されたフェーズ制御に  
**一切介入しない。**

---

## 0. 基本原則

SYSTEM_GUARD は、  
以下の性質を持つ。

- 違反を「判断」しない
- 正誤を「評価」しない
- 処理を「停止」しない
- 遷移を「制御」しない

SYSTEM_GUARD が行うのは、  
**定義された条件に該当したか否かの検知のみ**である。

---

## 1. 出力形式（唯一）

SYSTEM_GUARD の出力は、  
以下の形式に限定される。

- `violation_detected = true`
- `violation_detected = false`

これ以外の出力は行わない。

---

## 2. 検知対象（共通）

以下は、SYSTEM_GUARD による検知対象とする。

- MEP_core/foundation 配下の Canon / Protocol / Definition 文書
- MEP_core/protocol 配下の Protocol 文書
- system_protocol が参照対象として扱う成果物
- read-only と明示された領域

---

## 3. 検知公理

### 公理 G-01：行削除検知

対象文書において、  
**既存行の削除が 1 行でも検知された場合**、  
`violation_detected = true` とする。

---

### 公理 G-02：行置換検知

対象文書において、  
**同一行番号で内容が異なる行が検知された場合**、  
`violation_detected = true` とする。

（意味同一・表現改善・誤字修正は考慮しない）

---

### 公理 G-03：diff 非経由変更検知

unified diff を伴わない変更が検知された場合、  
`violation_detected = true` とする。

---

### 公理 G-04：read-only 領域書込み検知

以下の read-only 領域への書込みが検知された場合、  
`violation_detected = true` とする。

- X（最新確定仕様）
- S（最新確定成果物）
- Canon / Protocol / Master 文書

---

### 公理 G-05：違反検知後の継続試行検知

`violation_detected = true` の状態で、  
自動処理・自動生成・自動遷移の試行が検知された場合、  
`violation_detected = true` を維持する。

※ 本公理は  
　SYSTEM_GUARD が **継続を遮断することを意味しない**。

---

### 公理 G-06：保存試行検知

system_protocol により  
保存が成立していない状態で、  
X または S への保存試行が検知された場合、  
`violation_detected = true` とする。

※ 保存の可否・成立条件は  
　本書では定義しない。

---

### 公理 G-07：境界違反入力検知

API 実装時において、  
以下の行為が検知された場合、  
`violation_detected = true` とする。

- read-only 入力の再生成
- candidate を確定扱いする行為
- 会話文脈を判断根拠として使用する行為

---

## 4. system_protocol との関係

SYSTEM_GUARD の出力は、  
system_protocol によって **参照され得る**が、

- 遷移条件とはならない
- 停止条件とはならない
- 判断材料として解釈されない

SYSTEM_GUARD は、  
system_protocol の制御権限を  
**一切持たない。**

---

## 5. Z との関係

SYSTEM_GUARD は、  
Z の代替ではない。

SYSTEM_GUARD は、

- Z を参照しない
- Z に影響を与えない
- Z の判断材料を生成しない

SYSTEM_GUARD の検知結果は、  
Z の存在有無に関わらず  
独立して存在する。

---

## 6. 付記

- SYSTEM_GUARD は理由説明を行わない
- SYSTEM_GUARD は修正案を提示しない
- SYSTEM_GUARD は合意・確定を行わない

本書は、  
**SYSTEM における純粋な機械検知ガード条件**としてのみ効力を持つ。

---

以上。
