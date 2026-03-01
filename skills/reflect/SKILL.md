---
name: reflect
description: Analyzes Claude Code session JSONL logs to identify what needs fixing in agents, skills, hooks, or processes, and generates a structured fix task list (fixes.json). This skill should be used when the user explicitly asks to reflect on a session — trigger phrases include "反省して", "reflect", "review session", or "analyze what went wrong". Never auto-trigger; always run on explicit user request only.
disable-model-invocation: false
allowed-tools: Bash, Read, Write, Glob
---

# Reflection Skill

Analyze the most recent Claude Code session JSONL logs, identify problems in agents/skills/hooks/env/process, and produce a `fixes.json` repair task list per log file.

For output JSON schemas and classification rules, see [`references/output-schema.md`](references/output-schema.md).

## Example Usage

Typical user messages that trigger this skill:

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

Execute all steps in order. Do not skip any step without a clear reason.

### Step 1: Locate JSONL Log Files

Determine the log directory for the **current project** and find all JSONL session files within it:

```bash
# Compute current project directory name
# ~/.claude/projects/ uses the working directory path with :, \, /, . replaced by -
WIN_PWD=$(pwd -W 2>/dev/null || pwd)
PROJ_DIR=$(echo "$WIN_PWD" | tr ':\\/.' '-')
PROJ_PATH=~/.claude/projects/"$PROJ_DIR"

find "$PROJ_PATH" -name "*.jsonl" 2>/dev/null | sort
```

If the directory does not exist, list `~/.claude/projects/` to confirm the expected name, inform the user, and stop. If no `.jsonl` files are found inside the directory, inform the user and stop.

Collect **all** JSONL files found across all session directories. Files that have already been reflected will be skipped automatically in Step 2 (status: `"skip"`).

**Triage for large session counts**: After running Step 2 for all files, check how many returned `"ok"`. If more than 5:
1. Read each `<artifacts_dir>/reflection_input.json` and check `events_count`.
2. Sessions with ≤ 2 events are stubs with no meaningful content — skip them entirely. **Do not write a `fixes.json` or `index.jsonl` entry for stubs.** They will remain unregistered and can be re-evaluated in future runs.
3. Sort the remaining sessions by `events_count` descending and process the **top 5** in this run. Leave the rest unreflected (no index entry) for a subsequent session.

### Step 2: Run Extraction Script for Each File

Run `scripts/extract_events.py` for each JSONL file. The script parses events, computes a SHA-256 fingerprint for deduplication, and writes `reflection_input.json` to the artifacts directory.

```bash
SCRIPTS=~/.claude/skills/reflect/scripts
python $SCRIPTS/extract_events.py "<jsonl_path>" --reflection-root docs/tmp/reflection
```

The script outputs a single JSON line to stdout. Capture it and check the `status` field:

| status | Meaning | Action |
|---|---|---|
| `"skip"` | Already reflected with the same fingerprint | Log as skipped; continue to next file |
| `"error"` | File not found or unreadable | Log the error; continue to next file |
| `"ok"` | Extraction succeeded | Proceed to Step 3 with `artifacts_dir` |

### Step 3: Analyze Events and Generate fixes.json

For each file where extraction returned `"ok"`:

1. Read `<artifacts_dir>/reflection_input.json`
2. Read `references/output-schema.md` for schema and classification rules
3. Analyze all events to identify concrete problems
4. Write `<artifacts_dir>/fixes.json` following the schema

**Analysis guidelines:**

Use judgment to classify each problem, guided by the classification tables below. There is no single correct answer — prioritize the category that best describes the root cause.

**Rule generality:** When writing `proposed_fix` rules, prefer **general principles** over situation-specific ones. Ask: "Would this rule apply only to this exact scenario, or would it prevent a whole class of similar mistakes?" A rule that says "always clarify ambiguous requests before implementing" is reusable; one that says "ask what notification method the user prefers" is not. Overly specific rules consume context budget without adding value.

**Knowledge Skill routing — decision order:**

Step A: Is this rule specific to the ~/.claude workspace only?
- YES (e.g., skill directory conventions, workspace-specific workflow rules)
  → use `behavior_rule` → CLAUDE.md (workspace-scoped, intentional)
- NO (e.g., tool usage, coding patterns, implementation behavior)
  → continue to Step B

Step B: Does an existing knowledge skill cover this domain?
- Scope/confirmation/clarification behavior → `clarification-rules/references/scope-and-confirmation-rules.md`
- Tool execution / implementation behavior → `implementation-conventions/references/rules.md`
- No matching skill exists → use `knowledge_skill_update` targeting `implementation-conventions/references/rules.md` as a catch-all
→ use `knowledge_skill_update`

