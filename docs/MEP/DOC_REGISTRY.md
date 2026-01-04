# DOC_REGISTRY（文書状態台帳） v1.0

## 目的
- 「現在進行形で改良しているもの」と「安定・放置しているもの」を機械的に区別し、
  新チャット/別AIでの重複編集・競合を防ぐ。

## status 定義（固定）
- ACTIVE: 現在進行で改良してよい（次の作業対象）
- STABLE: 当面触らない（変更は目的明示の専用PRのみ）
- GENERATED: 生成物（直編集禁止。生成器/手順を直す）
- DEPRECATED: 参照は可。新規変更はしない

## 運用ルール（固定）
- 変更に着手する前に、本台帳の status を確認する。
- STABLE/GENERATED は原則触らない（例外は目的明示の専用PR）。
- 何かを ACTIVE に昇格させる場合は、本台帳の該当行を先に更新する（宣言してから触る）。

---

## Registry（主要文書）
| file | status | last_touch | note |
|---|---|---|---|
| START_HERE.md | STABLE | - | 入口。導線破壊は最重要事故。 |
| docs/MEP/CHAT_PACKET.md | STABLE | - | 生成/更新の仕組みがある場合は GENERATED に移行検討。 |
| docs/MEP/MEP_MANIFEST.yml | STABLE | - | 機械可読。変更は最小。 |
| docs/MEP/INDEX.md | ACTIVE | - | 入口の改善対象（リンク追加・整理）。 |
| docs/MEP/AI_BOOT.md | STABLE | - | AI要求制約。頻繁に触らない。 |
| docs/MEP/STATE_CURRENT.md | ACTIVE | - | 現在地と作業宣言。ここで ACTIVE を定義する。 |
| docs/MEP/ARCHITECTURE.md | STABLE | - | 境界・事故防止。頻繁に触らない。 |
| docs/MEP/PROCESS.md | STABLE | - | 手順テンプレ。改訂は目的を明示。 |
| docs/MEP/GLOSSARY.md | STABLE | - | 用語。必要時のみ追記。 |
| docs/MEP/GOLDEN_PATH.md | STABLE | - | 実績の固定。更新は目的明示。 |
| docs/MEP/PLAYBOOK.md | STABLE | - | 次の一手カード集。変更は専用PR。 |
| docs/MEP/RUNBOOK.md | STABLE | - | 復旧カード集。変更は専用PR。 |
| docs/MEP/STATE_SUMMARY.md | GENERATED | - | 生成物（直編集禁止）。 |
| docs/MEP/PLAYBOOK_SUMMARY.md | GENERATED | - | 生成物（直編集禁止）。 |
| docs/MEP/RUNBOOK_SUMMARY.md | GENERATED | - | 生成物（直編集禁止）。 |