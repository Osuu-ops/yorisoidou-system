#!/usr/bin/env bash
set -euo pipefail
# Usage:
#   bash tools/runner/p4_thresholds_load.sh [--github-env <path>] [SSOT_FILE]
#
# Loads BEGIN_ENV..END_ENV block from SSOT and validates required keys.
# If --github-env is given, appends P4_* variables to that file (for GitHub Actions env propagation).
github_env=""
if [[ "${1:-}" == "--github-env" ]]; then
  github_env="${2:-}"
  [[ -n "$github_env" ]] || { echo "STOP_HARD: --github-env requires path" >&2; exit 1; }
  shift 2
fi
SSOT_FILE="${1:-docs/MEP/P4_THRESHOLDS_SSOT.md}"
if [[ ! -f "$SSOT_FILE" ]]; then
  echo "STOP_HARD: P4_THRESHOLDS_SSOT_NOT_FOUND: $SSOT_FILE" >&2
  exit 1
fi
env_block="$(
  awk '
    $0 ~ /^##[[:space:]]*BEGIN_ENV[[:space:]]*$/ {in=1; next}
    $0 ~ /^##[[:space:]]*END_ENV[[:space:]]*$/ {in=0}
    in==1 {print}
  ' "$SSOT_FILE"
)"
if [[ -z "${env_block//[[:space:]]/}" ]]; then
  echo "STOP_HARD: P4_THRESHOLDS_ENV_BLOCK_EMPTY" >&2
  exit 1
fi
# shellcheck disable=SC1090
eval "$env_block"
required=(P4_MAX_BYTES P4_MAX_FILES P4_MAX_ADDED P4_ALLOW_REGEX P4_DENY_REGEX)
for k in "${required[@]}"; do
  if [[ -z "${!k:-}" ]]; then
    echo "STOP_HARD: P4_THRESHOLDS_MISSING_KEY: $k" >&2
    exit 1
  fi
done
export P4_MAX_BYTES P4_MAX_FILES P4_MAX_ADDED P4_ALLOW_REGEX P4_DENY_REGEX
if [[ -n "$github_env" ]]; then
  {
    echo "P4_MAX_BYTES=$P4_MAX_BYTES"
    echo "P4_MAX_FILES=$P4_MAX_FILES"
    echo "P4_MAX_ADDED=$P4_MAX_ADDED"
    echo "P4_ALLOW_REGEX=$P4_ALLOW_REGEX"
    echo "P4_DENY_REGEX=$P4_DENY_REGEX"
  } >> "$github_env"
fi
echo "P4_THRESHOLDS_LOADED: bytes=$P4_MAX_BYTES files=$P4_MAX_FILES added=$P4_MAX_ADDED"