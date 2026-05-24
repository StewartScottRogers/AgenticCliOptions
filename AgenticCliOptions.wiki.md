# AgenticCliOptions

A turn-key Windows toolkit that installs, configures, runs and removes **twenty
terminal-based coding-agent CLIs** side by side, plus an optional local
**LM Studio** OpenAI-compatible server. Everything is driven by plain
`.cmd` scripts so the workflow is "double-click, walk away".

The solution is delivered as a Visual Studio *shared project*
(`AgenticCliOptions.shproj` / `.slnx`) — the project itself contains no
buildable code; it is just a host for the `.cmd` scripts so they show up
inside Visual Studio / Rider's Solution Explorer.

---

## Table of contents

- [The twenty agents at a glance](#the-twenty-agents-at-a-glance)
- [Solution layout](#solution-layout)
- [Top-level scripts](#top-level-scripts)
- [Per-agent script conventions](#per-agent-script-conventions)
- [Shared dependencies](#shared-dependencies)
- [Per-agent config directories](#per-agent-config-directories)
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

## The twenty agents at a glance

| Agent          | Vendor       | Install channel                | Native creds                              | OpenRouter launcher | LM Studio launcher |
|----------------|--------------|--------------------------------|-------------------------------------------|---------------------|--------------------|
| **Claude**     | Anthropic    | npm `@anthropic-ai/claude-code` | Anthropic / Claude Code subscription      | yes                 | yes (settings file) |
| **Codex**      | OpenAI       | npm `@openai/codex`            | OpenAI / ChatGPT account                  | yes                 | yes (`-c` overrides) |
| **Gemini**     | Google       | npm `@google/gemini-cli`       | Google account (free tier) or `GEMINI_API_KEY` | no (Google-only API) | no (Google-only API) |
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
| **Junie**      | JetBrains    | official PowerShell installer (`install.ps1`) → `~/.local/bin\junie.bat` | Junie subscription or `--openrouter-api-key` BYOK | yes | no |
| **VT Code**    | vinhnx       | official PowerShell installer (`install.ps1`) → `~/.local/bin\vtcode.exe` | `OPENROUTER_API_KEY` (and many others) | yes (Windows builds **best-effort**) | no |
| **AmazonQ / Kiro** | Amazon   | WSL + official Linux `install.sh` | AWS Builder ID / IAM Identity Center | no (AWS Nova only) | no (AWS Nova only) |

> Agents that don't have an OpenRouter / LM Studio launcher are tied to
> their vendor's own API (Gemini, Grok, Amazon Q). To route those
> *models* through OpenRouter, drive them via an OpenAI-compatible
> agent — e.g. Qwen Code or Trae.

---

## Solution layout

```
AgenticCliOptions/
├── AgenticCliOptions.slnx          # solution file (shared project only)
├── AgenticCliOptions.shproj        # MSBuild shared project
├── AgenticCliOptions.projitems     # files included in the shared project
│
├── Install-All.cmd                 # turn-key install for every agent
├── Uninstall-All.cmd               # remove every agent CLI
├── Install-lmstudio.cmd            # install LM Studio + bring server up
├── Uninstall-lmstudio.cmd          # remove LM Studio app (config kept)
├── SetOpenRouterKey.cmd            # one-shot prompt + verify + persist
├── RunClaude.cmd                   # shortcut launcher at the root
│
└── CodingAgents/
    ├── AmazonQ/   AmazonQ--{install,run,uninstall}.cmd
    ├── Claude/    Claude--{install,run,uninstall,openrouter,settings-lmstudio}.cmd
    │              LMStudio.Claude.Settings.json
    ├── Codex/     Codex--{install,run,uninstall,openrouter,settings-lmstudio}.cmd
    ├── Gemini/    Gemini--{install,run,uninstall}.cmd
    ├── Grok/      Grok--{install,run,uninstall}.cmd
    ├── Mistral/   Mistral--{install,run,uninstall,openrouter}.cmd
    ├── Pi/        Pi--{install,run,uninstall,openrouter}.cmd
    ├── Qwen/      Qwen--{install,uninstall,openrouter,settings-lmstudio}.cmd
    ├── Trae/      Trae--{install,uninstall,openrouter,settings-lmstudio}.cmd
    ├── Hermes/    Hermes--{install,uninstall,openrouter,run}.cmd
    ├── Codebuff/  Codebuff--{install,uninstall,run}.cmd
    ├── Oh-My-Pi/  Oh-My-Pi--{install,uninstall,openrouter,run}.cmd
    ├── OpenSquilla/ OpenSquilla--{install,uninstall,openrouter,run}.cmd
    ├── Aider/     Aider--{install,uninstall,openrouter,run}.cmd
    ├── Junie/     Junie--{install,uninstall,openrouter,run}.cmd
    └── VTCode/    VTCode--{install,uninstall,openrouter,run}.cmd
```

---

## Top-level scripts

| Script                    | What it does                                                                                     |
|---------------------------|--------------------------------------------------------------------------------------------------|
| `Install-All.cmd`         | Installs shared deps once (Node LTS, uv, Git), then runs each agent's `*--install.cmd` in order. Amazon Q runs last because its WSL bootstrap may force a Windows reboot — the script is **safe to re-run** afterwards. Sets `AGENTS_INSTALL_ALL=1` so child scripts skip their final `pause`. |
| `Uninstall-All.cmd`       | Calls every agent's `*--uninstall.cmd` in reverse order. Leaves shared deps and per-agent config in place — see the script header for the manual steps to wipe those too. |
| `Install-lmstudio.cmd`    | Probes `LMSTUDIO_URL` (defaults to a LAN host) and `127.0.0.1:1234`; if no server answers, installs the LM Studio app via winget, locates `lms.exe`, starts the server, and re-probes. Idempotent. |
| `Uninstall-lmstudio.cmd`  | Stops the local server (`lms server stop`) and uninstalls the LM Studio app via winget. **Preserves** `%USERPROFILE%\.lmstudio` (config + the `lms` CLI) and `%APPDATA%\LMStudio` so re-installing restores everything. |
| `SetOpenRouterKey.cmd`    | Prompts for an OpenRouter key, sanity-checks the prefix, hits `https://openrouter.ai/api/v1/key` to verify, then stores it in the persistent user env var `OPENROUTER_API_KEY` via `setx`. Every `*--openrouter.cmd` reads this single variable. |
| `RunClaude.cmd`           | Convenience shortcut at the repo root — same as `CodingAgents\Claude\Claude--run.cmd`. |

---

## Per-agent script conventions

Each agent folder follows the same naming pattern, so a script's name
tells you what it does without opening it:

| Suffix                      | Purpose                                                                                  |
|-----------------------------|------------------------------------------------------------------------------------------|
| `<Agent>--install.cmd`      | Install or update the CLI. Re-runnable. Auto-installs its own deps via winget if missing. |
| `<Agent>--uninstall.cmd`    | Remove the CLI only. Never touches shared deps or `%USERPROFILE%\.<agent>` config dir.    |
| `<Agent>--run.cmd`          | Launch the CLI against its native vendor API (and native auth).                            |
| `<Agent>--openrouter.cmd`   | Launch via OpenRouter, using `OPENROUTER_API_KEY` and an overridable `OPENROUTER_MODEL`.   |
| `<Agent>--settings-lmstudio.cmd` | Launch against a local LM Studio server (auto-detects the loaded model).             |

Conventions baked into every script:

- **Idempotent install**. `where <bin>` short-circuits if the dep is
  already present; `winget install --silent --accept-*-agreements`
  otherwise. After winget the script calls `:refresh_path` to make the
  newly installed bin usable in the *current* shell — no "open a new
  terminal" detour.
- **Idempotent uninstall**. Each one tolerates the "not installed"
  case as success rather than failure, so re-running them is safe.
- **No interactive prompts when called from the parent**. Install-All
  / Uninstall-All set `AGENTS_INSTALL_ALL=1` / `AGENTS_UNINSTALL_ALL=1`,
  and every child script skips its final `pause` when that variable is
  defined.
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
| uv (Astral)             | Mistral, Trae, Hermes (used internally by its installer), OpenSquilla, Aider                     | `winget install astral-sh.uv`          |
| Git for Windows         | Grok, Codebuff, Oh-My-Pi, Aider (provides `bash.exe` + `git.exe` at runtime)                     | `winget install Git.Git`               |
| WSL + Ubuntu            | Amazon Q (no native Windows build)                                                               | `wsl --install` + `wsl --install -d Ubuntu` |
| Python 3.11 / 3.12      | Trae (`tree-sitter-languages` pin → 3.12); Hermes installer pins 3.11; OpenSquilla pins 3.12     | uv downloads them automatically        |
| winget                  | every agent uses winget for shared deps                                                          | ships with Windows 11 (App Installer)  |
| LM Studio (optional)    | every `*--settings-lmstudio.cmd`                                                                 | `winget install ElementLabs.LMStudio`  |

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
| Junie     | `%USERPROFILE%\.local\share\junie`, `%USERPROFILE%\.junie` |
| VT Code   | `%LOCALAPPDATA%\vinhnx\vtcode\config`, `%LOCALAPPDATA%\vinhnx\vtcode\data` |
| Amazon Q  | `~/.local/share/amazon-q` *inside WSL*              |
| LM Studio | `%USERPROFILE%\.lmstudio`, `%APPDATA%\LMStudio`     |

---

## Ongoing maintenance

### Routine: keep every agent current

The install scripts are also *update* scripts — they always install
`@latest` / `--upgrade`. So routine maintenance is just:

1. Re-run `Install-All.cmd` from time to time (monthly is plenty for
   most teams). Each agent fetches its latest published release.
2. If you only use one agent, run just that folder's `*--install.cmd`.
3. After an LM Studio update, re-run `Install-lmstudio.cmd` so the
   `lms` CLI and the local server come back up cleanly.

There is **no version pinning** in this repo by design — keeping every
agent on `@latest` makes drift between them visible quickly.

### Per-agent maintenance notes

These are the points where each agent has historically needed
hand-holding. Watch for them when upstreams change.

- **Claude** — install has *two* paths: the npm package
  `@anthropic-ai/claude-code` and Anthropic's native installer that
  drops a binary at `~/.local/bin/claude.exe`. The uninstaller cleans
  up both. If `del` fails with "Access is denied", a `claude` process
  is still running — close it and re-run the uninstaller.
- **Codex** — OpenRouter launcher uses on-the-fly `-c model_provider=...`
  overrides instead of editing `~/.codex/config.toml`. Keep
  `wire_api=chat` (OpenAI-compatible chat-completions endpoint).
- **Gemini** — no OpenRouter / LM Studio launcher; the Gemini CLI only
  speaks Google's own API. To route Gemini *models* via OpenRouter,
  use the Qwen Code CLI (it's a Gemini CLI fork and accepts an OpenAI
  base URL).
- **Pi** — `Pi--install.cmd` first quietly uninstalls the legacy
  `@mariozechner/pi-coding-agent` package because both ship a `pi` bin
  and npm fails with `EEXIST` otherwise. Pi installs with
  `--ignore-scripts` per upstream guidance. Pi has no LM Studio
  launcher — LM Studio integration lives in Pi's `models.json`.
- **Qwen** — requires Node 22+. If you upgrade Node manually, make sure
  the major version is `>=22` or `Install-All.cmd :ensure_node_22`
  will (correctly) force an upgrade.
- **Grok** — beta software; primary install path is the official bash
  installer (`curl -fsSL https://x.ai/cli/install.sh | bash`, run
  through Git Bash), npm fallback is the community `grok-build`
  package. If both paths fail, check <https://x.ai/cli> for the
  current install method. The uninstaller cleans up
  `%USERPROFILE%\.local\bin\grok`, `~/.x.ai\bin\grok`,
  `~/.grok\bin\grok` and the npm package.
- **Mistral** — installs as `uv tool install mistral-vibe`. The
  OpenRouter launcher works by overriding `MISTRAL_BASE_URL`, which
  only works if the current Vibe build honours that env var. Verify
  with a short test prompt after a Vibe update.
- **Trae** — *not on PyPI*. Installed from GitHub as
  `trae-agent[evaluation] @ git+https://github.com/bytedance/trae-agent.git`.
  Pinned to Python 3.12 because the `tree-sitter-languages` pin has
  no wheels for 3.13+. The `[evaluation]` extra is required even for
  normal use because `base_agent.py` unconditionally imports
  `docker_manager`, which pulls in `docker` and `pexpect`.
- **Hermes** — Nous Research's agent. Native Windows is
  documented as **early beta** but in practice installs and
  runs cleanly. The installer is the upstream PowerShell
  one-liner (`iex (irm .../install.ps1)`); no admin rights
  needed. It provisions Python 3.11 via uv, Node, PortableGit,
  ripgrep, ffmpeg and a Playwright-managed Chromium under
  `%LOCALAPPDATA%\hermes`. **The actual binary lives at
  `%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts\hermes.exe`**,
  not in a `\bin` subdir — every Hermes script in this repo
  prepends that exact path. The uninstaller calls Hermes' own
  `hermes uninstall` subcommand and then prunes that PATH
  entry from the User registry (Hermes' own uninstaller does
  not always clean it on Windows). OpenRouter launcher passes
  `--provider openrouter --model <slug>`; `OPENROUTER_API_KEY`
  is recognised natively.
- **Codebuff** — terminal coding agent backed by the
  codebuff.com platform. Installed via `npm install -g
  codebuff@latest`. On Windows it needs `bash.exe` to run its
  shell-execution tool; the installer pulls Git for Windows if
  missing (you already have it for Grok). **No OpenRouter
  launcher**: Codebuff handles model routing internally via its
  own backend and does not document a way to BYO an OpenRouter
  key at the CLI. Sign in with `codebuff` on first run.
- **Oh-My-Pi** — TypeScript coding-first fork of Pi (you also
  ship the original Pi). Installed via the upstream PowerShell
  installer in **binary** mode (`-Binary` flag) so no Bun is
  required at install time; the prebuilt EXE lands under
  `%LOCALAPPDATA%\omp\omp.exe` and that dir is added to the
  User PATH. omp needs `bash.exe` at runtime; the install
  script pulls Git for Windows if missing. The upstream tool
  has no uninstaller, so `Oh-My-Pi--uninstall.cmd` removes the
  install dir manually and prunes the PATH entry from the
  registry. OpenRouter via `--model openrouter/<provider>/<model>`.
  **Two installer gotchas we already work around** — both
  hidden in `Oh-My-Pi--install.cmd`, no action needed unless
  upstream rewrites their `install.ps1`:
    1. The upstream usage pattern `& ([scriptblock]::Create((irm
       ...))) -Binary` uses nested parens that cmd cannot parse;
       we stage the script to a temp file instead.
    2. `install.ps1` contains Unicode characters (✓, ⚠) but
       ships with **no BOM**. Windows PowerShell 5.1 reads
       BOM-less files as Windows-1252, which mangles the
       multi-byte UTF-8 and crashes the parser with `Unexpected
       token 'Path", "Machine")'`. We download via
       `Net.WebClient`, decode as UTF-8, and re-save **with a
       UTF-8 BOM** before invoking. Watch for this pattern in
       any future PowerShell-installer agent.
- **OpenSquilla** — token-efficient microkernel agent. **Not
  on PyPI**: the upstream installer only accepts a published
  wheel URL from GitHub Releases. `OpenSquilla--install.cmd`
  hits the GitHub API on every run to discover the latest
  `.whl` asset, then installs via
  `uv tool install --python 3.12 --upgrade "opensquilla[recommended] @ <url>"`.
  Re-run to upgrade. The OpenRouter launcher persists the
  provider via `opensquilla configure --section provider
  --provider openrouter --api-key-env OPENROUTER_API_KEY
  --model <slug>` and then `opensquilla chat --model <slug>`.
  `opensquilla` has no `--version` flag, so the install
  script reads the version from `uv tool list`. If you see
  `DLL load failed`, install the VC++ Redistributable.
- **Aider** — the classic AI pair-programmer for the terminal.
  Installed via `uv tool install --force --python 3.12
  --upgrade aider-chat`. Needs Git installed at runtime to
  track edits; the installer pulls Git for Windows if missing.
  OpenRouter via `--model openrouter/<provider>/<model>` with
  `OPENROUTER_API_KEY` in the environment.
  `aider --list-models openrouter/` enumerates every routable
  model Aider knows about.
- **Junie** — JetBrains' AI coding agent for the terminal.
  Installed via the upstream PowerShell installer that drops a
  shim at `~/.local/bin\junie.bat` and binaries under
  `~/.local/share\junie`. Junie self-updates: re-running the
  installer reinstalls the current release; the running binary
  applies pending updates on next launch. OpenRouter BYOK via
  `junie --openrouter-api-key %OPENROUTER_API_KEY% --model
  <slug>`; the launcher does that for you. No uninstall
  command upstream, so `Junie--uninstall.cmd` removes the shim
  and data dir manually.
- **VT Code** — Rust-based coding agent with code-understanding
  tooling and shell safety. **Windows builds are flagged
  "best-effort, may lag behind macOS/Linux"** by upstream — and
  in practice the most recent few releases often ship no
  Windows asset at all. The upstream PowerShell installer
  *intends* to walk back to the latest Windows release, but
  its HEAD-request probe silently fails in non-TTY contexts
  (e.g. when launched from cmd via our install scripts), so
  it falsely reports "no Windows asset". We bypass it
  entirely: query the GitHub API for the last 20 releases,
  pick the first whose **assets list** includes
  `vtcode-<tag>-x86_64-pc-windows-msvc.zip`, then download and
  extract to `~/.local/bin\vtcode.exe`. Re-run to upgrade.
  OpenRouter via `vtcode --provider openrouter --model <slug>
  chat`. If no recent release has a Windows asset at all,
  fall back to `cargo install vtcode` (needs Rust toolchain).
- **Amazon Q / Kiro** — runs *inside WSL*. The installer is staged:
  Stage 1 installs WSL (requires a reboot), Stage 2 installs Ubuntu,
  Stage 3 installs the CLI inside WSL via the official
  `kirocli-x86_64-linux.zip`. Each run detects where it left off and
  continues. AWS sign-in via `q login` runs on first `q chat`.

### Adding a brand-new coding agent

To keep the project coherent, follow this checklist:

1. **Create `CodingAgents\<Name>\`** with at least
   `<Name>--install.cmd`, `<Name>--run.cmd`, `<Name>--uninstall.cmd`.
   Copy from the closest existing agent (npm-based ⇒ Claude/Codex;
   `uv tool` ⇒ Mistral/Trae; bash installer ⇒ Grok; WSL-only ⇒ AmazonQ).
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
   Install order is: Claude, Codex, Gemini, Pi, Qwen, Grok, Mistral,
   Trae, Hermes, Codebuff, Oh-My-Pi, OpenSquilla, Aider, Junie,
   VT Code, then Amazon Q **last** (reboot). Uninstall is the reverse.
6. **Add the agent's config dir to the "leaves alone" list** in both
   `Uninstall-All.cmd` and the agent's own uninstaller.
7. **Add a row** to the [agent matrix above](#the-twenty-agents-at-a-glance)
   and a per-agent note in [maintenance notes](#per-agent-maintenance-notes).
   Bump the "**N agents at a glance**" count in the intro
   paragraph, the table of contents anchor, and the section
   heading so they stay in sync — they're three separate
   places to update.
8. **Optional: `<Name>--openrouter.cmd`** if the agent speaks an
   OpenAI- or Anthropic-compatible API. It must read the shared
   `OPENROUTER_API_KEY` env var and accept an overridable
   `OPENROUTER_MODEL` default.
9. **Optional: `<Name>--settings-lmstudio.cmd`** if the agent can be
   pointed at an OpenAI-compatible base URL. Auto-detect the loaded
   model from `${LMSTUDIO_URL}/v1/models`.
10. **Smoke-test the install end-to-end.** Set
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
