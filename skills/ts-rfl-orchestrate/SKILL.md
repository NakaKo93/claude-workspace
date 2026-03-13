---
name: ts-rfl-orchestrate
description: Analyzes Claude Code session JSONL logs to identify what needs fixing in agents, skills, hooks, or processes, and generates a structured fix task list (fixes.json). This skill should be used when the user explicitly asks to reflect on a session — trigger phrases include "反省して", "reflect", "review session", or "analyze what went wrong". Never auto-trigger; always run on explicit user request only.
disable-model-invocation: false
allowed-tools: Read
---

# Reflection Skill

Analyze the most recent Claude Code session JSONL logs, identify problems in agents/skills/hooks/env/process, and produce a `fixes.json` repair task list per log file.

For output JSON schemas and classification rules, see [`references/output-schema.md`](references/output-schema.md).

## Example Usage

- "反省して"
- "Reflect on the last session"
- "review session"
- "Analyze what went wrong"

## Scope

In scope: session JSONL log analysis, fix task generation, history-based deduplication, user-confirmed fix application
Out of scope: fully automatic fixes (without user confirmation), hook-triggered reflection, analysis of `thinking` block internals, generating `summary.md`

## Prerequisites

- Python 3.8+ available as `python` or `python3`
- Run from the `~/.claude` workspace root (where `docs/` and `projects/` live)
- Designed for local Claude Code sessions only — requires access to `~/.claude/projects/` on the local filesystem

---

## Steps

Execute all phases in order. Do not skip any phase without a clear reason.

### Phase 1: Extract Events

Invoke the `ts-rfl-extract` child skill using the `Skill` tool. The child skill will:
- Compute the project directory from the current working directory
- Locate all JSONL files under `~/.claude/projects/<current-project>/`
- Run `scripts/extract_events.py` for each file (deduplication handled by script)
- Apply triage: skip stubs (≤2 events), limit to top 5 sessions if >5 ok results
- Return an extraction report with a JSON list of `{artifacts_dir, events_count}` for sessions ready for analysis

If no sessions are ready (all skipped, excluded, or errored), inform the user and stop.

### Phase 2: Analyze Sessions

Pass the extraction report from Phase 1 to the `ts-rfl-analyze` child skill using the `Skill` tool. The child skill will:
- Read `references/output-schema.md` once for schema and classification rules
- Read each `reflection_input.json` from the provided artifacts list
- Analyze events, classify problems, and write `fixes.json` per session
- Append completed sessions to `docs/tmp/reflection/reflection_history/index.jsonl`
- Return an analysis report listing tasks and P0 counts per session

### Phase 3: Report to User

Present **only** the following summary — do not dump raw JSON:

```
Reflected:
  <filename>: <N> tasks (P0: <n>) → <artifacts_dir>
  <filename>: <N> tasks (P0: <n>) → <artifacts_dir>

Skipped (already reflected):
  <filename>

Proceed with fixes? [yes / no]
```

If the user confirms, proceed to Phase 4. If the user declines, stop.

### Phase 4: Apply Fixes

Pass the list of artifacts directories (from Phase 2) to the `ts-rfl-apply` child skill using the `Skill` tool. The child skill will:
- Read each `fixes.json`
- Apply each task according to its `proposed_fix.type`
- Return a summary of applied and skipped tasks

Present the apply summary to the user.

---

## Error Handling

- **No JSONL files found**: rfl-extract will report this; inform the user and stop.
- **All sessions already reflected**: Phase 3 report will show all as skipped; inform the user and stop.
- **Phase 2 produces no tasks**: Report "No issues found" and stop without proceeding to Phase 4.

---

## Limitations

- Does not apply fixes without user confirmation — Phase 4 runs only after the user explicitly confirms at Phase 3
- Does not trigger automatically via hooks
- Does not analyze `thinking` block internals
- Does not generate `summary.md`
- Does not delete existing logs
- Skips files already reflected with the same SHA-256 fingerprint
