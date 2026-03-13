# Orchestration Phases

This document defines the full build pipeline executed by the `ts-wfsk-orchestrate` skill (Step 2).
Each phase lists the responsible child skill, inputs, and expected outputs.

---

## Phase 1 — Requirement Structuring (inline — no child skill)

Organize the clarified user inputs into a requirement memo:

| Field | Description |
|-------|-------------|
| `goal` | One-sentence statement of what the workflow accomplishes |
| `triggers` | Trigger phrases and conditions |
| `scope` | `user` (global) or `project` (local) |
| `constraints` | Tools to avoid, preferred models, known existing assets |
| `output_expectations` | What the finished workflow should produce |

---

## Phase 2 — Design

**Invoke**: `ts-wfsk-design` (via Skill tool)
**Input**: Requirement memo
**Output**: Design document (components, responsibility split, flow, review criteria)

---

## Phase 3 — Reuse Research

**Invoke**: `ts-wfsk-research` (via Skill tool)
**Input**: Requirement memo + design document
**Output**: Reuse report (existing assets, gap analysis, new items needed)

---

## Phase 4 — Subagent Creation (only if new subagents are needed)

**Invoke**: `ts-wfsk-build-subagent` (via Skill tool)
**Condition**: Only if the reuse report's gap analysis identifies subagents to create
**Input**: Design document + reuse report + list of subagents to build
**Output**: Created file paths and frontmatter decisions

---

## Phase 5 — Skill Creation

**Invoke**: `ts-wfsk-build-skill` (via Skill tool)
**Input**: Design document + reuse report + subagent definitions
**Output**: Created SKILL.md and references/ paths

---

## Phase 6 — Review

**Invoke**: `ts-wfsk-review` (via Skill tool)
**Input**: All artifacts from Phases 2–5
**Output**: Review report (pass/fail per criterion, issues, recommended fixes)

---

## Phase 7 — Rework (if needed)

**Condition**: Reviewer reports ❌ Critical issues
**Action**:
1. Identify the responsible child skill (wfsk-design / wfsk-research / wfsk-build-subagent / wfsk-build-skill)
2. Re-invoke that child skill with the reviewer's specific feedback
3. Re-run Phase 6

---

## Constraints

- Pass only the minimum necessary context to each child skill.
- Track intermediate outputs as short summaries, not full file dumps.
- If a child skill returns with `issues` containing only ✅, proceed to the next phase.
- Do not implement design decisions yourself — delegate to the appropriate child skill.
