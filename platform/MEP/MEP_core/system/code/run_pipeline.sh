#!/bin/bash
set -e

# usage: ./run_pipeline.sh <diff_file>

DIFF_FILE="$1"

if [ -z "$DIFF_FILE" ]; then
  echo "diff file required"
  exit 1
fi

python pipeline.py "$DIFF_FILE"
