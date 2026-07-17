# AgentTerminals

Turn-key installers and full life-cycle management for **agent terminals** — the multiplexers and orchestrators that *host* AI coding agents, as opposed to the agents themselves (which live in the sibling [CodingAgents](../AgenticCliOptions/CodingAgents) catalogue).

Same shape as CodingAgents: one folder per terminal, each with a small set of `.cmd` scripts that install, probe, run, update, and uninstall the tool without you having to remember any vendor-specific incantations. Everything targets Windows and is safe to re-run.

## Catalogue

| Terminal | What it is | Folder |
|---|---|---|
| [Herdr](Herdr/Herdr.wiki.md) | Agent-aware terminal multiplexer / orchestrator (Rust; tmux for the agent age) | `Herdr\` |
| [Zellij](Zellij/Zellij.wiki.md) | Rust terminal workspace / multiplexer — "a modern tmux"; native on Windows since 0.44.0 | `Zellij\` |
| [WezTerm](WezTerm/WezTerm.wiki.md) | GPU terminal emulator **with a built-in multiplexer** (Rust; first-class Windows) | `WezTerm\` |
| [Mprocs](Mprocs/Mprocs.wiki.md) | Declarative parallel-process runner — bring up a fixed line-up of agents from one YAML | `Mprocs\` |
| [Wmux](Wmux/Wmux.wiki.md) | **Agent-aware** native-Windows multiplexer (ConPTY; messaging, approval gates, worktree fan-out) | `Wmux\` |
| [Tabby](Tabby/Tabby.wiki.md) | Customizable cross-platform GPU terminal with tabs + split panes | `Tabby\` |
| [ConEmu](ConEmu/ConEmu.wiki.md) | Veteran Windows console with tabs + free-grid split panes (Cmder is built on it) | `ConEmu\` |
| [Psmux](Psmux/Psmux.wiki.md) | Native-Windows **tmux** clone in Rust — speaks tmux, reads `.tmux.conf`, no WSL | `Psmux\` |
| [WindowsTerminal](WindowsTerminal/WindowsTerminal.wiki.md) | Microsoft's native terminal — tabs + split panes (`wt`); no session persistence | `WindowsTerminal\` |

_More terminals get added here as folders alongside `Herdr\`._

The catalogue spans two shapes: **agent-aware** hosts (Herdr, Wmux) that track/coordinate agents, and **general multiplexers/terminals** (Zellij, WezTerm, Mprocs, Tabby, ConEmu, Psmux, Windows Terminal) that simply run several agents in parallel panes. All are native on Windows.

### Considered but not (yet) added

These are strong tools that don't currently fit this catalogue's **native-Windows, dependency-light** bar:

- **[Claude Squad](https://github.com/smtg-ai/claude-squad)** (`cs`) — excellent agent orchestrator (isolated git-worktree workspaces per agent), but it hard-depends on **tmux + gh**, and tmux has no native Windows build (needs WSL/MSYS2). Revisit if a native-Windows path lands.
- **[Conductor](https://conductor.build/)** (Melty Labs) — polished parallel-agent desktop app, but **macOS / Apple-Silicon only**.
- **[Vibe Kanban](https://github.com/BloopAI/vibe-kanban)** — kanban-board orchestrator over agent worktrees (`npx vibe-kanban`), but upstream has **announced it is sunsetting**, so it's not a safe long-term add.
- **[amux](https://github.com/prettysmartdev/amux)** — Docker-sandboxed agent multiplexer; native Windows support is still "on the way" (and the name is shared by several unrelated projects). Revisit once Windows is first-class.

_(The Windows-first **wmux** — `openwong2kim.wmux` — that once sat here is now shipped in `Wmux\`.)_

## Life-cycle scripts (per terminal)

Every terminal folder `NAME\` follows the same convention:

| Script | Purpose |
|---|---|
| `NAME--install.cmd` | Turn-key install of the terminal + any deps. Re-runnable. |
| `NAME--is-installed.cmd` | Probe. Exit code `0` = installed, `1` = not. Prints a status line. |
| `NAME--run.cmd` | Launch / attach the terminal. |
| `NAME--update.cmd` | Upgrade in place via the tool's native self-updater. |
| `NAME--uninstall.cmd` | Remove the binary + PATH entry. Preserves user config/state. |
| `NAME.wiki.md` | Per-terminal notes: install path, quirks, keybindings. |

## Aggregate scripts (project root)

| Script | Purpose |
|---|---|
| `Install-All.cmd` | Interactive menu, or `Install-All.cmd all` / `Install-All.cmd Herdr` / `--status`. |
| `Uninstall-All.cmd` | Uninstall every terminal (config preserved). |
| `Update-All.cmd` | Update every *installed* terminal (skips ones not present). |

The aggregate scripts set `AGENTS_INSTALL_ALL` / `AGENTS_UNINSTALL_ALL` / `AGENTS_UPDATE_ALL` so the per-terminal scripts run unattended (they skip their own final `pause`). These are the same env-var conventions the CodingAgents scripts use.

## Adding a new terminal

1. Create a folder `NAME\` with the five `NAME--*.cmd` scripts + `NAME.wiki.md` (copy Herdr's as a template).
2. Add `NAME` to the `ALL_TERMINALS=` line in `Install-All.cmd`, `Uninstall-All.cmd`, and `Update-All.cmd`.
3. Add the new files to `AgentTerminals.projitems` so they show up in the solution.
4. Add a row to the **Catalogue** table above and link the new wiki.

## Relationship to CodingAgents

`CodingAgents` installs the agents (Claude, Codex, Gemini, Pi, …). `AgentTerminals` installs the terminals you run them *in*. A typical setup: install a terminal here, then start several CodingAgents inside its panes and watch their state side by side.
