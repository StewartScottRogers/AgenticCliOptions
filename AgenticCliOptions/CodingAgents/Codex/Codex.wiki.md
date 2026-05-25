# Codex

OpenAI's terminal coding agent.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | OpenAI |
| **Install channel** | npm `@openai/codex` |
| **Native auth** | OpenAI / ChatGPT account |
| **Default model** | `gpt-5.5` (override: `setx CODEX_MODEL "..."`) |
| **OpenRouter launcher** | yes (on-the-fly `-c model_provider=...` overrides) |
| **LM Studio launcher** | yes (same `-c` override mechanism) |
| **Runtime deps** | Node.js LTS (>= 22) |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Codex--install.cmd` | Install / update the npm package. Re-runnable. |
| `Codex--run.cmd` | Launch against the OpenAI API using `CODEX_MODEL`. |
| `Codex--openrouter.cmd` | Route through OpenRouter via on-the-fly `-c model_providers.openrouter.*` overrides + `OPENROUTER_API_KEY`. |
| `Codex--local-lmstudio.cmd` | Same `-c` override mechanism pointed at `${LMSTUDIO_URL}/v1`. |
| `Codex--remote-lmstudio.cmd` | Set `LMSTUDIO_URL` then call the local launcher. |
| `Codex--uninstall.cmd` | Remove the npm install. Leaves `~/.codex/` alone. |
| `Codex--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.codex`

## Maintenance notes

OpenRouter launcher uses on-the-fly `-c model_provider=...` overrides instead of editing `~/.codex/config.toml`, so nothing is persisted.

`wire_api=responses` selects the OpenAI Responses API protocol — the chat-completions wire shape was removed from codex (see github.com/openai/codex/discussions/7782); OpenRouter mirrors `/v1/responses` for `openai/*` models. `--dangerously-bypass-approvals-and-sandbox` is the modern replacement for the retired `--yolo` flag (skips all approval prompts; rely on git for safety).

## Plugins

Both `Codex--install.cmd` and `Codex--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Codex {install,uninstall}` so any plugin whose manifest lists Codex in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

Plugins shipping a hook for Codex:

- [`context7-mcp`](../Plugins/context7-mcp/plugin.json) — Context7 MCP server (up-to-date library docs). Added as a sentinel-fenced `[mcp_servers.context7]` block in `~/.codex/config.toml` so re-install / uninstall finds exactly that block without touching the user's other MCP entries.
