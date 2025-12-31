# MEP Repository Instructions (Non-negotiable)

## Source of truth
- The repository files are the single source of truth.
- Do not rely on chat memory or assumptions.

## Change policy
- Propose changes as minimal diffs only.
- Do NOT rewrite whole documents unless explicitly requested.
- Do NOT summarize or “improve wording” across unrelated areas.

## Scope
- Primary scope: platform/MEP/01_CORE/**/*.md
- Do not modify other directories unless explicitly requested.

## Audit gate
- Every change must pass the GitHub Actions workflow: "MEP Semantic Audit".
- If the audit fails, focus only on the failing parts and propose minimal fixes.

## Output format
- When proposing changes, output:
  1) What file(s) change
  2) Why (linked to audit log)
  3) Patch-style diff (unified diff)

# Copilot smoke test
