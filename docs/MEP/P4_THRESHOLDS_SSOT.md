# P4_THRESHOLDS_SSOT (v0)
この文書は P4 LLM_FENCE の **閾値（正）** を固定する SSOT である。  
**閾値の正は本SSOT**であり、workflow実装は参照側（読み取り側）でなければならない。
## 現行値（main実装の固定値をそのまま転記）
- max_bytes = 250000
- max_files = 60
- max_added = 2000
- scope allowlist:
  - mep/**
  - docs/MEP/**
  - .github/workflows/**
  - tools/runner/**
  - README.md
- keyword deny（検出したら STOP_HARD）:
  - secrets.
  - OPENAI_API_KEY
  - Authorization: Bearer
  - curl ... | sh
---
## BEGIN_ENV
P4_MAX_BYTES=250000
P4_MAX_FILES=60
P4_MAX_ADDED=2000
P4_ALLOW_REGEX=^(mep/|docs/MEP/|\.github/workflows/|tools/runner/|README\.md$)
P4_DENY_REGEX=(secrets\.|OPENAI_API_KEY|Authorization:\s*Bearer|curl\s+.*\|\s*sh)
## END_ENV