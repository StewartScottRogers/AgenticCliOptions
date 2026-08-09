# AgentTools

Turn-key installers and full life-cycle management for **agent tools** — TUI utilities that are useful *alongside* AI coding agents without being agents themselves and without hosting them.

This is the third catalogue in the solution, and the boundary between them is deliberate:

| Catalogue | Holds | Relationship to an agent |
|---|---|---|
| [CodingAgents](../AgenticCliOptions/CodingAgents) | Claude, Codex, Gemini, Tau, … | **Is** the agent |
| [AgentTerminals](../AgentTerminals/AgentTerminals.wiki.md) | Herdr, Zellij, WezTerm, Wmux, … | **Hosts** the agent (multiplexers) |
| **AgentTools** (here) | superfile, … | **Runs beside** the agent (utilities) |

Same shape as the other two: one folder per tool, each with a small set of `.cmd` scripts that install, probe, run, update, and uninstall the tool without you having to remember any vendor-specific incantations. Everything targets Windows and is safe to re-run.

## Catalogue

| Tool | What it is | Folder |
|---|---|---|
| [Superfile](Superfile/Superfile.wiki.md) | Modern TUI file manager (Go; binary is `spf`) — stage files before an agent run, inspect the wreckage after | `Superfile\` |

_More tools get added here as folders alongside `Superfile\`._

## Admission bar

This catalogue could sprawl indefinitely — nearly every TUI is arguably "useful near an agent." A candidate is added only if it clears all four:

1. **Installs unattended on Windows** — a native package (winget/scoop) or an official install script. No WSL requirement, no manual build step.
2. **Dependency-light** — ideally a single binary. A tool that drags in a whole toolchain belongs in the agent's own installer, not here.
3. **Earns its place in an agent workflow** — it does something you actually do *because* an agent is running: reviewing what changed, staging inputs, watching resource use, navigating output.
4. **Doesn't duplicate something already in the solution** — one file manager, one git TUI, one diff viewer. Overlap is the main way a catalogue like this rots.

Anything that fails a rule is recorded below with the reason, so the same candidate isn't re-litigated later.

## Candidate shortlist

Researched and triaged, **not yet built** — every winget ID below was verified to exist. Pick from this list and each becomes a folder drop.

### Tier 1 — clears the bar cleanly

| Tool | winget ID | Why it belongs |
|---|---|---|
| **lazygit** | `JesseDuffield.lazygit` | The natural companion to an agent that commits: stage hunks, review, amend, revert an agent's work interactively. Arguably higher day-to-day value than superfile. |
| **delta** | `dandavison.delta` | Syntax-highlighting pager for `git diff` — turns "what did the agent change" from a wall of text into something readable. Configured once in `.gitconfig`, benefits every agent. |
| **glow** | `charmbracelet.glow` | Renders Markdown in the terminal. This solution is *made of* `.wiki.md` files, and agents emit Markdown constantly. |

### Tier 2 — useful, lower urgency

| Tool | winget ID | Note |
|---|---|---|
| **bat** | `sharkdp.bat` | `cat` with syntax highlighting + git gutter. Overlaps superfile's preview pane, so value depends on whether you live in the file manager. |
| **btop** | *(verify)* | Resource monitor — watch what a runaway agent is doing to the box. ID not yet confirmed on winget; check before adding. |
| **fzf** | `junegunn.fzf` | Fuzzy finder. More a shell primitive than a TUI app; earns its place mainly if you wire it into helpers. |
| **difftastic** | `Wilfred.difftastic` | Structural (AST-aware) diff — excellent for reviewing refactors, but overlaps delta; pick one as the default diff and treat the other as a specialist. |

### Tier 3 — rejected, with reasons

| Tool | Reason |
|---|---|
| **yazi** (`sxyazi.yazi`) | Excellent Rust TUI file manager — but **duplicates superfile** (rule 4). Only worth swapping *to*, never adding *alongside*. |
| **lazydocker** (`JesseDuffield.Lazydocker`) | Only earns its place if agents run in containers. Revisit if a Docker-sandboxed workflow lands in this solution. |
| **ripgrep** (`BurntSushi.ripgrep.MSVC`) / **fd** (`sharkdp.fd`) | Not TUIs — plain CLI search tools that agents invoke internally. Belongs in an agent's dependency list, not a user-facing catalogue. |
| **atuin** (`Atuinsh.Atuin`) / **zoxide** (`ajeetdsouza.zoxide`) | Shell-history and directory-jump enhancers. They modify your shell profile rather than being launched, so they don't fit the install/run/update/uninstall contract. |

## Life-cycle scripts (per tool)

Every tool folder `NAME\` follows the same convention as AgentTerminals:

| Script | Purpose |
|---|---|
| `NAME--install.cmd` | Turn-key install of the tool + any deps. Re-runnable. |
| `NAME--is-installed.cmd` | Probe. Exit code `0` = installed, `1` = not. Prints a status line. |
| `NAME--run.cmd` | Launch the tool, forwarding arguments. |
| `NAME--update.cmd` | Upgrade in place — native self-updater if the tool has one, else `winget upgrade`. |
| `NAME--uninstall.cmd` | Remove the tool. Per-tool config/state is **kept**; each script documents what it leaves behind. |
| `NAME.wiki.md` | Per-tool wiki page. |

Note there are **no** `--openrouter` / `--local-lmstudio` / `--remote-lmstudio` launchers here. Those exist in CodingAgents because agents have a model to point somewhere; tools don't.

## Catalogue-level scripts

| Script | Purpose |
|---|---|
| `Install-All.cmd` | Interactive menu, or `all` / named tools / `--status`. Registry lives in `ALL_TOOLS`. |
| `Uninstall-All.cmd` | Removes every tool; prompts once unless `AGENTS_UNINSTALL_ALL` is set. |
| `Update-All.cmd` | Updates every *installed* tool; skips the rest. |

These honour the same `AGENTS_INSTALL_ALL` / `AGENTS_UNINSTALL_ALL` / `AGENTS_UPDATE_ALL` environment flags as the other two catalogues, so child scripts suppress their own `pause` during an unattended run.

## Adding a tool

1. Create `NAME\` with the six files listed above (copy `Superfile\` as the template).
2. Add `NAME` to `ALL_TOOLS` in **all three** of `Install-All.cmd`, `Uninstall-All.cmd`, `Update-All.cmd`.
3. Add every new file to `AgentTools.projitems` — this is a shared MSBuild project, so a file not listed there is invisible in Visual Studio even though it exists on disk.
4. Add a row to the Catalogue table above, and move the entry out of the shortlist.
