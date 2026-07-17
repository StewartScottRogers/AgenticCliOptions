# psmux

**tmux for Windows, natively.** psmux is a from-scratch Rust reimplementation of tmux that drives Windows ConPTY directly, speaks the tmux command language, reads your `.tmux.conf`, and supports tmux themes — so you get real tmux-style pane splitting to parallelize AI coding agents **without WSL, Cygwin or MSYS2**. It's the lightest, most keyboard-centric multiplexer in this catalogue: no GUI, just panes.

> Part of [AgentTerminals](../AgentTerminals.wiki.md). See the AgentTerminals wiki for the shared install / uninstall / update conventions this folder follows.

## At a glance

| | |
|---|---|
| **Vendor** | psmux (open source, Rust) |
| **What it is** | Native-Windows tmux clone / multiplexer (hosts agents; not agent-aware) |
| **Install channel** | Prebuilt GitHub release binary → `%LOCALAPPDATA%\Programs\psmux\bin\psmux.exe` |
| **Windows status** | **Native, Windows-first** (ConPTY; no WSL) |
| **Runtime deps** | none — single Rust binary (no Node / Python / Git / Rust toolchain) |
| **Architectures** | Windows x64 (x86 and arm64 builds also published upstream) |
| **Update path** | re-fetch latest release when the tag is newer — see `Psmux--update.cmd` |
| **Version check** | `psmux --version` |
| **Config / state** | `%USERPROFILE%\.tmux.conf` (reused, never owned/modified) |

## tmux compatibility

The release zip ships three binaries, all installed into the bin dir:

- **`psmux.exe`** — the multiplexer.
- **`pmux.exe`** — short alias.
- **`tmux.exe`** — a compatibility alias so `tmux ...` commands / scripts "just work" natively.

⚠️ That bundled `tmux.exe` will **shadow any other `tmux`** reachable from this dir on your PATH — intended, but worth knowing if you also run tmux under MSYS2/Git-Bash.

Default keys are the tmux defaults (prefix `Ctrl+B`, then `%` / `"` to split, arrows to move, `d` to detach), overridable via `.tmux.conf`.

## Where it fits vs the others

- **The minimalist.** Zellij is a batteries-included Rust multiplexer with layouts/plugins; psmux is a lean, faithful **tmux** you can drop straight into existing tmux muscle-memory and configs on Windows.
- **CLI-only.** Unlike WezTerm/Tabby/ConEmu (GUI terminals), psmux runs inside whatever terminal you already use.
- **Not agent-aware.** No blocked/working/done/idle tracking — for that use [Herdr](../Herdr/Herdr.wiki.md) or [wmux](../Wmux/Wmux.wiki.md).

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Psmux--install.cmd` | Downloads the latest prebuilt `*-windows-x64.zip`, extracts `psmux/pmux/tmux.exe`, adds the dir to the User PATH. |
| `Psmux--run.cmd` | Starts / attaches a session (`psmux`); reads your `.tmux.conf`. |
| `Psmux--update.cmd` | Re-fetches the latest release, but only if its tag is newer than the installed version. |
| `Psmux--uninstall.cmd` | Stops sessions, deletes the install dir (incl. the `tmux.exe` alias), prunes the User PATH entry. |
| `Psmux--is-installed.cmd` | Probes both `where psmux` and the known binary path. |

## Maintenance notes

**No self-updater.** `Psmux--update.cmd` re-downloads the latest release when the published tag differs from the installed one. Re-running the installer is equally safe.

**Alternate installs.** Upstream also offers `cargo install psmux`, a Scoop bucket, `winget install marlocarlo.psmux`, and a PowerShell one-liner. These scripts use the prebuilt release zip for a toolchain-free, user-level install with a clean uninstall.

**No model / OpenRouter / LM Studio launchers here.** psmux just splits panes. Configure models on the *agents* you run inside them (see the [CodingAgents](../../AgenticCliOptions/CodingAgents) launchers).
