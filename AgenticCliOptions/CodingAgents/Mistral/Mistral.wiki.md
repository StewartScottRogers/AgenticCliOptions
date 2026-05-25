# Mistral

Mistral AI's terminal coding agent (the `mistral-vibe` CLI).

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | Mistral AI |
| **Install channel** | `uv tool install mistral-vibe` |
| **Native auth** | `MISTRAL_API_KEY` |
| **Default model** | Native: `mistral-managed` (CLI picks internally; no `--model` flag). OpenRouter wrapper: `OPENROUTER_MODEL`. |
| **OpenRouter launcher** | yes — **caveat**: works by overriding `MISTRAL_BASE_URL`, which only works if the current Vibe build honours that env var |
| **LM Studio launcher** | no (stub) |
| **Runtime deps** | uv + Python (uv handles both) |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Mistral--install.cmd` | Install / update via `uv tool install`. Re-runnable. |
| `Mistral--run.cmd` | Launch against the Mistral API using `MISTRAL_API_KEY`. |
| `Mistral--openrouter.cmd` | Sets `MISTRAL_BASE_URL=https://openrouter.ai/api/v1` + `MISTRAL_API_KEY=%OPENROUTER_API_KEY%`. |
| `Mistral--uninstall.cmd` | Remove the `uv tool` install. Leaves config alone. |
| `Mistral--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |
| `Mistral--local-lmstudio.cmd` | Stub. |
| `Mistral--remote-lmstudio.cmd` | Placeholder. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.mistral`
- `%USERPROFILE%\.vibe`

## Maintenance notes

Installs as `uv tool install mistral-vibe`. The OpenRouter launcher works by overriding `MISTRAL_BASE_URL`, which only works if the current Vibe build honours that env var. **Verify with a short test prompt after a Vibe update.**

If Mistral via OpenRouter ignores `MISTRAL_BASE_URL`, your Vibe build doesn't honour that env var. Use `Mistral--run.cmd` against the native Mistral API, or drive Mistral models through OpenRouter with a different OpenAI-compatible CLI (Codex, Qwen, Trae).

## Plugins

Both `Mistral--install.cmd` and `Mistral--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Mistral {install,uninstall}` so any plugin whose manifest lists Mistral in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

No plugin in the repo currently ships a hook for Mistral.
