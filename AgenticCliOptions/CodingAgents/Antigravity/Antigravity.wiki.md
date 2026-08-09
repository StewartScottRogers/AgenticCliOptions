# Antigravity

Google's Go-based agentic CLI — the successor to Gemini CLI. Binary is `agy`.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | Google |
| **Install channel** | Official PowerShell installer `https://antigravity.google/cli/install.ps1` → `%LOCALAPPDATA%\agy\bin\agy.exe` |
| **Native auth** | Google account via system keyring (browser sign-in on first run) |
| **Default model** | `antigravity-managed` (multi-backend; switch via in-CLI `/model`) |
| **OpenRouter launcher** | no (provider-config schema not yet documented) |
| **LM Studio launcher** | no (same reason) |
| **Runtime deps** | none — single Go binary (no Node / Python / Git / winget needed) |
| **Architectures** | `windows_amd64`, `windows_arm64` |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Antigravity--install.cmd` | Runs the official `install.ps1`, refreshes PATH so `agy --version` works immediately. |
| `Antigravity--run.cmd` | Launches `agy`. Pick model with the in-CLI `/model` slash command. |
| `Antigravity--uninstall.cmd` | Deletes `agy.exe` + `%LOCALAPPDATA%\agy\`, prunes the User PATH entry. |
| `Antigravity--is-installed.cmd` | Probes both `where agy` and the known binary path. |
| `Antigravity--openrouter.cmd` | Stub — see note below. |
| `Antigravity--local-lmstudio.cmd` | Stub — see note below. |
| `Antigravity--remote-lmstudio.cmd` | Placeholder. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.antigravity`
- `%LOCALAPPDATA%\antigravity`

(The `%LOCALAPPDATA%\agy\` install dir IS removed by the uninstaller.)

## Maintenance notes

**The installer is not an updater.** Antigravity CLI self-updates in the background, and the upstream `install.ps1` refuses to overwrite an existing `agy.exe`. To force a fresh install, `del "%LOCALAPPDATA%\agy\bin\agy.exe"` first.

Multi-backend out of the box: Gemini 3 Pro, Claude Sonnet 4.5, and GPT-OSS are all selectable from inside the CLI without any per-vendor API key in this repo.

The OpenRouter and LM Studio launchers are **honest stubs**. The upstream config schema for adding a custom OpenAI-compatible provider (the equivalent of `~/.codex/config.toml`'s `model_providers` block) is not yet documented in a form trustworthy enough to script. Update those launchers once Google publishes the schema. In the meantime, route via `Qwen--openrouter.cmd`, `Codex--openrouter.cmd`, or `Claude--openrouter.cmd`.

**Gemini CLI deprecation context:** As of 2026-06-18, Gemini CLI no longer serves Pro/Ultra/free Code Assist users (Enterprise keeps it). Antigravity is the supported successor for those users — see the [Gemini](../Gemini/Gemini.wiki.md) per-agent wiki for the deprecation note.

## Plugins

Both `Antigravity--install.cmd` and `Antigravity--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Antigravity {install,uninstall}` so any plugin whose manifest lists Antigravity in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

Plugins shipping a hook for Antigravity:

- [`context7-mcp`](../Plugins/context7-mcp/plugin.json) — Context7 MCP server (up-to-date library docs). Merged into `mcpServers.context7` in `~/.antigravity/settings.json`. The shape mirrors Gemini's `settings.json` convention; if upstream ships an `agy mcp add` subcommand later, switch the hook to call that instead.
