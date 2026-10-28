# Jev model router

A `UserPromptSubmit` hook (`~/.claude/settings.json`) runs `router.py hook` on every message.
When the router is ON, it asks TypeSafe Jev one Choice question about the message: what is the
smallest model that can do this job well? It then tells the main session to delegate the job:

| Size | Helper agent | Model |
|---|---|---|
| tiny: lookup, rename, one-line answer | `jev-tiny` | Claude Haiku 5.5 |
| everyday: normal email, post, short doc | `jev-everyday` | Claude Sonnet 5.5 |
| large: multi-step build, research, full report | `jev-large` | Claude Opus 5.5 |
| hardest: strategy, costly-if-wrong | `jev-hardest` | Claude Fable 5.1 |

Helpers live in `~/.claude/agents/jev-*.md`. Each ends its reply with a `— done by <model>` line.

The main session handles the message itself when:
- Jev's top pick is under 60% likely;
- the message is a short reply that needs the conversation, such as "yes but shorter". This is a
  code check: 12 words or fewer, with a yes/ok opener or a word like it, that, again, shorter;
- the message looks like it contains a secret (API key, password, private key). It is not sent to Jev;
- Jev is slow (over 1.5 s), fails, or the key is missing. Every error exits 0 with no output.

## API key

`router.py` reads `TYPESAFE_API_KEY` from the environment, then falls back to the macOS Keychain
(service `TYPESAFE_API_KEY`). The Keychain path matters for the Claude desktop app, which launches
hooks without the user's shell environment, so fish/zsh exports are not visible there. Store once:

    security add-generic-password -U -a "$USER" -s TYPESAFE_API_KEY -w

(`-w` with no value prompts for the key.) `jev router status` shows `last error` when both are missing.

## Limits

Claude Code can't switch the main session's model per message. The main model still reads every
message and the helper's reply, so savings only come from the work the helper does. Helpers see
only the prompt the main model writes for them, not the whole conversation.

## Switch and status

Type these words in Claude Code. The hook answers them itself; they are not sent to the model.
- `jev router on`
- `jev router off`
- `jev router status`

From a shell: `python3 ~/.claude/jev-router/router.py on|off|status|reset`.

- `state.json`: on/off state, counts, Jev tokens and cost ($0.042 per Mtok input).
- `decisions.log`: one JSON line per routed message (route, probability, latency). It never
  stores the message text.

When ON, every message except slash commands, `!` commands, short replies and secret-looking text
is sent to api.typesafe.ai.
