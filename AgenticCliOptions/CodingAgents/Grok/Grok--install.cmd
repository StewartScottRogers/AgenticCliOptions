@echo off
setlocal

REM ============================================================
REM  Install xAI Grok CLI coding agent  --  turn-key installer
REM  ------------------------------------------------------------
REM  Checks for and installs EVERY dependency automatically:
REM    - Git for Windows (provides bash + curl) - via winget
REM    - the Grok CLI itself - via the official installer,
REM      with an npm package fallback (Node.js auto-installed too)
REM  Re-running this script updates an existing install.
REM
REM  winget (Windows Package Manager) performs the dependency
REM  installs. It ships with Windows 11 and current Windows 10.
REM  Grok is beta software - if install methods have changed,
REM  see https://x.ai/cli
REM  NOTE: There is no official npm package for the Grok CLI.
REM  The npm fallback (grok-build) is a community package and
REM  may not be current. Prefer the official bash installer.
REM ============================================================

REM ---- Primary path: official installer (needs bash + curl) --
call :ensure_git
if errorlevel 1 goto :trynpm
echo.
echo Installing the Grok CLI via the official installer...
call bash -lc "curl -fsSL https://x.ai/cli/install.sh | bash"
if not errorlevel 1 goto :done
echo Official installer failed - falling back to the npm package...

REM ---- Fallback path: npm package -----------------------------
:trynpm
call :ensure_node
if errorlevel 1 goto :failed
echo.
echo Installing the Grok CLI via npm...
call npm install -g grok-build@latest
if errorlevel 1 goto :failed

:done
call :refresh_path
call :ensure_grok_on_path
echo.
echo Grok CLI install step finished. Launch it with Grok--run.cmd,
echo or run 'grok' directly. If 'grok' is not found, open a new
echo terminal so PATH changes take effect.

REM  Fan plugin install hooks out to Grok.
call "%~dp0..\Plugins\_apply-plugins.cmd" Grok install
goto :end


REM ============================================================
REM  Helper routines
REM ============================================================

:ensure_git
REM  Ensure bash + curl are available (Git for Windows provides
REM  both); install Git via winget if bash is missing.
where bash >nul 2>nul && exit /b 0
echo.
echo bash was not found - installing Git for Windows (provides
echo bash and curl)...
call :ensure_winget
if errorlevel 1 exit /b 1
winget install --id Git.Git --exact --silent --accept-package-agreements --accept-source-agreements
call :refresh_path
where bash >nul 2>nul && exit /b 0
echo Git was installed but bash is still not on PATH - will try
echo the npm fallback instead.
exit /b 1

:ensure_node
REM  Ensure Node.js + npm are available; install Node.js LTS via
REM  winget if missing.
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
call :prepend_path "%ProgramFiles%\Git\cmd"
call :prepend_path "%ProgramFiles%\Git\bin"
call :prepend_path "%LOCALAPPDATA%\Microsoft\WinGet\Links"
call :prepend_path "%USERPROFILE%\.grok\bin"
exit /b 0

:ensure_grok_on_path
REM  The official x.ai installer adds ~/.grok/bin to .bashrc only, so
REM  cmd.exe / PowerShell never see 'grok' until we register it on
REM  the User PATH ourselves. Idempotent: only appends if absent.
if not exist "%USERPROFILE%\.grok\bin\grok.exe" exit /b 0
powershell -NoProfile -Command ^
  "$add = [IO.Path]::Combine($env:USERPROFILE, '.grok', 'bin');" ^
  "$p   = [Environment]::GetEnvironmentVariable('PATH','User');" ^
  "if (-not ($p -split ';' | Where-Object { $_ -ieq $add })) {" ^
  "  [Environment]::SetEnvironmentVariable('PATH', ($p.TrimEnd(';') + ';' + $add), 'User');" ^
  "  Write-Host \"Added $add to your User PATH (effective in new terminals).\"" ^
  "}"
exit /b 0

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0


:failed
echo.
echo ERROR: Installation failed - see the output above.
echo Grok is beta software; check https://x.ai/cli for the
echo current install instructions.

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
