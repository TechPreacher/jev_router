# Security

## What this tool sends where

When the router is ON, the text of each Claude Code message (first 6000 characters) is sent to
`https://api.typesafe.ai` with your `TYPESAFE_API_KEY`, or, when `JEV_AZURE_ENDPOINT` and
`JEV_AZURE_DEPLOYMENT` are set, to that Azure AI Foundry endpoint of yours with a Microsoft Entra
token (or `JEV_AZURE_API_KEY`). Messages are not sent when they:

- start with `/` or `!`;
- look like a short follow-up reply;
- match the built-in secret pattern (API keys, `password:`, private key blocks).

That pattern is a best-effort filter, not a guarantee. Treat the router as OFF for any session
where you paste material you would not send to a third-party API.

Nothing else leaves the machine. Stats in `~/.claude/jev-router/state.json` and
`decisions.log` never contain message text; `decisions.log` records which backend answered.

## Your credentials

`TYPESAFE_API_KEY`, `JEV_AZURE_ENDPOINT`, `JEV_AZURE_DEPLOYMENT` and `JEV_AZURE_API_KEY` are read
from the environment at hook time, then from the macOS Keychain item of the same name. The installer
never reads, copies or stores them. Keep them in your shell profile or the Keychain, not in any file in
this repo. The Azure endpoint and deployment name are treated as secrets too: they are never printed.

With the Azure backend and no `JEV_AZURE_API_KEY`, the router runs `az account get-access-token` (your
Azure CLI login) outside the hook and caches the bearer token in `~/.claude/jev-router/azure-token.json`,
created owner-only (mode 600). That file is a credential: it is valid for about an hour and
`uninstall.sh` removes the folder. Delete it yourself if you stop using the Azure backend earlier.

## Reporting a vulnerability

Open a GitHub issue for anything that does not expose user data. For a report that does, use
GitHub's private vulnerability reporting on this repository instead of a public issue.
