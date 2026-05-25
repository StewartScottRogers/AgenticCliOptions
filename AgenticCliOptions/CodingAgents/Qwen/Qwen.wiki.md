# Qwen

Alibaba's Qwen Code CLI — a fork of the Gemini CLI that speaks OpenAI-compatible APIs.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | Alibaba |
| **Install channel** | npm `@qwen-code/qwen-code` |
| **Native auth** | OAuth or `OPENAI_*` env vars |
| **Default model** | `qwen/qwen3-coder` (override: `setx QWEN_MODEL "..."`) |
| **OpenRouter launcher** | yes |
| **LM Studio launcher** | yes (settings file detected from the launcher's CWD) |
| **Runtime deps** | **Node.js 22+** (required) |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Qwen--install.cmd` | Install / update the npm package. Re-runnable. |
| `Qwen--openrouter.cmd` | Sets `OPENAI_BASE_URL=https://openrouter.ai/api/v1` + `OPENAI_API_KEY=%OPENROUTER_API_KEY%`. |
| `Qwen--local-lmstudio.cmd` | Auto-detects the loaded model from `${LMSTUDIO_URL}/v1/models` and pins the CLI to it. |
| `Qwen--remote-lmstudio.cmd` | Set `LMSTUDIO_URL` then call the local launcher. |
| `Qwen--uninstall.cmd` | Remove the npm install. Leaves `~/.qwen/` alone. |
| `Qwen--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |

> No native `Qwen--run.cmd` — only the OpenRouter / LM Studio launchers ship in this repo. Both honour `QWEN_MODEL` (not the shared `OPENROUTER_MODEL`).

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.qwen`

## Maintenance notes

**Requires Node 22+.** If you upgrade Node manually, make sure the major version is `>=22` or `Install-All.cmd :ensure_node_22` will (correctly) force an upgrade.

Because Qwen Code is a Gemini-CLI fork that accepts an OpenAI-compatible base URL, it's the recommended way to route Gemini-family *models* through OpenRouter — see the [Gemini](../Gemini/Gemini.wiki.md) per-agent wiki.

## Plugins

Both `Qwen--install.cmd` and `Qwen--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Qwen {install,uninstall}` so any plugin whose manifest lists Qwen in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

No plugin in the repo currently ships a hook for Qwen.
