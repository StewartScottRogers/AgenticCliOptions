# wmux

A **native-Windows terminal multiplexer built for AI agents** — the closest thing in this catalogue to "[Herdr](../Herdr/Herdr.wiki.md), but Windows-first." It splits several agents into panes in one window using ConPTY (Windows' native PTY — **no WSL, Cygwin or MSYS2**), then layers on agent-aware orchestration: agent-to-agent messaging, per-pane execute-approval gates, and task fan-out across git worktrees with unified diff harvesting. It also bundles MCP + Chrome DevTools browser automation.

> Part of [AgentTerminals](../AgentTerminals.wiki.md). See the AgentTerminals wiki for the shared install / uninstall / update conventions this folder follows.

## At a glance

| | |
|---|---|
| **Vendor** | openwong2kim / wmux (open source, MIT) |
| **What it is** | Native-Windows, **agent-aware** multiplexer + orchestrator |
| **Install channel** | winget package `openwong2kim.wmux` (also choco / Setup.exe) |
| **Windows status** | **Native, Windows-first** (Windows 10/11, ConPTY; no WSL) |
| **Runtime deps** | none required at run time (ships as a packaged app; TypeScript/Rust) |
| **Architectures** | Windows x86_64 |
| **Update path** | `winget upgrade -e --id openwong2kim.wmux` (also an in-app AutoUpdater) — see `Wmux--update.cmd` |
| **Supported agents** | Claude Code, Codex, Gemini CLI, Aider, OpenCode, Copilot CLI (auto-detected) |
| **Config / state** | typically `%APPDATA%\wmux` (preserved on uninstall) |

## Where it fits vs Herdr / Zellij / WezTerm

- **vs Herdr** — same idea (agent-aware orchestration), but Herdr is cross-platform/Rust with a preview-only Windows build, while wmux is **Windows-first** and adds a role-based side dock, approval gates, and built-in browser automation. If you want agent orchestration and you're primarily on Windows, wmux is the natural pick.
- **vs Zellij / WezTerm** — those are general multiplexers with no notion of "agent"; wmux understands agents (detection, messaging, worktree fan-out).

## Why winget (not Setup.exe)?

The raw `Setup.exe` trips Windows SmartScreen; installing via **winget** (or choco) avoids that prompt and gives clean update/uninstall. `Wmux--install.cmd` uses winget for exactly this reason.

⚠️ **Newer and less proven** than Zellij/WezTerm, and **the name "wmux" is shared** by more than one project (this folder targets `openwong2kim.wmux`; there is a separate `amirlehmam/wmux` billed as a "port of cmux"). If you switch sources, update the winget id in every script here.

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Wmux--install.cmd` | Installs via winget (`openwong2kim.wmux`), then refreshes this shell's PATH. |
| `Wmux--run.cmd` | Launches wmux in its own window (falls back to the per-user / Program Files exe). |
| `Wmux--update.cmd` | `winget upgrade -e --id openwong2kim.wmux` (no-op when already current). |
| `Wmux--uninstall.cmd` | Stops any wmux window, removes the winget package. Config preserved. |
| `Wmux--is-installed.cmd` | Probes `where wmux`, the common install dirs, and `winget list`. |

## Maintenance notes

**winget is the source of truth.** Install / update / uninstall all go through winget. wmux also self-updates in-app, so a running copy may already be newer than what winget last placed.

**Config path is best-effort.** wmux stores state under your profile (commonly `%APPDATA%\wmux`); the uninstaller leaves it untouched. Delete it by hand for a fully clean slate.

**No model / OpenRouter / LM Studio launchers here.** wmux hosts and coordinates agents; it is not a model client. Configure models on the *agents* you run in its panes (see the [CodingAgents](../../AgenticCliOptions/CodingAgents) launchers).
