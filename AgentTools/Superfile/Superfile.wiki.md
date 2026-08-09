# Superfile

"Pretty fancy and modern terminal file manager." A **TUI file manager** written in Go — a single binary (`spf`) with file panels, previews, bulk operations, a plugin-free TOML config and themable UI.

> Part of [AgentTools](../AgentTools.wiki.md). See the AgentTools wiki for the shared install / uninstall / update conventions this folder follows.

## At a glance

| | |
|---|---|
| **Vendor** | [yorukot](https://github.com/yorukot/superfile) (open source, MIT) |
| **What it is** | TUI file manager (not a coding agent, and not a multiplexer — it hosts nothing) |
| **Executable** | **`spf`** — *not* `superfile` |
| **Install channel** | winget `yorukot.superfile` → `%LOCALAPPDATA%\Microsoft\WinGet\Links\spf.exe` |
| **Runtime deps** | none — single Go binary (no Node / Python / Go toolchain) |
| **Update path** | `winget upgrade` — no built-in self-updater (see `Superfile--update.cmd`) |
| **Version check** | `spf --version` |
| **Config / state** | `%LOCALAPPDATA%\superfile` — `config.toml`, `hotkeys.toml`, `superfile.log`, `theme\` |
| **Path discovery** | `spf path-list` prints every path above |

## Why it earns a place next to the agents

An agent edits files faster than you can follow. superfile is the "what did that actually touch" pane:

- **Stage before** — browse and confirm the files you're about to point an agent at, in a pane beside it.
- **Inspect after** — previews and rich file metadata make it quick to eyeball what changed without a full diff tool.
- **Bulk fixups** — rename/move/delete the debris an agent leaves behind (stray backups, scratch dirs) without leaving the terminal.
- **Composable** — `--print-last-dir` writes the last directory to stdout on exit, and `--chooser-file` writes a chosen file's path out, so it can feed a shell function or an agent invocation instead of being a dead end.

It pairs naturally with the [AgentTerminals](../../AgentTerminals/AgentTerminals.wiki.md) catalogue: run it in one herdr/WezTerm pane with a coding agent in the next.

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Superfile--install.cmd` | `winget install -e --id yorukot.superfile`, refreshes PATH so `spf --version` works immediately. |
| `Superfile--is-installed.cmd` | Probes both `where spf` and the known winget shim path. Exit `0` = installed. |
| `Superfile--run.cmd` | Launches `spf`, forwarding any arguments (paths open as separate file panels). |
| `Superfile--update.cmd` | `winget upgrade -e --id yorukot.superfile`; tolerates "nothing to upgrade". |
| `Superfile--uninstall.cmd` | `winget uninstall`; **keeps** `%LOCALAPPDATA%\superfile` so config/themes survive a re-install. |

## Useful flags

| Flag | Purpose |
|---|---|
| `--print-last-dir`, `--pld` | Print the last directory to stdout on exit (wire into a `cd` helper). |
| `--chooser-file`, `--cf <path>` | On opening a file, write its path to `<path>` and exit — turns superfile into a file picker. |
| `--fix-config-file`, `--fch` | Append newly-added fields to an existing `config.toml`. |
| `--fix-hotkeys`, `--fh` | Append newly-added hotkeys to an existing `hotkeys.toml`. |
| `--config-file`, `-c <path>` | Use an alternate config file. |
| `spf path-list` | Print config / hotkeys / log / data directory paths. |

## Maintenance notes

**The binary is `spf`.** Every probe, launcher and PATH check in this folder keys on `spf`, not `superfile` — searching for a `superfile.exe` will always come up empty. This is the single most common trip-up with this tool.

**No self-updater.** Unlike herdr (`herdr update`), superfile ships no in-place upgrade command, so `Superfile--update.cmd` goes through `winget upgrade`. winget exits non-zero when there is simply nothing to upgrade; the script treats that as success rather than an error.

**Config survives uninstall by design.** `Superfile--uninstall.cmd` removes the package but leaves `%LOCALAPPDATA%\superfile` intact, so re-installing restores your existing hotkeys and theme. Delete that folder by hand for a genuinely clean slate.

**After a major upgrade, run the fixers.** New releases add config fields and hotkeys; existing files are *not* rewritten automatically. `spf --fix-config-file` and `spf --fix-hotkeys` append what's missing without clobbering your edits.

**No model / OpenRouter / LM Studio launchers here.** superfile is a file manager, not a model client — there is no model to configure. Model selection belongs to the *agents* (see the [CodingAgents](../../AgenticCliOptions/CodingAgents) launchers).
