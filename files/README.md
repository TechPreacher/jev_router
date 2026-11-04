# Model router

A `UserPromptSubmit` hook (`~/.claude/settings.json`) runs `router.py hook` on every message.
When the router is ON, it asks TypeSafe Jev one Choice question about the message: what is the
smallest model that can do this job well? It then tells the main session to delegate the job:

| Size | Helper agent | Model |
|---|---|---|
| tiny: lookup, rename, one-line answer | `router-tiny` | Claude Haiku 5.5 |
| everyday: normal email, post, short doc | `router-everyday` | Claude Sonnet 5.5 |
| large: multi-step build, research, full report | `router-large` | Claude Opus 5.5 |
| hardest: strategy, costly-if-wrong | `router-hardest` | Claude Fable 5.1 |

Helpers live in `~/.claude/agents/router-*.md`. Each ends its reply with a `— done by <model>` line.

The main session handles the message itself when:
- the sizing model's top pick is under 60% likely;
- the message is a short reply that needs the conversation, such as "yes but shorter". This is a
  code check: 12 words or fewer, with a yes/ok opener or a word like it, that, again, shorter;
- the message looks like it contains a secret (API key, password, private key). It is not sent to the sizing backend;
- the sizing backend is slow (over 1.5 s), fails, or its credentials are missing. Every error exits 0 with no output.

## Backend and credentials

Two backends answer the sizing question with the same request and response shape:

- **TypeSafe Jev** (default): `https://api.typesafe.ai`, model `jev-latest`, authenticated with
  `TYPESAFE_API_KEY`.
- **Microsoft Decision-1 in Azure AI Foundry**: used as soon as `MODEL_ROUTER_AZURE_ENDPOINT` (the Foundry
  resource endpoint, with or without `/providers/microsoft`) and `MODEL_ROUTER_AZURE_DEPLOYMENT` (the deployment
  name) are set. Requests go to `<endpoint>/providers/microsoft/v1/systemone` with `model` = deployment.
  Authentication is a Microsoft Entra bearer token from `az account get-access-token --scope
  https://ai.azure.com/.default` (change the scope with `MODEL_ROUTER_AZURE_SCOPE`), or an `api-key` header when
  `MODEL_ROUTER_AZURE_API_KEY` is set. `MODEL_ROUTER_BACKEND=typesafe` forces TypeSafe even when the Azure values exist.

Every one of these values is read from the environment first, then from the macOS Keychain item with
that service name. The Keychain path matters for the Claude desktop app, which launches hooks without
the user's shell environment, so fish/zsh exports are not visible there. Store each once:

    security add-generic-password -U -a "$USER" -s TYPESAFE_API_KEY -w
    security add-generic-password -U -a "$USER" -s MODEL_ROUTER_AZURE_ENDPOINT -w
    security add-generic-password -U -a "$USER" -s MODEL_ROUTER_AZURE_DEPLOYMENT -w

(`-w` with no value prompts for the value.) The endpoint and deployment name are treated as secrets:
`status` names the backend but never prints them.

The hook has 3 seconds and `az` needs about 2.5, so the hook never calls `az`. It uses a token cached in
`~/.claude/model-router/azure-token.json` (owner-only file) and, when that is missing or has under ten
minutes left, starts `router.py azure-token` as a detached background process and lets the current
message through unrouted (`status` then shows `last error: ... Azure token not cached yet`). The next
message routes. `router.py on` fetches the token right away, so turning the router on from a shell
avoids that first miss; `router.py azure-token` refreshes it by hand. Tokens last about an hour, so a
long session refreshes itself a few times without you noticing.

`model router status` shows `last error` when the active backend's credentials are missing.

## Limits

Claude Code can't switch the main session's model per message. The main model still reads every
message and the helper's reply, so savings only come from the work the helper does. Helpers see
only the prompt the main model writes for them, not the whole conversation.

## Switch and status

Type these words in Claude Code. The hook answers them itself; they are not sent to the model.
- `model router on`
- `model router off`
- `model router status`

From a shell: `python3 ~/.claude/model-router/router.py on|off|status|reset`.

- `state.json`: on/off state, counts, sizing input tokens and cost (at TypeSafe's $0.042 per Mtok).
- `decisions.log`: one JSON line per routed message (route, probability, latency). It never
  stores the message text.

When ON, every message except slash commands, `!` commands, short replies and secret-looking text
is sent to api.typesafe.ai.
