#!/usr/bin/env python3
"""Add or remove the Jev router UserPromptSubmit hook in ~/.claude/settings.json.

Usage: settings_hook.py add|remove [settings.json path]
Keeps every other setting and hook. Writes a timestamped backup before changing anything.
Aborts without changes if the file isn't valid JSON.
"""
import json
import os
import shutil
import sys
import time

MARKER = "jev-router/router.py"
HOOK = {
    "hooks": [{
        "type": "command",
        "command": 'python3 -I "$HOME/.claude/jev-router/router.py" hook',
        "timeout": 3,
    }]
}


def is_router_entry(entry):
    return any(MARKER in h.get("command", "") for h in entry.get("hooks", []))


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    path = sys.argv[2] if len(sys.argv) > 2 else os.path.expanduser("~/.claude/settings.json")
    if mode not in ("add", "remove"):
        sys.exit(__doc__)

    settings = {}
    if os.path.exists(path):
        try:
            with open(path) as f:
                settings = json.load(f)
        except ValueError as e:
            sys.exit(f"error: {path} is not valid JSON ({e}); fix it first. Nothing changed.")
        backup = f"{path}.bak-{time.strftime('%Y%m%d-%H%M%S')}"
        shutil.copy2(path, backup)
        print(f"backup: {backup}")

    entries = settings.setdefault("hooks", {}).setdefault("UserPromptSubmit", [])
    kept = [e for e in entries if not is_router_entry(e)]
    removed = len(entries) - len(kept)
    if mode == "add":
        kept.append(HOOK)
    settings["hooks"]["UserPromptSubmit"] = kept
    if not kept:
        del settings["hooks"]["UserPromptSubmit"]
    if not settings["hooks"]:
        del settings["hooks"]

    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    os.replace(tmp, path)
    if mode == "add":
        print(f"hook installed in {path}" + (" (replaced the old one)" if removed else ""))
    else:
        print(f"hook removed from {path}" if removed else f"no router hook found in {path}")


if __name__ == "__main__":
    main()
