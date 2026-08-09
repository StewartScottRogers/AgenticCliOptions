# Tau

Hugging Face's minimalist terminal coding agent (`tau-ai`).

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | Hugging Face |
| **Install channel** | PyPI `tau-ai` via `uv tool` (Python 3.12+) |
| **Native auth** | `/login` slash command or provider API keys |
| **Default model** | `claude-sonnet-5` on provider `anthropic` (override: `setx TAU_MODEL "..."` / `setx TAU_PROVIDER "..."`) |
| **OpenRouter launcher** | yes (built-in `openrouter` provider) |
| **LM Studio launcher** | yes (registers a provider via `tau setup`) |
| **Runtime deps** | uv + CPython 3.12 (uv auto-downloads Python) |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Tau--install.cmd` | Installs/updates `tau-ai` with `uv tool install --force --python 3.12 --upgrade`. |
| `Tau--run.cmd` | Launch the CLI, pinning `TAU_PROVIDER` + `TAU_MODEL`. |
| `Tau--openrouter.cmd` | Route through the built-in `openrouter` provider using `OPENROUTER_MODEL`. |
| `Tau--local-lmstudio.cmd` | `tau setup` a local `lmstudio` provider, then run against LM Studio. |
| `Tau--remote-lmstudio.cmd` | Placeholder. |
| `Tau--uninstall.cmd` | Remove the uv tool. Leaves `~/.tau/` alone. |
| `Tau--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.tau` (sessions under `~/.tau/sessions/`, user provider overrides in `~/.tau/catalog.toml`)

## Maintenance notes

Tau is Pi-derived: its built-in provider catalog is generated from Pi's API-provider metadata, so model slugs and provider names (`openai`, `anthropic`, `openrouter`, `huggingface`, ...) match Pi's. Model IDs are **provider-scoped** - e.g. `claude-sonnet-5` under `anthropic`, but `anthropic/claude-sonnet-5` under `openrouter`. Run `tau providers` to see what's configured and `tau --version` for the installed version.

`tau setup --provider <name> --base-url <url> --api-key-env <VAR>` registers any OpenAI-compatible endpoint into `~/.tau/catalog.toml`; the LM Studio launcher uses this each run (the upsert is idempotent).

## Plugins

Both `Tau--install.cmd` and `Tau--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Tau {install,uninstall}` so any plugin whose manifest lists Tau in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

No plugin in the repo currently ships a hook for Tau.
