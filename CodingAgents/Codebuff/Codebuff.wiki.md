# Codebuff

Terminal coding agent backed by the codebuff.com platform.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | Codebuff AI |
| **Install channel** | npm `codebuff` |
| **Native auth** | codebuff.com login (run `codebuff` on first launch) |
| **Default model** | `codebuff-managed` (platform routes internally; no `--model` flag) |
| **OpenRouter launcher** | no (platform-managed routing) |
| **LM Studio launcher** | no (same reason) |
| **Runtime deps** | Node.js LTS (>= 22); `bash.exe` at runtime (installer pulls Git for Windows if missing) |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Codebuff--install.cmd` | Install / update the npm package. Pulls Git for Windows if `bash` is missing. |
| `Codebuff--run.cmd` | Launch the CLI; signs you in on first run. |
| `Codebuff--uninstall.cmd` | Remove the npm install. Leaves config alone. |
| `Codebuff--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |
| `Codebuff--local-lmstudio.cmd` | Stub — Codebuff has no BYO-provider hook. |
| `Codebuff--remote-lmstudio.cmd` | Placeholder. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.codebuff`

## Maintenance notes

Installed via `npm install -g codebuff@latest`. On Windows it needs `bash.exe` to run its shell-execution tool; the installer pulls Git for Windows if missing (you already have it for Grok).

**No OpenRouter launcher**: Codebuff handles model routing internally via its own backend and does not document a way to BYO an OpenRouter key at the CLI. Sign in with `codebuff` on first run.

## Plugins

Both `Codebuff--install.cmd` and `Codebuff--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Codebuff {install,uninstall}` so any plugin whose manifest lists Codebuff in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

No plugin in the repo currently ships a hook for Codebuff.
