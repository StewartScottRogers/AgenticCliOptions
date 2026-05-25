@echo off
setlocal

REM ============================================================
REM  Install Google Antigravity CLI  --  turn-key installer
REM  ------------------------------------------------------------
REM  Antigravity CLI ('agy') is the Go-based successor to Gemini
REM  CLI (Gemini CLI loses Pro/Ultra/free access on 2026-06-18).
REM  See:
REM      https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/
REM      https://antigravity.google/docs/cli-using
REM
REM  Install method: official PowerShell one-liner
REM      irm https://antigravity.google/cli/install.ps1 | iex
REM  The installer:
REM    * downloads agy.exe (with SHA-512 verification)
REM    * places it at  %LOCALAPPDATA%\agy\bin\agy.exe
REM    * runs 'agy install' to add that dir to the User PATH
REM
REM  NO dependencies are needed - agy is a single Go binary
REM  (no Node, no Python, no Git, no winget). Architectures
REM  supported by upstream: windows_amd64 and windows_arm64.
REM
REM  *** This script is NOT an updater. ***
REM  Antigravity CLI self-updates in the background. The official
REM  installer refuses to overwrite an existing agy.exe - re-running
REM  this script prints a "already installed" notice and exits 0.
REM  To force a fresh install, delete the binary first:
REM      del "%LOCALAPPDATA%\agy\bin\agy.exe"
REM
REM  Authentication: 'agy' uses the system keyring and falls back
REM  to a browser-based Google sign-in on first run. SSH/headless
REM  sessions are handed an authorization URL + one-time code.
REM ============================================================

set "AGY_DIR=%LOCALAPPDATA%\agy\bin"
set "AGY_BIN=%AGY_DIR%\agy.exe"

echo.
echo Installing Google Antigravity CLI via the official installer...
echo     irm https://antigravity.google/cli/install.ps1 ^| iex
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; iex (irm 'https://antigravity.google/cli/install.ps1')"
if errorlevel 1 goto :failed

REM  The installer adds %LOCALAPPDATA%\agy\bin to the User PATH,
REM  but this already-running shell still has the old PATH. Prepend
REM  it now so 'agy --version' resolves immediately.
call :prepend_path "%AGY_DIR%"

echo.
where agy >nul 2>nul
if errorlevel 1 (
    if exist "%AGY_BIN%" (
        echo Antigravity CLI installed at:
        echo     %AGY_BIN%
        echo NOTE: 'agy' is not yet on PATH for this shell. Open a new
        echo terminal and run 'agy --version' to verify.
    ) else (
        echo ERROR: Installer reported success but agy.exe was not
        echo found at %AGY_BIN%. See the output above.
        goto :failed
    )
) else (
    echo Antigravity CLI installed. Reported version:
    call agy --version
)

echo.
echo Done. Launch it with Antigravity--run.cmd, or run 'agy' directly.
echo First run will open a browser to sign in with a Google account.

REM  Fan plugin install hooks out to Antigravity (MCP servers, etc.).
call "%~dp0..\Plugins\_apply-plugins.cmd" Antigravity install
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
echo Common causes:
echo   - No internet connection
echo   - PowerShell execution policy blocked the installer
echo   - Antivirus quarantined the downloaded binary
echo   - Unsupported CPU architecture (only amd64 / arm64 supported)
echo Re-run from an elevated terminal if PATH cannot be written.

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
