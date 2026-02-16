from __future__ import annotations
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple
@dataclass
class RunResult:
    state: str                    # DONE | STOP_WAIT | STOP_HARD
    hard_kind: Optional[str]       # FATAL | RECOVERABLE | None
    safe_bias: bool
    outputs: Dict[str, str]        # logical name -> file path (string)
    diff_report: str               # markdown text
    invariant_report: str          # markdown text
HEADER_RE = re.compile(r"^(TITLE|SYSTEM_ID|BUSINESS_ID):\s*(.+)$", re.MULTILINE)
def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")
def _write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")
def parse_headers(text: str) -> Dict[str, str]:
    found: Dict[str, str] = {}
    for m in HEADER_RE.finditer(text):
        found[m.group(1).strip()] = m.group(2).strip()
    return found
def evaluate_invariants(headers: Dict[str, str]) -> Tuple[str, Optional[str], List[str]]:
    """
    Minimal invariant evaluation per SYSTEM_PACK:
    - TITLE missing -> STOP_WAIT
    - SYSTEM_ID missing -> STOP_WAIT
    - BUSINESS_ID missing -> STOP_WAIT
    - BUSINESS_ID invalid format (not NONE and not BIZ-*) -> STOP_HARD_FATAL
    """
    reasons: List[str] = []
    title = headers.get("TITLE", "").strip()
    system_id = headers.get("SYSTEM_ID", "").strip()
    business_id = headers.get("BUSINESS_ID", "").strip()
    if not title:
        reasons.append("INV_TITLE_REQUIRED: TITLE missing -> STOP_WAIT")
        return ("STOP_WAIT", None, reasons)
    if not system_id:
        reasons.append("INV_SYSTEM_ID_REQUIRED: SYSTEM_ID missing -> STOP_WAIT")
        return ("STOP_WAIT", None, reasons)
    if not business_id:
        reasons.append("INV_BUSINESS_ID_REQUIRED: BUSINESS_ID missing -> STOP_WAIT")
        return ("STOP_WAIT", None, reasons)
    if business_id != "NONE" and not business_id.startswith("BIZ-"):
        reasons.append(f"INV_BUSINESS_ID_FORMAT: BUSINESS_ID invalid format ({business_id}) -> STOP_HARD_FATAL")
        return ("STOP_HARD", "FATAL", reasons)
    reasons.append("INV_OK: basic header invariants satisfied")
    return ("RUNNING", None, reasons)
def compute_safe_bias(meaning_or_strength_changed: List[str], manual_required: List[str]) -> bool:
    return (len(meaning_or_strength_changed) == 0) and (len(manual_required) == 0)
def render_diff_report(auto_applied: List[str], meaning_or_strength_changed: List[str], manual_required: List[str]) -> str:
    safe_bias = compute_safe_bias(meaning_or_strength_changed, manual_required)
    def section(title: str, items: List[str]) -> str:
        if not items:
            return f"## {title}\n\n- (empty)\n"
        return "## " + title + "\n\n" + "\n".join([f"- {x}" for x in items]) + "\n"
    out = "# DIFF REPORT\n\n"
    out += section("AUTO_APPLIED", auto_applied) + "\n"
    out += section("MEANING_OR_STRENGTH_CHANGED", meaning_or_strength_changed) + "\n"
    out += section("MANUAL_REQUIRED", manual_required) + "\n"
    out += "## SAFE_BIAS\n\n"
    out += f"- SAFE_BIAS: {'TRUE' if safe_bias else 'FALSE'}\n"
    return out
def render_invariant_report(invariant_reasons: List[str], state: str, hard_kind: Optional[str]) -> str:
    out = "# INVARIANT REPORT\n\n"
    out += f"- STATE: {state}\n"
    out += f"- HARD_KIND: {hard_kind if hard_kind else '(none)'}\n\n"
    out += "## DETAILS\n\n"
    for r in invariant_reasons:
        out += f"- {r}\n"
    return out
def render_formal_md(pack_text: str) -> str:
    """
    Minimal: formal.md is a generated artifact; for now we embed the pack text verbatim
    under a wrapper header. (No summary/abbreviation; avoids meaning drift.)
    """
    return "# FORMAL (GENERATED)\n\n" + pack_text + "\n"
def converge(pack_path: Path, out_dir: Path) -> RunResult:
    pack_text = _read_text(pack_path)
    headers = parse_headers(pack_text)
    inv_state, inv_hard_kind, inv_reasons = evaluate_invariants(headers)
    auto_applied: List[str] = []
    meaning_or_strength_changed: List[str] = []
    manual_required: List[str] = []
    # If STOP_WAIT due to missing required headers, demand manual input
    if inv_state == "STOP_WAIT":
        manual_required.append("MANUAL_REQUIRED: Provide missing required headers (TITLE/SYSTEM_ID/BUSINESS_ID).")
    # If STOP_HARD_FATAL, demand manual correction
    if inv_state == "STOP_HARD" and inv_hard_kind == "FATAL":
        manual_required.append("MANUAL_REQUIRED: Fix BUSINESS_ID format (NONE or BIZ-...).")
    # Build resolved_spec (best-effort)
    resolved = {
        "meta": {
            "source_pack": str(pack_path.as_posix()),
        },
        "headers": headers,
        "state": "DONE" if (inv_state == "RUNNING") else ("STOP_HARD" if inv_state == "STOP_HARD" else "STOP_WAIT"),
        "hard_kind": inv_hard_kind,
    }
    safe_bias = compute_safe_bias(meaning_or_strength_changed, manual_required)
    # Per pack: SAFE_BIAS false => STOP_WAIT (even if headers ok). We only enforce if issues exist.
    final_state = resolved["state"]
    final_hard_kind = inv_hard_kind
    if final_state == "DONE" and not safe_bias:
        final_state = "STOP_WAIT"
        final_hard_kind = None
        inv_reasons.append("INV_SAFE_BIAS: SAFE_BIAS is FALSE -> STOP_WAIT")
    # Write outputs
    out_dir.mkdir(parents=True, exist_ok=True)
    resolved_path = out_dir / "resolved_spec.json"
    diff_path = out_dir / "diff_report.md"
    inv_path = out_dir / "invariant_report.md"
    formal_path = out_dir / "formal.md"
    _write_text(resolved_path, json.dumps(resolved, ensure_ascii=False, indent=2))
    diff_report = render_diff_report(auto_applied, meaning_or_strength_changed, manual_required)
    _write_text(diff_path, diff_report)
    invariant_report = render_invariant_report(inv_reasons, final_state, final_hard_kind)
    _write_text(inv_path, invariant_report)
    _write_text(formal_path, render_formal_md(pack_text))
    outputs = {
        "resolved_spec.json": str(resolved_path.as_posix()),
        "diff_report.md": str(diff_path.as_posix()),
        "invariant_report.md": str(inv_path.as_posix()),
        "formal.md": str(formal_path.as_posix()),
    }
    return RunResult(
        state=final_state,
        hard_kind=final_hard_kind,
        safe_bias=safe_bias,
        outputs=outputs,
        diff_report=diff_report,
        invariant_report=invariant_report,
    )
