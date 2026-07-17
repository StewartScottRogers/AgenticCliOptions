# Windows Terminal

Microsoft's **native terminal** for Windows: tabs plus split panes, GPU text rendering, and profiles for cmd, PowerShell, pwsh, WSL and any other shell. Tile several AI coding agents into panes within a tab and drive them side by side. It's the simplest, most ubiquitous option in this catalogue — already installed on most Windows 11 machines — at the cost of having **no session persistence** (close the window and every pane's process ends).

> Part of [AgentTerminals](../AgentTerminals.wiki.md). See the AgentTerminals wiki for the shared install / uninstall / update conventions this folder follows.

## At a glance

| | |
|---|---|
| **Vendor** | Microsoft (open source, MIT) |
| **What it is** | Native Windows terminal with tabs + split panes (hosts agents; not agent-aware) |
| **Install channel** | winget package `Microsoft.WindowsTerminal` (MSIX / Microsoft Store) |
| **Windows status** | **Native, first-party** (ships with Windows 11) |
| **Runtime deps** | none — part of Windows |
| **Architectures** | Windows x64 / ARM64 |
| **Update path** | Microsoft Store auto-update, or `winget upgrade -e --id Microsoft.WindowsTerminal` — see `WindowsTerminal--update.cmd` |
| **Launcher** | `wt` (the `wt.exe` WindowsApps alias) |
| **Config / state** | `settings.json` under `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\` |

## Split-pane keys

| Keys | Action |
|---|---|
| `Alt+Shift++` | Split pane to the right |
| `Alt+Shift+-` | Split pane downward |
| `Alt+Arrow` | Move focus between panes |
| `Ctrl+Shift+T` / `Ctrl+Shift+W` | New tab / close pane |

You can also open a pre-split layout in one shot, e.g.:

```
wt split-pane -H claude ; split-pane -V codex
```

## Where it fits vs the others

- **The baseline.** No install friction (usually already present), a familiar UI, and `wt` command-line layouts. Good when you just want a couple of agents tiled and don't need anything fancy.
- **No detach/persist.** Unlike Zellij, WezTerm, or psmux, closing the window kills the panes — there's no re-attach. Reach for those (or Herdr/wmux) when you need sessions to survive.
- **Not agent-aware.** No blocked/working/done/idle tracking.

## Scripts in this folder

| Script | Purpose |
|---|---|
| `WindowsTerminal--install.cmd` | Installs via winget (`Microsoft.WindowsTerminal`); a no-op/repair if already present. |
| `WindowsTerminal--run.cmd` | Opens a new window with `wt`; split panes with the keys above. |
| `WindowsTerminal--update.cmd` | `winget upgrade` (or defers to the Store, which auto-updates it). |
| `WindowsTerminal--uninstall.cmd` | Stops the window, removes the winget/Store package. Settings preserved. |
| `WindowsTerminal--is-installed.cmd` | Probes `where wt` and `winget list`. |

## Maintenance notes

**Often Store-managed.** On Windows 11 it's usually a provisioned Store app that auto-updates; winget may report nothing to upgrade, and a full uninstall can require Settings ▸ Apps. The scripts handle and explain both cases.

**Removing it changes your default console.** Windows Terminal is the default terminal host on many setups — uninstalling can revert you to the legacy conhost. The uninstaller warns before proceeding.

**No model / OpenRouter / LM Studio launchers here.** It's a terminal, not a model client. Configure models on the *agents* you run in its panes (see the [CodingAgents](../../AgenticCliOptions/CodingAgents) launchers).
