---
name: ts-rfl-extract
description: Locates JSONL session logs for the current project and runs extract_events.py to produce reflection artifacts. Used by ts-rfl-orchestrate in Phase 1.
context: fork
agent: rfl-extract
---

# rfl-extract

Locate JSONL log files for the current project and extract structured events for reflection.

## Task Purpose

Enumerate all JSONL session logs under `~/.claude/projects/<current-project>/`, run `scripts/extract_events.py` for each, apply triage rules, and return a list of extracted artifacts ready for analysis.

## Input

Passed by the orchestrator:
- Current working directory context (used to compute the project directory name)

## Task-Specific Conditions

- Compute the project directory by transforming the current working directory path: replace `:`, `\`, `/`, `.` with `-`
- Run `extract_events.py` for **all** JSONL files found; the script handles deduplication via SHA-256 fingerprint
- After extraction, apply triage to sessions with `status: "ok"`:
  1. Read `events_count` from each `<artifacts_dir>/reflection_input.json`
  2. Exclude sessions with `events_count ≤ 2` (stubs — no meaningful content)
  3. If more than 5 non-stub sessions remain, sort by `events_count` descending and return only the top 5
- Do NOT write `fixes.json` or `index.jsonl` entries — that is rfl-analyze's responsibility

## Output Format

Return an extraction report followed by a JSON array for the orchestrator:

```
## Extraction Report

### Extracted (ready for analysis)
| artifacts_dir | events_count |
|---|---|
| docs/tmp/reflection/artifacts/<dir> | 42 |

### Skipped (already reflected)
- <filename>

### Excluded (stub — ≤2 events)
- <filename>

### Errors
- <filename>: <error message>
```

Followed by the JSON array:

```json
[
  {"artifacts_dir": "docs/tmp/reflection/artifacts/<dir>", "events_count": 42}
]
```
