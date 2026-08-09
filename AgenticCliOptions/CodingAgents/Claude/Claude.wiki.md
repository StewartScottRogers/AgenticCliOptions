# Claude Code

Anthropic's terminal coding agent.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | Anthropic |
| **Install channel** | npm `@anthropic-ai/claude-code` (and Anthropic's native installer at `~/.local/bin/claude.exe`) |
| **Native auth** | Anthropic / Claude Code subscription |
| **Default model** | `claude-sonnet-4-5` (override: `setx CLAUDE_MODEL "..."`) |
| **OpenRouter launcher** | yes |
| **LM Studio launcher** | yes (driven by the sibling settings JSON) |
| **Runtime deps** | Node.js LTS (>= 22) — installer pulls via winget if missing |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Claude--install.cmd` | Install / update the npm package. Re-runnable. |
| `Claude--run.cmd` | Launch against the Anthropic API using `CLAUDE_MODEL`. |
| `Claude--openrouter.cmd` | Route through OpenRouter via `ANTHROPIC_BASE_URL=https://openrouter.ai/api` + `OPENROUTER_API_KEY`. |
| `Claude--local-lmstudio.cmd` | Launch against a local LM Studio server. Renders `LMStudio.Claude.Settings.template.json`. |
| `Claude--remote-lmstudio.cmd` | Set `LMSTUDIO_URL` then call the local launcher. |
| `Claude--uninstall.cmd` | Removes BOTH the npm install and the native `~/.local/bin/claude.exe` shim. |
| `Claude--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |
| `LMStudio.Claude.Settings.template.json` | Template for the `--settings` file passed by the LM Studio launcher: sets `ANTHROPIC_BASE_URL` + a `UserPromptSubmit` hook that echoes the loaded model id. The launcher substitutes `__LMSTUDIO_URL__` and writes the rendered file to a temp path. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.claude`

## Maintenance notes

Install has *two* paths: the npm package `@anthropic-ai/claude-code` and Anthropic's native installer that drops a binary at `~/.local/bin/claude.exe`. The uninstaller cleans up both. If `del` fails with "Access is denied", a `claude` process is still running — close it and re-run the uninstaller.

There's also a `RunClaude.cmd` shortcut at the repo root that's identical to `Claude--run.cmd`.

## Plugins

Both `Claude--install.cmd` and `Claude--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Claude {install,uninstall}` so any plugin whose manifest lists Claude in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

Plugins shipping a hook for Claude:

- [`context7-mcp`](../Plugins/context7-mcp/plugin.json) — Context7 MCP server (up-to-date library docs). Registered via `claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp`.
