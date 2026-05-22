@echo off
setlocal

REM ============================================================
REM  Amazon Q Developer CLI  (now shipping as "Kiro CLI")
REM  FULL AUTO installer  -  WSL + Q / Kiro CLI
REM  ------------------------------------------------------------
REM  Amazon's coding-agent CLI has NO native Windows build. On
REM  Windows it runs inside WSL (Windows Subsystem for Linux),
REM  so this installer sets up the whole dependency chain for
REM  you with no Y/n prompts (turn-key).
REM
REM  Because installing WSL for the first time REQUIRES A REBOOT,
REM  the install cannot finish in a single run. This script is
REM  therefore STAGED and SAFE TO RE-RUN - each run detects how
REM  far things have progressed and continues from there:
REM
REM    Stage 1 - WSL is not installed at all.
REM              -> runs "wsl --install" (UAC prompt expected),
REM                 then asks you to REBOOT and re-run this file.
REM
REM    Stage 2 - WSL is installed but no Linux distro is ready.
REM              -> runs "wsl --install -d Ubuntu", asks you to
REM                 complete Ubuntu's first-run user/password
REM                 setup, then re-run this file.
REM
REM    Stage 3 - WSL + an Ubuntu distro are ready.
REM              -> installs the Amazon Q / Kiro CLI INSIDE WSL
REM                 (downloads the official Linux zip and runs
REM                 its install.sh non-interactively).
REM
REM  You will hit ONE reboot (after Stage 1) and that is the
REM  only manual interruption other than UAC prompts. Just keep
REM  re-running this script until it reports success.
REM
REM  Signing in to your AWS Builder ID / IAM Identity Center
REM  account is NOT automated here - it happens later the first
REM  time you launch AmazonQ--run.cmd (it runs "q login").
REM
REM  Official docs:
REM  https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-installing.html
REM  https://kiro.dev/docs/cli/installation/
REM ============================================================

echo ============================================================
echo  Amazon Q / Kiro CLI - full auto install (WSL + Q CLI)
echo ============================================================
echo.

REM ------------------------------------------------------------
REM  STAGE 1 : is WSL present at all?
REM ------------------------------------------------------------
where wsl >nul 2>nul
if errorlevel 1 goto :stage1_install_wsl

REM ------------------------------------------------------------
REM  STAGE 2 : WSL exists - is a usable Linux distro installed?
REM            "wsl -e true" succeeds only when a default distro
REM            is installed AND initialised.
REM ------------------------------------------------------------
wsl -e true >nul 2>nul
if errorlevel 1 goto :stage2_install_distro

REM ------------------------------------------------------------
REM  STAGE 3 : WSL + distro ready - install the CLI inside WSL.
REM ------------------------------------------------------------
goto :stage3_install_cli


REM ============================================================
REM  STAGE 1 - install WSL itself
REM ============================================================
:stage1_install_wsl
echo [Stage 1/3] WSL was not found on this machine.
echo.
echo Installing WSL plus a default Ubuntu distribution now.
echo A Windows UAC (administrator) prompt will appear - approve it.
echo.

REM  "wsl --install" is the standard, supported way to add WSL.
REM  (winget could also deliver the Store WSL package via
REM   "winget install --id 9P9TQF7MRM4R", but wsl --install is
REM   the canonical path, so we use it directly. The :ensure_winget
REM   helper below is kept for consistency with the other agents.)
wsl --install
if errorlevel 1 (
    echo.
    echo WSL install did not complete cleanly. Try running this
    echo script "as administrator", or from an elevated PowerShell:
    echo.
    echo     wsl --install
    echo.
    goto :end
)

echo.
echo ------------------------------------------------------------
echo  WSL has been installed.
echo.
echo  NEXT STEP:  REBOOT this PC now.
echo.
echo  After the reboot, Windows will finish setting up Ubuntu and
echo  ask you to choose a Linux username and password - do that,
echo  then RE-RUN this script (AmazonQ--install.cmd) to continue.
echo ------------------------------------------------------------
goto :end


REM ============================================================
REM  STAGE 2 - WSL present, but no usable Linux distro
REM ============================================================
:stage2_install_distro
echo [Stage 2/3] WSL is installed, but no Linux distro is ready.
echo.
echo Installing the Ubuntu distribution now...
echo.

