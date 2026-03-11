#!/usr/bin/env python3
"""Handoff OS v1 for WORKROOM-backed thread handoff state."""

from __future__ import annotations

import argparse
import json
import os
import re
import secrets
import shutil
import socket
import subprocess
import sys
import traceback
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Set, Tuple

SCHEMA_VERSION = 1
DEFAULT_REPO = "Osuu-ops/yorisoidou-system"
VALID_ACTORS = ("GPT", "CODEX", "HUMAN", "SYSTEM")
VALID_OWNERS = ("GPT", "CODEX", "HUMAN", "MIXED")
VALID_THREAD_MODES = ("FRESH", "HANDOFF", "CONTINUE")
VALID_STATUSES = ("IN_PROGRESS", "HANDOFF_READY", "BLOCKED", "DONE", "ARCHIVED")
VALID_BRANCH_STATUSES = ("OPEN", "SELECTED", "DROPPED", "MERGED", "BLOCKED")
MUTATING_COMMANDS = {
    "start",
    "update",
    "split",
    "select-branch",
    "drop-branch",
    "merge-branch",
    "packet",
    "accept",
    "complete",
    "archive",
    "restore",
    "rebuild",
    "doctor",
}
EVENT_TYPES = {
    "SESSION_STARTED",
    "SESSION_ACCEPTED",
    "STATE_UPDATED",
    "PLAN_SET",
    "TASK_SPLIT",
    "TASK_SELECTED",
    "TASK_DROPPED",
    "BRANCH_CREATED",
    "BRANCH_SELECTED",
    "BRANCH_DROPPED",
    "BRANCH_MERGED",
    "OWNER_CHANGED",
    "PR_OPENED",
    "PR_UPDATED",
    "PR_CLOSED",
    "PR_MERGED",
    "BLOCKER_FOUND",
    "BLOCKER_CLEARED",
    "HANDOFF_OUT_CREATED",
    "HANDOFF_OUT_EMITTED",
    "HANDOFF_IN_ACCEPTED",
    "HANDOFF_REJECTED",
    "WORK_COMPLETED",
    "WORK_CLOSED",
    "WORK_ARCHIVED",
    "WORK_RESTORED",
    "STOP_HARD",
}
GENERAL_UPDATE_EVENT_TYPES = {
    "STATE_UPDATED",
    "PLAN_SET",
    "OWNER_CHANGED",
    "PR_OPENED",
    "PR_UPDATED",
    "PR_CLOSED",
    "PR_MERGED",
    "BLOCKER_FOUND",
    "BLOCKER_CLEARED",
    "STOP_HARD",
}
PACKET_ORDER = [
    "PACKET_VERSION",
    "WORK_ID",
    "HANDOFF_ID",
    "PACKET_SEQUENCE",
    "STATE_VERSION",
    "THREAD_MODE",
    "STATUS",
    "CURRENT_GOAL",
    "CURRENT_STAGE",
    "CURRENT_STATE",
    "NEXT_ACTION",
    "ACTIVE_OWNER",
    "OWNER_SCOPE_GPT",
    "OWNER_SCOPE_CODEX",
    "OWNER_SCOPE_HUMAN",
    "PRIMARY_BRANCH",
    "LIVE_BRANCHES",
    "CLOSED_BRANCHES",
    "FORBIDDEN_ACTIONS",
    "REQUIRED_EVIDENCE",
    "EVIDENCE_LOG",
    "INPUTS",
    "OUTPUT_TARGET",
    "LAST_SAFE_POINT",
    "REPO",
    "REPO_HEAD",
    "PR_NUMBER",
    "ISSUE_NUMBER",
    "PARENT_HANDOFF_ID",
    "LATEST_HANDOFF_ID",
    "LAST_UPDATE_UTC",
    "HANDOFF_NOTE",
]
STALE_LOCK_SECONDS = 1800
MIRROR_FILE_NAMES = {
    "state": ["HANDOFF_LIVE_STATE.json", "HANDOFF_STATE.json"],
    "event_log": ["HANDOFF_EVENT_LOG.jsonl", "HANDOFF_EVENTS.jsonl"],
    "graph": ["HANDOFF_GRAPH.json"],
    "packet": ["HANDOFF_PACKET.txt"],
}


class StopHardError(RuntimeError):
    """Raised when the protocol requires a hard stop."""


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def utc_now_z() -> str:
    return utc_now().replace(microsecond=0).isoformat().replace("+00:00", "Z")


def parse_utc(value: str) -> datetime:
    text = (value or "").strip()
    if not text:
        return datetime(1970, 1, 1, tzinfo=timezone.utc)
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    try:
        parsed = datetime.fromisoformat(text)
    except ValueError:
        return datetime(1970, 1, 1, tzinfo=timezone.utc)
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return parsed.astimezone(timezone.utc)


def stop_hard(message: str) -> None:
    raise StopHardError(message)


def slugify(value: str, fallback: str = "branch") -> str:
    text = re.sub(r"[^A-Za-z0-9]+", "-", (value or "").strip()).strip("-").lower()
    return text or fallback


def dedupe(values: Iterable[Any]) -> List[str]:
    items = []
    seen = set()
    for raw in values or []:
        value = str(raw).strip()
        if not value or value in seen:
            continue
        seen.add(value)
        items.append(value)
    return items


def ensure_string_list(value: Any) -> List[str]:
    if value is None:
        return []
    if isinstance(value, (list, tuple)):
        return dedupe(value)
    text = str(value).strip()
    return [text] if text else []


def ensure_int(value: Any, default: int = 0) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def compact_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def read_text(path: Path, default: str = "") -> str:
    if not path.exists():
        return default
    return path.read_text(encoding="utf-8")


def read_json(path: Path, default: Any) -> Any:
    if not path.exists():
        return default
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        stop_hard("invalid JSON at {0}: {1}".format(path, exc))
    return default


def atomic_write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8", newline="\n") as handle:
        handle.write(text)
    tmp.replace(path)


def atomic_write_json(path: Path, payload: Any) -> None:
    atomic_write_text(path, json.dumps(payload, ensure_ascii=False, indent=2) + "\n")


