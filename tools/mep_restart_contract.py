#!/usr/bin/env python3
from __future__ import annotations

from typing import Any, Mapping

CONTRACT_VERSION = "v1"

RESTART_TEXT_FIELDS = [
    "contract_version",
    "status",
    "reason_code",
    "next_action",
    "issue_number",
    "lane",
    "source_phase",
    "source_workflow",
    "source_run_id",
    "source_run_url",
    "source_pr_url",
    "packet_path",
    "artifact_dir",
    "restart_packet_path",
    "generated_at_utc",
]


def _string(value: Any) -> str:
    if value is None:
        return ""
    return str(value).strip()


def normalize_restart_record(record: Mapping[str, Any]) -> dict[str, str]:
    normalized = {field: _string(record.get(field)) for field in RESTART_TEXT_FIELDS}
    if not normalized["contract_version"]:
        normalized["contract_version"] = CONTRACT_VERSION
    return normalized


def _require_fields(record: Mapping[str, str], fields: list[str]) -> None:
    missing = [field for field in fields if not record.get(field)]
    if missing:
        raise ValueError(f"missing restart contract field(s): {', '.join(missing)}")


def build_restart_record(
    *,
    issue_number: Any,
    lane: str,
    source_phase: str,
    source_workflow: str,
    source_run_id: Any = "",
    source_run_url: str = "",
    source_pr_url: str = "",
    packet_path: str,
    artifact_dir: str,
    restart_packet_path: str,
    next_action: str,
    reason_code: str,
    status: str = "READY",
    generated_at_utc: str,
) -> dict[str, str]:
    record = normalize_restart_record(
        {
            "contract_version": CONTRACT_VERSION,
            "status": status,
            "reason_code": reason_code,
            "next_action": next_action,
            "issue_number": issue_number,
            "lane": lane,
            "source_phase": source_phase,
            "source_workflow": source_workflow,
            "source_run_id": source_run_id,
            "source_run_url": source_run_url,
            "source_pr_url": source_pr_url,
            "packet_path": packet_path,
            "artifact_dir": artifact_dir,
            "restart_packet_path": restart_packet_path,
            "generated_at_utc": generated_at_utc,
        }
    )
    _require_fields(record, [
        "contract_version",
        "status",
        "reason_code",
        "next_action",
        "issue_number",
        "lane",
        "source_phase",
        "source_workflow",
        "packet_path",
        "artifact_dir",
        "restart_packet_path",
        "generated_at_utc",
    ])
    if record["lane"] not in {"SYSTEM", "BUSINESS"}:
        raise ValueError(f"invalid restart contract lane: {record['lane']}")
    return record


def render_restart_packet_text(record: Mapping[str, Any]) -> str:
    normalized = normalize_restart_record(record)
    lines = ["RESTART_PACKET"]
    for field in RESTART_TEXT_FIELDS:
        lines.append(f"{field.upper()}={normalized[field]}")
    return "\n".join(lines).rstrip() + "\n"


def restart_bridge_from_record(record: Mapping[str, Any], *, include_legacy_aliases: bool = True) -> dict[str, str]:
    normalized = normalize_restart_record(record)
    bridge = dict(normalized)
    bridge["schema"] = "restart_packet_contract"
    if include_legacy_aliases:
        bridge["source_issue_number"] = normalized["issue_number"]
        bridge["source_standalone_run_id"] = normalized["source_run_id"]
        bridge["source_standalone_run_url"] = normalized["source_run_url"]
        bridge["artifact_pr_url"] = normalized["source_pr_url"]
        bridge["restart_packet"] = normalized["restart_packet_path"]
        bridge["bridged_at"] = normalized["generated_at_utc"]
    return bridge


def restart_record_from_bridge(bridge: Mapping[str, Any] | None) -> dict[str, str]:
    if not isinstance(bridge, Mapping):
        return {}
    if bridge.get("contract_version"):
        return normalize_restart_record(bridge)
    issue_number = _string(bridge.get("issue_number") or bridge.get("source_issue_number"))
    if not issue_number:
        return {}
    return normalize_restart_record(
        {
            "contract_version": CONTRACT_VERSION,
            "status": bridge.get("status") or "READY",
            "reason_code": bridge.get("reason_code") or "RESTART_BRIDGE_READY",
            "next_action": bridge.get("next_action") or "DISPATCH_8GATE_ENTRY",
            "issue_number": issue_number,
            "lane": bridge.get("lane") or "",
            "source_phase": bridge.get("source_phase") or "STANDALONE_ARTIFACT",
            "source_workflow": bridge.get("source_workflow") or ".github/workflows/mep_standalone_autoloop_dispatch_v2.yml",
            "source_run_id": bridge.get("source_run_id") or bridge.get("source_standalone_run_id") or "",
            "source_run_url": bridge.get("source_run_url") or bridge.get("source_standalone_run_url") or "",
            "source_pr_url": bridge.get("source_pr_url") or bridge.get("artifact_pr_url") or "",
            "packet_path": bridge.get("packet_path") or "",
            "artifact_dir": bridge.get("artifact_dir") or "",
            "restart_packet_path": bridge.get("restart_packet_path") or bridge.get("restart_packet") or "",
            "generated_at_utc": bridge.get("generated_at_utc") or bridge.get("bridged_at") or "",
        }
    )
