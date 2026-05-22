@echo off
setlocal

REM ============================================================
REM  Install / update the OpenAI Codex CLI
REM  ------------------------------------------------------------
REM  Installs the 'codex' command globally via npm. Re-running
REM  this script updates an existing install to the latest version.
REM
REM  Requires Node.js 20 or newer - https://nodejs.org
REM ============================================================

REM  Verify npm is on PATH before doing anything.
where npm >nul 2>nul
if errorlevel 1 goto :nonpm

echo Installing the OpenAI Codex CLI globally...
echo     npm install -g @openai/codex@latest
echo.
call npm install -g @openai/codex@latest
if errorlevel 1 goto :failed

echo.
echo OpenAI Codex CLI installed. Reported version:
call codex --version
echo.
echo Done. Launch it with Codex--run.cmd, or run 'codex' directly.
goto :end

:nonpm
echo ERROR: 'npm' was not found on your PATH.
echo Install Node.js 20 or newer first, then re-run this script:
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
