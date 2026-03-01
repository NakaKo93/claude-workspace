#!/usr/bin/env python3
"""
Detect orphan files and cross-skill references in a skill directory.

Checks:
1. Files in scripts/, references/, assets/ not referenced from SKILL.md (orphans → warning)
2. References to other skills (.claude/skills/<other-name>/) in SKILL.md (error)
3. Parent-directory traversal (../) in SKILL.md (error)

Usage: python find_orphans.py <skill_directory>
Exit code: 0 = no errors (warnings OK), 1 = one or more errors found
"""

import re
import sys
from pathlib import Path


def find_orphans(skill_dir: str) -> bool:
    """Returns True if no errors (may still have warnings), False if errors exist."""
    skill_path = Path(skill_dir)
    skill_name = skill_path.name
    skill_md = skill_path / "SKILL.md"

    if not skill_md.exists():
        print(f"ERROR: SKILL.md not found in {skill_dir}")
        return False

    content = skill_md.read_text(encoding="utf-8")
    lines = content.splitlines()

    has_errors = False

    # ── 1. Orphan files ──────────────────────────────────────────────────────
    # Extract explicit path references of the form scripts/foo.py, references/bar.md, assets/baz.txt
    path_refs = re.findall(
        r'(?:scripts|references|assets)/[^\s\)\]\'\"\`<>]+',
        content
    )
    referenced_paths = set(path_refs)
    referenced_filenames = {p.split('/')[-1] for p in referenced_paths}

    orphans = []
    for subdir_name in ["scripts", "references", "assets"]:
        subdir = skill_path / subdir_name
        if not subdir.exists():
            continue
        for f in subdir.rglob("*"):
            if not f.is_file():
                continue
            rel_posix = f.relative_to(skill_path).as_posix()
            # File is referenced if its path or filename appears in explicit path references
            if rel_posix not in referenced_paths and f.name not in referenced_filenames:
                orphans.append(rel_posix)

    if orphans:
        print("Orphan files (not referenced in SKILL.md):")
        for o in orphans:
            print(f"  ⚠️  {o}")
        print()
    else:
        print("Orphan files: none")
        print()

    # ── 2. Cross-skill references ────────────────────────────────────────────
    cross_skill_hits = []
    for lineno, line in enumerate(lines, start=1):
        for m in re.finditer(r'\.claude/skills/([a-zA-Z0-9][a-zA-Z0-9-]*)', line):
            other_name = m.group(1)
            # Skip the current skill itself
            if other_name != skill_name:
                cross_skill_hits.append((lineno, line.strip()))
                break  # one hit per line is enough

    if cross_skill_hits:
        print("Cross-skill references:")
        for lineno, text in cross_skill_hits:
            print(f'  ❌ SKILL.md:{lineno} — "{text}"')
        has_errors = True
        print()
    else:
        print("Cross-skill references: none")
        print()

    # ── 3. Path traversal ───────────────────────────────────────────────────
    traversal_hits = []
    for lineno, line in enumerate(lines, start=1):
        # Skip comment lines (leading #) and remove URLs before checking
        stripped = re.sub(r'^\s*#.*$', '', line)
        stripped = re.sub(r'https?://\S+', '', stripped)
        if "../" in stripped:
            traversal_hits.append((lineno, line.strip()))

    if traversal_hits:
        print("Path traversal:")
        for lineno, text in traversal_hits:
            print(f'  ❌ SKILL.md:{lineno} — "{text}"')
        has_errors = True
        print()
    else:
        print("Path traversal: none")
        print()

    if has_errors:
        print("Result: ❌ errors found — fix before packaging.")
    elif orphans:
        print("Result: ⚠️  warnings found — review orphan files.")
    else:
        print("Result: ✅ all checks passed.")

    return not has_errors


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python find_orphans.py <skill_directory>")
        sys.exit(1)

    ok = find_orphans(sys.argv[1])
    sys.exit(0 if ok else 1)
