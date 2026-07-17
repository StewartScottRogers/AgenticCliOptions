# WezTerm

A **GPU-accelerated terminal emulator *and* multiplexer**, written in Rust. Where Herdr and Zellij sit *inside* an existing terminal, WezTerm *is* the terminal — a fast, cross-platform window with tabs, split panes, and its own built-in multiplexer (no tmux required). A background "mux server" keeps panes and their processes alive so you can detach and re-attach, and `wezterm cli` lets you spawn and script panes programmatically. That combination makes it a comfortable home for several AI coding agents running in parallel split panes.

> Part of [AgentTerminals](../AgentTerminals.wiki.md). See the AgentTerminals wiki for the shared install / uninstall / update conventions this folder follows.

## At a glance

| | |
|---|---|
| **Vendor** | Wez Furlong / wezterm.org (open source, MIT) |
| **What it is** | GPU terminal emulator with a built-in multiplexer (hosts agents; not agent-aware) |
| **Install channel** | winget package `wez.wezterm` → `%ProgramFiles%\WezTerm\wezterm.exe` |
| **Windows status** | **Native, first-class** (Windows is a primary target) |
| **Runtime deps** | none beyond winget for install; self-contained binary set |
| **Architectures** | Windows x86_64 (ARM64 under emulation) |
| **Update path** | `winget upgrade -e --id wez.wezterm` — see `WezTerm--update.cmd` |
| **Version check** | `wezterm -V` |
| **Config / state** | `%USERPROFILE%\.wezterm.lua` or `%USERPROFILE%\.config\wezterm\wezterm.lua` (Lua) |

## What makes it different from Herdr / Zellij

- **It's the terminal, not a layer on top.** No host terminal needed — WezTerm draws its own GPU-accelerated window. If you want your *default* terminal to also be your multiplexer, this is the one.
- **Built-in multiplexer.** Split panes, tabs, and a detach/attach mux server are native — no tmux/zellij underneath.
- **Scriptable panes.** `wezterm cli spawn` / `split-pane` / `send-text` let a script (or an agent) lay out panes and drive them — a lightweight orchestration hook.
- **Lua configuration.** The entire config is a Lua program: keybindings, launch menus, per-workspace layouts, ssh domains.
- **General-purpose.** Like Zellij it has no built-in "agent state" awareness (blocked/working/done/idle) — for that use [Herdr](../Herdr/Herdr.wiki.md). WezTerm wins on being a fast, self-contained terminal you'd happily use all day.

## Default split-pane keys

| Keys | Action |
|---|---|
| `Ctrl+Shift+Alt+"` | Split pane top / bottom |
| `Ctrl+Shift+Alt+%` | Split pane left / right |
| `Ctrl+Shift+Arrow` | Move focus between panes |
| `Ctrl+Shift+T` / `Ctrl+Shift+W` | New / close tab |

Full config and key reference: https://wezterm.org/config/.

## Scripts in this folder

| Script | Purpose |
|---|---|
| `WezTerm--install.cmd` | Installs via winget (`wez.wezterm`), then refreshes this shell's PATH so `wezterm -V` works immediately. |
| `WezTerm--run.cmd` | Launches the GUI (`wezterm start`). Split panes with the keys above; run one agent per pane. |
| `WezTerm--update.cmd` | `winget upgrade -e --id wez.wezterm` (no-op when already current). |
| `WezTerm--uninstall.cmd` | Stops the GUI + mux server, removes the winget package. Lua config preserved. |
| `WezTerm--is-installed.cmd` | Probes `where wezterm`, the default install dirs, and `winget list`. |

## Maintenance notes

**winget is the source of truth.** Install/update/uninstall all go through winget, so upgrades follow the official package. If winget is missing (no "App Installer"), the scripts point you at https://wezterm.org/install/windows.html for the standalone installer.

**Stable vs nightly.** These scripts track the stable `wez.wezterm` package. WezTerm also ships fast-moving nightlies (`wez.wezterm.nightly`), but that winget package has been mispackaged in the past — stick with stable unless you need a specific nightly fix.

**No model / OpenRouter / LM Studio launchers here.** WezTerm is a terminal/multiplexer, not a model client. Configure models on the *agents* you run inside its panes (see the [CodingAgents](../../AgenticCliOptions/CodingAgents) launchers).
