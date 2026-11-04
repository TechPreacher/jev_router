#!/usr/bin/env bash
# Remove the Model router from Claude Code for the current user (macOS or Linux).
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/files"
CLAUDE="$HOME/.claude"

python3 -I "$SRC/settings_hook.py" remove "$CLAUDE/settings.json"
rm -f "$CLAUDE"/agents/router-tiny.md "$CLAUDE"/agents/router-everyday.md \
      "$CLAUDE"/agents/router-large.md "$CLAUDE"/agents/router-hardest.md \
      "$CLAUDE"/agents/jev-tiny.md "$CLAUDE"/agents/jev-everyday.md \
      "$CLAUDE"/agents/jev-large.md "$CLAUDE"/agents/jev-hardest.md  # the jev-* ones: the name before the rename
rm -rf "$CLAUDE/model-router" "$CLAUDE/jev-router"
echo "Model router removed (hook, helper agents, ~/.claude/model-router with its stats)."
