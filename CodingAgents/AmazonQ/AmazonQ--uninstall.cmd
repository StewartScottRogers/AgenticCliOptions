@echo off
setlocal

REM ============================================================
REM  Amazon Q Developer CLI  (a.k.a. "Kiro CLI")
REM  UNINSTALLER  -  removes the CLI from inside WSL
REM  ------------------------------------------------------------
REM  Because Amazon Q has no native Windows build, the install
REM  lives inside WSL. This uninstaller mirrors that: it runs
REM  the CLI's own uninstaller inside WSL (which cleans up the
REM  binary in ~/.local/bin and the supporting files), then
REM  falls back to manual removal if the built-in uninstaller
REM  is not available.
REM
REM  What this script does NOT remove:
REM    - WSL itself, the Ubuntu distro, or any other Linux
REM      packages installed alongside it (curl, unzip, etc.)
REM    - Your AWS Builder ID / IAM Identity Center login
REM      cached inside the distro at ~/.local/share/amazon-q
REM      (delete that folder by hand for a fully clean slate).
REM ============================================================

REM  Tear down plugin entries BEFORE removing the CLI. Plugin
REM  hooks for AmazonQ must shell into WSL themselves if they
REM  target the CLI.
call "%~dp0..\Plugins\_apply-plugins.cmd" AmazonQ uninstall

echo ============================================================
echo  Amazon Q / Kiro CLI uninstaller
echo ============================================================
echo.

REM ------------------------------------------------------------
REM  Step 1: WSL must be present, otherwise there is nothing the
REM          CLI could have been installed into.
REM ------------------------------------------------------------
where wsl >nul 2>nul
if errorlevel 1 (
    echo WSL is not installed on this machine - the Amazon Q CLI
    echo could not have been installed either. Nothing to do.
    goto :end
)

wsl -e true >nul 2>nul
if errorlevel 1 (
    echo WSL has no usable Linux distro - the Amazon Q CLI could
    echo not have been installed inside one. Nothing to do.
    goto :end
)

REM ------------------------------------------------------------
REM  Step 2: Is the CLI actually present? If not, exit cleanly.
REM ------------------------------------------------------------
wsl -e bash -lc "command -v q >/dev/null 2>&1 || command -v kiro-cli >/dev/null 2>&1"
if errorlevel 1 (
    echo The Amazon Q / Kiro CLI is not installed inside WSL.
    echo Nothing to uninstall.
    goto :end
)

REM ------------------------------------------------------------
REM  Step 3: Prefer the CLI's own 'uninstall' subcommand. It
REM          removes shims and supporting files correctly.
REM          Try q first, then kiro-cli. If neither has an
REM          uninstall subcommand, fall back to manual cleanup.
REM ------------------------------------------------------------
echo Running the CLI's built-in uninstaller inside WSL...
echo.
wsl -e bash -lc "if command -v q >/dev/null 2>&1; then q uninstall --no-confirm 2>/dev/null || q uninstall 2>/dev/null; fi; if command -v kiro-cli >/dev/null 2>&1; then kiro-cli uninstall --no-confirm 2>/dev/null || kiro-cli uninstall 2>/dev/null; fi; true"

REM  If either binary is still present, fall back to manually
REM  removing the well-known install paths the install.sh uses
REM  (~/.local/bin/{q,kiro-cli} and the supporting libexec/share
REM  dirs at ~/.local/share/amazon-q and ~/.local/share/kiro-cli).
wsl -e bash -lc "command -v q >/dev/null 2>&1 || command -v kiro-cli >/dev/null 2>&1"
if not errorlevel 1 (
    echo.
    echo Built-in uninstaller did not fully remove the CLI -
    echo cleaning up the install paths manually...
    wsl -e bash -lc "rm -f \"$HOME/.local/bin/q\" \"$HOME/.local/bin/kiro-cli\" \"$HOME/.local/bin/qchat\" \"$HOME/.local/bin/qterm\"; rm -rf \"$HOME/.local/share/amazon-q\" \"$HOME/.local/share/kiro-cli\" \"$HOME/.local/libexec/amazon-q\" \"$HOME/.local/libexec/kiro-cli\""
)

REM ------------------------------------------------------------
REM  Step 4: Report final state.
REM ------------------------------------------------------------
wsl -e bash -lc "command -v q >/dev/null 2>&1 || command -v kiro-cli >/dev/null 2>&1"
if errorlevel 1 (
    echo.
    echo ============================================================
    echo  SUCCESS - the Amazon Q / Kiro CLI is no longer installed
    echo  inside WSL.
    echo.
    echo  WSL itself, the Ubuntu distro, and any cached AWS login
    echo  data have been LEFT IN PLACE. If you want them gone too,
    echo  remove them manually:
    echo.
    echo    wsl --unregister Ubuntu          ^(deletes the distro^)
    echo    wsl --uninstall                  ^(removes WSL itself^)
    echo ============================================================
) else (
    echo.
    echo ------------------------------------------------------------
    echo  The CLI is still detected inside WSL. Open a WSL shell
    echo  and finish removal by hand:
    echo.
    echo    wsl
    echo    which q kiro-cli       # find what remains
    echo    rm -f $(which q kiro-cli 2>/dev/null)
    echo ------------------------------------------------------------
)

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
