@echo off
setlocal

REM ============================================================
REM  Install / update Nanocoder  --  turn-key installer
REM  ------------------------------------------------------------
REM  Nanocoder is a beautiful local-first coding agent that runs
REM  in your terminal. See
REM  https://github.com/Nano-Collective/nanocoder for source.
REM
REM  Checks for and installs EVERY dependency automatically:
REM    - Node.js LTS (provides npm) - installed via winget if missing
REM    - the Nanocoder CLI itself - installed/updated via npm
REM  Re-running this script updates an existing install.
REM
REM  Upstream documentation does not officially flag native
REM  Windows support, but the npm install path works on Windows
REM  in practice. Treat this agent as best-effort on Windows.
REM ============================================================

call :ensure_node
if errorlevel 1 goto :failed

echo.
echo Installing the Nanocoder CLI globally...
echo     npm install -g @nanocollective/nanocoder@latest
echo.
call npm install -g @nanocollective/nanocoder@latest
if errorlevel 1 goto :failed

echo.
echo Nanocoder CLI installed. Reported version:
call nanocoder --version
echo.
echo Done. Launch it with Nanocoder--openrouter.cmd, or run
echo 'nanocoder' directly inside a project.
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
echo Common causes: no internet connection, or winget could not
echo install Node.js. Try running this script as administrator.

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
