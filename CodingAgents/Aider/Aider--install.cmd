@echo off
setlocal

REM ============================================================
REM  Install / update Aider  --  turn-key installer
REM  ------------------------------------------------------------
REM  Aider is the classic AI pair-programmer for the terminal.
REM  See https://aider.chat/ for docs.
REM
REM  Checks for and installs EVERY dependency automatically:
REM    - uv (Astral's Python tool installer) - via winget if missing
REM    - CPython 3.12 - uv downloads it automatically
REM    - Aider itself - installed/updated via 'uv tool' from
REM      the 'aider-chat' package on PyPI
REM  Re-running this script updates an existing install.
REM
REM  Aider needs Git installed to track its edits; we ensure it
REM  is present via winget if missing. Git for Windows is also a
REM  dependency of other agents in this repo (Grok, Codebuff,
REM  Oh-My-Pi).
REM ============================================================

call :ensure_uv
if errorlevel 1 goto :failed
call :ensure_git

echo.
echo Installing / updating Aider...
echo     uv tool install --force --python 3.12 --upgrade aider-chat
echo.
call uv tool install --force --python 3.12 --upgrade aider-chat
if errorlevel 1 goto :failed

call uv tool update-shell >nul 2>nul
call :refresh_path

echo.
echo Aider installed. Reported version:
call aider --version
echo.
echo Done. Launch it with Aider--openrouter.cmd, or run 'aider'
echo directly inside a project.
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

:ensure_git
where git >nul 2>nul && exit /b 0
echo.
echo Git was not found - installing Git for Windows (Aider
echo needs it to track edits)...
call :ensure_winget
if errorlevel 1 exit /b 0
winget install --id Git.Git --exact --silent --accept-package-agreements --accept-source-agreements
call :refresh_path
exit /b 0

:ensure_winget
where winget >nul 2>nul && exit /b 0
echo ERROR: 'winget' (Windows Package Manager) was not found.
echo Install "App Installer" from the Microsoft Store, then
echo re-run this script:  https://aka.ms/getwinget
exit /b 1

:refresh_path
call :prepend_path "%ProgramFiles%\Git\cmd"
call :prepend_path "%ProgramFiles%\Git\bin"
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
