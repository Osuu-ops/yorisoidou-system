# Old Entry Seal (Deprecated)
対象（旧入口）:
- .github/workflows/mep_llm_dispatch_entry.yml （deprecated / ghost/422 history）
目的:
- 旧入口を「正」として扱う運用を完全に封印する
- 誤起動があっても、正しい入口（v2）へ誘導できる状態を維持する
## 正入口（Canonical）
- .github/workflows/mep_llm_dispatch_entry_v2.yml が唯一の正入口
- 旧入口は運用上「正として扱わない」
## 封印ポリシー
- 旧入口は “復活させない / 正に戻さない”
- 変更が必要なら v2 側で行う
- 旧入口を触る変更は原則禁止（例外が必要なら、一次根拠＋理由＋回帰必須）
## 誤起動時の対応
- 旧入口が起動された事実（run URL）を一次根拠として記録
- 正入口（v2）を使用して再実行し、回帰を一次根拠で固定する
## 参考（一次根拠）
- v2統合: PR #2215 (MERGED)
- 回帰: NO_DRAFT run 22023267821 → PR #2216 (MERGED)
- 回帰: WITH_DRAFT run 22023302204 → PR #2217 (MERGED)