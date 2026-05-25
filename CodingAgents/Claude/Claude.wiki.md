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
| `Claude--local-lmstudio.cmd` | Launch against a local LM Studio server. Reads `LMStudio.Claude.Settings.json`. |
| `Claude--remote-lmstudio.cmd` | Set `LMSTUDIO_URL` then call the local launcher. |
| `Claude--uninstall.cmd` | Removes BOTH the npm install and the native `~/.local/bin/claude.exe` shim. |
| `Claude--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |
| `LMStudio.Claude.Settings.json` | `--settings` file passed by the LM Studio launcher: sets `ANTHROPIC_BASE_URL` + a `UserPromptSubmit` hook that echoes the loaded model id. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.claude`

## Maintenance notes

Install has *two* paths: the npm package `@anthropic-ai/claude-code` and Anthropic's native installer that drops a binary at `~/.local/bin/claude.exe`. The uninstaller cleans up both. If `del` fails with "Access is denied", a `claude` process is still running — close it and re-run the uninstaller.

There's also a `RunClaude.cmd` shortcut at the repo root that's identical to `Claude--run.cmd`.
