# Implementation Conventions

Rules applied across all projects, regardless of language or technology.

---

## Rule 1: File name must match content

A file's name must accurately describe what it does or contains.
The implementation inside the file must match what the name implies.

Examples:
- A file named `no-compound-bash.sh` must not itself use `&&`, `||`, or `;`
- A file named `block-dangerous.sh` must only block dangerous commands
- A config file named `prettier.config.js` must only configure Prettier

When you find a mismatch during implementation, fix the name or the content — do not leave them inconsistent.

---

## Rule 2: Read before Edit — parallel edit pre-check

Before issuing any Edit tool calls, every target file must have been Read in the current session.

**Procedure (mandatory order):**
1. Identify all files that will be edited.
2. Check which ones have NOT been Read in the current session.
3. Issue Read calls for all unread files. Reads can be parallelized.
4. Wait for all reads to complete.
5. Only then issue Edit calls (can also be parallelized).

**Never** send an Edit and a Read for the same file in the same message —
the Edit will fail with "File has not been read yet. Read it first before writing to it."

**Common failure pattern to avoid:**
Announcing "I will edit N files in parallel" and sending Edit calls for files that include
any unread targets. The result is partial failure: some edits succeed, others fail,
and recovery reads + re-edits are required.

---

## Rule 3: Use post-edit content for subsequent edits in the same session

If a file has already been edited in the current session, any further Edit on that file
must use the current (post-edit) content as `old_string`. Never reuse the pre-edit
`old_string` after the file has changed.

**Procedure:**
1. After editing a file, if another edit is needed on the same file, Read it first.
2. Use the content returned by that Read as the basis for `old_string`.

**Common failure pattern to avoid:**
Making a first Edit, then reading the file to verify, then issuing a second Edit
using the original pre-edit `old_string`. Since the first Edit already changed that
text, the second Edit fails with "old_string not found in file".
