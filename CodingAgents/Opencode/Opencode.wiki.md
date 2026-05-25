# opencode

SST's open-source, provider-neutral terminal AI coding agent.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | SST (open source, Apache 2.0) |
| **Install channel** | npm `opencode-ai` |
| **Native auth** | Per-provider via `opencode auth login <provider>` (persists in `~/.config/opencode/auth.json`) |
| **Default model** | `anthropic/claude-sonnet-4-5` (override: `setx OPENCODE_MODEL "..."`) — model invocation is always `provider/model` |
| **OpenRouter launcher** | yes (first-class built-in provider) |
| **LM Studio launcher** | yes (per-run `OPENCODE_CONFIG` JSON declaring a custom provider — opencode has no `--base-url` CLI flag) |
| **Runtime deps** | Node.js LTS (>= 22) |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `Opencode--install.cmd` | Install / update via `npm install -g opencode-ai@latest`. Re-runnable. |
| `Opencode--run.cmd` | Launch using `OPENCODE_MODEL` (a `provider/model` slug). |
| `Opencode--openrouter.cmd` | Launch with `--model openrouter/<slug>`. Reads `OPENROUTER_API_KEY` from env, with a fallback note pointing users at `opencode auth login openrouter`. |
| `Opencode--local-lmstudio.cmd` | Generates a temp `OPENCODE_CONFIG` JSON declaring an `lmstudio` provider via `@ai-sdk/openai-compatible`, auto-detects the loaded model, then launches `--model lmstudio/<id>`. Temp config is deleted after exit. |
| `Opencode--remote-lmstudio.cmd` | Placeholder. Set `LMSTUDIO_URL` and call the local launcher. |
| `Opencode--uninstall.cmd` | Remove the npm install. Leaves `~/.config/opencode/` alone. |
| `Opencode--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |

## Config (NOT removed by uninstall)

- `%USERPROFILE%\.config\opencode` (XDG-style even on Windows — contains `opencode.json`, `auth.json`, sessions)

## Maintenance notes

opencode is the rare provider-neutral CLI in this catalogue — switch between Anthropic, OpenAI, Google, OpenRouter and local models from one binary. Model invocation always takes the `provider/model` shape (alias `-m`).

**Authentication is per-provider** and persists in `~/.config/opencode/auth.json`. Run `opencode auth login <provider>` once interactively. The OpenRouter launcher in this repo tries the shared `OPENROUTER_API_KEY` env var first; if your build of opencode does not auto-pick that up, the explicit `auth login` step is the cure (no script change needed).

**No `--base-url` CLI flag.** The LM Studio launcher works around this by generating a per-run config JSON in `%TEMP%`, pointing `OPENCODE_CONFIG` at it, and declaring an `lmstudio` provider via the `@ai-sdk/openai-compatible` adapter. The model id is detected from `${LMSTUDIO_URL}/v1/models` and embedded in the config so opencode accepts the `-m lmstudio/<id>` invocation. Override the URL with `set LMSTUDIO_URL=http://...` before calling the launcher; `_resolve-lmstudio-url.cmd` auto-detects loopback + LAN IPv4s on ports 1234 / 1235 otherwise.

**MCP key is `mcp`, not `mcpServers`.** opencode uses a flat top-level `mcp` object in `opencode.json` where each server has `type` (`local` | `remote`) and either `command: [array]` (local) or `url: <string>` (remote). Plugins in this repo that target opencode write to that shape — see the [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer).

The official `curl | bash` installer is POSIX-only (Linux / macOS / WSL). scoop and choco also publish opencode on Windows, but we standardise on npm for parity with Claude / Codex / Gemini / Pi / Qwen.

## Plugins

Both `Opencode--install.cmd` and `Opencode--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd Opencode {install,uninstall}` so any plugin whose manifest lists Opencode in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

Plugins shipping a hook for Opencode:

- [`context7-mcp`](../Plugins/context7-mcp/plugin.json) — Context7 MCP server (up-to-date library docs). Merged into the top-level `mcp.context7` entry in `~/.config/opencode/opencode.json` as `{"type":"local","command":["npx","-y","@upstash/context7-mcp"],"enabled":true}`.
