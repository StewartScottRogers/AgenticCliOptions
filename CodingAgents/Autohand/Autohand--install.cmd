@echo off
setlocal

REM ============================================================
REM  Install / update Autohand Code CLI  --  turn-key installer
REM  ------------------------------------------------------------
REM  Autohand Code CLI is a fast, self-evolving coding agent
REM  that runs in your terminal. OpenRouter is its **default**
REM  provider. See https://autohand.ai/ for docs and
REM  https://github.com/autohandai/code-cli for source.
REM
REM  Install method: the upstream PowerShell installer at
REM  autohand.ai/install.ps1. It downloads the prebuilt
REM  autohand.exe to %LOCALAPPDATA%\autohand\autohand.exe and
REM  adds that dir to the User PATH. Re-running this script
REM  picks up the current release.
REM ============================================================

set "INSTALL_URL=https://autohand.ai/install.ps1"

echo.
echo Installing / updating Autohand Code CLI via the official
echo PowerShell installer...
echo     iwr -useb %INSTALL_URL% ^| iex
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; iwr -useb '%INSTALL_URL%' | iex"
if errorlevel 1 goto :failed

REM  The upstream installer drops autohand.exe but does NOT add
REM  its directory to the User PATH (it just prints copy-paste
REM  instructions). Add the entry to the persistent User PATH so
REM  new terminals can find 'autohand' without manual setup.
set "AH_DIR=%LOCALAPPDATA%\autohand"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p=[Environment]::GetEnvironmentVariable('Path','User'); $needle='%AH_DIR%'; if (($p -split ';') -notcontains $needle) { [Environment]::SetEnvironmentVariable('Path', ($p.TrimEnd(';') + ';' + $needle), 'User'); Write-Host 'Added %AH_DIR% to User PATH.' } else { Write-Host 'User PATH already contains %AH_DIR%.' }"

call :prepend_path "%AH_DIR%"

echo.
where autohand >nul 2>nul
if errorlevel 1 (
    echo NOTE: 'autohand' is not yet on PATH for this shell. Open
    echo a new terminal and run 'autohand --version' to verify.
) else (
    echo Autohand Code CLI installed. Reported version:
    call autohand --version
)
echo.
echo Done. Launch it with Autohand--openrouter.cmd, or run
echo 'autohand' directly. First run prompts you to sign in.
goto :end


REM ============================================================
REM  Helper routines
REM ============================================================

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0


:failed
echo.
echo ERROR: Installation failed - see the output above.
echo Verify https://autohand.ai/ is reachable. Try the installer
echo manually with extra flags:
echo   iwr -useb https://autohand.ai/install.ps1 -OutFile install.ps1
echo   .\install.ps1 -Clean

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
