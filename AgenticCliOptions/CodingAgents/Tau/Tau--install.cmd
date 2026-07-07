@echo off
setlocal

REM ============================================================
REM  Install / update Tau  --  turn-key installer
REM  ------------------------------------------------------------
REM  Tau (tau-ai) is Hugging Face's minimalist terminal coding
REM  agent - a readable, Pi-style harness with a Textual TUI, a
REM  print mode, file/shell tools, on-disk sessions and a
REM  config-driven provider catalog. See
REM  https://github.com/huggingface/tau for docs.
REM
REM  Checks for and installs EVERY dependency automatically:
REM    - uv (Astral's Python tool installer) - via winget if missing
REM    - CPython 3.12 - uv downloads it automatically
REM    - Tau itself - installed/updated via 'uv tool' from the
REM      'tau-ai' package on PyPI (requires Python 3.12+)
REM  Re-running this script updates an existing install.
REM
REM  Tau needs no Git to run (its edits are plain file writes), so
REM  unlike Aider we only ensure uv is present.
REM ============================================================

call :ensure_uv
if errorlevel 1 goto :failed

echo.
echo Installing / updating Tau...
echo     uv tool install --force --python 3.12 --upgrade tau-ai
echo.
call uv tool install --force --python 3.12 --upgrade tau-ai
if errorlevel 1 goto :failed

call uv tool update-shell >nul 2>nul
call :refresh_path

echo.
echo Tau installed. Reported version:
call tau --version
echo.
echo Done. Launch it with Tau--run.cmd (or Tau--openrouter.cmd),
echo or run 'tau' directly inside a project. First run: use the
echo /login slash command, or set a provider API key.

REM  Fan plugin install hooks out to Tau.
call "%~dp0..\Plugins\_apply-plugins.cmd" Tau install
goto :end


REM ============================================================
REM  Helper routines
REM ============================================================

:ensure_uv
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
where winget >nul 2>nul && exit /b 0
echo ERROR: 'winget' (Windows Package Manager) was not found.
echo Install "App Installer" from the Microsoft Store, then
echo re-run this script:  https://aka.ms/getwinget
exit /b 1

:refresh_path
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
