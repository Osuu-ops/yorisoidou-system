# pipeline.py
# diff -> candidate -> Z.evaluate -> S.commit
# ENFORCE MODE / no human judgment

import json
import subprocess
import sys
from pathlib import Path
from datetime import datetime


def run_z_evaluate(candidate_path: Path) -> bool:
    result = subprocess.run(
        ["python", "z_evaluate.py", str(candidate_path)],
        capture_output=True,
        text=True
    )
    return result.returncode == 0


def commit_to_s(candidate_path: Path):
    subprocess.run(["git", "add", str(candidate_path)], check=True)
    subprocess.run(
        ["git", "commit", "-m", "S.commit: candidate approved by Z.evaluate"],
        check=True
    )


def main(diff_path: str):
    diff_path = Path(diff_path)
    candidate_path = Path("candidate.json")

    # diff -> candidate (mechanical wrap only)
    candidate = {
        "diff": diff_path.read_text(encoding="utf-8"),
        "metadata": {
            "generated_at": datetime.utcnow().isoformat() + "Z",
            "source": str(diff_path)
        }
    }

    candidate_path.write_text(
        json.dumps(candidate, ensure_ascii=False, indent=2),
        encoding="utf-8"
    )

    # Z.evaluate
    if not run_z_evaluate(candidate_path):
        print("Z.evaluate NG", file=sys.stderr)
        sys.exit(1)

    # S.commit
    commit_to_s(candidate_path)
    print("S.commit OK")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("diff path required", file=sys.stderr)
        sys.exit(1)

    main(sys.argv[1])
