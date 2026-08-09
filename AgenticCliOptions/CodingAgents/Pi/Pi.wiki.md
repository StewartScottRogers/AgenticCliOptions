# Pi

Earendil's terminal coding agent.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | Earendil |
| **Install channel** | npm `@earendil-works/pi-coding-agent` (installed with `--ignore-scripts`) |
| **Native auth** | `/login` slash command or provider API keys |
| **Default model** | `anthropic/claude-sonnet-5` (override: `setx PI_MODEL "..."`) |
| **OpenRouter launcher** | yes |
| **LM Studio launcher** | no (LM Studio integration lives in Pi's `models.json` instead) |
| **Runtime deps** | Node.js LTS (>= 22) |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Pi--install.cmd` | Uninstalls the legacy `@mariozechner/pi-coding-agent` first to avoid an `EEXIST` collision, then installs `@earendil-works/pi-coding-agent`. |
| `Pi--run.cmd` | Launch the CLI. |
| `Pi--openrouter.cmd` | Route through OpenRouter using `PI_MODEL`. |
| `Pi--uninstall.cmd` | Remove the npm install. Leaves `~/.pi/` alone. |
| `Pi--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |
| `Pi--local-lmstudio.cmd` | Stub — Pi uses its own `models.json` for local model routing. |
| `Pi--remote-lmstudio.cmd` | Placeholder. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.pi`

## Maintenance notes

`Pi--install.cmd` first quietly uninstalls the legacy `@mariozechner/pi-coding-agent` package because both ship a `pi` bin and npm fails with `EEXIST` otherwise. Pi installs with `--ignore-scripts` per upstream guidance.

Pi has no LM Studio launcher — LM Studio integration lives in Pi's `models.json`. The fork [Oh-My-Pi](../Oh-My-Pi/Oh-My-Pi.wiki.md) is shipped alongside Pi in this repo.

## Plugins

Both `Pi--install.cmd` and `Pi--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Pi {install,uninstall}` so any plugin whose manifest lists Pi in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

No plugin in the repo currently ships a hook for Pi.
