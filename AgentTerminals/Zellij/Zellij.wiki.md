# Zellij

A **terminal workspace / multiplexer** written in Rust — often described as "a modern tmux." Split the screen into panes and tabs, run many AI coding agents side by side, detach and re-attach without losing anything, and script whole layouts. Zellij is *not* agent-aware like [Herdr](../Herdr/Herdr.wiki.md) — it treats agents as ordinary processes — but it is the exact class of tool Herdr positions itself against, and it is rock-solid, batteries-included, and now runs natively on Windows.

> Part of [AgentTerminals](../AgentTerminals.wiki.md). See the AgentTerminals wiki for the shared install / uninstall / update conventions this folder follows.

## At a glance

| | |
|---|---|
| **Vendor** | zellij.dev (open source, MIT) |
| **What it is** | General terminal multiplexer / workspace (hosts agents; not agent-aware) |
| **Install channel** | Prebuilt GitHub release binary → `%LOCALAPPDATA%\Programs\Zellij\bin\zellij.exe` |
| **Windows status** | **Native** since 0.44.0 (Mar 2026) — no WSL required |
| **Runtime deps** | none — single Rust binary (no Node / Python / Git / Rust toolchain) |
| **Architectures** | Windows x86_64; ARM64 runs the x64 build under emulation |
| **Update path** | re-fetch latest release when the tag is newer — see `Zellij--update.cmd` |
| **Version check** | `zellij --version` |
| **Config / state** | `%APPDATA%\zellij` (config, layouts, keybindings, plugins) |

## Why this and not `cargo install` / winget?

- **No Rust toolchain.** These scripts pull the official prebuilt `zellij-x86_64-pc-windows-msvc.zip` from the latest GitHub release, so you don't need `cargo`.
- **winget is a community package.** `arndawg.zellij-windows` exists but has had version-numbering bugs (0.44.1 published as 0.4.11). Pulling the release asset directly tracks upstream tags cleanly.

## What makes it different from tmux / Herdr

- **Modal, discoverable keybindings.** No single prefix key — a status bar shows the current mode (pane / tab / resize / session) and its hints, so it's usable without memorising a cheatsheet.
- **Layouts as code.** KDL layout files spin up a fixed arrangement of panes/tabs running preset commands — handy for "one pane per agent" setups.
- **Plugins (WASM).** A real plugin system for status bars, file pickers, session managers, etc.
- **Floating & stacked panes**, plus session persistence and (0.44+) remote sessions over HTTPS.
- **General-purpose.** It has no notion of "agent state" — for the blocked/working/done/idle sidebar, use Herdr instead. Zellij wins on maturity, layouts, and plugins.

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Zellij--install.cmd` | Downloads the latest prebuilt Windows binary, extracts `zellij.exe`, adds its dir to the User PATH. |
| `Zellij--run.cmd` | Starts / attaches a session. Modal keys: `Ctrl+P` pane, `Ctrl+T` tab, `Ctrl+O` session (then `d` = detach). |
| `Zellij--update.cmd` | Re-fetches the latest release, but only if its tag is newer than the installed version. |
| `Zellij--uninstall.cmd` | Stops sessions, deletes the install dir, prunes the User PATH entry. Config preserved. |
| `Zellij--is-installed.cmd` | Probes both `where zellij` and the known binary path. |

## Maintenance notes

**No self-updater.** Zellij ships no `zellij update`, so `Zellij--update.cmd` re-downloads the latest release when the published tag differs from the installed one. Re-running the installer is equally safe (it just overwrites the binary).

**Full build, `web` feature included.** These scripts install the standard `zellij-x86_64-pc-windows-msvc.zip` (which carries the web/remote-session feature). If you want the leaner variant, the release also publishes a `zellij-no-web-...` asset — swap the asset name in the install/update scripts.

**No model / OpenRouter / LM Studio launchers here.** Zellij is a multiplexer, not a model client. Configure models on the *agents* you run inside its panes (see the [CodingAgents](../../AgenticCliOptions/CodingAgents) launchers).
