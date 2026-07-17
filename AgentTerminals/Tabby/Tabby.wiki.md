# Tabby

A **highly customizable, cross-platform GPU terminal** (formerly "Terminus") with native tabs and split panes — run several AI coding agents side by side in one polished window, no tmux/zellij underneath. Rich plugin and theme ecosystem, built-in SSH/serial client, and a portable mode. Like WezTerm it is a *general* terminal (not agent-aware); think of it as the GUI-terminal companion to WezTerm, tuned for customization and a friendly settings UI.

> Part of [AgentTerminals](../AgentTerminals.wiki.md). See the AgentTerminals wiki for the shared install / uninstall / update conventions this folder follows.

## At a glance

| | |
|---|---|
| **Vendor** | Eugene Pankov / tabby.sh (open source, MIT) |
| **What it is** | Customizable GPU terminal with tabs + split panes (hosts agents; not agent-aware) |
| **Install channel** | winget package `Eugeny.Tabby` → `%LOCALAPPDATA%\Programs\Tabby\Tabby.exe` |
| **Windows status** | **Native, first-class** |
| **Runtime deps** | none beyond winget for install (self-contained app) |
| **Architectures** | Windows x86_64 (also macOS / Linux) |
| **Update path** | `winget upgrade -e --id Eugeny.Tabby` (also in-app updater) — see `Tabby--update.cmd` |
| **Config / state** | `%APPDATA%\tabby` (YAML config, plugins, themes) |

## Split-pane keys

| Keys | Action |
|---|---|
| `Ctrl+Shift+D` | Split pane downward |
| `Ctrl+Shift+R` | Split pane to the right |
| `Ctrl+Shift+Arrow` | Move focus between panes |
| `Ctrl+Shift+T` / `Ctrl+Shift+W` | New / close tab |

Everything is remappable from **Settings**; plugins and themes install from the in-app store.

## Where it fits vs WezTerm / Zellij

- **vs WezTerm** — both are native-Windows GPU terminals with a built-in pane splitter. WezTerm leans on a Lua config + a detach/attach mux server and `wezterm cli` scripting; Tabby leans on a GUI settings panel + a plugin marketplace. Pick by taste: scriptable (WezTerm) vs point-and-click customizable (Tabby).
- **vs Zellij** — Zellij runs *inside* a terminal and adds layouts/session-persistence; Tabby *is* the terminal window.
- **Not agent-aware.** For blocked/working/done/idle state tracking use [Herdr](../Herdr/Herdr.wiki.md) or [wmux](../Wmux/Wmux.wiki.md).

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Tabby--install.cmd` | Installs via winget (`Eugeny.Tabby`). |
| `Tabby--run.cmd` | Launches `Tabby.exe`; split panes with the keys above, one agent per pane. |
| `Tabby--update.cmd` | `winget upgrade -e --id Eugeny.Tabby` (no-op when already current). |
| `Tabby--uninstall.cmd` | Stops the window, removes the winget package. YAML config preserved. |
| `Tabby--is-installed.cmd` | Probes the install dir, `where tabby`, and `winget list`. |

## Maintenance notes

**winget is the source of truth.** Install / update / uninstall go through winget; Tabby also self-updates in-app.

**Portable mode.** Tabby runs portable if a `data` folder sits next to `Tabby.exe` — handy for a USB / no-install setup, but these scripts use the standard winget (per-user) install.

**No model / OpenRouter / LM Studio launchers here.** Tabby is a terminal, not a model client. Configure models on the *agents* you run inside its panes (see the [CodingAgents](../../AgenticCliOptions/CodingAgents) launchers).
