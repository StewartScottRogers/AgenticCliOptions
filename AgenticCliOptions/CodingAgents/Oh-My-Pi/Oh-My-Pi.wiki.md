# Oh-My-Pi

TypeScript coding-first fork of Pi from [can1357](https://github.com/can1357).

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | can1357 |
| **Install channel** | PowerShell installer (`omp.sh/install.ps1 -Binary`) → `%LOCALAPPDATA%\omp\omp.exe` |
| **Native auth** | `OPENROUTER_API_KEY` (and many others) |
| **Default model** | `openrouter/anthropic/claude-sonnet-5` (override: `setx OMP_MODEL "..."`) |
| **OpenRouter launcher** | yes (`--model openrouter/<provider>/<model>`) |
| **LM Studio launcher** | no (stub) |
| **Runtime deps** | `bash.exe` (installer pulls Git for Windows if missing); **no Bun** needed thanks to the `-Binary` flag |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Oh-My-Pi--install.cmd` | Wraps the upstream installer in binary mode, working around two known parse failures (see notes). |
| `Oh-My-Pi--run.cmd` | Launch the CLI. |
| `Oh-My-Pi--openrouter.cmd` | Route through OpenRouter using `--model openrouter/<provider>/<model>`. |
| `Oh-My-Pi--uninstall.cmd` | Removes the install dir manually (no upstream uninstaller) and prunes the User PATH entry. |
| `Oh-My-Pi--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |
| `Oh-My-Pi--local-lmstudio.cmd` | Stub. |
| `Oh-My-Pi--remote-lmstudio.cmd` | Placeholder. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.omp`
- `%LOCALAPPDATA%\omp` (the install dir IS removed by the uninstaller, but config under it may persist)

## Maintenance notes

You also ship the original [Pi](../Pi/Pi.wiki.md) — Oh-My-Pi is a separate fork.

Installed via the upstream PowerShell installer in **binary** mode (`-Binary` flag) so no Bun is required at install time. The prebuilt EXE lands under `%LOCALAPPDATA%\omp\omp.exe` and that dir is added to the User PATH. The upstream tool has no uninstaller, so `Oh-My-Pi--uninstall.cmd` removes the install dir manually and prunes the PATH entry from the registry.

**Two installer gotchas we already work around** — both hidden in `Oh-My-Pi--install.cmd`, no action needed unless upstream rewrites their `install.ps1`:

1. The upstream usage pattern `& ([scriptblock]::Create((irm ...))) -Binary` uses nested parens that cmd cannot parse; we stage the script to a temp file instead.
2. `install.ps1` contains Unicode characters (✓, ⚠) but ships with **no BOM**. Windows PowerShell 5.1 reads BOM-less files as Windows-1252, which mangles the multi-byte UTF-8 and crashes the parser with `Unexpected token 'Path", "Machine")'`. We download via `Net.WebClient`, decode as UTF-8, and re-save **with a UTF-8 BOM** before invoking. Watch for this pattern in any future PowerShell-installer agent.

## Plugins

Both `Oh-My-Pi--install.cmd` and `Oh-My-Pi--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Oh-My-Pi {install,uninstall}` so any plugin whose manifest lists Oh-My-Pi in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

No plugin in the repo currently ships a hook for Oh-My-Pi.
