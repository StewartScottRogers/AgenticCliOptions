@echo off
setlocal

REM ============================================================
REM  Install / update the OpenAI Codex CLI  --  turn-key installer
REM  ------------------------------------------------------------
REM  Checks for and installs EVERY dependency automatically:
REM    - Node.js LTS (provides npm) - installed via winget if missing
REM    - the OpenAI Codex CLI itself - installed/updated via npm
REM  Re-running this script updates an existing install.
REM
REM  winget (Windows Package Manager) performs the dependency
REM  installs. It ships with Windows 11 and current Windows 10.
REM  A UAC elevation prompt may appear while Node.js installs -
REM  that is expected.
REM ============================================================

call :ensure_node
if errorlevel 1 goto :failed

echo.
echo Installing the OpenAI Codex CLI globally...
echo     npm install -g @openai/codex@latest
echo.
call npm install -g @openai/codex@latest
if errorlevel 1 goto :failed

echo.
echo OpenAI Codex CLI installed. Reported version:
call codex --version
echo.
echo Done. Launch it with Codex--run.cmd, or run 'codex' directly.
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
REM  winget drives every dependency install in this script.
where winget >nul 2>nul && exit /b 0
echo ERROR: 'winget' (Windows Package Manager) was not found.
echo Install "App Installer" from the Microsoft Store, then
echo re-run this script:  https://aka.ms/getwinget
exit /b 1

:refresh_path
REM  winget updates the registry PATH but not this already-running
REM  shell. Prepend the well-known install dirs so a freshly
REM  installed tool is usable now, without opening a new terminal.
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
