# ISSUE_ENTRY_USAGE（固定｜入口｜Issue草案→PR_CREATE）
## 目的
Issueに草案を投入して、PR_CREATE→PR_CHECKS（Bライン）へ自動接続する。
## 入口コマンド（唯一）
Issueコメントに以下を貼る：
### NO_LLM（パッチ直接）
/mep run
MODE: NO_LLM
PATCH_START
<unified diff patch>
PATCH_END
### LLM（草案→パッチ生成）
/mep run
MODE: LLM
DRAFT_START
<draft text>
DRAFT_END
## 規約
- 入口は上記のみ（他の入口workflowは誤起動防止のため封印/ガードされる）
- PR上では Required checks が必ず走る（SSOT_SCAN/CONFLICT_SCAN を含む）
