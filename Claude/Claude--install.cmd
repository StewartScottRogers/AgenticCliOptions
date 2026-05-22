@echo off
setlocal

REM ============================================================
REM  Install / update the Claude Code CLI
REM  ------------------------------------------------------------
REM  Installs the 'claude' command globally via npm. Re-running
REM  this script updates an existing install to the latest version.
REM
REM  Requires Node.js 18 or newer - https://nodejs.org
REM ============================================================

REM  Verify npm is on PATH before doing anything.
where npm >nul 2>nul
if errorlevel 1 goto :nonpm

echo Installing the Claude Code CLI globally...
echo     npm install -g @anthropic-ai/claude-code@latest
echo.
call npm install -g @anthropic-ai/claude-code@latest
if errorlevel 1 goto :failed

echo.
echo Claude Code CLI installed. Reported version:
call claude --version
echo.
echo Done. Launch it with Claude--dangerously-skip-permissions.cmd,
echo or run 'claude' directly.
goto :end

:nonpm
echo ERROR: 'npm' was not found on your PATH.
echo Install Node.js 18 or newer first, then re-run this script:
echo.
echo     https://nodejs.org
goto :end

:failed
echo.
echo ERROR: Installation failed - see the npm output above.
echo Common causes: no internet connection, or a global install
echo needing an elevated terminal (Run as administrator).

:end
echo.
pause
endlocal
