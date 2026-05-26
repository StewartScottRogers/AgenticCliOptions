# Hermes

Nous Research's terminal coding agent. Native Windows is an **early beta** but installs and runs cleanly.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | Nous Research |
| **Install channel** | Official PowerShell installer (`install.ps1`) → `%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts\hermes.exe` |
| **Native auth** | Nous Portal OAuth or `OPENROUTER_API_KEY` |
| **Default model** | `Hermes-4-405B` (override: `setx HERMES_MODEL "..."`) |
| **OpenRouter launcher** | yes (`--provider openrouter --model <slug>`) |
| **LM Studio launcher** | no (stub) |
| **Runtime deps** | none from this repo — the installer provisions Python 3.11 via uv, Node, PortableGit, ripgrep, ffmpeg, and a Playwright Chromium under `%LOCALAPPDATA%\hermes` |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Hermes--install.cmd` | Runs the upstream PowerShell installer via `Hhermes-install-patched.ps1` (which patches the `playwright install chromium` call to suppress a misleading warning box). |
| `Hhermes-install-patched.ps1` | Sibling PowerShell helper: downloads upstream `install.ps1`, patches one line, then iex's it. |
| `Hermes--run.cmd` | Launch against the Nous API. |
| `Hermes--openrouter.cmd` | Route through OpenRouter via Hermes's native `--provider openrouter` flag. |
| `Hermes--uninstall.cmd` | Calls Hermes's own `hermes uninstall` subcommand, then prunes the User PATH entry from the registry. |
| `Hermes--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |
| `Hermes--local-lmstudio.cmd` | Stub. |
| `Hermes--remote-lmstudio.cmd` | Placeholder. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.hermes`
- `%LOCALAPPDATA%\hermes` (the install dir IS removed by the uninstaller, but the surrounding parent may retain other state)

## Maintenance notes

**The binary lives at `%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts\hermes.exe`**, not in a `\bin` subdir — every Hermes script in this repo prepends that exact path.

The installer adds that dir to the User PATH; if `where hermes` returns nothing after install, open a new terminal (the PATH change doesn't reach already-open shells).

The uninstaller calls Hermes's own `hermes uninstall` subcommand and then prunes that PATH entry from the User registry — Hermes's own uninstaller does not always clean it on Windows.

## Plugins

Both `Hermes--install.cmd` and `Hermes--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Hermes {install,uninstall}` so any plugin whose manifest lists Hermes in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

No plugin in the repo currently ships a hook for Hermes.
