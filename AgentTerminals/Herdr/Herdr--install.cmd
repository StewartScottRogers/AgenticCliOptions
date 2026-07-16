@echo off
setlocal

REM ============================================================
REM  Install herdr  --  turn-key installer
REM  ------------------------------------------------------------
REM  herdr is a terminal multiplexer built for AI coding agents:
REM  a single ~10MB Rust binary that runs Claude Code, Codex,
REM  Gemini, Copilot CLI and 15+ terminal agents in parallel
REM  panes with per-agent state awareness (blocked / working /
REM  done / idle), session persistence, and a local socket API.
REM  See https://herdr.dev/ and https://herdr.dev/docs/.
REM
REM  Install method: official PowerShell one-liner
REM      irm https://herdr.dev/install.ps1 | iex
REM  The installer:
REM    * reads the PREVIEW channel manifest (https://herdr.dev/preview.json)
REM      - Windows is preview-only for now; 'herdr channel set
REM        stable' is rejected on Windows.
REM    * downloads herdr.exe (x86_64; ARM64 runs the x64 build
REM      under emulation) into a versioned release dir under
REM      %USERPROFILE%\.herdr\packages\...
REM    * exposes it as %LOCALAPPDATA%\Programs\Herdr\bin\herdr.exe
REM      via a 'current' junction and prepends that bin dir to the
REM      User PATH.
REM    * verifies the binary with 'herdr --version'.
REM
REM  NO dependencies are needed - herdr is a single Rust binary
REM  (no Node, no Python, no Git, no winget).
REM
REM  Re-running is safe: the installer keeps the last 3 releases
REM  and skips a re-download if the target version is already
REM  present. To pull the newest build later, use Herdr--update.cmd
REM  ('herdr update'), which is the supported upgrade path.
REM ============================================================

set "HERDR_DIR=%LOCALAPPDATA%\Programs\Herdr\bin"
set "HERDR_BIN=%HERDR_DIR%\herdr.exe"

echo.
echo Installing herdr via the official installer...
echo     irm https://herdr.dev/install.ps1 ^| iex
echo (Windows support is in beta - this uses the preview channel.)
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; iex (irm 'https://herdr.dev/install.ps1')"
if errorlevel 1 goto :failed

REM  The installer adds %LOCALAPPDATA%\Programs\Herdr\bin to the
REM  User PATH, but this already-running shell still has the old
REM  PATH. Prepend it now so 'herdr --version' resolves immediately.
call :prepend_path "%HERDR_DIR%"

echo.
where herdr >nul 2>nul
if errorlevel 1 (
    if exist "%HERDR_BIN%" (
        echo herdr installed at:
        echo     %HERDR_BIN%
        echo NOTE: 'herdr' is not yet on PATH for this shell. Open a new
        echo terminal and run 'herdr --version' to verify.
    ) else (
        echo ERROR: Installer reported success but herdr.exe was not
        echo found at %HERDR_BIN%. See the output above.
        goto :failed
    )
) else (
    echo herdr installed. Reported version:
    call herdr --version
)

echo.
echo Done. Launch it with Herdr--run.cmd, or run 'herdr' directly.
echo First run starts a background server and drops you into a pane;
echo start your agents inside it and watch their state in the sidebar.
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
echo   - Unsupported platform (herdr is Windows x64 / ARM64 only;
echo     32-bit is rejected)

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
