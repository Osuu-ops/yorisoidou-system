# UI Application Protocol
（MEP UI 適用仕様）

## 位置づけ
本書は、MEP システムにおける UI の適用方法を定義する。
UI は MEP の外部に位置し、MEP 本体・判断・統治を持たない。

## UI 種別
- 仮UI（UIなし／手順・CLIベース）

## UI が触る API
- diff 投稿 API
- read_only 取得 API

※ candidate / Z.evaluate / S.commit は UI から触らない。

## UI 入力単位
- 1 diff / 1 実行

## UI 実行
- トリガー：手動のみ
- 実行頻度：都度実行

## 失敗時の扱い
- UI 上の表示なし
- ログ（CI / Z.evaluate）のみを正とする

## 再実行ルール
- 再実行は禁止
- 必ず差し戻し（diff 修正 → 新 diff 投入）

## UI 出力
- 画面出力なし
- ログのみ

## UI 操作ログ
- 取得しない
- CI / Z.evaluate ログのみを正とする


## NG_TEST
- エラー時は UI が原因を説明し、再実行を促す

## NG_TEST2
- エラー時は UI が原因を説明し、再実行を促す
