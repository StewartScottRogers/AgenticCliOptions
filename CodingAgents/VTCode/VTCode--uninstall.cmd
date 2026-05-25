@echo off
setlocal

REM ============================================================
REM  Uninstall VT Code  --  matching uninstaller
REM  ------------------------------------------------------------
REM  The upstream installer ships no uninstall command. We
REM  delete the vtcode.exe shim from %USERPROFILE%\.local\bin.
REM  That directory itself is shared with Junie / Mistral / Trae,
REM  so it is NOT removed.
REM
REM  What this DOES NOT remove (on purpose):
REM    - %USERPROFILE%\.vtcode  (config, sessions, API keys -
REM      if vtcode writes there)
REM    - Any workspace-local vtcode.toml files
REM  Delete by hand if you want a fully clean slate.
REM ============================================================

REM  Tear down plugin entries BEFORE removing the CLI.
call "%~dp0..\Plugins\_apply-plugins.cmd" VTCode uninstall

set "VT_BIN=%USERPROFILE%\.local\bin\vtcode.exe"

if exist "%VT_BIN%" (
    echo Removing %VT_BIN% ...
    del /f /q "%VT_BIN%"
) else (
    echo %VT_BIN% not present - nothing to remove.
)

echo.
where vtcode >nul 2>nul
if errorlevel 1 (
    echo VT Code removed.
) else (
    echo NOTE: 'vtcode' is still resolvable on PATH. It may be a
    echo cargo / homebrew copy. Run 'where vtcode' to investigate.
)
echo.
echo Done. Any ~/.vtcode config was NOT touched - delete it
echo manually if you want a fully clean slate.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
