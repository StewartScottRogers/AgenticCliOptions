# VT Code

vinhnx's Rust-based coding agent with code-understanding tooling and shell safety. See <https://github.com/vinhnx/vtcode>.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | vinhnx |
| **Install channel** | Direct download of `vtcode-<tag>-x86_64-pc-windows-msvc.zip` from GitHub Releases → `%USERPROFILE%\.local\bin\vtcode.exe` |
| **Native auth** | `OPENROUTER_API_KEY` (and many others) |
| **Default model** | `qwen/qwen3-coder` (override: `setx VTCODE_MODEL "..."`) |
| **OpenRouter launcher** | yes (**Windows builds best-effort** — see notes) |
| **LM Studio launcher** | no (stub) |
| **Runtime deps** | none |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `VTCode--install.cmd` | Queries the GitHub API for the latest release that ships a Windows zip, downloads + extracts to `~/.local/bin\vtcode.exe`. Re-run to upgrade. |
| `VTCode--run.cmd` | Launch with `vtcode chat`. |
| `VTCode--openrouter.cmd` | Route via `vtcode --provider openrouter --model <slug> chat`. |
| `VTCode--uninstall.cmd` | Removes `vtcode.exe`. |
| `VTCode--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |
| `VTCode--local-lmstudio.cmd` | Stub. |
| `VTCode--remote-lmstudio.cmd` | Placeholder. |

## Config (NOT removed by uninstall)

- `%LOCALAPPDATA%\vinhnx\vtcode\config`
- `%LOCALAPPDATA%\vinhnx\vtcode\data`

## Maintenance notes

**Windows builds are flagged "best-effort, may lag behind macOS/Linux"** by upstream — and in practice the most recent few releases often ship no Windows asset at all. The upstream PowerShell installer *intends* to walk back to the latest Windows release, but its HEAD-request probe silently fails in non-TTY contexts (e.g. when launched from cmd via our install scripts), so it falsely reports "no Windows asset".

We bypass it entirely: query the GitHub API for the last 20 releases, pick the first whose **assets list** includes `vtcode-<tag>-x86_64-pc-windows-msvc.zip`, then download and extract to `~/.local/bin\vtcode.exe`. Re-run to upgrade.

If no recent release has a Windows asset at all, fall back to `cargo install vtcode` (needs Rust toolchain).

## Plugins

Both `VTCode--install.cmd` and `VTCode--uninstall.cmd` fan into `..\Plugins\_apply-plugins.cmd VTCode {install,uninstall}` so any plugin whose manifest lists VTCode in `supports` (or names it as `agent`) is installed / removed automatically. See [Plugin layer](../../AgenticCliOptions.wiki.md#plugin-layer) for the manifest format and dispatcher behavior.

No plugin in the repo currently ships a hook for VTCode.
