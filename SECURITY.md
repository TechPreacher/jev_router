# Security

## What this tool sends where

When the router is ON, the text of each Claude Code message (first 6000 characters) is sent to
`https://api.typesafe.ai` with your `TYPESAFE_API_KEY`. Messages are not sent when they:

- start with `/` or `!`;
- look like a short follow-up reply;
- match the built-in secret pattern (API keys, `password:`, private key blocks).

That pattern is a best-effort filter, not a guarantee. Treat the router as OFF for any session
where you paste material you would not send to a third-party API.

Nothing else leaves the machine. Stats in `~/.claude/jev-router/state.json` and
`decisions.log` never contain message text.

## Your API key

The key is read from the `TYPESAFE_API_KEY` environment variable at hook time. The installer
never reads, copies or stores it. Keep it in your shell profile, not in any file in this repo.

## Reporting a vulnerability

Open a GitHub issue for anything that does not expose user data. For a report that does, use
GitHub's private vulnerability reporting on this repository instead of a public issue.
