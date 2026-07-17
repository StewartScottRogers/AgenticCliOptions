@echo off
setlocal

REM ============================================================
REM  Install wmux  --  turn-key installer
REM  ------------------------------------------------------------
REM  wmux is a NATIVE-Windows terminal multiplexer built for AI
REM  agents - "a Windows tmux alternative for AI agents, no WSL
REM  required." It splits several agents into panes in one window,
REM  uses ConPTY (native Windows PTY), and adds agent-aware
REM  orchestration: agent-to-agent messaging, per-pane execute
REM  approval gates, and task fan-out across git worktrees. It also
REM  bundles MCP + Chrome DevTools browser automation. Auto-detects
REM  Claude Code, Codex, Gemini, Aider, OpenCode and Copilot CLI.
REM  See https://github.com/openwong2kim/wmux.
REM
REM  Install method: winget (official package 'openwong2kim.wmux';
REM  winget/choco avoid the SmartScreen prompt the raw Setup.exe hits).
REM      winget install -e --id openwong2kim.wmux
REM ============================================================

echo.
echo Installing wmux via winget (openwong2kim.wmux)...
echo.

where winget >nul 2>nul
if errorlevel 1 (
    echo ERROR: winget was not found. wmux is distributed through the
    echo Windows Package Manager. Install "App Installer" from the
    echo Microsoft Store [which provides winget], then re-run this script.
    echo Alternatively: choco install wmux, or grab Setup.exe from
    echo https://github.com/openwong2kim/wmux/releases
    goto :failed
)

winget install -e --id openwong2kim.wmux --accept-source-agreements --accept-package-agreements
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
    where wmux >nul 2>nul
    if errorlevel 1 (
        winget list -e --id openwong2kim.wmux >nul 2>nul
        if errorlevel 1 goto :failed
    )
)

call :refresh_path

echo.
where wmux >nul 2>nul
if errorlevel 1 (
    echo wmux installed. If 'wmux' does not resolve in this shell, open a
    echo new terminal [or use the Start-menu shortcut] to launch it.
) else (
    echo wmux installed and on PATH.
)

echo.
echo Done. Launch it with Wmux--run.cmd. Start one agent per pane and
echo use the side dock to route tasks / messages between them.
goto :end


REM  Rebuild this shell's PATH from the registry (machine then user)
REM  so a freshly-installed tool resolves without a new terminal.
:refresh_path
for /f "skip=2 tokens=2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYSPATH=%%B"
for /f "skip=2 tokens=2,*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USRPATH=%%B"
set "PATH=%SYSPATH%;%USRPATH%"
exit /b 0


:failed
echo.
echo ERROR: Installation failed - see the output above.
echo Common causes:
echo   - winget not installed (install "App Installer" from the Store)
echo   - No internet connection / winget source unavailable
echo   - SmartScreen / antivirus blocked the download

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
