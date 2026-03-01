---
name: plain-doc
description: Reads a source file or inline text and writes a plain-language Markdown reference document to docs/reference/. This skill should be used when the user asks to analyze, explain, or summarize a file — trigger phrases include "このファイルを分析して", "まとめて", "analyze this file", or "summarize this document".
disable-model-invocation: false
allowed-tools: Read, Glob, Grep, Write, Task
---

# Plain-Doc Skill

Read a source file (or inline text) and write a plain-language reference document to `docs/reference/`.
The original source is never edited. The output explains concepts concretely — what they do and why they matter — without assuming prior domain knowledge.

Heavy work (file reading, analysis, writing) is delegated to the `plain-doc-analyzer` subagent via the Task tool to avoid consuming the main conversation's context budget.

## Example Usage

- "このファイルを分析して `skills/reflection/SKILL.md`"
- "このドキュメントをわかりやすくまとめて `docs/reference/claude/reflection/overview.md`"
- "analyze this file and save it as a reference: `settings.json`"
- "このファイルを説明して → `docs/reference/hooks/overview.md` に保存して"

## Inputs

| Input | How to provide | Required |
|---|---|---|
| Source file path | Mentioned in the user's message | Required (or provide inline text) |
| Output path | Optionally specified by the user | Optional — infer if omitted |
| Inline text | Pasted directly into the message instead of a file | Alternative to file path |

If the user provides only a file path with no output path, derive the output path as:
`docs/reference/<source-filename-without-extension>/overview.md`

---

## Steps

Execute all steps in order.

### Step 1: Resolve Inputs

1. Extract the source file path from the user's message.
   - If the user provided inline text instead of a file, treat that text as the source content (skip file reading in this step).

2. Determine the output path:
   - **If the user specified an output path explicitly, use it exactly. Skip to step 3.**
   - **If the output path is not specified**, do NOT auto-derive it from the filename. Instead:
     a. Use Glob to check the existing structure under `docs/reference/`:
        ```
        docs/reference/**/*.md
        ```
     b. Read the first 30 lines of the source file to understand its subject and category.
     c. Propose a path that:
        - Fits within the existing `docs/reference/` hierarchy (e.g. Claude-related content goes under `docs/reference/claude/`)
        - Reflects the **meaning and subject** of the content, not the source filename
        - Uses lowercase hyphen-case directory names
     d. **Ask the user to confirm the proposed path before proceeding.** Do not continue until confirmed.
        Example: "出力先を `docs/reference/claude/agents/design-requirements-analyst/overview.md` にしようと思いますが、よいですか？"

3. Once the output path is confirmed, state it in one line and proceed.

### Step 2: Delegate to plain-doc-analyzer subagent

Spawn the `plain-doc-analyzer` subagent via the Task tool. Pass the resolved source path and output path in the prompt.

**Prompt to pass:**
```
source: <absolute source file path>
output: <absolute output file path>
```

The subagent handles all file reading, plain-language analysis, and writing in its own isolated context window. Wait for it to complete and capture its result.

### Step 3: Report to the User

After the subagent finishes, report one confirmation line:

```
Saved: <output path>
```

If the subagent returned an error, report it to the user and ask how to proceed.

---

## Error Handling

- **Source file not found**: Inform the user and ask for the correct path. Do not guess.
- **Output path conflict** (file already exists): Overwrite it — reference docs are always overwritable per CLAUDE.md policy.
- **Source is binary or non-text**: Inform the user that the file cannot be read as text and suggest an alternative.
- **Source is very large (>500 lines)**: The subagent handles this by reading in sections; no action needed from the skill layer.
- **Subagent fails or times out**: Report the error to the user. Do not attempt to redo the analysis in the main context.

---

## Limitations

- Does not modify the original source file.
- Does not translate the output language — the output language matches the dominant language of the source (Japanese source → Japanese output; English source → English output). Mixed sources default to Japanese output.
- Does not generate diagrams or visualizations.
- Does not summarize binary formats (images, PDFs, compiled files).
