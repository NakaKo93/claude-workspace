#!/usr/bin/env python3
"""
Validate that all Markdown links in SKILL.md resolve to real files within the skill directory.
External URLs (http/https) are skipped.

Usage: python validate_links.py <skill_directory>
Exit code: 0 = all links OK, 1 = broken links found
"""

import re
import sys
from pathlib import Path


def validate_links(skill_dir: str) -> bool:
    skill_path = Path(skill_dir)
    skill_md = skill_path / "SKILL.md"

    if not skill_md.exists():
        print(f"ERROR: SKILL.md not found in {skill_dir}")
        return False

    content = skill_md.read_text(encoding="utf-8")
    lines = content.splitlines()

    print("Checking links in SKILL.md...")

    # Collect links with line numbers
    broken = []
    ok_count = 0

    for lineno, line in enumerate(lines, start=1):
        for path_str in re.findall(r'\[.*?\]\(([^)#\s]+)\)', line):
            # Skip external URLs
            if path_str.startswith("http://") or path_str.startswith("https://"):
                continue

            target = skill_path / path_str
            if target.exists():
                print(f"  ✅ {path_str}")
                ok_count += 1
            else:
                print(f"  ❌ {path_str} (line {lineno}) — file not found")
                broken.append((lineno, path_str))

    print()
    if broken:
        print(f"Broken links: {len(broken)}")
        return False

    print(f"All {ok_count} link(s) OK.")
    return True


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python validate_links.py <skill_directory>")
        sys.exit(1)

    ok = validate_links(sys.argv[1])
    sys.exit(0 if ok else 1)
