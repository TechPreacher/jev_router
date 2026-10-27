#!/usr/bin/env bash
# Install the Jev model router into Claude Code for the current user (macOS or Linux).
# Safe to re-run: it updates files in place and never adds a second hook. The router is left OFF.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/files"
CLAUDE="$HOME/.claude"

command -v python3 >/dev/null || { echo "error: python3 not found. Install it first (macOS: xcode-select --install; Linux: your package manager)."; exit 1; }
if [ -f "$CLAUDE/settings.json" ] && ! python3 -I -c 'import json,sys; json.load(open(sys.argv[1]))' "$CLAUDE/settings.json" 2>/dev/null; then
  echo "error: $CLAUDE/settings.json is not valid JSON; fix it first. Nothing changed."; exit 1
fi

echo "Installing Jev router into $CLAUDE"
mkdir -p "$CLAUDE/jev-router" "$CLAUDE/agents"
cp "$SRC/router.py" "$SRC/README.md" "$CLAUDE/jev-router/"
for f in "$SRC"/agents/jev-*.md; do
  name="$(basename "$f")"
  if [ -f "$CLAUDE/agents/$name" ] && ! cmp -s "$f" "$CLAUDE/agents/$name"; then
    cp "$CLAUDE/agents/$name" "$CLAUDE/agents/$name.bak-$(date +%Y%m%d-%H%M%S)"
  fi
  cp "$f" "$CLAUDE/agents/"
done
python3 -I "$SRC/settings_hook.py" add "$CLAUDE/settings.json"

# Start OFF unless this machine already had a router state (keeps existing on/off and stats).
if [ ! -f "$CLAUDE/jev-router/state.json" ]; then
  python3 -I "$CLAUDE/jev-router/router.py" off >/dev/null
fi

echo
echo "Done. Router is $(python3 -I "$CLAUDE/jev-router/router.py" status | head -1 | sed 's/Jev router: //')."
if [ -z "${TYPESAFE_API_KEY:-}" ]; then
  cat <<'EOF'

NOTE: TYPESAFE_API_KEY is not set in this shell. The router needs it, or it will silently do
nothing. Export it in your shell profile (for example ~/.zshrc or ~/.bashrc), outside any file you share:
    export TYPESAFE_API_KEY=...
EOF
fi
cat <<'EOF'

Next: start a new Claude Code session (helpers load at startup), then type:
    jev router on
Also: "jev router off", "jev router status". Uninstall with ./uninstall.sh
EOF
