# validate_master_spec.py
# Purpose: Detect contradictions in tictactoe master_spec and exit non-zero (error)
import sys
from pathlib import Path


def fail(msg: str) -> int:
    print(f"[SPEC_ERROR] {msg}", file=sys.stderr)
    return 1


def main() -> int:
    if len(sys.argv) != 2:
        return fail("usage: python validate_master_spec.py <path-to-master_spec.md>")

    p = Path(sys.argv[1])
    if not p.exists():
        return fail(f"file not found: {p}")

    text = p.read_text(encoding="utf-8")

    # Very small, explicit contradiction checks (deterministic)
    has_win_condition = ("勝利条件" in text) and ("揃" in text or "横" in text or "縦" in text or "斜め" in text)
    says_no_winner = ("勝者は存在しない" in text) or ("勝者が存在しない" in text)

    if has_win_condition and says_no_winner:
        return fail("contradiction: win condition exists but spec also says 'no winner exists'.")

    print("[SPEC_OK] no contradictions detected.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
