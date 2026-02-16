# system_pack_engine (parallel-safe)
This directory is intentionally isolated:
- new files only
- no edits to existing 8-gate orchestration
- produces templates/spec artifacts first
- wiring into 8-gates happens later via a single, reviewable PR
## How to run (local)
From repo root:
python -c "import sys; print(sys.version)"
python -m pip install -U pip
python -m pip install pytest
# run engine
python -c "from pathlib import Path; print(Path('docs/MEP/system_packs').exists())"
python -m system_pack_engine.cli --pack docs/MEP/system_packs/MEP_SYSTEM_PACK_v1_FULL_CONVERGENCE_2026-02-16.md --out ./.mep_system_pack_out
# run tests
python -m pytest -q tools/system_pack_engine/tests
