#!/usr/bin/env python3
"""
Extract and compact events from a Claude Code session JSONL log.

Usage:
    python extract_events.py <jsonl_path> [--reflection-root <dir>]

Outputs one JSON line to stdout:
    {"status": "skip",  "source_log": "...", "fingerprint": "...", "reason": "..."}
    {"status": "error", "source_log": "...", "reason": "..."}
    {"status": "ok",    "source_log": "...", "fingerprint": "...",
                        "artifacts_dir": "...", "events_count": N, "tool_errors": N}

Exit code is always 0 (caller checks the status field).
"""

import argparse
import hashlib
import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

# ── Constants ──────────────────────────────────────────────────────────────────

# JSONL message types to silently skip
SKIP_TYPES = {"file-history-snapshot", "queue-operation", "progress"}

# Bash bind / readline warning lines to strip from tool output
BASH_NOISE_RE = re.compile(
    r"^bash:\s+(bind:|readline|line \d+:).*$", re.MULTILINE | re.IGNORECASE
)

# Trim limits for tool_result output
TRIM_NORMAL = (800, 200)   # (head, tail) chars for non-error results
TRIM_ERROR  = (2000, 400)  # (head, tail) chars for is_error=true results


# ── Helpers ────────────────────────────────────────────────────────────────────

def compute_fingerprint(path: Path) -> str:
    """Return SHA-256 hex digest of a file."""
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def encode_artifact_name(jsonl_path: Path, fingerprint: str) -> str:
    """Build a filesystem-safe directory name from filename + fingerprint prefix."""
    return f"{jsonl_path.name}__{fingerprint[:8]}"


def trim_text(text: str, is_error: bool) -> str:
    """Trim long text to (head + tail), inserting an omission notice in the middle."""
    head, tail = TRIM_ERROR if is_error else TRIM_NORMAL
    limit = head + tail
    if len(text) <= limit:
        return text
    omitted = len(text) - limit
    return f"{text[:head]}\n…[{omitted} chars omitted]…\n{text[-tail:]}"


