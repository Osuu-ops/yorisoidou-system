# HANDOFF TWO-LAYER INPUT SPEC (Fixed)

## Purpose
Prevent audit contamination by strictly separating:
- Audit-truth (Bundled/EVIDENCE only)
- Work-continuation (unfinished tasks / next steps)

## Non-negotiable principles
1. Truth source is Bundled/EVIDENCE only (PR→main→Bundled).
2. Conversation logs are NOT primary evidence.
3. Unfinished tasks must be preserved as "unfinished" (not silently dropped).
4. Confirmation is allowed ONLY at exit points:
   - Approval 1: merge implementation PR to main
   - Approval 2: confirm evidence is appended to Bundled (Evidence Log)

## Required two-layer format (new chat first message)

[監査用引継ぎ]（一次根拠・確定事実）
- BUNDLE_VERSION = <value>
- PR #<number> | audit=OK,WB0000 | <optional fields>

[作業用引継ぎ]（監査外・未確定）
- 未完タスク:
  - ...
- 次工程候補:
  - ...
- 注意点:
  - ...

## Interpretation rules (system behavior)
- Only [監査用引継ぎ] is treated as confirmed facts.
- [作業用引継ぎ] is NEVER treated as confirmed facts; it is a work memo only.
- Mixing layers or missing a layer is WB0001 input contamination and must stop processing.

## Error code
- WB0001: Input contamination (missing layer / mixed content / audit layer contains non-evidence)