# Junie

JetBrains' AI coding agent for the terminal.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | JetBrains |
| **Install channel** | Official PowerShell installer (`install.ps1`) → `~/.local/bin\junie.bat` |
| **Native auth** | Junie subscription or `--openrouter-api-key` BYOK |
| **Default model** | `sonnet` (override: `setx JUNIE_MODEL "..."`) |
| **OpenRouter launcher** | yes (BYOK via `--openrouter-api-key` flag) |
| **LM Studio launcher** | no (stub) |
| **Runtime deps** | none from this repo — installer ships its own binaries |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Junie--install.cmd` | Runs the upstream PowerShell installer. Junie self-updates on next launch. |
| `Junie--run.cmd` | Launch with a Junie subscription, against the JetBrains API. |
| `Junie--openrouter.cmd` | Passes `--openrouter-api-key %OPENROUTER_API_KEY% --model <slug>`. |
| `Junie--uninstall.cmd` | Removes the shim and data dir manually — no upstream uninstaller. |
| `Junie--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |
| `Junie--local-lmstudio.cmd` | Stub. |
| `Junie--remote-lmstudio.cmd` | Placeholder. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.local\share\junie`
- `%USERPROFILE%\.junie`

## Maintenance notes

Junie self-updates: re-running the installer reinstalls the current release; the running binary applies pending updates on next launch.

No uninstall command upstream, so `Junie--uninstall.cmd` removes the shim and data dir manually.

## Plugins

Both `Junie--install.cmd` and `Junie--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Junie {install,uninstall}` so any plugin whose manifest lists Junie in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

No plugin in the repo currently ships a hook for Junie.
