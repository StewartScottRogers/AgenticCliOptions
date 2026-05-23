@echo off
setlocal

REM ============================================================
REM  Install-All  --  one-shot turn-key setup for every agent
REM  ------------------------------------------------------------
REM  Installs every shared dependency once via winget, then runs
REM  each coding agent's own turn-key install script. Double-click
REM  this file and walk away.
REM
REM  Shared dependencies installed here:
REM    - Node.js LTS  - for Claude, Codex, Gemini, Pi, Qwen
REM    - uv           - for Mistral, Trae
REM    - Git          - for Grok (provides bash + curl)
REM
REM  Amazon Q is processed LAST because setting up WSL for the
REM  first time forces a Windows reboot. After rebooting, just
REM  run this script again - every step is safe to re-run.
REM
REM  A UAC elevation prompt may appear while dependencies install.
REM ============================================================

REM  Child install scripts read this variable and skip their own
REM  final 'pause', so the whole run is unattended.
set "AGENTS_INSTALL_ALL=1"
set "ROOT=%~dp0"

echo ============================================================
echo  Turn-key install for every coding agent in this project
echo ============================================================
echo.
echo [1/3] Installing shared dependencies via winget...
echo.

where winget >nul 2>nul
if errorlevel 1 goto :nowinget

where npm >nul 2>nul
if errorlevel 1 (
    echo Installing Node.js LTS for Claude, Codex, Gemini, Pi and Qwen...
    winget install --id OpenJS.NodeJS.LTS --exact --silent --accept-package-agreements --accept-source-agreements
) else (
    call :ensure_node_22
)

where uv >nul 2>nul || (
    echo Installing uv for Mistral and Trae...
    winget install --id astral-sh.uv --exact --silent --accept-package-agreements --accept-source-agreements
)

where bash >nul 2>nul || (
    echo Installing Git for Windows for Grok...
    winget install --id Git.Git --exact --silent --accept-package-agreements --accept-source-agreements
)

REM  Make the freshly installed tools visible to this session so
REM  the per-agent scripts below all inherit a working PATH.
call :refresh_path
echo.
echo Shared dependencies ready.
goto :run_agents

:nowinget
echo WARNING: winget was not found - shared dependencies cannot be
echo pre-installed here. Each agent script will still try on its
echo own and report what is missing. Install "App Installer" from
echo the Microsoft Store to enable winget:  https://aka.ms/getwinget
echo.

:run_agents
echo.
echo [2/3] Installing each coding agent CLI...
echo.

call :install_agent Claude
call :install_agent Codex
call :install_agent Gemini
call :install_agent Pi
call :install_agent Qwen
call :install_agent Grok
call :install_agent Mistral
call :install_agent Trae
call :install_agent Hermes
call :install_agent OpenClaw

echo.
echo [3/3] Amazon Q  -  installed last; WSL setup may need a reboot.
echo.
call :install_agent AmazonQ

echo.
echo ============================================================
echo  All agents processed.
echo.
echo  - If Amazon Q asked you to REBOOT, do so and re-run this
echo    script to finish its WSL setup.
echo  - Run SetOpenRouterKey.cmd once to enable every
echo    *--openrouter.cmd launcher.
echo ============================================================
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
goto :eof


REM ============================================================
REM  Helper: run one agent's install script
REM ============================================================
:install_agent
echo ------------------------------------------------------------
echo  %~1
echo ------------------------------------------------------------
if exist "%ROOT%CodingAgents\%~1\%~1--install.cmd" (
    call "%ROOT%CodingAgents\%~1\%~1--install.cmd"
) else (
    echo ERROR: install script for %~1 was not found.
)
echo.
exit /b 0

REM ============================================================
REM  Helper: ensure Node.js is at least v22 (Qwen's requirement).
REM  If an older Node is present, uninstall the old winget package
REM  and install the current LTS. Needs UAC; we let winget prompt.
REM ============================================================
:ensure_node_22
REM  'node --version' prints e.g. v20.18.1 - split on 'v' and '.'
REM  to grab the major version (token 2; token 1 is empty).
set "NODE_MAJOR="
for /f "tokens=2 delims=v." %%a in ('node --version 2^>nul') do set "NODE_MAJOR=%%a"
if not defined NODE_MAJOR exit /b 0
if %NODE_MAJOR% GEQ 22 exit /b 0
echo.
echo Node.js v%NODE_MAJOR% is installed but Qwen requires v22+.
echo Upgrading to the current Node.js LTS via winget...
echo (You may see a UAC prompt - accept it to allow the upgrade.)
echo.
REM  Strip any legacy versioned package id (e.g. OpenJS.NodeJS.20)
REM  so the LTS install does not collide with it. Each line is
REM  best-effort; missing packages just exit nonzero and are OK.
for %%V in (16 18 20 22) do (
    winget uninstall --id OpenJS.NodeJS.%%V --exact --silent --disable-interactivity >nul 2>nul
)
winget install --id OpenJS.NodeJS.LTS --exact --silent --accept-package-agreements --accept-source-agreements
exit /b 0

REM ============================================================
REM  Helper: make freshly winget-installed tools visible now,
REM  without needing to open a new terminal.
REM ============================================================
:refresh_path
call :prepend_path "%ProgramFiles%\nodejs"
call :prepend_path "%ProgramW6432%\nodejs"
call :prepend_path "%ProgramFiles%\Git\cmd"
call :prepend_path "%ProgramFiles%\Git\bin"
call :prepend_path "%LOCALAPPDATA%\Microsoft\WinGet\Links"
call :prepend_path "%USERPROFILE%\.local\bin"
exit /b 0

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0