wsl --install -d Ubuntu
if errorlevel 1 (
    echo.
    echo Could not install the Ubuntu distro automatically.
    echo Open a terminal and run this manually, then re-run me:
    echo.
    echo     wsl --install -d Ubuntu
    echo.
    goto :end
)

echo.
echo ------------------------------------------------------------
echo  Ubuntu is being set up.
echo.
echo  NEXT STEP:  If an Ubuntu window opened, complete its
echo  first-run setup (choose a Linux username and password).
echo  A reboot may also be required if this is a fresh WSL.
echo.
echo  Then RE-RUN this script (AmazonQ--install.cmd) to continue.
echo ------------------------------------------------------------
goto :end


REM ============================================================
REM  STAGE 3 - install the Amazon Q / Kiro CLI inside WSL
REM ============================================================
:stage3_install_cli
echo [Stage 3/3] WSL and a Linux distro are ready.
echo.

REM  If the CLI is already present, nothing to do.
wsl -e bash -lc "command -v q >/dev/null 2>&1 || command -v kiro-cli >/dev/null 2>&1"
if not errorlevel 1 (
    echo The Amazon Q / Kiro CLI is already installed inside WSL.
    goto :stage3_done
)

echo Installing the Amazon Q / Kiro CLI inside WSL (Ubuntu).
echo This downloads the official Linux build and runs its
echo installer non-interactively - no input needed.
echo.

REM ------------------------------------------------------------
REM  Run the whole Linux-side install in ONE bash -lc command:
REM    1. apt-get update + install curl/unzip (passwordless sudo
REM       is the default for WSL Ubuntu's first user).
REM    2. curl down the official Kiro / Amazon Q Linux zip.
REM    3. unzip it.
REM    4. run install.sh with --no-confirm (fully non-interactive,
REM       installs to ~/.local/bin, no sudo needed).
REM
REM  Official zip:
REM    https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-x86_64-linux.zip
REM ------------------------------------------------------------
wsl -e bash -lc "set -e; export DEBIAN_FRONTEND=noninteractive; sudo apt-get update -y && sudo apt-get install -y curl unzip; cd /tmp; curl --proto '=https' --tlsv1.2 -sSf 'https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-x86_64-linux.zip' -o kirocli.zip; rm -rf /tmp/kirocli; unzip -o kirocli.zip; chmod +x ./kirocli/install.sh; ./kirocli/install.sh --no-confirm; rm -f /tmp/kirocli.zip"
if errorlevel 1 goto :stage3_failed

:stage3_done
echo.
echo ============================================================
echo  SUCCESS - the Amazon Q / Kiro CLI is installed in WSL.
echo ------------------------------------------------------------
echo  NEXT STEP:  run  AmazonQ--run.cmd
echo.
echo  That launches an Amazon Q chat session. The FIRST time it
echo  runs it will prompt you to sign in with  q login  using
echo  your AWS Builder ID / IAM Identity Center account.
echo ============================================================
goto :end

:stage3_failed
echo.
echo ------------------------------------------------------------
echo  The automated CLI install hit a problem (a step may have
echo  needed interactive input, e.g. a sudo password).
echo.
echo  Finish it by hand - opening a WSL shell now. Run:
echo.
echo    sudo apt-get update ^&^& sudo apt-get install -y curl unzip
echo    curl --proto '=https' --tlsv1.2 -sSf \
echo      "https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-x86_64-linux.zip" \
echo      -o kirocli.zip
echo    unzip -o kirocli.zip
echo    ./kirocli/install.sh --no-confirm
echo.
echo  Type 'exit' when done, then use AmazonQ--run.cmd to launch.
echo ------------------------------------------------------------
echo.
call wsl
goto :end


REM ============================================================
REM  HELPER : ensure winget is available
REM  ------------------------------------------------------------
REM  Kept for consistency with the other agent installers in this
REM  repo. This script does not need winget for the WSL path
REM  (it uses "wsl --install"), but the helper is here so callers
REM  can rely on the same routine name across all agents.
REM ============================================================
:ensure_winget
where winget >nul 2>nul
if errorlevel 1 (
    echo NOTE: winget was not found. It ships with App Installer
    echo from the Microsoft Store on Windows 10/11. This installer
    echo does not require winget - WSL is added via "wsl --install".
    exit /b 1
)
exit /b 0


REM ============================================================
REM  END
REM ============================================================
:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
