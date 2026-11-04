#!/usr/bin/env bash
# Install the Model router into Claude Code for the current user (macOS or Linux).
# Safe to re-run: it updates files in place and never adds a second hook. The router is left OFF.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/files"
CLAUDE="$HOME/.claude"

command -v python3 >/dev/null || { echo "error: python3 not found. Install it first (macOS: xcode-select --install; Linux: your package manager)."; exit 1; }
if [ -f "$CLAUDE/settings.json" ] && ! python3 -I -c 'import json,sys; json.load(open(sys.argv[1]))' "$CLAUDE/settings.json" 2>/dev/null; then
  echo "error: $CLAUDE/settings.json is not valid JSON; fix it first. Nothing changed."; exit 1
fi

echo "Installing Model router into $CLAUDE"
# An install made under the old name (jev-router) moves over: state and stats are kept, the old helper agents are
# removed, and settings_hook.py replaces the old hook entry.
if [ -d "$CLAUDE/jev-router" ] && [ ! -d "$CLAUDE/model-router" ]; then
  mv "$CLAUDE/jev-router" "$CLAUDE/model-router"
  for size in tiny everyday large hardest; do rm -f "$CLAUDE/agents/jev-$size.md"; done
  echo "  migrated the jev-router install to $CLAUDE/model-router (state and stats kept; old agents removed)"
fi
mkdir -p "$CLAUDE/model-router" "$CLAUDE/agents"
cp "$SRC/router.py" "$SRC/README.md" "$CLAUDE/model-router/"
for f in "$SRC"/agents/router-*.md; do
  name="$(basename "$f")"
  if [ -f "$CLAUDE/agents/$name" ] && ! cmp -s "$f" "$CLAUDE/agents/$name"; then
    cp "$CLAUDE/agents/$name" "$CLAUDE/agents/$name.bak-$(date +%Y%m%d-%H%M%S)"
  fi
  cp "$f" "$CLAUDE/agents/"
done
python3 -I "$SRC/settings_hook.py" add "$CLAUDE/settings.json"

# Start OFF unless this machine already had a router state (keeps existing on/off and stats).
if [ ! -f "$CLAUDE/model-router/state.json" ]; then
  python3 -I "$CLAUDE/model-router/router.py" off >/dev/null
fi

echo
echo "Done. Router is $(python3 -I "$CLAUDE/model-router/router.py" status | head -1 | sed 's/Model router: //')."
if [ -z "${TYPESAFE_API_KEY:-}" ] && { [ -z "${MODEL_ROUTER_AZURE_ENDPOINT:-}" ] || [ -z "${MODEL_ROUTER_AZURE_DEPLOYMENT:-}" ]; }; then
  cat <<'EOF'

NOTE: neither TYPESAFE_API_KEY nor an Azure backend (MODEL_ROUTER_AZURE_ENDPOINT + MODEL_ROUTER_AZURE_DEPLOYMENT) is set in
this shell. The router needs one, or it will silently do nothing. Export it in your shell profile (for
example ~/.zshrc or ~/.bashrc) or store it in the Keychain (see files/README.md), outside any file you share:
    export TYPESAFE_API_KEY=...
EOF
fi
cat <<'EOF'

Next: start a new Claude Code session (helpers load at startup), then type:
    model router on
Also: "model router off", "model router status". Uninstall with ./uninstall.sh
EOF
