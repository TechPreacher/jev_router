#!/usr/bin/env bash
# Remove the Jev model router from Claude Code for the current user (macOS or Linux).
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/files"
CLAUDE="$HOME/.claude"

python3 -I "$SRC/settings_hook.py" remove "$CLAUDE/settings.json"
rm -f "$CLAUDE"/agents/jev-tiny.md "$CLAUDE"/agents/jev-everyday.md \
      "$CLAUDE"/agents/jev-large.md "$CLAUDE"/agents/jev-hardest.md
rm -rf "$CLAUDE/jev-router"
echo "Jev router removed (hook, helper agents, ~/.claude/jev-router with its stats)."
