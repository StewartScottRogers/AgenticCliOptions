@echo off
setlocal

REM ============================================================
REM  Install / update Codebuff  --  turn-key installer
REM  ------------------------------------------------------------
REM  Codebuff is an AI coding agent that runs in your terminal.
REM  See https://www.codebuff.com/ for docs.
REM
REM  Checks for and installs EVERY dependency automatically:
REM    - Node.js LTS (provides npm) - installed via winget if missing
REM    - Git for Windows (Codebuff needs bash.exe for shell exec) -
REM      installed via winget if missing
REM    - the Codebuff CLI itself - installed/updated via npm
REM  Re-running this script updates an existing install.
REM
REM  Windows-specific: Codebuff runs natively on Windows but
REM  needs a bash.exe to execute its shell tools. Git for Windows
REM  provides one; we install it if missing. See
REM  https://github.com/CodebuffAI/codebuff/blob/main/WINDOWS.md
REM
REM  winget (Windows Package Manager) performs the dependency
REM  installs. It ships with Windows 11 and current Windows 10.
REM ============================================================

call :ensure_node
if errorlevel 1 goto :failed
call :ensure_git
if errorlevel 1 goto :failed

echo.
echo Installing the Codebuff CLI globally...
echo     npm install -g codebuff@latest
echo.
call npm install -g codebuff@latest
if errorlevel 1 goto :failed

echo.
echo Codebuff CLI installed. Reported version:
call codebuff --version
echo.
echo Done. Launch it with Codebuff--run.cmd, or run 'codebuff'
echo directly inside a project. First run will prompt you to sign
echo in via codebuff.com.
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

:ensure_git
where bash >nul 2>nul && exit /b 0
echo.
echo bash was not found - installing Git for Windows (provides
echo bash, which Codebuff needs for shell tool execution)...
call :ensure_winget
if errorlevel 1 exit /b 1
winget install --id Git.Git --exact --silent --accept-package-agreements --accept-source-agreements
call :refresh_path
where bash >nul 2>nul && exit /b 0
echo WARNING: Git was installed but bash is still not on PATH.
echo Codebuff may fail on shell-tool calls. Open a new terminal
echo and re-run if needed.
exit /b 0

:ensure_winget
where winget >nul 2>nul && exit /b 0
echo ERROR: 'winget' (Windows Package Manager) was not found.
echo Install "App Installer" from the Microsoft Store, then
echo re-run this script:  https://aka.ms/getwinget
exit /b 1

:refresh_path
call :prepend_path "%ProgramFiles%\nodejs"
call :prepend_path "%ProgramW6432%\nodejs"
call :prepend_path "%ProgramFiles%\Git\cmd"
call :prepend_path "%ProgramFiles%\Git\bin"
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
