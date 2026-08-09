# Gemini

Google's terminal coding agent.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## ⚠️ Deprecation: 2026-06-18

As of **2026-06-18**, Gemini CLI no longer serves requests for Google AI Pro, Ultra, and free Gemini Code Assist users. Enterprise tier (Gemini Code Assist Standard / Enterprise) keeps access.

**Migration:** install [Antigravity CLI](../Antigravity/Antigravity.wiki.md) — Google's Go-based successor — and run `agy plugin import gemini` to convert extensions and settings.

## At a glance

| | |
|---|---|
| **Vendor** | Google |
| **Install channel** | npm `@google/gemini-cli` |
| **Native auth** | Google account (free tier) or `GEMINI_API_KEY` |
| **Default model** | `gemini-2.5-pro` (override: `setx GEMINI_MODEL "..."`) |
| **OpenRouter launcher** | no (Google-only API) |
| **LM Studio launcher** | no (Google-only API) |
| **Runtime deps** | Node.js LTS (>= 22) |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Gemini--install.cmd` | Install / update the npm package. Re-runnable. |
| `Gemini--run.cmd` | Launch against the Google API using `GEMINI_MODEL`. |
| `Gemini--uninstall.cmd` | Remove the npm install. Leaves `~/.gemini/` alone. |
| `Gemini--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |
| `Gemini--local-lmstudio.cmd` | Stub — Gemini CLI has no OpenAI-compatible endpoint flag. |
| `Gemini--remote-lmstudio.cmd` | Placeholder. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.gemini`

## Maintenance notes

No OpenRouter / LM Studio launcher; the Gemini CLI only speaks Google's own API. To route Gemini *models* via OpenRouter today, use the [Qwen Code CLI](../Qwen/Qwen.wiki.md) (it's a Gemini CLI fork and accepts an OpenAI base URL).

Unless you are on the Enterprise tier, prefer Antigravity — the 2026-06-18 cutoff has passed.

## Plugins

Both `Gemini--install.cmd` and `Gemini--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Gemini {install,uninstall}` so any plugin whose manifest lists Gemini in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

Plugins shipping a hook for Gemini:

- [`context7-mcp`](../Plugins/context7-mcp/plugin.json) — Context7 MCP server (up-to-date library docs). Merged into `mcpServers.context7` in `~/.gemini/settings.json`; other keys / other MCP servers in the file are preserved.
