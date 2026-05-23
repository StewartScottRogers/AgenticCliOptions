# AgenticCliOptions

A turn-key Windows toolkit that installs, configures, runs and removes **thirteen
terminal-based coding-agent CLIs** side by side, plus an optional local
**LM Studio** OpenAI-compatible server. Everything is driven by plain
`.cmd` scripts so the workflow is "double-click, walk away".

The solution is delivered as a Visual Studio *shared project*
(`AgenticCliOptions.shproj` / `.slnx`) — the project itself contains no
buildable code; it is just a host for the `.cmd` scripts so they show up
inside Visual Studio / Rider's Solution Explorer.

---

## Table of contents

- [The thirteen agents at a glance](#the-thirteen-agents-at-a-glance)
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

## The thirteen agents at a glance

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
| **Hermes**     | Nous Research | official PowerShell installer (`install.ps1`) → `%LOCALAPPDATA%\hermes` | Nous Portal OAuth or `OPENROUTER_API_KEY` | yes                 | no (early-beta on Windows) |
| **OpenClaw**   | OpenClaw     | npm `openclaw` (requires Node 22.19+) | onboarding wizard or `OPENROUTER_API_KEY` | yes                 | no                  |
| **Codebuff**   | Codebuff AI  | npm `codebuff` (needs Git/bash on Windows) | codebuff.com login | no (platform-managed routing) | no |
| **Oh-My-Pi**   | can1357      | PowerShell installer (`omp.sh/install.ps1 -Binary`) | `OPENROUTER_API_KEY` (and many others) | yes | no |
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
    ├── OpenClaw/  OpenClaw--{install,uninstall,openrouter,run}.cmd
    ├── Codebuff/  Codebuff--{install,uninstall,run}.cmd
    └── Oh-My-Pi/  Oh-My-Pi--{install,uninstall,openrouter,run}.cmd
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

| Dependency              | Used by                                  | Installed by                           |
|-------------------------|------------------------------------------|----------------------------------------|
| Node.js LTS (>= 22)     | Claude, Codex, Gemini, Pi, Qwen (and Grok npm fallback) | `winget install OpenJS.NodeJS.LTS` |
| uv (Astral)             | Mistral, Trae                            | `winget install astral-sh.uv`          |
| Git for Windows         | Grok (provides `bash` + `curl`)          | `winget install Git.Git`               |
| WSL + Ubuntu            | Amazon Q (no native Windows build)       | `wsl --install` + `wsl --install -d Ubuntu` |
| Python 3.12             | Trae (tree-sitter-languages pin)         | uv downloads it automatically          |
| LM Studio (optional)    | every `*--settings-lmstudio.cmd`         | `winget install ElementLabs.LMStudio`  |

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
| OpenClaw  | `%USERPROFILE%\.openclaw`                           |
| Codebuff  | `%USERPROFILE%\.codebuff`                           |
| Oh-My-Pi  | `%USERPROFILE%\.omp`, `%LOCALAPPDATA%\omp`          |
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
- **Hermes** — Nous Research's agent. Native Windows is **early
  beta**. The installer is the upstream PowerShell one-liner
  (`iex (irm .../install.ps1)`); no admin rights needed. It
  provisions Python (via uv), Node, PortableGit, ripgrep and
  ffmpeg under `%LOCALAPPDATA%\hermes` and adds `hermes` to the
  User PATH. The uninstaller calls Hermes' own `hermes uninstall`
  subcommand. OpenRouter launcher passes
  `--provider openrouter --model <slug>`; `OPENROUTER_API_KEY` is
  recognised natively.
- **OpenClaw** — open-source personal AI assistant. Installed
  globally via `npm install -g openclaw@latest`. **Needs Node
  22.19+** — the existing `:ensure_node_22` helper in
  `Install-All.cmd` covers this. First run requires
  `openclaw onboard` to set up the gateway/workspace. The
  OpenRouter launcher uses model refs of the form
  `openrouter/<provider>/<model>` and lets the chat command
  `/model openrouter/...` switch on the fly. Note: upstream
  recommends WSL2 for the **best** experience, but the npm
  install works natively on Windows.
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
   Trae, Hermes, OpenClaw, Codebuff, Oh-My-Pi, then Amazon Q
   **last** (reboot). Uninstall is the reverse.
6. **Add the agent's config dir to the "leaves alone" list** in both
   `Uninstall-All.cmd` and the agent's own uninstaller.
7. **Add a row** to the [agent matrix above](#the-nine-agents-at-a-glance)
   and a per-agent note in [maintenance notes](#per-agent-maintenance-notes).
8. **Optional: `<Name>--openrouter.cmd`** if the agent speaks an
   OpenAI- or Anthropic-compatible API. It must read the shared
   `OPENROUTER_API_KEY` env var and accept an overridable
   `OPENROUTER_MODEL` default.
9. **Optional: `<Name>--settings-lmstudio.cmd`** if the agent can be
   pointed at an OpenAI-compatible base URL. Auto-detect the loaded
   model from `${LMSTUDIO_URL}/v1/models`.

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
