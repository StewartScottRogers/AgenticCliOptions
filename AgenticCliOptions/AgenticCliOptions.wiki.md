# AgenticCliOptions

A turn-key Windows toolkit that installs, configures, runs and removes **nineteen
terminal-based coding-agent CLIs** side by side, plus an optional local
**LM Studio** OpenAI-compatible server. Everything is driven by plain
`.cmd` scripts so the workflow is "double-click, walk away".

The solution is delivered as a Visual Studio *shared project*
(`AgenticCliOptions.shproj` / `.slnx`) — the project itself contains no
buildable code; it is just a host for the `.cmd` scripts so they show up
inside Visual Studio / Rider's Solution Explorer.

---

## Table of contents

- [Purpose](#purpose)
- [The nineteen agents at a glance](#the-nineteen-agents-at-a-glance)
- [Solution layout](#solution-layout)
- [Top-level scripts](#top-level-scripts)
- [Per-agent script conventions](#per-agent-script-conventions)
- [Shared dependencies](#shared-dependencies)
- [Per-agent config directories](#per-agent-config-directories)
- [Plugin layer](#plugin-layer)
  - [How plugins integrate](#how-plugins-integrate)
  - [Plugin manifest](#plugin-manifest)
  - [Reference plugin: context7-mcp](#reference-plugin-context7-mcp)
  - [Adding a new plugin](#adding-a-new-plugin)
- [Ongoing maintenance](#ongoing-maintenance)
  - [Routine: keep every agent current](#routine-keep-every-agent-current)
  - [Per-agent maintenance notes](#per-agent-maintenance-notes)
  - [Adding a brand-new coding agent](#adding-a-brand-new-coding-agent)
  - [Adding an OpenRouter or LM Studio launcher to an existing agent](#adding-an-openrouter-or-lm-studio-launcher-to-an-existing-agent)
  - [Updating shared dependencies](#updating-shared-dependencies)
  - [Rotating API keys](#rotating-api-keys)
  - [Clean uninstall vs. clean slate](#clean-uninstall-vs-clean-slate)
- [Troubleshooting](#troubleshooting)

---

## Purpose

### The core problem

Every AI coding-agent CLI worth using ships with its own setup quirks, its
own model-selection knobs, and (often) its own opinion about which backend
you can point it at. Picking one is easy; running ten of them on the same
machine, switching their backends per-session, and keeping their extensions
in sync is a logistics problem. This repo is the **logistics layer**: a
uniform turn-key shell around 17 disparate agents so the per-agent friction
disappears.

### What it manages

- **The agents themselves** — 17 CLIs behind a uniform 4-script contract
  per agent:
  - `*--install.cmd` / `*--uninstall.cmd` — idempotent lifecycle, dependency-aware
    (winget for Node / uv / Git, WSL for AmazonQ, etc.)
  - `*--is-installed.cmd` — exit-code probe used by the fleet menu and the
    plugin dispatcher
  - `*--run.cmd` — native invocation
- **Four backends per agent**, addressed by parallel launchers:
  - `*--run.cmd` — the agent's native provider (Anthropic, OpenAI, Google, etc.)
  - `*--openrouter.cmd` — OpenRouter's unified gateway
  - `*--local-lmstudio.cmd` — an OpenAI-compatible LM Studio server on `localhost`
  - `*--remote-lmstudio.cmd` — same protocol pointed at a LAN host (auto-discovered
    by `_resolve-lmstudio-url.ps1`)

  The chosen model per agent is overridable via env var (`CLAUDE_MODEL`,
  `QWEN_MODEL`, `OPENROUTER_MODEL`, …).
- **Fleet orchestration** — `Install-All.cmd` / `Update-All.cmd` /
  `Uninstall-All.cmd` give a single interactive picker over the catalogue,
  install shared deps once, respect ordering constraints (AmazonQ runs last
  because it can demand a reboot), and report a status table. `Update-All`
  re-runs each *installed* agent's installer — every installer doubles as its
  own updater (see *Idempotent everything* below).
- **Plugins / extensions** — manifest-driven plugins under
  `CodingAgents/Plugins/` with `scope: shared` (fanned out to every supporting
  agent) or `scope: per-agent` (locked to one). Every agent's install /
  uninstall calls the plugin dispatcher, so plugins arrive and depart with
  their host. See the [Plugin layer](#plugin-layer) section.

### Design principles the code follows

- **Idempotent everything.** Re-running an installer updates; re-running an
  uninstaller is a no-op when there's nothing to remove. Marker files and
  CLI-level idempotency guards (`claude mcp add`, sentinel-fenced TOML,
  JSON object replacement) carry this into the plugin layer.
- **Config is sacred.** Uninstallers remove the CLI but never
  `%USERPROFILE%\.<agent>` — so a reinstall restores API keys, sessions
  and preferences intact. The plugin layer mirrors this: hooks edit
  settings files surgically, never overwrite.
- **Comments explain WHY, not what.** Every script's header documents the
  rationale and the gotchas (CLAUDECODE locks, WSL reboots, BOM-less
  Unicode in Oh-My-Pi's installer, Antigravity's PATH pruning).
- **Fleet orchestrators are thin; per-agent scripts own the mess.**
  `Install-All.cmd` is a menu + dependency bootstrapper + dispatcher; the
  agent-specific batch sits inside each agent's folder. The plugin layer
  follows the same shape — orchestrators in `Plugins/`, knowledge about
  each agent's MCP plumbing inside the plugin's per-agent hook.
- **Graceful degradation.** Missing deps warn rather than hard-fail;
  "not installed" is treated as success in uninstallers; the plugin
  dispatcher always returns 0 so a broken plugin can't break the host
  install.
- **Sentinel envs to make scripts composable.** `AGENTS_INSTALL_ALL` /
  `AGENTS_UNINSTALL_ALL` suppress per-script pauses during fleet runs.
  The plugin orchestrators honor the same convention.

### One-sentence summary

A **uniform install / run / teardown harness** that turns an unruly zoo of
AI coding CLIs into a single matrix of
`{agent} × {native | OpenRouter | local-LMStudio | remote-LMStudio} × {plugins it supports}`,
with the agent-specific ugliness contained behind a consistent 4-script-per-agent
contract.

---

## The nineteen agents at a glance

| Agent          | Vendor       | Install channel                | Native creds                              | OpenRouter launcher | LM Studio launcher |
|----------------|--------------|--------------------------------|-------------------------------------------|---------------------|--------------------|
| **Claude**     | Anthropic    | npm `@anthropic-ai/claude-code` | Anthropic / Claude Code subscription      | yes                 | yes (settings file) |
| **Codex**      | OpenAI       | npm `@openai/codex`            | OpenAI / ChatGPT account                  | yes                 | yes (`-c` overrides) |
| **Gemini**     | Google       | npm `@google/gemini-cli`       | Google account (free tier) or `GEMINI_API_KEY` | no (Google-only API) | no (Google-only API) |
| **Antigravity** | Google      | official PowerShell installer (`install.ps1`) → `%LOCALAPPDATA%\agy\bin\agy.exe` | Google account (system keyring) | no (provider-config schema not yet documented) | no (same reason) |
| **Pi**         | Earendil     | npm `@earendil-works/pi-coding-agent` | `/login` or provider API keys      | yes                 | no (uses `models.json`) |
| **Qwen**       | Alibaba      | npm `@qwen-code/qwen-code`     | OAuth or `OPENAI_*` env vars              | yes                 | yes                  |
| **Grok**       | xAI          | official bash installer + npm fallback `grok-build` | SuperGrok account or `GROK_CODE_XAI_API_KEY` | no (xAI-only API) | no (xAI-only API) |
| **Mistral**    | Mistral AI   | `uv tool install mistral-vibe` | `MISTRAL_API_KEY`                         | yes (caveat — uses `MISTRAL_BASE_URL`) | no |
| **Trae**       | ByteDance    | `uv tool install` from GitHub (Python 3.12, `[evaluation]` extra) | provider-agnostic via env vars | yes                 | yes                  |
| **Hermes**     | Nous Research | official PowerShell installer (`install.ps1`) → `%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts` | Nous Portal OAuth or `OPENROUTER_API_KEY` | yes                 | no                  |
| **Codebuff**   | Codebuff AI  | npm `codebuff` (needs Git/bash on Windows) | codebuff.com login | no (platform-managed routing) | no |
| **Oh-My-Pi**   | can1357      | PowerShell installer (`omp.sh/install.ps1 -Binary`) | `OPENROUTER_API_KEY` (and many others) | yes | no |
| **OpenSquilla** | OpenSquilla | `uv tool install` from latest GitHub release wheel | `OPENROUTER_API_KEY` (via `onboard --api-key-env`) | yes | no |
| **Aider**      | Aider community | `uv tool install aider-chat` | `OPENROUTER_API_KEY` (and many others) | yes | no |
| **Tau**        | Hugging Face | `uv tool install tau-ai` (Python 3.12+) | `/login` or provider API keys | yes (built-in `openrouter` provider) | yes (registers a provider via `tau setup`) |
| **Junie**      | JetBrains    | official PowerShell installer (`install.ps1`) → `~/.local/bin\junie.bat` | Junie subscription or `--openrouter-api-key` BYOK | yes | no |
| **VT Code**    | vinhnx       | official PowerShell installer (`install.ps1`) → `~/.local/bin\vtcode.exe` | `OPENROUTER_API_KEY` (and many others) | yes (Windows builds **best-effort**) | no |
| **opencode**   | SST          | npm `opencode-ai` | Per-provider via `opencode auth login <provider>` (writes to `~/.config/opencode/auth.json`) | yes (first-class built-in provider) | yes (per-run `OPENCODE_CONFIG` JSON declaring a custom provider — no `--base-url` CLI flag) |
| **AmazonQ / Kiro** | Amazon   | WSL + official Linux `install.sh` | AWS Builder ID / IAM Identity Center | no (AWS Nova only) | no (AWS Nova only) |

> Agents that don't have an OpenRouter / LM Studio launcher are tied to
> their vendor's own API (Gemini, Grok, Amazon Q). To route those
> *models* through OpenRouter, drive them via an OpenAI-compatible
> agent — e.g. Qwen Code or Trae.

---

## Solution layout

```
<repo-root>/
├── AgenticCliOptions.slnx          # solution file (shared project only)
├── OpenRouter.url                  # shortcut to https://openrouter.ai
├── RunClaude.cmd                   # shortcut launcher at the repo root
│
└── AgenticCliOptions/              # .NET shared project ("project root")
    ├── AgenticCliOptions.shproj    # MSBuild shared project
    ├── AgenticCliOptions.projitems # files included in the shared project
    ├── AgenticCliOptions.wiki.md   # this document
    ├── SetOpenRouterKey.cmd        # one-shot prompt + verify + persist
    │
    └── CodingAgents/               # everything per-agent + shared launchers
        ├── Install-All.cmd                 # turn-key install for every agent
        ├── Update-All.cmd                  # upgrade every installed agent
        ├── Uninstall-All.cmd               # remove every agent CLI
        ├── Install-lmstudio.cmd            # install LM Studio + bring server up
        ├── Uninstall-lmstudio.cmd          # remove LM Studio app (config kept)
        ├── _resolve-lmstudio-url.cmd       # shared LMSTUDIO_URL probe (CALL only)
        ├── _resolve-lmstudio-url.ps1       # PowerShell sidecar for the probe
        │
        ├── Plugins/                        # cross-agent plugin layer
        │   ├── Install-Plugin.cmd          # picker that fans one plugin out
        │   ├── Uninstall-Plugin.cmd        # symmetric removal
        │   ├── _apply-plugins.{cmd,ps1}    # dispatcher called from each agent
        │   ├── _install-plugin.ps1         # picker -> per-agent hook runner
        │   └── context7-mcp/  plugin.json + install/<agent>.cmd + uninstall/<agent>.cmd
        │
        ├── AmazonQ/      AmazonQ--{install,run,uninstall}.cmd
        ├── Claude/       Claude--{install,run,uninstall,openrouter,local-lmstudio,remote-lmstudio}.cmd
        │                 LMStudio.Claude.Settings.template.json
        ├── Codex/        Codex--{install,run,uninstall,openrouter,local-lmstudio,remote-lmstudio}.cmd
        ├── Gemini/       Gemini--{install,run,uninstall}.cmd
        ├── Antigravity/  Antigravity--{install,run,uninstall,openrouter,local-lmstudio,remote-lmstudio,is-installed}.cmd
        ├── Grok/         Grok--{install,run,uninstall}.cmd
        ├── Mistral/      Mistral--{install,run,uninstall,openrouter}.cmd
        ├── Pi/           Pi--{install,run,uninstall,openrouter}.cmd
        ├── Qwen/         Qwen--{install,uninstall,openrouter,local-lmstudio,remote-lmstudio}.cmd
        ├── Trae/         Trae--{install,uninstall,openrouter,local-lmstudio,remote-lmstudio}.cmd
        ├── Hermes/       Hermes--{install,uninstall,openrouter,run}.cmd
        ├── Codebuff/     Codebuff--{install,uninstall,run}.cmd
        ├── Oh-My-Pi/     Oh-My-Pi--{install,uninstall,openrouter,run}.cmd
        ├── OpenSquilla/  OpenSquilla--{install,uninstall,openrouter,run}.cmd
        ├── Aider/        Aider--{install,uninstall,openrouter,run}.cmd
        ├── Tau/          Tau--{install,uninstall,openrouter,run}.cmd
        ├── Junie/        Junie--{install,uninstall,openrouter,run}.cmd
        ├── VTCode/       VTCode--{install,uninstall,openrouter,run}.cmd
        └── Opencode/     Opencode--{install,uninstall,run,openrouter,local-lmstudio,remote-lmstudio,is-installed}.cmd
```

The script set above is illustrative — every agent folder also ships
`<Name>--is-installed.cmd` (the install probe used by `Install-All --status`),
`<Name>--local-lmstudio.cmd` + `<Name>--remote-lmstudio.cmd`
(launchers or honest stubs depending on the agent), and a
`<Name>.wiki.md` per-agent reference doc. See
[per-agent script conventions](#per-agent-script-conventions) below
for the full naming pattern and
[per-agent maintenance notes](#per-agent-maintenance-notes) for the
index of per-agent wikis.

---

## Top-level scripts

| Script                    | What it does                                                                                     |
|---------------------------|--------------------------------------------------------------------------------------------------|
| `Install-All.cmd`         | Installs shared deps once (Node LTS, uv, Git), then runs each agent's `*--install.cmd` in order. Amazon Q runs last because its WSL bootstrap may force a Windows reboot — the script is **safe to re-run** afterwards. Sets `AGENTS_INSTALL_ALL=1` so child scripts skip their final `pause`. The menu also exposes `M)` to update everything installed (delegates to `Update-All.cmd`). |
| `Update-All.cmd`          | Re-runs each **installed** agent's `*--install.cmd` (which doubles as its updater — npm `@latest`, `uv tool --upgrade`, GitHub-latest, etc.) in install order; not-installed agents are skipped. Sets `AGENTS_INSTALL_ALL=1` to suppress child pauses. Two near-no-ops are expected: Antigravity self-updates in the background, and AmazonQ's WSL installer skips when the CLI is already present. |
| `Uninstall-All.cmd`       | Calls every agent's `*--uninstall.cmd` in reverse order. Leaves shared deps and per-agent config in place — see the script header for the manual steps to wipe those too. |
| `Install-lmstudio.cmd`    | Probes `LMSTUDIO_URL` (defaults to a LAN host) and `127.0.0.1:1234`; if no server answers, installs the LM Studio app via winget, locates `lms.exe`, starts the server, and re-probes. Idempotent. |
| `Uninstall-lmstudio.cmd`  | Stops the local server (`lms server stop`) and uninstalls the LM Studio app via winget. **Preserves** `%USERPROFILE%\.lmstudio` (config + the `lms` CLI) and `%APPDATA%\LMStudio` so re-installing restores everything. |
| `SetOpenRouterKey.cmd`    | Prompts for an OpenRouter key, sanity-checks the prefix, hits `https://openrouter.ai/api/v1/key` to verify, then stores it in the persistent user env var `OPENROUTER_API_KEY` via `setx`. Every `*--openrouter.cmd` reads this single variable. |
| `RunClaude.cmd`           | Convenience shortcut at the repo root — same as `CodingAgents\Claude\Claude--run.cmd`. |

---

## Per-agent script conventions

Each agent folder follows the same naming pattern, so a script's name
tells you what it does without opening it:

| Suffix                          | Purpose                                                                                  |
|---------------------------------|------------------------------------------------------------------------------------------|
| `<Agent>--install.cmd`          | Install or update the CLI. Re-runnable. Auto-installs its own deps via winget if missing. |
| `<Agent>--uninstall.cmd`        | Remove the CLI only. Never touches shared deps or `%USERPROFILE%\.<agent>` config dir.    |
| `<Agent>--run.cmd`              | Launch the CLI against its native vendor API (and native auth).                           |
| `<Agent>--openrouter.cmd`       | Launch via OpenRouter, using `OPENROUTER_API_KEY` and an overridable `OPENROUTER_MODEL`.  |
| `<Agent>--local-lmstudio.cmd`   | Launch against a local LM Studio server (auto-detects the loaded model from `${LMSTUDIO_URL}/v1/models`). |
| `<Agent>--remote-lmstudio.cmd`  | Placeholder for a future remote-LM-Studio launcher. Today, set `LMSTUDIO_URL` to the remote host and call the local launcher. |
| `<Agent>--is-installed.cmd`     | Probe used by `Install-All.cmd --status` (and the interactive menu) to render the install-status table. Exits 0 if installed, 1 otherwise. The status table also runs each installed CLI's `--version` and extracts the bare version number for a **Version** column (`?` = installed but no parseable version, e.g. Gemini when its `settings.json` is malformed; `-` = not installed). |
| `<Agent>.wiki.md`               | Per-agent reference doc: at-a-glance table, scripts in the folder, config dirs, and historical quirks. |

Conventions baked into every script:

- **Idempotent install**. `where <bin>` short-circuits if the dep is
  already present; `winget install --silent --accept-*-agreements`
  otherwise. After winget the script calls `:refresh_path` to make the
  newly installed bin usable in the *current* shell — no "open a new
  terminal" detour.
- **Idempotent uninstall**. Each one tolerates the "not installed"
  case as success rather than failure, so re-running them is safe.
- **No interactive prompts when called from the parent**. Install-All
  / Update-All / Uninstall-All set `AGENTS_INSTALL_ALL=1` /
  `AGENTS_UNINSTALL_ALL=1`, and every child script skips its final `pause`
  when that variable is defined. (Update-All reuses `AGENTS_INSTALL_ALL`
  since it calls the install scripts; the menu sets `AGENTS_UPDATE_ALL=1`
  so Update-All itself skips its standalone end-pause.)
- **Config dirs are sacred**. Uninstall scripts deliberately leave
  `%USERPROFILE%\.<agent>` alone so reinstall restores sessions and
  API keys exactly as they were.
- **OpenRouter launchers** all read the single `OPENROUTER_API_KEY` env
  var and accept an `OPENROUTER_MODEL` override.
- **LM Studio launchers** all default to `LMSTUDIO_URL=http://192.168.12.174:1234`
  (override via env var). They auto-detect the currently loaded model id
  with a one-liner `Invoke-RestMethod /v1/models` and pin the CLI to it.

---

## Shared dependencies

| Dependency              | Used by                                                                                          | Installed by                           |
|-------------------------|--------------------------------------------------------------------------------------------------|----------------------------------------|
| Node.js LTS (>= 22)     | Claude, Codex, Gemini, Pi, Qwen, Codebuff (and Grok npm fallback)                                | `winget install OpenJS.NodeJS.LTS`     |
| uv (Astral)             | Mistral, Trae, Hermes (used internally by its installer), OpenSquilla, Aider, Tau                | `winget install astral-sh.uv`          |
| Git for Windows         | Grok, Codebuff, Oh-My-Pi, Aider (provides `bash.exe` + `git.exe` at runtime)                     | `winget install Git.Git`               |
| WSL + Ubuntu            | Amazon Q (no native Windows build)                                                               | `wsl --install` + `wsl --install -d Ubuntu` |
| Python 3.11 / 3.12      | Trae (`tree-sitter-languages` pin → 3.12); Hermes installer pins 3.11; OpenSquilla pins 3.12     | uv downloads them automatically        |
| winget                  | every agent uses winget for shared deps                                                          | ships with Windows 11 (App Installer)  |
| LM Studio (optional)    | every `*--local-lmstudio.cmd` (and the placeholder `*--remote-lmstudio.cmd`)                     | `winget install ElementLabs.LMStudio`  |

> **Node 22 enforcement.** `Install-All.cmd :ensure_node_22` detects an
> older Node (e.g. legacy `OpenJS.NodeJS.20`), uninstalls it via winget,
> then installs `OpenJS.NodeJS.LTS`. Qwen requires Node 22+ — keep this
> guard in any future installer too.

---

## Per-agent config directories

Uninstall scripts never delete these. Wipe them by hand for a fully
clean slate.

| Agent     | Path                                                |
|-----------|-----------------------------------------------------|
| Claude    | `%USERPROFILE%\.claude`                             |
| Codex     | `%USERPROFILE%\.codex`                              |
| Gemini    | `%USERPROFILE%\.gemini`                             |
| Antigravity | `%USERPROFILE%\.antigravity`, `%LOCALAPPDATA%\antigravity` (the `%LOCALAPPDATA%\agy` install dir IS removed by the uninstaller) |
| Pi        | `%USERPROFILE%\.pi`                                 |
| Qwen      | `%USERPROFILE%\.qwen`                               |
| Grok      | `%USERPROFILE%\.grok` (and possibly `~/.x.ai`)      |
| Mistral   | `%USERPROFILE%\.mistral`, `%USERPROFILE%\.vibe`     |
| Trae      | `%USERPROFILE%\.trae`                               |
| Hermes    | `%USERPROFILE%\.hermes`, `%LOCALAPPDATA%\hermes`    |
| Codebuff  | `%USERPROFILE%\.codebuff`                           |
| Oh-My-Pi  | `%USERPROFILE%\.omp`, `%LOCALAPPDATA%\omp`          |
| OpenSquilla | `%USERPROFILE%\.opensquilla`                      |
| Aider     | `%USERPROFILE%\.aider.conf.yml`, `%USERPROFILE%\.aider.tags.cache.v3` |
| Tau       | `%USERPROFILE%\.tau` (sessions, `catalog.toml`, `providers.json`) |
| Junie     | `%USERPROFILE%\.local\share\junie`, `%USERPROFILE%\.junie` |
| VT Code   | `%LOCALAPPDATA%\vinhnx\vtcode\config`, `%LOCALAPPDATA%\vinhnx\vtcode\data` |
| opencode  | `%USERPROFILE%\.config\opencode` (XDG-style on Windows; contains `opencode.json`, `auth.json`, sessions) |
| Amazon Q  | `~/.local/share/amazon-q` *inside WSL*              |
| LM Studio | `%USERPROFILE%\.lmstudio`, `%APPDATA%\LMStudio`     |

---

## Plugin layer

`CodingAgents/Plugins/` is a manifest-driven extension layer that rides
alongside the per-agent folders. A plugin's job is to install (and later
remove) something **inside** an agent — most commonly an MCP server
registration, but the layer is generic enough for slash commands, rule
files, config snippets, or anything else with a per-agent install
procedure.

```
CodingAgents/Plugins/
├── _apply-plugins.cmd          # per-agent dispatcher (called by every <Agent>--install.cmd / --uninstall.cmd)
├── _apply-plugins.ps1
├── Install-Plugin.cmd          # top-level: pick one plugin -> install into every supporting agent
├── Uninstall-Plugin.cmd        # top-level: pick one plugin -> uninstall from same
├── _install-plugin.ps1         # shared fan-out engine for both orchestrators
└── <plugin-name>/
    ├── plugin.json             # manifest
    ├── install/<agent>.cmd     # per-agent install hook (lowercase agent name)
    └── uninstall/<agent>.cmd   # per-agent uninstall hook
```

### How plugins integrate

Two install/uninstall paths feed into the same dispatcher:

1. **Per-agent lifecycle.** Every `<Agent>--install.cmd` ends with
   `call "%~dp0..\Plugins\_apply-plugins.cmd" <Agent> install` on the
   success path; every `<Agent>--uninstall.cmd` calls the matching
   `uninstall` action *before* removing the CLI (so hooks that use the
   agent's own subcommands — e.g. `claude mcp remove` — still resolve).
   Plugins therefore arrive and depart with their host agent.
2. **Top-level orchestrators.** `Plugins\Install-Plugin.cmd` and
   `Plugins\Uninstall-Plugin.cmd` invert the loop: pick one plugin and
   fan its install / uninstall hook out to every supporting, currently-installed
   agent. `Install-All.cmd` exposes these via `P)` and `Y)` on the main menu.

The dispatcher (`_apply-plugins.ps1`) walks every `Plugins\*\plugin.json`,
filters by manifest `scope` + `supports` / `agent`, and runs the matching
hook for the named agent. **It always exits 0** — a missing or failing
plugin must never break the host agent's install. Per-plugin failures are
surfaced as `[warn]` lines in the output.

Idempotency is plugin-side: each hook either checks a marker file
(`%USERPROFILE%\.agentic-cli-plugins\<plugin>.<Agent>.installed` by
convention) or relies on the target CLI's own idempotency
(`claude mcp add`, JSON object replacement, sentinel-fenced TOML blocks).

### Plugin manifest

```jsonc
{
  "name": "context7-mcp",
  "kind": "mcp-server",            // mcp-server | slash-command | rule-file | config-snippet | extension-pack
  "description": "...",
  "scope": "shared",               // shared = manifest.supports list; per-agent = single manifest.agent
  "agent": null,                   // required when scope = per-agent
  "supports": ["Claude", "Codex", "Gemini", "Antigravity"],
  "version": "1.0.0",
  "marker": "%USERPROFILE%\\.agentic-cli-plugins\\context7-mcp.installed"
}
```

Field meanings:

| Field         | Meaning                                                                                 |
|---------------|-----------------------------------------------------------------------------------------|
| `name`        | Unique plugin id. Must match the folder name.                                            |
| `kind`        | Informational. Used to organise hooks; the dispatcher does not switch on it.             |
| `scope`       | `shared` — fan out to every agent in `supports`. `per-agent` — install only into `agent`.|
| `agent`       | Required when `scope: per-agent`. Ignored when `scope: shared`.                          |
| `supports`    | Required when `scope: shared`. List of agent names whose hooks ship with the plugin.     |
| `marker`      | Convention only — used by the hooks for their own idempotency checks.                    |

Hooks live at `install/<agent-lowercase>.cmd` and `uninstall/<agent-lowercase>.cmd`.
A missing hook is a quiet skip — a plugin can legitimately declare support
for an agent but not yet ship hooks for it.

### Reference plugin: context7-mcp

`Plugins/context7-mcp/` is a working reference that demonstrates a
`scope: shared` MCP server fanned out to five agents with four different
config plumbings:

| Agent        | Hook implementation                                                                                  |
|--------------|------------------------------------------------------------------------------------------------------|
| Claude       | `claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp` (first-class CLI subcommand)  |
| Gemini       | Merges `mcpServers.context7` into `~/.gemini/settings.json` via `_mcp-json-edit.ps1`                 |
| Antigravity  | Same JSON-merge approach against `~/.antigravity/settings.json` (assumed to follow Gemini's shape)   |
| Codex        | Adds a sentinel-fenced `[mcp_servers.context7]` block to `~/.codex/config.toml` via `_mcp-toml-edit.ps1` |
| opencode     | Merges `mcp.context7 = { type:"local", command:[…], enabled:true }` into `~/.config/opencode/opencode.json` via `_mcp-opencode-edit.ps1` (different shape: top-level key is `mcp` not `mcpServers`, and `command` is a single array combining bin + args) |

The three helpers `_mcp-json-edit.ps1`, `_mcp-toml-edit.ps1`, and
`_mcp-opencode-edit.ps1` are private to this plugin (they live in
`Plugins/context7-mcp/`, not in `Plugins/`) — every plugin owns the
helpers it needs.

### Adding a new plugin

1. Create `CodingAgents\Plugins\<plugin-name>\` and a `plugin.json`
   declaring `scope`, `kind`, `supports` (or `agent`).
2. Add `install\<agent>.cmd` + `uninstall\<agent>.cmd` for every agent
   in `supports`. Lowercase filenames. Each hook must be idempotent —
   check a marker file or use the target CLI's own idempotency.
3. The hook's job is whatever the target agent needs: shell out to the
   agent's CLI (`claude mcp add …`), or merge into the agent's
   settings file (use PowerShell from inside the `.cmd` — see the
   context7 hooks for the pattern), or copy payload into the agent's
   config dir.
4. Test: `Plugins\Install-Plugin.cmd <plugin-name>` will fan out to
   every supporting agent that is currently installed. The output
   reports `[install] <agent>`, `[skip] <agent>: not installed`, or
   `[warn] <agent>: hook returned exit N` per agent.
5. From then on, the plugin auto-applies whenever a supporting agent
   is installed or uninstalled — no per-agent script edits needed.
   The dispatcher discovers the new manifest automatically.

---

## Ongoing maintenance

### Routine: keep every agent current

The install scripts are also *update* scripts — they always install
`@latest` / `--upgrade`. So routine maintenance is just:

1. Run `Update-All.cmd` (or press `M)` in the `Install-All.cmd` menu) from
   time to time (monthly is plenty for most teams). It re-runs the installer
   for every *installed* agent, so each fetches its latest published release;
   agents you never installed are skipped. Re-running `Install-All.cmd`
   achieves the same upgrade but will also offer to add missing agents.
2. If you only use one agent, run just that folder's `*--install.cmd`.
3. After an LM Studio update, re-run `Install-lmstudio.cmd` so the
   `lms` CLI and the local server come back up cleanly.

There is **no version pinning** in this repo by design — keeping every
agent on `@latest` makes drift between them visible quickly.

### Per-agent maintenance notes

Each agent has its own wiki at `CodingAgents/<Name>/<Name>.wiki.md`
covering install channel, scripts in the folder, config dirs, and
historical quirks. The one-liners below are a scan-friendly index
into the most surprising or load-bearing detail per agent — follow
the link for full context. Listed in install order.

- **Claude** — npm + Anthropic's native `~/.local/bin/claude.exe` (uninstaller cleans both). → [Claude.wiki.md](CodingAgents/Claude/Claude.wiki.md)
- **Codex** — npm; OpenRouter via on-the-fly `-c model_provider=...` overrides; `wire_api=responses`. → [Codex.wiki.md](CodingAgents/Codex/Codex.wiki.md)
- **Gemini** — npm; ⚠️ **deprecated 2026-06-18** for Pro/Ultra/free Code Assist users; migrate to Antigravity. → [Gemini.wiki.md](CodingAgents/Gemini/Gemini.wiki.md)
- **Antigravity** — Google's Go-based Gemini-CLI successor (`agy`); self-updates; install dir `%LOCALAPPDATA%\agy\bin`. → [Antigravity.wiki.md](CodingAgents/Antigravity/Antigravity.wiki.md)
- **Pi** — npm; install nukes legacy `@mariozechner/pi-coding-agent` first to avoid `EEXIST`; LM Studio via `models.json`. → [Pi.wiki.md](CodingAgents/Pi/Pi.wiki.md)
- **Qwen** — npm; **requires Node 22+**; recommended for routing Gemini-family models via OpenRouter (it's a Gemini-CLI fork). → [Qwen.wiki.md](CodingAgents/Qwen/Qwen.wiki.md)
- **Grok** — beta; bash installer (Git Bash) with `grok-build` npm fallback; xAI-only. → [Grok.wiki.md](CodingAgents/Grok/Grok.wiki.md)
- **Mistral** — `uv tool install mistral-vibe`; OpenRouter via `MISTRAL_BASE_URL` (re-verify after Vibe updates). → [Mistral.wiki.md](CodingAgents/Mistral/Mistral.wiki.md)
- **Trae** — `uv tool install` from GitHub (Python 3.12); `[evaluation]` extra required even for normal use. → [Trae.wiki.md](CodingAgents/Trae/Trae.wiki.md)
- **Hermes** — Nous Research PowerShell installer; binary at `…\hermes-agent\venv\Scripts\hermes.exe` (non-obvious subdir). → [Hermes.wiki.md](CodingAgents/Hermes/Hermes.wiki.md)
- **Codebuff** — npm; needs `bash.exe` at runtime; **no OpenRouter** (platform-managed routing). → [Codebuff.wiki.md](CodingAgents/Codebuff/Codebuff.wiki.md)
- **Oh-My-Pi** — PowerShell installer in `-Binary` mode; two workarounds: nested-paren parse, UTF-8 BOM. → [Oh-My-Pi.wiki.md](CodingAgents/Oh-My-Pi/Oh-My-Pi.wiki.md)
- **OpenSquilla** — `uv tool install` from latest GitHub-Releases `.whl`; no `--version` flag (use `uv tool list`). → [OpenSquilla.wiki.md](CodingAgents/OpenSquilla/OpenSquilla.wiki.md)
- **Aider** — `uv tool install aider-chat`; OpenRouter via `--model openrouter/<provider>/<model>`. → [Aider.wiki.md](CodingAgents/Aider/Aider.wiki.md)
- **Junie** — JetBrains PowerShell installer → `~/.local/bin\junie.bat`; self-updates; OpenRouter BYOK via `--openrouter-api-key`. → [Junie.wiki.md](CodingAgents/Junie/Junie.wiki.md)
- **VT Code** — direct GitHub-Releases zip → `~/.local/bin\vtcode.exe` (skips broken upstream `install.ps1`); Windows builds best-effort. → [VTCode.wiki.md](CodingAgents/VTCode/VTCode.wiki.md)
- **opencode** — npm `opencode-ai`; provider-neutral (`--model provider/model`); LM Studio via per-run `OPENCODE_CONFIG` JSON (no `--base-url` flag); MCP key is `mcp`, not `mcpServers`. → [Opencode.wiki.md](CodingAgents/Opencode/Opencode.wiki.md)
- **Amazon Q / Kiro** — runs *inside WSL*; staged installer survives a Windows reboot; AWS Nova only. → [AmazonQ.wiki.md](CodingAgents/AmazonQ/AmazonQ.wiki.md)

### Adding a brand-new coding agent

To keep the project coherent, follow this checklist:

1. **Create `CodingAgents\<Name>\`** with at least
   `<Name>--install.cmd`, `<Name>--run.cmd`, `<Name>--uninstall.cmd`.
   Copy from the closest existing agent (npm-based ⇒ Claude/Codex;
   `uv tool` ⇒ Mistral/Trae; bash installer ⇒ Grok; WSL-only ⇒ AmazonQ).
   When copying, keep the plugin-dispatcher calls already present in
   those scripts (`call "%~dp0..\Plugins\_apply-plugins.cmd" <Name> install`
   on the install success path; matching `... uninstall` call near the
   top of the uninstall script, after any preflight that early-exits).
   See the [Plugin layer](#plugin-layer) for details.
2. **Match the header style** — every existing script starts with a
   `REM ===...===` block explaining what is installed, where deps come
   from, what is *not* removed, and how to re-run safely.
3. **Add the unattended guard.** Last line of the script should be:
   ```bat
   if not defined AGENTS_INSTALL_ALL pause
   ```
   (or `AGENTS_UNINSTALL_ALL` for uninstallers).
4. **If you need new shared deps**, also update `Install-All.cmd` so
   they install in the `[1/3]` shared-deps block and survive a
   re-run.
5. **Wire the agent into `Install-All.cmd` and `Uninstall-All.cmd`**.
   Install order is: Claude, Codex, Gemini, Antigravity, Pi, Qwen,
   Grok, Mistral, Trae, Hermes, Codebuff, Oh-My-Pi, OpenSquilla,
   Aider, Junie, VT Code, opencode, then Amazon Q **last** (reboot).
   Uninstall is the reverse.
6. **Add the agent's config dir to the "leaves alone" list** in both
   `Uninstall-All.cmd` and the agent's own uninstaller.
7. **Add a row** to the [agent matrix above](#the-seventeen-agents-at-a-glance)
   and a one-line entry in [maintenance notes](#per-agent-maintenance-notes)
   linking to the new per-agent wiki. Bump the "**N agents at a glance**"
   count in the intro paragraph, the table of contents anchor, and the
   section heading so they stay in sync — they're three separate places
   to update.
8. **Create `CodingAgents\<Name>\<Name>.wiki.md`** — the per-agent
   reference doc. Copy the structure from the closest existing wiki
   (e.g. [Codex.wiki.md](CodingAgents/Codex/Codex.wiki.md)): an
   "At a glance" table, the actual scripts in the folder with one-line
   purposes, the config dirs the uninstaller leaves alone, and
   maintenance notes. Add it to `AgenticCliOptions.projitems` so it
   shows up in the Solution Explorer.
9. **Optional: `<Name>--openrouter.cmd`** if the agent speaks an
   OpenAI- or Anthropic-compatible API. It must read the shared
   `OPENROUTER_API_KEY` env var and accept an overridable
   `OPENROUTER_MODEL` default.
10. **Optional: `<Name>--local-lmstudio.cmd`** if the agent can be
    pointed at an OpenAI-compatible base URL. Auto-detect the loaded
    model from `${LMSTUDIO_URL}/v1/models`. Ship a placeholder
    `<Name>--remote-lmstudio.cmd` for symmetry.
11. **Smoke-test the install end-to-end.** Set
    `AGENTS_INSTALL_ALL=1` so the script runs unattended, run
    `<Name>--install.cmd`, then run the binary's `--version`
    flag (or its closest equivalent — some agents like
    OpenSquilla have no `--version`; fall back to
    `uv tool list` or `where <bin>`). Common surprises to
    look out for:
    - **Binary lives in a non-obvious subdir** (Hermes →
      `\hermes-agent\venv\Scripts`). Don't trust the docs;
      run the installer once and run `where <bin>` to find
      out where it actually lands.
    - **`--version` is not a recognised flag** (OpenSquilla).
      Pivot to a version probe that does work, e.g. reading
      `uv tool list` output.
    - **Upstream `install.ps1` mis-parses on PS 5.1**
      (Oh-My-Pi). If the script contains non-ASCII chars
      (check marks, warning signs) and ships without a BOM,
      PS 5.1 reads it as Windows-1252 and corrupts the
      multi-byte UTF-8. Download via `Net.WebClient`, re-save
      with a UTF-8 BOM before invoking.

### Adding an OpenRouter or LM Studio launcher to an existing agent

Use the existing launchers as templates — they all share the same
shape:

```bat
@echo off
setlocal

REM 1. Sane defaults (override via env var)
if not defined OPENROUTER_MODEL set "OPENROUTER_MODEL=<vendor>/<model-slug>"

REM 2. Bail out helpfully if the key is missing
if not defined OPENROUTER_API_KEY goto :nokey

REM 3. Export the env vars the CLI reads, redirected to OpenRouter
set "OPENAI_API_KEY=%OPENROUTER_API_KEY%"
set "OPENAI_BASE_URL=https://openrouter.ai/api/v1"

REM 4. Run the CLI from its own folder so any local config is picked up
pushd "%~dp0"
call <agent-bin> --yolo --model "%OPENROUTER_MODEL%"
popd
```

LM Studio launchers swap the URL/key and add the model-detect step:

```bat
for /f "delims=" %%i in ('powershell -command "try { (Invoke-RestMethod '%LMSTUDIO_URL%/v1/models').data[0].id } catch { '' }"') do set "LMSTUDIO_MODEL=%%i"
```

Verify the resulting launcher with a quick smoke test (a one-line
prompt) before declaring it working.

### Updating shared dependencies

- **Node.js LTS / Git / uv** — re-running `Install-All.cmd` is enough.
  winget upgrades the package in place. The `:ensure_node_22` helper
  guarantees Qwen's minimum.
- **LM Studio** — re-run `Install-lmstudio.cmd`. It will winget-install
  the latest, then probe the server again.
- **WSL / Ubuntu** — `wsl --update` and `wsl --shutdown` as needed.
  `AmazonQ--install.cmd` doesn't drive these; they're general-purpose
  Windows components.

### Rotating API keys

- **OpenRouter** — re-run `SetOpenRouterKey.cmd`. It detects the existing
  `OPENROUTER_API_KEY`, asks for replacement, verifies the new key
  against `https://openrouter.ai/api/v1/key`, then `setx`-stores it.
  Open a new terminal for the change to take effect.
- **Per-vendor keys** (Mistral, OpenAI, Anthropic, xAI, Gemini, Qwen) —
  set with `setx`, e.g. `setx MISTRAL_API_KEY "..."`, then open a new
  terminal. The relevant `*--run.cmd` headers list the exact variable
  name for each vendor.
- **AWS (Amazon Q)** — sign out from inside the CLI (`q logout`) and
  back in with `q login`.

### Clean uninstall vs. clean slate

1. `Uninstall-All.cmd` — removes the CLIs. Reinstall later and your
   sessions / API keys come back exactly as they were.
2. **Clean slate** — after step 1, also delete the per-agent config
   dirs in [the table above](#per-agent-config-directories), and
   optionally:
   - `winget uninstall OpenJS.NodeJS.LTS`
   - `winget uninstall astral-sh.uv`
   - `winget uninstall Git.Git`
   - `wsl --unregister Ubuntu` and `wsl --uninstall`
   - `Uninstall-lmstudio.cmd` followed by removing `%USERPROFILE%\.lmstudio`
     and `%APPDATA%\LMStudio`.

---

## Troubleshooting

- **`'winget' is not recognized`** — install "App Installer" from the
  Microsoft Store (<https://aka.ms/getwinget>) and re-run.
- **A freshly installed bin isn't found** — `Install-All.cmd` calls
  `:refresh_path` so the current shell sees the new tool. If that
  still fails, close the terminal and open a new one — the registry
  PATH has the entry but your shell snapshotted the old PATH at
  launch.
- **`'claude'` still resolves after uninstall** — there's a stale
  copy somewhere. Run `where claude` to find it. The same applies to
  every other agent.
- **`Claude--uninstall.cmd` says "Access is denied" on `claude.exe`** —
  a Claude Code session is still running. Close it and re-run.
- **`'lms server start'` returns nonzero** — usually means the server
  was already running. The installer re-probes anyway; check the
  output of the probe.
- **LM Studio launcher says "Could not detect model"** — start the
  LM Studio app, load a model, and start its local server from the
  Developer tab. Check that `LMSTUDIO_URL` matches.
- **Amazon Q install loops on "please reboot"** — the previous reboot
  didn't finish provisioning Ubuntu. Open the Ubuntu app from the
  Start menu, complete its first-run username/password setup, then
  re-run `AmazonQ--install.cmd`.
- **Trae fails to import `docker_manager`** — the `[evaluation]` extra
  was not installed. Re-run `Trae--install.cmd`; the script always
  passes the right spec.
- **Mistral via OpenRouter ignores `MISTRAL_BASE_URL`** — your Vibe
  build doesn't honour that env var. Use `Mistral--run.cmd` against
  the native Mistral API, or drive Mistral models through OpenRouter
  with a different OpenAI-compatible CLI (Codex, Qwen, Trae).
- **Hermes installs but `where hermes` returns nothing** — the
  binary lives at
  `%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts\hermes.exe`,
  not under a `\bin` subdir. Open a new terminal (the
  installer added it to the User PATH) or invoke that path
  directly.
- **Oh-My-Pi install fails with `Unexpected token 'Path", "Machine")'`** —
  upstream `install.ps1` contains Unicode characters without a
  BOM and Windows PowerShell 5.1 reads BOM-less files as
  Windows-1252. `Oh-My-Pi--install.cmd` already works around
  this by re-saving the script with a UTF-8 BOM. If you see
  this error from another agent's installer, apply the same
  pattern to its install script.
- **VT Code installer reports "No recent releases include a
  Windows native binary asset"** — upstream `install.ps1`
  uses HEAD requests to probe for assets and that probe
  silently fails in non-TTY contexts. `VTCode--install.cmd`
  bypasses the upstream installer and reads the GitHub API's
  assets list directly. If you see this error, you ran the
  upstream installer by hand — use `VTCode--install.cmd`
  instead.
- **`opensquilla --version` returns an error** — this is
  expected; OpenSquilla doesn't have a `--version` flag. Use
  `uv tool list | findstr opensquilla` to see the installed
  version.
