# AgentTerminals

Turn-key installers and full life-cycle management for **agent terminals** — the multiplexers and orchestrators that *host* AI coding agents, as opposed to the agents themselves (which live in the sibling [CodingAgents](../AgenticCliOptions/CodingAgents) catalogue).

Same shape as CodingAgents: one folder per terminal, each with a small set of `.cmd` scripts that install, probe, run, update, and uninstall the tool without you having to remember any vendor-specific incantations. Everything targets Windows and is safe to re-run.

## Catalogue

| Terminal | What it is | Folder |
|---|---|---|
| [Herdr](Herdr/Herdr.wiki.md) | Agent-aware terminal multiplexer / orchestrator (Rust; tmux for the agent age) | `Herdr\` |

_More terminals get added here as folders alongside `Herdr\`._

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
