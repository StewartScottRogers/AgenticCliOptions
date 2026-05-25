@echo off
setlocal

REM ============================================================
REM  Install / update Mistral Vibe  --  turn-key installer
REM  ------------------------------------------------------------
REM  Checks for and installs EVERY dependency automatically:
REM    - uv (Astral's Python tool installer) - via winget if missing
REM    - a suitable Python - uv downloads one automatically
REM    - Mistral Vibe itself - installed/updated via 'uv tool'
REM  Re-running this script updates an existing install.
REM
REM  winget (Windows Package Manager) installs uv. It ships with
REM  Windows 11 and current Windows 10.
REM ============================================================

call :ensure_uv
if errorlevel 1 goto :failed

echo.
echo Installing / updating Mistral Vibe...
echo     uv tool install --upgrade mistral-vibe
echo.
call uv tool install --upgrade mistral-vibe
if errorlevel 1 goto :failed

REM  Make sure uv's tool-bin directory is on PATH for new terminals,
REM  then refresh PATH here so the 'vibe' command works right away.
call uv tool update-shell >nul 2>nul
call :refresh_path

echo.
echo Mistral Vibe installed. Reported version:
call vibe --version
echo.
echo Done. Launch it with Mistral--run.cmd, or run 'vibe' directly.

REM  Fan plugin install hooks out to Mistral.
call "%~dp0..\Plugins\_apply-plugins.cmd" Mistral install
goto :end


REM ============================================================
REM  Helper routines
REM ============================================================

:ensure_uv
REM  Ensure uv is available; install it via winget if missing,
REM  then make it visible to this already-running shell. uv will
REM  download a suitable Python by itself when it installs a tool.
where uv >nul 2>nul && exit /b 0
echo.
echo uv (the Python tool installer) was not found - installing it...
call :ensure_winget
if errorlevel 1 exit /b 1
winget install --id astral-sh.uv --exact --silent --accept-package-agreements --accept-source-agreements
call :refresh_path
where uv >nul 2>nul && exit /b 0
echo ERROR: uv was installed but is still not on PATH.
echo Close this window, open a new terminal, and re-run this script.
exit /b 1

:ensure_winget
REM  winget drives the uv install in this script.
where winget >nul 2>nul && exit /b 0
echo ERROR: 'winget' (Windows Package Manager) was not found.
echo Install "App Installer" from the Microsoft Store, then
echo re-run this script:  https://aka.ms/getwinget
exit /b 1

:refresh_path
REM  winget updates the registry PATH but not this already-running
REM  shell. Prepend the well-known install dirs so a freshly
REM  installed tool is usable now, without opening a new terminal.
call :prepend_path "%LOCALAPPDATA%\Microsoft\WinGet\Links"
call :prepend_path "%USERPROFILE%\.local\bin"
exit /b 0

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0


:failed
echo.
echo ERROR: Installation failed - see the output above.
echo Common causes: no internet connection, or winget could not
echo install uv. Try running this script as administrator.

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
