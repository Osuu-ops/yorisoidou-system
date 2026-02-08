# HANDOFF｜次チャット冒頭に貼る本文（二重構造・公式テンプレ｜未記入版）
---
## 監査用引継ぎ（一次根拠のみ／確定事項）
### REPO_ORIGIN
（例：https://github.com/owner/repo.git）
### 基準ブランチ
main
### HEAD（main）
（git rev-parse HEAD）
### PARENT_BUNDLED
docs/MEP/MEP_BUNDLE.md
### EVIDENCE_BUNDLE
docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md
### PARENT_BUNDLE_VERSION
（Bundled 内に記載されている vX.Y.Z+…）
### EVIDENCE_BUNDLE_VERSION
（EVIDENCE Bundled 内に記載されている vX.Y.Z+…）
### EVIDENCE_BUNDLE_LAST_COMMIT
（git log -1 -- docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md の  
commit_sha / commit_datetime / commit_message）
---
### 確定（証跡）
- **PR #**
  - mergedAt:
  - mergeCommit:
  - PR_URL
※上記はすべて main ブランチおよび gh / git の一次出力に基づく。
---
## 作業用引継ぎ（外部：設計意図／派生管理）
### 人間用要約（一次根拠外）
#### NOW（現在地）
- （直近で確定した状態を1〜3行で記述）
#### REMAINING（残り未完）
- OP- ：（未完の理由／未確定点）
- OP- ：（必要に応じて追加）
#### PROGRESS（進捗）
- **STRONG**: （HEAD / PARENT_BUNDLE_VERSION の変化）
- **WEAK**: （証跡行・PR状態などの変化）
- **進捗率（%）**: （任意。分母を固定できる場合のみ）
---
### 上位目的（外部固定・一次根拠外）
#### OP-0
- システムとビジネスを分離して管理する  
- 親システム側の変更がビジネス領域に混入・汚染しない構造を維持する  
- 承認（0）→PR→main→Bundled/EVIDENCE の一次根拠ループを自動で回せる状態を作る  
※この上位目的は本テンプレの最上位契約であり、削除・再定義しない。
---
### 上位目的からの派生（外部固定）
#### OP-1
- EVIDENCE（子MEP）が main の進行に追随し続ける状態を保証する
#### OP-2
- handoff が破損しても復帰できる最小運用系を常に保持する
#### OP-3
- Scope Guard / 非干渉ガードにより、ログ・zip・想定外ファイル混入を自動排除する
（※必要に応じて OP-4, OP-5… を追加する）
---
## 完了（派生ID基準）
- **OP-**
  - 完了内容の要約  
  - 一次根拠：PR # / mergeCommit / HEAD
---
## 未完（派生ID基準）
- **OP-**
  - 未完理由／未確定点
---
## 次工程（派生ID参照）
- **OP-**
  - 次に実施する具体作業
- **OP-**
  - 必要に応じて追加
---
## 新チャット開始メッセージ（固定・未記入版）
ここから **新チャットとして処理を開始する**。  
上記 HANDOFF を唯一の入力正とし、**過去会話は参照しない**。
最初に行う作業は次のとおり：
1. PowerShell により main / Bundled / EVIDENCE / SSOT を吸い上げて監査する  
2. 現在地・未完・次工程が HANDOFF と一致しているか確認する  
3. 未完 OP の実装を進める  
**すべての操作・検証・出力は PowerShell で完結させること。**
