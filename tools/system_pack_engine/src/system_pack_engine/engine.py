from __future__ import annotations
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple
@dataclass
class RunResult:
    state: str
    hard_kind: Optional[str]
    safe_bias: bool
    outputs: Dict[str, str]
    diff_report: str
    invariant_report: str
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
    PACK準拠（現時点の最小セット）
    - TITLE/SYSTEM_ID/BUSINESS_ID 欠落 -> STOP_WAIT
    - SYSTEM_ID は SYS-MEP 固定 -> STOP_WAIT
    - BUSINESS_ID は NONE or BIZ-* -> それ以外は STOP_HARD/FATAL
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
    if system_id != "SYS-MEP":
        reasons.append("INV_SYSTEM_ID_VALUE: SYSTEM_ID must be SYS-MEP -> STOP_WAIT")
        return ("STOP_WAIT", None, reasons)
    if business_id != "NONE" and not business_id.startswith("BIZ-"):
        reasons.append("INV_BUSINESS_ID_FORMAT: invalid format -> STOP_HARD_FATAL")
        return ("STOP_HARD", "FATAL", reasons)
    reasons.append("INV_OK")
    return ("RUNNING", None, reasons)
def compute_safe_bias(meaning: List[str], manual: List[str]) -> bool:
    return len(meaning) == 0 and len(manual) == 0
def render_diff_report(auto: List[str], meaning: List[str], manual: List[str]) -> str:
    safe = compute_safe_bias(meaning, manual)
    def sec(name: str, items: List[str]) -> str:
        if not items:
            return f"## {name}\n\n- (empty)\n"
        return "## " + name + "\n\n" + "\n".join([f"- {x}" for x in items]) + "\n"
    out = "# DIFF REPORT\n\n"
    out += sec("AUTO_APPLIED", auto) + "\n"
    out += sec("MEANING_OR_STRENGTH_CHANGED", meaning) + "\n"
    out += sec("MANUAL_REQUIRED", manual) + "\n"
    out += "## SAFE_BIAS\n\n"
    out += f"- SAFE_BIAS: {'TRUE' if safe else 'FALSE'}\n"
    return out
def render_invariant_report(reasons: List[str], state: str, hard_kind: Optional[str]) -> str:
    out = "# INVARIANT REPORT\n\n"
    out += f"- STATE: {state}\n"
    out += f"- HARD_KIND: {hard_kind if hard_kind else '(none)'}\n\n"
    for r in reasons:
        out += f"- {r}\n"
    return out
def render_formal_md(pack_text: str) -> str:
    return "# FORMAL (GENERATED)\n\n" + pack_text + "\n"
def render_auto_patch_json(safe_bias: bool) -> Dict:
    return {
        "type": "AUTO_PATCH",
        "safe_bias": safe_bias,
        "operations": []
    }
def render_auto_patch_md(safe_bias: bool) -> str:
    if safe_bias:
        return "# AUTO PATCH\n\n- No changes required (SAFE_BIAS=TRUE)\n"
    return "# AUTO PATCH\n\n- Patch suggestions generated (SAFE_BIAS=FALSE)\n"
def converge(pack_path: Path, out_dir: Path) -> RunResult:
    pack_text = _read_text(pack_path)
    headers = parse_headers(pack_text)
    inv_state, inv_hard_kind, inv_reasons = evaluate_invariants(headers)
    auto: List[str] = []
    meaning: List[str] = []
    manual: List[str] = []
    if inv_state == "STOP_WAIT":
        manual.append("MANUAL_REQUIRED: Fix required headers or SYSTEM_ID mismatch.")
    if inv_state == "STOP_HARD" and inv_hard_kind == "FATAL":
        manual.append("MANUAL_REQUIRED: Fix BUSINESS_ID format (NONE or BIZ-...).")
    safe_bias = compute_safe_bias(meaning, manual)
    final_state = "DONE" if (inv_state == "RUNNING" and safe_bias) else inv_state
    out_dir.mkdir(parents=True, exist_ok=True)
    resolved_path = out_dir / "resolved_spec.json"
    diff_path = out_dir / "diff_report.md"
    inv_path = out_dir / "invariant_report.md"
    formal_path = out_dir / "formal.md"
    auto_json_path = out_dir / "auto_patch.json"
    auto_md_path = out_dir / "auto_patch.md"
    resolved = {
        "headers": headers,
        "state": final_state,
        "hard_kind": inv_hard_kind
    }
    diff_report = render_diff_report(auto, meaning, manual)
    invariant_report = render_invariant_report(inv_reasons, final_state, inv_hard_kind)
    _write_text(resolved_path, json.dumps(resolved, ensure_ascii=False, indent=2))
    _write_text(diff_path, diff_report)
    _write_text(inv_path, invariant_report)
    _write_text(formal_path, render_formal_md(pack_text))
    auto_patch_json = render_auto_patch_json(safe_bias)
    auto_patch_md = render_auto_patch_md(safe_bias)
    _write_text(auto_json_path, json.dumps(auto_patch_json, ensure_ascii=False, indent=2))
    _write_text(auto_md_path, auto_patch_md)
    outputs = {
        "resolved_spec.json": str(resolved_path),
        "diff_report.md": str(diff_path),
        "invariant_report.md": str(inv_path),
        "formal.md": str(formal_path),
        "auto_patch.json": str(auto_json_path),
        "auto_patch.md": str(auto_md_path),
    }
    return RunResult(
        state=final_state,
        hard_kind=inv_hard_kind,
        safe_bias=safe_bias,
        outputs=outputs,
        diff_report=diff_report,
        invariant_report=invariant_report
    )
