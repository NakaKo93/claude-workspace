# Scope and Confirmation Rules

Rules for when Claude must stop and ask the user before proceeding, and how to
determine the correct scope of any change.

---

## 1. Stop-and-Confirm Triggers (MUST ask before proceeding)

Claude must pause and ask the user when any of the following conditions apply:

- **Target is ambiguous** — "which file / skill / section?" is unspecified and
  multiple candidates exist
- **Method/approach is ambiguous** — multiple valid approaches exist and none
  was explicitly specified by the user
- **Change count is ambiguous** — the request could logically apply to 1 or N
  places; do not assume N without confirmation
- **Request uses vague verbs without specifying what** — words like "improve",
  "fix", "update", or "clean up" without naming the specific aspect to change

Asking is always cheaper than undoing unwanted changes.

---

## 2. Scope Boundaries

**In scope**: only what the user explicitly named in the request.

**Out of scope**: related improvements, "while we're at it" fixes, adjacent
files not mentioned, or anything that requires inferring intent beyond what was
stated.

Specific rules:

- "Add a rule to X" → change X only. Not X plus all documents that reference X.
- "Fix this function" → fix that function. Not the surrounding code, tests,
  or related utilities unless they were mentioned.
- If multiple files contain similar content, confirm which to change before
  changing all of them.
- Do not expand scope to "related" files without explicit instruction.

---

## 3. Anti-Patterns (Claude's common mistakes in this workspace)

Patterns that must be actively avoided:

| Anti-pattern | What happens | Correct behavior |
|---|---|---|
| Scope creep | Asked to add a rule to one file; edits several related files | Edit only the named file |
| Ambiguity → autonomy | Request is unclear; Claude fills in details and proceeds | Stop and ask what was intended |
| Alternatives as clarification | Proposes Options A/B/C instead of asking what the user wants | Ask a direct question about the intended approach |
| "While we're at it" changes | Adds unrequested improvements alongside the actual task | Do exactly what was asked, nothing more |
| Count assumption | Assumes "update all occurrences" when only one was implied | Confirm whether the change should apply to one or all |

---

## 4. When It Is OK to Proceed Without Confirming

Claude may proceed immediately when **all** of the following are true:

1. The target is explicitly named (specific file, section, or function)
2. The method or approach is explicitly stated or has only one reasonable interpretation
3. The scope is unambiguous (one location, clearly bounded)
4. The change is reversible (no destructive operations, no shared-state side effects)

If any of these conditions is not met, default to asking.
