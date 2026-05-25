# Amazon Q / Kiro

Amazon's terminal coding agent. Runs *inside WSL* — no native Windows build.

> Part of [AgenticCliOptions](../../AgenticCliOptions.wiki.md). See the top-level wiki for shared install / uninstall, OpenRouter key setup, and LM Studio launcher conventions.

## At a glance

| | |
|---|---|
| **Vendor** | Amazon |
| **Install channel** | WSL + Ubuntu + official Linux `install.sh` (staged across reboots) |
| **Native auth** | AWS Builder ID / IAM Identity Center (`q login`) |
| **Default model** | `aws-managed` (CLI picks internally; no `--model` flag) |
| **OpenRouter launcher** | no (AWS Nova only) |
| **LM Studio launcher** | no (AWS Nova only) |
| **Runtime deps** | WSL + Ubuntu (installer drives both) |

## Scripts in this folder

| Script | Purpose |
|---|---|
| `AmazonQ--install.cmd` | Staged installer: WSL → Ubuntu → Kiro CLI inside WSL. Resumes on re-run after a reboot. |
| `AmazonQ--run.cmd` | Drops into the WSL `q chat` session. |
| `AmazonQ--uninstall.cmd` | Removes the CLI inside WSL. Leaves WSL + Ubuntu in place. |
| `AmazonQ--is-installed.cmd` | Probe used by `Install-All.cmd --status`. |
| `AmazonQ--local-lmstudio.cmd` | Stub — AWS Nova only. |
| `AmazonQ--remote-lmstudio.cmd` | Placeholder. |

> Amazon Q always runs **last** in `Install-All.cmd` because Stage 1 (WSL install) can force a Windows reboot.

## Config (NOT removed by uninstall)

- `~/.local/share/amazon-q` *inside WSL*

## Maintenance notes

Runs inside WSL. The installer is staged: Stage 1 installs WSL (requires a reboot), Stage 2 installs Ubuntu, Stage 3 installs the CLI inside WSL via the official `kirocli-x86_64-linux.zip`. Each run detects where it left off and continues. AWS sign-in via `q login` runs on first `q chat`.

If Amazon Q install loops on "please reboot", the previous reboot didn't finish provisioning Ubuntu. Open the Ubuntu app from the Start menu, complete its first-run username/password setup, then re-run `AmazonQ--install.cmd`.
