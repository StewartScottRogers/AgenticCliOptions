@echo off
setlocal

REM ============================================================
REM  Install / update opencode  --  turn-key installer
REM  ------------------------------------------------------------
REM  opencode (sst/opencode) is an open, provider-neutral terminal
REM  AI coding agent: pick Anthropic, OpenAI, Google, OpenRouter
REM  or any OpenAI-compatible local server per session. Docs:
REM  https://opencode.ai
REM
REM  Checks for and installs EVERY dependency automatically:
REM    - Node.js LTS (provides npm) - installed via winget if missing
REM    - opencode itself - via npm package 'opencode-ai'
REM  Re-running this script updates an existing install.
REM
REM  Native Windows install channel is npm. The official curl|bash
REM  installer is POSIX-only (Linux / macOS / WSL); scoop and choco
REM  also ship opencode. We standardise on npm here for parity with
REM  the other npm-based agents in this repo.
REM ============================================================

call :ensure_node
if errorlevel 1 goto :failed

echo.
echo Installing the opencode CLI globally...
echo     npm install -g opencode-ai@latest
echo.
call npm install -g opencode-ai@latest
if errorlevel 1 goto :failed

echo.
echo opencode installed. Reported version:
call opencode --version
echo.
echo Done. Launch it with Opencode--run.cmd, or run 'opencode' directly.
echo First time: 'opencode auth login ^<provider^>' signs you in.

REM  Fan plugin install hooks out to Opencode.
call "%~dp0..\Plugins\_apply-plugins.cmd" Opencode install
goto :end


REM ============================================================
REM  Helper routines
REM ============================================================

:ensure_node
REM  Ensure Node.js + npm are available; install Node.js LTS via
REM  winget if missing, then make it visible to this running shell.
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
echo Common causes: no internet connection, or winget could not
echo install Node.js. Try running this script as administrator.

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
