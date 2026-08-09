# Trae

ByteDance's terminal coding agent (Trae Agent).

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | ByteDance |
| **Install channel** | `uv tool install --python 3.12 --upgrade "trae-agent[evaluation] @ git+https://github.com/bytedance/trae-agent.git"` |
| **Native auth** | Provider-agnostic via env vars (OpenAI, Anthropic, etc.) |
| **Default model** | `anthropic/claude-sonnet-5` (override: `setx OPENROUTER_MODEL "..."` — Trae shares the OpenRouter wrapper var) |
| **OpenRouter launcher** | yes |
| **LM Studio launcher** | yes |
| **Runtime deps** | uv + Python 3.12 (uv handles both); see notes for why 3.13 is rejected |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Trae--install.cmd` | Install / update via `uv tool install` from the GitHub source. Re-runnable. |
| `Trae--openrouter.cmd` | Route through OpenRouter using `OPENROUTER_MODEL`. |
| `Trae--local-lmstudio.cmd` | Point at `${LMSTUDIO_URL}/v1` with auto-detected model. |
| `Trae--remote-lmstudio.cmd` | Set `LMSTUDIO_URL` then call the local launcher. |
| `Trae--uninstall.cmd` | Remove the `uv tool` install. Leaves config alone. |
| `Trae--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |

> No native `Trae--run.cmd` — only the OpenRouter / LM Studio launchers ship in this repo.

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.trae`

## Maintenance notes

**Not on PyPI.** Installed from GitHub as `trae-agent[evaluation] @ git+https://github.com/bytedance/trae-agent.git`. Pinned to Python 3.12 because the `tree-sitter-languages` pin has no wheels for 3.13+. The `[evaluation]` extra is required even for normal use because `base_agent.py` unconditionally imports `docker_manager`, which pulls in `docker` and `pexpect`.

If Trae fails to import `docker_manager`, the `[evaluation]` extra was not installed. Re-run `Trae--install.cmd`; the script always passes the right spec.

## Plugins

Both `Trae--install.cmd` and `Trae--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Trae {install,uninstall}` so any plugin whose manifest lists Trae in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

No plugin in the repo currently ships a hook for Trae.
