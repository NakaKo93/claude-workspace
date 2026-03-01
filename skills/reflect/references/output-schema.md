# Reflection Output Schema Reference

## Table of Contents

- [Directory Structure](#directory-structure)
- [fixes.json](#fixesjson)
  - [target.kind Classification](#targetkind-classification)
  - [target.name Conventions](#targetname-conventions)
  - [Priority Definition](#priority-definition)
  - [proposed_fix.type Values](#proposed_fixtype-values)
- [reflection_input.json](#reflection_inputjson)
  - [Event kind Values](#event-kind-values)
  - [tool_result Trimming](#tool_result-trimming)
- [source.json](#sourcejson)
- [reflection_history/index.jsonl](#reflection_historyindexjsonl)

---

## Directory Structure

```
docs/tmp/reflection/
  artifacts/
    <encoded_source_path>/
      source.json
      reflection_input.json
      fixes.json
      errors.json        (optional — only when extraction errors occurred)
  reflection_history/
    index.jsonl
```

`<encoded_source_path>` is derived from the JSONL filename + first 8 chars of its fingerprint, with path separators replaced by `__`. Example:

```
agent-a4eab02.jsonl (fingerprint: ef62abcd...)
→ agent-a4eab02.jsonl__ef62abcd
```

---

## fixes.json

Written to `<artifacts_dir>/fixes.json` after analysis.

```json
{
  "source_log": "/abs/path/to/<sessionId>.jsonl",
  "fingerprint": "<sha256hex>",
  "generated_at": "2026-02-23T12:00:00Z",
  "tasks": [
    {
      "id": "T-001",
      "priority": "P0",
      "target": {
        "kind": "agent|skill|hooks|env|process",
        "name": "skill:reflection"
      },
      "problem": "One-sentence summary of the problem.",
      "evidence": [
        {
          "event_index": 12,
          "ts": "2026-02-23T11:58:00Z",
          "quote": "Exact excerpt from the event that demonstrates the problem."
        }
      ],
      "proposed_fix": {
        "type": "prompt_change|code_change|config_change|behavior_rule",
        "location": "File path or config section to modify",
        "steps": [
          "Specific step 1",
          "Specific step 2"
        ]
      },
      "acceptance_test": [
        "Condition that confirms the fix is working."
      ]
    }
  ],
  "stats": {
    "events_used": 50,
    "tool_errors": 1
  }
}
```

### target.kind Classification

| kind | Assign when |
|---|---|
| `agent` | Intent misunderstood / wrong skill delegated / inappropriate next action |
| `skill` | I/O contract unclear / output unstable / missing preconditions / repeated pattern → candidate for new skill |
| `hooks` | Trigger timing wrong / logging insufficient |
| `env` | Path / bash / execution environment issue |
| `process` | Workflow design problem / repeated ad-hoc subagent delegation → candidate for dedicated subagent |

### target.name Conventions

| Pattern | Example |
|---|---|
| Existing skill | `"skill:reflection"` |
| Candidate new skill | `"skill:candidate:git-status-check"` |
| Candidate new subagent | `"subagent:candidate:test-runner"` |

### Priority Definition

| priority | Meaning |
|---|---|
| P0 | Fix immediately — incorrect behavior, misinterpretation, critical error |
| P1 | Quality improvement |
| P2 | Refactoring |

### proposed_fix.type Values

| type | Use when |
|---|---|
| `prompt_change` | Updating SKILL.md body, CLAUDE.md, or agent system prompt |
| `code_change` | Modifying a script file |
| `config_change` | Changing settings.json, hooks config, or permissions |
| `behavior_rule` | Adding a rule specific to the ~/.claude workspace (CLAUDE.md + MEMORY.md). Do NOT use for cross-project rules — those belong in a knowledge skill. |
| `knowledge_skill_update` | Appending a new rule or item to a knowledge skill's reference file — use when the insight is a recurring behavioral pattern that belongs in a knowledge skill's permanent reference content (e.g., a new stop-and-confirm trigger, a new anti-pattern, a new scope boundary rule) |

---

## reflection_input.json

Written by `extract_events.py` to `<artifacts_dir>/reflection_input.json`. Read this file during analysis.

```json
{
  "source_log": "/abs/path/to/<sessionId>.jsonl",
  "fingerprint": "<sha256hex>",
  "events": [
    {
      "ts": "2026-02-23T11:58:00Z",
      "kind": "user",
      "text": "User message content."
    },
    {
      "ts": "2026-02-23T11:58:01Z",
      "kind": "assistant",
      "text": "[tool_use: Bash]",
      "tool": {
        "name": "Bash",
        "input": { "command": "ls ~/.claude/agents" }
      }
    },
    {
      "ts": "2026-02-23T11:58:02Z",
      "kind": "tool",
      "tool": {
        "name": "Bash",
        "input": { "command": "ls ~/.claude/agents" },
        "output": "code-reviewer.md\ntest-runner.md",
        "is_error": false
      }
    }
  ]
}
```

### Event kind Values

| kind | Source |
|---|---|
| `user` | User message (`type == "user"` in JSONL) |
| `assistant` | Assistant text or tool_use block (`type == "assistant"`) |
| `tool` | Tool result (`type == "tool_result"`) |

### tool_result Trimming

The script applies these trim limits to `tool.output`:

| Condition | Head kept | Tail kept |
|---|---|---|
| Normal result (`is_error: false`) | 800 chars | 200 chars |
| Error result (`is_error: true`) | 2000 chars | 400 chars |

---

## source.json

Minimal metadata written alongside `reflection_input.json`.

```json
{
  "source_log": "/abs/path/to/<sessionId>.jsonl",
  "fingerprint": "<sha256hex>"
}
```

---

## reflection_history/index.jsonl

Append-only log. One JSON object per line. Never delete or modify existing entries.

```json
{"ts": "2026-02-23T12:00:00Z", "source_log": "/abs/path/...", "fingerprint": "<sha256>", "status": "done", "artifacts_dir": "docs/tmp/reflection/artifacts/...", "tasks_count": 3, "p0_count": 1}
```

| Field | Type | Meaning |
|---|---|---|
| `ts` | ISO 8601 string | When this reflection was recorded |
| `source_log` | string | Absolute path to the JSONL log |
| `fingerprint` | string | SHA-256 hex digest of the log |
| `status` | `"done"` \| `"skipped"` | Outcome |
| `artifacts_dir` | string | Path to the artifacts directory |
| `tasks_count` | integer | Total number of tasks in fixes.json |
| `p0_count` | integer | Number of P0 tasks |
