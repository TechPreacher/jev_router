# Jev model router for Claude Code

Routes each Claude Code message to the smallest model that can do the job well. TypeSafe Jev
sizes the job; one of four helper agents does it (Haiku 5.5, Sonnet 5.5, Opus 5.5, Fable 5.1).
See [`files/README.md`](files/README.md) for how it works and its limits.

## Requirements

- macOS or Linux with Claude Code and access to the haiku, sonnet, opus and fable models
- `python3` (standard library only, no packages to install)
- A [TypeSafe](https://typesafe.ai) API key exported as `TYPESAFE_API_KEY` in your shell profile,
  or a Microsoft Decision-1 deployment in Azure AI Foundry (set `JEV_AZURE_ENDPOINT` and
  `JEV_AZURE_DEPLOYMENT`; sign in with `az login`). The installer never copies or stores any of them.
  See [`files/README.md`](files/README.md#backend-and-credentials).

## Install

```bash
git clone https://github.com/TechPreacher/jev_router.git
cd jev_router
./install.sh
```

The installer:
- copies `router.py` to `~/.claude/jev-router/`;
- copies the four `jev-*.md` helpers to `~/.claude/agents/`. A changed helper is backed up
  before it's replaced;
- adds one `UserPromptSubmit` hook to `~/.claude/settings.json`. It keeps all other settings and
  writes a timestamped `.bak-*` copy first. Re-running it never adds a second hook;
- leaves the router OFF.

Then start a new Claude Code session and type `jev router on`. Other commands:
`jev router off`, `jev router status`.

## Uninstall

```bash
./uninstall.sh
```

This removes the hook, the four helpers and `~/.claude/jev-router/`, including its stats.

## Privacy

When ON, message text is sent to api.typesafe.ai, or to your own Azure AI Foundry deployment when
one is configured, to be sized. Slash commands, `!` commands, short replies and secret-looking text
are kept local. Details in [SECURITY.md](SECURITY.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