def extract_text_from_content(content) -> str:
    """Return plain text from a content field (str, list of blocks, etc.)."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, str):
                parts.append(block)
            elif isinstance(block, dict):
                btype = block.get("type", "")
                if btype == "text":
                    parts.append(block.get("text", ""))
                elif btype == "tool_result":
                    for sub in block.get("content", []):
                        if isinstance(sub, dict) and sub.get("type") == "text":
                            parts.append(sub.get("text", ""))
        return "\n".join(p for p in parts if p)
    return ""


def already_reflected(index_path: Path, source_log: str, fingerprint: str) -> bool:
    """Return True if this (source_log, fingerprint) pair is already marked 'done'."""
    if not index_path.exists():
        return False
    try:
        with open(index_path, encoding="utf-8") as f:
            for raw in f:
                raw = raw.strip()
                if not raw:
                    continue
                try:
                    entry = json.loads(raw)
                except json.JSONDecodeError:
                    continue
                if (
                    entry.get("source_log") == source_log
                    and entry.get("fingerprint") == fingerprint
                    and entry.get("status") == "done"
                ):
                    return True
    except OSError:
        pass
    return False


# ── JSONL Parsing ──────────────────────────────────────────────────────────────

def parse_jsonl(path: Path) -> list:
    """
    Parse a Claude Code JSONL log and return a list of compact event dicts.

    Supports two common JSONL layouts:
      Layout A: {"type": "user"|"assistant"|"tool_result", "message": {...}, "timestamp": "..."}
      Layout B: {"role": "user"|"assistant", "content": [...], "timestamp": "..."}
    """
    events: list = []
    tool_use_map: dict = {}  # tool_use id → {"name": ..., "input": ...}

    with open(path, encoding="utf-8", errors="replace") as f:
        for lineno, raw in enumerate(f, 1):
            raw = raw.strip()
            if not raw:
                continue
            try:
                line = json.loads(raw)
            except json.JSONDecodeError:
                continue
            if not isinstance(line, dict):
                continue

            msg_type = line.get("type", "")
            ts = line.get("timestamp", line.get("ts", ""))

            # ── Skip noise types ───────────────────────────────────────────
            if msg_type in SKIP_TYPES:
                continue

            # ── Layout A: type-tagged messages ─────────────────────────────
            if msg_type in ("user", "assistant", "tool_result"):
                _process_type_tagged(line, msg_type, ts, events, tool_use_map)
                continue

            # ── Layout B: role-based messages ──────────────────────────────
            if "role" in line:
                _process_role_based(line, ts, events, tool_use_map)

    return events


def _process_type_tagged(line, msg_type, ts, events, tool_use_map):
    # Unwrap nested "message" if present (Layout A)
    message = line.get("message", line)

    if msg_type == "user":
        content = message.get("content", line.get("content", ""))
        text = extract_text_from_content(content).strip()
        if text:
            events.append({"ts": ts, "kind": "user", "text": text})

    elif msg_type == "assistant":
        content = message.get("content", line.get("content", []))
        _handle_assistant_content(content, ts, events, tool_use_map)

    elif msg_type == "tool_result":
        _handle_tool_result(line, ts, events, tool_use_map)


def _process_role_based(line, ts, events, tool_use_map):
    role = line.get("role", "")
    content = line.get("content", "")

    if role == "user":
        text = extract_text_from_content(content).strip()
        if text:
            events.append({"ts": ts, "kind": "user", "text": text})

    elif role == "assistant":
        _handle_assistant_content(content, ts, events, tool_use_map)


def _handle_assistant_content(content, ts, events, tool_use_map):
    if isinstance(content, str):
        text = content.strip()
        if text:
            events.append({"ts": ts, "kind": "assistant", "text": text})
        return

    if not isinstance(content, list):
        return

    for block in content:
        if not isinstance(block, dict):
            continue
        btype = block.get("type", "")

        if btype == "text":
            text = block.get("text", "").strip()
            if text:
                events.append({"ts": ts, "kind": "assistant", "text": text})

        elif btype == "tool_use":
            tool_id = block.get("id", "")
            tool_name = block.get("name", "")
            tool_input = block.get("input", {})
            tool_use_map[tool_id] = {"name": tool_name, "input": tool_input}
            events.append({
                "ts": ts,
                "kind": "assistant",
                "text": f"[tool_use: {tool_name}]",
                "tool": {"name": tool_name, "input": tool_input},
            })


def _handle_tool_result(line, ts, events, tool_use_map):
    tool_use_id = line.get("tool_use_id", "")
    is_error = bool(line.get("is_error", False))
    content = line.get("content", line.get("output", ""))

    if isinstance(content, str):
        raw_text = content
    else:
        raw_text = extract_text_from_content(content)

    # Strip bash noise
    raw_text = BASH_NOISE_RE.sub("", raw_text).strip()
    trimmed = trim_text(raw_text, is_error)

    tool_info = tool_use_map.get(tool_use_id, {})
    events.append({
        "ts": ts,
        "kind": "tool",
        "tool": {
            "name": tool_info.get("name", ""),
            "input": tool_info.get("input", {}),
            "output": trimmed,
            "is_error": is_error,
        },
    })


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Extract and compact events from a Claude Code JSONL log."
    )
    parser.add_argument("jsonl_path", help="Path to the .jsonl log file.")
    parser.add_argument(
        "--reflection-root",
        default="docs/tmp/reflection",
        help="Root directory for reflection artifacts (default: docs/tmp/reflection).",
    )
    args = parser.parse_args()

    jsonl_path = Path(args.jsonl_path)
    reflection_root = Path(args.reflection_root)

    # Resolve to absolute path for consistent source_log values
    try:
        jsonl_path = jsonl_path.resolve()
    except OSError:
        pass

    source_log = str(jsonl_path)

    if not jsonl_path.exists():
        print(json.dumps({
            "status": "error",
            "source_log": source_log,
            "reason": f"File not found: {jsonl_path}",
        }))
        sys.exit(0)

    # Compute fingerprint
    try:
        fingerprint = compute_fingerprint(jsonl_path)
    except OSError as e:
        print(json.dumps({
            "status": "error",
            "source_log": source_log,
            "reason": f"Cannot read file: {e}",
        }))
        sys.exit(0)

    # Check history — skip if already reflected with same fingerprint
    index_path = reflection_root / "reflection_history" / "index.jsonl"
    if already_reflected(index_path, source_log, fingerprint):
        print(json.dumps({
            "status": "skip",
            "source_log": source_log,
            "fingerprint": fingerprint,
            "reason": "Already reflected with the same fingerprint.",
        }))
        sys.exit(0)

    # Extract events
    try:
        events = parse_jsonl(jsonl_path)
    except OSError as e:
        print(json.dumps({
            "status": "error",
            "source_log": source_log,
            "reason": f"Cannot parse file: {e}",
        }))
        sys.exit(0)

    # Create artifacts directory
    artifact_name = encode_artifact_name(jsonl_path, fingerprint)
    artifacts_dir = reflection_root / "artifacts" / artifact_name
    try:
        artifacts_dir.mkdir(parents=True, exist_ok=True)
    except OSError as e:
        print(json.dumps({
            "status": "error",
            "source_log": source_log,
            "reason": f"Cannot create artifacts dir: {e}",
        }))
        sys.exit(0)

    # Write source.json
    (artifacts_dir / "source.json").write_text(
        json.dumps(
            {"source_log": source_log, "fingerprint": fingerprint},
            ensure_ascii=False, indent=2
        ),
        encoding="utf-8",
    )

    # Write reflection_input.json
    reflection_input = {
        "source_log": source_log,
        "fingerprint": fingerprint,
        "events": events,
    }
    (artifacts_dir / "reflection_input.json").write_text(
        json.dumps(reflection_input, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    tool_errors = sum(
        1 for e in events
        if e.get("kind") == "tool" and e.get("tool", {}).get("is_error")
    )

    print(json.dumps({
        "status": "ok",
        "source_log": source_log,
        "fingerprint": fingerprint,
        "artifacts_dir": str(artifacts_dir),
        "events_count": len(events),
        "tool_errors": tool_errors,
    }))
    sys.exit(0)


if __name__ == "__main__":
    main()
