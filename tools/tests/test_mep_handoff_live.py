from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPT = REPO_ROOT / 'tools' / 'mep_handoff_live.py'
PACKET_KEYS = [
    'PACKET_VERSION',
    'WORK_ID',
    'HANDOFF_ID',
    'PACKET_SEQUENCE',
    'STATE_VERSION',
    'THREAD_MODE',
    'STATUS',
    'CURRENT_GOAL',
    'CURRENT_STAGE',
    'CURRENT_STATE',
    'NEXT_ACTION',
    'ACTIVE_OWNER',
    'OWNER_SCOPE_GPT',
    'OWNER_SCOPE_CODEX',
    'OWNER_SCOPE_HUMAN',
    'PRIMARY_BRANCH',
    'LIVE_BRANCHES',
    'CLOSED_BRANCHES',
    'FORBIDDEN_ACTIONS',
    'REQUIRED_EVIDENCE',
    'EVIDENCE_LOG',
    'INPUTS',
    'OUTPUT_TARGET',
    'LAST_SAFE_POINT',
    'REPO',
    'REPO_HEAD',
    'PR_NUMBER',
    'ISSUE_NUMBER',
    'PARENT_HANDOFF_ID',
    'LATEST_HANDOFF_ID',
    'LAST_UPDATE_UTC',
    'HANDOFF_NOTE',
]


