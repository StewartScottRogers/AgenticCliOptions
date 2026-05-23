@echo off
setlocal

REM ============================================================
REM  Install / update VT Code  --  turn-key installer
REM  ------------------------------------------------------------
REM  VT Code is an open-source coding agent with code-
REM  understanding tooling and shell safety. See
REM  https://github.com/vinhnx/vtcode for source.
REM
REM  Install method: the upstream PowerShell installer at
REM    https://raw.githubusercontent.com/vinhnx/vtcode/main/scripts/install.ps1
REM  It downloads vtcode.exe to %USERPROFILE%\.local\bin and
REM  picks the most recent release that ships a Windows asset
REM  (helpful because upstream flags Windows builds as
REM  "best-effort, may lag behind macOS/Linux").
REM
REM  Re-running this script picks up the latest available
REM  Windows release.
REM ============================================================

set "INSTALL_URL=https://raw.githubusercontent.com/vinhnx/vtcode/main/scripts/install.ps1"

echo.
echo Installing / updating VT Code via the official PowerShell
echo installer...
echo     irm %INSTALL_URL% ^| iex
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; irm '%INSTALL_URL%' | iex"
if errorlevel 1 goto :failed

call :prepend_path "%USERPROFILE%\.local\bin"

echo.
where vtcode >nul 2>nul
if errorlevel 1 (
    echo NOTE: 'vtcode' is not yet on PATH for this shell. Open a
    echo new terminal and run 'vtcode --version' to verify.
) else (
    echo VT Code installed. Reported version:
    call vtcode --version
)
echo.
echo Done. Launch it with VTCode--openrouter.cmd, or run
echo 'vtcode chat' directly.
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
echo Upstream marks Windows artifacts as best-effort - the
echo current release may not ship a Windows binary at all. Try
echo the cargo path instead (needs Rust toolchain):
echo   cargo install vtcode

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
