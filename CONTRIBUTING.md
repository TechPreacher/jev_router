# Contributing

Thanks for helping improve the Jev model router.

## Ground rules

- Keep the hook fast and silent. Every failure path in `files/router.py` must exit 0 with no
  output, and the Jev call must keep its hard timeout. A hook that blocks or slows a message is a
  bug, even if it is "correct".
- No new dependencies. The router runs on a stock Python 3 (macOS or Linux) and the standard
  library only.
- Never log or store the user's message text. `decisions.log` records route, probability and
  latency; keep it that way.
- Scripts are POSIX-compatible bash (`#!/usr/bin/env bash`). Test `install.sh` and
  `uninstall.sh` on a fresh `~/.claude` as well as an existing one with other hooks.

## Workflow

1. Fork and branch from `main`.
2. Make your change. Run a syntax check:
   ```bash
   python3 -I -m py_compile files/router.py files/settings_hook.py
   bash -n install.sh uninstall.sh
   ```
3. Try the hook by hand with the router pointed at a scratch directory:
   ```bash
   export JEV_ROUTER_HOME=/tmp/jev-test
   python3 -I files/router.py on
   echo '{"prompt":"rename foo to bar"}' | python3 -I files/router.py hook
   python3 -I files/router.py status
   ```
4. Open a pull request. Say what changed and why; keep it small.

## Reporting issues

Use GitHub issues. Include your OS and Claude Code versions, the output of
`python3 ~/.claude/jev-router/router.py status`, and the relevant lines from
`~/.claude/jev-router/decisions.log` (they contain no message text). Never paste your
`TYPESAFE_API_KEY`.