class HandoffOsCliTests(unittest.TestCase):
    maxDiff = None

    def run_cli(self, base_dir: Path, *args: str, expect_ok: bool = True) -> subprocess.CompletedProcess[str]:
        cmd = [sys.executable, str(SCRIPT), '--base-dir', str(base_dir), *args]
        completed = subprocess.run(cmd, capture_output=True, text=True)
        if expect_ok and completed.returncode != 0:
            self.fail(f'command failed: {cmd}\nstdout={completed.stdout}\nstderr={completed.stderr}')
        if not expect_ok and completed.returncode == 0:
            self.fail(f'command unexpectedly succeeded: {cmd}\nstdout={completed.stdout}\nstderr={completed.stderr}')
        return completed

    def workroom(self, base_dir: Path) -> Path:
        return base_dir / 'docs' / 'WORKROOM'

    def work_items_root(self, base_dir: Path) -> Path:
        return self.workroom(base_dir) / 'WORK_ITEMS'

    def archive_root(self, base_dir: Path) -> Path:
        return self.workroom(base_dir) / 'ARCHIVE'

    def work_dirs(self, base_dir: Path, archived: bool = False) -> list[Path]:
        root = self.archive_root(base_dir) if archived else self.work_items_root(base_dir)
        if not root.exists():
            return []
        return sorted(path for path in root.iterdir() if path.is_dir() and path.name.startswith('WORK_'))

    def single_work_dir(self, base_dir: Path, archived: bool = False) -> Path:
        items = self.work_dirs(base_dir, archived=archived)
        self.assertEqual(1, len(items), items)
        return items[0]

    def work_dir_by_id(self, base_dir: Path, work_id: str, archived: bool = False) -> Path:
        root = self.archive_root(base_dir) if archived else self.work_items_root(base_dir)
        return root / work_id

    def load_json(self, path: Path) -> dict:
        return json.loads(path.read_text(encoding='utf-8'))

    def load_jsonl(self, path: Path) -> list[dict]:
        return [json.loads(line) for line in path.read_text(encoding='utf-8').splitlines() if line.strip()]

    def load_state(self, base_dir: Path, work_id: str | None = None, archived: bool = False) -> dict:
        work_dir = self.work_dir_by_id(base_dir, work_id, archived) if work_id else self.single_work_dir(base_dir, archived)
        return self.load_json(work_dir / 'LIVE_STATE.json')

    def load_meta(self, base_dir: Path, work_id: str | None = None, archived: bool = False) -> dict:
        work_dir = self.work_dir_by_id(base_dir, work_id, archived) if work_id else self.single_work_dir(base_dir, archived)
        return self.load_json(work_dir / 'META.json')

    def load_graph(self, base_dir: Path, work_id: str | None = None, archived: bool = False) -> dict:
        work_dir = self.work_dir_by_id(base_dir, work_id, archived) if work_id else self.single_work_dir(base_dir, archived)
        return self.load_json(work_dir / 'GRAPH.json')

    def load_events(self, base_dir: Path, work_id: str | None = None, archived: bool = False) -> list[dict]:
        work_dir = self.work_dir_by_id(base_dir, work_id, archived) if work_id else self.single_work_dir(base_dir, archived)
        return self.load_jsonl(work_dir / 'EVENT_LOG.jsonl')

    def packet_path(self, base_dir: Path, work_id: str | None = None, archived: bool = False) -> Path:
        work_dir = self.work_dir_by_id(base_dir, work_id, archived) if work_id else self.single_work_dir(base_dir, archived)
        return work_dir / 'HANDOFF_PACKET.txt'

    def load_packet(self, base_dir: Path, work_id: str | None = None, archived: bool = False) -> str:
        return self.packet_path(base_dir, work_id, archived).read_text(encoding='utf-8')

    def load_active_index(self, base_dir: Path) -> list[dict]:
        return self.load_json(self.workroom(base_dir) / 'ACTIVE_INDEX.json')

    def load_archive_index(self, base_dir: Path) -> list[dict]:
        return self.load_json(self.workroom(base_dir) / 'ARCHIVE_INDEX.json')

    def load_control_tower(self, base_dir: Path) -> str:
        return (self.workroom(base_dir) / 'CONTROL_TOWER.md').read_text(encoding='utf-8')

    def load_mirror_state(self, base_dir: Path) -> dict:
        return self.load_json(base_dir / 'docs' / 'MEP' / 'HANDOFF_LIVE_STATE.json')

    def load_mirror_graph(self, base_dir: Path) -> dict:
        return self.load_json(base_dir / 'docs' / 'MEP' / 'HANDOFF_GRAPH.json')

    def load_mirror_events(self, base_dir: Path) -> list[dict]:
        return self.load_jsonl(base_dir / 'docs' / 'MEP' / 'HANDOFF_EVENT_LOG.jsonl')

    def load_mirror_packet(self, base_dir: Path) -> str:
        return (base_dir / 'docs' / 'MEP' / 'HANDOFF_PACKET.txt').read_text(encoding='utf-8')

    def start_work(self, base_dir: Path, actor: str = 'CODEX', next_action: str = 'Continue implementation') -> str:
        self.run_cli(
            base_dir,
            'start',
            '--actor', actor,
            '--current-goal', 'Build Handoff OS',
            '--current-stage', 'implementation',
            '--current-state', 'starting',
            '--next-action', next_action,
            '--last-safe-point', 'Start command committed.',
        )
        return self.single_work_dir(base_dir).name

    def emit_packet(self, base_dir: Path, actor: str = 'CODEX', to_actor: str = 'GPT', work_id: str | None = None) -> str:
        args = ['packet', '--actor', actor, '--to-actor', to_actor]
        if work_id:
            args.extend(['--work-id', work_id])
        return self.run_cli(base_dir, *args).stdout

    def test_start_uses_neutral_initial_branch(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir)
            state = self.load_state(base_dir, work_id)
            self.assertEqual('BRANCH_initial_1', state['primary_branch'])
            self.assertEqual(['BRANCH_initial_1'], state['live_branches'])
            self.run_cli(base_dir, 'verify', '--work-id', work_id)

    def write_packet_copy(self, base_dir: Path, packet_text: str, name: str = 'packet.txt') -> Path:
        path = base_dir / name
        path.write_text(packet_text, encoding='utf-8')
        return path

    def test_start_update_packet_accept_update(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir)
            self.run_cli(
                base_dir,
                'update',
                '--work-id', work_id,
                '--actor', 'CODEX',
                '--event-type', 'PLAN_SET',
                '--current-stage', 'planning',
                '--current-state', 'plan-fixed',
                '--next-action', 'Emit packet to GPT',
                '--evidence-log', 'plan approved',
            )
            packet_text = self.emit_packet(base_dir, actor='CODEX', to_actor='GPT', work_id=work_id)
            packet_copy = self.write_packet_copy(base_dir, packet_text)
            self.run_cli(base_dir, 'accept', '--work-id', work_id, '--actor', 'GPT', '--packet-path', str(packet_copy))
            self.run_cli(
                base_dir,
                'update',
                '--work-id', work_id,
                '--actor', 'GPT',
                '--current-stage', 'continuation',
                '--current-state', 'accepted-and-working',
                '--next-action', 'Hand back to CODEX after review',
            )
            state = self.load_state(base_dir, work_id)
            events = self.load_events(base_dir, work_id)
            self.assertEqual('HANDOFF', state['thread_mode'])
            self.assertEqual('GPT', state['active_owner'])
            self.assertEqual('HANDOFF_WORK_', state['latest_handoff_id'][:13])
            self.assertEqual('Hand back to CODEX after review', state['next_action'])
            self.assertEqual(['SESSION_STARTED', 'PLAN_SET', 'HANDOFF_OUT_CREATED', 'HANDOFF_OUT_EMITTED', 'SESSION_ACCEPTED', 'OWNER_CHANGED', 'HANDOFF_IN_ACCEPTED', 'STATE_UPDATED'], [event['event_type'] for event in events])
            self.run_cli(base_dir, 'verify')

    def test_split_select_drop_merge_branch(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir, next_action='Split branches')
            initial_state = self.load_state(base_dir, work_id)
            main_branch = initial_state['primary_branch']
            self.run_cli(base_dir, 'split', '--work-id', work_id, '--actor', 'CODEX', '--branch-name', 'alpha')
            self.run_cli(base_dir, 'split', '--work-id', work_id, '--actor', 'CODEX', '--branch-name', 'beta')
            state_after_split = self.load_state(base_dir, work_id)
            extra_branches = [branch for branch in state_after_split['live_branches'] if branch != main_branch]
            alpha_branch = next(branch for branch in extra_branches if 'alpha' in branch)
            beta_branch = next(branch for branch in extra_branches if 'beta' in branch)
            self.run_cli(base_dir, 'drop-branch', '--work-id', work_id, '--actor', 'CODEX', '--branch-id', alpha_branch)
            self.run_cli(base_dir, 'select-branch', '--work-id', work_id, '--actor', 'CODEX', '--branch-id', beta_branch)
            self.run_cli(base_dir, 'merge-branch', '--work-id', work_id, '--actor', 'CODEX', '--branch-id', beta_branch, '--target-branch-id', main_branch)
            state = self.load_state(base_dir, work_id)
            graph = self.load_graph(base_dir, work_id)
            self.assertEqual(main_branch, state['primary_branch'])
            self.assertIn(main_branch, state['live_branches'])
            self.assertIn(alpha_branch, state['closed_branches'])
            self.assertIn(beta_branch, state['closed_branches'])
            edge_types = {edge['type'] for edge in graph['edges']}
            self.assertTrue({'branched_to', 'selected', 'dropped', 'merged_back'}.issubset(edge_types))
            self.run_cli(base_dir, 'verify', '--work-id', work_id)

    def test_complete_then_archive(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir, next_action='Complete work')
            self.run_cli(base_dir, 'complete', '--work-id', work_id, '--actor', 'CODEX')
            self.run_cli(base_dir, 'archive', '--work-id', work_id, '--actor', 'CODEX')
            self.assertFalse(self.work_dir_by_id(base_dir, work_id, archived=False).exists())
            archived_state = self.load_state(base_dir, work_id, archived=True)
            archive_index = self.load_archive_index(base_dir)
            active_index = self.load_active_index(base_dir)
            self.assertEqual('ARCHIVED', archived_state['status'])
            self.assertFalse(active_index)
            self.assertEqual(work_id, archive_index[0]['work_id'])
            self.run_cli(base_dir, 'verify')

    def test_archive_then_restore(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir, next_action='Complete work')
            self.run_cli(base_dir, 'complete', '--work-id', work_id, '--actor', 'CODEX')
            self.run_cli(base_dir, 'archive', '--work-id', work_id, '--actor', 'CODEX')
            self.run_cli(base_dir, 'restore', '--work-id', work_id, '--actor', 'GPT')
            state = self.load_state(base_dir, work_id)
            archive_index = self.load_archive_index(base_dir)
            active_index = self.load_active_index(base_dir)
            self.assertEqual('BLOCKED', state['status'])
            self.assertEqual('CONTINUE', state['thread_mode'])
            self.assertEqual('RESTORE_REQUIRES_PACKET_REISSUE', state['block_reason_code'])
            self.assertIn('reissue a packet', state['block_reason_text'])
            self.assertIsNone(state['latest_handoff_id'])
            self.assertFalse(archive_index)
            self.assertEqual(work_id, active_index[0]['work_id'])
            self.run_cli(base_dir, 'verify')

    def test_stale_packet_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir, next_action='Emit packet')
            old_packet = self.emit_packet(base_dir, actor='CODEX', to_actor='GPT', work_id=work_id)
            old_packet_path = self.write_packet_copy(base_dir, old_packet, 'stale_packet.txt')
            self.run_cli(base_dir, 'update', '--work-id', work_id, '--actor', 'CODEX', '--current-state', 'new-state', '--next-action', 'Emit replacement packet')
            self.emit_packet(base_dir, actor='CODEX', to_actor='GPT', work_id=work_id)
            rejected = self.run_cli(base_dir, 'accept', '--work-id', work_id, '--actor', 'GPT', '--packet-path', str(old_packet_path), expect_ok=False)
            self.assertIn('STOP_HARD', rejected.stderr)
            self.assertIn('stale packet sequence', rejected.stderr)
            event_types = [event['event_type'] for event in self.load_events(base_dir, work_id)]
            self.assertIn('HANDOFF_REJECTED', event_types)

    def test_restore_rejects_pre_restore_packet(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir, next_action='Emit packet')
            packet_text = self.emit_packet(base_dir, actor='CODEX', to_actor='GPT', work_id=work_id)
            packet_path = self.write_packet_copy(base_dir, packet_text, 'pre_restore_packet.txt')
            self.run_cli(base_dir, 'complete', '--work-id', work_id, '--actor', 'CODEX')
            self.run_cli(base_dir, 'archive', '--work-id', work_id, '--actor', 'CODEX')
            self.run_cli(base_dir, 'restore', '--work-id', work_id, '--actor', 'GPT')
            rejected = self.run_cli(base_dir, 'accept', '--work-id', work_id, '--actor', 'CODEX', '--packet-path', str(packet_path), expect_ok=False)
            self.assertIn('STOP_HARD', rejected.stderr)
            self.assertIn('packet invalidated by restore', rejected.stderr)
            self.run_cli(base_dir, 'verify', '--work-id', work_id)

    def test_double_accept_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir, next_action='Emit packet')
            packet_text = self.emit_packet(base_dir, actor='CODEX', to_actor='GPT', work_id=work_id)
            packet_path = self.write_packet_copy(base_dir, packet_text)
            self.run_cli(base_dir, 'accept', '--work-id', work_id, '--actor', 'GPT', '--packet-path', str(packet_path))
            rejected = self.run_cli(base_dir, 'accept', '--work-id', work_id, '--actor', 'GPT', '--packet-path', str(packet_path), expect_ok=False)
            self.assertIn('STOP_HARD', rejected.stderr)
            self.assertIn('handoff already accepted', rejected.stderr)

    def test_stale_lock_detected(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir)
            lock_path = self.workroom(base_dir) / 'LOCKS' / f'{work_id}.lock'
            lock_payload = {
                'schema_version': 1,
                'work_id': work_id,
                'owner_pid': 1,
                'hostname': 'test-host',
                'actor': 'CODEX',
                'command': 'update',
                'started_at_utc': '2000-01-01T00:00:00Z',
            }
            lock_path.write_text(json.dumps(lock_payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
            failed = self.run_cli(base_dir, 'verify', expect_ok=False)
            self.assertIn('STOP_HARD', failed.stderr)
            self.assertIn('stale lock detected', failed.stderr)
            self.run_cli(base_dir, 'doctor')
            self.run_cli(base_dir, 'verify')

    def test_partial_txn_recovery_via_doctor_and_rebuild(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir)
            work_dir = self.work_dir_by_id(base_dir, work_id)
            txn_path = work_dir / 'TXN' / 'txn_2.json'
            txn_payload = {
                'schema_version': 1,
                'txn_sequence': 2,
                'work_id': work_id,
                'command': 'update',
                'actor': 'CODEX',
                'session_id': 'SESSION_PARTIAL',
                'status': 'PREPARED',
                'prepared_at_utc': '2026-03-10T00:00:00Z',
                'committed_at_utc': '',
                'aborted_at_utc': '',
                'message': '',
            }
            txn_path.write_text(json.dumps(txn_payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
            failed = self.run_cli(base_dir, 'verify', expect_ok=False)
            self.assertIn('doctor required', failed.stderr)
            self.run_cli(base_dir, 'doctor', '--work-id', work_id)
            self.run_cli(base_dir, 'rebuild', '--work-id', work_id)
            txn_after = self.load_json(txn_path)
            self.assertEqual('ABORTED', txn_after['status'])
            self.run_cli(base_dir, 'verify', '--work-id', work_id)

    def test_active_index_control_tower_and_live_state_are_consistent(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir, next_action='Inspect indexes')
            state = self.load_state(base_dir, work_id)
            active_index = self.load_active_index(base_dir)
            tower = self.load_control_tower(base_dir)
            self.assertEqual(1, len(active_index))
            self.assertEqual(work_id, active_index[0]['work_id'])
            self.assertEqual(state['next_action'], active_index[0]['next_action'])
            self.assertIn(work_id, tower)
            self.assertIn(state['primary_branch'], tower)
            self.run_cli(base_dir, 'verify')

    def test_archived_work_update_fails(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir, next_action='Archive it')
            self.run_cli(base_dir, 'complete', '--work-id', work_id, '--actor', 'CODEX')
            self.run_cli(base_dir, 'archive', '--work-id', work_id, '--actor', 'CODEX')
            failed = self.run_cli(base_dir, 'update', '--work-id', work_id, '--actor', 'CODEX', '--current-state', 'should-fail', '--next-action', 'never', expect_ok=False)
            self.assertIn('archived work cannot be updated', failed.stderr)

    def test_mirror_outputs_match_preferred_work(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir, next_action='Emit packet')
            self.emit_packet(base_dir, actor='CODEX', to_actor='GPT', work_id=work_id)
            state = self.load_state(base_dir, work_id)
            graph = self.load_graph(base_dir, work_id)
            events = self.load_events(base_dir, work_id)
            self.assertEqual(state, self.load_mirror_state(base_dir))
            self.assertEqual(graph, self.load_mirror_graph(base_dir))
            self.assertEqual(events, self.load_mirror_events(base_dir))
            self.assertEqual(self.load_packet(base_dir, work_id), self.load_mirror_packet(base_dir))
            self.run_cli(base_dir, 'verify')

    def test_rebuild_restores_all_derived_files_from_event_log(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir, next_action='Split work')
            self.run_cli(base_dir, 'split', '--work-id', work_id, '--actor', 'CODEX', '--branch-name', 'rebuild-case')
            work_dir = self.work_dir_by_id(base_dir, work_id)
            for relative in [
                Path('LIVE_STATE.json'),
                Path('GRAPH.json'),
                Path('HANDOFF_PACKET.txt'),
                Path('SUMMARY.md'),
            ]:
                (work_dir / relative).unlink()
            branch_root = work_dir / 'BRANCHES'
            for item in sorted(branch_root.iterdir(), reverse=True):
                if item.is_file():
                    item.unlink()
                else:
                    for nested in sorted(item.iterdir(), reverse=True):
                        nested.unlink()
                    item.rmdir()
            for global_path in [
                self.workroom(base_dir) / 'ACTIVE_INDEX.json',
                self.workroom(base_dir) / 'ARCHIVE_INDEX.json',
                self.workroom(base_dir) / 'CONTROL_TOWER.md',
                base_dir / 'docs' / 'MEP' / 'HANDOFF_LIVE_STATE.json',
                base_dir / 'docs' / 'MEP' / 'HANDOFF_EVENT_LOG.jsonl',
                base_dir / 'docs' / 'MEP' / 'HANDOFF_GRAPH.json',
                base_dir / 'docs' / 'MEP' / 'HANDOFF_PACKET.txt',
                base_dir / 'docs' / 'MEP' / 'HANDOFF_STATE.json',
                base_dir / 'docs' / 'MEP' / 'HANDOFF_EVENTS.jsonl',
            ]:
                global_path.unlink()
            self.run_cli(base_dir, 'rebuild', '--work-id', work_id)
            self.assertTrue((work_dir / 'LIVE_STATE.json').exists())
            self.assertTrue((work_dir / 'GRAPH.json').exists())
            self.assertTrue((work_dir / 'HANDOFF_PACKET.txt').exists())
            self.assertTrue((work_dir / 'SUMMARY.md').exists())
            self.assertTrue((self.workroom(base_dir) / 'ACTIVE_INDEX.json').exists())
            self.assertTrue((base_dir / 'docs' / 'MEP' / 'HANDOFF_LIVE_STATE.json').exists())
            self.run_cli(base_dir, 'verify')

    def test_owner_conflict_detected(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir)
            failed = self.run_cli(base_dir, 'update', '--work-id', work_id, '--actor', 'GPT', '--current-state', 'racing', '--next-action', 'should-stop', expect_ok=False)
            self.assertIn('owner conflict', failed.stderr)

    def test_verify_rejects_blocked_without_reason(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir, next_action='Complete work')
            self.run_cli(base_dir, 'complete', '--work-id', work_id, '--actor', 'CODEX')
            self.run_cli(base_dir, 'archive', '--work-id', work_id, '--actor', 'CODEX')
            self.run_cli(base_dir, 'restore', '--work-id', work_id, '--actor', 'GPT')
            state_path = self.work_dir_by_id(base_dir, work_id) / 'LIVE_STATE.json'
            state = self.load_json(state_path)
            state['block_reason_code'] = ''
            state['block_reason_text'] = ''
            state_path.write_text(json.dumps(state, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
            failed = self.run_cli(base_dir, 'verify', '--work-id', work_id, expect_ok=False)
            self.assertIn('BLOCKED state requires block_reason_code/text', failed.stderr)

    def test_complete_rejects_missing_required_evidence(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir)
            self.run_cli(base_dir, 'update', '--work-id', work_id, '--actor', 'CODEX', '--required-evidence', 'test-proof', '--next-action', 'Gather evidence')
            failed = self.run_cli(base_dir, 'complete', '--work-id', work_id, '--actor', 'CODEX', expect_ok=False)
            self.assertIn('required_evidence is incomplete', failed.stderr)

    def test_universal_packet_contains_required_keys(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base_dir = Path(tmp)
            work_id = self.start_work(base_dir, next_action='Emit packet')
            packet_text = self.emit_packet(base_dir, actor='CODEX', to_actor='GPT', work_id=work_id)
            self.assertTrue(packet_text.startswith('[UNIVERSAL_THREAD_PACKET v1]'))
            for key in PACKET_KEYS:
                self.assertIn(f'{key}=', packet_text)


if __name__ == '__main__':
    unittest.main()




