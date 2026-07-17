# ConEmu

The **veteran customizable Windows console** — one GUI window that hosts many consoles as tabs, with **free-grid split panes**. Each pane can be a different shell (cmd, PowerShell, pwsh), with its own credentials or elevation, so you can run several AI coding agents in a tiled grid and watch them together. Battle-tested for well over a decade; **Cmder** is a preconfigured distribution built on top of ConEmu.

> Part of [AgentTerminals](../AgentTerminals.wiki.md). See the AgentTerminals wiki for the shared install / uninstall / update conventions this folder follows.

## At a glance

| | |
|---|---|
| **Vendor** | Maximus5 / conemu.github.io (open source, BSD-3) |
| **What it is** | Windows console emulator with tabs + split panes (hosts agents; not agent-aware) |
| **Install channel** | winget package `Maximus5.ConEmu` → `%ProgramFiles%\ConEmu\ConEmu64.exe` |
| **Windows status** | **Native, Windows-only** (this is a Windows-specific tool) |
| **Runtime deps** | none beyond winget for install |
| **Architectures** | Windows x86_64 (ships 64- and 32-bit binaries) |
| **Update path** | `winget upgrade -e --id Maximus5.ConEmu` (also Settings ▸ Update) — see `ConEmu--update.cmd` |
| **Config / state** | `ConEmu.xml` (under `%APPDATA%\ConEmu\` or beside the exe) |

## Split-pane keys

| Keys | Action |
|---|---|
| `Ctrl+Shift+O` | Split: duplicate active shell into a pane below |
| `Ctrl+Shift+E` | Split: duplicate active shell into a pane to the right |
| `[+]` menu ▸ *Split* | New console (any shell / elevation) as a pane |
| `Ctrl+Tab` | Cycle panes / consoles |

## Where it fits vs the others

- **The Windows-native old guard.** Where WezTerm and Tabby are modern GPU terminals and Zellij is a Rust multiplexer, ConEmu is the long-standing Windows console that pioneered tabs + splits on Windows. If you already live in ConEmu/Cmder, this slots your agents into the setup you know.
- **Hosts any shell per pane** with different elevation/credentials — handy for running an agent elevated in one pane and normal in another.
- **Not agent-aware.** No blocked/working/done/idle tracking — for that use [Herdr](../Herdr/Herdr.wiki.md) or [wmux](../Wmux/Wmux.wiki.md).

## Scripts in this folder

| Script | Purpose |
|---|---|
| `ConEmu--install.cmd` | Installs via winget (`Maximus5.ConEmu`). |
| `ConEmu--run.cmd` | Launches `ConEmu64.exe`; split with the keys above, one agent per pane. |
| `ConEmu--update.cmd` | `winget upgrade -e --id Maximus5.ConEmu` (no-op when already current). |
| `ConEmu--uninstall.cmd` | Stops the window, removes the winget package. `ConEmu.xml` preserved. |
| `ConEmu--is-installed.cmd` | Probes the install dir, `where ConEmu64`, and `winget list`. |

## Maintenance notes

**winget is the source of truth.** Install / update / uninstall go through winget; ConEmu can also update itself from **Settings ▸ Update**.

**Cmder.** If you prefer Cmder (ConEmu + clink + a git-for-windows shell, preconfigured), install that instead (`winget install Cmder.Cmder`); it's the same underlying multiplexer with a curated default config. This folder targets plain ConEmu.

**No model / OpenRouter / LM Studio launchers here.** ConEmu is a console host, not a model client. Configure models on the *agents* you run in its panes (see the [CodingAgents](../../AgenticCliOptions/CodingAgents) launchers).
