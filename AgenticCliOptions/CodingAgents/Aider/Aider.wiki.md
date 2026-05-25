# Aider

The classic AI pair-programmer for the terminal, from the Aider community.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | Aider community |
| **Install channel** | `uv tool install --force --python 3.12 --upgrade aider-chat` |
| **Native auth** | `OPENROUTER_API_KEY` (and many others) |
| **Default model** | `openrouter/anthropic/claude-sonnet-4.5` (override: `setx AIDER_MODEL "..."`) |
| **OpenRouter launcher** | yes |
| **LM Studio launcher** | no (stub — use Qwen / Codex / Claude for local routing) |
| **Runtime deps** | Git (installer pulls Git for Windows if missing); Python 3.12 (uv downloads it) |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Aider--install.cmd` | Install / update via `uv tool install`. Re-runnable. |
| `Aider--run.cmd` | Launch against the native API using `AIDER_MODEL`. |
| `Aider--openrouter.cmd` | Route through OpenRouter with `OPENROUTER_API_KEY` + `OPENROUTER_MODEL`. |
| `Aider--uninstall.cmd` | Remove the `uv tool` install. Leaves `~/.aider*` config alone. |
| `Aider--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |
| `Aider--local-lmstudio.cmd` | Stub — Aider has no first-class local-server launcher in this repo. |
| `Aider--remote-lmstudio.cmd` | Placeholder. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.aider.conf.yml`
- `%USERPROFILE%\.aider.tags.cache.v3`

## Maintenance notes

Installed via `uv tool install --force --python 3.12 --upgrade aider-chat`. Needs Git installed at runtime to track edits; the installer pulls Git for Windows if missing. OpenRouter via `--model openrouter/<provider>/<model>` with `OPENROUTER_API_KEY` in the environment. `aider --list-models openrouter/` enumerates every routable model Aider knows about.

## Plugins

Both `Aider--install.cmd` and `Aider--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Aider {install,uninstall}` so any plugin whose manifest lists Aider in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

No plugin in the repo currently ships a hook for Aider.
