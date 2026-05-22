@echo off
setlocal

REM ============================================================
REM  Install / update Trae Agent (ByteDance)  --  turn-key installer
REM  ------------------------------------------------------------
REM  Checks for and installs EVERY dependency automatically:
REM    - uv (Astral's Python tool installer) - via winget if missing
REM    - a suitable Python - uv downloads one automatically
REM    - Trae Agent itself - installed/updated via 'uv tool'
REM  Re-running this script updates an existing install.
REM
REM  winget (Windows Package Manager) installs uv. It ships with
REM  Windows 11 and current Windows 10.
REM
REM  If the 'trae-agent' package cannot be found on PyPI, install
REM  from source instead:
REM      git clone https://github.com/bytedance/trae-agent.git
REM      cd trae-agent
REM      uv sync --all-extras
REM ============================================================

call :ensure_uv
if errorlevel 1 goto :failed

echo.
echo Installing / updating Trae Agent...
echo     uv tool install --upgrade trae-agent
echo.
call uv tool install --upgrade trae-agent
if errorlevel 1 goto :failed

REM  Make sure uv's tool-bin directory is on PATH for new terminals,
REM  then refresh PATH here so the 'trae-cli' command works now.
call uv tool update-shell >nul 2>nul
call :refresh_path

echo.
echo Trae Agent installed. Reported version:
call trae-cli --version
echo.
echo Done. Launch it with Trae--openrouter.cmd or
echo Trae--settings-lmstudio.cmd.
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
echo If the 'trae-agent' package cannot be found, install from
echo source - see the note at the top of this script.

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
