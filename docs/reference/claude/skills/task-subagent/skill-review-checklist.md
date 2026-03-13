# Skill Review Checklist

Derived from `docs/reference/claude/skills/` (overview.md / spec.md / best-practices.md / examples.md).
Load this file during the ts-val-orchestrate workflow to perform a self-review before finalizing.

Legend: ❌ = must fix before packaging | ⚠️ = should fix (quality) | ✅ = pass

## Table of Contents

- [A. Frontmatter Quality](#a-frontmatter-quality)
- [B. SKILL.md Body Quality](#b-skillmd-body-quality)
- [C. File Hygiene](#c-file-hygiene)
- [D. Progressive Disclosure](#d-progressive-disclosure)
- [E. Scripts Quality](#e-scripts-quality-only-if-scripts-is-present)
- [F. Workflow Quality](#f-workflow-quality)
- [G. Trigger Accuracy](#g-trigger-accuracy)
- [H. Testing & Evaluation](#h-testing--evaluation)
- [I. Skill Architecture](#i-skill-architecture)
- [J. File Placement (docs vs references)](#j-file-placement-docs-vs-references)
- [Reporting Format](#reporting-format)

---

## A. Frontmatter Quality

| # | Severity | Item | How to check |
|---|---|---|---|
| A-1 | ❌ | `name` is hyphen-case, 1–64 chars, no leading/trailing hyphens, no consecutive `--` | Inspect frontmatter |
| A-2 | ❌ | `name` exactly matches the skill directory name | Compare `name:` with directory name |
| A-3 | ❌ | `description` is present, 1–1024 chars, no `<` `>` angle brackets | Inspect frontmatter |
| A-4 | ⚠️ | `description` contains "what it does" AND "when to use it" (trigger conditions). For user-invocable skills: at least 2 quoted trigger phrases are listed (e.g., `"コミットして"`, `"commit these changes"`) | Read description; check for quoted trigger phrases |
| A-5 | ⚠️ | `description` uses third-person or 体言止め. Imperative first words (`Use`, `Consult`, `Call`, `Run`) are forbidden — rephrase as "This skill should be used when..." or "Skill that \<verb\>s..." | Check first word of each sentence in description |
| A-6 | ⚠️ | `description` contains specific searchable keywords (not generic phrases like "helps with tasks") | Read description |
| A-7 | ⚠️ | `disable-model-invocation: true` is set if the skill creates files, runs commands, or has other side effects | Check if Write/Bash/Edit is in `allowed-tools` → if so, verify this flag is `true` |
| A-8 | ⚠️ | `allowed-tools` is declared with the minimum necessary set (least privilege) | Verify no extra tools are listed |
| A-9 | ⚠️ | For user-invocable skills in a Japanese-language context: at least one Japanese trigger phrase (hiragana/katakana/kanji) is included alongside English triggers | Read description for Japanese-character trigger phrases |

---

## B. SKILL.md Body Quality

| # | Severity | Item | How to check |
|---|---|---|---|
| B-1 | ❌ | No unresolved TODO placeholders (`TODO`, `FIXME`, `<placeholder>`) remain | Grep for TODO/FIXME/`<` in body |
| B-2 | ❌ | All content is written in English | Read body |
| B-3 | ⚠️ | Body is ≤500 lines (spec recommendation — longer bodies consume context budget) | Count lines: `wc -l SKILL.md` |
| B-4 | ⚠️ | At least 2 representative user utterance examples are included | Find example usage section |
| B-5 | ⚠️ | At least 1 primary workflow is written in step-by-step form | Find Steps section |
| B-6 | ⚠️ | Error handling section is present: each failure case specifies (a) cause, (b) what to do next | Find Error Handling section |
| B-7 | ⚠️ | Limitations section is present (what this skill does NOT handle) | Find Limitations section |
| B-8 | ⚠️ | Time-sensitive or frequently-changing information is not hardcoded in the body | Review for version numbers, dates, URLs |
| B-9 | ⚠️ | Terminology is consistent (same concept is not referred to by multiple names) | Scan for synonym pairs like "user/person", "endpoint/route/URL" |
| B-10 | ⚠️ | At least one concrete I/O example is included (not just abstract descriptions) | Look for input→output pairs, code blocks with realistic values |
| B-11 | ⚠️ | Skill does not repeat general knowledge Claude already knows | Check if content would appear in a generic AI textbook — if so, remove it |
| B-12 | ⚠️ | One default approach is specified; alternatives are presented with conditions | Look for lists of "Option A / Option B" without guidance on when to choose |

---

## C. File Hygiene

Check using `Glob` or `Bash ls` on the skill directory.

| # | Severity | Item | How to check |
|---|---|---|---|
| C-1 | ❌ | Example files from `init_skill.py` are deleted: `scripts/example.py`, `references/api_reference.md`, `assets/example_asset.txt` | `Glob scripts/example.py`, etc. |
| C-2 | ⚠️ | No `__pycache__/` directories inside the skill directory | `Glob **/__pycache__/**` |
| C-3 | ⚠️ | No empty directories (e.g. `scripts/`, `references/`, `assets/` with no real content) | Check each subdirectory |
| C-4 | ⚠️ | Every file referenced or linked from SKILL.md actually exists in the skill directory | Run `validate_links.py` |
| C-5 | ⚠️ | No files exist that are not referenced from SKILL.md (orphan files) | Run `find_orphans.py` |

---

## D. Progressive Disclosure

| # | Severity | Item | How to check |
|---|---|---|---|
| D-1 | ⚠️ | SKILL.md contains step sequence and per-step descriptions only. Judgment criteria, decision tables, checklists, format definitions, and example collections must be in `references/`. | Check body for inline criteria, checklists, or format specs — move any found to `references/` |
| D-2 | ❌ | References are not chained: SKILL.md links directly to all reference files (no SKILL.md → A.md → B.md chains) | Read reference links in body |
| D-3 | ❌ | Reference files with 100+ lines have a table of contents at the top | Check length of each reference file |
| D-4 | ⚠️ | Information is not duplicated between SKILL.md body and `references/` files | Spot-check for repeated content |
| D-5 | ❌ | All paths in SKILL.md use forward slashes only (no backslashes) | `grep -n "\\\\" SKILL.md` — should return no results |
| D-6 | ⚠️ | Reference filenames are descriptive (not `reference.md`, `doc.md`, `info.md`) | List files in references/ and verify names reflect content |
| D-7 | ⚠️ | Each reference file covers exactly one step or one coherent topic. Multiple steps' supporting detail must not be bundled into a single file (bundling forces loading unneeded context when only one step runs). | Check references/ — if one file contains material for 2+ steps, split it |

---

## E. Scripts Quality (only if `scripts/` is present)

| # | Severity | Item | How to check |
|---|---|---|---|
| E-1 | ⚠️ | Each script is self-contained (does not import from other scripts in the directory) | Read script headers |
| E-2 | ⚠️ | Required commands/packages are explicitly stated in the script header or in SKILL.md | Read script and body |
| E-3 | ⚠️ | Scripts produce meaningful error messages on failure (not silent errors) | Review error handling in scripts |
| E-4 | ⚠️ | Every script in `scripts/` is mentioned or linked from SKILL.md | Cross-check scripts/ listing vs. body |
| E-5 | ❌ | All scripts executed by this skill live inside the skill's own `scripts/` directory — no references to scripts from other skills or external paths | Grep SKILL.md for patterns like `~/.claude/skills/<other>/`, `../`, or absolute paths outside this skill |
| E-6 | ❌ | The skill is fully self-contained: everything needed to run it (scripts, references, assets) is stored within this skill's directory | Confirm no runtime dependency on files outside the skill directory |
| E-7 | ⚠️ | Magic numbers in scripts have explanatory comments | Scan scripts for numeric literals without adjacent comments |
| E-8 | ⚠️ | Required packages/commands are listed in SKILL.md or script header | Check for `import` or CLI calls that have no corresponding "Requirements:" note |
| E-9 | ⚠️ | Execution environment assumption is stated (claude.ai vs API) | If skill uses network/install, verify environment compatibility is noted |
| E-10 | ⚠️ | MCP tools (if any) are referenced with fully-qualified names (`Server:tool`) | Search SKILL.md for tool references without `ServerName:` prefix |
| E-11 | ⚠️ | Bundled scripts are referenced with clear run/read instructions | Each script in scripts/ has an instruction stating whether to run it or read it |

**How to check E-5 and E-6:**

```bash
SKILL_DIR=<path/to/skill-folder>
SKILL_NAME=$(basename "$SKILL_DIR")

# Look for script references pointing outside this skill's directory
# Flags: paths to other skills, parent-directory traversal, or absolute paths not inside SKILL_DIR
grep -n "scripts/" "$SKILL_DIR/SKILL.md" | grep -v "^\s*#" || true

# Check for references to other skill directories (e.g. ~/.claude/skills/<other-name>/)
grep -n "\.claude/skills/" "$SKILL_DIR/SKILL.md" | grep -v "$SKILL_NAME" && \
  echo "WARNING: found reference to another skill's directory" || echo "OK: no cross-skill script references"

# Check for parent directory traversal
grep -n "\.\.\/" "$SKILL_DIR/SKILL.md" && \
  echo "WARNING: found ../ path traversal" || echo "OK: no ../ references"
```

Or use the automated script:

```bash
python $SKILL_SCRIPTS/find_orphans.py <path/to/skill>
```

A violation looks like: `python ~/.claude/skills/other-skill/scripts/foo.py`
A valid pattern looks like: `python scripts/foo.py` or `python $SKILL_SCRIPTS/foo.py` where `SKILL_SCRIPTS` points inside this skill.

---

## F. Workflow Quality

| # | Severity | Item | How to check |
|---|---|---|---|
| F-1 | ⚠️ | Complex tasks (3+ steps) are broken into numbered steps or checklists | Look for multi-step workflows — verify they use `1.` / `- [ ]` format |
| F-2 | ⚠️ | Verification steps are embedded within the workflow (not only at the end) | Check that each critical step has a validation point before proceeding |
| F-3 | ⚠️ | Feedback loop conditions use strong language ("MUST", "Only proceed when … passes") | Search for loop/retry instructions — verify they are not phrased as suggestions |
| F-4 | ⚠️ | Degree of freedom is declared for each workflow (ALWAYS/MUST vs. use judgment) | Each significant workflow step states whether Claude has discretion or must follow exactly |
| F-5 | △ | For high-risk operations (file deletion, git push, deployments): plan→verify→execute pattern is used | Confirm irreversible actions have a preview/confirm step before execution |

---

## G. Trigger Accuracy

| # | Severity | Item | How to check |
|---|---|---|---|
| G-1 | ⚠️ | Description keywords match the trigger phrases the user would actually use | Read description, compare to usage examples |
| G-2 | ⚠️ | Description is specific enough to avoid false positives with similar-but-different tasks | Consider: "what other tasks sound similar?" |

---

## H. Testing & Evaluation

Testing is performed **after** placing the skill, not during pre-packaging review.

| # | Severity | Item | How to check |
|---|---|---|---|
| H-1 | ⚠️ | At least 3 test scenarios are defined (Normal / Edge / Out-of-scope) | Check Step 6 test table |
| H-2 | ⚠️ | Output verified with at least 2 Claude model variants (e.g., Sonnet + Haiku) | Run with both models and compare |
| H-3 | ⚠️ | Observed which files Claude reads during execution — navigation fixed if any skipped | Manually run and inspect tool calls |
| H-4 | ⚠️ | Verified skill triggers for intended prompts and NOT for similar-but-out-of-scope prompts | Test boundary cases against description |
| H-5 | △ | Baseline output saved for regression comparison (for frequently updated skills) | Save sample output to assets/ or docs/ |

---

## I. Skill Architecture

| # | Severity | Item | How to check |
|---|---|---|---|
| I-1 | ⚠️ | Skill has exactly one purpose expressible in a single sentence | Read description — if "and" joins two distinct goals, consider splitting |
| I-2 | ⚠️ | Top-level workflow step count is 2–3 (modules) | Count `###` headers under `## Steps` |
| I-3 | ❌ | If step count is 4+, splitting has been explicitly evaluated | Skill body must justify size, or it should be split |
| I-4 | ⚠️ | If this is an orchestrator skill: body contains ONLY sub-skill invocations, no procedural steps | Verify no detailed workflow besides `/skill-name` calls |
| I-5 | ⚠️ | Skill chain depth does not exceed ~5 invocations | Trace the full invocation chain from this skill |
| I-6 | ⚠️ | Skill name follows verb+purpose pattern (e.g., `create-skill`, `reflect`, `ts-val-orchestrate`) | Check `name:` in frontmatter |
| I-7 | ⚠️ | No similar installed skill has overlapping purpose (no structural bloat) | Compare against the skills list; consolidate if overlap found |

---

## J. File Placement (docs vs references)

Rules for distinguishing `docs/` (authoritative human documents) from `references/` (skill-execution aids).

| # | Severity | Item | How to check |
|---|---|---|---|
| J-1 | ❌ | `references/` files do not contain content that belongs in `docs/`: design policies, naming rules, review criteria, or operational rules that humans agree on and update | Read each reference file — if the content reads as a shared standard or policy, it should live in `docs/` |
| J-2 | ⚠️ | `references/` files contain only skill-execution aids: output formats, JSON schemas, report templates, few-shot examples, or skill-specific I/O contracts | Verify each reference file serves the skill's runtime needs, not documentation purposes |
| J-3 | ❌ | `references/` files are not paraphrases or excerpts of `docs/` content (no knowledge copy-paste) | If a reference file says the same thing as a docs file, remove it and link to the docs source instead |
| J-4 | ⚠️ | `docs/` files do not contain skill-specific output templates, schemas, or execution-only helpers | Check that `docs/` content is suitable for humans to read and update independently of any skill |
| J-5 | ❌ | There is a clear single source of truth: if similar content exists in both `docs/` and `references/`, one is the authority and the other is derived (with an explicit link) | Look for duplicated rules or descriptions across the two locations |

**Decision aid:**

| Question | → Location |
|---|---|
| Will a human read and agree on this as a standard? | `docs/` |
| Is this needed only when Claude executes this skill? | `references/` |
| Does this define shared naming, design, or review policy? | `docs/` |
| Is this an output template, schema, or few-shot example? | `references/` |
| Would another skill or team member also need this? | `docs/` |
| Is this useful only inside this skill's workflow? | `references/` |

---

## Reporting Format

After going through all items, report the results in this format:

```
## Self-Review Results: <skill-name>

| Section | ❌ | ⚠️ | ✅ |
|---|---|---|---|
| A. Frontmatter | n | n | n |
| B. SKILL.md Body | n | n | n |
| C. File Hygiene | n | n | n |
| D. Progressive Disclosure | n | n | n |
| E. Scripts | n | n | n |
| F. Workflow Quality | n | n | n |
| G. Trigger Accuracy | n | n | n |
| I. Skill Architecture | n | n | n |
| J. File Placement | n | n | n |

### Issues Found

**❌ Must-fix (blocks packaging):**
- [item ID] [description of the issue] → [how to fix]

**⚠️ Should-fix (quality):**
- [item ID] [description] → [recommendation]

### Verdict
- ❌ items remain → Fix before packaging (do not proceed to Step 5)
- Only ⚠️ items remain → Inform user, then proceed to packaging
- All ✅ → Proceed to packaging
```