def append_jsonl(path: Path, rows: Sequence[Dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8", newline="\n") as handle:
        for row in rows:
            handle.write(json.dumps(row, ensure_ascii=False) + "\n")


def git_capture(repo_root: Path, *args: str) -> str:
    try:
        completed = subprocess.run(
            ["git", *args],
            cwd=str(repo_root),
            capture_output=True,
            check=True,
            encoding="utf-8",
            text=True,
        )
    except Exception:
        return ""
    return completed.stdout.strip()


def detect_repo_root(base_dir: Path) -> Path:
    root = git_capture(base_dir, "rev-parse", "--show-toplevel")
    return Path(root) if root else base_dir


def parse_origin_repo(origin: str) -> str:
    text = (origin or "").strip()
    if not text:
        return DEFAULT_REPO
    if text.endswith(".git"):
        text = text[:-4]
    for marker in ("github.com:", "github.com/"):
        if marker in text:
            return text.split(marker, 1)[1]
    if text.count("/") == 1:
        return text
    return DEFAULT_REPO


def normalize_owner_scope(scope: Optional[Dict[str, Any]]) -> Dict[str, str]:
    payload = scope or {}
    result = {"GPT": "", "CODEX": "", "HUMAN": ""}
    for key in result:
        result[key] = str(payload.get(key, "") or "").strip()
    return result


def infer_active_owner(scope: Dict[str, str], current: str = "") -> str:
    owners = [key for key, value in scope.items() if str(value or "").strip()]
    if len(owners) > 1:
        return "MIXED"
    if len(owners) == 1:
        return owners[0]
    return current or ""


def default_owner_scope() -> Dict[str, str]:
    return {"GPT": "", "CODEX": "", "HUMAN": ""}


def build_blank_state(repo_context: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "schema_version": SCHEMA_VERSION,
        "state_version": 0,
        "work_id": "",
        "thread_mode": "FRESH",
        "status": "BLOCKED",
        "current_goal": "",
        "current_stage": "",
        "current_state": "NO_ACTIVE_WORK",
        "next_action": "Run start to create a tracked work item.",
        "active_owner": "",
        "owner_scope": default_owner_scope(),
        "primary_branch": "",
        "live_branches": [],
        "closed_branches": [],
        "forbidden_actions": [],
        "required_evidence": [],
        "evidence_log": [],
        "inputs": [],
        "output_target": [],
        "last_safe_point": "No tracked work has started.",
        "repo": repo_context.get("repo") or DEFAULT_REPO,
        "repo_head": repo_context.get("repo_head") or "",
        "pr_number": 0,
        "issue_number": 0,
        "latest_handoff_id": None,
        "latest_packet_sequence": 0,
        "parent_handoff_id": None,
        "last_update_utc": "",
        "blockers": [],
        "block_reason_code": "NO_ACTIVE_WORK",
        "block_reason_text": "No tracked work has started.",
        "handoff_note": "",
    }


def normalize_state(state: Dict[str, Any], repo_context: Dict[str, Any]) -> Dict[str, Any]:
    result = build_blank_state(repo_context)
    result.update(state or {})
    result["schema_version"] = SCHEMA_VERSION
    result["state_version"] = ensure_int(result.get("state_version"))
    result["thread_mode"] = str(result.get("thread_mode") or "FRESH")
    result["status"] = str(result.get("status") or "BLOCKED")
    result["owner_scope"] = normalize_owner_scope(result.get("owner_scope"))
    result["active_owner"] = str(result.get("active_owner") or "").strip()
    result["primary_branch"] = str(result.get("primary_branch") or "").strip()
    for key in (
        "live_branches",
        "closed_branches",
        "forbidden_actions",
        "required_evidence",
        "evidence_log",
        "inputs",
        "output_target",
        "blockers",
    ):
        result[key] = dedupe(result.get(key) or [])
    result["pr_number"] = ensure_int(result.get("pr_number"))
    result["issue_number"] = ensure_int(result.get("issue_number"))
    result["latest_handoff_id"] = result.get("latest_handoff_id") or None
    result["parent_handoff_id"] = result.get("parent_handoff_id") or None
    result["latest_packet_sequence"] = ensure_int(result.get("latest_packet_sequence"))
    result["repo"] = str(result.get("repo") or repo_context.get("repo") or DEFAULT_REPO)
    result["repo_head"] = str(result.get("repo_head") or repo_context.get("repo_head") or "")
    result["block_reason_code"] = str(result.get("block_reason_code") or "").strip()
    result["block_reason_text"] = str(result.get("block_reason_text") or "").strip()
    if result["status"] != "BLOCKED":
        result["block_reason_code"] = ""
        result["block_reason_text"] = ""
    result["handoff_note"] = str(result.get("handoff_note") or "").strip()
    return result


def normalize_meta(meta: Dict[str, Any], repo_context: Dict[str, Any]) -> Dict[str, Any]:
    result = {
        "schema_version": SCHEMA_VERSION,
        "work_id": str(meta.get("work_id") or "").strip(),
        "created_at_utc": str(meta.get("created_at_utc") or ""),
        "created_by_actor": str(meta.get("created_by_actor") or "SYSTEM"),
        "repo": str(meta.get("repo") or repo_context.get("repo") or DEFAULT_REPO),
        "event_sequence": ensure_int(meta.get("event_sequence")),
        "state_version": ensure_int(meta.get("state_version")),
        "packet_sequence": ensure_int(meta.get("packet_sequence")),
        "txn_sequence": ensure_int(meta.get("txn_sequence")),
        "active": bool(meta.get("active", True)),
        "archived": bool(meta.get("archived", False)),
    }
    return result


def default_graph() -> Dict[str, Any]:
    return {"schema_version": SCHEMA_VERSION, "nodes": [], "edges": []}


def jsonish(value: str, default: Any) -> Any:
    text = (value or "").strip()
    if not text:
        return default
    if text[:1] in ("[", "{"):
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            return default
    return text


def build_packet_note(state: Dict[str, Any]) -> str:
    parts = []
    if state.get("blockers"):
        parts.append("BLOCKERS: " + "; ".join(state["blockers"]))
    if state.get("required_evidence"):
        parts.append("REQUIRED_EVIDENCE: " + "; ".join(state["required_evidence"]))
    if state.get("status") == "BLOCKED" and state.get("block_reason_text"):
        parts.append("BLOCK_REASON: " + state["block_reason_text"])
    if state.get("evidence_log"):
        parts.append("EVIDENCE_LOG: " + "; ".join(state["evidence_log"][-3:]))
    if state.get("forbidden_actions"):
        parts.append("FORBIDDEN: " + "; ".join(state["forbidden_actions"]))
    if not parts:
        return state.get("handoff_note") or "No extra handoff notes."
    return " | ".join(parts)


def packet_lines_from_state(state: Dict[str, Any]) -> List[str]:
    packet = {
        "PACKET_VERSION": 1,
        "WORK_ID": state.get("work_id", ""),
        "HANDOFF_ID": state.get("latest_handoff_id") or "",
        "PACKET_SEQUENCE": ensure_int(state.get("latest_packet_sequence")),
        "STATE_VERSION": ensure_int(state.get("state_version")),
        "THREAD_MODE": state.get("thread_mode", "FRESH"),
        "STATUS": state.get("status", "BLOCKED"),
        "CURRENT_GOAL": state.get("current_goal", ""),
        "CURRENT_STAGE": state.get("current_stage", ""),
        "CURRENT_STATE": state.get("current_state", ""),
        "NEXT_ACTION": state.get("next_action", ""),
        "ACTIVE_OWNER": state.get("active_owner", ""),
        "OWNER_SCOPE_GPT": state.get("owner_scope", {}).get("GPT", ""),
        "OWNER_SCOPE_CODEX": state.get("owner_scope", {}).get("CODEX", ""),
        "OWNER_SCOPE_HUMAN": state.get("owner_scope", {}).get("HUMAN", ""),
        "PRIMARY_BRANCH": state.get("primary_branch", ""),
        "LIVE_BRANCHES": state.get("live_branches", []),
        "CLOSED_BRANCHES": state.get("closed_branches", []),
        "FORBIDDEN_ACTIONS": state.get("forbidden_actions", []),
        "REQUIRED_EVIDENCE": state.get("required_evidence", []),
        "EVIDENCE_LOG": state.get("evidence_log", []),
        "INPUTS": state.get("inputs", []),
        "OUTPUT_TARGET": state.get("output_target", []),
        "LAST_SAFE_POINT": state.get("last_safe_point", ""),
        "REPO": state.get("repo", DEFAULT_REPO),
        "REPO_HEAD": state.get("repo_head", ""),
        "PR_NUMBER": ensure_int(state.get("pr_number")),
        "ISSUE_NUMBER": ensure_int(state.get("issue_number")),
        "PARENT_HANDOFF_ID": state.get("parent_handoff_id") or "",
        "LATEST_HANDOFF_ID": state.get("latest_handoff_id") or "",
        "LAST_UPDATE_UTC": state.get("last_update_utc", ""),
        "HANDOFF_NOTE": build_packet_note(state),
    }
    lines = ["[UNIVERSAL_THREAD_PACKET v1]"]
    for key in PACKET_ORDER:
        value = packet[key]
        if isinstance(value, (list, dict)):
            rendered = compact_json(value)
        else:
            rendered = "" if value is None else str(value)
        lines.append("{0}={1}".format(key, rendered))
    return lines


def parse_packet(text: str) -> Dict[str, Any]:
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    if not lines or lines[0] != "[UNIVERSAL_THREAD_PACKET v1]":
        stop_hard("packet must start with [UNIVERSAL_THREAD_PACKET v1]")
    payload = {}
    for line in lines[1:]:
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        payload[key.strip()] = value.strip()
    missing = [key for key in PACKET_ORDER if key not in payload]
    if missing:
        stop_hard("packet missing keys: {0}".format(", ".join(missing)))
    return {
        "packet_version": ensure_int(payload.get("PACKET_VERSION")),
        "work_id": payload.get("WORK_ID", ""),
        "handoff_id": payload.get("HANDOFF_ID") or None,
        "packet_sequence": ensure_int(payload.get("PACKET_SEQUENCE")),
        "state_version": ensure_int(payload.get("STATE_VERSION")),
        "thread_mode": payload.get("THREAD_MODE", ""),
        "status": payload.get("STATUS", ""),
        "current_goal": payload.get("CURRENT_GOAL", ""),
        "current_stage": payload.get("CURRENT_STAGE", ""),
        "current_state": payload.get("CURRENT_STATE", ""),
        "next_action": payload.get("NEXT_ACTION", ""),
        "active_owner": payload.get("ACTIVE_OWNER", ""),
        "owner_scope": {
            "GPT": payload.get("OWNER_SCOPE_GPT", ""),
            "CODEX": payload.get("OWNER_SCOPE_CODEX", ""),
            "HUMAN": payload.get("OWNER_SCOPE_HUMAN", ""),
        },
        "primary_branch": payload.get("PRIMARY_BRANCH", ""),
        "live_branches": ensure_string_list(jsonish(payload.get("LIVE_BRANCHES", ""), [])),
        "closed_branches": ensure_string_list(jsonish(payload.get("CLOSED_BRANCHES", ""), [])),
        "forbidden_actions": ensure_string_list(jsonish(payload.get("FORBIDDEN_ACTIONS", ""), [])),
        "required_evidence": ensure_string_list(jsonish(payload.get("REQUIRED_EVIDENCE", ""), [])),
        "evidence_log": ensure_string_list(jsonish(payload.get("EVIDENCE_LOG", ""), [])),
        "inputs": ensure_string_list(jsonish(payload.get("INPUTS", ""), [])),
        "output_target": ensure_string_list(jsonish(payload.get("OUTPUT_TARGET", ""), [])),
        "last_safe_point": payload.get("LAST_SAFE_POINT", ""),
        "repo": payload.get("REPO", DEFAULT_REPO),
        "repo_head": payload.get("REPO_HEAD", ""),
        "pr_number": ensure_int(payload.get("PR_NUMBER")),
        "issue_number": ensure_int(payload.get("ISSUE_NUMBER")),
        "parent_handoff_id": payload.get("PARENT_HANDOFF_ID") or None,
        "latest_handoff_id": payload.get("LATEST_HANDOFF_ID") or None,
        "last_update_utc": payload.get("LAST_UPDATE_UTC", ""),
        "handoff_note": payload.get("HANDOFF_NOTE", ""),
    }

class HandoffOS(object):
    def __init__(self, base_dir: Path) -> None:
        self.base_dir = Path(base_dir).resolve()
        self.repo_root = detect_repo_root(self.base_dir)
        self.repo_context = {
            "repo": parse_origin_repo(git_capture(self.repo_root, "remote", "get-url", "origin")),
            "repo_head": git_capture(self.repo_root, "rev-parse", "HEAD") or "",
            "branch_name": git_capture(self.repo_root, "branch", "--show-current") or "main",
        }
        self.workroom_root = self.repo_root / "docs" / "WORKROOM"
        self.work_items_root = self.workroom_root / "WORK_ITEMS"
        self.archive_root = self.workroom_root / "ARCHIVE"
        self.locks_root = self.workroom_root / "LOCKS"
        self.active_index_path = self.workroom_root / "ACTIVE_INDEX.json"
        self.archive_index_path = self.workroom_root / "ARCHIVE_INDEX.json"
        self.control_tower_path = self.workroom_root / "CONTROL_TOWER.md"
        self.mirror_root = self.repo_root / "docs" / "MEP"
        self.ensure_layout()

    def ensure_layout(self) -> None:
        for path in (self.workroom_root, self.work_items_root, self.archive_root, self.locks_root, self.mirror_root):
            path.mkdir(parents=True, exist_ok=True)
        if not self.active_index_path.exists():
            atomic_write_json(self.active_index_path, [])
        if not self.archive_index_path.exists():
            atomic_write_json(self.archive_index_path, [])
        if not self.control_tower_path.exists():
            atomic_write_text(self.control_tower_path, self.blank_control_tower())
        self.write_blank_mirror_if_missing()

    def blank_control_tower(self) -> str:
        return "# CONTROL_TOWER\n\nUpdated: \n\n## ACTIVE WORK\n- none\n\n## DONE NOT ARCHIVED\n- none\n\n## ARCHIVED RECENT\n- none\n"

    def blank_packet_text(self) -> str:
        return "\n".join(packet_lines_from_state(build_blank_state(self.repo_context))) + "\n"

    def blank_state_text(self) -> str:
        return json.dumps(build_blank_state(self.repo_context), ensure_ascii=False, indent=2) + "\n"

    def write_blank_mirror_if_missing(self) -> None:
        blank_state = build_blank_state(self.repo_context)
        blank_graph = default_graph()
        blank_packet = self.blank_packet_text()
        for name in MIRROR_FILE_NAMES["state"]:
            path = self.mirror_root / name
            if not path.exists():
                atomic_write_json(path, blank_state)
        for name in MIRROR_FILE_NAMES["event_log"]:
            path = self.mirror_root / name
            if not path.exists():
                atomic_write_text(path, "")
        for name in MIRROR_FILE_NAMES["graph"]:
            path = self.mirror_root / name
            if not path.exists():
                atomic_write_json(path, blank_graph)
        for name in MIRROR_FILE_NAMES["packet"]:
            path = self.mirror_root / name
            if not path.exists():
                atomic_write_text(path, blank_packet)

    def work_dir(self, work_id: str, archived: bool = False) -> Path:
        root = self.archive_root if archived else self.work_items_root
        return root / work_id

    def meta_path(self, work_dir: Path) -> Path:
        return work_dir / "META.json"

    def state_path(self, work_dir: Path) -> Path:
        return work_dir / "LIVE_STATE.json"

    def graph_path(self, work_dir: Path) -> Path:
        return work_dir / "GRAPH.json"

    def event_log_path(self, work_dir: Path) -> Path:
        return work_dir / "EVENT_LOG.jsonl"

    def packet_path(self, work_dir: Path) -> Path:
        return work_dir / "HANDOFF_PACKET.txt"

    def summary_path(self, work_dir: Path) -> Path:
        return work_dir / "SUMMARY.md"

    def branches_root(self, work_dir: Path) -> Path:
        return work_dir / "BRANCHES"

    def branch_dir(self, work_dir: Path, branch_id: str) -> Path:
        return self.branches_root(work_dir) / branch_id

    def txn_root(self, work_dir: Path) -> Path:
        return work_dir / "TXN"

    def txn_path(self, work_dir: Path, txn_sequence: int) -> Path:
        return self.txn_root(work_dir) / ("txn_{0}.json".format(txn_sequence))

    def lock_path(self, work_id: str) -> Path:
        return self.locks_root / ("{0}.lock".format(work_id))

    def new_work_id(self) -> str:
        stamp = utc_now().strftime("%Y%m%d_%H%M%S")
        return "WORK_{0}_{1}".format(stamp, secrets.token_hex(3))

    def new_session_id(self) -> str:
        stamp = utc_now().strftime("%Y%m%d_%H%M%S")
        return "SESSION_{0}_{1}".format(stamp, secrets.token_hex(3))

    def make_handoff_id(self, work_id: str, packet_sequence: int) -> str:
        return "HANDOFF_{0}_{1}".format(work_id, packet_sequence)

    def make_branch_id(self, slug: str, sequence: int) -> str:
        return "BRANCH_{0}_{1}".format(slugify(slug), sequence)

    def default_meta(self, work_id: str, actor: str) -> Dict[str, Any]:
        return {
            "schema_version": SCHEMA_VERSION,
            "work_id": work_id,
            "created_at_utc": utc_now_z(),
            "created_by_actor": actor,
            "repo": self.repo_context["repo"],
            "event_sequence": 0,
            "state_version": 0,
            "packet_sequence": 0,
            "txn_sequence": 0,
            "active": True,
            "archived": False,
        }

    def ensure_work_skeleton(self, work_dir: Path, meta: Dict[str, Any]) -> None:
        work_dir.mkdir(parents=True, exist_ok=True)
        self.txn_root(work_dir).mkdir(parents=True, exist_ok=True)
        self.branches_root(work_dir).mkdir(parents=True, exist_ok=True)
        if not self.meta_path(work_dir).exists():
            atomic_write_json(self.meta_path(work_dir), normalize_meta(meta, self.repo_context))
        if not self.event_log_path(work_dir).exists():
            atomic_write_text(self.event_log_path(work_dir), "")
        if not self.state_path(work_dir).exists():
            atomic_write_json(self.state_path(work_dir), build_blank_state(self.repo_context))
        if not self.graph_path(work_dir).exists():
            atomic_write_json(self.graph_path(work_dir), default_graph())
        if not self.packet_path(work_dir).exists():
            atomic_write_text(self.packet_path(work_dir), self.blank_packet_text())
        if not self.summary_path(work_dir).exists():
            atomic_write_text(self.summary_path(work_dir), "# SUMMARY\n\n- No work yet.\n")

    def list_work_dirs(self, archived: bool) -> List[Path]:
        root = self.archive_root if archived else self.work_items_root
        if not root.exists():
            return []
        items = [path for path in root.iterdir() if path.is_dir() and path.name.startswith("WORK_")]
        return sorted(items, key=lambda item: item.name)

    def all_work_locations(self) -> Dict[str, Tuple[Path, bool]]:
        mapping = {}
        for archived in (False, True):
            for work_dir in self.list_work_dirs(archived):
                work_id = work_dir.name
                if work_id in mapping:
                    stop_hard("double master detected for {0}".format(work_id))
                mapping[work_id] = (work_dir, archived)
        return mapping

    def find_work(self, work_id: str, allow_archived: bool = True) -> Tuple[Path, bool]:
        locations = self.all_work_locations()
        if work_id not in locations:
            stop_hard("unknown work_id: {0}".format(work_id))
        work_dir, archived = locations[work_id]
        if archived and not allow_archived:
            stop_hard("archived work cannot be updated: {0}".format(work_id))
        return work_dir, archived

    def resolve_single_work(self, work_id: str, allow_archived: bool = False) -> Tuple[Path, bool]:
        if work_id:
            return self.find_work(work_id, allow_archived=allow_archived)
        candidates = []
        for candidate_dir in self.list_work_dirs(False):
            meta = normalize_meta(read_json(self.meta_path(candidate_dir), {}), self.repo_context)
            if meta.get("active"):
                candidates.append((candidate_dir, False))
        if allow_archived and not candidates:
            archived = [(path, True) for path in self.list_work_dirs(True)]
            candidates.extend(archived)
        if len(candidates) != 1:
            stop_hard("work_id is required when the active work is not unique")
        return candidates[0]

    def load_meta(self, work_dir: Path) -> Dict[str, Any]:
        meta = normalize_meta(read_json(self.meta_path(work_dir), {}), self.repo_context)
        if not meta.get("work_id"):
            stop_hard("META.json missing work_id at {0}".format(work_dir))
        return meta

    def load_txns(self, work_dir: Path) -> List[Dict[str, Any]]:
        items = []
        for path in sorted(self.txn_root(work_dir).glob("txn_*.json")):
            payload = read_json(path, {})
            payload["path"] = str(path)
            payload["txn_sequence"] = ensure_int(payload.get("txn_sequence"))
            payload["status"] = str(payload.get("status") or "")
            items.append(payload)
        return items

    def unresolved_txns(self, work_dir: Path) -> List[Dict[str, Any]]:
        return [item for item in self.load_txns(work_dir) if item.get("status") not in ("COMMITTED", "ABORTED")]

    def acquire_lock(self, work_id: str, actor: str, command_name: str) -> Path:
        path = self.lock_path(work_id)
        payload = {
            "schema_version": SCHEMA_VERSION,
            "work_id": work_id,
            "owner_pid": os.getpid(),
            "hostname": socket.gethostname(),
            "actor": actor,
            "command": command_name,
            "started_at_utc": utc_now_z(),
        }
        path.parent.mkdir(parents=True, exist_ok=True)
        try:
            fd = os.open(str(path), os.O_CREAT | os.O_EXCL | os.O_WRONLY)
        except FileExistsError:
            lock_info = read_json(path, {})
            if self.is_stale_lock(lock_info):
                stop_hard("stale lock detected for {0}; run doctor".format(work_id))
            stop_hard("lock conflict on {0}".format(work_id))
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as handle:
            json.dump(payload, handle, ensure_ascii=False, indent=2)
            handle.write("\n")
        return path

    def release_lock(self, work_id: str) -> None:
        path = self.lock_path(work_id)
        if path.exists():
            path.unlink()

    def is_stale_lock(self, payload: Dict[str, Any]) -> bool:
        started = parse_utc(str(payload.get("started_at_utc") or ""))
        return (utc_now() - started) > timedelta(seconds=STALE_LOCK_SECONDS)

    def begin_txn(self, work_dir: Path, meta: Dict[str, Any], actor: str, session_id: str, command_name: str) -> Tuple[int, Path, Dict[str, Any]]:
        pending = self.unresolved_txns(work_dir)
        if pending:
            stop_hard("uncommitted txn exists; run doctor before new mutation")
        txn_sequence = ensure_int(meta.get("txn_sequence")) + 1
        txn_path = self.txn_path(work_dir, txn_sequence)
        payload = {
            "schema_version": SCHEMA_VERSION,
            "txn_sequence": txn_sequence,
            "work_id": meta.get("work_id"),
            "command": command_name,
            "actor": actor,
            "session_id": session_id,
            "status": "PREPARED",
            "prepared_at_utc": utc_now_z(),
            "committed_at_utc": "",
            "aborted_at_utc": "",
            "message": "",
        }
        txn_path.parent.mkdir(parents=True, exist_ok=True)
        atomic_write_json(txn_path, payload)
        return txn_sequence, txn_path, payload

    def finish_txn(self, txn_path: Path, payload: Dict[str, Any], status: str, message: str) -> None:
        payload = dict(payload)
        payload["status"] = status
        payload["message"] = message
        key = "committed_at_utc" if status == "COMMITTED" else "aborted_at_utc"
        payload[key] = utc_now_z()
        atomic_write_json(txn_path, payload)

    def read_all_events(self, work_dir: Path) -> Tuple[List[Dict[str, Any]], List[str]]:
        parsed = []
        raw_lines = []
        for line in read_text(self.event_log_path(work_dir), "").splitlines():
            text = line.strip()
            if not text:
                continue
            try:
                event = json.loads(text)
            except json.JSONDecodeError as exc:
                stop_hard("invalid EVENT_LOG.jsonl at {0}: {1}".format(work_dir, exc))
            parsed.append(event)
            raw_lines.append(text)
        return parsed, raw_lines

    def visible_events(
        self,
        work_dir: Path,
        meta: Dict[str, Any],
        target_event_sequence: Optional[int] = None,
        allowed_txn_sequences: Optional[Set[int]] = None,
    ) -> Tuple[List[Dict[str, Any]], List[str]]:
        allowed = allowed_txn_sequences or set()
        events, raw_lines = self.read_all_events(work_dir)
        visible_max = ensure_int(target_event_sequence if target_event_sequence is not None else meta.get("event_sequence"))
        txn_status = {ensure_int(item.get("txn_sequence")): item.get("status") for item in self.load_txns(work_dir)}
        visible_events = []
        visible_lines = []
        expected = 1
        last_seen = 0
        for event, raw in zip(events, raw_lines):
            sequence = ensure_int(event.get("event_sequence"))
            if sequence <= last_seen:
                stop_hard("EVENT_SEQUENCE is not strictly increasing for {0}".format(meta.get("work_id")))
            last_seen = sequence
            if sequence > visible_max:
                continue
            txn_sequence = ensure_int(event.get("txn_sequence"))
            if txn_status.get(txn_sequence) != "COMMITTED" and txn_sequence not in allowed:
                stop_hard("visible event references uncommitted txn for {0}".format(meta.get("work_id")))
            if sequence != expected:
                stop_hard("committed EVENT_SEQUENCE has a gap for {0}".format(meta.get("work_id")))
            expected += 1
            visible_events.append(event)
            visible_lines.append(raw)
        if visible_max != 0 and (expected - 1) != visible_max:
            stop_hard("META.event_sequence does not match visible events for {0}".format(meta.get("work_id")))
        return visible_events, visible_lines

    def merge_owner_scope(self, current: Dict[str, str], updates: Dict[str, Any]) -> Dict[str, str]:
        result = normalize_owner_scope(current)
        for key in ("GPT", "CODEX", "HUMAN"):
            if key in updates and updates[key] is not None:
                result[key] = str(updates[key]).strip()
        return result

    def merge_state_patch(self, state: Dict[str, Any], patch: Dict[str, Any]) -> Dict[str, Any]:
        merged = dict(state)
        for key, value in (patch or {}).items():
            if key == "owner_scope":
                merged[key] = self.merge_owner_scope(state.get("owner_scope", {}), value or {})
            elif key in (
                "live_branches",
                "closed_branches",
                "forbidden_actions",
                "required_evidence",
                "evidence_log",
                "inputs",
                "output_target",
                "blockers",
            ):
                merged[key] = dedupe(value or [])
            elif key in ("pr_number", "issue_number", "latest_packet_sequence", "state_version"):
                merged[key] = ensure_int(value)
            else:
                merged[key] = value
        merged = normalize_state(merged, self.repo_context)
        if not merged.get("active_owner"):
            merged["active_owner"] = infer_active_owner(merged.get("owner_scope", {}), merged.get("active_owner", ""))
        return merged

    def add_graph_node(self, node_map: Dict[Tuple[str, str], Dict[str, Any]], node_id: str, kind: str, **extra: Any) -> None:
        if not node_id:
            return
        key = (kind, node_id)
        payload = dict(node_map.get(key, {"id": node_id, "kind": kind}))
        for item_key, item_value in extra.items():
            if item_value not in (None, "", [], {}):
                payload[item_key] = item_value
        node_map[key] = payload

    def add_graph_edge(self, edge_map: Dict[str, Dict[str, Any]], source: str, target: str, edge_type: str, **extra: Any) -> None:
        if not source or not target:
            return
        payload = {"from": source, "to": target, "type": edge_type}
        for item_key, item_value in extra.items():
            if item_value not in (None, "", [], {}):
                payload[item_key] = item_value
        edge_map[compact_json(payload)] = payload

    def derive_snapshot(
        self,
        work_dir: Path,
        meta: Dict[str, Any],
        target_state_version: int,
        target_packet_sequence: int,
        target_event_sequence: Optional[int] = None,
        allowed_txn_sequences: Optional[Set[int]] = None,
        status_override: Optional[str] = None,
        meta_override: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        effective_meta = normalize_meta(meta_override or meta, self.repo_context)
        visible_events, visible_lines = self.visible_events(
            work_dir,
            meta,
            target_event_sequence=target_event_sequence,
            allowed_txn_sequences=allowed_txn_sequences,
        )
        state = build_blank_state(self.repo_context)
        state["work_id"] = effective_meta.get("work_id", "")
        state["repo"] = effective_meta.get("repo") or self.repo_context["repo"]
        state["repo_head"] = self.repo_context.get("repo_head", "")
        node_map = {}
        edge_map = {}
        branches = {}
        sessions = set()
        accepted_handoffs = set()
        latest_session_id = ""
        archived_at_utc = ""
        self.add_graph_node(node_map, effective_meta.get("work_id"), "work")

        for event in visible_events:
            event_type = str(event.get("event_type") or "")
            if event_type not in EVENT_TYPES:
                stop_hard("unknown event_type: {0}".format(event_type))
            sequence = ensure_int(event.get("event_sequence"))
            session_id = str(event.get("session_id") or "")
            actor = str(event.get("actor") or "")
            payload = event.get("payload") or {}
            state_patch = payload.get("state_patch") or {}
            branch_id = str(event.get("branch_id") or payload.get("branch_id") or "")
            handoff_id = str(event.get("handoff_id") or payload.get("handoff_id") or "")
            ts_utc = str(event.get("ts_utc") or "")
            latest_session_id = session_id or latest_session_id
            state = self.merge_state_patch(state, state_patch)
            state["work_id"] = effective_meta.get("work_id")
            state["last_update_utc"] = ts_utc
            if state_patch.get("repo_head"):
                state["repo_head"] = state_patch.get("repo_head")
            self.add_graph_node(node_map, effective_meta.get("work_id"), "work")

            if event_type in ("SESSION_STARTED", "SESSION_ACCEPTED") and session_id:
                sessions.add(session_id)
                self.add_graph_node(node_map, session_id, "session", actor=actor)
                self.add_graph_edge(edge_map, effective_meta.get("work_id"), session_id, "started")

            if branch_id:
                branches.setdefault(branch_id, {
                    "branch_id": branch_id,
                    "status": "OPEN",
                    "owner": actor,
                    "purpose": str(payload.get("purpose") or payload.get("branch_name") or branch_id),
                    "last_update_utc": ts_utc,
                    "next_action": state.get("next_action", ""),
                    "blocker": "; ".join(state.get("blockers", [])),
                    "label": str(payload.get("branch_name") or branch_id),
                })
                self.add_graph_node(node_map, branch_id, "branch", owner=actor)
                if session_id:
                    self.add_graph_edge(edge_map, session_id, branch_id, "owns")

            if event_type == "TASK_SPLIT":
                parent_branch_id = str(payload.get("parent_branch_id") or state.get("primary_branch") or "")
                if branch_id:
                    branches.setdefault(branch_id, {})
                    branches[branch_id]["status"] = "OPEN"
                    branches[branch_id]["owner"] = actor
                    branches[branch_id]["purpose"] = str(payload.get("purpose") or branches[branch_id].get("purpose") or branch_id)
                    branches[branch_id]["last_update_utc"] = ts_utc
                    self.add_graph_edge(edge_map, parent_branch_id, branch_id, "branched_to")
            elif event_type == "BRANCH_CREATED":
                if branch_id:
                    branch = branches.setdefault(branch_id, {})
                    branch["status"] = str(payload.get("branch_status") or "OPEN")
                    branch["owner"] = actor
                    branch["purpose"] = str(payload.get("purpose") or branch.get("purpose") or branch_id)
                    branch["last_update_utc"] = ts_utc
                    branch["next_action"] = state.get("next_action", "")
            elif event_type == "BRANCH_SELECTED":
                if branch_id:
                    branch = branches.setdefault(branch_id, {})
                    branch["status"] = "SELECTED"
                    branch["last_update_utc"] = ts_utc
                    self.add_graph_edge(edge_map, effective_meta.get("work_id"), branch_id, "selected")
            elif event_type == "BRANCH_DROPPED":
                if branch_id:
                    branch = branches.setdefault(branch_id, {})
                    branch["status"] = "DROPPED"
                    branch["last_update_utc"] = ts_utc
                    self.add_graph_edge(edge_map, effective_meta.get("work_id"), branch_id, "dropped")
            elif event_type == "BRANCH_MERGED":
                target_branch = str(payload.get("target_branch_id") or state.get("primary_branch") or "")
                if branch_id:
                    branch = branches.setdefault(branch_id, {})
                    branch["status"] = "MERGED"
                    branch["last_update_utc"] = ts_utc
                    self.add_graph_edge(edge_map, branch_id, target_branch, "merged_back")
            elif event_type == "OWNER_CHANGED":
                state["active_owner"] = str(payload.get("active_owner") or state.get("active_owner") or "")
            elif event_type == "HANDOFF_OUT_CREATED":
                if handoff_id:
                    self.add_graph_node(node_map, handoff_id, "handoff", actor=actor)
                    self.add_graph_edge(edge_map, session_id, handoff_id, "emitted")
            elif event_type == "HANDOFF_IN_ACCEPTED":
                if handoff_id:
                    accepted_handoffs.add(handoff_id)
                    self.add_graph_node(node_map, handoff_id, "handoff", actor=payload.get("from_actor") or actor)
                    self.add_graph_edge(edge_map, handoff_id, session_id, "accepted_by")
            elif event_type == "HANDOFF_REJECTED":
                if handoff_id:
                    self.add_graph_node(node_map, handoff_id, "handoff", actor=actor)
            elif event_type == "PR_OPENED" or event_type == "PR_UPDATED" or event_type == "PR_CLOSED" or event_type == "PR_MERGED":
                pr_number = ensure_int(payload.get("pr_number") or state.get("pr_number"))
                if pr_number > 0:
                    pr_id = "PR_{0}".format(pr_number)
                    self.add_graph_node(node_map, pr_id, "pr", number=pr_number)
                    self.add_graph_edge(edge_map, effective_meta.get("work_id"), pr_id, "owns")
            elif event_type == "WORK_ARCHIVED":
                archive_node = "ARCHIVE_{0}".format(effective_meta.get("work_id"))
                archived_at_utc = ts_utc
                self.add_graph_node(node_map, archive_node, "archive", archived_at_utc=ts_utc)
                self.add_graph_edge(edge_map, effective_meta.get("work_id"), archive_node, "archived_to")

            if branch_id and branch_id in branches:
                branches[branch_id]["next_action"] = state.get("next_action", "")
                branches[branch_id]["blocker"] = "; ".join(state.get("blockers", []))
                branches[branch_id]["last_update_utc"] = ts_utc

        if status_override:
            state["status"] = status_override
        if effective_meta.get("archived"):
            state["status"] = "ARCHIVED"
        state["state_version"] = ensure_int(target_state_version)
        state["latest_packet_sequence"] = ensure_int(target_packet_sequence)
        state["owner_scope"] = normalize_owner_scope(state.get("owner_scope"))
        if not state.get("active_owner"):
            state["active_owner"] = infer_active_owner(state.get("owner_scope"), state.get("active_owner", ""))
        if not state.get("handoff_note"):
            state["handoff_note"] = build_packet_note(state)
        graph = {
            "schema_version": SCHEMA_VERSION,
            "nodes": sorted(node_map.values(), key=lambda item: (item.get("kind", ""), item.get("id", ""))),
            "edges": sorted(edge_map.values(), key=lambda item: (item.get("from", ""), item.get("to", ""), item.get("type", ""))),
        }
        packet_text = "\n".join(packet_lines_from_state(state)) + "\n"
        summary_text = self.build_summary(state, branches, archived_at_utc)
        return {
            "meta": effective_meta,
            "state": normalize_state(state, self.repo_context),
            "graph": graph,
            "packet_text": packet_text,
            "summary_text": summary_text,
            "branches": branches,
            "visible_events": visible_events,
            "visible_event_lines": visible_lines,
            "accepted_handoffs": accepted_handoffs,
            "latest_session_id": latest_session_id,
            "archived_at_utc": archived_at_utc,
        }

    def build_summary(self, state: Dict[str, Any], branches: Dict[str, Dict[str, Any]], archived_at_utc: str) -> str:
        lines = [
            "# SUMMARY",
            "",
            "- WORK_ID: {0}".format(state.get("work_id", "")),
            "- STATUS: {0}".format(state.get("status", "")),
            "- THREAD_MODE: {0}".format(state.get("thread_mode", "")),
            "- ACTIVE_OWNER: {0}".format(state.get("active_owner", "")),
            "- CURRENT_GOAL: {0}".format(state.get("current_goal", "")),
            "- CURRENT_STAGE: {0}".format(state.get("current_stage", "")),
            "- CURRENT_STATE: {0}".format(state.get("current_state", "")),
            "- NEXT_ACTION: {0}".format(state.get("next_action", "")),
            "- PRIMARY_BRANCH: {0}".format(state.get("primary_branch", "")),
            "- LIVE_BRANCHES: {0}".format(", ".join(state.get("live_branches", [])) or "none"),
            "- CLOSED_BRANCHES: {0}".format(", ".join(state.get("closed_branches", [])) or "none"),
            "- BLOCKERS: {0}".format("; ".join(state.get("blockers", [])) or "none"),
            "- LATEST_HANDOFF_ID: {0}".format(state.get("latest_handoff_id") or ""),
            "- LAST_SAFE_POINT: {0}".format(state.get("last_safe_point", "")),
        ]
        if archived_at_utc:
            lines.append("- ARCHIVED_AT_UTC: {0}".format(archived_at_utc))
        lines.extend(["", "## Branches"])
        if not branches:
            lines.append("- none")
        else:
            for branch_id in sorted(branches):
                branch = branches[branch_id]
                lines.append(
                    "- {0}: {1} | owner={2} | next={3}".format(
                        branch_id,
                        branch.get("status", ""),
                        branch.get("owner", ""),
                        branch.get("next_action", ""),
                    )
                )
        return "\n".join(lines) + "\n"

    def write_branch_artifacts(self, work_dir: Path, branches: Dict[str, Dict[str, Any]]) -> None:
        branches_root = self.branches_root(work_dir)
        branches_root.mkdir(parents=True, exist_ok=True)
        existing = [path for path in branches_root.iterdir() if path.is_dir()]
        branch_ids = set(branches.keys())
        for stale in existing:
            if stale.name not in branch_ids:
                shutil.rmtree(str(stale))
        for branch_id, branch in branches.items():
            branch_dir = self.branch_dir(work_dir, branch_id)
            branch_dir.mkdir(parents=True, exist_ok=True)
            owner_md = "\n".join([
                "WORK_ID: {0}".format(work_dir.name),
                "BRANCH_ID: {0}".format(branch_id),
                "OWNER: {0}".format(branch.get("owner", "")),
                "PURPOSE: {0}".format(branch.get("purpose", "")),
                "STATUS: {0}".format(branch.get("status", "")),
                "LAST_UPDATE: {0}".format(branch.get("last_update_utc", "")),
                "NEXT_ACTION: {0}".format(branch.get("next_action", "")),
                "BLOCKER: {0}".format(branch.get("blocker", "")),
                "",
            ])
            status_json = {
                "branch_id": branch_id,
                "status": branch.get("status", "OPEN"),
                "owner": branch.get("owner", ""),
                "last_update_utc": branch.get("last_update_utc", ""),
                "label": branch.get("label", branch_id),
            }
            notes_md = "# NOTES\n\n- PURPOSE: {0}\n- STATUS: {1}\n- NEXT_ACTION: {2}\n".format(
                branch.get("purpose", ""), branch.get("status", ""), branch.get("next_action", "")
            )
            atomic_write_text(branch_dir / "OWNER.md", owner_md)
            atomic_write_json(branch_dir / "STATUS.json", status_json)
            atomic_write_text(branch_dir / "NOTES.md", notes_md)

    def write_snapshot(self, work_dir: Path, snapshot: Dict[str, Any]) -> None:
        work_dir.mkdir(parents=True, exist_ok=True)
        self.txn_root(work_dir).mkdir(parents=True, exist_ok=True)
        self.branches_root(work_dir).mkdir(parents=True, exist_ok=True)
        atomic_write_json(self.state_path(work_dir), snapshot["state"])
        atomic_write_json(self.graph_path(work_dir), snapshot["graph"])
        atomic_write_text(self.packet_path(work_dir), snapshot["packet_text"])
        atomic_write_text(self.summary_path(work_dir), snapshot["summary_text"])
        self.write_branch_artifacts(work_dir, snapshot["branches"])

    def validate_owner_consistency(self, state: Dict[str, Any]) -> Optional[str]:
        scope = normalize_owner_scope(state.get("owner_scope"))
        active_owner = state.get("active_owner", "")
        owners = [actor for actor, value in scope.items() if value]
        if active_owner == "MIXED" and len(owners) < 2:
            return "active_owner=MIXED but owner_scope is not mixed"
        if active_owner in VALID_ACTORS and active_owner not in owners:
            return "active_owner is not represented in owner_scope"
        if active_owner not in VALID_OWNERS and active_owner != "":
            return "active_owner is invalid"
        return None

    def validate_work_snapshot(
        self,
        work_dir: Path,
        meta: Dict[str, Any],
        snapshot: Dict[str, Any],
        require_committed_txn: bool,
        check_files: bool,
    ) -> None:
        state = snapshot["state"]
        if meta.get("active") and meta.get("archived"):
            stop_hard("META active/archived conflict for {0}".format(meta.get("work_id")))
        if work_dir.parent == self.archive_root and not meta.get("archived"):
            stop_hard("archived location has non-archived META for {0}".format(meta.get("work_id")))
        if work_dir.parent == self.work_items_root and meta.get("archived"):
            stop_hard("active location has archived META for {0}".format(meta.get("work_id")))
        if require_committed_txn and self.unresolved_txns(work_dir):
            stop_hard("doctor required: unresolved txn remains for {0}".format(meta.get("work_id")))
        if state.get("status") not in ("DONE", "ARCHIVED"):
            if not state.get("current_goal"):
                stop_hard("current_goal is empty for {0}".format(meta.get("work_id")))
            if not state.get("next_action"):
                stop_hard("next_action is empty for {0}".format(meta.get("work_id")))
        if state.get("primary_branch"):
            if state["primary_branch"] not in state.get("live_branches", []):
                stop_hard("primary_branch is not live for {0}".format(meta.get("work_id")))
            if state["primary_branch"] in state.get("closed_branches", []):
                stop_hard("primary_branch is closed for {0}".format(meta.get("work_id")))
        elif state.get("status") not in ("DONE", "ARCHIVED"):
            stop_hard("primary_branch is missing for {0}".format(meta.get("work_id")))
        owner_error = self.validate_owner_consistency(state)
        if owner_error:
            stop_hard("{0}: {1}".format(meta.get("work_id"), owner_error))
        if state.get("status") == "HANDOFF_READY":
            if not self.packet_path(work_dir).exists():
                stop_hard("handoff packet missing for {0}".format(meta.get("work_id")))
            packet = parse_packet(read_text(self.packet_path(work_dir)))
            if packet.get("packet_sequence") != state.get("latest_packet_sequence"):
                stop_hard("packet sequence mismatch for {0}".format(meta.get("work_id")))
            if packet.get("handoff_id") != state.get("latest_handoff_id"):
                stop_hard("latest handoff mismatch for {0}".format(meta.get("work_id")))
        if state.get("status") == "BLOCKED":
            if not state.get("block_reason_code") or not state.get("block_reason_text"):
                stop_hard("BLOCKED state requires block_reason_code/text for {0}".format(meta.get("work_id")))
            if state.get("block_reason_code") == "RESTORE_REQUIRES_PACKET_REISSUE":
                if state.get("latest_handoff_id") is not None:
                    stop_hard("restored work must invalidate latest_handoff_id for {0}".format(meta.get("work_id")))
                packet = parse_packet(read_text(self.packet_path(work_dir)))
                if packet.get("handoff_id"):
                    stop_hard("restored work packet must not carry an active handoff for {0}".format(meta.get("work_id")))
        if state.get("status") in ("DONE", "ARCHIVED"):
            missing = [item for item in state.get("required_evidence", []) if item not in state.get("evidence_log", [])]
            if missing:
                stop_hard("required_evidence is incomplete for {0}".format(meta.get("work_id")))
        if check_files:
            stored_state = normalize_state(read_json(self.state_path(work_dir), {}), self.repo_context)
            stored_graph = read_json(self.graph_path(work_dir), {})
            if stored_state.get("status") == "BLOCKED":
                if not stored_state.get("block_reason_code") or not stored_state.get("block_reason_text"):
                    stop_hard("BLOCKED state requires block_reason_code/text for {0}".format(meta.get("work_id")))
            if stored_state != state:
                stop_hard("LIVE_STATE mismatch for {0}".format(meta.get("work_id")))
            if stored_graph != snapshot["graph"]:
                stop_hard("GRAPH mismatch for {0}".format(meta.get("work_id")))
            if read_text(self.packet_path(work_dir)) != snapshot["packet_text"]:
                stop_hard("HANDOFF_PACKET mismatch for {0}".format(meta.get("work_id")))

    def snapshot_for_existing_work(self, work_dir: Path) -> Dict[str, Any]:
        meta = self.load_meta(work_dir)
        return self.derive_snapshot(
            work_dir,
            meta,
            target_state_version=ensure_int(meta.get("state_version")),
            target_packet_sequence=ensure_int(meta.get("packet_sequence")),
        )

    def build_active_index(self, snapshots: Dict[str, Dict[str, Any]]) -> List[Dict[str, Any]]:
        rows = []
        for work_id in sorted(snapshots):
            snapshot = snapshots[work_id]
            meta = snapshot["meta"]
            state = snapshot["state"]
            if not meta.get("active") or meta.get("archived"):
                continue
            rows.append({
                "work_id": work_id,
                "status": state.get("status", ""),
                "primary_branch": state.get("primary_branch", ""),
                "active_owner": state.get("active_owner", ""),
                "next_action": state.get("next_action", ""),
                "packet_path": str(self.packet_path(self.work_dir(work_id))),
                "last_update_utc": state.get("last_update_utc", ""),
            })
        return rows

    def build_archive_index(self, snapshots: Dict[str, Dict[str, Any]]) -> List[Dict[str, Any]]:
        rows = []
        for work_id in sorted(snapshots):
            snapshot = snapshots[work_id]
            meta = snapshot["meta"]
            state = snapshot["state"]
            if not meta.get("archived"):
                continue
            archived_at = snapshot.get("archived_at_utc") or state.get("last_update_utc", "")
            rows.append({
                "work_id": work_id,
                "archived_at_utc": archived_at,
                "archive_path": str(self.work_dir(work_id, archived=True)),
                "last_handoff_id": state.get("latest_handoff_id") or "",
                "last_safe_point": state.get("last_safe_point", ""),
            })
        return rows

    def build_control_tower(self, active_rows: List[Dict[str, Any]], archive_rows: List[Dict[str, Any]], snapshots: Dict[str, Dict[str, Any]]) -> str:
        def section(title: str, lines: List[str]) -> List[str]:
            return ["## {0}".format(title)] + (lines or ["- none"]) + [""]

        active_lines = []
        done_lines = []
        for row in active_rows:
            work_id = row["work_id"]
            snapshot = snapshots[work_id]
            state = snapshot["state"]
            blocker_text = "; ".join(state.get("blockers", [])) or "none"
            handoff_text = state.get("latest_handoff_id") or "none"
            line = "- {0} | status={1} | branch={2} | owner={3} | next={4} | blockers={5} | handoff={6}".format(
                work_id,
                row["status"],
                row["primary_branch"] or "none",
                row["active_owner"] or "none",
                row["next_action"] or "none",
                blocker_text,
                handoff_text if row["status"] == "HANDOFF_READY" else "none",
            )
            if row["status"] == "DONE":
                done_lines.append(line)
            else:
                active_lines.append(line)
        archive_sorted = sorted(archive_rows, key=lambda item: parse_utc(item.get("archived_at_utc", "")), reverse=True)[:5]
        archive_lines = [
            "- {0} | archived_at={1} | last_handoff={2} | safe_point={3}".format(
                item["work_id"],
                item.get("archived_at_utc", ""),
                item.get("last_handoff_id", "") or "none",
                item.get("last_safe_point", "") or "none",
            )
            for item in archive_sorted
        ]
        update_candidates = [snapshot["state"].get("last_update_utc", "") for snapshot in snapshots.values()]
        tower_updated = max(update_candidates, key=parse_utc) if update_candidates else ""
        lines = ["# CONTROL_TOWER", "", "Updated: {0}".format(tower_updated), ""]
        for title, content in (("ACTIVE WORK", active_lines), ("DONE NOT ARCHIVED", done_lines), ("ARCHIVED RECENT", archive_lines)):
            lines.extend(section(title, content))
        return "\n".join(lines).rstrip() + "\n"

    def preferred_mirror_work(self, snapshots: Dict[str, Dict[str, Any]]) -> Optional[str]:
        rows = []
        for work_id, snapshot in snapshots.items():
            meta = snapshot["meta"]
            state = snapshot["state"]
            rank = 3
            if meta.get("active") and not meta.get("archived") and state.get("status") == "HANDOFF_READY":
                rank = 0
            elif meta.get("active") and not meta.get("archived"):
                rank = 1
            elif meta.get("archived"):
                rank = 2
            rows.append((rank, parse_utc(state.get("last_update_utc", "")), work_id))
        if not rows:
            return None
        rows.sort(key=lambda item: (item[0], -item[1].timestamp(), item[2]))
        return rows[0][2]

    def write_mirror_outputs(self, snapshots: Dict[str, Dict[str, Any]]) -> None:
        preferred = self.preferred_mirror_work(snapshots)
        if preferred is None:
            self.write_blank_mirror_if_missing()
            blank_state = build_blank_state(self.repo_context)
            blank_graph = default_graph()
            blank_packet = self.blank_packet_text()
            for name in MIRROR_FILE_NAMES["state"]:
                atomic_write_json(self.mirror_root / name, blank_state)
            for name in MIRROR_FILE_NAMES["event_log"]:
                atomic_write_text(self.mirror_root / name, "")
            for name in MIRROR_FILE_NAMES["graph"]:
                atomic_write_json(self.mirror_root / name, blank_graph)
            for name in MIRROR_FILE_NAMES["packet"]:
                atomic_write_text(self.mirror_root / name, blank_packet)
            return
        snapshot = snapshots[preferred]
        for name in MIRROR_FILE_NAMES["state"]:
            atomic_write_json(self.mirror_root / name, snapshot["state"])
        event_text = "\n".join(snapshot["visible_event_lines"]) + ("\n" if snapshot["visible_event_lines"] else "")
        for name in MIRROR_FILE_NAMES["event_log"]:
            atomic_write_text(self.mirror_root / name, event_text)
        for name in MIRROR_FILE_NAMES["graph"]:
            atomic_write_json(self.mirror_root / name, snapshot["graph"])
        for name in MIRROR_FILE_NAMES["packet"]:
            atomic_write_text(self.mirror_root / name, snapshot["packet_text"])

    def rebuild_global_outputs(self, override_snapshots: Optional[Dict[str, Dict[str, Any]]] = None) -> Dict[str, Dict[str, Any]]:
        snapshots = {}
        for work_id, (work_dir, _) in self.all_work_locations().items():
            snapshots[work_id] = self.snapshot_for_existing_work(work_dir)
        for work_id, snapshot in (override_snapshots or {}).items():
            snapshots[work_id] = snapshot
        active_rows = self.build_active_index(snapshots)
        archive_rows = self.build_archive_index(snapshots)
        atomic_write_json(self.active_index_path, active_rows)
        atomic_write_json(self.archive_index_path, archive_rows)
        atomic_write_text(self.control_tower_path, self.build_control_tower(active_rows, archive_rows, snapshots))
        self.write_mirror_outputs(snapshots)
        return snapshots

    def make_event(
        self,
        meta: Dict[str, Any],
        event_sequence: int,
        txn_sequence: int,
        session_id: str,
        actor: str,
        event_type: str,
        payload: Dict[str, Any],
        handoff_id: Optional[str] = None,
        branch_id: Optional[str] = None,
    ) -> Dict[str, Any]:
        if event_type not in EVENT_TYPES:
            stop_hard("unsupported event_type: {0}".format(event_type))
        return {
            "schema_version": SCHEMA_VERSION,
            "event_sequence": event_sequence,
            "ts_utc": utc_now_z(),
            "event_type": event_type,
            "work_id": meta.get("work_id"),
            "session_id": session_id,
            "actor": actor,
            "handoff_id": handoff_id,
            "branch_id": branch_id,
            "txn_sequence": txn_sequence,
            "payload": payload or {},
        }

    def repo_head(self) -> str:
        return self.repo_context.get("repo_head") or git_capture(self.repo_root, "rev-parse", "HEAD") or ""

    def resolve_packet_text(self, packet_path: str, packet_text: str) -> str:
        if packet_text:
            return packet_text
        path = Path(packet_path) if packet_path else None
        if path is None:
            stop_hard("packet_path or packet_text is required")
        if not path.is_absolute():
            path = (self.repo_root / path).resolve()
        if not path.exists():
            stop_hard("packet file not found: {0}".format(path))
        return path.read_text(encoding="utf-8")

    def state_patch_from_args(
        self,
        current: Dict[str, Any],
        args: argparse.Namespace,
        status: Optional[str] = None,
        thread_mode: Optional[str] = None,
        latest_handoff_id: Optional[str] = None,
        latest_packet_sequence: Optional[int] = None,
        parent_handoff_id: Optional[str] = None,
    ) -> Dict[str, Any]:
        patch = dict(current)
        if args.current_goal:
            patch["current_goal"] = args.current_goal
        if args.current_stage:
            patch["current_stage"] = args.current_stage
        if args.current_state:
            patch["current_state"] = args.current_state
        if args.next_action:
            patch["next_action"] = args.next_action
        if args.last_safe_point:
            patch["last_safe_point"] = args.last_safe_point
        if args.active_owner:
            patch["active_owner"] = args.active_owner
        owner_scope = normalize_owner_scope(patch.get("owner_scope"))
        if args.owner_scope_gpt is not None:
            owner_scope["GPT"] = args.owner_scope_gpt
        if args.owner_scope_codex is not None:
            owner_scope["CODEX"] = args.owner_scope_codex
        if args.owner_scope_human is not None:
            owner_scope["HUMAN"] = args.owner_scope_human
        patch["owner_scope"] = owner_scope
        if args.primary_branch:
            patch["primary_branch"] = args.primary_branch
        if args.live_branches:
            patch["live_branches"] = dedupe(patch.get("live_branches", []) + list(args.live_branches))
        if args.closed_branches:
            patch["closed_branches"] = dedupe(patch.get("closed_branches", []) + list(args.closed_branches))
        if args.forbidden_actions:
            patch["forbidden_actions"] = dedupe(patch.get("forbidden_actions", []) + list(args.forbidden_actions))
        if args.required_evidence:
            patch["required_evidence"] = dedupe(patch.get("required_evidence", []) + list(args.required_evidence))
        if args.evidence_log:
            patch["evidence_log"] = dedupe(patch.get("evidence_log", []) + list(args.evidence_log))
        if args.inputs:
            patch["inputs"] = dedupe(patch.get("inputs", []) + list(args.inputs))
        if args.output_target:
            patch["output_target"] = dedupe(patch.get("output_target", []) + list(args.output_target))
        if args.clear_blockers:
            patch["blockers"] = []
        if args.blockers:
            patch["blockers"] = dedupe(patch.get("blockers", []) + list(args.blockers))
        if args.pr_number > 0:
            patch["pr_number"] = args.pr_number
        if args.issue_number > 0:
            patch["issue_number"] = args.issue_number
        if args.handoff_note:
            patch["handoff_note"] = args.handoff_note
        if hasattr(args, "block_reason_code") and args.block_reason_code is not None:
            patch["block_reason_code"] = args.block_reason_code
        if hasattr(args, "block_reason_text") and args.block_reason_text is not None:
            patch["block_reason_text"] = args.block_reason_text
        if status is not None:
            patch["status"] = status
        if thread_mode is not None:
            patch["thread_mode"] = thread_mode
        if latest_handoff_id is not None:
            patch["latest_handoff_id"] = latest_handoff_id
        if latest_packet_sequence is not None:
            patch["latest_packet_sequence"] = latest_packet_sequence
        if parent_handoff_id is not None:
            patch["parent_handoff_id"] = parent_handoff_id
        payload_patch = jsonish(args.payload_json, {})
        if isinstance(payload_patch, dict):
            patch.update(payload_patch)
        patch["repo"] = self.repo_context["repo"]
        patch["repo_head"] = self.repo_head()
        patch["last_update_utc"] = utc_now_z()
        normalized = normalize_state(patch, self.repo_context)
        if not normalized.get("active_owner"):
            normalized["active_owner"] = infer_active_owner(normalized.get("owner_scope"), args.actor)
        return normalized

    def commit_mutation(
        self,
        work_dir: Path,
        meta: Dict[str, Any],
        txn_sequence: int,
        txn_path: Path,
        txn_payload: Dict[str, Any],
        events: List[Dict[str, Any]],
        snapshot: Dict[str, Any],
        meta_updates: Dict[str, Any],
        override_snapshots: Optional[Dict[str, Dict[str, Any]]] = None,
    ) -> Dict[str, Any]:
        self.write_snapshot(work_dir, snapshot)
        snapshots = self.rebuild_global_outputs(override_snapshots=override_snapshots or {meta["work_id"]: snapshot})
        next_meta = dict(meta)
        next_meta.update(meta_updates)
        next_meta["txn_sequence"] = txn_sequence
        atomic_write_json(self.meta_path(work_dir), normalize_meta(next_meta, self.repo_context))
        self.finish_txn(txn_path, txn_payload, "COMMITTED", "mutation committed")
        return snapshots.get(meta["work_id"], snapshot)

    def reject_accept(self, work_dir: Path, meta: Dict[str, Any], actor: str, session_id: str, reason: str) -> None:
        txn_sequence, txn_path, txn_payload = self.begin_txn(work_dir, meta, actor, session_id, "accept")
        current = self.snapshot_for_existing_work(work_dir)
        event_sequence = ensure_int(meta.get("event_sequence")) + 1
        reject_event = self.make_event(
            meta,
            event_sequence,
            txn_sequence,
            session_id,
            actor,
            "HANDOFF_REJECTED",
            {"reason": reason, "state_patch": current["state"]},
            handoff_id=current["state"].get("latest_handoff_id"),
        )
        append_jsonl(self.event_log_path(work_dir), [reject_event])
        snapshot = self.derive_snapshot(
            work_dir,
            meta,
            target_state_version=ensure_int(meta.get("state_version")) + 1,
            target_packet_sequence=ensure_int(meta.get("packet_sequence")),
            target_event_sequence=event_sequence,
            allowed_txn_sequences=set([txn_sequence]),
        )
        meta_updates = {
            "event_sequence": event_sequence,
            "state_version": ensure_int(meta.get("state_version")) + 1,
        }
        self.commit_mutation(work_dir, meta, txn_sequence, txn_path, txn_payload, [reject_event], snapshot, meta_updates)
        stop_hard(reason)

    def command_start(self, args: argparse.Namespace) -> int:
        work_id = args.work_id or self.new_work_id()
        if work_id in self.all_work_locations():
            stop_hard("work_id already exists: {0}".format(work_id))
        session_id = args.session_id or self.new_session_id()
        primary_branch = self.make_branch_id("initial", 1)
        work_dir = self.work_dir(work_id)
        meta = self.default_meta(work_id, args.actor)
        self.ensure_work_skeleton(work_dir, meta)
        self.acquire_lock(work_id, args.actor, "start")
        try:
            txn_sequence, txn_path, txn_payload = self.begin_txn(work_dir, meta, args.actor, session_id, "start")
            owner_scope = default_owner_scope()
            owner_scope[args.actor] = "Primary owner"
            patch = self.state_patch_from_args(
                build_blank_state(self.repo_context),
                args,
                status="IN_PROGRESS",
                thread_mode="FRESH",
            )
            patch["work_id"] = work_id
            patch["active_owner"] = args.actor
            patch["owner_scope"] = owner_scope
            patch["primary_branch"] = primary_branch
            patch["live_branches"] = [primary_branch]
            patch["closed_branches"] = []
            patch["latest_handoff_id"] = None
            patch["latest_packet_sequence"] = 0
            patch["parent_handoff_id"] = None
            patch["state_version"] = 1
            event = self.make_event(
                meta,
                1,
                txn_sequence,
                session_id,
                args.actor,
                "SESSION_STARTED",
                {
                    "state_patch": patch,
                    "branch_id": primary_branch,
                    "branch_name": "initial",
                    "branch_status": "SELECTED",
                    "purpose": "neutral initial branch",
                },
                branch_id=primary_branch,
            )
            append_jsonl(self.event_log_path(work_dir), [event])
            snapshot = self.derive_snapshot(
                work_dir,
                meta,
                target_state_version=1,
                target_packet_sequence=0,
                target_event_sequence=1,
                allowed_txn_sequences=set([txn_sequence]),
            )
            meta_updates = {"event_sequence": 1, "state_version": 1, "packet_sequence": 0}
            self.commit_mutation(work_dir, meta, txn_sequence, txn_path, txn_payload, [event], snapshot, meta_updates)
        except Exception as exc:
            self.finish_txn(self.txn_path(work_dir, ensure_int(meta.get("txn_sequence")) + 1), txn_payload if 'txn_payload' in locals() else {}, "ABORTED", str(exc)) if 'txn_payload' in locals() else None
            raise
        finally:
            self.release_lock(work_id)
        self.print_work_status(work_dir)
        return 0

    def command_update(self, args: argparse.Namespace) -> int:
        work_dir, archived = self.resolve_single_work(args.work_id, allow_archived=False)
        if archived:
            stop_hard("archived work cannot be updated")
        meta = self.load_meta(work_dir)
        current = self.snapshot_for_existing_work(work_dir)
        if current["state"].get("status") == "ARCHIVED":
            stop_hard("archived work cannot be updated")
        if current["state"].get("active_owner") not in ("", args.actor, "MIXED"):
            stop_hard("owner conflict: {0}".format(current["state"].get("active_owner")))
        self.acquire_lock(meta["work_id"], args.actor, "update")
        try:
            txn_sequence, txn_path, txn_payload = self.begin_txn(work_dir, meta, args.actor, args.session_id or current.get("latest_session_id") or self.new_session_id(), "update")
            session_id = args.session_id or current.get("latest_session_id") or self.new_session_id()
            target_status = current["state"].get("status")
            if target_status == "HANDOFF_READY":
                target_status = "IN_PROGRESS"
            if args.event_type == "BLOCKER_FOUND" or args.blockers:
                target_status = "BLOCKED"
            elif args.event_type == "BLOCKER_CLEARED" and args.clear_blockers:
                target_status = "IN_PROGRESS"
            elif args.event_type == "STOP_HARD":
                target_status = "BLOCKED"
            patch = self.state_patch_from_args(current["state"], args, status=target_status)
            if target_status == "BLOCKED":
                if not patch.get("block_reason_code"):
                    if args.event_type == "STOP_HARD":
                        patch["block_reason_code"] = "STOP_HARD"
                    elif args.event_type == "BLOCKER_FOUND" or args.blockers:
                        patch["block_reason_code"] = "BLOCKER_FOUND"
                    else:
                        patch["block_reason_code"] = current["state"].get("block_reason_code") or "BLOCKED_PENDING_REVIEW"
                if not patch.get("block_reason_text"):
                    if args.blockers:
                        patch["block_reason_text"] = "; ".join(args.blockers)
                    elif args.event_type == "STOP_HARD":
                        patch["block_reason_text"] = "STOP_HARD event recorded; operator review required."
                    elif args.event_type == "BLOCKER_FOUND":
                        patch["block_reason_text"] = "Blocker reported; resolve the blocker before continuing."
                    else:
                        patch["block_reason_text"] = current["state"].get("block_reason_text") or "Work is blocked pending explicit review."
            event_sequence = ensure_int(meta.get("event_sequence")) + 1
            event = self.make_event(
                meta,
                event_sequence,
                txn_sequence,
                session_id,
                args.actor,
                args.event_type,
                {"state_patch": patch, "pr_number": patch.get("pr_number"), "issue_number": patch.get("issue_number")},
            )
            append_jsonl(self.event_log_path(work_dir), [event])
            snapshot = self.derive_snapshot(
                work_dir,
                meta,
                target_state_version=ensure_int(meta.get("state_version")) + 1,
                target_packet_sequence=ensure_int(meta.get("packet_sequence")),
                target_event_sequence=event_sequence,
                allowed_txn_sequences=set([txn_sequence]),
            )
            meta_updates = {
                "event_sequence": event_sequence,
                "state_version": ensure_int(meta.get("state_version")) + 1,
            }
            self.commit_mutation(work_dir, meta, txn_sequence, txn_path, txn_payload, [event], snapshot, meta_updates)
        except Exception as exc:
            if 'txn_path' in locals():
                self.finish_txn(txn_path, txn_payload, "ABORTED", str(exc))
            raise
        finally:
            self.release_lock(meta["work_id"])
        self.print_work_status(work_dir)
        return 0

    def command_split(self, args: argparse.Namespace) -> int:
        work_dir, archived = self.resolve_single_work(args.work_id, allow_archived=False)
        if archived:
            stop_hard("archived work cannot be split")
        meta = self.load_meta(work_dir)
        current = self.snapshot_for_existing_work(work_dir)
        parent_branch = current["state"].get("primary_branch")
        if not parent_branch:
            stop_hard("primary_branch is missing")
        existing_count = len(current["branches"]) + 1
        branch_id = args.branch_id or self.make_branch_id(args.branch_name or args.branch_slug or "branch", existing_count)
        if branch_id in current["branches"]:
            stop_hard("branch already exists: {0}".format(branch_id))
        self.acquire_lock(meta["work_id"], args.actor, "split")
        try:
            session_id = args.session_id or current.get("latest_session_id") or self.new_session_id()
            txn_sequence, txn_path, txn_payload = self.begin_txn(work_dir, meta, args.actor, session_id, "split")
            patch = self.state_patch_from_args(current["state"], args, status=current["state"].get("status") or "IN_PROGRESS")
            patch["live_branches"] = dedupe(current["state"].get("live_branches", []) + [branch_id])
            event_sequence = ensure_int(meta.get("event_sequence")) + 1
            events = [
                self.make_event(
                    meta,
                    event_sequence,
                    txn_sequence,
                    session_id,
                    args.actor,
                    "TASK_SPLIT",
                    {"state_patch": patch, "branch_id": branch_id, "parent_branch_id": parent_branch, "purpose": args.branch_name or branch_id},
                    branch_id=branch_id,
                ),
                self.make_event(
                    meta,
                    event_sequence + 1,
                    txn_sequence,
                    session_id,
                    args.actor,
                    "BRANCH_CREATED",
                    {"state_patch": patch, "branch_id": branch_id, "branch_name": args.branch_name or branch_id, "purpose": args.branch_name or branch_id, "branch_status": "OPEN"},
                    branch_id=branch_id,
                ),
            ]
            append_jsonl(self.event_log_path(work_dir), events)
            snapshot = self.derive_snapshot(
                work_dir,
                meta,
                target_state_version=ensure_int(meta.get("state_version")) + 1,
                target_packet_sequence=ensure_int(meta.get("packet_sequence")),
                target_event_sequence=event_sequence + 1,
                allowed_txn_sequences=set([txn_sequence]),
            )
            meta_updates = {"event_sequence": event_sequence + 1, "state_version": ensure_int(meta.get("state_version")) + 1}
            self.commit_mutation(work_dir, meta, txn_sequence, txn_path, txn_payload, events, snapshot, meta_updates)
        except Exception as exc:
            if 'txn_path' in locals():
                self.finish_txn(txn_path, txn_payload, "ABORTED", str(exc))
            raise
        finally:
            self.release_lock(meta["work_id"])
        self.print_work_status(work_dir)
        return 0

    def command_select_branch(self, args: argparse.Namespace) -> int:
        work_dir, archived = self.resolve_single_work(args.work_id, allow_archived=False)
        if archived:
            stop_hard("archived work cannot select a branch")
        meta = self.load_meta(work_dir)
        current = self.snapshot_for_existing_work(work_dir)
        branch_id = args.branch_id or args.primary_branch
        if not branch_id or branch_id not in current["branches"]:
            stop_hard("unknown branch_id: {0}".format(branch_id))
        if current["branches"][branch_id].get("status") in ("DROPPED", "MERGED"):
            stop_hard("closed branch cannot be selected: {0}".format(branch_id))
        self.acquire_lock(meta["work_id"], args.actor, "select-branch")
        try:
            session_id = args.session_id or current.get("latest_session_id") or self.new_session_id()
            txn_sequence, txn_path, txn_payload = self.begin_txn(work_dir, meta, args.actor, session_id, "select-branch")
            patch = self.state_patch_from_args(current["state"], args, status="IN_PROGRESS")
            patch["primary_branch"] = branch_id
            patch["live_branches"] = dedupe(current["state"].get("live_branches", []) + [branch_id])
            base_seq = ensure_int(meta.get("event_sequence")) + 1
            events = [
                self.make_event(meta, base_seq, txn_sequence, session_id, args.actor, "BRANCH_SELECTED", {"state_patch": patch, "branch_id": branch_id}, branch_id=branch_id),
                self.make_event(meta, base_seq + 1, txn_sequence, session_id, args.actor, "TASK_SELECTED", {"state_patch": patch, "branch_id": branch_id}, branch_id=branch_id),
            ]
            append_jsonl(self.event_log_path(work_dir), events)
            snapshot = self.derive_snapshot(work_dir, meta, ensure_int(meta.get("state_version")) + 1, ensure_int(meta.get("packet_sequence")), base_seq + 1, set([txn_sequence]))
            meta_updates = {"event_sequence": base_seq + 1, "state_version": ensure_int(meta.get("state_version")) + 1}
            self.commit_mutation(work_dir, meta, txn_sequence, txn_path, txn_payload, events, snapshot, meta_updates)
        except Exception as exc:
            if 'txn_path' in locals():
                self.finish_txn(txn_path, txn_payload, "ABORTED", str(exc))
            raise
        finally:
            self.release_lock(meta["work_id"])
        self.print_work_status(work_dir)
        return 0

    def command_drop_branch(self, args: argparse.Namespace) -> int:
        work_dir, archived = self.resolve_single_work(args.work_id, allow_archived=False)
        if archived:
            stop_hard("archived work cannot drop a branch")
        meta = self.load_meta(work_dir)
        current = self.snapshot_for_existing_work(work_dir)
        branch_id = args.branch_id or args.primary_branch
        if not branch_id or branch_id not in current["branches"]:
            stop_hard("unknown branch_id: {0}".format(branch_id))
        if branch_id == current["state"].get("primary_branch"):
            stop_hard("primary_branch cannot be dropped")
        self.acquire_lock(meta["work_id"], args.actor, "drop-branch")
        try:
            session_id = args.session_id or current.get("latest_session_id") or self.new_session_id()
            txn_sequence, txn_path, txn_payload = self.begin_txn(work_dir, meta, args.actor, session_id, "drop-branch")
            patch = self.state_patch_from_args(current["state"], args, status=current["state"].get("status") or "IN_PROGRESS")
            patch["live_branches"] = [item for item in current["state"].get("live_branches", []) if item != branch_id]
            patch["closed_branches"] = dedupe(current["state"].get("closed_branches", []) + [branch_id])
            base_seq = ensure_int(meta.get("event_sequence")) + 1
            events = [
                self.make_event(meta, base_seq, txn_sequence, session_id, args.actor, "BRANCH_DROPPED", {"state_patch": patch, "branch_id": branch_id}, branch_id=branch_id),
                self.make_event(meta, base_seq + 1, txn_sequence, session_id, args.actor, "TASK_DROPPED", {"state_patch": patch, "branch_id": branch_id}, branch_id=branch_id),
            ]
            append_jsonl(self.event_log_path(work_dir), events)
            snapshot = self.derive_snapshot(work_dir, meta, ensure_int(meta.get("state_version")) + 1, ensure_int(meta.get("packet_sequence")), base_seq + 1, set([txn_sequence]))
            meta_updates = {"event_sequence": base_seq + 1, "state_version": ensure_int(meta.get("state_version")) + 1}
            self.commit_mutation(work_dir, meta, txn_sequence, txn_path, txn_payload, events, snapshot, meta_updates)
        except Exception as exc:
            if 'txn_path' in locals():
                self.finish_txn(txn_path, txn_payload, "ABORTED", str(exc))
            raise
        finally:
            self.release_lock(meta["work_id"])
        self.print_work_status(work_dir)
        return 0

    def command_merge_branch(self, args: argparse.Namespace) -> int:
        work_dir, archived = self.resolve_single_work(args.work_id, allow_archived=False)
        if archived:
            stop_hard("archived work cannot merge a branch")
        meta = self.load_meta(work_dir)
        current = self.snapshot_for_existing_work(work_dir)
        branch_id = args.branch_id or args.primary_branch
        target_branch = args.target_branch_id or current["state"].get("primary_branch")
        if not branch_id or branch_id not in current["branches"]:
            stop_hard("unknown branch_id: {0}".format(branch_id))
        if not target_branch:
            stop_hard("target branch is required")
        self.acquire_lock(meta["work_id"], args.actor, "merge-branch")
        try:
            session_id = args.session_id or current.get("latest_session_id") or self.new_session_id()
            txn_sequence, txn_path, txn_payload = self.begin_txn(work_dir, meta, args.actor, session_id, "merge-branch")
            patch = self.state_patch_from_args(current["state"], args, status="IN_PROGRESS")
            patch["primary_branch"] = target_branch
            patch["live_branches"] = dedupe([item for item in current["state"].get("live_branches", []) if item != branch_id] + [target_branch])
            patch["closed_branches"] = dedupe(current["state"].get("closed_branches", []) + [branch_id])
            event_sequence = ensure_int(meta.get("event_sequence")) + 1
            event = self.make_event(
                meta,
                event_sequence,
                txn_sequence,
                session_id,
                args.actor,
                "BRANCH_MERGED",
                {"state_patch": patch, "branch_id": branch_id, "target_branch_id": target_branch},
                branch_id=branch_id,
            )
            append_jsonl(self.event_log_path(work_dir), [event])
            snapshot = self.derive_snapshot(work_dir, meta, ensure_int(meta.get("state_version")) + 1, ensure_int(meta.get("packet_sequence")), event_sequence, set([txn_sequence]))
            meta_updates = {"event_sequence": event_sequence, "state_version": ensure_int(meta.get("state_version")) + 1}
            self.commit_mutation(work_dir, meta, txn_sequence, txn_path, txn_payload, [event], snapshot, meta_updates)
        except Exception as exc:
            if 'txn_path' in locals():
                self.finish_txn(txn_path, txn_payload, "ABORTED", str(exc))
            raise
        finally:
            self.release_lock(meta["work_id"])
        self.print_work_status(work_dir)
        return 0

    def command_packet(self, args: argparse.Namespace) -> int:
        work_dir, archived = self.resolve_single_work(args.work_id, allow_archived=False)
        if archived:
            stop_hard("archived work cannot emit a packet")
        meta = self.load_meta(work_dir)
        current = self.snapshot_for_existing_work(work_dir)
        if current["state"].get("status") in ("DONE", "ARCHIVED"):
            stop_hard("completed work cannot emit a packet")
        self.acquire_lock(meta["work_id"], args.actor, "packet")
        try:
            session_id = args.session_id or current.get("latest_session_id") or self.new_session_id()
            txn_sequence, txn_path, txn_payload = self.begin_txn(work_dir, meta, args.actor, session_id, "packet")
            packet_sequence = ensure_int(meta.get("packet_sequence")) + 1
            handoff_id = self.make_handoff_id(meta["work_id"], packet_sequence)
            patch = self.state_patch_from_args(
                current["state"],
                args,
                status="HANDOFF_READY",
                latest_handoff_id=handoff_id,
                latest_packet_sequence=packet_sequence,
            )
            patch["handoff_note"] = args.handoff_note or build_packet_note(patch)
            base_seq = ensure_int(meta.get("event_sequence")) + 1
            events = [
                self.make_event(
                    meta,
                    base_seq,
                    txn_sequence,
                    session_id,
                    args.actor,
                    "HANDOFF_OUT_CREATED",
                    {"state_patch": patch, "to_actor": args.to_actor},
                    handoff_id=handoff_id,
                ),
                self.make_event(
                    meta,
                    base_seq + 1,
                    txn_sequence,
                    session_id,
                    args.actor,
                    "HANDOFF_OUT_EMITTED",
                    {"state_patch": patch, "to_actor": args.to_actor},
                    handoff_id=handoff_id,
                ),
            ]
            append_jsonl(self.event_log_path(work_dir), events)
            snapshot = self.derive_snapshot(work_dir, meta, ensure_int(meta.get("state_version")) + 1, packet_sequence, base_seq + 1, set([txn_sequence]))
            meta_updates = {
                "event_sequence": base_seq + 1,
                "state_version": ensure_int(meta.get("state_version")) + 1,
                "packet_sequence": packet_sequence,
            }
            snapshot = self.commit_mutation(work_dir, meta, txn_sequence, txn_path, txn_payload, events, snapshot, meta_updates)
        except Exception as exc:
            if 'txn_path' in locals():
                self.finish_txn(txn_path, txn_payload, "ABORTED", str(exc))
            raise
        finally:
            self.release_lock(meta["work_id"])
        sys.stdout.write(snapshot["packet_text"])
        return 0

    def command_accept(self, args: argparse.Namespace) -> int:
        packet = parse_packet(self.resolve_packet_text(args.packet_path, args.packet_text))
        if not packet.get("work_id"):
            stop_hard("packet missing WORK_ID")
        work_dir, archived = self.find_work(packet["work_id"], allow_archived=True)
        if archived:
            stop_hard("archived work cannot accept packet")
        meta = self.load_meta(work_dir)
        self.acquire_lock(meta["work_id"], args.actor, "accept")
        try:
            current = self.snapshot_for_existing_work(work_dir)
            session_id = args.session_id or self.new_session_id()
            reasons = []
            if current["state"].get("latest_handoff_id") != packet.get("handoff_id"):
                reasons.append("HANDOFF_ID mismatch")
            if ensure_int(current["state"].get("latest_packet_sequence")) != ensure_int(packet.get("packet_sequence")):
                reasons.append("stale packet sequence")
            if ensure_int(current["state"].get("state_version")) != ensure_int(packet.get("state_version")):
                reasons.append("stale state version")
            if current["state"].get("status") != "HANDOFF_READY":
                reasons.append("work is not handoff-ready")
            if current["state"].get("block_reason_code") == "RESTORE_REQUIRES_PACKET_REISSUE":
                reasons.append("packet invalidated by restore; reissue required")
            if meta.get("archived"):
                reasons.append("work is archived")
            if current["state"].get("latest_handoff_id") in current.get("accepted_handoffs", set()):
                reasons.append("handoff already accepted")
            if packet.get("handoff_id") != packet.get("latest_handoff_id"):
                reasons.append("packet latest_handoff_id mismatch")
            if reasons:
                self.reject_accept(work_dir, meta, args.actor, session_id, "; ".join(reasons))
            owner_scope = normalize_owner_scope(current["state"].get("owner_scope"))
            if not owner_scope.get(args.actor):
                owner_scope[args.actor] = "Accepted handoff"
            patch = self.state_patch_from_args(
                current["state"],
                args,
                status="IN_PROGRESS",
                thread_mode="HANDOFF",
                latest_handoff_id=packet.get("handoff_id"),
                latest_packet_sequence=packet.get("packet_sequence"),
                parent_handoff_id=packet.get("handoff_id"),
            )
            patch["active_owner"] = args.actor
            patch["owner_scope"] = owner_scope
            base_seq = ensure_int(meta.get("event_sequence")) + 1
            txn_sequence, txn_path, txn_payload = self.begin_txn(work_dir, meta, args.actor, session_id, "accept")
            events = [
                self.make_event(meta, base_seq, txn_sequence, session_id, args.actor, "SESSION_ACCEPTED", {"state_patch": patch, "from_handoff_id": packet.get("handoff_id")}, handoff_id=packet.get("handoff_id")),
                self.make_event(meta, base_seq + 1, txn_sequence, session_id, args.actor, "OWNER_CHANGED", {"state_patch": patch, "active_owner": args.actor}, handoff_id=packet.get("handoff_id")),
                self.make_event(meta, base_seq + 2, txn_sequence, session_id, args.actor, "HANDOFF_IN_ACCEPTED", {"state_patch": patch, "from_actor": packet.get("active_owner")}, handoff_id=packet.get("handoff_id")),
            ]
            append_jsonl(self.event_log_path(work_dir), events)
            snapshot = self.derive_snapshot(work_dir, meta, ensure_int(meta.get("state_version")) + 1, ensure_int(meta.get("packet_sequence")), base_seq + 2, set([txn_sequence]))
            meta_updates = {"event_sequence": base_seq + 2, "state_version": ensure_int(meta.get("state_version")) + 1}
            self.commit_mutation(work_dir, meta, txn_sequence, txn_path, txn_payload, events, snapshot, meta_updates)
        except Exception as exc:
            if 'txn_path' in locals():
                self.finish_txn(txn_path, txn_payload, "ABORTED", str(exc))
            raise
        finally:
            self.release_lock(meta["work_id"])
        self.print_work_status(work_dir)
        return 0

    def command_complete(self, args: argparse.Namespace) -> int:
        work_dir, archived = self.resolve_single_work(args.work_id, allow_archived=False)
        if archived:
            stop_hard("archived work cannot be completed")
        meta = self.load_meta(work_dir)
        current = self.snapshot_for_existing_work(work_dir)
        missing = [item for item in current["state"].get("required_evidence", []) if item not in current["state"].get("evidence_log", [])]
        if missing:
            stop_hard("required_evidence is incomplete: {0}".format(", ".join(missing)))
        self.acquire_lock(meta["work_id"], args.actor, "complete")
        try:
            session_id = args.session_id or current.get("latest_session_id") or self.new_session_id()
            txn_sequence, txn_path, txn_payload = self.begin_txn(work_dir, meta, args.actor, session_id, "complete")
            patch = self.state_patch_from_args(current["state"], args, status="DONE")
            if not patch.get("next_action"):
                patch["next_action"] = "Archive this work when verification is complete."
            base_seq = ensure_int(meta.get("event_sequence")) + 1
            events = [
                self.make_event(meta, base_seq, txn_sequence, session_id, args.actor, "WORK_COMPLETED", {"state_patch": patch}),
                self.make_event(meta, base_seq + 1, txn_sequence, session_id, args.actor, "WORK_CLOSED", {"state_patch": patch}),
            ]
            append_jsonl(self.event_log_path(work_dir), events)
            snapshot = self.derive_snapshot(work_dir, meta, ensure_int(meta.get("state_version")) + 1, ensure_int(meta.get("packet_sequence")), base_seq + 1, set([txn_sequence]), status_override="DONE")
            meta_updates = {"event_sequence": base_seq + 1, "state_version": ensure_int(meta.get("state_version")) + 1}
            self.commit_mutation(work_dir, meta, txn_sequence, txn_path, txn_payload, events, snapshot, meta_updates)
        except Exception as exc:
            if 'txn_path' in locals():
                self.finish_txn(txn_path, txn_payload, "ABORTED", str(exc))
            raise
        finally:
            self.release_lock(meta["work_id"])
        self.print_work_status(work_dir)
        return 0

    def command_archive(self, args: argparse.Namespace) -> int:
        work_dir, archived = self.resolve_single_work(args.work_id, allow_archived=False)
        if archived:
            stop_hard("work is already archived")
        meta = self.load_meta(work_dir)
        current = self.snapshot_for_existing_work(work_dir)
        self.validate_work_snapshot(work_dir, meta, current, require_committed_txn=True, check_files=False)
        if current["state"].get("status") != "DONE":
            stop_hard("only DONE work can be archived")
        target_dir = self.work_dir(meta["work_id"], archived=True)
        if target_dir.exists():
            stop_hard("archive target already exists: {0}".format(target_dir))
        self.acquire_lock(meta["work_id"], args.actor, "archive")
        moved = False
        current_dir = work_dir
        try:
            session_id = args.session_id or current.get("latest_session_id") or self.new_session_id()
            txn_sequence, txn_path, txn_payload = self.begin_txn(work_dir, meta, args.actor, session_id, "archive")
            event_sequence = ensure_int(meta.get("event_sequence")) + 1
            patch = self.state_patch_from_args(current["state"], args, status="ARCHIVED")
            event = self.make_event(meta, event_sequence, txn_sequence, session_id, args.actor, "WORK_ARCHIVED", {"state_patch": patch})
            append_jsonl(self.event_log_path(work_dir), [event])
            shutil.move(str(work_dir), str(target_dir))
            moved = True
            current_dir = target_dir
            new_meta = dict(meta)
            new_meta["active"] = False
            new_meta["archived"] = True
            snapshot = self.derive_snapshot(current_dir, meta, ensure_int(meta.get("state_version")) + 1, ensure_int(meta.get("packet_sequence")), event_sequence, set([txn_sequence]), status_override="ARCHIVED", meta_override=new_meta)
            self.write_snapshot(current_dir, snapshot)
            override = {meta["work_id"]: snapshot}
            self.rebuild_global_outputs(override_snapshots=override)
            new_meta["event_sequence"] = event_sequence
            new_meta["state_version"] = ensure_int(meta.get("state_version")) + 1
            new_meta["txn_sequence"] = txn_sequence
            atomic_write_json(self.meta_path(current_dir), normalize_meta(new_meta, self.repo_context))
            self.finish_txn(self.txn_path(current_dir, txn_sequence), txn_payload, "COMMITTED", "archive committed")
        except Exception as exc:
            if moved:
                txn_path = self.txn_path(current_dir, ensure_int(meta.get("txn_sequence")) + 1)
            if 'txn_path' in locals() and txn_path.exists():
                self.finish_txn(txn_path, txn_payload, "ABORTED", str(exc))
            raise
        finally:
            self.release_lock(meta["work_id"])
        self.print_work_status(current_dir)
        return 0

    def command_restore(self, args: argparse.Namespace) -> int:
        if not args.work_id:
            stop_hard("work_id is required for restore")
        work_dir, archived = self.find_work(args.work_id, allow_archived=True)
        if not archived:
            stop_hard("restore requires archived work")
        meta = self.load_meta(work_dir)
        target_dir = self.work_dir(meta["work_id"], archived=False)
        if target_dir.exists():
            stop_hard("active target already exists: {0}".format(target_dir))
        current = self.snapshot_for_existing_work(work_dir)
        self.acquire_lock(meta["work_id"], args.actor, "restore")
        moved = False
        current_dir = work_dir
        try:
            session_id = args.session_id or self.new_session_id()
            txn_sequence, txn_path, txn_payload = self.begin_txn(work_dir, meta, args.actor, session_id, "restore")
            shutil.move(str(work_dir), str(target_dir))
            moved = True
            current_dir = target_dir
            event_sequence = ensure_int(meta.get("event_sequence")) + 1
            prior_handoff_id = current["state"].get("latest_handoff_id") or current["state"].get("parent_handoff_id")
            patch = self.state_patch_from_args(current["state"], args, status="BLOCKED", thread_mode="CONTINUE", latest_handoff_id="", parent_handoff_id=prior_handoff_id)
            if not patch.get("next_action"):
                patch["next_action"] = "Review restored work and reissue a packet before continuing."
            patch["block_reason_code"] = args.block_reason_code or "RESTORE_REQUIRES_PACKET_REISSUE"
            patch["block_reason_text"] = args.block_reason_text or "Restored work invalidates prior packets; review state and reissue a packet before continuing."
            event = self.make_event(meta, event_sequence, txn_sequence, session_id, args.actor, "WORK_RESTORED", {"state_patch": patch})
            append_jsonl(self.event_log_path(current_dir), [event])
            new_meta = dict(meta)
            new_meta["active"] = True
            new_meta["archived"] = False
            snapshot = self.derive_snapshot(current_dir, meta, ensure_int(meta.get("state_version")) + 1, ensure_int(meta.get("packet_sequence")), event_sequence, set([txn_sequence]), status_override="BLOCKED", meta_override=new_meta)
            self.write_snapshot(current_dir, snapshot)
            override = {meta["work_id"]: snapshot}
            self.rebuild_global_outputs(override_snapshots=override)
            new_meta["event_sequence"] = event_sequence
            new_meta["state_version"] = ensure_int(meta.get("state_version")) + 1
            new_meta["txn_sequence"] = txn_sequence
            atomic_write_json(self.meta_path(current_dir), normalize_meta(new_meta, self.repo_context))
            self.finish_txn(self.txn_path(current_dir, txn_sequence), txn_payload, "COMMITTED", "restore committed")
        except Exception as exc:
            if moved:
                txn_path = self.txn_path(current_dir, ensure_int(meta.get("txn_sequence")) + 1)
            if 'txn_path' in locals() and txn_path.exists():
                self.finish_txn(txn_path, txn_payload, "ABORTED", str(exc))
            raise
        finally:
            self.release_lock(meta["work_id"])
        self.print_work_status(current_dir)
        return 0

    def print_work_status(self, work_dir: Path) -> None:
        snapshot = self.snapshot_for_existing_work(work_dir)
        state = snapshot["state"]
        lines = [
            "WORK_ID={0}".format(state.get("work_id", "")),
            "STATUS={0}".format(state.get("status", "")),
            "THREAD_MODE={0}".format(state.get("thread_mode", "")),
            "ACTIVE_OWNER={0}".format(state.get("active_owner", "")),
            "PRIMARY_BRANCH={0}".format(state.get("primary_branch", "")),
            "NEXT_ACTION={0}".format(state.get("next_action", "")),
            "BLOCKERS={0}".format(compact_json(state.get("blockers", []))),
            "LATEST_HANDOFF_ID={0}".format(state.get("latest_handoff_id") or ""),
            "PACKET_SEQUENCE={0}".format(state.get("latest_packet_sequence", 0)),
        ]
        sys.stdout.write("\n".join(lines) + "\n")

    def command_status(self, args: argparse.Namespace) -> int:
        if args.work_id:
            work_dir, _ = self.find_work(args.work_id, allow_archived=True)
            self.print_work_status(work_dir)
            return 0
        active_rows = read_json(self.active_index_path, [])
        if not active_rows:
            sys.stdout.write("NO_ACTIVE_WORK\n")
            return 0
        for row in active_rows:
            sys.stdout.write("{work_id} | {status} | {active_owner} | {primary_branch} | {next_action}\n".format(**row))
        return 0

    def command_verify(self, args: argparse.Namespace) -> int:
        locks = [path for path in self.locks_root.glob("WORK_*.lock") if path.is_file()]
        for lock_path in locks:
            payload = read_json(lock_path, {})
            if self.is_stale_lock(payload):
                stop_hard("stale lock detected: {0}".format(lock_path.name))
        snapshots = {}
        targets = [self.find_work(args.work_id, allow_archived=True)[0]] if args.work_id else [item[0] for item in self.all_work_locations().values()]
        for work_dir in targets:
            meta = self.load_meta(work_dir)
            snapshot = self.snapshot_for_existing_work(work_dir)
            self.validate_work_snapshot(work_dir, meta, snapshot, require_committed_txn=True, check_files=True)
            snapshots[meta["work_id"]] = snapshot
        if not args.work_id:
            expected_active = self.build_active_index(snapshots)
            expected_archive = self.build_archive_index(snapshots)
            expected_tower = self.build_control_tower(expected_active, expected_archive, snapshots)
            if read_json(self.active_index_path, []) != expected_active:
                stop_hard("ACTIVE_INDEX mismatch")
            if read_json(self.archive_index_path, []) != expected_archive:
                stop_hard("ARCHIVE_INDEX mismatch")
            if read_text(self.control_tower_path) != expected_tower:
                stop_hard("CONTROL_TOWER mismatch")
            preferred = self.preferred_mirror_work(snapshots)
            if preferred:
                snapshot = snapshots[preferred]
                mirror_state = normalize_state(read_json(self.mirror_root / MIRROR_FILE_NAMES["state"][0], {}), self.repo_context)
                if mirror_state != snapshot["state"]:
                    stop_hard("MEP mirror state mismatch")
                if read_text(self.mirror_root / MIRROR_FILE_NAMES["packet"][0]) != snapshot["packet_text"]:
                    stop_hard("MEP mirror packet mismatch")
        sys.stdout.write("VERIFY=OK\n")
        return 0

    def command_rebuild(self, args: argparse.Namespace) -> int:
        targets = [self.find_work(args.work_id, allow_archived=True)[0]] if args.work_id else [item[0] for item in self.all_work_locations().values()]
        overrides = {}
        for work_dir in targets:
            if self.unresolved_txns(work_dir):
                stop_hard("doctor required before rebuild for {0}".format(work_dir.name))
            meta = self.load_meta(work_dir)
            snapshot = self.snapshot_for_existing_work(work_dir)
            self.write_snapshot(work_dir, snapshot)
            overrides[meta["work_id"]] = snapshot
        self.rebuild_global_outputs(override_snapshots=overrides)
        sys.stdout.write("REBUILD=OK\n")
        return 0

    def command_doctor(self, args: argparse.Namespace) -> int:
        repaired = []
        for lock_path in list(self.locks_root.glob("WORK_*.lock")):
            payload = read_json(lock_path, {})
            if self.is_stale_lock(payload):
                lock_path.unlink()
                repaired.append("removed stale lock {0}".format(lock_path.name))
            else:
                stop_hard("active lock present: {0}".format(lock_path.name))
        targets = [self.find_work(args.work_id, allow_archived=True)[0]] if args.work_id else [item[0] for item in self.all_work_locations().values()]
        overrides = {}
        for work_dir in targets:
            meta = self.load_meta(work_dir)
            for txn in self.unresolved_txns(work_dir):
                txn_path = Path(txn["path"])
                payload = dict(txn)
                payload.pop("path", None)
                self.finish_txn(txn_path, payload, "ABORTED", "doctor aborted unresolved txn")
                repaired.append("aborted txn {0} for {1}".format(txn.get("txn_sequence"), meta["work_id"]))
            if work_dir.parent == self.archive_root and not meta.get("archived"):
                meta["archived"] = True
                meta["active"] = False
                repaired.append("fixed archive META for {0}".format(meta["work_id"]))
            if work_dir.parent == self.work_items_root and meta.get("archived"):
                meta["archived"] = False
                meta["active"] = True
                repaired.append("fixed active META for {0}".format(meta["work_id"]))
            atomic_write_json(self.meta_path(work_dir), normalize_meta(meta, self.repo_context))
            snapshot = self.snapshot_for_existing_work(work_dir)
            self.write_snapshot(work_dir, snapshot)
            overrides[meta["work_id"]] = snapshot
        self.rebuild_global_outputs(override_snapshots=overrides)
        sys.stdout.write("DOCTOR=OK\n")
        if repaired:
            sys.stdout.write("REPAIRS={0}\n".format("; ".join(repaired)))
        return 0


def add_common_state_args(parser: argparse.ArgumentParser, require_actor: bool = False) -> None:
    if require_actor:
        parser.add_argument("--actor", required=True, choices=VALID_ACTORS)
    else:
        parser.add_argument("--actor", choices=VALID_ACTORS)
    parser.add_argument("--work-id")
    parser.add_argument("--session-id")
    parser.add_argument("--current-goal")
    parser.add_argument("--current-stage")
    parser.add_argument("--current-state")
    parser.add_argument("--next-action")
    parser.add_argument("--last-safe-point")
    parser.add_argument("--active-owner", choices=VALID_OWNERS)
    parser.add_argument("--owner-scope-gpt")
    parser.add_argument("--owner-scope-codex")
    parser.add_argument("--owner-scope-human")
    parser.add_argument("--primary-branch")
    parser.add_argument("--live-branches", action="append", default=[])
    parser.add_argument("--closed-branches", action="append", default=[])
    parser.add_argument("--blockers", action="append", default=[])
    parser.add_argument("--clear-blockers", action="store_true")
    parser.add_argument("--forbidden-actions", action="append", default=[])
    parser.add_argument("--required-evidence", action="append", default=[])
    parser.add_argument("--evidence-log", action="append", default=[])
    parser.add_argument("--inputs", action="append", default=[])
    parser.add_argument("--output-target", action="append", default=[])
    parser.add_argument("--pr-number", type=int, default=0)
    parser.add_argument("--issue-number", type=int, default=0)
    parser.add_argument("--payload-json", default="")
    parser.add_argument("--block-reason-code")
    parser.add_argument("--block-reason-text")
    parser.add_argument("--handoff-note")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Handoff OS v1")
    parser.add_argument("--base-dir", default=".")
    subparsers = parser.add_subparsers(dest="command", required=True)

    start = subparsers.add_parser("start")
    add_common_state_args(start, require_actor=True)
    start.set_defaults(handler="command_start")

    session_start = subparsers.add_parser("session-start")
    add_common_state_args(session_start, require_actor=True)
    session_start.set_defaults(handler="command_start")

    update = subparsers.add_parser("update")
    add_common_state_args(update, require_actor=True)
    update.add_argument("--event-type", default="STATE_UPDATED", choices=sorted(EVENT_TYPES))
    update.set_defaults(handler="command_update")

    split = subparsers.add_parser("split")
    add_common_state_args(split, require_actor=True)
    split.add_argument("--branch-id")
    split.add_argument("--branch-name")
    split.add_argument("--branch-slug")
    split.set_defaults(handler="command_split")

    select_branch = subparsers.add_parser("select-branch")
    add_common_state_args(select_branch, require_actor=True)
    select_branch.add_argument("--branch-id")
    select_branch.set_defaults(handler="command_select_branch")

    drop_branch = subparsers.add_parser("drop-branch")
    add_common_state_args(drop_branch, require_actor=True)
    drop_branch.add_argument("--branch-id")
    drop_branch.set_defaults(handler="command_drop_branch")

    merge_branch = subparsers.add_parser("merge-branch")
    add_common_state_args(merge_branch, require_actor=True)
    merge_branch.add_argument("--branch-id")
    merge_branch.add_argument("--target-branch-id")
    merge_branch.set_defaults(handler="command_merge_branch")

    packet = subparsers.add_parser("packet")
    add_common_state_args(packet, require_actor=True)
    packet.add_argument("--to-actor", default="ANY", choices=VALID_ACTORS + ("ANY",))
    packet.set_defaults(handler="command_packet")

    accept = subparsers.add_parser("accept")
    add_common_state_args(accept, require_actor=True)
    accept.add_argument("--packet-path")
    accept.add_argument("--packet-text")
    accept.set_defaults(handler="command_accept")

    complete = subparsers.add_parser("complete")
    add_common_state_args(complete, require_actor=True)
    complete.set_defaults(handler="command_complete")

    close = subparsers.add_parser("close")
    add_common_state_args(close, require_actor=True)
    close.set_defaults(handler="command_complete")

    archive = subparsers.add_parser("archive")
    add_common_state_args(archive, require_actor=True)
    archive.set_defaults(handler="command_archive")

    restore = subparsers.add_parser("restore")
    add_common_state_args(restore, require_actor=True)
    restore.set_defaults(handler="command_restore")

    status = subparsers.add_parser("status")
    status.add_argument("--work-id")
    status.set_defaults(handler="command_status")

    verify = subparsers.add_parser("verify")
    verify.add_argument("--work-id")
    verify.set_defaults(handler="command_verify")

    rebuild = subparsers.add_parser("rebuild")
    rebuild.add_argument("--work-id")
    rebuild.set_defaults(handler="command_rebuild")

    doctor = subparsers.add_parser("doctor")
    doctor.add_argument("--work-id")
    doctor.set_defaults(handler="command_doctor")

    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_parser()
    args = parser.parse_args(list(argv) if argv is not None else None)
    engine = HandoffOS(Path(args.base_dir))
    handler_name = getattr(args, "handler")
    handler = getattr(engine, handler_name)
    try:
        return int(handler(args) or 0)
    except StopHardError as exc:
        sys.stderr.write("STOP_HARD: {0}\n".format(exc))
        return 2
    except Exception as exc:
        sys.stderr.write("STOP_HARD: {0}\n".format(exc))
        traceback.print_exc(file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
















