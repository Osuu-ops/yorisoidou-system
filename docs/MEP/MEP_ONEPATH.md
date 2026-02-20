# MEP One-Path (Fixed Wiring)

- generated_at: 20260220_115828

## Canonical Entry
- Start: Issue draft -> artifacts -> Gate0 audit -> Gate1 packet -> /mep run

### Step 0 (Artifacts Build)
- workflow: mep_standalone_autoloop_dispatch_v2.yml
- outputs: docs/MEP/ARTIFACTS/<LANE>/ISSUE_<N>/{AUDIT.md,MERGED_DRAFT.md,INPUT_PACKET.md,RUN_SUMMARY.md,RESTART_PACKET.txt}

### Step 1 (Gate0 Audit/Compile/Dispatch)
- workflow: mep_gate0_audit_compile_dispatch.yml (workflow_dispatch)
- action: if OK -> comment '/mep run' to Issue

### Step 2 (Gate1 Packet Filter)
- workflow: mep_8gate_entry_filter.yml (workflow_dispatch)
- action: validate_input_packet.py; if OK -> comment '/mep run' to Issue

### Step 3 (Receiver: IssueOps)
- workflow: mep_issueops_run.yml (issue_comment created; body contains '/mep run')
- action: python tools/agent/issueops.py

### Step 4 (Runner Loop: next_action)
- workflow(s): mep_gate0_unified_entry.yml / mep_entry_exec_nextaction_dispatch.yml / mep_entry_clean.yml
- action: runner.py status -> apply-safe -> merge-finish -> dispatch writeback

### Step 5 (Gate8 Writeback Entry)
- workflow: mep_writeback_bundle_dispatch_entry.yml (ID=228815143)
- outputs: Bundled/EVIDENCE updates + RESTART_PACKET artifact + Gate12 Health step

### Step 6 (Gate11 Handoff / Gate12 Health)
- handoff: mep_handoff_dispatch.yml (if used by writeback/runner policies)
- health: tools/mep_health_generate.ps1 (+ smoke: mep_health_smoke_dispatch.yml)

## Success Evidence (must exist)
- PR created + required checks pass + merge
- writeback evidence lines
- restart-packet artifact / comment
- handoff.md updated
- mep_health.json/md generated (artifact OK)
