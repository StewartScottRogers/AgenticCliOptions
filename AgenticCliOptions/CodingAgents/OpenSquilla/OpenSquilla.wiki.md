# OpenSquilla

Token-efficient microkernel coding agent.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | OpenSquilla |
| **Install channel** | `uv tool install --python 3.12 --upgrade "opensquilla[recommended] @ <github-wheel-url>"` |
| **Native auth** | `OPENROUTER_API_KEY` (via `opensquilla configure --api-key-env`) |
| **Default model** | `anthropic/claude-sonnet-5` (override: `setx OPENSQUILLA_MODEL "..."`) |
| **OpenRouter launcher** | yes |
| **LM Studio launcher** | no (stub) |
| **Runtime deps** | uv + Python 3.12 (uv handles both); VC++ Redistributable for some wheels |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `OpenSquilla--install.cmd` | Queries the GitHub Releases API for the latest `.whl`, installs via `uv tool install`. Re-run to upgrade. |
| `OpenSquilla--run.cmd` | Launch against the configured provider. |
| `OpenSquilla--openrouter.cmd` | Persists `opensquilla configure --provider openrouter --api-key-env OPENROUTER_API_KEY --model <slug>`, then runs `opensquilla chat --model <slug>`. |
| `OpenSquilla--uninstall.cmd` | Remove the `uv tool` install. Leaves config alone. |
| `OpenSquilla--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |
| `OpenSquilla--local-lmstudio.cmd` | Stub. |
| `OpenSquilla--remote-lmstudio.cmd` | Placeholder. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.opensquilla`

## Maintenance notes

**Not on PyPI**: the upstream installer only accepts a published wheel URL from GitHub Releases. `OpenSquilla--install.cmd` hits the GitHub API on every run to discover the latest `.whl` asset, then installs via `uv tool install --python 3.12 --upgrade "opensquilla[recommended] @ <url>"`. Re-run to upgrade.

The OpenRouter launcher persists the provider via `opensquilla configure --section provider --provider openrouter --api-key-env OPENROUTER_API_KEY --model <slug>` and then `opensquilla chat --model <slug>`.

`opensquilla` has no `--version` flag, so the install script reads the version from `uv tool list`. If you see `DLL load failed`, install the VC++ Redistributable.

## Plugins

Both `OpenSquilla--install.cmd` and `OpenSquilla--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd OpenSquilla {install,uninstall}` so any plugin whose manifest lists OpenSquilla in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

No plugin in the repo currently ships a hook for OpenSquilla.
