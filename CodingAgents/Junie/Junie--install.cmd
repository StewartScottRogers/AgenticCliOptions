@echo off
setlocal

REM ============================================================
REM  Install / update Junie CLI (JetBrains)  --  turn-key installer
REM  ------------------------------------------------------------
REM  Junie is JetBrains' AI coding agent for the terminal. See
REM  https://junie.jetbrains.com/ for docs.
REM
REM  Install method: the upstream PowerShell installer
REM      iex (irm 'https://junie.jetbrains.com/install.ps1')
REM  Drops a shim at %USERPROFILE%\.local\bin\junie.bat and the
REM  actual binaries under %USERPROFILE%\.local\share\junie\.
REM  Junie self-updates: re-running this script reinstalls the
REM  current release; the running binary applies pending updates
REM  on next launch.
REM
REM  Other agents in this repo (Mistral, Trae) also add
REM  %USERPROFILE%\.local\bin to PATH, so the shim is reachable
REM  for new terminals automatically.
REM ============================================================

set "INSTALL_URL=https://junie.jetbrains.com/install.ps1"

echo.
echo Installing / updating Junie CLI via the official PowerShell
echo installer...
echo     iex (irm %INSTALL_URL%)
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; iex (irm '%INSTALL_URL%')"
if errorlevel 1 goto :failed

REM  Make the freshly installed shim reachable in this shell.
call :prepend_path "%USERPROFILE%\.local\bin"

echo.
where junie >nul 2>nul
if errorlevel 1 (
    echo NOTE: 'junie' is not yet on PATH for this shell. Open a
    echo new terminal and run 'junie --version' to verify.
) else (
    echo Junie installed. Reported version:
    call junie --version
)
echo.
echo Done. Launch it with Junie--openrouter.cmd or 'junie' in a
echo project directory. Use /account inside the TUI to switch
echo providers.
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
echo Verify https://junie.jetbrains.com/ is reachable and that
echo PowerShell can run remote scripts (the script uses Bypass).

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