Key principle: `behavior_rule` is for workspace-specific rules only.
Cross-project behavioral rules must always go to a knowledge skill.

Assign each problem a `target.kind` using this table:

| kind | Assign when |
|---|---|
| `agent` | Intent was misunderstood / wrong skill delegated / next action was inappropriate |
| `skill` | I/O contract unclear / output unstable / missing precondition |
| `hooks` | Trigger timing wrong / logging insufficient |
| `env` | Path / bash / execution environment issue |
| `process` | Workflow design problem |

Assign priority:

| priority | Meaning |
|---|---|
| P0 | Fix immediately — incorrect behavior, misinterpretation, critical error |
| P1 | Quality improvement |
| P2 | Refactoring |

For each task, provide `evidence` with the exact `event_index`, `ts`, and a direct `quote` from the log. Keep `proposed_fix.steps` concrete and actionable.

5. **Only after completing item 3 (actual analysis)**, write a one-line entry to `docs/tmp/reflection/reflection_history/index.jsonl` (create file if absent). **Never write an index entry for sessions that were triaged out, skipped due to stub size, or volume-limited** — doing so permanently blocks future analysis of those sessions.

```json
{"ts": "<ISO8601>", "source_log": "<path>", "fingerprint": "<sha256>", "status": "done", "artifacts_dir": "<dir>", "tasks_count": <n>, "p0_count": <n>}
```

**Critical — Windows path escaping**: Copy the `source_log` and `fingerprint` values **verbatim from the script's stdout JSON output** — do not manually retype the Windows path. The script emits correctly double-escaped backslashes (`C:\\Users\\...`) required for valid JSON. Manually typed single backslashes (`C:\Users\...`) produce invalid JSON that silently breaks the deduplication check on every subsequent run.

Correct example:
```json
{"ts": "2026-03-01T16:00:00Z", "source_log": "C:\\Users\\nakakou\\.claude\\projects\\...\\session.jsonl", "fingerprint": "abc123...", "status": "done", "artifacts_dir": "docs/tmp/reflection/artifacts/session.jsonl__abc123", "tasks_count": 1, "p0_count": 0}
```

### Step 4: Report to User

Present **only** the following summary — do not dump raw JSON:

```
Reflected:
  <filename>: <N> tasks (P0: <n>) → <artifacts_dir>
  <filename>: <N> tasks (P0: <n>) → <artifacts_dir>

Skipped (already reflected):
  <filename>

Proceed with fixes? [yes / no]
```

Example:

```
Reflected:
  6de9aed1.jsonl: 1 task (P0: 1) → docs/tmp/reflection/artifacts/6de9aed1.jsonl__011e6906

Proceed with fixes? [yes / no]
```

If the user confirms, proceed to Step 5.

### Step 5: Apply Fixes

Read `<artifacts_dir>/fixes.json` and apply each task according to its `proposed_fix.type`:

| type | Where to apply | How |
|---|---|---|
| `behavior_rule` | `~/.claude/.claude/CLAUDE.md` (Key Constraints section) and memory | Add the rule as a bullet under the relevant heading; also save to `MEMORY.md` for cross-session persistence |
| `prompt_change` | File specified in `proposed_fix.location` | Edit the SKILL.md body, agent file, or CLAUDE.md section named in the task |
| `code_change` | Script file specified in `proposed_fix.location` | Edit or rewrite the relevant function/section |
| `config_change` | Config file specified in `proposed_fix.location` | Edit settings.json, hooks config, or permissions as described |
| `knowledge_skill_update` | Reference file specified in `proposed_fix.location` (e.g., `skills/clarification-rules/references/scope-and-confirmation-rules.md`) | Append the new item to the appropriate section of the reference file |

After applying all tasks, confirm to the user which tasks were applied and which (if any) were skipped and why.

---

## Error Handling

- **No JSONL files found**: Inform the user and stop.
- **Script exits non-zero**: Display the error, skip that file, continue with the rest.
- **Empty events list after extraction**: Note in the report that the file had no analyzable events; skip `fixes.json` generation for that file.
- **Malformed JSONL lines**: The script skips unparseable lines and continues; proceed with whatever events were extracted.

---

## Limitations

- Does not apply fixes without user confirmation — Step 5 runs only after the user explicitly confirms at Step 4
- Does not trigger automatically via hooks
- Does not analyze `thinking` block internals
- Does not generate `summary.md`
- Does not delete existing logs
- Skips files already reflected with the same SHA-256 fingerprint
