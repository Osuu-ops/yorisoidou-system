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
def header_order_ok(text: str) -> bool:
    order: List[str] = []
    for line in text.splitlines():
        m = re.match(r"^(TITLE|SYSTEM_ID|BUSINESS_ID):\s*", line)
        if m:
            order.append(m.group(1))
            if len(order) >= 3:
                break
    return order[:3] == ["TITLE", "SYSTEM_ID", "BUSINESS_ID"]
def evaluate_invariants(pack_text: str, headers: Dict[str, str]) -> Tuple[str, Optional[str], List[str]]:
    reasons: List[str] = []
    if not header_order_ok(pack_text):
        reasons.append("INV_HEADER_ORDER: header order must be TITLE->SYSTEM_ID->BUSINESS_ID -> STOP_WAIT")
        return ("STOP_WAIT", None, reasons)
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
def compute_safe_bias(meaning_or_strength_changed: List[str], manual_required: List[str]) -> bool:
    # PACK規則：両方空なら TRUE、それ以外 FALSE
    return (len(meaning_or_strength_changed) == 0) and (len(manual_required) == 0)
def render_diff_report(auto_applied: List[str], meaning_or_strength_changed: List[str], manual_required: List[str]) -> str:
    safe = compute_safe_bias(meaning_or_strength_changed, manual_required)
    def sec(name: str, items: List[str]) -> str:
        if not items:
            return f"## {name}\n\n- (empty)\n"
        return "## " + name + "\n\n" + "\n".join([f"- {x}" for x in items]) + "\n"
    out = "# DIFF REPORT\n\n"
    out += sec("AUTO_APPLIED", auto_applied) + "\n"
    out += sec("MEANING_OR_STRENGTH_CHANGED", meaning_or_strength_changed) + "\n"
    out += sec("MANUAL_REQUIRED", manual_required) + "\n"
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
    return {"type": "AUTO_PATCH", "safe_bias": safe_bias, "operations": []}
def render_auto_patch_md(safe_bias: bool) -> str:
    if safe_bias:
        return "# AUTO PATCH\n\n- No changes required (SAFE_BIAS=TRUE)\n"
    return "# AUTO PATCH\n\n- Patch suggestions generated (SAFE_BIAS=FALSE)\n"
def converge(pack_path: Path, out_dir: Path) -> RunResult:
    pack_text = _read_text(pack_path)
    headers = parse_headers(pack_text)
    inv_state, inv_hard_kind, inv_reasons = evaluate_invariants(pack_text, headers)
    auto_applied: List[str] = []
    meaning_or_strength_changed: List[str] = []
    manual_required: List[str] = []
    # PACK: STOP_WAIT / STOP_HARD でも返却物セットは出す。MANUAL_REQUIRED に理由を入れる。
    if inv_state == "STOP_WAIT":
        manual_required.append("MANUAL_REQUIRED: Fix header order/required headers/SYSTEM_ID mismatch.")
    if inv_state == "STOP_HARD" and inv_hard_kind == "FATAL":
        manual_required.append("MANUAL_REQUIRED: Fix BUSINESS_ID format (NONE or BIZ-...).")
    safe_bias = compute_safe_bias(meaning_or_strength_changed, manual_required)
    # PACK運用：SAFE_BIASがFALSEなら STOP_WAIT（RUNNINGでも落とす）
    final_state = inv_state
    final_hard_kind = inv_hard_kind
    if inv_state == "RUNNING" and safe_bias:
        final_state = "DONE"
        final_hard_kind = None
    elif inv_state == "RUNNING" and not safe_bias:
        final_state = "STOP_WAIT"
        final_hard_kind = None
        inv_reasons.append("INV_SAFE_BIAS: SAFE_BIAS is FALSE -> STOP_WAIT")
    out_dir.mkdir(parents=True, exist_ok=True)
    resolved_path = out_dir / "resolved_spec.json"
    diff_path = out_dir / "diff_report.md"
    inv_path = out_dir / "invariant_report.md"
    formal_path = out_dir / "formal.md"
    auto_json_path = out_dir / "auto_patch.json"
    auto_md_path = out_dir / "auto_patch.md"
    diff_report = render_diff_report(auto_applied, meaning_or_strength_changed, manual_required)
    invariant_report = render_invariant_report(inv_reasons, final_state, final_hard_kind)
    resolved = {
        "headers": headers,
        "state": final_state,
        "hard_kind": final_hard_kind,
        "safe_bias": safe_bias,
        "auto_applied": auto_applied,
        "meaning_or_strength_changed": meaning_or_strength_changed,
        "manual_required": manual_required,
    }
    _write_text(resolved_path, json.dumps(resolved, ensure_ascii=False, indent=2))
    _write_text(diff_path, diff_report)
    _write_text(inv_path, invariant_report)
    _write_text(formal_path, render_formal_md(pack_text))
    _write_text(auto_json_path, json.dumps(render_auto_patch_json(safe_bias), ensure_ascii=False, indent=2))
    _write_text(auto_md_path, render_auto_patch_md(safe_bias))
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
        hard_kind=final_hard_kind,
        safe_bias=safe_bias,
        outputs=outputs,
        diff_report=diff_report,
        invariant_report=invariant_report,
    )
