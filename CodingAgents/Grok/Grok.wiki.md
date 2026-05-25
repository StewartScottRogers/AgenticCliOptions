# Grok

xAI's terminal coding agent. Beta software.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | xAI |
| **Install channel** | Official bash installer (`curl -fsSL https://x.ai/cli/install.sh \| bash`, via Git Bash); npm fallback `grok-build` |
| **Native auth** | SuperGrok account or `GROK_CODE_XAI_API_KEY` |
| **Default model** | `xai-managed` (CLI picks internally) |
| **OpenRouter launcher** | no (xAI-only API) |
| **LM Studio launcher** | no (xAI-only API) |
| **Runtime deps** | Git for Windows (provides `bash.exe`); Node.js LTS for the npm fallback |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Grok--install.cmd` | Tries the official bash installer first, falls back to `grok-build` from npm. |
| `Grok--run.cmd` | Launch against the xAI API. |
| `Grok--uninstall.cmd` | Removes the binary from all three known install locations + the npm package. |
| `Grok--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |
| `Grok--local-lmstudio.cmd` | Stub — xAI only. |
| `Grok--remote-lmstudio.cmd` | Placeholder. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.grok`
- `~/.x.ai` (may exist)

## Maintenance notes

Beta software; primary install path is the official bash installer (`curl -fsSL https://x.ai/cli/install.sh | bash`, run through Git Bash), npm fallback is the community `grok-build` package. If both paths fail, check <https://x.ai/cli> for the current install method. The uninstaller cleans up `%USERPROFILE%\.local\bin\grok`, `~/.x.ai\bin\grok`, `~/.grok\bin\grok` and the npm package.

## Plugins

Both `Grok--install.cmd` and `Grok--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Grok {install,uninstall}` so any plugin whose manifest lists Grok in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

No plugin in the repo currently ships a hook for Grok.
