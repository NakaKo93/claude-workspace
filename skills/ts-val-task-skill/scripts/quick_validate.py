#!/usr/bin/env python3
"""
Quick validation script for skills - minimal version
"""

import sys
import re
from pathlib import Path


def validate_skill(skill_path):
    """Basic validation of a skill. Returns (is_valid, message)."""
    skill_path = Path(skill_path)
    errors = []

    # SKILL.md の存在確認（これ以降の検証が不可能なため早期リターン）
    skill_md = skill_path / 'SKILL.md'
    if not skill_md.exists():
        return False, "SKILL.md not found"

    content = skill_md.read_text(encoding="utf-8")
    if not content.startswith('---'):
        return False, "No YAML frontmatter found"

    # frontmatter 抽出（\r\n / Windows 改行に対応）
    match = re.match(r'^---\r?\n(.*?)\r?\n---', content, re.DOTALL)
    if not match:
        return False, "Invalid frontmatter format"

    frontmatter = match.group(1)

    # 必須フィールドの存在チェック
    if 'name:' not in frontmatter:
        errors.append("Missing 'name' in frontmatter")
    if 'description:' not in frontmatter:
        errors.append("Missing 'description' in frontmatter")

    # name の命名規則チェック
    name_match = re.search(r'name:\s*(.+)', frontmatter)
    if name_match:
        name = name_match.group(1).strip()
        if not re.match(r'^[a-z0-9-]+$', name):
            errors.append(
                f"Name '{name}' should be hyphen-case (lowercase letters, digits, and hyphens only)"
            )
        elif name.startswith('-') or name.endswith('-') or '--' in name:
            errors.append(
                f"Name '{name}' cannot start/end with hyphen or contain consecutive hyphens"
            )
        elif len(name) > 64:
            errors.append(f"Name '{name}' exceeds 64 character limit ({len(name)} chars)")

        # ディレクトリ名と frontmatter name の一致チェック
        if skill_path.name != name:
            errors.append(
                f"Directory name '{skill_path.name}' must match frontmatter name '{name}'"
            )

    # description のチェック
    desc_match = re.search(r'description:\s*(.+)', frontmatter)
    if desc_match:
        description = desc_match.group(1).strip()
        if '<' in description or '>' in description:
            errors.append("Description cannot contain angle brackets (< or >)")
        # 最低文字数チェック
        if len(description) < 30:
            errors.append(
                f"Description is too short ({len(description)} chars). "
                "Include when/how to use this skill."
            )
        # テンプレ残骸チェック
        template_remnants = ['[TODO', 'TBD', 'FIXME', 'placeholder', 'Replace with']
        for remnant in template_remnants:
            if remnant.lower() in description.lower():
                errors.append(
                    f"Description appears to contain template text: '{remnant}'"
                )
                break

    # TODO プレースホルダーの残存チェック（B-1: TODO/FIXME/<placeholder> を検出）
    todo_patterns = [r'\[TODO[:\]]', r'\bFIXME\b', r'<placeholder>']
    if any(re.search(p, content) for p in todo_patterns):
        errors.append("SKILL.md contains TODO/FIXME placeholders. Complete all before packaging.")

    # 例ファイルの残存チェック
    example_files = [
        skill_path / 'scripts' / 'example.py',
        skill_path / 'references' / 'api_reference.md',
        skill_path / 'assets' / 'example_asset.txt',
    ]
    for f in example_files:
        if f.exists():
            errors.append(
                f"Example file not deleted: {f.relative_to(skill_path)} "
                "(delete if not needed, or replace with actual content)"
            )

    # Windows-style paths check (checklist C-1 / D-5)
    # Match drive letters (C:\) or common Windows path roots (\\Users\, \\Program)
    if re.search(r'[A-Z]:\\\\|\\\\Users\\\\|\\\\Program', content):
        errors.append("SKILL.md contains Windows-style paths (backslash). Use forward slashes only.")

    # Line count check (checklist B-3)
    line_count = len(content.splitlines())
    if line_count > 500:
        errors.append(f"SKILL.md is {line_count} lines (limit: 500). Move details to references/.")
    elif line_count > 400:
        print(f"  ⚠️  Warning: SKILL.md is {line_count} lines (approaching 500-line limit)")

    # __pycache__ check (checklist C-2)
    pycache_dirs = list(skill_path.rglob('__pycache__'))
    if pycache_dirs:
        errors.append("__pycache__/ directories found. Remove before packaging.")

    # Empty subdirectory check (checklist C-3)
    for subdir_name in ['scripts', 'references', 'assets']:
        subdir = skill_path / subdir_name
        if subdir.exists() and not any(subdir.iterdir()):
            errors.append(f"{subdir_name}/ directory is empty. Remove it or add content.")

    if errors:
        error_list = "\n".join(f"  - {e}" for e in errors)
        return False, f"Validation failed ({len(errors)} error(s)):\n{error_list}"

    return True, "Skill is valid!"


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python quick_validate.py <skill_directory>")
        sys.exit(1)

    valid, message = validate_skill(sys.argv[1])
    print(message)
    sys.exit(0 if valid else 1)
