@echo off
setlocal

REM ============================================================
REM  Install / update OpenClaw  --  turn-key installer
REM  ------------------------------------------------------------
REM  OpenClaw is an open-source personal AI assistant / coding
REM  agent. See https://openclaw.ai/ and the docs at
REM  https://docs.openclaw.ai/ for details.
REM
REM  Checks for and installs EVERY dependency automatically:
REM    - Node.js LTS (provides npm) - installed via winget if missing
REM    - the OpenClaw CLI itself - installed/updated via npm
REM  Re-running this script updates an existing install.
REM
REM  Runtime requirement: Node 24 (recommended) or Node 22.19+.
REM  The Install-All.cmd :ensure_node_22 helper covers the 22+
REM  baseline. The upstream project also offers a Windows .exe
REM  installer (OpenClaw Desktop) - not used here.
REM
REM  winget (Windows Package Manager) performs the dependency
REM  installs. It ships with Windows 11 and current Windows 10.
REM ============================================================

call :ensure_node
if errorlevel 1 goto :failed

echo.
echo Installing the OpenClaw CLI globally...
echo     npm install -g openclaw@latest
echo.
call npm install -g openclaw@latest
if errorlevel 1 goto :failed

echo.
echo OpenClaw CLI installed. Reported version:
call openclaw --version
echo.
echo First-time setup: run 'openclaw onboard' to configure the
echo gateway, workspace and providers. Or use
echo OpenClaw--openrouter.cmd to launch against OpenRouter.
goto :end


REM ============================================================
REM  Helper routines
REM ============================================================

:ensure_node
where npm >nul 2>nul && exit /b 0
echo.
echo Node.js / npm was not found - installing Node.js LTS...
call :ensure_winget
if errorlevel 1 exit /b 1
winget install --id OpenJS.NodeJS.LTS --exact --silent --accept-package-agreements --accept-source-agreements
call :refresh_path
where npm >nul 2>nul && exit /b 0
echo ERROR: Node.js was installed but npm is still not on PATH.
echo Close this window, open a new terminal, and re-run this script.
exit /b 1

:ensure_winget
where winget >nul 2>nul && exit /b 0
echo ERROR: 'winget' (Windows Package Manager) was not found.
echo Install "App Installer" from the Microsoft Store, then
echo re-run this script:  https://aka.ms/getwinget
exit /b 1

:refresh_path
call :prepend_path "%ProgramFiles%\nodejs"
call :prepend_path "%ProgramW6432%\nodejs"
call :prepend_path "%LOCALAPPDATA%\Microsoft\WinGet\Links"
exit /b 0

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0


:failed
echo.
echo ERROR: Installation failed - see the output above.
echo Common causes: no internet connection, or Node.js below
echo 22.19. Re-run Install-All.cmd to upgrade Node first.

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
