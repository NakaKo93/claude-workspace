---
name: create-task-skill
description: Creates a new Claude Code Task Skill from scratch, guiding through requirements, resource planning, initialization, and content writing. This skill should be used when users want to create a Task Skill (with scripts and a step-by-step workflow) — invoked by the create-skill orchestrator when the user selects Task Skill.
disable-model-invocation: false
allowed-tools: Bash, Read, Write, Edit, Glob
---

# Create Task Skill

Create a new Claude Code Task Skill by understanding requirements, planning resources, initializing the skill directory, and writing effective content.

For skill anatomy, frontmatter fields, bundled resources, and Progressive Disclosure architecture, see [references/about-skills.md](references/about-skills.md).
For skill design rules (single purpose, module limits, split/orchestrator decisions, naming), see [~/.claude/docs/reference/claude/skills/design-rules.md](~/.claude/docs/reference/claude/skills/design-rules.md).

## Example Usage

- "Create a new skill that summarizes GitHub PRs"
- "Build a skill for converting PDF files"
- "スキルを作って"
- "新しいスキルを作りたい"
- "Make a skill for querying our BigQuery database"

---

## Steps

### Step 1: Understand the Skill with Concrete Examples

If the skill's purpose, trigger phrases, and content are already defined in the current context
(e.g. from a plan, a prior discussion, or an explicit specification), skip this step and proceed to Step 2.

Otherwise, ask the user for concrete examples of how the skill will be used. Key questions:

- "What functionality should the skill support?"
- "What would a user say to trigger this skill?"
- "Can you give 2–3 examples of actual use?"

Avoid asking too many questions at once. Start with the most important and follow up as needed. Conclude when the purpose and trigger phrases are clear.

### Step 2: Plan Skill Architecture and Reusable Contents

**Architecture check — resolve before building:**

| Question | Yes → | No → |
|---|---|---|
| Goal expressible in **one sentence**? | Proceed | Split into focused sub-skills |
| Planned workflow has **≤3 top-level steps**? | Proceed | Evaluate split (see below) |
| Sub-skills always run in fixed sequence? | Consider orchestrator | Use linear chain or call independently |

**If splitting is needed:** define each sub-skill independently first, then decide if an orchestrator skill is needed. Read [references/design-rules.md](references/design-rules.md) for the full split/orchestrator decision tree and orchestrator template.

**Content classification — decide before writing anything:**

| Question | → Location |
|---|---|
| Will a human read and agree on this as a shared standard or policy? | `docs/reference/` (link from SKILL.md) |
| Is this needed only when Claude executes this skill? | `references/<topic>.md` |
| Is this a few-shot example, output template, or I/O schema? | `references/<topic>.md` |
| Does this define shared naming, design, or review rules? | `docs/reference/` (link from SKILL.md) |

Do NOT put skill-execution content (examples, templates, decision tables) in `docs/`. Do NOT copy `docs/` content into `references/` — link instead.

**References per step — enumerate before writing:**

For each workflow step, explicitly list what reference file it needs:

```
Step 1: <topic> → references/<file>.md  (or "none")
Step 2: <topic> → references/<file>.md
Step 3: <topic> → references/<file>.md
```

Missing a reference file here means the step will lack supporting detail. Create all planned reference files in Step 4 before writing SKILL.md.

**Reusable resources:** for each concrete example, identify resources that eliminate repetitive work:

| Repeated work | Resource to create |
|---|---|
| Same code generated every run | `scripts/<name>.py` |
| Same template used every run | `assets/<template>` |
| Same reference looked up every run | `references/<topic>.md` |

Produce a complete list of docs links and reference files before proceeding.

### Step 3: Initialize the Skill

Run the init script to create the skill directory:

```bash
SKILL_SCRIPTS=~/.claude/skills/create-task-skill/scripts
python $SKILL_SCRIPTS/init_skill.py <skill-name> --path ~/.claude/skills
```

**Naming:** Use `verb-noun` format (e.g., `create-skill`, `validate-skill`, `reflect`). The name should make the trigger obvious. Hyphen-case, max 64 characters, no leading/trailing/consecutive hyphens.

**Skill placement:**

| Location | Scope |
|---|---|
| `~/.claude/skills/<skill-name>/` | Personal (all projects) |
| `.claude/skills/<skill-name>/` | Project-scoped |

Skip this step only if the skill directory already exists.

**After initialization, remove unused template directories:**

`init_skill.py` creates `scripts/` and `assets/` as placeholders. If the skill does not need them, remove them now — empty directories cause validation to fail:

```bash
# Remove only the directories the skill will NOT use
rmdir ~/.claude/skills/<skill-name>/scripts
rmdir ~/.claude/skills/<skill-name>/assets
```

### Step 4: Edit the Skill

Start with reusable resources (`scripts/`, `references/`, `assets/`), then write SKILL.md.

**Before writing SKILL.md:** `init_skill.py` has already generated a placeholder `SKILL.md`. The Write tool requires a prior Read before overwriting an existing file — Read it first, then Write.

**Language:** Write all skill content in English.

**Apply Progressive Disclosure** — keep SKILL.md lean; move supporting detail to `references/`:

| Content type | Location |
|---|---|
| Overview, core workflow, key rules | SKILL.md body |
| Reference tables, large examples | `references/<topic>.md` |
| Repeated code / deterministic logic | `scripts/<name>.py` |
| Templates, binary assets | `assets/` |

**SKILL.md required sections:** Overview (recommended), Example Usage (≥2, required), Steps (required), Error Handling (required), Limitations (recommended).

**`description` field:** Write in third person, ≤2 sentences. Include explicit trigger phrases.

**`disable-model-invocation`:** Always write `false` unless the user explicitly instructs otherwise.

Delete any unused example files (`scripts/example.py`, `references/api_reference.md`, `assets/example_asset.txt`) after editing.

### Step 5: Validate and Review

Invoke `validate-task-skill` to run structural checks and self-review:

```
/validate-task-skill <path/to/skill>
```

---

## Error Handling

- **No context provided**: Ask clarifying questions in Step 1. Do not proceed to Step 3 without a clear purpose.
- **`init_skill.py` fails**: Verify the target `--path` exists and the skill name follows hyphen-case conventions.
- **Packaging requested**: Run `scripts/package_skill.py <path/to/skill>` — only when the user explicitly requests a zip file.
- **Out-of-scope request** (installing, enabling, disabling, or deleting skills): Explain scope and direct to Claude Code documentation.

## Limitations

- Does not handle skill installation, activation, deactivation, or deletion.
- Cannot manage versioning or dependencies between skills.
- Does not validate semantic correctness — structural checks are handled by `validate-task-skill`.
