# Z.evaluate - minimal implementation
# ENFORCE MODE
# Decision authority: Z only (no human judgment)

import json
import sys
from datetime import datetime


def z_evaluate(candidate_path: str) -> int:
    """
    Input:
      candidate_path: path to candidate json

    Output:
      exit code
        0 = OK
        1 = NG
    """

    try:
        with open(candidate_path, "r", encoding="utf-8") as f:
            candidate = json.load(f)

        # --- Minimal axioms check ---
        # Existence only. No intelligence. No inference.
        required_keys = ["diff", "metadata"]

        for key in required_keys:
            if key not in candidate:
                log_ng(f"missing key: {key}")
                return 1

        log_ok("Z.evaluate OK")
        return 0

    except Exception as e:
        log_ng(str(e))
        return 1


def log_ok(message: str):
    log = {
        "result": "OK",
        "message": message,
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }
    print(json.dumps(log, ensure_ascii=False))


def log_ng(message: str):
    log = {
        "result": "NG",
        "message": message,
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }
    print(json.dumps(log, ensure_ascii=False), file=sys.stderr)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        log_ng("candidate path not provided")
        sys.exit(1)

    candidate_path = sys.argv[1]
    exit_code = z_evaluate(candidate_path)
    sys.exit(exit_code)
