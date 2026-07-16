# Herdr

"One terminal for the whole herd." A terminal **multiplexer built for AI coding agents** — a single ~10&nbsp;MB Rust binary (`herdr`) that runs many agents in parallel panes and surfaces each one's execution state. Think *tmux rebuilt for the agent age*.

> Part of [AgentTerminals](../AgentTerminals.wiki.md). See the AgentTerminals wiki for the shared install / uninstall / update conventions this folder follows.

## At a glance

| | |
|---|---|
| **Vendor** | herdr.dev (open source, AGPL-3.0) |
| **What it is** | Agent-aware terminal multiplexer / orchestrator (not a coding agent itself) |
| **Install channel** | Official PowerShell installer `https://herdr.dev/install.ps1` → `%LOCALAPPDATA%\Programs\Herdr\bin\herdr.exe` |
| **Windows status** | **Beta — preview channel only** (`herdr channel set stable` is rejected on Windows) |
| **Runtime deps** | none — single Rust binary (no Node / Python / Git / winget) |
| **Architectures** | Windows x86_64; ARM64 runs the x64 build under emulation |
| **Update path** | `herdr update` (self-updater) — see `Herdr--update.cmd` |
| **Version check** | `herdr --version` |
| **Config / state** | `%USERPROFILE%\.herdr` (workspaces, settings, keymap, release cache) |

## What makes it different from tmux / zellij

- **Agent state awareness** — each agent is auto-classified in a sidebar: 🔴 blocked · 🟡 working · 🔵 done · 🟢 idle. Zero config; detection is process-name matching plus terminal-output heuristics, so you can see at a glance who needs input.
- **Real PTYs** — agents run in actual terminal panes where they already run; herdr adds a thin observability/orchestration layer rather than wrapping them in an app.
- **Session persistence** — a background server keeps every pane and agent process alive across detach, terminal close, laptop sleep, or network drop. Re-attach (including over **SSH**, phone-friendly UI) and everything is where you left it.
- **Socket API** — a local Unix/named-socket JSON-RPC endpoint lets any program *or agent* create panes, spawn sub-agents, read another agent's output, and subscribe to state-change events. This is what turns herdr from a viewer into an **orchestrator**.

## Supported agents

Claude Code, Codex, Gemini CLI, GitHub Copilot CLI, Cursor Agent, OpenCode, Amp, Droid, Cline, Pi — **any terminal agent works out of the box**; first-class integrations get richer state tracking. Everything in the sibling [CodingAgents](../../AgenticCliOptions/CodingAgents) catalogue can be run inside a herdr pane.

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Herdr--install.cmd` | Runs the official `install.ps1` (preview channel), refreshes PATH so `herdr --version` works immediately. |
| `Herdr--run.cmd` | Launches / re-attaches `herdr`. Prefix key is `Ctrl+B` (tmux-compatible); also mouse-first. |
| `Herdr--update.cmd` | `herdr update`, with a fallback to re-running the installer. |
| `Herdr--uninstall.cmd` | Stops the server, deletes `%LOCALAPPDATA%\Programs\Herdr\` + the release cache, prunes the User PATH entry. |
| `Herdr--is-installed.cmd` | Probes both `where herdr` and the known binary path. |

## Maintenance notes

**The installer is not the updater.** Re-running `install.ps1` is safe (it keeps the last 3 releases and skips a re-download if the version is already present), but the supported upgrade is `herdr update`. If an update changes the client/server protocol, herdr asks whether to stop the old server — doing so tears down agents in existing panes, so detach or finish critical work first.

**Windows is beta.** Only the preview channel serves Windows builds today. Track [herdr.dev/docs](https://herdr.dev/docs/) for when a stable Windows channel lands, then this folder can drop the preview-only caveat.

**No model / OpenRouter / LM Studio launchers here.** herdr is a multiplexer, not a model client — it has no model of its own. Configure models on the *agents* you run inside it (see the [CodingAgents](../../AgenticCliOptions/CodingAgents) launchers).
