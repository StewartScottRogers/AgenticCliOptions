# mprocs

A tiny, focused **process multiplexer**: list the commands you want in an `mprocs.yaml`, run `mprocs`, and every command comes up at once in its own pane with keyboard-driven switching. Unlike tmux/Zellij (built for long-lived interactive sessions) or Herdr (agent-aware orchestration), mprocs is deliberately small — it's the fastest way to declare *"bring up these N agents together"* and interact with any of them. Written in Rust, single binary, native on Windows.

> Part of [AgentTerminals](../AgentTerminals.wiki.md). See the AgentTerminals wiki for the shared install / uninstall / update conventions this folder follows.

## At a glance

| | |
|---|---|
| **Vendor** | pvolok / mprocs (open source, MIT) |
| **What it is** | Declarative parallel-process runner with per-process panes (hosts agents; not agent-aware) |
| **Install channel** | Prebuilt GitHub release binary → `%LOCALAPPDATA%\Programs\mprocs\bin\mprocs.exe` |
| **Windows status** | **Native** — a published `windows-x86_64` build |
| **Runtime deps** | none — single Rust binary (no Node / Python / Git / Rust toolchain) |
| **Architectures** | Windows x86_64 |
| **Update path** | re-fetch latest release when the tag is newer — see `Mprocs--update.cmd` |
| **Version check** | `mprocs --version` |
| **Config / state** | `%APPDATA%\mprocs\mprocs.yaml` (global) + per-project `mprocs.yaml` |

## Where it fits vs the others

- **Herdr** — agent-aware orchestrator (blocked/working/done/idle sidebar, socket API). Richest for watching agents.
- **Zellij / WezTerm** — full interactive multiplexers you drive by hand, pane by pane.
- **mprocs** — you *declare* the set of processes once (in YAML) and it launches them together, every time, reproducibly. Best when you have a fixed line-up of agents/dev-servers you always start as a batch.

## Example: three agents at once

`mprocs.yaml` in a project:

```yaml
procs:
  claude:
    shell: "claude"
  codex:
    shell: "codex"
  gemini:
    shell: "gemini"
```

Then just `mprocs` (or `Mprocs--run.cmd`) in that folder. Or ad-hoc, no file:

```
mprocs "claude" "codex" "gemini"
```

## Default keys

| Keys | Action |
|---|---|
| `Ctrl+A` | Enter focus/command mode |
| `j` / `k` | Select next / previous process |
| `x` / `r` | Stop / restart the selected process |
| `q` | Quit (prompts to stop running procs) |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Mprocs--install.cmd` | Downloads the latest prebuilt Windows binary, extracts `mprocs.exe`, adds its dir to the User PATH. |
| `Mprocs--run.cmd` | Runs `mprocs` (reads `mprocs.yaml` in the cwd, or pass commands directly). |
| `Mprocs--update.cmd` | Re-fetches the latest release, but only if its tag is newer than the installed version. |
| `Mprocs--uninstall.cmd` | Stops any instance, deletes the install dir, prunes the User PATH entry. Config preserved. |
| `Mprocs--is-installed.cmd` | Probes both `where mprocs` and the known binary path. |

## Maintenance notes

**No self-updater.** mprocs ships no update subcommand, so `Mprocs--update.cmd` re-downloads the latest release when the published tag differs from the installed one. The install script matches the `*windows-x86_64.zip` asset by pattern, so it keeps working even if the version number in the filename changes.

**Long-lived vs one-shot.** mprocs is aimed at commands you run repeatedly as a group; it is not a general session manager. For hand-driven splitting, detach/attach, and layouts, reach for Zellij or WezTerm; for agent-state awareness, reach for Herdr.

**No model / OpenRouter / LM Studio launchers here.** mprocs just launches processes. Configure models on the *agents* it starts (see the [CodingAgents](../../AgenticCliOptions/CodingAgents) launchers).
