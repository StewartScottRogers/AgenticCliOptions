@echo off
setlocal

REM ============================================================
REM  Install / update the Google Gemini CLI
REM  ------------------------------------------------------------
REM  Installs the 'gemini' command globally via npm. Re-running
REM  this script updates an existing install to the latest version.
REM
REM  Requires Node.js 20 or newer - https://nodejs.org
REM ============================================================

REM  Verify npm is on PATH before doing anything.
where npm >nul 2>nul
if errorlevel 1 goto :nonpm

echo Installing the Google Gemini CLI globally...
echo     npm install -g @google/gemini-cli@latest
echo.
call npm install -g @google/gemini-cli@latest
if errorlevel 1 goto :failed

echo.
echo Google Gemini CLI installed. Reported version:
call gemini --version
echo.
echo Done. Launch it with Gemini--run.cmd, or run 'gemini' directly.
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
