# Skill Design Rules

Evidence-based rules for building focused, high-performing Claude Code skills.
Load this file when planning a new skill or deciding whether to split, merge, or add an orchestrator.

## Table of Contents

- [Core Rules](#core-rules)
- [Split vs. Consolidate Decision](#split-vs-consolidate-decision)
- [Orchestration Pattern](#orchestration-pattern)
- [Naming Convention](#naming-convention)
- [Real-World Example](#real-world-example)

---

## Core Rules

| Category | Rule | Rationale | How to apply |
|---|---|---|---|
| Single purpose | 1 Skill = 1 clear goal | Mixed goals reduce success rate | Goal must be expressible in one sentence |
| Module count | Limit to 2–3 modules | Focused Skills perform best (SkillsBench) | Count top-level steps; if 4+, split |
| Content density | Avoid exhaustive descriptions | Excess information degrades performance | Write procedures, not encyclopedias |
| Structure | Procedural (step-by-step) | Explicit steps improve output quality | Write "what to do" in numbered order |
| Reusability | Split into reusable units | Skill chaining is effective | Ask: can this unit serve other tasks independently? |
| Split rule | Redesign when modules ≥ 4 | Over-information is a performance signal | Create independent skills per goal |
| Merge rule | Merge when tightly coupled with same goal | Over-splitting adds complexity | Single goal = single skill |
| Chain design | Use skill chains for complex flows | Internal simplicity + external composition | Each skill stays focused; chain handles flow |
| Orchestrator body | No detailed steps in orchestrator | Duplicate instructions become noise | Orchestrator lists `/skill-name` calls only |
| Chain depth | Avoid excessive chaining | Cognitive load grows with depth | Keep chains to ~5 invocations maximum |
| Auto-generation | Do not rely on auto-generated skills | Self-generation underperforms | Hand-craft skill structure |
| Model size | Small models can be effective | Skills compensate for model limitations | Use skills to enable cost optimization |
| Naming | Use verb+purpose format | Improves trigger accuracy | Examples: `create-skill`, `reflect`, `validate-skill` |
| Description | State trigger conditions explicitly | Enables precise invocation decisions | Include "when X, use this skill" phrasing |
| Maintenance | Consolidate when similar skills accumulate | Prevents structural bloat | Review installed skills periodically |
| Externalization | SKILL.md = flow only; judgment detail → `references/` | Inline criteria add context bloat and are hard to maintain | Tables, checklists, format specs, examples → `references/`; keep only step sequence + descriptions in SKILL.md |
| Reference granularity | One reference file = one step or topic | Bundling multiple steps' detail forces loading unneeded context | Split by step (`step1-format.md`, `step2-criteria.md`), not by broad block (`all-formats.md`) |
| Reference readability | Reference files with 100+ lines must include a table of contents at the top | Long files without navigation require scanning entire content to find relevant section | Add `## Table of Contents` with anchored links after the opening description |

---

## Split vs. Consolidate Decision

Use this flowchart when scoping a skill in Step 2:

```
1. Can the goal be stated in ONE sentence?
   └── No  → Split into focused sub-skills, then restart for each

2. Count the planned top-level workflow steps (modules):
   ├── 2–3 → Keep as a single skill ✅
   └── 4+  → Consider splitting ⚠️
              └── Do the sub-units have independent value?
                  ├── Yes → Split + evaluate if orchestrator is needed (see below)
                  └── No  → Keep as single skill (document the justification)

3. Do the sub-skills always run together in a fixed sequence?
   ├── Yes + combined flow is large → Create an orchestrator skill
   ├── Yes + one naturally ends with "invoke X" → Use a linear chain (simpler)
   └── No  → Call sub-skills independently as needed
```

**Merge check** — before splitting, verify the opposite is not true:
- If two skills share the exact same goal and are always used together → merge them
- Over-splitting creates unnecessary complexity

---

## Orchestration Pattern

### When to create an orchestrator skill

Create an orchestrator when ALL of the following are true:

1. Two or more sub-skills **always run together** in sequence
2. The combined flow would exceed 3 modules in a single skill
3. Each sub-skill has **independent value** when called alone

If only conditions 1 and 2 hold (sub-skills have no independent value), keep them merged.

### Orchestrator body rules

An orchestrator skill MUST:
- Contain ONLY sub-skill invocations — no procedural steps
- State the sequence and what each sub-skill produces
- Pass output context between sub-skills if needed

An orchestrator MUST NOT:
- Repeat the detailed steps already in sub-skills
- Contain conditional logic (split into sub-skills instead)

### Orchestrator template

```markdown
## Steps

Invoke sub-skills in this order:

1. `/sub-skill-a` — [one-line description of what it produces]
2. `/sub-skill-b <output-from-step-1>` — [one-line description]
3. `/sub-skill-c` — [one-line description]

Pass the output of each step as input to the next where applicable.
```

### When NOT to use an orchestrator

- Sub-skills are rarely called together → call them independently
- One skill naturally ends with "now invoke X" → this is a **linear chain** (simpler, preferred)

---

## Naming Convention

Format: `verb-noun` or `verb-noun-qualifier` in hyphen-case.

| Pattern | Good examples | Avoid |
|---|---|---|
| verb + object | `create-skill`, `validate-skill`, `reflect` | `skill-creator`, `reflection` |
| verb + object + qualifier | `review-pr-security`, `format-commit-msg` | `pr-review-tool` |
| role/enforcer (-er suffix) | `tdd-enforcer`, `lint-guard` | `test-helper`, `linting` |

**Rule:** The name should make the trigger obvious. A user reading the name should know when to invoke the skill.

---

## Real-World Example

**Original:** `skill-creator` — 8 workflow modules, 6 resource files.

**Problem:** Module count (8) far exceeded the 2–3 limit. Mixed two distinct purposes: creation workflow + validation/review.

**Split applied:**

```
skill-creator (8 modules)
  ├── create-skill (Steps 1–4: 4 modules) — creation workflow
  │     └── ends with "/validate-skill" → linear chain, no orchestrator needed
  └── validate-skill (Steps 4.5+4.8: 3 modules) — validation workflow
        └── can be invoked standalone for updates/reviews
```

**Why no orchestrator?** `create-skill` always ends by calling `validate-skill`, but `validate-skill` has independent value. A linear chain (one skill calls the next at the end) is simpler than a dedicated orchestrator.

**Result:** Each skill now has a single, expressible goal and stays within the 2–3 module target.
